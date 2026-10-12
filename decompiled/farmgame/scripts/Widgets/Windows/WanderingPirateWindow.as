package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.HUD.HUD;
   import Managers.SameFeatureFriendsManager;
   import Managers.WanderingPirateManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Constants.ZwToggleMode;
   import Widgets.Core.Constants.ZwToggleState;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.WanderingPirateCraftSlotContainerFrame;
   import Widgets.Frames.WanderingPirateKeyBoxSlotContainerFrame;
   import Widgets.Frames.WanderingPirateRewardItemsFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Slots.WanderingPirateKeyBoxSlot;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class WanderingPirateWindow extends FarmWindowWithTutorial
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 4;
      
      public static const ZLOC_PACKAGE_DIALOGS:String = ZLocConstants.DIALOG_UTIL_PKG;
      
      private var m_featureName:String = WanderingPirateManager.FEATURE_NAME;
      
      public var m_keyBoxSlotFrame:WanderingPirateKeyBoxSlotContainerFrame;
      
      public var m_rewardItemsFrame:WanderingPirateRewardItemsFrame;
      
      private var m_npc:ZwWidget;
      
      public var m_craftFrame:WanderingPirateCraftSlotContainerFrame;
      
      private var m_featureManager:WanderingPirateManager = WanderingPirateManager.getInstance(WanderingPirateManager.FEATURE_NAME);
      
      private var m_endDate:String = this.m_featureManager.FEATURE_END_DATE;
      
      private var m_timerFrame:ZwFrame;
      
      private var m_descriptionTextField:ZwTextField;
      
      private var m_timerTextField:ZwTextField;
      
      private var m_currencyFrame:ZwFrame;
      
      private var m_currencyCountTextField:ZwTextField;
      
      private var m_currencyItemIcon:FarmIcon;
      
      private var m_currencyBuyButton:FarmAnimatedCashButton;
      
      private var m_currencyAskButton:FarmAnimatedTextButton;
      
      private var m_currencyItemCount:int;
      
      private var m_currencyItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(WanderingPirateManager.getInstance(WanderingPirateManager.FEATURE_NAME).CURRENCY_ITEM_NAME);
      
      private var m_timer:Timer;
      
      private var m_titleTextField:FarmTextField;
      
      private var m_animationMc:ZwWidget;
      
      private var m_OrbScrren_mc:MovieClip = new MovieClip();
      
      private var m_OrbScrren0_mc:MovieClip = new MovieClip();
      
      private var m_OrbScrren1_mc:MovieClip = new MovieClip();
      
      private var m_OrbScrren2_mc:MovieClip = new MovieClip();
      
      private var m_OrbScrren3_mc:MovieClip = new MovieClip();
      
      private var m_OrbScrren4_mc:MovieClip = new MovieClip();
      
      private var m_CurrentOrbScrren_mc:MovieClip = new MovieClip();
      
      private var m_FinalRewardGrant_mc:MovieClip = new MovieClip();
      
      private var m_FinalReward_mc:MovieClip = new MovieClip();
      
      private var m_orbTitleTextField:FarmTextField;
      
      private var m_orbBodyTextField:FarmTextField;
      
      private var m_orbHeaderTextField:FarmTextField;
      
      private var m_subheaderTextField:FarmTextField;
      
      private var m_descriptionTextField1:ZwTextField;
      
      private var m_craftTitleTextField:FarmTextField;
      
      private var m_craftTitleTf:ZwTextField;
      
      private var m_craftslot1Tf:ZwTextField;
      
      private var m_craftslot2Tf:ZwTextField;
      
      private var m_craftslot3Tf:ZwTextField;
      
      private var m_consumableTitleTf:ZwTextField;
      
      public var m_completeMc:ZwWidget;
      
      private var m_bonusMc:ZwWidget;
      
      public function WanderingPirateWindow(assetUrl:String = "assets/dialogs/WP_LostCities2018/FV_WPLostCities2018_MainUI.swf", parameters:XML = null)
      {
         super(this.m_featureName,assetUrl,NUM_TUTORIAL_SCENES);
         if(!Global.player.getSeenFlag(this.m_featureName + "_Start_Reward"))
         {
            this.m_currencyItemCount = int(this.m_featureManager.startRewardGrant());
         }
         var currentTimeSec:int = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         Global.player.setFeatureLastShown(WanderingPirateManager.WP_WINDOW_LAST_SHOWN,currentTimeSec,true);
      }
      
      override protected function postLoadComplete() : void
      {
         var mapsFinished:Number = NaN;
         var currentOrbScrren:String = null;
         var bonusRewardTooltip:FarmTextTooltip = null;
         if(m_window.hasOwnProperty("npc_mc"))
         {
            this.m_npc = addWidget(new ZwWidget(m_window.npc_mc),true) as ZwWidget;
         }
         super.postLoadComplete();
         if(m_window.addFriends_bt)
         {
            addWidget(new FarmAnimatedTextButton(m_window.addFriends_bt,"Add Friends",this.openNeighborSuggestionWindow));
         }
         if(m_window.hasOwnProperty("itemsPlaceHolder_mc"))
         {
            this.m_rewardItemsFrame = new WanderingPirateRewardItemsFrame(m_window.itemsPlaceHolder_mc,this);
            if(this.m_rewardItemsFrame)
            {
               addWidget(this.m_rewardItemsFrame,false);
            }
         }
         if(m_window.hasOwnProperty("des_txt"))
         {
            this.m_descriptionTextField = new ZwTextField(m_window.des_txt,ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,this.m_featureName + "_windowDescriptionText"));
            if(this.m_featureManager.hasUserFinished())
            {
               if(this.m_descriptionTextField)
               {
                  this.m_descriptionTextField.text = ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,this.m_featureName + "_finishedDescription");
               }
            }
            addWidget(this.m_descriptionTextField);
            this.m_descriptionTextField.selectable = false;
         }
         if(m_window.hasOwnProperty("des2_txt"))
         {
            this.m_descriptionTextField1 = new ZwTextField(m_window.des2_txt,ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,this.m_featureName + "_windowDescriptionText2"));
            addWidget(this.m_descriptionTextField1);
            this.m_descriptionTextField1.selectable = false;
         }
         if(m_window.hasOwnProperty("title_tf"))
         {
            this.m_titleTextField = new FarmTextField(m_window.title_tf,ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,this.m_featureName + "_title"),true);
            if(this.m_titleTextField)
            {
               addWidget(this.m_titleTextField);
            }
            this.m_titleTextField.selectable = false;
         }
         if(m_window.hasOwnProperty("consumable_tf"))
         {
            this.m_consumableTitleTf = addWidget(new ZwTextField(m_window["consumable_tf"],"Old Map Pieces")) as ZwTextField;
            this.m_consumableTitleTf.visible = true;
         }
         if(m_window.hasOwnProperty("keyBox_mc"))
         {
            this.m_keyBoxSlotFrame = new WanderingPirateKeyBoxSlotContainerFrame(m_window.keyBox_mc,this);
            if(this.m_keyBoxSlotFrame)
            {
               addWidget(this.m_keyBoxSlotFrame);
               this.refresh();
               (this.m_keyBoxSlotFrame.slots[0] as WanderingPirateKeyBoxSlot).onViewButtonClicked();
            }
         }
         if(m_window.hasOwnProperty("whatisthis_bt"))
         {
            addWidget(new ZwButton(m_window.whatisthis_bt,this.onHowDoesThisWorkClick));
         }
         if(m_window.hasOwnProperty("orb_bt"))
         {
            addWidget(new ZwButton(m_window.orb_bt,this.onClickOrbButton));
         }
         if(m_window.hasOwnProperty("orbScreen_mc"))
         {
            this.m_OrbScrren_mc = m_window.orbScreen_mc;
            this.m_OrbScrren_mc.visible = false;
            mapsFinished = WanderingPirateManager.getInstance().getMapsFinished();
            if(mapsFinished > WanderingPirateManager.NUM_OF_CASES)
            {
               mapsFinished = WanderingPirateManager.NUM_OF_CASES;
            }
            currentOrbScrren = "orb_" + mapsFinished.toString() + "_mc";
            if(this.m_OrbScrren_mc)
            {
               this.m_CurrentOrbScrren_mc = this.m_OrbScrren_mc[currentOrbScrren];
               this.m_CurrentOrbScrren_mc.visible = false;
               this.hideAllOrbScrrens();
               this.m_FinalRewardGrant_mc = this.m_OrbScrren_mc.finalRewardGrant_mc;
               this.m_FinalRewardGrant_mc.visible = false;
               this.m_FinalReward_mc = this.m_OrbScrren_mc.finalReward_mc;
               this.m_FinalReward_mc.visible = true;
               if(this.m_OrbScrren_mc.hasOwnProperty("rewardBody_tf"))
               {
                  this.m_orbBodyTextField = new FarmTextField(this.m_OrbScrren_mc.rewardBody_tf,"You have won a <RewardName>!",true);
                  if(this.m_orbBodyTextField)
                  {
                     addWidget(this.m_orbBodyTextField);
                  }
               }
               if(this.m_OrbScrren_mc.hasOwnProperty("subheader_tf"))
               {
                  this.m_orbHeaderTextField = new FarmTextField(this.m_OrbScrren_mc.subheader_tf,"Cap’n Zelda has got more treasure up for grabs, so keep going to win it all!",true);
                  if(this.m_orbHeaderTextField)
                  {
                     addWidget(this.m_orbHeaderTextField);
                  }
               }
               if(this.m_OrbScrren_mc.hasOwnProperty("rewardtitle_tf"))
               {
                  this.m_orbTitleTextField = new FarmTextField(this.m_OrbScrren_mc.rewardtitle_tf,"Awesome!",true);
                  if(this.m_orbTitleTextField)
                  {
                     addWidget(this.m_orbTitleTextField);
                  }
               }
               if(this.m_OrbScrren_mc.hasOwnProperty("orbClose_bt"))
               {
                  addWidget(new ZwButton(this.m_OrbScrren_mc.orbClose_bt,this.CloseOrbScreen));
               }
            }
         }
         if(m_window.hasOwnProperty("craftingPlaceHolder_mc"))
         {
            this.m_craftFrame = new WanderingPirateCraftSlotContainerFrame(m_window.craftingPlaceHolder_mc,this);
            if(m_window["craftingPlaceHolder_mc"].hasOwnProperty("craftTitle_tf"))
            {
               this.m_craftTitleTf = addWidget(new ZwTextField(m_window["craftingPlaceHolder_mc"]["craftTitle_tf"],"Craft Old Map Pieces")) as ZwTextField;
            }
            if(this.m_craftFrame)
            {
               addWidget(this.m_craftFrame,false);
               this.refreshCraftSlot();
            }
         }
         if(m_window.hasOwnProperty("craft_bt"))
         {
            addWidget(new FarmAnimatedTextButton(m_window.craft_bt,ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,this.m_featureName + "_craftToolTip"),this.onCraftClick));
         }
         if(m_window.hasOwnProperty("ask_bt"))
         {
            addWidget(this.m_currencyAskButton = new FarmAnimatedTextButton(m_window.ask_bt,ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,"GenericAsk"),this.onAskForCurrencyItem));
         }
         if(m_window.hasOwnProperty("buy_bt"))
         {
            if(this.m_currencyItem)
            {
               addWidget(this.m_currencyBuyButton = new FarmAnimatedCashButton(m_window.buy_bt,"",this.m_currencyItem.cash.toString(),this.onBuyCurrencyItem,true));
               addWidget(new ZwTextField(m_window.buy_bt.genericNum_tf,this.m_currencyItem.cash.toString()));
               addWidget(new ZwTextField(m_window.buy_bt.generic_tf,ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,this.m_featureName + "_buyCurrency")));
               this.setCurrencyButtonState();
            }
         }
         if(m_window.hasOwnProperty("bonus_mc"))
         {
            this.m_bonusMc = addWidget(new ZwWidget(m_window.bonus_mc),true) as ZwWidget;
            bonusRewardTooltip = new FarmTextTooltip("Old Time Machine");
            this.m_bonusMc.attachTooltip(bonusRewardTooltip);
            m_window.bonus_mc.visible = true;
         }
         if(m_window.hasOwnProperty("completeIcon_mc"))
         {
            this.m_completeMc = addWidget(new ZwWidget(m_window.completeIcon_mc),true) as ZwWidget;
            this.m_completeMc.visible = false;
         }
         if(m_window.hasOwnProperty("keyLoader_mc"))
         {
            addWidget(this.m_currencyFrame = new ZwFrame(m_window.keyLoader_mc));
            if(this.m_featureManager)
            {
               this.m_currencyItemCount = this.m_featureManager.getCurrencyCount();
            }
            if(this.m_currencyFrame)
            {
               this.m_currencyFrame.addWidget(this.m_currencyCountTextField = new ZwTextField(m_window.keyLoader_mc.loader_txt,"x" + this.m_currencyItemCount.toString()));
               if(Boolean(m_window.keyLoader_mc.icon_mc) && Boolean(this.m_currencyItem))
               {
                  this.m_currencyFrame.addWidget(this.m_currencyItemIcon = new FarmIcon(m_window.keyLoader_mc.icon_mc,this.m_currencyItem.iconUrl));
                  this.m_currencyItemIcon.setIconSize(100,100);
               }
            }
         }
         var currentMapStage:int = this.m_featureManager.getMapStageForUser() >= WanderingPirateManager.NUM_OF_CASES ? WanderingPirateManager.NUM_OF_CASES : this.m_featureManager.getMapStageForUser();
         var currentMapStageString:String = "stage" + currentMapStage + "_mc";
         if(m_window.hasOwnProperty(currentMapStageString))
         {
            addWidget(new ZwWidget(m_window[currentMapStageString]),true);
         }
         if(m_window.hasOwnProperty("npc_anim_mc"))
         {
            this.m_animationMc = addWidget(new ZwWidget(m_window.npc_anim_mc),true) as ZwWidget;
            if(this.m_animationMc)
            {
               if(Boolean(this.m_featureManager) && this.m_featureManager.hasUserFinished())
               {
                  this.m_animationMc.element.gotoAndPlay(239);
               }
               else
               {
                  this.m_animationMc.element.play();
               }
            }
         }
         if(m_window.hasOwnProperty("timeLoader_mc"))
         {
            addWidget(this.m_timerFrame = new ZwFrame(m_window.timeLoader_mc));
            if(this.m_timerFrame)
            {
               this.m_timerFrame.addWidget(this.m_timerTextField = new ZwTextField(m_window.timeLoader_mc.loader_txt,this.getExpiryDateText())) as ZwTextField;
            }
            this.m_timerTextField.selectable = false;
         }
         var shouldShow:Boolean = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - Global.player.getFeatureLastShown(this.m_featureManager.ASK_FEED_FREQUENCY_KEY) >= this.m_featureManager.ASK_FEED_FREQUENCY;
         if(this.m_currencyAskButton)
         {
            if(shouldShow)
            {
               this.toggleButton(this.m_currencyAskButton,true);
            }
            else
            {
               this.disableAskButton();
            }
         }
         this.showFTUE();
      }
      
      private function disableAskButton() : void
      {
         var infoTooltip:FarmTextTooltip = null;
         if(this.m_currencyAskButton)
         {
            this.m_currencyAskButton.enabled = true;
            this.m_currencyAskButton.setToggleMode(ZwToggleMode.SINGLE_SELECT);
            this.m_currencyAskButton.setToggleState(ZwToggleState.SELECTED);
            this.m_currencyAskButton.applyGrayOut = true;
            this.m_currencyAskButton.element.buttonMode = false;
            infoTooltip = new FarmTextTooltip(ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,this.m_featureName + "_askToolTip"));
            this.m_currencyAskButton.attachTooltip(infoTooltip);
         }
      }
      
      private function toggleButton(button:FarmAnimatedButton, to:Boolean) : void
      {
         button.enabled = to;
         button.applyGrayOut = !to;
      }
      
      private function refresh() : void
      {
         var slotItems:Array = new Array();
         var i:int = 0;
         while(i < WanderingPirateManager.NUM_OF_CASES)
         {
            slotItems.push({
               "keyBoxNumber":i,
               "rewardItems":WanderingPirateManager.getInstance(this.m_featureName).getRewardItemsForKey(i),
               "numItemsWon":WanderingPirateManager.getInstance(this.m_featureName).getLength(i),
               "grantedAll":WanderingPirateManager.getInstance(this.m_featureName).hasUserFinished()
            });
            i++;
         }
         if(Boolean(this.m_keyBoxSlotFrame) && Boolean(this.m_keyBoxSlotFrame))
         {
            this.m_keyBoxSlotFrame.items = slotItems;
         }
      }
      
      private function refreshCraftSlot() : void
      {
         var craftingRecipes:Array = new Array();
         var i:int = 0;
         while(i < WanderingPirateManager.NUM_OF_CRAFT_SLOTS)
         {
            craftingRecipes.push({
               "craftSlotNumber":i,
               "craftingRecipe":WanderingPirateManager.getInstance(this.m_featureName).getCraftingRecipeForKey(i)
            });
            i++;
         }
         this.m_craftFrame.items = craftingRecipes;
      }
      
      override protected function showTutorial() : void
      {
         if(this.m_npc)
         {
            this.m_npc.visible = false;
         }
         super.showTutorial();
      }
      
      private function onHowDoesThisWorkClick(event:Event) : void
      {
         this.showTutorial();
      }
      
      private function openNeighborSuggestionWindow(event:Event) : void
      {
         SameFeatureFriendsManager.instance.showMainUI();
      }
      
      public function showFTUE() : void
      {
         var firstTimeSeenFlag:String = this.m_featureName + "ftue";
         if(!Global.player.getSeenFlag(firstTimeSeenFlag))
         {
            this.showTutorial();
            Global.player.setSeenFlag(firstTimeSeenFlag);
         }
      }
      
      private function CloseOrbScreen(event:Event) : void
      {
         this.m_OrbScrren_mc.visible = false;
      }
      
      private function onClickOrbButton(event:Event) : void
      {
         this.showOrbit();
      }
      
      public function showOrbit(showAnimation:Boolean = false) : void
      {
         this.m_OrbScrren_mc.visible = true;
         var mapsFinished:Number = WanderingPirateManager.getInstance().getMapsFinished();
         if(mapsFinished > WanderingPirateManager.NUM_OF_CASES)
         {
            mapsFinished = WanderingPirateManager.NUM_OF_CASES;
         }
         var currentOrbScrren:String = "orb_" + mapsFinished.toString() + "_mc";
         this.m_CurrentOrbScrren_mc = this.m_OrbScrren_mc[currentOrbScrren];
         this.m_CurrentOrbScrren_mc.visible = true;
         if(showAnimation)
         {
            this.m_CurrentOrbScrren_mc.gotoAndPlay(1);
         }
         this.m_orbBodyTextField.text = ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,WanderingPirateManager.FEATURE_NAME + "_orbScreen_text" + mapsFinished.toString());
         this.m_orbTitleTextField.text = ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,WanderingPirateManager.FEATURE_NAME + "_orbScreen_title" + mapsFinished.toString());
         switch(mapsFinished)
         {
            case 0:
               this.m_orbHeaderTextField.visible = false;
               break;
            case 1:
            case 2:
            case 3:
               this.m_orbHeaderTextField.visible = true;
               break;
            case 4:
            default:
               this.m_FinalRewardGrant_mc.visible = true;
               this.m_FinalReward_mc.visible = false;
               this.m_orbHeaderTextField.visible = false;
         }
      }
      
      private function onBuyCurrencyItem(event:Event) : void
      {
         var item:FarmItem = this.m_currencyItem;
         if(Global.player.canBuyCash(item.cash,false))
         {
            this.m_featureManager.buyCurrencyItem(item.cash);
         }
         else
         {
            this.m_currencyBuyButton.enabled = false;
         }
         this.refreshWindow();
      }
      
      private function setCurrencyButtonState() : void
      {
         var item:FarmItem = this.m_currencyItem;
         this.m_currencyBuyButton.enabled = false;
         if(Global.player.canBuyCash(item.cash,false))
         {
            this.m_currencyBuyButton.enabled = true;
         }
      }
      
      private function onCraftClick(event:Event) : void
      {
         this.toggleRewardAndCraftFrame(false);
      }
      
      public function toggleRewardAndCraftFrame(visible:Boolean) : void
      {
         this.m_rewardItemsFrame.visible = visible;
         this.m_craftFrame.visible = !visible;
      }
      
      override public function refreshWindow() : void
      {
         this.m_currencyItemCount = this.m_featureManager.getCurrencyCount();
         if(this.m_currencyCountTextField)
         {
            this.m_currencyCountTextField.text = "x" + this.m_currencyItemCount.toString();
         }
         if(this.m_rewardItemsFrame)
         {
            this.m_rewardItemsFrame.resetUnlockButton();
         }
         this.refresh();
         if(this.m_currencyBuyButton)
         {
            this.m_currencyBuyButton.enabled = Global.player.canBuyCash(this.m_currencyItem.cash,false);
         }
         var currentMapStage:int = this.m_featureManager.getMapStageForUser() >= WanderingPirateManager.NUM_OF_CASES ? WanderingPirateManager.NUM_OF_CASES : this.m_featureManager.getMapStageForUser();
         var currentMapStageString:String = "stage" + currentMapStage + "_mc";
         if(Boolean(m_window) && Boolean(m_window.hasOwnProperty(currentMapStageString)) && !getWidget(m_window[currentMapStageString]))
         {
            addWidget(new ZwWidget(m_window[currentMapStageString]),true);
         }
         if(this.m_animationMc)
         {
            if(Boolean(this.m_featureManager) && this.m_featureManager.hasUserFinished())
            {
               this.m_animationMc.element.gotoAndPlay(239);
            }
            else
            {
               this.m_animationMc.element.play();
            }
         }
         if(this.m_featureManager.hasUserFinished())
         {
            if(this.m_descriptionTextField)
            {
               this.m_descriptionTextField.text = ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,this.m_featureName + "_finishedDescription");
            }
         }
         super.refreshWindow();
      }
      
      private function onAskForCurrencyItem(event:Event) : void
      {
         if(this.m_currencyAskButton)
         {
            this.disableAskButton();
         }
         if(this.m_featureManager)
         {
            this.m_featureManager.askForCurrencyItem();
         }
      }
      
      private function getExpiryDateText() : String
      {
         var result:String = "";
         var timeRemaining:Number = (FarmGameUtil.synchronizedDateToNumber(this.m_endDate) - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var numDays:int = Math.ceil(timeRemaining / FarmGameUtil.NUM_SECS_IN_DAY);
         if(numDays > 1)
         {
            result = ZLocUtils.t("Dialogs","Harvest_Helper_Hud_text",{"days":numDays});
         }
         else
         {
            if(this.m_timer == null)
            {
               this.m_timer = new Timer(1000);
               this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer);
               this.m_timer.start();
            }
            result = HUD.getformattedTimeLeft(timeRemaining);
         }
         return result;
      }
      
      private function onTimer(event:TimerEvent) : void
      {
         if(this.m_timerTextField)
         {
            this.m_timerTextField.text = this.getExpiryDateText();
         }
      }
      
      override protected function hideTutorial() : void
      {
         super.hideTutorial();
         if(this.m_npc)
         {
            this.m_npc.visible = true;
         }
      }
      
      override public function close() : void
      {
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer = null;
         }
         super.close();
      }
      
      override protected function release() : void
      {
         this.m_npc = null;
         this.m_keyBoxSlotFrame = null;
         this.m_rewardItemsFrame = null;
         this.m_featureName = null;
         this.m_descriptionTextField = null;
         this.m_craftFrame = null;
         this.m_timerFrame = null;
         this.m_currencyFrame = null;
         this.m_currencyAskButton = null;
         this.m_currencyBuyButton = null;
         this.m_currencyCountTextField = null;
         super.release();
      }
      
      public function refreshCurrencyCount() : void
      {
         var count:int = WanderingPirateManager.getInstance().getCurrencyCount();
         if(this.m_currencyCountTextField)
         {
            this.m_currencyCountTextField.text = count.toString();
         }
      }
      
      private function hideAllOrbScrrens() : void
      {
         this.m_OrbScrren0_mc = this.m_OrbScrren_mc["orb_0_mc"];
         this.m_OrbScrren0_mc.visible = false;
         this.m_OrbScrren1_mc = this.m_OrbScrren_mc["orb_1_mc"];
         this.m_OrbScrren1_mc.visible = false;
         this.m_OrbScrren2_mc = this.m_OrbScrren_mc["orb_2_mc"];
         this.m_OrbScrren2_mc.visible = false;
         this.m_OrbScrren3_mc = this.m_OrbScrren_mc["orb_3_mc"];
         this.m_OrbScrren3_mc.visible = false;
         this.m_OrbScrren4_mc = this.m_OrbScrren_mc["orb_4_mc"];
         this.m_OrbScrren4_mc.visible = false;
      }
      
      public function get currencyItem() : FarmItem
      {
         return this.m_currencyItem;
      }
   }
}

