package Widgets.Windows.Breeding
{
   import Classes.FeatureBuilding;
   import Classes.MysterySeedling;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   
   public class SeedlingNurseryContentsWindow extends NurseryContentsWindow
   {
      
      public function SeedlingNurseryContentsWindow(building:FeatureBuilding)
      {
         super(building);
      }
      
      override protected function initFeatureWidgets() : void
      {
         super.initFeatureWidgets();
         m_contentTab_bt = new FarmAnimatedTextButton(m_window.animalsTab_mc,ZLocUtils.t("Dialogs","Seedlings"),onShowContents);
      }
      
      private function get feedItemsArray() : Array
      {
         return MysterySeedling.MINI_MARKET_ITEMS;
      }
      
      override protected function get containeePartMarketItems() : Array
      {
         return this.feedItemsArray;
      }
   }
}

