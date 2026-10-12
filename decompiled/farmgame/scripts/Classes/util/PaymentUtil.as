package Classes.util
{
   import Cache.Classes.ZCacheUtil;
   import Managers.InGamePaymentsManager;
   
   public class PaymentUtil
   {
      
      public static const FB_RESP_ERROR_CODE:String = "error_code";
      
      public static const FB_RESP_ERROR_MSG:String = "error_message";
      
      public static const FB_RESP_ORDER_ID:String = "order_id";
      
      public static const FB_RESP_STATUS:String = "status";
      
      private static const ADD_TO_CART:String = "FarmNS.PaymentManager.addToCart";
      
      private static const CASH_PAYMENT_ITEM_CODE:String = "0:22616";
      
      private static const GIFT_GRANT_CATEGORY:String = "2";
      
      private static const SOCIAL_CHARITY_GRANT_CATEGORY:String = "3";
      
      private static var s_instance:PaymentUtil = new PaymentUtil();
      
      public function PaymentUtil()
      {
         super();
      }
      
      public static function get instance() : PaymentUtil
      {
         return s_instance;
      }
      
      public static function getPricePoint(cashNeeded:int) : Number
      {
         var cashPackage:Object = null;
         var packageAmount:int = 0;
         var difference:int = 0;
         var cashPackages:Array = InGamePaymentsManager.packages;
         var smallestPackageAmount:Number = 0;
         var cashAfterDeduction:int = Global.player.cash - cashNeeded;
         for each(cashPackage in cashPackages)
         {
            packageAmount = parseInt(cashPackage["amount"]);
            difference = packageAmount + cashAfterDeduction;
            if(difference >= 0 && (packageAmount < smallestPackageAmount || smallestPackageAmount == 0))
            {
               smallestPackageAmount = packageAmount;
            }
         }
         return smallestPackageAmount;
      }
      
      public function addToCart(itemCode:String, quantity:int = 1, ref:String = "", onSuccess:Function = null, onFailure:Function = null) : void
      {
         var grantCode:String = "0:" + FarmGameUtil.itemCodeAsInt(itemCode);
         this.addPaymentItemToCart(grantCode,quantity,ref,onSuccess,onFailure);
      }
      
      public function addGiftToCart(itemCode:String, quantity:int = 1, ref:String = "", onSuccess:Function = null, onFailure:Function = null, overrideTitle:String = "", overrideDescription:String = "", overrideImage:String = "") : void
      {
         var grantCode:String = GIFT_GRANT_CATEGORY + ":" + FarmGameUtil.itemCodeAsInt(itemCode);
         this.addPaymentItemToCart(grantCode,quantity,ref,onSuccess,onFailure,overrideTitle,overrideDescription,overrideImage);
      }
      
      public function addSocialCharityToCart(itemCode:String, quantity:int = 1, ref:String = "", onSuccess:Function = null, onFailure:Function = null) : void
      {
         var grantCode:String = SOCIAL_CHARITY_GRANT_CATEGORY + ":" + FarmGameUtil.itemCodeAsInt(itemCode);
         this.addPaymentItemToCart(grantCode,quantity,ref,onSuccess,onFailure);
      }
      
      public function addCashToCart(quantity:int = 1, ref:String = "", onSuccess:Function = null, onFailure:Function = null) : void
      {
         this.addPaymentItemToCart(CASH_PAYMENT_ITEM_CODE,quantity,ref,onSuccess,onFailure);
      }
      
      public function addPaymentItemToCart(paymentItemCode:String, quantity:int = 1, ref:String = "", onSuccess:Function = null, onFailure:Function = null, overrideTitle:String = "", overrideDescription:String = "", overrideImage:String = "") : void
      {
         var callback:Function = ZCacheUtil.applyPartial(this.onPaymentComplete,this,[onSuccess,onFailure]);
         var callId:String = ExternalUtil.instance.registerCallback(callback);
         ExternalUtil.instance.call(ADD_TO_CART,Global.player.uid,paymentItemCode,quantity,ref,callId,overrideTitle,overrideDescription,overrideImage);
      }
      
      private function onPaymentComplete(onSuccess:Function, onFailure:Function, fbResponse:Object) : void
      {
         var orderId:String = null;
         var status:String = null;
         var errorCode:String = FarmGameUtil.getSafeString(fbResponse,FB_RESP_ERROR_CODE);
         var errorMsg:String = FarmGameUtil.getSafeString(fbResponse,FB_RESP_ERROR_MSG);
         if(errorCode != "" || errorMsg != "")
         {
            if(onFailure !== null)
            {
               onFailure(errorCode,errorMsg);
            }
         }
         else if(onSuccess !== null)
         {
            orderId = FarmGameUtil.getSafeString(fbResponse,FB_RESP_ORDER_ID);
            status = FarmGameUtil.getSafeString(fbResponse,FB_RESP_STATUS);
            Global.player.updateTransactionLog(1,1);
            onSuccess(orderId,status);
         }
      }
   }
}

