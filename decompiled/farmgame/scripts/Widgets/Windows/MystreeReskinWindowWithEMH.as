package Widgets.Windows
{
   import Classes.Constants.Experiments;
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.HUD.HUD;
   import Display.TutorialUI;
   import Display.UI;
   import Managers.FarmStatsManager;
   import Managers.IMystreeReskinManager;
   import Managers.MystreeReskinDifficultyLevelsManager;
   import Managers.MystreeReskinManager;
   import Managers.MystreeReskinManagerWithEMH;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Constants.ZwToggleMode;
   import Widgets.Core.Constants.ZwToggleState;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.MystreeReskinFrame;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.text.TextField;
   import flash.utils.Timer;
   
   public class MystreeReskinWindowWithEMH extends FarmWindow implements IMystreeReskinWindow
   {
      
      private static const TREE_PREFIX:String = "treecount_";
      
      private static const TOOLTIP_PRIFIX:String = "tooltip_";
      
      private static const TIMER_DELAY_MS:int = 1000;
      
      private var m_featureName:String = null;
      
      private var m_tree_bt:FarmAnimatedTextButton;
      
      private var m_switch_bt:FarmAnimatedTextButton;
      
      private var m_speedup_bt:FarmAnimatedCashButton;
      
      private var m_craft_bt:FarmAnimatedTextButton;
      
      private var m_buy_bt:FarmAnimatedTextButton;
      
      private var m_awesome_bt:FarmAnimatedTextButton;
      
      private var m_craft_mc:MovieClip;
      
      private var m_plots:MystreeReskinFrame;
      
      private var m_treeCollection:MovieClip;
      
      private var m_sunshineCount_tf:ZwTextField;
      
      private var m_treecollection_subtitle_tf:ZwTextField;
      
      private var m_ask_bt:FarmAnimatedTextButton;
      
      private var m_whatIsThis_mc:FarmAnimatedButton;
      
      private var m_animatedNPC:MovieClip;
      
      private var m_npcAnimationCallback:Function = null;
      
      private var m_isNPCAnimComplete:Boolean = true;
      
      private var m_endDate:String;
      
      private var m_timer:Timer;
      
      private var m_overLay_mc:MovieClip;
      
      private var m_watch_add_to_speed_bt:FarmAnimatedTextButton;
      
      public function MystreeReskinWindowWithEMH(featureName:String = null)
      {
         this.m_featureName = featureName;
         var dialogPath:String = MystreeReskinManagerWithEMH.getInstance(featureName).getMainDialogAssetURL();
         if(dialogPath != "")
         {
            super(dialogPath);
         }
         var ftueFlag:String = MystreeReskinManagerWithEMH.getInstance(this.m_featureName).getFtueFlag();
         var ftueChristmasPatchFlag:String = MystreeReskinManagerWithEMH.getInstance(this.m_featureName).getFtueChristmasFlag();
         if(!Global.player.getSeenFlag(ftueFlag))
         {
            MystreeReskinManagerWithEMH.getInstance(this.m_featureName).initFeature();
            this.howDoesThisWorkClick(null);
         }
         else if(!Global.player.getSeenFlag(ftueChristmasPatchFlag))
         {
            MystreeReskinManagerWithEMH.getInstance(this.m_featureName).setDataForAdditionalRewards();
            Global.player.setSeenFlag(ftueChristmasPatchFlag,true);
         }
         this.m_endDate = MystreeReskinManagerWithEMH.getInstance(this.m_featureName).getEndDate();
      }
      
      override protected function postLoadComplete() : void
      {
         var footNote:String = null;
         var noOfAnimal:int = 0;
         var rainbowButterfly:ZwWidget = null;
         var feedLimitSeconds:Number = NaN;
         var replacements:Object = null;
         super.postLoadComplete();
         var windowName:String = MystreeReskinManagerWithEMH.getInstance(this.m_featureName).getWindowName();
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_title")),true);
         }
         if(m_window.hasOwnProperty("subtitle_tf"))
         {
            if(MystreeReskinManagerWithEMH.getInstance(this.m_featureName).isFeatureInActivePeriod())
            {
               addWidget(new ZwTextField(m_window.subtitle_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_subtitle")),true);
            }
            else
            {
               addWidget(new ZwTextField(m_window.subtitle_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_subtitle_redeem")),true);
            }
         }
         if(m_window.hasOwnProperty("subtitle2_tf"))
         {
            noOfAnimal = MystreeReskinManagerWithEMH.getInstance(this.m_featureName).getNoOfAnimals();
            addWidget(new ZwTextField(m_window.subtitle2_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_subtitle2",{"noOfAnimal":noOfAnimal})),true);
         }
         if(m_window.hasOwnProperty("craft_mc"))
         {
            this.m_craft_mc = m_window.craft_mc;
            if(m_window.craft_mc.hasOwnProperty("bucketcount_tf"))
            {
               addWidget(this.m_sunshineCount_tf = new ZwTextField(m_window.craft_mc.bucketcount_tf,""),true);
               this.m_sunshineCount_tf.text = MystreeReskinManagerWithEMH.getInstance(this.m_featureName).getNumberOfBuckets();
            }
            if(m_window.craft_mc.hasOwnProperty("craftbucket_bt"))
            {
               this.m_craft_bt = addWidget(new FarmAnimatedTextButton(m_window.craft_mc.craftbucket_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_craftbucket"),this.clickCraft),true) as FarmAnimatedTextButton;
            }
            this.m_craft_mc.visible = true;
            if(!MystreeReskinManagerWithEMH.getInstance(this.m_featureName).isFeatureInActivePeriod())
            {
               this.m_craft_bt.enabled = false;
            }
         }
         if(m_window.hasOwnProperty("buy_bt"))
         {
            this.m_buy_bt = addWidget(new FarmAnimatedTextButton(m_window.buy_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_BuyButtonText"),this.clickBuyBtn),true) as FarmAnimatedTextButton;
         }
         if(m_window.hasOwnProperty("view_bt"))
         {
            addWidget(this.m_tree_bt = new FarmAnimatedTextButton(m_window.view_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_buildingName"),this.openTreeWindow),true);
         }
         if(m_window.hasOwnProperty("change_bt"))
         {
            if(MystreeReskinManagerWithEMH.getInstance(this.m_featureName).isAnyStageCompleted() == false)
            {
               addWidget(this.m_switch_bt = new FarmAnimatedTextButton(m_window.change_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"switchOK"),this.switchDifficultyLevel),true) as FarmAnimatedTextButton;
               footNote = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_switchFootNote");
               if(MystreeReskinManagerWithEMH.getInstance(this.m_featureName).canSwitchDifficultyLevel() == false)
               {
                  this.m_switch_bt.enabled = false;
                  this.m_switch_bt.applyGrayOut = true;
                  footNote = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_disabledFootNote");
               }
            }
            else
            {
               addWidget(this.m_switch_bt = new FarmAnimatedTextButton(m_window.change_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_PlayAnotherstage"),this.ReplayFeature),true) as FarmAnimatedTextButton;
               footNote = "";
               if(MystreeReskinManagerWithEMH.getInstance(this.m_featureName).isStageComplete() == false || !MystreeReskinManagerWithEMH.getInstance(this.m_featureName).isFeatureInActivePeriod())
               {
                  this.m_switch_bt.enabled = true;
                  this.m_switch_bt.applyGrayOut = false;
                  footNote = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_disabledFootNote");
               }
            }
         }
         if(m_window.hasOwnProperty("speed_bt"))
         {
            this.m_speedup_bt = addWidget(new FarmAnimatedCashButton(m_window.speed_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"SeedDispenser_SpeedUp"),MystreeReskinManagerWithEMH.getInstance(this.m_featureName).getSpeedUpCost().toString(),this.onSpeedUp),true) as FarmAnimatedCashButton;
         }
         if(m_window.hasOwnProperty("watchAd_bt"))
         {
            this.m_watch_add_to_speed_bt = addWidget(new FarmAnimatedTextButton(m_window.watchAd_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"watch_to_skip"),this.watchAddToSpeedup),true) as FarmAnimatedTextButton;
         }
         if(m_window.hasOwnProperty("whatisthis_mc"))
         {
            this.m_whatIsThis_mc = addWidget(new FarmAnimatedTextButton(m_window.whatisthis_mc,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"HowDoesThisWork"),this.howDoesThisWorkClick),true) as FarmAnimatedButton;
         }
         if(m_window.plantplot_mc)
         {
            addWidget(this.m_plots = new MystreeReskinFrame(m_window.plantplot_mc,this.m_featureName,this),true);
         }
         if(m_window.NPC_Shooting)
         {
            this.m_animatedNPC = m_window.NPC_Shooting;
            this.m_animatedNPC.visible = true;
            this.m_animatedNPC.gotoAndPlay("START");
         }
         if(m_window.collection_mc)
         {
            this.m_treeCollection = m_window.collection_mc;
            if(m_window.collection_mc.hasOwnProperty("awesome_bt"))
            {
               this.m_awesome_bt = addWidget(new FarmAnimatedTextButton(m_window.collection_mc.awesome_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_awesome"),this.clickAwesome),true) as FarmAnimatedTextButton;
            }
            if(m_window.collection_mc.hasOwnProperty("subtitle1_tf"))
            {
               this.m_treecollection_subtitle_tf = addWidget(new ZwTextField(m_window.collection_mc.subtitle1_tf),true) as ZwTextField;
            }
            this.refreshTreeCollection();
            this.m_treeCollection.visible = false;
         }
         if(m_window.rainbowbutterfly_mc)
         {
            rainbowButterfly = addWidget(new ZwWidget(m_window.rainbowbutterfly_mc),true) as ZwWidget;
            feedLimitSeconds = Global.craftConfigSettings.getRecipeIngredientRequestFeedLimitSeconds();
            replacements = {};
            replacements["time"] = FarmGameUtil.toFriendlyTime(feedLimitSeconds,true);
            rainbowButterfly.attachTooltip(new FarmTextTooltip(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_askTooltip",replacements)));
         }
         if(m_window.askbutterfly_bt)
         {
            this.m_ask_bt = addWidget(new FarmAnimatedTextButton(m_window.askbutterfly_bt,"Ask",this.onAskClick),true) as FarmAnimatedTextButton;
         }
         var hoursRemaining:int = Math.ceil(MystreeReskinManagerWithEMH.getInstance(this.m_featureName).getTimeUntilPostFeedEnabled() / FarmGameUtil.NUM_SECS_IN_HOUR);
         if(hoursRemaining > 0)
         {
            this.disableAskButton();
         }
         if(!MystreeReskinManagerWithEMH.getInstance(this.m_featureName).isFeatureInActivePeriod())
         {
            this.m_overLay_mc = m_window.overlay_mc;
            if(this.m_overLay_mc)
            {
               this.m_overLay_mc.visible = true;
               if(this.m_overLay_mc.hasOwnProperty("title_tf"))
               {
                  this.m_overLay_mc["title_tf"].visible = false;
               }
               if(this.m_overLay_mc.hasOwnProperty("body_tf"))
               {
                  this.m_overLay_mc["body_tf"].text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_redeemBubbleText");
               }
            }
            footNote = "";
            this.m_whatIsThis_mc.visible = false;
         }
         if(m_window.hasOwnProperty("change_tf"))
         {
            addWidget(new ZwTextField(m_window.change_tf,footNote),true);
         }
         FarmStatsManager.count(this.m_featureName,"Main UI","view",MystreeReskinManagerWithEMH.getInstance(this.m_featureName).getDifficultyLevel().toString());
         this.startTimer();
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_MYSTREE_WATCH_TO_SKIP) <= 0)
         {
            if(m_window.hasOwnProperty("speed_bt"))
            {
               this.m_watch_add_to_speed_bt.visible = false;
            }
         }
      }
      
      private function getTutorialPopUpType() : String
      {
         var firstTimeSeenFlag:String = MystreeReskinManagerWithEMH.getInstance(this.m_featureName).getFtueFlag();
         var tutorialPopUpType:String = "repop";
         if(!Global.player.getSeenFlag(firstTimeSeenFlag))
         {
            tutorialPopUpType = "autopop";
         }
         return tutorialPopUpType;
      }
      
      public function setSpeedBtAmount(newAmount:int) : void
      {
         this.m_speedup_bt.setAmountText(newAmount.toString());
      }
      
      public function setnoOfAnimalAvailableToTend() : void
      {
         var windowName:String = MystreeReskinManagerWithEMH.getInstance(this.m_featureName).getWindowName();
         var newAmount:int = MystreeReskinManagerWithEMH.getInstance(this.m_featureName).noOfSaplingWaiting();
         m_window.subtitle2_tf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_subtitle2",{"noOfAnimal":newAmount});
      }
      
      private function howDoesThisWorkClick(e:Event = null) : void
      {
         var prefixUrl:String = MystreeReskinManagerWithEMH.getInstance(this.m_featureName).getWhatisthisPrefixURL();
         var buildingName:String = MystreeReskinManagerWithEMH.getInstance(this.m_featureName).getWindowName();
         FarmStatsManager.count(this.m_featureName,"FTUE_2","start",this.getTutorialPopUpType());
         TutorialUI.displayTutorialWindowForItem(buildingName,"Dialogs:" + buildingName + "_Tutorial_Title",prefixUrl,false,this.tutorialCloseCallback);
      }
      
      private function tutorialCloseCallback(e:Event = null) : void
      {
         FarmStatsManager.count(this.m_featureName,"FTUE_2","end",this.getTutorialPopUpType());
         var firstTimeSeenFlag:String = MystreeReskinManagerWithEMH.getInstance(this.m_featureName).getFtueFlag();
         if(!Global.player.getSeenFlag(firstTimeSeenFlag))
         {
            Global.player.setSeenFlag(firstTimeSeenFlag,true);
         }
      }
      
      private function openTreeWindow(e:Event = null) : void
      {
         if(m_window)
         {
            this.m_whatIsThis_mc.visible = false;
            m_closeButton.visible = false;
            if(this.m_treeCollection)
            {
               this.m_treeCollection.visible = true;
               this.refreshTreeCollection();
            }
            else if(MystreeReskinManagerWithEMH.getInstance(this.m_featureName).getCollectionDialogURL() != "")
            {
               UI.displayPopup(new MystreeReskinTreeColWindowWithEMH(this.m_featureName));
               close();
            }
            FarmStatsManager.count(this.m_featureName,"Collection Window","view",MystreeReskinManagerWithEMH.getInstance(this.m_featureName).getDifficultyLevel().toString());
         }
      }
      
      private function switchDifficultyLevel(e:Event = null) : void
      {
         var m_switchConfirmationWindow:MystreeReskinSwitchConfirmationWindow = new MystreeReskinSwitchConfirmationWindow("assets/dialogs/Adventurers2017/FV_Adventurers2017_confirm.swf",this.m_featureName,this.onAcceptSwitchdifficulty,this.getSwitchConfirmationBodyText(),ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"Accept"));
         UI.displayPopup(m_switchConfirmationWindow,false,"",true);
      }
      
      private function ReplayFeature(e:Event) : void
      {
         var m_switchConfirmationWindow:MystreeReskinSwitchConfirmationWindow = new MystreeReskinSwitchConfirmationWindow("assets/dialogs/Adventurers2017/FV_Adventurers2017_confirm.swf",this.m_featureName,this.onAcceptSwitchdifficulty,this.getSwitchConfirmationBodyText(),ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"Accept"));
         UI.displayPopup(m_switchConfirmationWindow,false,"",true);
         FarmStatsManager.count(this.m_featureName,"Difficulty Screen","View","level_complete_" + MystreeReskinManagerWithEMH.getInstance(this.m_featureName).getDifficultyLevel().toString());
      }
      
      private function getSwitchConfirmationBodyText() : String
      {
         var confirmationText:String = null;
         var windowName:String = MystreeReskinManagerWithEMH.getInstance(this.m_featureName).getWindowName();
         if(MystreeReskinManagerWithEMH.getInstance(this.m_featureName).hasProgressMade())
         {
            confirmationText = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_switch_ConfirmationText2");
         }
         else
         {
            confirmationText = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_switch_ConfirmationText1");
         }
         return confirmationText;
      }
      
      private function onAcceptSwitchdifficulty() : void
      {
         close();
         MystreeReskinDifficultyLevelsManager.getInstance(this.m_featureName).showDifficultyMainWindow();
         FarmStatsManager.count(this.m_featureName,"MainUI","Switch","from_difficulty_level_" + MystreeReskinManagerWithEMH.getInstance(this.m_featureName).getDifficultyLevel().toString());
         FarmStatsManager.count(this.m_featureName,"Difficulty Screen","View","switch_" + MystreeReskinManagerWithEMH.getInstance(this.m_featureName).getDifficultyLevel().toString());
      }
      
      private function refreshTreeCollection() : void
      {
         var i:int = 0;
         var count:int = 0;
         var ItemNameToolTip:ZwWidget = null;
         var mystreeItem:FarmItem = null;
         var isAllCollected:Boolean = true;
         var collectionData:Object = MystreeReskinManagerWithEMH.getInstance(this.m_featureName).getCollectionData();
         var mystrees:Array = MystreeReskinManagerWithEMH.getInstance(this.m_featureName).getMystreeData();
         var windowName:String = MystreeReskinManagerWithEMH.getInstance(this.m_featureName).getWindowName();
         var treeCount:int = 0;
         if(this.m_treeCollection)
         {
            for(i = 0; i < mystrees.length; i++)
            {
               count = int(collectionData[mystrees[i]]);
               if(count == 0)
               {
                  isAllCollected = false;
               }
               else
               {
                  treeCount++;
               }
               if(count > 999)
               {
                  (this.m_treeCollection[TREE_PREFIX + i] as TextField).text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_maxShowtreeCount");
               }
               else
               {
                  (this.m_treeCollection[TREE_PREFIX + i] as TextField).text = count.toString();
               }
               if(this.m_treeCollection[TOOLTIP_PRIFIX + i])
               {
                  ItemNameToolTip = new ZwWidget(this.m_treeCollection[TOOLTIP_PRIFIX + i]);
                  mystreeItem = Global.farmGameSettingsManager.getFarmItemByCode(mystrees[i]);
                  if(Boolean(ItemNameToolTip) && Boolean(mystreeItem))
                  {
                     ItemNameToolTip.attachTooltip(new FarmTextTooltip(ZLocUtils.tk_pk_asTitle(mystreeItem.friendlyName)));
                  }
               }
            }
            if(!isAllCollected)
            {
               this.m_treecollection_subtitle_tf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_subtitle1_incomplete",{"treeCount":treeCount});
            }
            else
            {
               this.m_treecollection_subtitle_tf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_subtitle1_complete");
            }
         }
      }
      
      private function onSpeedUp(e:Event = null) : void
      {
         var noOfSapling:int = MystreeReskinManagerWithEMH.getInstance(this.m_featureName).noOfSaplingWaiting();
         MystreeReskinManagerWithEMH.getInstance(this.m_featureName).speedUpSaplings(noOfSapling);
         this.m_plots.refresh();
         this.updateSpeedUpPossible();
         this.updateSpeedupViaAdsPossible();
      }
      
      private function watchAddToSpeedup(e:Event = null) : void
      {
         MystreeReskinManagerWithEMH.getInstance(this.m_featureName).speedUpSaplingsByWatchingAd(this.refreshSlotsOnCompleteingAd);
      }
      
      protected function updateSpeedUpPossible() : void
      {
         var enable:Boolean = false;
         var manager:IMystreeReskinManager = MystreeReskinManager.getInstance(this.m_featureName);
         if(manager.isAnySaplingWaiting())
         {
            enable = true;
         }
         this.m_speedup_bt.enabled = enable;
         this.m_watch_add_to_speed_bt.enabled = enable;
      }
      
      protected function updateSpeedupViaAdsPossible() : void
      {
         var enable:Boolean = false;
         var manager:IMystreeReskinManager = MystreeReskinManager.getInstance(this.m_featureName);
         if(manager.isAnySaplingWaiting() && manager.isAdBtnShouldbeAvailable())
         {
            enable = true;
         }
         this.m_speedup_bt.enabled = enable;
         this.m_watch_add_to_speed_bt.enabled = enable;
      }
      
      public function refreshSlotsOnCompleteingAd() : void
      {
         this.m_plots.refresh();
         this.updateSpeedUpPossible();
         this.updateSpeedupViaAdsPossible();
      }
      
      private function clickCraft(e:Event = null) : void
      {
         close();
         MystreeReskinManagerWithEMH.getInstance(this.m_featureName).showCraftingWindowWithItem();
      }
      
      private function clickBuyBtn(e:Event = null) : void
      {
         var m_sunshineBuyWindow:MystreeReskinBuyWindow = new MystreeReskinBuyWindow(MystreeReskinManager.getInstance(this.m_featureName).getByDialogURL(),this.m_featureName);
         UI.displayPopup(m_sunshineBuyWindow,true,"",true);
         close();
      }
      
      private function clickAwesome(e:Event = null) : void
      {
         this.m_treeCollection.visible = false;
         m_closeButton.visible = true;
         this.m_whatIsThis_mc.visible = true;
      }
      
      override protected function release() : void
      {
         this.m_tree_bt = null;
         this.m_craft_bt = null;
         this.m_speedup_bt = null;
         this.m_watch_add_to_speed_bt = null;
         this.m_awesome_bt = null;
         this.m_craft_mc = null;
         this.m_plots = null;
         this.m_treeCollection = null;
         this.m_sunshineCount_tf = null;
         this.m_animatedNPC = null;
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this.m_timer = null;
         }
         super.release();
      }
      
      public function updateSunshineBuckets() : void
      {
         if(this.m_sunshineCount_tf)
         {
            this.m_sunshineCount_tf.text = MystreeReskinManagerWithEMH.getInstance(this.m_featureName).getNumberOfBuckets();
         }
      }
      
      public function enableSpeedUp(enable:Boolean) : void
      {
         this.m_speedup_bt.enabled = enable;
      }
      
      public function enableWatchToSpeedup(enable:Boolean) : void
      {
         this.m_watch_add_to_speed_bt.enabled = enable;
      }
      
      public function onAskClick(e:Event = null) : void
      {
         this.m_ask_bt.enabled = false;
         if(MystreeReskinManagerWithEMH.getInstance(this.m_featureName).canPostFeed())
         {
            MystreeReskinManagerWithEMH.getInstance(this.m_featureName).postGeneralFeed(this.handleAskButtonCallback);
            if(this.m_ask_bt)
            {
               this.toggleButton(this.m_ask_bt,false);
            }
         }
      }
      
      private function toggleButton(button:FarmAnimatedButton, to:Boolean) : void
      {
         button.enabled = to;
         button.applyGrayOut = !to;
      }
      
      private function handleAskButtonCallback(shouldDisable:Boolean) : void
      {
         if(this.m_ask_bt)
         {
            if(shouldDisable)
            {
               this.disableAskButton();
            }
            else
            {
               this.toggleButton(this.m_ask_bt,true);
            }
         }
      }
      
      private function disableAskButton() : void
      {
         var hoursRemaining:int = 0;
         if(this.m_ask_bt)
         {
            this.m_ask_bt.enabled = true;
            this.m_ask_bt.setToggleMode(ZwToggleMode.SINGLE_SELECT);
            this.m_ask_bt.setToggleState(ZwToggleState.SELECTED);
            this.m_ask_bt.applyGrayOut = true;
            this.m_ask_bt.element.buttonMode = false;
            hoursRemaining = Math.ceil(MystreeReskinManagerWithEMH.getInstance(this.m_featureName).getTimeUntilPostFeedEnabled() / FarmGameUtil.NUM_SECS_IN_HOUR);
            this.m_ask_bt.attachTooltip(new FarmTextTooltip(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"Growable_ConsumableAskWithTimer",{"timeLeft":hoursRemaining})));
         }
      }
      
      public function animateNpc(npcAnimationCallback:Function) : void
      {
         this.m_npcAnimationCallback = npcAnimationCallback;
         if(Boolean(this.m_animatedNPC) && this.m_isNPCAnimComplete)
         {
            this.m_animatedNPC.gotoAndPlay("SHOOT");
            (this.m_animatedNPC as MovieClip).addEventListener(Event.ENTER_FRAME,this.onNPCAnimation);
            this.m_isNPCAnimComplete = false;
         }
         else if(this.m_animatedNPC)
         {
            if(this.m_npcAnimationCallback != null)
            {
               this.m_npcAnimationCallback();
            }
            this.m_animatedNPC.gotoAndPlay("START");
            (this.m_animatedNPC as MovieClip).removeEventListener(Event.ENTER_FRAME,this.onNPCAnimation);
            this.m_isNPCAnimComplete = true;
            this.m_plots.refresh();
         }
      }
      
      private function onNPCAnimation(event:Event) : void
      {
         if(Boolean(this.m_animatedNPC) && this.m_animatedNPC.currentFrame == this.m_animatedNPC.totalFrames)
         {
            (this.m_animatedNPC as MovieClip).removeEventListener(Event.ENTER_FRAME,this.onNPCAnimation);
            this.m_isNPCAnimComplete = true;
            if(this.m_npcAnimationCallback != null)
            {
               this.m_npcAnimationCallback();
            }
            this.m_plots.refresh();
         }
      }
      
      public function isNPCAnimationAvailable() : Boolean
      {
         return this.m_animatedNPC ? true : false;
      }
      
      private function startTimer() : void
      {
         if(this.m_timer == null)
         {
            this.m_timer = new Timer(TIMER_DELAY_MS);
            this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer);
            this.m_timer.start();
         }
      }
      
      private function stopTimer() : void
      {
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this.m_timer = null;
         }
      }
      
      private function onTimer(event:TimerEvent) : void
      {
         if(Boolean(m_window.time_tf) && this.m_endDate != "")
         {
            ZLocUtils.setText(m_window,"time_tf","Dialogs","GlitterAndIceCraftingBasket_ExpiryText",{"time":this.getExpiryDateText()});
         }
         if(!MystreeReskinManagerWithEMH.getInstance(this.m_featureName).isFeatureInActivePeriod())
         {
            m_window.time_tf.text += " for finishing your stage!";
         }
         if(m_window.time_tf)
         {
            m_window.time_tf.visible = true;
         }
      }
      
      public function getExpiryDateText() : String
      {
         var result:String = "";
         var timeRemaining:Number = (FarmGameUtil.synchronizedDateToNumber(this.m_endDate) - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         if(MystreeReskinManagerWithEMH.getInstance(this.m_featureName).isFeatureInActivePeriod())
         {
            timeRemaining -= MystreeReskinManagerWithEMH.REDEEM_ADDITIONAL_DAYS * FarmGameUtil.NUM_SECS_IN_DAY;
         }
         var numDays:int = timeRemaining / FarmGameUtil.NUM_SECS_IN_DAY;
         if(!isNaN(timeRemaining))
         {
            if(numDays > 1)
            {
               result = numDays.toString() + " days";
               this.stopTimer();
            }
            else
            {
               this.startTimer();
               result = HUD.getformattedTimeLeft(timeRemaining);
            }
         }
         return result;
      }
   }
}

