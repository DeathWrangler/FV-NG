package Transactions
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.FarmStatsManager;
   import Widgets.Constants.Market.Currency;
   
   public class TBuyItemPutGiftbox extends TFarmTransaction
   {
      
      private var m_item:FarmItem = null;
      
      private var m_currency:String = "coins";
      
      private var m_quantity:int = 1;
      
      private var m_showPopup:Boolean = true;
      
      private var m_forceGift:Boolean = false;
      
      private var m_successCallBack:Function;
      
      private var m_assumeSuccess:Boolean;
      
      public function TBuyItemPutGiftbox(item:FarmItem, currency:String, quantity:int = 1, showPopup:Boolean = true, forceGift:Boolean = false, successCallback:Function = null, assumeSuccess:Boolean = false)
      {
         super();
         this.m_item = item;
         this.m_currency = currency;
         this.m_quantity = quantity;
         this.m_showPopup = showPopup;
         this.m_forceGift = forceGift;
         this.m_successCallBack = successCallback;
         this.m_assumeSuccess = assumeSuccess;
         if(this.m_assumeSuccess)
         {
            this.updateClient();
         }
      }
      
      override public function perform() : void
      {
         signedCall("UserService.buyItemPutGiftbox",this.m_item.name,this.m_quantity,this.m_forceGift);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result != null)
         {
            if(result.success == true)
            {
               if(!this.m_assumeSuccess)
               {
                  this.updateClient();
               }
               Global.player.xp += result.xpGain;
               if(this.m_successCallBack !== null)
               {
                  this.m_successCallBack.call(null,result);
               }
            }
         }
      }
      
      private function updateClient() : void
      {
         var isValidCurrency:Boolean = false;
         var iCash:int = 0;
         var cash:int = 0;
         var iCoin:int = 0;
         var cost:int = 0;
         var title:String = null;
         var message:String = null;
         switch(this.m_currency)
         {
            case Currency.CASH:
               isValidCurrency = true;
               for(iCash = 0; iCash < this.m_quantity; iCash++)
               {
                  FarmStatsManager.count("model_farm","buys_item","cash",this.m_item.name,String(this.m_item.cash));
               }
               cash = this.m_item.realCashCost * this.m_quantity;
               if(cash > 0)
               {
                  Global.player.cash -= cash;
               }
               break;
            case Currency.COINS:
               isValidCurrency = true;
               for(iCoin = 0; iCoin < this.m_quantity; iCoin++)
               {
                  FarmStatsManager.count("model_farm","buys_item","coin",this.m_item.name,String(this.m_item.cost));
               }
               cost = this.m_item.cost * this.m_quantity;
               if(cost > 0)
               {
                  Global.player.gold -= cost;
               }
         }
         if(isValidCurrency)
         {
            Global.player.addGift(this.m_item.name,"0",this.m_quantity);
            if(this.m_showPopup == true)
            {
               title = ZLocUtils.t("Dialogs","PromoFarm_ModelFarmNPC_PurchaseConfirm_title");
               if(this.m_item.className == "CSeedPackage")
               {
                  message = ZLocUtils.t("Dialogs","PromoFarm_ModelFarmNPC_seeds");
               }
               else if(this.m_quantity > 1)
               {
                  message = ZLocUtils.t("Dialogs","PromoFarm_ModelFarmNPC_items");
               }
               else
               {
                  message = ZLocUtils.t("Dialogs","PromoFarm_ModelFarmNPC_PurchaseConfirm_body",{"item":ZLocUtils.tk_pk(this.m_item.friendlyName)});
               }
               UI.showMessage(message,UI.BUTTON_LAYOUT_OK,title,this.m_item.iconRelativeUrl);
            }
         }
      }
   }
}

