package Widgets.Windows.Breeding
{
   import Classes.FeatureBuilding;
   import Classes.MutableAnimalCrate;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.FarmGameSettingsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   
   public class BabyNurseryContentsWindow extends NurseryContentsWindow
   {
      
      public function BabyNurseryContentsWindow(building:FeatureBuilding)
      {
         super(building);
      }
      
      override protected function initFeatureWidgets() : void
      {
         super.initFeatureWidgets();
         m_contentTab_bt = new FarmAnimatedTextButton(m_window.animalsTab_mc,ZLocUtils.t("Dialogs","Babies"),onShowContents);
      }
      
      private function get feedItemsArray() : Array
      {
         var name:String = null;
         var testItem:FarmItem = null;
         var marketItems:Array = new Array();
         for(var i:int = 0; i < MutableAnimalCrate.MINI_MARKET_ITEMS.length; i++)
         {
            name = MutableAnimalCrate.MINI_MARKET_ITEMS[i];
            testItem = Global.farmGameSettingsManager.getFarmItemByName(name);
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               if(Boolean(testItem) && Boolean(testItem.checkExperimentGate(null)))
               {
                  marketItems.push(testItem.name);
               }
            }
            else if(Boolean(testItem) && Boolean(testItem.checkExperimentGate(testItem.xml)))
            {
               marketItems.push(testItem.name);
            }
         }
         return marketItems;
      }
      
      override protected function get containeePartMarketItems() : Array
      {
         return this.feedItemsArray;
      }
   }
}

