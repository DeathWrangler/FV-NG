package Display.HUD.HUDWidgets
{
   import Classes.Constants.Experiments;
   import Classes.Constants.ZLocConstants;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Utilities;
   import Events.SubscriptionsEvent;
   import Managers.FarmStatsManager;
   import Managers.InGamePaymentsManager;
   import Managers.SubscriptionsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.BuyMoneyWindow;
   import Widgets.Windows.MOTD.SubscriptionsMOTDWindow;
   import Widgets.Windows.Subscriptions.SubscriptionsMainWindow;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.text.TextField;
   import flash.utils.Timer;
   
   public class HUDSubscriptionsWidget extends HUDWidget
   {
      
      private static const ASSET_PATH:String = "assets/hud/FV_Subscriptions3_HUD.swf";
      
      private static const ASSET_PATH_V2:String = "assets/dialogs/Subscriptions/FV_Subscriptions3_HUD_v3.swf";
      
      private static const ASSET_PATH_TRIAL:String = "assets/dialogs/Subscriptions/FV_Subscriptions_HUD_trial.swf";
      
      private static const ASSET_PATH_BRONZE:String = "assets/dialogs/Subscriptions/FV_Subscriptions3_HUD_v3_bronze.swf";
      
      private static const ASSET_PATH_SILVER:String = "assets/dialogs/Subscriptions/FV_Subscriptions3_HUD_v3_silver.swf";
      
      private static const ASSET_PATH_GOLD:String = "assets/dialogs/Subscriptions/FV_Subscriptions3_HUD_v3_gold.swf";
      
      private static const ASSET_PATH_RUBY:String = "assets/dialogs/Subscriptions/FV_Subscriptions3_HUD_v3_ruby.swf";
      
      private static const ASSET_PATH_DIAMOND:String = "assets/dialogs/Subscriptions/FV_Subscriptions3_HUD_v3_diamond.swf";
      
      private static const BDDD_ARROW_ASSET_PATH:String = "assets/hud/IndicatorArrows/FV_HUD_NewGoalArrow_dailydrip.swf";
      
      private static const EXPAND_ANIMATION_DELAY:int = 30000;
      
      private static const CONTRACT_ANIMATION_DELAY:int = 10000;
      
      private static const BDDD_HUD_ARROW_RUNTIME_FLAG:String = "BDDD_SHOW_HUD_ARROW";
      
      private static const BDDD_HUD_ARROW_BACKOFF_NAME:String = "BDDD_HUD_Arrow";
      
      private static const BDDD_HUD_ARROW_CUSTOM_BACKOFF_NAME:String = "BDDD_HUD_Arrow_CUSTOM";
      
      private static const BDDD_HUD_ARROW_X_OFFSET:Number = 108;
      
      private static const INGAME_BUY_DIALOG_VARIANT_ON:int = 2;
      
      private static const BDDD_HUD_ARROW_MAX_BACKOFF:int = 10;
      
      private static const BDDD_NOCLICK_TIMER_DELAY:int = 15000;
      
      private var m_vipPanel:ZwFrame;
      
      private var m_button:FarmAnimatedTextButton;
      
      private var m_imageFrame:ZwButton;
      
      private var m_farmCashButton:FarmAnimatedTextButton;
      
      private var m_timer:Timer;
      
      private var m_expanding:Boolean = false;
      
      private var m_bddd_timer:Timer = null;
      
      private var m_isActiveV2Surfacing:Boolean = false;
      
      private var m_isActiveTrialSubSurfacing:Boolean = false;
      
      public function HUDSubscriptionsWidget(parentElement:Sprite)
      {
         var assetPath:String = null;
         if(SubscriptionsManager.isTrialSubscriptionActive() || SubscriptionsManager.inTrialPeriod())
         {
            this.m_isActiveV2Surfacing = false;
            this.m_isActiveTrialSubSurfacing = true;
            if(SubscriptionsManager.inTrialPeriod())
            {
               assetPath = ASSET_PATH_BRONZE;
            }
            else
            {
               assetPath = ASSET_PATH_V2;
            }
         }
         else if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_SUBSCRIPTIONS_V2_SURFACING) == Experiments.VARIANT_SUBSCRIPTIONS_V2_SURFACING || Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_SUBSCRIPTIONS_V2_POSTMIGRATION_SURFACING) == Experiments.VARIANT_SUBSCRIPTIONS_V2_POSTMIGRATION_SURFACING && SubscriptionsManager.instance.isSubscriber())
         {
            assetPath = ASSET_PATH_V2;
            this.m_isActiveV2Surfacing = true;
         }
         else
         {
            assetPath = ASSET_PATH;
            this.m_isActiveV2Surfacing = false;
         }
         assetPath = this.getAssetForHUD(assetPath);
         super(assetPath,parentElement);
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         var buttonString:String = null;
         var buttonText:TextField = null;
         var subscriber:Boolean = false;
         var canShowBDDDArrow:Boolean = false;
         var lastShownMsec:Number = NaN;
         var mc:MovieClip = null;
         var hudArrow:FarmIcon = null;
         super.onLoadComplete(event);
         FarmStatsManager.sample(100,SubscriptionsMainWindow.STATS_COUNTER,"indicator","view");
         m_loader.x = 190;
         m_loader.y = 3;
         if(m_element.hasOwnProperty("currency_bt"))
         {
            addWidget(this.m_farmCashButton = new FarmAnimatedTextButton(m_element.currency_bt,Utilities.formatNumber(Global.player.cash),this.onGetCoins));
         }
         if(m_element.hasOwnProperty("vip_mc"))
         {
            addWidget(this.m_vipPanel = new ZwFrame(m_element.vip_mc));
            this.m_vipPanel.addWidget(this.m_imageFrame = new ZwButton(m_element.vip_mc.images_mc,this.onSubscriptionsClick));
            (m_element.vip_mc.images_mc as MovieClip).buttonMode = true;
            if(this.m_isActiveV2Surfacing || this.m_isActiveTrialSubSurfacing)
            {
               if(SubscriptionsManager.instance.isSubscriber())
               {
                  buttonString = "See the Benefit";
               }
               else
               {
                  buttonString = "Sign Up Now!";
               }
               if(m_element.vip_mc.images_mc.hasOwnProperty("dropdown_tf"))
               {
                  (m_element.vip_mc.images_mc.dropdown_tf as TextField).text = buttonString;
                  (m_element.vip_mc.images_mc.dropdown_tf as TextField).mouseWheelEnabled = false;
               }
               if(m_element.vip_mc.hasOwnProperty("button_mc"))
               {
                  (m_element.vip_mc.button_mc as MovieClip).buttonMode = true;
                  (m_element.vip_mc.button_mc as MovieClip).addEventListener(MouseEvent.CLICK,this.onSubscriptionsClick);
               }
               if(Boolean(m_element.vip_mc.hasOwnProperty("button_mc")) && Boolean(m_element.vip_mc.button_mc.hasOwnProperty("generic_tf")))
               {
                  buttonText = m_element.vip_mc.button_mc.generic_tf;
                  if(SubscriptionsManager.isRevampTrialActive())
                  {
                     buttonText.text = "Free Trial!";
                  }
                  if(this.m_isActiveTrialSubSurfacing)
                  {
                     if(SubscriptionsManager.inTrialPeriod())
                     {
                        buttonText.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"vipTrialHUDTitle");
                     }
                     else
                     {
                        buttonText.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"vipPreTrialHUDTitle");
                     }
                  }
               }
            }
            else
            {
               subscriber = SubscriptionsMainWindow.isSubscriber() && Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_COINS_SUBSCRIPTIONS) == 3;
               if(subscriber)
               {
                  addWidget(new ZwBaseWidget(m_element.vip_mc.images_mc.blueImage_mc),false);
                  addWidget(new ZwBaseWidget(m_element.vip_mc.images_mc.goldImage_mc));
                  buttonString = ZLocUtils.t("Dialogs","Subscriptions_HUD_Subscriber");
               }
               else
               {
                  addWidget(new ZwBaseWidget(m_element.vip_mc.images_mc.blueImage_mc));
                  addWidget(new ZwBaseWidget(m_element.vip_mc.images_mc.goldImage_mc),false);
                  buttonString = ZLocUtils.t("Dialogs","Subscriptions_HUD_NonSubscriber");
               }
               if(Boolean(m_element.vip_mc.hasOwnProperty("button_mc")) && Boolean(m_element.vip_mc.button_mc.hasOwnProperty("generic_tf")))
               {
                  buttonText = m_element.vip_mc.button_mc.generic_tf;
                  buttonText.text = buttonString;
                  buttonText.mouseEnabled = false;
                  (m_element.vip_mc.button_mc as MovieClip).buttonMode = true;
                  (m_element.vip_mc.button_mc as MovieClip).addEventListener(MouseEvent.CLICK,this.onSubscriptionsClick);
               }
            }
         }
         var arrowRuntimeOn:Boolean = Boolean(Global.flashHotParams[BDDD_HUD_ARROW_RUNTIME_FLAG]);
         if(BuyMoneyWindow.inBDDDExperiment() && arrowRuntimeOn)
         {
            canShowBDDDArrow = Global.player.canShowFeatureWithBackoff(BDDD_HUD_ARROW_BACKOFF_NAME,BDDD_HUD_ARROW_MAX_BACKOFF);
            if(!canShowBDDDArrow)
            {
               lastShownMsec = Global.player.getFeatureLastShown(BDDD_HUD_ARROW_CUSTOM_BACKOFF_NAME) * FarmGameUtil.NUM_MSECS_IN_SECOND;
               if(GlobalEngine.serverTime > lastShownMsec + BDDD_HUD_ARROW_MAX_BACKOFF * FarmGameUtil.NUM_MSECS_IN_DAY)
               {
                  canShowBDDDArrow = true;
               }
            }
            if(canShowBDDDArrow)
            {
               Global.player.setFeatureLastShown(BDDD_HUD_ARROW_CUSTOM_BACKOFF_NAME,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,true);
               mc = new MovieClip();
               hudArrow = addWidget(new FarmIcon(mc)) as FarmIcon;
               hudArrow.loadIcon(BDDD_ARROW_ASSET_PATH,this.generateBDDDArrowOnLoadCallback(mc));
               mc.x = BDDD_HUD_ARROW_X_OFFSET;
               m_element.addChild(mc);
               this.m_bddd_timer = new Timer(BDDD_NOCLICK_TIMER_DELAY,1);
               this.m_bddd_timer.addEventListener(TimerEvent.TIMER,this.didNotClickBDDDArrow);
               this.m_bddd_timer.start();
            }
         }
         if(!this.m_isActiveV2Surfacing && Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_SUBSCRIPTIONS_V1_DERAMP) == Experiments.VARIANT_SUBSCRIPTIONS_V1_DERAMP)
         {
            this.m_vipPanel.visible = false;
         }
         else
         {
            this.m_timer = new Timer(EXPAND_ANIMATION_DELAY,1);
            this.m_timer.addEventListener(TimerEvent.TIMER,this.expandSubscriptionsRollover);
            this.m_timer.start();
         }
         if(this.m_isActiveTrialSubSurfacing)
         {
            this.m_vipPanel.visible = true;
         }
         if(this.m_vipPanel)
         {
            this.m_vipPanel.visible = false;
         }
         Global.hud.conditionallyRefreshHUD(true);
      }
      
      private function generateBDDDArrowOnLoadCallback(mc:MovieClip) : Function
      {
         return function():void
         {
            var hudArrowWindow:* = mc.getChildAt(0) as MovieClip;
            addWidget(new ZwTextField(hudArrowWindow.progressArrow_mc.arrow_mc.infoGroup_mc.generic_tf,ZLocUtils.t("Dialogs","bddd_hud_arrow_text")));
         };
      }
      
      private function onSubscriptionsClick(event:Event) : void
      {
         if(this.m_isActiveTrialSubSurfacing)
         {
            FarmStatsManager.count(SubscriptionsManager.TRIAL_SUB_STATS_COUNTER,"indicator","click");
            if(SubscriptionsManager.instance.isSubscriber())
            {
               SubscriptionsManager.instance.dispatchEvent(new SubscriptionsEvent(SubscriptionsManager.SHOW_BENEFITS_POPUP,{
                  "source":"vip_hud",
                  "sub_type":SubscriptionsManager.TRIAL_SUBSCRIPTION_CODE
               }));
            }
            else if(SubscriptionsManager.inTrialPeriod())
            {
               SubscriptionsManager.instance.dispatchEvent(new SubscriptionsEvent(SubscriptionsManager.SHOW_BENEFITS_POPUP,{
                  "source":"vip_hud",
                  "sub_type":SubscriptionsManager.TRIAL_SUBSCRIPTION_CODE
               }));
            }
            else
            {
               SubscriptionsManager.instance.dispatchEvent(new SubscriptionsEvent(SubscriptionsManager.SHOW_SIGNUP_POPUP,{
                  "source":"vip_hud",
                  "sub_type":SubscriptionsManager.TRIAL_SUBSCRIPTION_CODE
               }));
            }
         }
         else if(this.m_isActiveV2Surfacing)
         {
            FarmStatsManager.count(SubscriptionsManager.STATS_COUNTER,"indicator","click");
            if(SubscriptionsManager.instance.isSubscriber())
            {
               SubscriptionsManager.instance.dispatchEvent(new SubscriptionsEvent(SubscriptionsManager.SHOW_BENEFITS_POPUP,{"source":"vip_hud"}));
            }
            else
            {
               SubscriptionsManager.instance.dispatchEvent(new SubscriptionsEvent(SubscriptionsManager.SHOW_SIGNUP_POPUP,{"source":"vip_hud"}));
            }
         }
         else
         {
            FarmStatsManager.count(SubscriptionsMainWindow.STATS_COUNTER,"indicator","click");
            if(this.m_expanding)
            {
               this.m_expanding = false;
               this.m_timer.stop();
               (this.m_vipPanel.element as MovieClip).play();
            }
            this.m_timer.stop();
            if(SubscriptionsMainWindow.isSubscriber())
            {
               UI.displayPopup(new SubscriptionsMainWindow(),true,"SubscriptionsMainWindow",true);
            }
            else
            {
               UI.displayPopup(new SubscriptionsMOTDWindow(),true,"SubscriptionsMOTDWindow",true);
            }
         }
      }
      
      public function set cash(cash:Number) : void
      {
         if(this.m_farmCashButton != null)
         {
            this.m_farmCashButton.text = Utilities.formatNumber(cash);
         }
      }
      
      public function get cashTextField() : TextField
      {
         var result:TextField = null;
         if(this.m_farmCashButton != null && this.m_farmCashButton.element != null)
         {
            result = this.m_farmCashButton.element["generic_tf"] as TextField;
         }
         return result;
      }
      
      private function expandSubscriptionsRollover(event:Event) : void
      {
         this.m_expanding = true;
         (this.m_vipPanel.element as MovieClip).play();
         this.m_timer.stop();
         this.m_timer.removeEventListener(TimerEvent.TIMER,this.expandSubscriptionsRollover);
         this.m_timer = new Timer(CONTRACT_ANIMATION_DELAY,1);
         this.m_timer.addEventListener(TimerEvent.TIMER,this.contractSubscriptionsRollover);
         this.m_timer.start();
      }
      
      private function contractSubscriptionsRollover(event:Event) : void
      {
         this.m_expanding = false;
         (this.m_vipPanel.element as MovieClip).play();
         this.m_timer.removeEventListener(TimerEvent.TIMER,this.contractSubscriptionsRollover);
      }
      
      private function onGetCoins(event:Event) : void
      {
         if(BuyMoneyWindow.inBDDDExperiment())
         {
            if(Boolean(this.m_bddd_timer) && this.m_bddd_timer.running)
            {
               this.m_bddd_timer.removeEventListener(TimerEvent.TIMER,this.didNotClickBDDDArrow);
               this.m_bddd_timer.stop();
               Global.player.resetBackoffInterval(BDDD_HUD_ARROW_BACKOFF_NAME);
            }
         }
         var bdddString:String = BuyMoneyWindow.inBDDDExperiment() ? "BDDDon" : "BDDDoff";
         FarmStatsManager.count("daily_drip","Click_fc_button_hud",bdddString);
         var variant:int = Global.experimentManager.getExperimentVariant("fv_ingame_payments");
         if(variant == InGamePaymentsManager.VARIANT_HUD || this.inIngameBuyDialog())
         {
            FarmStatsManager.count("Add_cash_payments_test","click_button_add_cash","click_HUD_button");
            FarmStatsManager.count("Add_cash_payments_test","dialog_impresssions",variant.toString());
         }
      }
      
      private function didNotClickBDDDArrow(event:TimerEvent) : void
      {
         Global.player.incrementBackoffInterval(BDDD_HUD_ARROW_BACKOFF_NAME);
      }
      
      private function inIngameBuyDialog() : Boolean
      {
         return Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_BUYDIALOG_DAILY_DRIP) >= INGAME_BUY_DIALOG_VARIANT_ON;
      }
      
      public function getAssetForHUD(asset:String) : String
      {
         var result:String = asset;
         if(SubscriptionsManager.isRetentionProgramActivated())
         {
            switch(SubscriptionsManager.instance.getSubscriptionLevel())
            {
               case SubscriptionsManager.LEVEL_BRONZE:
                  result = ASSET_PATH_BRONZE;
                  break;
               case SubscriptionsManager.LEVEL_SILVER:
                  result = ASSET_PATH_SILVER;
                  break;
               case SubscriptionsManager.LEVEL_GOLD:
                  result = ASSET_PATH_GOLD;
                  break;
               case SubscriptionsManager.LEVEL_RUBY:
                  result = ASSET_PATH_RUBY;
                  break;
               case SubscriptionsManager.LEVEL_DIAMOND:
                  result = ASSET_PATH_DIAMOND;
            }
         }
         return result;
      }
   }
}

