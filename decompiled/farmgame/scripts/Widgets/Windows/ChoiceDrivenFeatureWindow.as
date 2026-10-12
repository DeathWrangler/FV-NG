package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.HUD.HUD;
   import Managers.ChoiceDrivenManager;
   import Managers.Crafting.CraftingManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ChoiceDrivenFeatureSlotFrame;
   import Widgets.Frames.ResourcePreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import com.greensock.TweenMax;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.utils.Timer;
   
   public class ChoiceDrivenFeatureWindow extends FarmWindowWithTutorial
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 4;
      
      private static const X:String = "x";
      
      private static const IDLE_STATE:String = ".idle_mc";
      
      private static const ATTACK_STATE:String = ".fight_mc";
      
      private static const TutorialSuffix:String = "_fight";
      
      public static const SERVICE_NAME:String = "ChoiceDrivenService";
      
      public static const BAR_YELLOW:String = "yellow";
      
      public static const BAR_GREEN:String = "green";
      
      protected var m_featureName:String;
      
      private const TITLE_TF:String = "title_tf";
      
      private const DESCRIPTION_TF:String = "description_tf";
      
      private const WHATISTHIS_MC:String = "whatisthis_mc";
      
      private const XCURRENCY_MC:String = "xCurrency_mc";
      
      private const XICON_MC:String = "xIcon_mc";
      
      private const XCOUNT_TF:String = "xCount_tf";
      
      private const XCRAFT_BT:String = "xCraft_bt";
      
      private const XBUY_BT:String = "xBuy_bt";
      
      private const XPOST_BT:String = "xPost_bt";
      
      private const YCURRENCY_MC:String = "yCurrency_mc";
      
      private const YICON_MC:String = "yIcon_mc";
      
      private const YCOUNT_TF:String = "yCount_tf";
      
      private const YCOLLECT_BT:String = "yCollect_bt";
      
      private const YSKIP_BT:String = "ySkip_bt";
      
      private const NPC1_MC:String = "npc1_mc";
      
      private const LIFEMETER1_MC:String = "lifeMeter1_mc";
      
      private const NPC2_MC:String = "npc2_mc";
      
      private const LIFEMETER2_MC:String = "lifeMeter2_mc";
      
      private const ROUND_TF:String = "round_tf";
      
      private const FIGHT_BT:String = "fight_bt";
      
      private const FIREANIM_MC:String = "fireAnim_mc";
      
      private const METER1_MC:String = "meter1_mc";
      
      private const METER2_MC:String = "meter2_mc";
      
      private const TIMER_MC:String = "timer_mc";
      
      private const VIEW_BT:String = "viewOpponents_bt";
      
      private const SLOTS_MC:String = "slots_mc";
      
      private const BONUS_MC:String = "bonus_mc";
      
      private const BONUSTITLE_TF:String = "bonusTitle_tf";
      
      private const ICON_MC:String = "icon_mc";
      
      private const EXPIRED_MC:String = "bonusExpired_mc";
      
      private const EXPIRED_tf:String = "expired_tf";
      
      private const DISMISS_BT:String = "dismiss_bt";
      
      private const TEXT_TITLE:String = "_fight_title";
      
      private const TEXT_FINAL_TITLE:String = "_final_fight_title";
      
      private const TEXT_DESC:String = "_fight_description";
      
      private const TEXT_ROUND:String = "_round_number";
      
      private const TEXT_WHATISTHIS:String = "HowDoesThisWork";
      
      private const TEXT_FIGHT_HOVER:String = "_fight_button_hover";
      
      private const TEXT_DISMISS:String = "_fight_dismiss";
      
      private const TEXT_CRAFT_RECIPE_NAME:String = "_craft_recipe_name";
      
      private const TEXT_FEATURE_TIME_LEFT:String = "_feature_timeLeft";
      
      private const TEXT_TIME_LEFT:String = "_timeLeft";
      
      private const TEXT_BONUS_EXPIRED:String = "_bonus_expired";
      
      private const TEXT_COLLECT_TIME_LEFT:String = "_collect_timeLeft";
      
      protected var m_slotsFrame:ChoiceDrivenFeatureSlotFrame;
      
      protected var m_xCurrencyFrame:ZwFrame;
      
      protected var m_xCraftButton:FarmAnimatedTextButton;
      
      protected var m_xBuyButton:FarmAnimatedTextButton;
      
      protected var m_xPostButton:FarmAnimatedTextButton;
      
      protected var m_yCurrencyFrame:ZwFrame;
      
      protected var m_yCollectButton:FarmAnimatedTextButton;
      
      protected var m_ySkipButton:FarmAnimatedCashButton;
      
      protected var m_sakuraFrame:ResourcePreviewFrame;
      
      protected var m_contederFrame:ResourcePreviewFrame;
      
      protected var m_lifeMeter1:MovieClip;
      
      protected var m_lifeMeter2:MovieClip;
      
      protected var m_meter1Frame:ZwFrame;
      
      protected var m_meter2Frame:ZwFrame;
      
      protected var m_timerFrame:ZwFrame;
      
      protected var m_bonusFrame:ZwFrame;
      
      protected var m_fireFrame:ZwFrame;
      
      protected var m_bonusExpiredFrame:ZwFrame;
      
      protected var m_fightButton:FarmAnimatedTextButton;
      
      protected var m_dismissButton:FarmAnimatedTextButton;
      
      protected var m_viewOpponentsButton:FarmAnimatedTextButton;
      
      protected var m_descTf:ZwTextField;
      
      protected var m_roundTf:ZwTextField;
      
      private var m_timer:Timer;
      
      private var m_BonusTimer:Timer;
      
      private var m_GlowTimer:Timer;
      
      public function ChoiceDrivenFeatureWindow(assetPathUrl:String, featureName:String)
      {
         this.m_featureName = featureName;
         super(this.m_featureName + TutorialSuffix,assetPathUrl,NUM_TUTORIAL_SCENES,true,true);
      }
      
      override protected function postLoadComplete() : void
      {
         var showExpired:Boolean = false;
         var activeContender:String = null;
         var bonItem:FarmItem = null;
         var itemName:String = null;
         var infoTooltip:FarmTextTooltip = null;
         var xCurrencyItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.manager.currencyCodePink);
         var yCurrencyItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.manager.currencyCodeWhite);
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_TITLE)));
         }
         if(m_window.hasOwnProperty(this.DESCRIPTION_TF))
         {
            this.m_descTf = addWidget(new ZwTextField(m_window[this.DESCRIPTION_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_DESC))) as ZwTextField;
         }
         if(m_window.hasOwnProperty(this.WHATISTHIS_MC))
         {
            addWidget(new FarmAnimatedTextButton(m_window[this.WHATISTHIS_MC],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.TEXT_WHATISTHIS),this.howDoesThisWorkClick));
         }
         if(m_window.hasOwnProperty(this.SLOTS_MC))
         {
            addWidget(this.m_slotsFrame = new ChoiceDrivenFeatureSlotFrame(this.m_featureName,m_window[this.SLOTS_MC],this));
         }
         if(m_window.hasOwnProperty(this.XCURRENCY_MC))
         {
            addWidget(this.m_xCurrencyFrame = new ZwFrame(m_window[this.XCURRENCY_MC]));
            if(this.m_xCurrencyFrame.element.hasOwnProperty(this.XICON_MC))
            {
               addWidget(new FarmIcon(this.m_xCurrencyFrame.element[this.XICON_MC]));
               (getWidget(this.m_xCurrencyFrame.element[this.XICON_MC]) as FarmIcon).attachTooltip(new FarmTextTooltip(xCurrencyItem.friendlyTitle));
            }
            if(this.m_xCurrencyFrame.element.hasOwnProperty(this.XCOUNT_TF))
            {
               this.m_xCurrencyFrame.element[this.XCOUNT_TF].text = X + this.manager.getPinkConsumableCount();
               this.m_xCurrencyFrame.element[this.XCOUNT_TF].visible = true;
            }
            if(this.m_xCurrencyFrame.element.hasOwnProperty(this.XCRAFT_BT))
            {
               this.m_xCraftButton = new FarmAnimatedTextButton(this.m_xCurrencyFrame.element[this.XCRAFT_BT],"Craft",this.onClickCraft);
               this.m_xCurrencyFrame.addWidget(this.m_xCraftButton);
            }
            if(this.m_xCurrencyFrame.element.hasOwnProperty(this.XBUY_BT))
            {
               this.m_xBuyButton = new FarmAnimatedTextButton(this.m_xCurrencyFrame.element[this.XBUY_BT],"Buy",this.openBuyWindow);
               this.m_xCurrencyFrame.addWidget(this.m_xBuyButton);
            }
            if(this.m_xCurrencyFrame.element.hasOwnProperty(this.XPOST_BT))
            {
               this.m_xPostButton = new FarmAnimatedTextButton(this.m_xCurrencyFrame.element[this.XPOST_BT],"Ask",this.onAskButtonClick);
               this.m_xCurrencyFrame.addWidget(this.m_xPostButton);
            }
            if(m_window.hasOwnProperty(this.YCURRENCY_MC))
            {
               addWidget(this.m_yCurrencyFrame = new ZwFrame(m_window[this.YCURRENCY_MC]));
               if(this.m_yCurrencyFrame.element.hasOwnProperty(this.YICON_MC))
               {
                  addWidget(new FarmIcon(this.m_yCurrencyFrame.element[this.YICON_MC]));
                  (getWidget(this.m_yCurrencyFrame.element[this.YICON_MC]) as FarmIcon).attachTooltip(new FarmTextTooltip(yCurrencyItem.friendlyTitle));
               }
               if(this.m_yCurrencyFrame.element.hasOwnProperty(this.YCOUNT_TF))
               {
                  this.m_yCurrencyFrame.element[this.YCOUNT_TF].text = X + this.manager.getWhiteConsumableCount();
                  this.m_yCurrencyFrame.element[this.YCOUNT_TF].visible = true;
               }
               if(this.m_yCurrencyFrame.element.hasOwnProperty(this.YCOLLECT_BT))
               {
                  this.m_yCollectButton = new FarmAnimatedTextButton(this.m_yCurrencyFrame.element[this.YCOLLECT_BT],"Collect",this.onClickHarvest);
                  this.m_yCurrencyFrame.addWidget(this.m_yCollectButton);
               }
               if(this.m_yCurrencyFrame.element.hasOwnProperty(this.YSKIP_BT))
               {
                  this.m_ySkipButton = new FarmAnimatedCashButton(this.m_yCurrencyFrame.element[this.YSKIP_BT],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"Skip"),yCurrencyItem.cash.toString(),this.onSkipHarvest,false,false,true,"",ChoiceDrivenManager.DEFAULT_PAYMENT_CONFIRMATION_MINIMUM);
                  this.m_yCurrencyFrame.addWidget(this.m_ySkipButton,true);
                  this.m_ySkipButton.buyConfirmationText = ZLocUtils.t("Dialogs","FarmCashBuyConfirmation",{"price":yCurrencyItem.cash.toString()});
                  this.m_ySkipButton.keepDisabledAfterPaymentConfirmation = true;
               }
            }
            if(m_window.hasOwnProperty(this.NPC1_MC))
            {
               this.m_sakuraFrame = new ResourcePreviewFrame(m_window[this.NPC1_MC],this.manager.sakuraMovieClip(),"sakura" + IDLE_STATE);
               addWidget(this.m_sakuraFrame);
            }
            if(m_window.hasOwnProperty(this.LIFEMETER1_MC))
            {
               this.m_lifeMeter1 = m_window[this.LIFEMETER1_MC];
               this.m_lifeMeter1.visible = true;
            }
            if(m_window.hasOwnProperty(this.NPC2_MC))
            {
               activeContender = this.manager.getActiveContender();
               this.m_contederFrame = new ResourcePreviewFrame(m_window[this.NPC2_MC],this.manager.contenderMovieClip(activeContender),this.manager.getActiveContenderIdleExportName());
               addWidget(this.m_contederFrame);
            }
            if(m_window.hasOwnProperty(this.LIFEMETER2_MC))
            {
               this.m_lifeMeter2 = m_window[this.LIFEMETER2_MC];
               this.m_lifeMeter2.visible = true;
            }
            if(m_window.hasOwnProperty(this.ROUND_TF))
            {
               addWidget(this.m_roundTf = new ZwTextField(m_window[this.ROUND_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_ROUND,{"number":this.manager.getRoundNumber()})));
            }
            if(m_window.hasOwnProperty(this.FIGHT_BT))
            {
               this.m_fightButton = new FarmAnimatedTextButton(m_window[this.FIGHT_BT],"Fight",this.onClickFight);
               addWidget(this.m_fightButton);
            }
            if(m_window.hasOwnProperty(this.FIREANIM_MC))
            {
               this.m_fireFrame = new ZwFrame(m_window[this.FIREANIM_MC]);
               addWidget(this.m_fireFrame,false);
            }
            if(m_window.hasOwnProperty(this.METER1_MC))
            {
               addWidget(this.m_meter1Frame = new ZwFrame(m_window[this.METER1_MC]));
               this.m_meter1Frame.element.bar_complete_mc.visible = false;
               this.m_meter1Frame.element.bar_fill_mc.visible = false;
            }
            if(m_window.hasOwnProperty(this.METER2_MC))
            {
               addWidget(this.m_meter2Frame = new ZwFrame(m_window[this.METER2_MC]));
               this.m_meter2Frame.element.bar_fill_mc.visible = false;
               this.m_meter2Frame.element.bar_complete_mc.visible = false;
            }
            if(m_window.hasOwnProperty(this.TIMER_MC))
            {
               addWidget(this.m_timerFrame = new ZwFrame(m_window[this.TIMER_MC]));
               this.setTimerText();
            }
            showExpired = false;
            if(m_window.hasOwnProperty(this.BONUS_MC))
            {
               addWidget(this.m_bonusFrame = new ZwFrame(m_window[this.BONUS_MC]),true);
               if(this.manager.getBonusSelected() != null)
               {
                  this.m_bonusFrame.visible = true;
                  bonItem = Global.farmGameSettingsManager.getFarmItemByName(this.manager.getBonusSelected());
                  addWidget(new ZwTextField(this.m_bonusFrame.element[this.BONUSTITLE_TF],"BONUS ITEM"));
                  addWidget(new FarmIcon(this.m_bonusFrame.element[this.ICON_MC],bonItem.getImageByName("feed")));
                  if(this.manager.isContenderBonusActive())
                  {
                     itemName = ZLocUtils.tk_pk_asTitle(bonItem.friendlyName);
                     infoTooltip = new FarmTextTooltip(itemName);
                     (getWidget(this.m_bonusFrame.element[this.ICON_MC]) as FarmIcon).attachTooltip(infoTooltip);
                     this.setBonusTimerText();
                  }
                  else if(!this.manager.isBonusExpireDismissed())
                  {
                     (this.m_bonusFrame.element[this.ICON_MC] as MovieClip).filters = [new ColorMatrixFilter(FarmGameUtil.getSaturationMatrix(0))];
                     ZLocUtils.setText(m_window,"bonus_mc.bonusTimer1_tf","Dialogs","Expired");
                     this.m_dismissButton = new FarmAnimatedTextButton(this.m_bonusFrame.element[this.DISMISS_BT],"Dismiss",this.onClickDismiss);
                     infoTooltip = new FarmTextTooltip(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_DISMISS));
                     addWidget(this.m_dismissButton);
                     this.m_dismissButton.attachTooltip(infoTooltip);
                  }
                  else
                  {
                     showExpired = true;
                  }
               }
               else if(!this.manager.isContenderBonusActive())
               {
                  showExpired = true;
               }
               if(showExpired)
               {
                  if(m_window.hasOwnProperty(this.EXPIRED_MC))
                  {
                     this.m_bonusFrame.visible = false;
                     m_window[this.EXPIRED_MC].visible = true;
                     m_window[this.EXPIRED_MC][this.EXPIRED_tf].text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_BONUS_EXPIRED);
                  }
               }
            }
            if(m_window.hasOwnProperty(this.VIEW_BT))
            {
               this.m_viewOpponentsButton = new FarmAnimatedTextButton(m_window[this.VIEW_BT],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_contender_title"),this.viewOpponents);
               addWidget(this.m_viewOpponentsButton);
            }
            super.postLoadComplete();
            this.refreshWindow();
         }
      }
      
      public function partialXSlotRefresh() : void
      {
         var xPostTimeRemaining:int = 0;
         var timeRemaining:Array = null;
         if(this.m_xCurrencyFrame.element)
         {
            this.m_xCurrencyFrame.element[this.XCOUNT_TF].text = X + this.manager.getPinkConsumableCount();
            xPostTimeRemaining = this.manager.getTimeRemaining(this.manager.ASK_FEED_FREQUENCY_KEY);
            if(xPostTimeRemaining > 0)
            {
               timeRemaining = FarmGameUtil.parseTimeLeft(xPostTimeRemaining);
               if(timeRemaining[1] !== 0 || timeRemaining[2] !== 0)
               {
                  FarmGameUtil.disableButtonAndShowTooltip(this.m_xPostButton,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"asksnowflake_timeleft",{
                     "hrs":timeRemaining[1],
                     "min":timeRemaining[2]
                  }));
               }
               else
               {
                  FarmGameUtil.disableButtonAndShowTooltip(this.m_xPostButton,"Ask again in " + timeRemaining[3] + " seconds");
               }
            }
            else
            {
               this.m_xPostButton.enabled = true;
               this.m_xPostButton.detachTooltip();
            }
         }
      }
      
      public function partialYSlotRefresh() : void
      {
         var yCollectTimeRemaining:int = 0;
         var timeRemaining:Array = null;
         if(this.m_yCurrencyFrame.element)
         {
            this.m_yCurrencyFrame.element[this.YCOUNT_TF].text = X + this.manager.getWhiteConsumableCount();
            yCollectTimeRemaining = this.manager.getTimeRemaining(this.manager.HARVEST_FREQUENCY_KEY);
            if(yCollectTimeRemaining > 0)
            {
               this.m_ySkipButton.enabled = true;
               timeRemaining = FarmGameUtil.parseTimeLeft(yCollectTimeRemaining);
               if(timeRemaining[1] !== 0 || timeRemaining[2] !== 0)
               {
                  FarmGameUtil.disableButtonAndShowTooltip(this.m_yCollectButton,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_COLLECT_TIME_LEFT,{
                     "hrs":timeRemaining[1],
                     "min":timeRemaining[2]
                  }));
               }
               else
               {
                  FarmGameUtil.disableButtonAndShowTooltip(this.m_yCollectButton,"Collect in " + timeRemaining[3] + " seconds");
               }
            }
            else
            {
               this.m_yCollectButton.enabled = true;
               this.m_yCollectButton.detachTooltip();
               this.m_ySkipButton.enabled = false;
               this.m_ySkipButton.applyGrayOut = true;
            }
         }
      }
      
      override public function refreshWindow() : void
      {
         this.partialXSlotRefresh();
         this.partialYSlotRefresh();
         if(this.m_roundTf.element)
         {
            this.m_roundTf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_ROUND,{"number":this.manager.getRoundNumber()});
         }
         if(this.m_slotsFrame)
         {
            this.m_slotsFrame.refresh();
         }
         var completedPercentage:Number = this.manager.getGreenProgressMilestone();
         this.updateProgressBar(BAR_GREEN,completedPercentage);
         this.updateProgressBar(BAR_YELLOW,this.manager.getPinkConsumableProgress(),this.manager.getWhiteConsumableProgress());
         this.m_lifeMeter1.gotoAndStop(this.manager.getRoundNumber());
         this.m_lifeMeter2.gotoAndStop(this.manager.getRoundNumber());
         if(this.manager.canClaimReward())
         {
            this.m_sakuraFrame.exportName = "sakura" + ATTACK_STATE;
            this.m_contederFrame.exportName = this.manager.getActiveContenderFightExportName();
            if(this.m_fireFrame.element)
            {
               this.m_fireFrame.visible = true;
               this.m_fightButton.enabled = true;
               this.m_fightButton.detachTooltip();
            }
         }
         else
         {
            this.m_sakuraFrame.exportName = "sakura" + IDLE_STATE;
            this.m_contederFrame.exportName = this.manager.getActiveContenderIdleExportName();
            if(this.m_fireFrame.element)
            {
               this.m_fireFrame.visible = false;
               FarmGameUtil.disableButtonAndShowTooltip(this.m_fightButton,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_FIGHT_HOVER));
            }
         }
         this.disableGlowProgressBar();
      }
      
      private function updateProgressBar(barType:String, percentValue1:Number, percentValue2:Number = 0) : void
      {
         var barWidth:Number = NaN;
         var barWidth1:Number = NaN;
         var barWidth2:Number = NaN;
         var circleBarWidth:Number = 22;
         var barSegmentWidth:Number = 120;
         var endCircleBarWidth:Number = 9;
         if(Boolean(this.m_meter1Frame.element) && Boolean(this.m_meter2Frame.element))
         {
            this.m_meter1Frame.element.bar_complete_mc.visible = true;
            this.m_meter2Frame.element.bar_complete_mc.visible = true;
            this.m_meter1Frame.element.bar_fill_mc.visible = true;
            this.m_meter2Frame.element.bar_fill_mc.visible = true;
            if(barType == BAR_GREEN)
            {
               barWidth = percentValue1 * barSegmentWidth * 4;
               if(Boolean(this.m_meter1Frame.element.bar_complete_mc) && Boolean(this.m_meter2Frame.element.bar_complete_mc))
               {
                  if(percentValue1 == 0)
                  {
                     this.m_meter1Frame.element.bar_complete_mc.visible = false;
                     this.m_meter2Frame.element.bar_complete_mc.visible = false;
                  }
                  else if(percentValue1 == 1)
                  {
                     TweenMax.to(this.m_meter1Frame.element.bar_complete_mc,2,{"width":barWidth + circleBarWidth + endCircleBarWidth});
                     TweenMax.to(this.m_meter2Frame.element.bar_complete_mc,2,{"width":barWidth + circleBarWidth + endCircleBarWidth});
                  }
                  else
                  {
                     TweenMax.to(this.m_meter1Frame.element.bar_complete_mc,2,{"width":barWidth + circleBarWidth});
                     TweenMax.to(this.m_meter2Frame.element.bar_complete_mc,2,{"width":barWidth + circleBarWidth});
                  }
               }
            }
            else if(barType == BAR_YELLOW)
            {
               barWidth1 = percentValue1 * barSegmentWidth * 4;
               barWidth2 = percentValue2 * barSegmentWidth * 4;
               if(Boolean(this.m_meter1Frame.element.bar_fill_mc) && Boolean(this.m_meter2Frame.element.bar_fill_mc))
               {
                  if(percentValue1 == 0)
                  {
                     this.m_meter1Frame.element.bar_fill_mc.visible = false;
                  }
                  else if(percentValue1 == 1)
                  {
                     TweenMax.to(this.m_meter1Frame.element.bar_fill_mc,2,{"width":barWidth1 + circleBarWidth + endCircleBarWidth});
                  }
                  else
                  {
                     TweenMax.to(this.m_meter1Frame.element.bar_fill_mc,2,{"width":barWidth1 + circleBarWidth});
                  }
                  if(percentValue2 == 0)
                  {
                     this.m_meter2Frame.element.bar_fill_mc.visible = false;
                     (this.m_meter2Frame.element.bar_fill_mc as MovieClip).width = barWidth2;
                  }
                  else if(percentValue2 == 1)
                  {
                     TweenMax.to(this.m_meter2Frame.element.bar_fill_mc,2,{"width":barWidth2 + circleBarWidth + endCircleBarWidth});
                  }
                  else
                  {
                     TweenMax.to(this.m_meter2Frame.element.bar_fill_mc,2,{"width":barWidth2 + circleBarWidth});
                  }
               }
            }
         }
      }
      
      public function enableGlowProgressBar() : void
      {
         if(Boolean(this.m_meter1Frame.element) && Boolean(this.m_meter2Frame.element))
         {
            this.m_meter1Frame.element.progressEffect_mc.visible = true;
            this.m_meter2Frame.element.progressEffect_mc.visible = true;
         }
         this.startGlowTimer();
      }
      
      public function disableGlowProgressBar() : void
      {
         if(Boolean(this.m_meter1Frame.element) && Boolean(this.m_meter2Frame.element))
         {
            this.m_meter1Frame.element.progressEffect_mc.visible = false;
            this.m_meter2Frame.element.progressEffect_mc.visible = false;
         }
      }
      
      override public function close() : void
      {
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this.m_timer = null;
         }
         if(this.m_BonusTimer)
         {
            this.m_BonusTimer.stop();
            this.m_BonusTimer.removeEventListener(TimerEvent.TIMER,this.onBonusTimer);
            this.m_BonusTimer = null;
         }
         super.close();
      }
      
      private function get manager() : ChoiceDrivenManager
      {
         return ChoiceDrivenManager.getInstance(this.m_featureName);
      }
      
      private function setTimerText() : void
      {
         var timeRemaining:Number = NaN;
         var numDays:int = 0;
         var daysLeft:String = null;
         if(this.m_timerFrame)
         {
            timeRemaining = (FarmGameUtil.synchronizedDateToNumber(this.manager.featureEndDate) - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
            numDays = Math.ceil(timeRemaining / FarmGameUtil.NUM_SECS_IN_DAY);
            daysLeft = this.getExpiryDateText(this.manager.featureEndDate);
            addWidget(new ZwTextField(this.m_timerFrame.element.timerTitle_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_FEATURE_TIME_LEFT)));
            addWidget(new ZwTextField(this.m_timerFrame.element.timer1_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_TIME_LEFT,{"days":daysLeft})));
            if(!isNaN(timeRemaining))
            {
               if(numDays > 2)
               {
                  this.m_timerFrame.element.timer2_mc.visible = false;
               }
               else
               {
                  this.startTimer();
                  this.m_timerFrame.element.timer1_tf.visible = false;
                  this.m_timerFrame.element.timer2_mc.visible = true;
                  ZLocUtils.setText(m_window,"timer_mc.timer2_mc.timerAnim_mc.timer2_tf","Dialogs",this.m_featureName + this.TEXT_TIME_LEFT,{"days":daysLeft});
               }
            }
         }
      }
      
      private function setBonusTimerText() : void
      {
         var timeRemaining:Number = NaN;
         var numDays:int = 0;
         var daysLeft:String = null;
         if(this.m_bonusFrame)
         {
            timeRemaining = (FarmGameUtil.synchronizedDateToNumber(this.manager.bonusEndDate) - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
            numDays = Math.ceil(timeRemaining / FarmGameUtil.NUM_SECS_IN_DAY);
            daysLeft = this.getExpiryDateText(this.manager.bonusEndDate);
            addWidget(new ZwTextField(this.m_bonusFrame.element.bonusTimer1_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_TIME_LEFT,{"days":daysLeft})));
            if(!isNaN(timeRemaining))
            {
               if(numDays > 1)
               {
                  this.m_bonusFrame.element.bonusTimer2_mc.visible = false;
               }
               else
               {
                  this.startBonusTimer();
                  this.m_bonusFrame.element.bonusTimer1_tf.visible = false;
                  this.m_bonusFrame.element.bonusTimer2_mc.visible = true;
                  this.m_bonusFrame.element.bonusTimer2_mc.timerAnim_mc.bonusTimer2_tf.text = HUD.getformattedTimeLeft(timeRemaining);
               }
            }
         }
      }
      
      private function howDoesThisWorkClick(event:Event) : void
      {
         showTutorial();
      }
      
      public function onAskButtonClick(e:Event) : void
      {
         if(this.m_xPostButton.enabled)
         {
            this.m_xPostButton.enabled = false;
            this.manager.askForCurrency();
         }
      }
      
      public function onClickHarvest(e:Event) : void
      {
         if(this.m_yCollectButton.enabled)
         {
            this.enableWindow(false);
            this.manager.harvestConsumable(this);
            this.m_ySkipButton.enabled = true;
            this.m_ySkipButton.applyGrayOut = false;
         }
      }
      
      public function onSkipHarvest(e:Event) : void
      {
         this.m_ySkipButton.enabled = false;
         this.m_ySkipButton.applyGrayOut = true;
         this.manager.skipHarvest(this);
      }
      
      protected function openBuyWindow(event:Event) : void
      {
         tintWindow();
         enableInput = false;
         this.manager.openBuyWindow(this);
      }
      
      private function onClickFight(event:Event) : void
      {
         if(this.m_fightButton.enabled)
         {
            this.enableWindow(false);
            this.manager.claimReward(this);
            this.m_fightButton.enabled = false;
            this.m_fireFrame.visible = false;
         }
      }
      
      private function onClickCraft(event:Event) : void
      {
         CraftingManager.getInstance().openCraftshopWindow(CraftingManager.getCraftShopNameForCurrentWorld(Global.worldManager.currentWorldType),ZLocUtils.t("Dialogs",this.m_featureName + this.TEXT_CRAFT_RECIPE_NAME),this,"consumable",this.refreshWindow);
      }
      
      private function viewOpponents(event:Event) : void
      {
         this.manager.showContenderUI();
         this.close();
      }
      
      private function onClickDismiss(event:Event) : void
      {
         this.m_dismissButton.visible = false;
         this.manager.dismissNoBonusMessage(this);
         if(this.manager.isBonusExpireDismissed())
         {
            if(this.m_bonusFrame)
            {
               this.m_bonusFrame.visible = false;
            }
            if(m_window.hasOwnProperty(this.EXPIRED_MC))
            {
               m_window[this.EXPIRED_MC].visible = true;
               m_window[this.EXPIRED_MC][this.EXPIRED_tf].text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_BONUS_EXPIRED);
            }
         }
      }
      
      private function startTimer() : void
      {
         if(this.m_timer == null)
         {
            this.m_timer = new Timer(1000);
            this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer);
            this.m_timer.start();
         }
      }
      
      private function startGlowTimer() : void
      {
         if(this.m_GlowTimer == null)
         {
            this.m_GlowTimer = new Timer(5000);
            this.m_GlowTimer.addEventListener(TimerEvent.TIMER,this.onGlowTimer);
            this.m_GlowTimer.start();
         }
      }
      
      private function startBonusTimer() : void
      {
         if(this.m_timer == null)
         {
            this.m_timer = new Timer(1000);
            this.m_timer.addEventListener(TimerEvent.TIMER,this.onBonusTimer);
            this.m_timer.start();
         }
      }
      
      private function onTimer(event:TimerEvent) : void
      {
         var timeRemaining:Number = (FarmGameUtil.synchronizedDateToNumber(this.manager.featureEndDate) - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         if(!isNaN(timeRemaining))
         {
            this.m_timerFrame.element.timer1_tf.visible = false;
            this.m_timerFrame.element.timer2_mc.visible = true;
            ZLocUtils.setText(m_window,"timer_mc.timer2_mc.timerAnim_mc.timer2_tf","Dialogs",this.m_featureName + this.TEXT_TIME_LEFT,{"days":HUD.getformattedTimeLeft(timeRemaining)});
         }
      }
      
      private function onBonusTimer(event:TimerEvent) : void
      {
         var timeRemaining:Number = (FarmGameUtil.synchronizedDateToNumber(this.manager.bonusEndDate) - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         if(!isNaN(timeRemaining))
         {
            this.m_bonusFrame.element.bonusTimer1_tf.visible = false;
            this.m_bonusFrame.element.bonusTimer2_mc.visible = true;
            this.m_bonusFrame.element.bonusTimer2_mc.timerAnim_mc.bonusTimer2_tf.text = HUD.getformattedTimeLeft(timeRemaining);
         }
      }
      
      private function onGlowTimer(event:TimerEvent) : void
      {
         this.disableGlowProgressBar();
         if(this.m_GlowTimer)
         {
            this.m_GlowTimer.stop();
            this.m_GlowTimer.removeEventListener(TimerEvent.TIMER,this.onGlowTimer);
            this.m_GlowTimer = null;
         }
      }
      
      private function getExpiryDateText(endDate:String) : String
      {
         var result:String = "";
         var timeRemaining:Number = (FarmGameUtil.synchronizedDateToNumber(endDate) - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var numDays:int = Math.ceil(timeRemaining / FarmGameUtil.NUM_SECS_IN_DAY);
         if(!isNaN(timeRemaining))
         {
            if(numDays > 1)
            {
               result = numDays.toString() + " Days";
            }
            else
            {
               result = HUD.getformattedTimeLeft(timeRemaining);
            }
         }
         return result;
      }
      
      public function enableWindow(enable:Boolean) : void
      {
         this.enableInput = enable;
         if(enable)
         {
            untintWindow();
            this.refreshWindow();
         }
         else
         {
            tintWindow();
         }
      }
      
      public function enableWindowWithGlow() : void
      {
         this.enableWindow(true);
         this.enableGlowProgressBar();
      }
   }
}

