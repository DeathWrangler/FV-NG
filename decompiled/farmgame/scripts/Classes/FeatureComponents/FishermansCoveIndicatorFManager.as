package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   
   public class FishermansCoveIndicatorFManager extends IntervalIndicatorFManager implements IStateIndicatorComponent
   {
      
      private static const INDICATOR_X_OFFSET:Number = 254;
      
      private static const INDICATOR_Y_OFFSET:Number = 573;
      
      public function FishermansCoveIndicatorFManager(owner:FeatureBuilding)
      {
         super(owner);
      }
      
      override protected function createIndicator(state:String) : void
      {
         var arrowState:Object = null;
         for each(arrowState in this.m_states)
         {
            arrowState["icon"] = this.getExpandFeedImage();
         }
         super.createIndicator(state);
      }
      
      override protected function getHorizontalOffset() : Number
      {
         return INDICATOR_X_OFFSET;
      }
      
      override protected function getVerticalOffset() : Number
      {
         return INDICATOR_Y_OFFSET;
      }
      
      override public function onClick() : void
      {
         super.onClick();
         m_owner.displayStorageDialog();
      }
      
      protected function getExpandFeedImage() : String
      {
         var level:String = String(this.m_owner.storageLevel + 1);
         return Global.getAssetURL("assets/buildings/building_" + this.m_owner.getItem().name + "_" + level + "_icon.png");
      }
      
      override public function canDisplay() : Boolean
      {
         return false;
      }
   }
}

