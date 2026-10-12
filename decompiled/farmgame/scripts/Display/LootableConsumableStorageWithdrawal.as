package Display
{
   import Classes.StorageBuilding;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Transactions.TUseLootableConsumable;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class LootableConsumableStorageWithdrawal extends PottingShedWithdrawal
   {
      
      public function LootableConsumableStorageWithdrawal(storage:StorageBuilding)
      {
         m_dialogAsset = "assets/dialogs/FV_PottingShed.swf";
         m_dialogType = "lootableConsumableStorage";
         super(storage);
      }
      
      override protected function onUse(event:Event) : void
      {
         var itemName:String = event.target.name;
         var itemCode:String = Global.farmGameSettingsManager.getFarmItemByName(itemName).code;
         this.removeItemFromStorage(itemCode);
         TransactionManager.addTransaction(new TUseLootableConsumable(itemName,false,m_building.getId()));
         onCloseClick(new MouseEvent(MouseEvent.CLICK));
         FarmStatsManager.count(m_dialogType,"click_use");
      }
      
      private function removeItemFromStorage(itemCode:String) : void
      {
         m_building.removeContents(itemCode);
         m_window.current_tf.text = ZLocUtils.t("Dialogs","Current",{"quantity":m_building.count});
         --m_usedTypes[itemCode];
      }
   }
}

