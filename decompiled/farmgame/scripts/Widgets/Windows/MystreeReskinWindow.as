package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.HUD.HUD;
   import Display.TutorialUI;
   import Display.UI;
   import Managers.FarmStatsManager;
   import Managers.MystreeReskinManager;
   import Managers.MystreeReskinManagerWithoutEMH;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Constants.ZwToggleMode;
   import Widgets.Core.Constants.ZwToggleState;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.MystreeReskinFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.text.TextField;
   import flash.utils.Timer;
   
   public class MystreeReskinWindow extends FarmWindow implements IMystreeReskinWindow
   {
      
      private static const TREE_PREFIX:String = "treecount_";
      
      private static const TOOLTIP_PRIFIX:String = "tooltip_";
      
      private static const TIMER_DELAY_MS:int = 1000;
      
      public static const REDEEM_ADDITIONAL_DAYS:int = 2;
      
      private static const REWARD_FTUE_FLAG:String = "firstTimeSeenFlag";
      
      private static const FEATURE_TRACKING:String = "GPF_spookyrampshow";
      
      private var m_featureName:String = null;
      
      private var m_tree_bt:FarmAnimatedTextButton;
      
      private var m_speedup_bt:FarmAnimatedCashButton;
      
      private var m_craft_bt:FarmAnimatedTextButton;
      
      private var m_awesome_bt:FarmAnimatedTextButton;
      
      private var m_craft_mc:MovieClip;
      
      private var m_plots:MystreeReskinFrame;
      
      private var m_treeCollection:MovieClip;
      
      private var m_building_mc:MovieClip;
      
      private var m_sunshineCount_tf:ZwTextField;
      
      private var m_treecollection_subtitle_tf:ZwTextField;
      
      private var m_ask_bt:FarmAnimatedTextButton;
      
      private var m_whatIsThis_mc:FarmAnimatedButton;
      
      private var m_animatedNPC:MovieClip;
      
      private var m_npcAnimationCallback:Function = null;
      
      private var m_isNPCAnimComplete:Boolean = true;
      
      private var m_endDate:String;
      
      private var m_timer:Timer;
      
      private var m_buy_bt:FarmAnimatedTextButton;
      
      private var HAS_REDEEM_PERIOD:Boolean = true;
      
      private var m_overLay_mc:MovieClip;
      
      private var m_timeLeft_tf:ZwTextField;
      
      protected var m_ftue:MovieClip = null;
      
      protected var m_tutorialScene:int;
      
      protected var m_tutorialButton:FarmAnimatedTextButton;
      
      private const NUM_OF_SCENES:int = 1;
      
      private var m_ftueOn:Boolean = false;
      
      private var m_bodyText:ZwTextField;
      
      public function MystreeReskinWindow(featureName:String = null)
      {
         this.m_featureName = featureName;
         var dialogPath:String = MystreeReskinManagerWithoutEMH.getInstance(featureName).getMainDialogAssetURL();
         if(dialogPath != "")
         {
            super(dialogPath);
         }
         var ftueFlag:String = MystreeReskinManagerWithoutEMH.getInstance(this.m_featureName).getFtueFlag();
         var ftueChristmasPatchFlag:String = MystreeReskinManagerWithoutEMH.getInstance(this.m_featureName).getFtueChristmasFlag();
         if(!Global.player.getSeenFlag(ftueFlag))
         {
            MystreeReskinManagerWithoutEMH.getInstance(this.m_featureName).initFeature();
            this.howDoesThisWorkClick(null);
            Global.player.setSeenFlag(ftueFlag,true);
         }
         else if(!Global.player.getSeenFlag(ftueChristmasPatchFlag))
         {
            MystreeReskinManagerWithoutEMH.getInstance(this.m_featureName).setDataForAdditionalRewards();
            Global.player.setSeenFlag(ftueChristmasPatchFlag,true);
         }
         this.m_endDate = MystreeReskinManagerWithoutEMH.getInstance(this.m_featureName).getEndDate();
      }
      
      override protected function postLoadComplete() : void
      {
         var m_buildingMCtooltip:FarmIcon = null;
         var buildingName:String = null;
         var buildingItem:FarmItem = null;
         var rainbowButterfly:ZwWidget = null;
         var feedLimitSeconds:Number = NaN;
         var replacements:Object = null;
         super.postLoadComplete();
         var windowName:String = MystreeReskinManagerWithoutEMH.getInstance(this.m_featureName).getWindowName();
         var firstTimeSeenFlag:String = windowName + REWARD_FTUE_FLAG;
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_title")),true);
         }
         if(m_window.hasOwnProperty("subtitle_tf"))
         {
            addWidget(this.m_bodyText = new ZwTextField(m_window.subtitle_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_subtitle")),true);
         }
         if(m_window.hasOwnProperty("subtitle2_tf"))
         {
            addWidget(new ZwTextField(m_window.subtitle2_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_subtitle2")),true);
         }
         if(m_window.hasOwnProperty("craft_mc"))
         {
            this.m_craft_mc = m_window.craft_mc;
            if(m_window.craft_mc.hasOwnProperty("bucketcount_tf"))
            {
               addWidget(this.m_sunshineCount_tf = new ZwTextField(m_window.craft_mc.bucketcount_tf,""),true);
               this.m_sunshineCount_tf.text = MystreeReskinManagerWithoutEMH.getInstance(this.m_featureName).getNumberOfBuckets();
            }
            if(m_window.craft_mc.hasOwnProperty("craftbucket_bt"))
            {
               this.m_craft_bt = addWidget(new FarmAnimatedTextButton(m_window.craft_mc.craftbucket_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_craftbucket"),this.clickCraft),true) as FarmAnimatedTextButton;
            }
            this.m_craft_mc.visible = true;
         }
         if(m_window.hasOwnProperty("time_tf") && this.m_endDate != "")
         {
            this.m_timeLeft_tf = new ZwTextField(m_window.time_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"GlitterAndIceCraftingBasket_ExpiryText",{"time":this.getExpiryDateText(this.HAS_REDEEM_PERIOD)}));
            this.m_timeLeft_tf.visible = true;
         }
         if(m_window.hasOwnProperty("view_bt"))
         {
            addWidget(this.m_tree_bt = new FarmAnimatedTextButton(m_window.view_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_buildingName"),this.openTreeWindow),true);
         }
         if(m_window.hasOwnProperty("speed_bt"))
         {
            this.m_speedup_bt = addWidget(new FarmAnimatedCashButton(m_window.speed_bt,"Finish Now!",MystreeReskinManagerWithoutEMH.getInstance(this.m_featureName).getSpeedUpCost().toString(),this.onSpeedUp),true) as FarmAnimatedCashButton;
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
         if(m_window.hasOwnProperty("buy_bt"))
         {
            this.m_buy_bt = addWidget(new FarmAnimatedTextButton(m_window.buy_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_BuyButtonText"),this.clickBuyBtn),true) as FarmAnimatedTextButton;
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
         if(m_window.hasOwnProperty("building_mc"))
         {
            this.m_building_mc = m_window.building_mc;
            this.m_building_mc.visible = true;
            m_buildingMCtooltip = new FarmIcon(this.m_building_mc);
            buildingName = MystreeReskinManagerWithoutEMH.getInstance(this.m_featureName).getBuildingName();
            buildingItem = Global.farmGameSettingsManager.getFarmItemByName(buildingName);
            if(buildingItem)
            {
               m_buildingMCtooltip.attachTooltip(new FarmTextTooltip(buildingItem.friendlyTitle));
            }
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
         var hoursRemaining:int = Math.ceil(MystreeReskinManagerWithoutEMH.getInstance(this.m_featureName).getTimeUntilPostFeedEnabled() / FarmGameUtil.NUM_SECS_IN_HOUR);
         if(hoursRemaining > 0)
         {
            this.disableAskButton();
         }
         FarmStatsManager.count(this.m_featureName,"Main UI","view");
         this.startTimer();
         if(m_window.time_tf)
         {
            m_window.time_tf.visible = true;
         }
         if(!Global.player.getSeenFlag(firstTimeSeenFlag))
         {
            this.showFTUE();
            if(this.m_bodyText)
            {
               this.m_bodyText.text = "Prep the Craft Tables with Costume Kits and watch them transform into exuberant rewards.";
            }
         }
      }
      
      protected function showFTUE() : void
      {
         if(!this.m_ftue)
         {
            this.setupFTUE();
         }
         if(this.m_ftue)
         {
            this.m_tutorialScene = 1;
            this.m_ftue.gotoAndStop(this.m_tutorialScene);
            this.m_tutorialButton.text = "Okay";
            this.m_ftue.visible = true;
            this.m_ftueOn = true;
         }
      }
      
      protected function setupFTUE() : void
      {
         var windowName:String = MystreeReskinManagerWithoutEMH.getInstance(this.m_featureName).getWindowName();
         this.m_tutorialScene = 1;
         if(Boolean(m_window) && Boolean(m_window.overlay_mc))
         {
            this.m_ftue = m_window.overlay_mc as MovieClip;
            if(this.m_ftue)
            {
               if(this.m_ftue.hasOwnProperty("title_tf"))
               {
                  this.m_ftue["title_tf"].text = "My Collections";
               }
               if(this.m_ftue.hasOwnProperty("body_tf"))
               {
                  this.m_ftue["body_tf"].text = "Find all your rewards and bonus animals in \'My Collection\'";
               }
               if(this.m_tutorialButton == null && this.m_ftue.hasOwnProperty("okay_bt"))
               {
                  addWidget(this.m_tutorialButton = new FarmAnimatedTextButton(this.m_ftue.okay_bt,"Okay",this.onFTUEOKBtnClick));
               }
            }
         }
      }
      
      protected function onFTUEOKBtnClick(e:Event) : void
      {
         var windowName:String = null;
         var firstTimeSeenFlag:String = null;
         if(this.m_tutorialScene++ < this.NUM_OF_SCENES)
         {
            (this.m_ftue as MovieClip).play();
         }
         else
         {
            windowName = MystreeReskinManagerWithoutEMH.getInstance(this.m_featureName).getWindowName();
            firstTimeSeenFlag = windowName + REWARD_FTUE_FLAG;
            Global.player.setSeenFlag(firstTimeSeenFlag);
            this.m_ftue.visible = false;
            this.m_ftueOn = false;
         }
         if(this.m_bodyText)
         {
            this.m_bodyText.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_subtitle");
         }
      }
      
      private function clickBuyBtn(e:Event = null) : void
      {
         var m_sunshineBuyWindow:MystreeReskinBuyWindow = new MystreeReskinBuyWindow(MystreeReskinManager.getInstance(this.m_featureName).getByDialogURL(),this.m_featureName);
         UI.displayPopup(m_sunshineBuyWindow,true,"",true);
         close();
      }
      
      private function howDoesThisWorkClick(e:Event = null) : void
      {
         var prefixUrl:String = MystreeReskinManagerWithoutEMH.getInstance(this.m_featureName).getWhatisthisPrefixURL();
         var ftueFlag:String = MystreeReskinManagerWithoutEMH.getInstance(this.m_featureName).getFtueFlag();
         var callback:Function = null;
         if(!Global.player.getSeenFlag(ftueFlag))
         {
            callback = this.openTreeWindow;
         }
         var buildingName:String = MystreeReskinManagerWithoutEMH.getInstance(this.m_featureName).getWindowName();
         TutorialUI.displayTutorialWindowForItem(buildingName,"Dialogs:" + buildingName + "_Tutorial_Title",prefixUrl,false,callback);
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
            else if(MystreeReskinManagerWithoutEMH.getInstance(this.m_featureName).getCollectionDialogURL() != "")
            {
               UI.displayPopup(new MystreeReskinTreeColWindow(this.m_featureName));
               close();
            }
            FarmStatsManager.count(this.m_featureName,"Collection","view");
         }
      }
      
      private function refreshTreeCollection() : void
      {
         var i:int = 0;
         var count:int = 0;
         var ItemNameToolTip:ZwWidget = null;
         var mystreeItem:FarmItem = null;
         var isAllCollected:Boolean = true;
         var collectionData:Object = MystreeReskinManagerWithoutEMH.getInstance(this.m_featureName).getCollectionData();
         var mystrees:Array = MystreeReskinManagerWithoutEMH.getInstance(this.m_featureName).getMystreeData();
         var windowName:String = MystreeReskinManagerWithoutEMH.getInstance(this.m_featureName).getWindowName();
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
         MystreeReskinManagerWithoutEMH.getInstance(this.m_featureName).speedUpSaplings();
         this.m_plots.refresh();
      }
      
      public function setSpeedBtAmount(newAmount:int) : void
      {
         this.m_speedup_bt.setAmountText(newAmount.toString());
      }
      
      private function clickCraft(e:Event = null) : void
      {
         close();
         FarmStatsManager.count(FEATURE_TRACKING,"PerformTask","Craft","Click");
         MystreeReskinManagerWithoutEMH.getInstance(this.m_featureName).showCraftingWindowWithItem();
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
            this.m_sunshineCount_tf.text = MystreeReskinManagerWithoutEMH.getInstance(this.m_featureName).getNumberOfBuckets();
         }
      }
      
      public function enableSpeedUp(enable:Boolean) : void
      {
         this.m_speedup_bt.enabled = enable;
      }
      
      public function onAskClick(e:Event = null) : void
      {
         this.m_ask_bt.enabled = false;
         FarmStatsManager.count(FEATURE_TRACKING,"PerformTask","Ask","Click");
         if(MystreeReskinManagerWithoutEMH.getInstance(this.m_featureName).canPostFeed())
         {
            MystreeReskinManagerWithoutEMH.getInstance(this.m_featureName).postGeneralFeed(this.handleAskButtonCallback);
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
            hoursRemaining = Math.ceil(MystreeReskinManagerWithoutEMH.getInstance(this.m_featureName).getTimeUntilPostFeedEnabled() / FarmGameUtil.NUM_SECS_IN_HOUR);
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
            if(this.m_featureName == "mystree_v10")
            {
               this.m_timeLeft_tf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"GlitterAndIceCraftingBasket_ExpiryText",{"time":this.getExpiryDateText(this.HAS_REDEEM_PERIOD)});
            }
            else
            {
               this.m_timeLeft_tf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"GlitterAndIceCraftingBasket_ExpiryText",{"time":this.getExpiryDateText(this.HAS_REDEEM_PERIOD)});
            }
         }
      }
      
      private function getExpiryDateText(hasRedeemPeriod:Boolean = false) : String
      {
         var result:String = "";
         var timeRemaining:Number = 0;
         if(hasRedeemPeriod)
         {
            timeRemaining = (FarmGameUtil.synchronizedDateToNumber(this.m_endDate) - REDEEM_ADDITIONAL_DAYS * FarmGameUtil.NUM_MSECS_IN_DAY - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         }
         else
         {
            timeRemaining = (FarmGameUtil.synchronizedDateToNumber(this.m_endDate) - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         }
         var numDays:int = Math.ceil(timeRemaining / FarmGameUtil.NUM_SECS_IN_DAY);
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
      
      public function enableWatchToSpeedup(value:Boolean) : void
      {
      }
   }
}

