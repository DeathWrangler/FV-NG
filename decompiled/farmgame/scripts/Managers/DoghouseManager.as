package Managers
{
   import Classes.FeatureBuilding;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.Doghouse.DoghouseContentsWindow;
   import Widgets.Windows.Doghouse.DoghouseFetchResultsWindow;
   
   public class DoghouseManager
   {
      
      private static var m_fetchTransactionPending:Boolean;
      
      private static var m_fetchAmount:int;
      
      private static var m_fetchBuilding:FeatureBuilding;
      
      private static var m_currentContentsWindow:DoghouseContentsWindow;
      
      public function DoghouseManager()
      {
         super();
      }
      
      public static function get transactionPending() : Boolean
      {
         return m_fetchTransactionPending;
      }
      
      public static function get currentContentsWindow() : DoghouseContentsWindow
      {
         return m_currentContentsWindow;
      }
      
      public static function set currentContentsWindow(value:DoghouseContentsWindow) : void
      {
         m_currentContentsWindow = value;
      }
      
      public static function getFetchConsumableItemName(building:FeatureBuilding) : String
      {
         return building.harvester.harvestReward.name;
      }
      
      public static function getFetchConsumableItemCount(building:FeatureBuilding) : int
      {
         return Global.player.getGiftCountForItem(getFetchConsumableItemName(building));
      }
      
      public static function fetch(building:FeatureBuilding, amount:int) : void
      {
         if(!m_fetchTransactionPending)
         {
            m_fetchTransactionPending = true;
            m_fetchAmount = amount;
            m_fetchBuilding = building;
            Global.player.removeGiftWithKey(Global.farmGameSettingsManager.getFarmItemCodeByName(getFetchConsumableItemName(m_fetchBuilding)),m_fetchAmount);
            if(m_currentContentsWindow)
            {
               m_currentContentsWindow.refresh();
            }
            TransactionManager.addTransaction(new TGenericTransaction("DoghouseService","fetch",fetchTransactionCallback,[m_fetchBuilding.getSaveObject(),m_fetchAmount]),true);
         }
      }
      
      private static function fetchTransactionCallback(result:Object) : void
      {
         m_fetchTransactionPending = false;
         if(Boolean(result["complete"]) && Boolean(result["lootItem"]) && Boolean(result["lootQuantity"]))
         {
            Global.player.addGift(String(result["lootItem"]),"0",int(result["lootQuantity"]));
            UI.displayPopup(new DoghouseFetchResultsWindow(m_fetchBuilding,result),false);
            if(m_currentContentsWindow)
            {
               m_currentContentsWindow.refresh();
            }
         }
      }
   }
}

