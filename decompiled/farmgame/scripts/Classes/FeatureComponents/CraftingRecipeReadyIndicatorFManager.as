package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   
   public class CraftingRecipeReadyIndicatorFManager extends ArrowIndicatorFManager implements IStateIndicatorComponent
   {
      
      public static const INDICATOR_STATE_PLURAL:String = "plural";
      
      public static const INDICATOR_STATE_STATION_EMPTY:String = "empty";
      
      public static const INDICATOR_STATE_STATION_EXPAND:String = "expand";
      
      protected static const OVERRIDE_ARROW_HORIZONTAL_OFFSET:Number = 30;
      
      protected static const OVERRIDE_ARROW_VERTICAL_OFFSET:Number = 40;
      
      public function CraftingRecipeReadyIndicatorFManager(owner:FeatureBuilding)
      {
         super(owner);
         hide();
      }
      
      public function changeStateIcon(stateName:String, fileName:String) : void
      {
         m_states[stateName].icon = Global.getAssetURL(fileName);
      }
      
      public function showIndicator(state:String = "default") : void
      {
         drawIndicator(state);
         this.m_owner.conditionallyRedraw(true);
      }
      
      override protected function getHorizontalOffset() : Number
      {
         return OVERRIDE_ARROW_HORIZONTAL_OFFSET;
      }
      
      override protected function getVerticalOffset() : Number
      {
         return OVERRIDE_ARROW_VERTICAL_OFFSET;
      }
      
      override public function onClick() : void
      {
         super.onClick();
         m_owner.displayStorageDialog();
      }
   }
}

