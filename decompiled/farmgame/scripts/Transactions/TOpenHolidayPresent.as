package Transactions
{
   import Classes.LootableDecoration;
   import Classes.StorageBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.HolidayTreePopup;
   import Display.UI;
   
   public class TOpenHolidayPresent extends TOpenLootItem
   {
      
      public function TOpenHolidayPresent(lootItem:LootableDecoration, building:StorageBuilding, isTrade:Boolean, codes:Object = null)
      {
         super(lootItem);
         m_params = new Object();
         m_params.buildingId = building.getId();
         m_params.isTrade = isTrade;
         if(codes != null)
         {
            m_params.codes = codes;
         }
         m_popup = UI.displayMessage(ZLocUtils.t("Dialogs","HolidayPresent_OpeningBox"),GenericPopup.TYPE_MODAL,null,"",true);
      }
      
      override public function perform() : void
      {
         signedWorldAction("openOrTrade",m_params);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var itemName:String = null;
         var item:FarmItem = null;
         m_popup.close();
         if(result)
         {
            if(result.item)
            {
               itemName = result.item.toString();
               Global.player.addGift(itemName);
               m_wonItemName = itemName;
               item = Global.farmGameSettingsManager.getFarmItemByName(m_wonItemName);
               UI.displayPopup(new HolidayTreePopup(updateXP,item,m_params.isTrade,result.rewardLink),false);
            }
            else if(result.error)
            {
               UI.displayMessage(ZLocUtils.t("Dialogs",m_lootItem.itemName + "_" + result.error));
            }
         }
      }
   }
}

