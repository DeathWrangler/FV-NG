package Display
{
   import Classes.Idle.PromoIdleTask;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Transactions.TPromotion;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class PromotionsPopup extends GenericPopup
   {
      
      public static const VARIANT_0:int = 0;
      
      public static const VARIANT_1:int = 1;
      
      public static const VARIANT_2:int = 2;
      
      public static const VARIANT_3:int = 3;
      
      public static var describeDialogOpen:Boolean = false;
      
      protected static const DIALOGS_DIR:String = "assets/dialogs/";
      
      protected static const DEFAULT_DIALOG:String = "FV_GenPopUpGold.swf";
      
      protected static const DEAD_BUYER_PROMO_ID:String = "PromoDeadBuyer";
      
      private var m_iconLoader:Loader;
      
      private var m_close:GenericButton;
      
      private var m_acceptButtonText:String = "Buy";
      
      private var m_popupValue:String = "";
      
      protected var m_item:FarmItem;
      
      protected var m_itemName:String;
      
      protected var m_variant:int;
      
      private var m_timer:Timer;
      
      private var m_remainingSeconds:int;
      
      private var m_buyButton:MovieClip;
      
      public function PromotionsPopup(userVariant:int = 0)
      {
         var variantSettings:XMLList = null;
         var variant:XML = null;
         this.m_variant = userVariant;
         if(PromoIdleTask.activePromoSettings)
         {
            variantSettings = PromoIdleTask.activePromoSettings.variant.(@variantNum == userVariant);
            if(variantSettings.length() > 0)
            {
               variant = variantSettings[0];
               if(variant.@dialog)
               {
                  m_dialogAsset = DIALOGS_DIR + variant.@dialog.toString();
               }
               else
               {
                  m_dialogAsset = DIALOGS_DIR + DEFAULT_DIALOG;
               }
               if(Boolean(variant.@promoGiftItem) && variant.@promoGiftItem.toString() != "")
               {
                  this.m_itemName = variant.@promoGiftItem.toString();
               }
            }
         }
         super(" ",TYPE_OK,null,m_dialogAsset);
      }
      
      override protected function onLoadComplete() : void
      {
         var name:String = null;
         var gender:String = null;
         var deadBuyerPromoData:Object = null;
         var promoDates:Array = null;
         var weekCount:int = 0;
         var variantSettings:XMLList = null;
         var variant:XML = null;
         var percentOff:String = null;
         var promoSeconds:String = null;
         m_window = m_loader.content as MovieClip;
         if(PromoIdleTask.activePromoSettings.@promoName)
         {
            this.m_acceptButtonText = ZLocUtils.t("Dialogs",PromoIdleTask.activePromoSettings.@promoName.toString() + "_ActionButton_variant_" + this.m_variant);
         }
         else
         {
            this.m_acceptButtonText = ZLocUtils.t("Dialogs","Buy");
         }
         if(PromoIdleTask.activePromoSettings.@promoName == PromotionsPopup.DEAD_BUYER_PROMO_ID)
         {
            m_window.close_bt.addEventListener(MouseEvent.CLICK,this.onCancel);
            m_window.accept_bt.generic_tf.text = ZLocUtils.t("Dialogs","DeadBuyerPromoBuyButton");
            m_window.accept_bt.addEventListener(MouseEvent.CLICK,this.onAccept);
            m_window.accept_bt.addEventListener(MouseEvent.ROLL_OVER,this.onRollOver,false,0,true);
            m_window.accept_bt.addEventListener(MouseEvent.ROLL_OUT,this.onRollOut,false,0,true);
            m_window.accept_bt.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
            this.m_buyButton = m_window.accept_bt;
            name = Global.player.name;
            gender = Global.player.snUser.gender;
            m_window.generic_0_tf.text = ZLocUtils.t("Dialogs","DeadBuyerPromoCongratulations",{"user":ZLocUtils.tn(name,ZLocUtils.tg(gender))});
            deadBuyerPromoData = Global.player.getPromo(PromotionsPopup.DEAD_BUYER_PROMO_ID);
            promoDates = deadBuyerPromoData["promoDates"];
            weekCount = int(promoDates.length);
            variantSettings = PromoIdleTask.activePromoSettings.variant.(@variantNum == m_variant);
            if(variantSettings.length() > 0)
            {
               variant = variantSettings[0];
               if(weekCount == 0)
               {
                  percentOff = variant.@percentOff1;
               }
               else if(weekCount == 1)
               {
                  percentOff = variant.@percentOff2;
               }
               else
               {
                  percentOff = variant.@percentOff3;
               }
               m_window.generic_1_tf.text = ZLocUtils.t("Dialogs","DeadBuyerPromoOffer",{"quantity":percentOff});
               m_window.sale_percent_tf.text = percentOff;
               m_window.percent_off_tf.text = ZLocUtils.t("Dialogs","DeadBuyerPromoOff");
               m_window.generic_2_tf.text = ZLocUtils.t("Dialogs","DeadBuyerPromoTimeLeft");
               promoSeconds = PromoIdleTask.activePromoSettings.@promoExpirationTime;
               this.m_remainingSeconds = int(promoSeconds) - 1;
               this.setPromoTimer(this.m_remainingSeconds);
               this.addTimer();
               addChild(m_window);
            }
            else
            {
               GlobalEngine.log("PromotionsPopup","gameSetting.xml is missing variants for PromoDeadBuyer");
            }
         }
         else
         {
            m_window.popupBox_mc.accept_bt.visible = true;
            m_window.popupBox_mc.cancel_bt.visible = true;
            m_accept = new GenericButton(m_window.popupBox_mc.accept_bt,this.onAccept);
            m_accept.text = this.m_acceptButtonText;
            m_reject = new GenericButton(m_window.popupBox_mc.cancel_bt,this.onCancel);
            m_reject.text = ZLocUtils.t("Dialogs","Cancel");
            m_window.popupBox_mc.goldTitle_tf.text = ZLocUtils.t("Dialogs",PromoIdleTask.activePromoSettings.@promoName.toString() + "_title_variant_" + this.m_variant);
            m_window.popupBox_mc.popupBox_tf.htmlText = ZLocUtils.t("Dialogs",PromoIdleTask.activePromoSettings.@promoName + "_offerText_variant_" + this.m_variant);
            addChild(m_window);
         }
      }
      
      protected function onRollOver(event:MouseEvent) : void
      {
         this.m_buyButton.gotoAndStop(2);
      }
      
      protected function onRollOut(event:MouseEvent) : void
      {
         this.m_buyButton.gotoAndStop(1);
      }
      
      protected function onMouseDown(event:MouseEvent) : void
      {
         this.m_buyButton.gotoAndStop(3);
      }
      
      protected function onIconLoaded(event:Event) : void
      {
         var iconMc:MovieClip = m_window.popupBox_mc.icon_mc;
         iconMc.scaleX = iconMc.scaleY = 1;
         while(iconMc.numChildren)
         {
            iconMc.removeChildAt(0);
         }
         var newIcon:DisplayObject = this.m_iconLoader.content;
         newIcon.x = -newIcon.width / 2;
         newIcon.y = -newIcon.height / 2;
         iconMc.addChild(newIcon);
      }
      
      protected function removeTimer() : void
      {
         if(PromoIdleTask.activePromoSettings.@promoName == PromotionsPopup.DEAD_BUYER_PROMO_ID)
         {
            this.m_timer.stop();
            this.m_timer = null;
         }
      }
      
      protected function addTimer() : void
      {
         if(PromoIdleTask.activePromoSettings.@promoName == PromotionsPopup.DEAD_BUYER_PROMO_ID)
         {
            this.m_timer = new Timer(1000);
            this.m_timer.addEventListener("timer",this.timerCallback);
            this.m_timer.start();
         }
      }
      
      protected function timerCallback(event:TimerEvent) : void
      {
         --this.m_remainingSeconds;
         this.setPromoTimer(this.m_remainingSeconds);
      }
      
      protected function setPromoTimer(remainingSeconds:int) : void
      {
         var hoursMinutesSeconds:Array = FarmGameUtil.parseTimeLeft(remainingSeconds);
         var hoursString:String = hoursMinutesSeconds[1].toString();
         var minutesString:String = hoursMinutesSeconds[2].toString();
         var secondsString:String = hoursMinutesSeconds[3].toString();
         if(hoursString.length == 2)
         {
            m_window.value_0_tf.text = hoursString.charAt(0);
            m_window.value_1_tf.text = hoursString.charAt(1);
         }
         else
         {
            m_window.value_0_tf.text = "0";
            m_window.value_1_tf.text = hoursString.charAt(0);
         }
         if(minutesString.length == 2)
         {
            m_window.value_2_tf.text = minutesString.charAt(0);
            m_window.value_3_tf.text = minutesString.charAt(1);
         }
         else
         {
            m_window.value_2_tf.text = "0";
            m_window.value_3_tf.text = minutesString.charAt(0);
         }
         if(secondsString.length == 2)
         {
            m_window.value_4_tf.text = secondsString.charAt(0);
            m_window.value_5_tf.text = secondsString.charAt(1);
         }
         else
         {
            m_window.value_4_tf.text = "0";
            m_window.value_5_tf.text = secondsString.charAt(0);
         }
      }
      
      override protected function onAccept(event:MouseEvent) : void
      {
         this.removeTimer();
         TransactionManager.addTransaction(new TPromotion(true),true);
         super.onAccept(event);
      }
      
      override protected function onCancel(event:MouseEvent) : void
      {
         this.removeTimer();
         TransactionManager.addTransaction(new TPromotion(false),true);
         super.onCancel(event);
      }
      
      public function setPopupValue(val:String) : void
      {
         this.m_popupValue = val;
      }
   }
}

