package Classes.Idle
{
   import Display.PromotionsPopup;
   import Display.UI;
   import Engine.Utilities;
   import Widgets.Windows.Promotions.PromoBuyerAbandonmentWindow;
   
   public class PromoIdleTask extends BaseIdleTask
   {
      
      public static var activePromoSettings:XML = null;
      
      public static var shouldShow:Boolean = false;
      
      protected var m_delay:Number = 60000;
      
      protected var m_requeue:Boolean = true;
      
      public function PromoIdleTask()
      {
         var allPromos:Array = null;
         var i:int = 0;
         var activePromo:String = null;
         var promoSettings:XML = null;
         var promoDialogDelay:int = 0;
         var promoObj:Object = null;
         super();
         m_displaysPopup = true;
         PromoIdleTask.shouldShow = false;
         var promo:Object = Global.player.getAllPromos();
         if(Boolean(promo) && Global.worldManager.isVisiting() == false)
         {
            allPromos = Utilities.xmlListToArray(Global.farmGameSettingsManager.getAllPromotionsSettings(),"promoName");
            for(i = 0; i < allPromos.length; i++)
            {
               activePromo = allPromos[i];
               if(activePromo != "" && Boolean(promo[activePromo]))
               {
                  promoSettings = Global.farmGameSettingsManager.getPromotionSettings(activePromo) as XML;
                  promoDialogDelay = int(promoSettings.@promoDialogDelay);
                  this.m_delay = GlobalEngine.currentTime + promoDialogDelay * 1000;
                  if(promoDialogDelay <= 0)
                  {
                     this.m_requeue = false;
                  }
                  promoObj = promo[activePromo];
                  if(String(promo[activePromo]["showPromo"]).toLowerCase() == "true")
                  {
                     PromoIdleTask.activePromoSettings = promoSettings;
                     PromoIdleTask.shouldShow = true;
                     break;
                  }
               }
            }
         }
      }
      
      public static function navigateToMoneyPage() : void
      {
      }
      
      override public function get shouldAdd() : Boolean
      {
         if(!super.isEligibleForPopups())
         {
            return false;
         }
         return PromoIdleTask.shouldShow;
      }
      
      override public function get requireActionQueueIdle() : Boolean
      {
         return false;
      }
      
      override public function get canFire() : Boolean
      {
         return this.m_delay < GlobalEngine.currentTime;
      }
      
      override public function fire() : void
      {
         var promoName:String = null;
         var promoObj:Object = null;
         var promoVariant:int = 0;
         var variantSettings:XMLList = null;
         if(PromoIdleTask.activePromoSettings)
         {
            promoName = PromoIdleTask.activePromoSettings.@promoName;
            promoObj = Global.player.getPromo(promoName);
            if(promoObj)
            {
               promoVariant = int(promoObj["variant"]);
               variantSettings = PromoIdleTask.activePromoSettings.variant.(@variantNum == promoVariant);
               if(variantSettings.length() > 0)
               {
                  switch(promoName)
                  {
                     case "PromoBuyerAbandonment":
                        UI.displayPopup(new PromoBuyerAbandonmentWindow(variantSettings[0]),true,"addPromotionPopup",true);
                        break;
                     default:
                        UI.displayPopup(new PromotionsPopup(promoVariant),true,"addPromotionPopup",true);
                  }
               }
            }
         }
         PromoIdleTask.shouldShow = false;
         if(this.m_requeue)
         {
            IdleTaskQueue.getInstance().addTask(new PromoIdleTask());
         }
      }
   }
}

