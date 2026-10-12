package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   import Engine.Managers.ErrorManager;
   import Events.FarmGameWorldEvent;
   
   public class ImageProgressionFObject extends BaseImageProgressionObject
   {
      
      private static const PROGRESS_MIN_COMPARE:String = "min";
      
      private static const PROGRESS_NO_COMPARE:String = "none";
      
      private var m_levels:Array;
      
      private var m_countMethod:String;
      
      private var m_compareMethod:String;
      
      private var m_deferredCall:Boolean = false;
      
      public function ImageProgressionFObject(owner:FeatureBuilding)
      {
         super(owner);
         var progressionData:Object = Global.farmGameSettingsManager.getBuildingProgressionData(owner.bldgName);
         this.m_levels = progressionData["levels"];
         this.m_countMethod = progressionData["countMethod"];
         this.m_compareMethod = progressionData["compareMethod"];
         if(this.m_levels.length == 0)
         {
            ErrorManager.addError("ImageProgressionFObject: no level definitions in gameSettings.xml for " + owner.featureName);
         }
      }
      
      override public function setProgression() : void
      {
         if(Boolean(Global.player) && Global.player.isDataLoaded)
         {
            this.doSetProgression();
         }
         else if(!this.m_deferredCall)
         {
            this.m_deferredCall = true;
            Global.world.addEventListener(FarmGameWorldEvent.USER_CHANGED,this.deferredSetProgression,false,0,true);
         }
      }
      
      public function deferredSetProgression(event:FarmGameWorldEvent) : void
      {
         Global.world.removeEventListener(FarmGameWorldEvent.USER_CHANGED,this.deferredSetProgression);
         this.m_deferredCall = false;
         this.doSetProgression(true);
      }
      
      public function doSetProgression(redraw:Boolean = false) : void
      {
         var levelByCapacity:int = m_owner.storageLevel - 1;
         var levelByProgressionCount:int = this.getProgressionLevel();
         var level:int = 0;
         switch(this.m_compareMethod)
         {
            case PROGRESS_NO_COMPARE:
               level = levelByProgressionCount;
               break;
            case PROGRESS_MIN_COMPARE:
            default:
               level = Math.min(levelByCapacity,levelByProgressionCount);
         }
         m_owner.setOverlayOverride(level + 1,redraw);
      }
      
      protected function getProgressionCount() : int
      {
         var masteryType:String = null;
         var result:int = 0;
         switch(this.m_countMethod)
         {
            case FeaturedRenderFManager.PROGRESS_COUNT_MASTERY:
               masteryType = Global.farmGameSettingsManager.getString(m_owner.featureName + "MasteryType");
               result = Global.player.getMasteredCountByType(masteryType);
               break;
            case FeaturedRenderFManager.PROGRESS_COUNT_LEVEL:
               result = m_owner.storageLevel - 1;
               break;
            case FeaturedRenderFManager.PROGRESS_COUNT_CONTENTS:
            default:
               result = m_owner.count;
         }
         return result;
      }
      
      protected function getProgressionLevel() : int
      {
         var progressionCount:int = this.getProgressionCount();
         var level:int = 0;
         for(var i:int = 0; i < this.m_levels.length; i++)
         {
            if(progressionCount < this.m_levels[i])
            {
               break;
            }
            level = i;
         }
         return level;
      }
   }
}

