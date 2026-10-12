package Classes.MOTD
{
   import Classes.Constants.WorldsConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.DataDrivenOkayPopup;
   import Display.UI;
   
   public class ItemByWorldMOTDHandler extends MOTDHandler
   {
      
      protected var m_itemName:String = "";
      
      public function ItemByWorldMOTDHandler(currentMOTD:Object)
      {
         super(currentMOTD);
      }
      
      override public function execute() : void
      {
         var farmItem:FarmItem = null;
         var farmItemName:String = null;
         var params:Array = null;
         var displayPopup:DataDrivenOkayPopup = null;
         var imageUrl:String = "";
         var title:String = "";
         var text:String = "";
         var buttonText:String = "";
         var itemCode:String = this.getItemByWorldType();
         if(itemCode != "")
         {
            farmItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
            if(this.canGift(farmItem))
            {
               farmItemName = Global.farmGameSettingsManager.getFarmItemByCode(m_currentMOTD.itemCodes.@farm).name;
               this.m_itemName = farmItem.name;
               Global.player.addGift(this.m_itemName);
               imageUrl = m_currentMOTD.icon;
               title = ZLocUtils.t("Dialogs","MOTD_" + farmItemName + "_Title");
               text = ZLocUtils.t("Dialogs","MOTD_" + farmItemName + "_Text");
               buttonText = ZLocUtils.t("Dialogs","MOTD_" + farmItemName + "_ButtonText");
               params = [imageUrl,text,title,buttonText];
               displayPopup = new DataDrivenOkayPopup(MOTD_DIALOG_NAME_NO_CANCEL,params,this.acceptMOTD);
               UI.displayPopup(displayPopup,false);
            }
         }
         super.execute();
      }
      
      private function canGift(farmItem:FarmItem) : Boolean
      {
         var result:Boolean = true;
         var giftItemLimit:int = parseInt(farmItem["limit"]);
         var giftItemsInWorld:Array = Global.world.getObjectsByNames([farmItem.name]);
         var giftItemsInBox:int = Global.player.getGiftCountForItem(farmItem.name);
         if(giftItemLimit > 0 && giftItemsInWorld.length + giftItemsInBox >= giftItemLimit)
         {
            result = false;
         }
         return result;
      }
      
      private function getItemByWorldType() : String
      {
         var result:String = "";
         if(m_currentMOTD.itemCodes != null)
         {
            if(Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_HOME)
            {
               result = m_currentMOTD.itemCodes.@farm;
            }
            else
            {
               result = m_currentMOTD.itemCodes.@england;
            }
         }
         return result;
      }
      
      override protected function acceptMOTD() : void
      {
         super.acceptMOTD();
         Global.world.enterForcePlaceMode(this.m_itemName,true);
      }
   }
}

