package Widgets.Windows.Subscriptions
{
   import Classes.Constants.Experiments;
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Events.SubscriptionsEvent;
   import Managers.SubscriptionsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.FarmWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   
   public class SubscriptionsBenefitsRetention extends FarmWindow
   {
      
      private static const ASSET_NAME:String = "assets/dialogs/Subscriptions/FV_SubscriptionRevamp_MainUI_v2.swf";
      
      private static const ASSET_NAME_2:String = "assets/dialogs/Subscriptions/FV_SubscriptionRevamp_MainUI_v3.swf";
      
      private static const ASSET_NAME_3:String = "assets/dialogs/Subscriptions/FV_SubscriptionRevamp_MainUI_v4.swf";
      
      private var m_callBack:Function;
      
      private var m_source:String;
      
      private var m_subtitleTF:FarmTextField = null;
      
      private var m_stayTF:FarmTextField = null;
      
      private var m_supprtbt:FarmAnimatedTextButton = null;
      
      private var m_body1TF:FarmTextField = null;
      
      private var m_bronzeButton:FarmButton = null;
      
      private var m_silverButton:FarmButton = null;
      
      private var m_goldButton:FarmButton = null;
      
      private var m_rubyButton:FarmButton = null;
      
      private var m_diamondButton:FarmButton = null;
      
      private var m_bronzeSubtitle:FarmTextField = null;
      
      private var m_silverSubtitle:FarmTextField = null;
      
      private var m_goldSubtitle:FarmTextField = null;
      
      private var m_rubySubtitle:FarmTextField = null;
      
      private var m_diamondSubtitle:FarmTextField = null;
      
      private var m_bronzeButtonBG:ZwBaseWidget = null;
      
      private var m_silverButtonBG:ZwBaseWidget = null;
      
      private var m_goldButtonBG:ZwBaseWidget = null;
      
      private var m_rubyButtonBG:ZwBaseWidget = null;
      
      private var m_diamondButtonBG:ZwBaseWidget = null;
      
      private var m_bronzeButtonBGSelected:ZwBaseWidget = null;
      
      private var m_silverButtonBGSelected:ZwBaseWidget = null;
      
      private var m_goldButtonBGSelected:ZwBaseWidget = null;
      
      private var m_rubyButtonBGSelected:ZwBaseWidget = null;
      
      private var m_diamondButtonBGSelected:ZwBaseWidget = null;
      
      private var m_silverTF:FarmTextField = null;
      
      private var m_goldTF:FarmTextField = null;
      
      private var m_rubyTF:FarmTextField = null;
      
      private var m_diamondTF:FarmTextField = null;
      
      private var m_subsValueAmount:FarmTextField = null;
      
      private var m_subsValueText:FarmTextField = null;
      
      private var m_subsValueBG:ZwBaseWidget = null;
      
      private var m_framesMC:ZwBaseWidget = null;
      
      private var m_bronzeFrame:ZwBaseWidget = null;
      
      private var m_silverFrame:ZwBaseWidget = null;
      
      private var m_goldFrame:ZwBaseWidget = null;
      
      private var m_rubyFrame:ZwBaseWidget = null;
      
      private var m_diamondFrame:ZwBaseWidget = null;
      
      public function SubscriptionsBenefitsRetention(dialogAsset:String, source:String = "default", callBack:Function = null)
      {
         super(dialogAsset);
         this.m_callBack = callBack;
         this.m_source = source;
      }
      
      public static function display(source:String = "default", callBack:Function = null) : void
      {
         var popUp:SubscriptionsBenefitsRetention = null;
         var assetName:String = ASSET_NAME_3;
         popUp = new SubscriptionsBenefitsRetention(assetName,source,callBack);
         UI.displayPopup(popUp);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         this.setupDetails();
      }
      
      private function setupDetails() : void
      {
         var currentLevel:int = SubscriptionsManager.instance.getSubscriptionLevel();
         var currentStreak:int = SubscriptionsManager.instance.getSubscriptionStreak();
         this.addFrames();
         this.addDialogTextAndCloseBt();
         this.addLevelButtons();
         this.addLevelSubtitles();
         this.addLevelsButtonBG();
         this.addLevelsButtonSelectedGlow();
         this.addBeLevelTFs(currentLevel,currentStreak);
         this.addLearnMoreLink();
         this.addPayerSupportButton();
         this.preselectLoadViewTab(currentLevel);
      }
      
      private function onSupportClick(event:Event) : void
      {
         ExternalInterface.call("showPayerSupportTab",Global.player.uid);
      }
      
      private function addPayerSupportButton() : void
      {
         if(m_window.customer_bt)
         {
            addWidget(this.m_supprtbt = new FarmAnimatedTextButton(m_window.customer_bt,"Get Faster Support",this.onSupportClick));
         }
      }
      
      private function onCloseButtonClicked(event:Event) : void
      {
         if(this.m_callBack != null)
         {
            this.m_callBack();
         }
         super.onClose(event);
      }
      
      override protected function release() : void
      {
         (m_window.learnmore_mc as MovieClip).removeEventListener(MouseEvent.CLICK,this.onLearnMoreClicked);
         this.m_callBack = null;
         super.release();
      }
      
      public function onLearnMoreClicked(event:MouseEvent) : void
      {
         SubscriptionsManager.instance.dispatchEvent(new SubscriptionsEvent(SubscriptionsManager.SHOW_LEARN_MORE_POPUP,{
            "source":this.m_source,
            "previousPopupEventType":SubscriptionsManager.SHOW_BENEFITS_POPUP,
            "isTrial":SubscriptionsManager.inTrialPeriod()
         }));
         super.close();
      }
      
      private function addLevelButtons() : void
      {
         addWidget(this.m_bronzeButton = new FarmAnimatedTextButton(m_window.bronze_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subsRet_level_bronze"),this.onBronzeClicked),true);
         addWidget(this.m_silverButton = new FarmAnimatedTextButton(m_window.silver_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subsRet_level_silver"),this.onSilverClicked),true);
         addWidget(this.m_goldButton = new FarmAnimatedTextButton(m_window.gold_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subsRet_level_gold"),this.onGoldClicked),true);
         addWidget(this.m_rubyButton = new FarmAnimatedTextButton(m_window.ruby_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subsRet_level_ruby"),this.onRubyClicked),true);
         addWidget(this.m_diamondButton = new FarmAnimatedTextButton(m_window.diamond_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subsRet_level_diamond"),this.onDiamondClicked),true);
      }
      
      private function addLevelSubtitles() : void
      {
         addWidget(this.m_bronzeSubtitle = new FarmTextField(m_window.subtitle_bronze_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subsRet_levelSubtitle_bronze")),true);
         addWidget(this.m_silverSubtitle = new FarmTextField(m_window.subtitle_silver_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subsRet_levelSubtitle_silver")),true);
         addWidget(this.m_goldSubtitle = new FarmTextField(m_window.subtitle_gold_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subsRet_levelSubtitle_gold")),true);
         addWidget(this.m_rubySubtitle = new FarmTextField(m_window.subtitle_ruby_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subsRet_levelSubtitle_ruby")),true);
         addWidget(this.m_diamondSubtitle = new FarmTextField(m_window.subtitle_diamond_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subsRet_levelSubtitle_diamond")),true);
      }
      
      private function hideLevelSubtitles() : void
      {
         this.m_bronzeSubtitle.visible = false;
         this.m_silverSubtitle.visible = false;
         this.m_goldSubtitle.visible = false;
         this.m_rubySubtitle.visible = false;
         this.m_diamondSubtitle.visible = false;
      }
      
      private function addLevelsButtonBG() : void
      {
         addWidget(this.m_bronzeButtonBG = new ZwBaseWidget(m_window.bronze_mc),true);
         addWidget(this.m_silverButtonBG = new ZwBaseWidget(m_window.silver_mc),true);
         addWidget(this.m_goldButtonBG = new ZwBaseWidget(m_window.gold_mc),true);
         addWidget(this.m_rubyButtonBG = new ZwBaseWidget(m_window.ruby_mc),true);
         addWidget(this.m_diamondButtonBG = new ZwBaseWidget(m_window.diamond_mc),true);
      }
      
      private function addFrames() : void
      {
         addWidget(this.m_framesMC = new ZwBaseWidget(m_window.frames_mc),true);
         addWidget(this.m_bronzeFrame = new ZwBaseWidget(m_window.frames_mc.bronzeframe_mc),true);
         addWidget(this.m_silverFrame = new ZwBaseWidget(m_window.frames_mc.silverframe_mc),true);
         addWidget(this.m_goldFrame = new ZwBaseWidget(m_window.frames_mc.goldframe_mc),true);
         addWidget(this.m_rubyFrame = new ZwBaseWidget(m_window.frames_mc.rubyframe_mc),true);
         addWidget(this.m_diamondFrame = new ZwBaseWidget(m_window.frames_mc.diamondframe_mc),true);
      }
      
      private function hideAllFrames() : void
      {
         this.m_bronzeFrame.visible = false;
         this.m_silverFrame.visible = false;
         this.m_goldFrame.visible = false;
         this.m_rubyFrame.visible = false;
         this.m_diamondFrame.visible = false;
      }
      
      private function addLevelsButtonSelectedGlow() : void
      {
         addWidget(this.m_bronzeButtonBGSelected = new ZwBaseWidget(m_window.bronze_selected_mc),true);
         addWidget(this.m_silverButtonBGSelected = new ZwBaseWidget(m_window.silver_selected_mc),true);
         addWidget(this.m_goldButtonBGSelected = new ZwBaseWidget(m_window.gold_selected_mc),true);
         addWidget(this.m_rubyButtonBGSelected = new ZwBaseWidget(m_window.ruby_selected_mc),true);
         addWidget(this.m_diamondButtonBGSelected = new ZwBaseWidget(m_window.diamond_selected_mc),true);
      }
      
      private function hideLevelsButtonSelectedGlow() : void
      {
         this.m_bronzeButtonBGSelected.alpha = 0.3;
         this.m_silverButtonBGSelected.alpha = 0.3;
         this.m_goldButtonBGSelected.alpha = 0.3;
         this.m_rubyButtonBGSelected.alpha = 0.3;
         this.m_diamondButtonBGSelected.alpha = 0.3;
      }
      
      private function addBeLevelTFs(currentLevel:int = 0, currentStreak:int = 0) : void
      {
         var toSilverTxt:String = null;
         var toGoldTxt:String = null;
         var toRubyTxt:String = null;
         var toDiamondTxt:String = null;
         switch(currentLevel)
         {
            case SubscriptionsManager.LEVEL_BRONZE:
               toSilverTxt = SubscriptionsManager.STREAK_LEVEL_SILVER - currentStreak == 1 ? ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subsRet_levelUp_withNext") : (SubscriptionsManager.STREAK_LEVEL_SILVER - currentStreak > 1 ? "In " + (SubscriptionsManager.STREAK_LEVEL_SILVER - currentStreak) + " months" : "");
               addWidget(this.m_silverTF = new FarmTextField(m_window.besilver_tf,toSilverTxt),true);
               break;
            case SubscriptionsManager.LEVEL_SILVER:
               toGoldTxt = SubscriptionsManager.STREAK_LEVEL_GOLD - currentStreak == 1 ? ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subsRet_levelUp_withNext") : (SubscriptionsManager.STREAK_LEVEL_GOLD - currentStreak > 1 ? "In " + (SubscriptionsManager.STREAK_LEVEL_GOLD - currentStreak) + " months" : "");
               addWidget(this.m_goldTF = new FarmTextField(m_window.begold_tf,toGoldTxt),true);
               break;
            case SubscriptionsManager.LEVEL_GOLD:
               toRubyTxt = SubscriptionsManager.STREAK_LEVEL_RUBY - currentStreak == 1 ? ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subsRet_levelUp_withNext") : (SubscriptionsManager.STREAK_LEVEL_RUBY - currentStreak > 1 ? "In " + (SubscriptionsManager.STREAK_LEVEL_RUBY - currentStreak) + " months" : "");
               addWidget(this.m_rubyTF = new FarmTextField(m_window.beruby_tf,toRubyTxt),true);
               break;
            case SubscriptionsManager.LEVEL_RUBY:
               toDiamondTxt = SubscriptionsManager.STREAK_LEVEL_DIAMOND - currentStreak == 1 ? ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subsRet_levelUp_withNext") : (SubscriptionsManager.STREAK_LEVEL_DIAMOND - currentStreak > 1 ? "In " + (SubscriptionsManager.STREAK_LEVEL_DIAMOND - currentStreak) + " months" : "");
               addWidget(this.m_diamondTF = new FarmTextField(m_window.bediamond_tf,toDiamondTxt),true);
         }
      }
      
      private function addSubsPackageCost() : void
      {
      }
      
      private function hideSubsPackageCost() : void
      {
      }
      
      private function showSubsPackageCost(value:int = 20) : void
      {
      }
      
      private function addLearnMoreLink() : void
      {
         var learnMoreBtn:ZwButton = new ZwButton(m_window.learnmore_mc,this.onLearnMoreClicked);
         addWidget(learnMoreBtn,true);
         learnMoreBtn.toggleClickableButton(true);
         (m_window.learnmore_mc as MovieClip).buttonMode = true;
         (m_window.learnmore_mc as MovieClip).useHandCursor = true;
      }
      
      private function addDialogTextAndCloseBt() : void
      {
         addWidget(m_closeButton = new FarmButton(m_window.bt_close,this.onCloseButtonClicked),true);
         addWidget(new FarmTextField(m_window.body_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subscriptionsBenefitsBody")),true);
         if(SubscriptionsManager.inTrialPeriod())
         {
            addWidget(this.m_body1TF = new FarmTextField(m_window.body1_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"tsubsRet_packageprice")),true);
            addWidget(new FarmTextField(m_window.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"tsubscriptionsBenefitsTitle")),true);
         }
         else
         {
            addWidget(this.m_body1TF = new FarmTextField(m_window.body1_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subsRet_packageprice")),true);
            addWidget(new FarmTextField(m_window.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subscriptionsBenefitsTitle")),true);
         }
      }
      
      private function hideAllHidableElements() : void
      {
         this.hideAllFrames();
         this.hideLevelsButtonSelectedGlow();
         this.hideLevelSubtitles();
      }
      
      private function onBronzeClicked(event:Event = null) : void
      {
         var trail_mc:MovieClip = null;
         if(Boolean(m_window) && m_window.hasOwnProperty("trial_mc"))
         {
            trail_mc = m_window.trial_mc as MovieClip;
         }
         this.hideAllHidableElements();
         if(SubscriptionsManager.inTrialPeriod())
         {
            this.m_bronzeButtonBGSelected.alpha = 1;
            this.m_bronzeFrame.visible = true;
            this.m_bronzeSubtitle.visible = true;
            this.showSubsPackageCost(SubscriptionsManager.PACKAGE_COST_TRIAL);
            if(trail_mc)
            {
               trail_mc.visible = true;
            }
         }
         else
         {
            this.m_bronzeButtonBGSelected.alpha = 1;
            this.m_bronzeFrame.visible = true;
            this.m_bronzeSubtitle.visible = true;
            this.showSubsPackageCost(SubscriptionsManager.PACKAGE_COST_BRONZE);
            if(trail_mc)
            {
               trail_mc.visible = false;
            }
         }
      }
      
      private function onSilverClicked(event:Event = null) : void
      {
         this.hideAllHidableElements();
         this.m_silverButtonBGSelected.alpha = 1;
         this.m_silverFrame.visible = true;
         this.m_silverSubtitle.visible = true;
         this.showSubsPackageCost(SubscriptionsManager.PACKAGE_COST_SILVER);
      }
      
      private function onGoldClicked(event:Event = null) : void
      {
         this.hideAllHidableElements();
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_SUBSCRIPTIONS_V2_RETENTION_GOLD_AD) == Experiments.VARIANT_SUBSCRIPTIONS_V2_RETENTION_GOLD_AD)
         {
            this.showSubsPackageCost(SubscriptionsManager.PACKAGE_COST_GOLD);
         }
         this.m_goldButtonBGSelected.alpha = 1;
         this.m_goldFrame.visible = true;
         this.m_goldSubtitle.visible = true;
      }
      
      private function onRubyClicked(event:Event = null) : void
      {
         this.hideAllHidableElements();
         this.m_rubyButtonBGSelected.alpha = 1;
         this.m_rubyFrame.visible = true;
         this.m_rubySubtitle.visible = true;
         this.showSubsPackageCost(SubscriptionsManager.PACKAGE_COST_RUBY);
      }
      
      private function onDiamondClicked(event:Event = null) : void
      {
         this.hideAllHidableElements();
         this.m_diamondButtonBGSelected.alpha = 1;
         this.m_diamondFrame.visible = true;
         this.m_diamondSubtitle.visible = true;
         this.showSubsPackageCost(SubscriptionsManager.PACKAGE_COST_DIAMOND);
      }
      
      private function preselectLoadViewTab(level:int = 0) : void
      {
         switch(level)
         {
            case SubscriptionsManager.LEVEL_BRONZE:
               this.onBronzeClicked();
               break;
            case SubscriptionsManager.LEVEL_SILVER:
               this.onSilverClicked();
               break;
            case SubscriptionsManager.LEVEL_GOLD:
               this.onGoldClicked();
               break;
            case SubscriptionsManager.LEVEL_RUBY:
               this.onRubyClicked();
               break;
            case SubscriptionsManager.LEVEL_DIAMOND:
               this.onDiamondClicked();
               break;
            default:
               this.onBronzeClicked();
         }
      }
   }
}

