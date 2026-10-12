package Managers
{
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Widgets.Windows.TargetedLimitedSaleWindow;
   import Widgets.Windows.VIPSaleWindow;
   import com.adobe.serialization.json.JSON;
   
   public class LimitedSaleUtility
   {
      
      public static const RUNTIME_DATA_NAME:String = "LIMITED_SALE";
      
      public static const NO_CURRENT_SALE:int = -1;
      
      public static const NO_EXPIRATION_SPECIFIED:int = -1;
      
      public static const LIMITED_SALE_ICON_NAME:String = "limitedSale";
      
      private static const SALE_KEY_LOC:String = "message_key";
      
      private static const SALE_KEY_ITEMS:String = "items";
      
      private static const SALE_VIP:String = "is_vip_sale";
      
      private static var m_instance:LimitedSaleUtility = null;
      
      private static var m_canInstantiate:Boolean = false;
      
      public static var isEligible:Boolean = false;
      
      private var m_saleData:Object = null;
      
      public function LimitedSaleUtility()
      {
         super();
         if(!m_canInstantiate)
         {
            throw new Error("Instantiation failed! User LimitedSaleUtility.instance() instead.");
         }
         try
         {
            this.m_saleData = com.adobe.serialization.json.JSON.decode(Global.flashHotParams[RUNTIME_DATA_NAME]);
         }
         catch(error:Error)
         {
            FarmStatsManager.sample(1000,TargetedLimitedSaleWindow.DIALOG_STATS_WINDOW,"json_error",error.message);
         }
      }
      
      public static function instance() : LimitedSaleUtility
      {
         if(m_instance == null)
         {
            m_canInstantiate = true;
            m_instance = new LimitedSaleUtility();
            m_canInstantiate = false;
         }
         return m_instance;
      }
      
      public function conditionallyOpenSaleDialog() : void
      {
         if(this.getTimeRemainingOnCurrentSale() <= 0)
         {
            this.showSaleOverMessage();
         }
         else if(this.isVIPSale())
         {
            UI.displayPopup(new VIPSaleWindow());
         }
         else
         {
            UI.displayPopup(new TargetedLimitedSaleWindow());
         }
      }
      
      public function showSaleOverMessage() : void
      {
         UI.showMessage(ZLocUtils.t("Dialogs","limitedSaleTimerExpired"),UI.BUTTON_LAYOUT_OK,null,null,false);
         Global.hud.rightSideIconQueue.removeIconByName(LIMITED_SALE_ICON_NAME);
      }
      
      public function getTimeRemainingOnCurrentSale() : int
      {
         var expiration:int = 0;
         var result:int = NO_CURRENT_SALE;
         if(this.m_saleData != null)
         {
            expiration = Global.player.getlimitedSaleExpirationForVersion(this.m_saleData.version);
            if(expiration != NO_EXPIRATION_SPECIFIED)
            {
               result = expiration - GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            }
         }
         return result;
      }
      
      public function getSaleItems() : Object
      {
         return this.getSaleField(SALE_KEY_ITEMS);
      }
      
      public function getLocalizationKey() : String
      {
         return this.getSaleField(SALE_KEY_LOC);
      }
      
      public function isVIPSale() : Boolean
      {
         var result:Boolean = false;
         var isVIP:int = this.getSaleField(SALE_VIP);
         if(isVIP > 0)
         {
            result = true;
         }
         return result;
      }
      
      private function getSaleField(fieldName:String) : *
      {
         var result:* = null;
         if(this.m_saleData != null)
         {
            if(this.m_saleData.hasOwnProperty(fieldName))
            {
               result = this.m_saleData[fieldName];
            }
         }
         return result;
      }
   }
}

