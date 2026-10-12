package Transactions
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericXMLDialog;
   import Display.SpecialDeliveryBoxShowRewardDialog;
   import Display.UI;
   import Widgets.Slots.GiftBox.GiftBoxSlot;
   
   public class TUseAllSpecialDelivery extends TFarmTransaction
   {
      
      public static const SPECIAL_DELIVERY_BOX_ITEM_NAME:String = "socialplumbingmysterygift";
      
      private var m_itemToUse:FarmItem;
      
      private var m_quantity:int;
      
      private var m_dialog:GenericXMLDialog;
      
      public function TUseAllSpecialDelivery(item:FarmItem, quantity:int)
      {
         this.m_itemToUse = item;
         this.m_quantity = quantity;
         this.showOpeningDialog();
         super();
      }
      
      override public function perform() : void
      {
         if(this.m_itemToUse.className == GiftBoxSlot.RTUE_DELIVERY_CLASS_NAME)
         {
            signedCall("SpecialDeliveryService.openAllRtue",this.m_quantity);
         }
         else
         {
            signedCall("SpecialDeliveryService.openAll",this.m_quantity);
         }
      }
      
      protected function showOpeningDialog() : void
      {
         this.m_dialog = new GenericXMLDialog(null,"",null,null,NaN,NaN,ZLocUtils.t("Dialogs","UseAll_DialogOpeningBoxes"));
         UI.displayPopup(this.m_dialog,false);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var i:Number = NaN;
         var sdbGiftItem:Object = null;
         var quantity:Number = NaN;
         var itemCode:String = null;
         var item:FarmItem = null;
         var sender:String = null;
         this.m_dialog.close();
         this.m_dialog = null;
         var sdbItems:Array = new Array();
         var totalSDBItems:Number = 0;
         if(result != null)
         {
            for(i = 0; i < result.length; i++)
            {
               sdbGiftItem = new Object();
               quantity = Number(result[i]["quantity"]);
               itemCode = result[i]["code"].toString();
               item = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
               sender = "0";
               Global.player.removeGiftWithKey(this.m_itemToUse.code,quantity);
               Global.player.addGift(item.name,sender,quantity);
               sdbGiftItem.friendlyName = item.friendlyName;
               sdbGiftItem.quantity = quantity;
               sdbGiftItem.iconUrl = item.iconUrl;
               sdbItems.push(sdbGiftItem);
               totalSDBItems += quantity;
            }
            UI.displayPopup(new SpecialDeliveryBoxShowRewardDialog(sdbItems,totalSDBItems));
         }
      }
   }
}

