package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   import Events.FarmGameWorldEvent;
   import Managers.FeatureOptionsManager;
   
   public class AmexImageProgressionFStateObject extends DeferredFStateObject
   {
      
      private var m_treeLevel:int;
      
      public function AmexImageProgressionFStateObject(owner:FeatureBuilding)
      {
         super(owner);
      }
      
      override protected function getDeferredEventName() : String
      {
         return FarmGameWorldEvent.USER_CHANGED;
      }
      
      override protected function checkDeferredCondition() : Boolean
      {
         return FeatureOptionsManager.getInstance().loaded;
      }
      
      override protected function doSetProgression(redraw:Boolean = false) : void
      {
         var treeData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.FEATURE_AMEX_TREE,"tree_data");
         if(treeData != null && treeData.hasOwnProperty("level"))
         {
            this.m_treeLevel = (treeData.level - 1) * 2;
         }
         else
         {
            this.m_treeLevel = (m_owner.storageLevel - 1) * 2;
         }
         var harvestable:int = m_owner.getState() == FeatureBuilding.STATE_BARE ? 0 : 1;
         var displayState:int = this.m_treeLevel + harvestable;
         var state:String = m_owner.getState();
         var numImages:int = m_owner.numImageStates;
         if(numImages > 0 && displayState > numImages)
         {
            displayState = numImages;
         }
         m_owner.setOverlayOverride(displayState,redraw);
      }
   }
}

