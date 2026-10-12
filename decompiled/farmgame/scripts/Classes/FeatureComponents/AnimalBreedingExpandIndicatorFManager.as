package Classes.FeatureComponents
{
   import Classes.Constants.Experiments;
   import Classes.FeatureBuilding;
   import Events.FarmGameWorldEvent;
   import Managers.FarmStatsManager;
   
   public class AnimalBreedingExpandIndicatorFManager extends ArrowIndicatorFManager implements IStateIndicatorComponent
   {
      
      private static const INDICATOR_X_OFFSET:Number = 65;
      
      private static const INDICATOR_Y_OFFSET:Number = 110;
      
      private static const ALTERNATIVE_OFFSET_STATE:String = "expand";
      
      public function AnimalBreedingExpandIndicatorFManager(owner:FeatureBuilding)
      {
         super(owner);
      }
      
      override protected function getHorizontalOffset() : Number
      {
         var result:int = INDICATOR_X_OFFSET;
         if(m_states[ALTERNATIVE_OFFSET_STATE] != null && m_states[ALTERNATIVE_OFFSET_STATE].horizontalIndicatorOffset != null)
         {
            result = int(m_states[ALTERNATIVE_OFFSET_STATE].horizontalIndicatorOffset);
         }
         return result;
      }
      
      override protected function getVerticalOffset() : Number
      {
         var result:int = INDICATOR_Y_OFFSET;
         if(m_states[ALTERNATIVE_OFFSET_STATE] != null && m_states[ALTERNATIVE_OFFSET_STATE].verticalIndicatorOffset != null)
         {
            result = int(m_states[ALTERNATIVE_OFFSET_STATE].verticalIndicatorOffset);
         }
         return result;
      }
      
      override public function onClick() : void
      {
         super.onClick();
         Global.player.setSeenFlag(this.getBuildingSeenFlag());
         m_owner.displayStorageDialog("expand");
         FarmStatsManager.count("expand_arrow",m_owner.bldgName,"click");
      }
      
      override public function get lookInsideOnClick() : Boolean
      {
         return true;
      }
      
      override public function canDisplay() : Boolean
      {
         var result:Boolean = false;
         if(!Global.player.getSeenFlag(this.getBuildingSeenFlag()) && !Global.worldManager.isVisiting())
         {
            result = true;
         }
         return result;
      }
      
      override public function show(state:String = "default") : void
      {
         if(Global.player.isDataLoaded)
         {
            if(state == DEFAULT_STATE)
            {
               state = EXPAND_STATE;
            }
            if(!Global.player.getSeenFlag(this.getBuildingSeenFlag(state)))
            {
               switch(state)
               {
                  case EXPAND_STATE:
                     if(owner.isBuilt() && !owner.hasReachedMaxExpansionLevel())
                     {
                        super.show(state);
                     }
                     break;
                  default:
                     super.show(state);
               }
            }
         }
         else
         {
            m_delayedShowState = state;
            if(!m_isDelayedShow)
            {
               m_isDelayedShow = true;
               Global.world.addEventListener(FarmGameWorldEvent.USER_CHANGED,onDelayedShow,false,0,true);
            }
         }
      }
      
      protected function getBuildingSeenFlag(state:String = null) : String
      {
         var result:String = null;
         var variant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_ANIMAL_BREEDING_EXPANSION_V2);
         if(Boolean(variant) && variant == 2)
         {
            result = owner.bldgName + Global.worldManager.getWorldFriendlyName() + "_seenExpansionArrowV2";
         }
         else
         {
            result = owner.bldgName + "_seenExpansionArrow";
         }
         return result;
      }
      
      override public function hide() : void
      {
         if(m_isDelayedShow)
         {
            Global.world.removeEventListener(FarmGameWorldEvent.USER_CHANGED,onDelayedShow);
            m_isDelayedShow = false;
         }
         else
         {
            super.hide();
         }
      }
   }
}

