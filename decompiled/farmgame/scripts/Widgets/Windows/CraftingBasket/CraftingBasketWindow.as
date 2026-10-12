package Widgets.Windows.CraftingBasket
{
   import Classes.CraftingBasket;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.Crafting.CraftingManager;
   import Managers.CraftingBasketDifficultyLevelManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.CraftingBasketCollectionSlotFrame;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Slots.CraftingBasket.CraftingBasketCollectionSlot;
   import Widgets.Slots.CraftingBasket.CraftingBasketCraftSlot;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.CraftingBasketBuyWindow;
   import Widgets.Windows.FarmWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   public class CraftingBasketWindow extends FarmWindow
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 3;
      
      private static const FTUE_FLAG:String = "ftue";
      
      private static const OFFSET_OPF_Y:int = -40;
      
      private var m_featureName:String;
      
      private var m_featureParentName:String;
      
      private var m_basket:CraftingBasket;
      
      private var m_parentBasket:CraftingBasketDifficultyLevelManager = null;
      
      private var m_redeemItemChoice:String;
      
      private var m_subtitleTextField:ZwTextField;
      
      private var m_titleTextField:ZwTextField;
      
      private var m_whatisthisBtn:FarmAnimatedButton;
      
      private var m_tutorialButton:FarmAnimatedTextButton;
      
      private var m_ftue:MovieClip = null;
      
      private var m_tutorialScene:int;
      
      private var m_currencyFrame:ZwFrame;
      
      private var m_postFeedTextField:ZwTextField;
      
      private var m_currencyAskButton:FarmAnimatedTextButton;
      
      private var m_currencyBuyButton:FarmAnimatedCashButton;
      
      private var m_currencyItem:FarmItem;
      
      private var m_currencyCountTextField:ZwTextField;
      
      private var m_collectionSlots:Array;
      
      private var m_collectionFrame:CraftingBasketCollectionSlotFrame;
      
      private var m_craftFrame:ZwFrame;
      
      private var m_infoTooltip:FarmTextTooltip;
      
      private var m_prizeFrame:ZwFrame;
      
      private var m_timerFrame:ZwFrame;
      
      private var m_bonusIcon:ObjectPreviewFrame;
      
      private var m_bonusIconSilhouette:ZwFrame;
      
      private var m_prizeNameTextField:ZwTextField;
      
      private var m_redeemallTextField:ZwTextField;
      
      private var m_timerTextField:ZwTextField;
      
      private var m_bonusCheckmark:ZwWidget;
      
      private var m_changeButton:FarmAnimatedTextButton = null;
      
      private var m_replayButton:FarmAnimatedTextButton = null;
      
      private var m_switchButtonText:ZwTextField;
      
      private var m_footnote:ZwTextField = null;
      
      private var m_isDifficultySet:Boolean = false;
      
      private var m_change2TFInitialized:Boolean = false;
      
      public function CraftingBasketWindow(windowURL:String, featureName:String, featureParentName:String = null)
      {
         this.m_featureName = featureName;
         this.m_featureParentName = featureParentName;
         super(windowURL);
      }
      
      public function isDifficultyLevelSet() : Boolean
      {
         var data:Object = FeatureOptionsManager.getInstance().getFeatureOption(this.m_featureParentName,FeatureOptionsManager.DIFFICULTY_LEVEL);
         return data != null;
      }
      
      override protected function postLoadComplete() : void
      {
         var subtitileText:String = null;
         var titleText:String = null;
         var craftSlot:CraftingBasketCraftSlot = null;
         var collectionSlot:CraftingBasketCollectionSlot = null;
         super.postLoadComplete();
         this.m_isDifficultySet = this.isDifficultyLevelSet();
         if(this.m_isDifficultySet)
         {
            this.m_basket = new CraftingBasket(this.m_featureParentName,true,this);
            this.m_parentBasket = new CraftingBasketDifficultyLevelManager(this.m_featureParentName);
         }
         else
         {
            this.m_basket = new CraftingBasket(this.m_featureName);
         }
         this.m_basket.resetCurrencyItemCount();
         this.m_currencyItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_basket.currencyItemName);
         var prizeItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_basket.bonusItemName);
         var callbacks:Object = new Object();
         callbacks[CraftingBasket.BUY_ITEM] = this.onBuyItem;
         callbacks[CraftingBasket.REDEEM_ITEM] = this.onRedeemItem;
         callbacks[CraftingBasket.ASK_FOR_CURRENCY] = this.onAskForCurrencyItem;
         callbacks[CraftingBasket.CRAFT_CURRENCY] = this.onCraftCurrencyItem;
         callbacks[CraftingBasket.BUY_CURRENCY] = this.onBuyCurrencyItem;
         var currentTime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var featureendtime:Number = FarmGameUtil.synchronizedDateToNumber(this.m_basket.endDate) / FarmGameUtil.NUM_MSECS_IN_SECOND - CraftingBasket.REDEEM_ADDITIONAL_DAYS * FarmGameUtil.NUM_SECS_IN_DAY;
         var is_redeemperiod:Boolean = currentTime > featureendtime;
         if(Boolean(m_window.whatisthis_mc) && !is_redeemperiod)
         {
            addWidget(this.m_whatisthisBtn = new FarmAnimatedButton(m_window.whatisthis_mc,this.onWhatIsThisClick));
         }
         if(this.m_basket.isFeatureInActivePeriod())
         {
            subtitileText = ZLocUtils.t("Dialogs",this.m_featureParentName + "_subtitle");
         }
         else
         {
            subtitileText = ZLocUtils.t("Dialogs",this.m_featureParentName + "_subtitle_notActive");
         }
         titleText = ZLocUtils.t("Dialogs",this.m_featureParentName + "_title");
         addWidget(this.m_titleTextField = new ZwTextField(m_window.title_tf,titleText));
         addWidget(this.m_subtitleTextField = new ZwTextField(m_window.copy_tf,subtitileText));
         addWidget(this.m_currencyFrame = new ZwFrame(m_window.collect_mc));
         addWidget(this.m_currencyAskButton = new FarmAnimatedTextButton(m_window.collect_mc.ask_bt,ZLocUtils.t("Dialogs",this.m_featureParentName + "_askCurrency"),this.onAskForCurrencyItem)) as FarmAnimatedTextButton;
         this.toggleCurrencyAskButton();
         if(m_window.hasOwnProperty("collect_mc") && Boolean(m_window.collect_mc.hasOwnProperty("buy_bt")))
         {
            addWidget(this.m_currencyBuyButton = new FarmAnimatedCashButton(m_window.collect_mc.buy_bt,ZLocUtils.t("Dialogs",this.m_featureParentName + "_buyCurrency"),this.m_currencyItem.cash.toString(),this.onBuyCurrencyItem));
            this.setCurrencyButtonState();
         }
         addWidget(this.m_currencyCountTextField = new ZwTextField(m_window.collect_mc.count_tf,this.m_basket.currencyItemCount.toString()));
         addWidget(this.m_craftFrame = new ZwFrame(m_window.craft_mc)) as ZwFrame;
         var i:int = 0;
         while(i < this.m_basket.recipeIds.length && m_window["craft_mc"]["craftItem" + i + "_mc"] != null)
         {
            craftSlot = new CraftingBasketCraftSlot(m_window["craft_mc"]["craftItem" + i + "_mc"],this.m_featureParentName,this.m_basket.recipeIds[i],callbacks);
            this.m_craftFrame.addWidget(craftSlot);
            i++;
         }
         if(!this.m_basket.isFeatureInActivePeriod())
         {
            this.m_craftFrame.enabled = false;
            this.m_craftFrame.hideAllWidgets();
         }
         this.m_collectionSlots = new Array();
         addWidget(this.m_collectionFrame = new CraftingBasketCollectionSlotFrame(m_window.slots_mc,this.m_featureParentName,callbacks)) as CraftingBasketCollectionSlotFrame;
         this.refresh();
         if(!is_redeemperiod)
         {
            addWidget(this.m_prizeFrame = new ZwFrame(m_window.prize_mc));
            this.m_prizeFrame.addWidget(this.m_prizeNameTextField = new ZwTextField(m_window.prize_mc.name_tf,ZLocUtils.tk_pk_asTitle(prizeItem.friendlyName)));
            if(m_window.prize_mc.generic_tf)
            {
               this.m_prizeFrame.addWidget(this.m_redeemallTextField = new ZwTextField(m_window.prize_mc.generic_tf,"Redeem all " + this.m_basket.collectionItems.length + " items"));
            }
            this.m_prizeFrame.addWidget(this.m_bonusIcon = new ObjectPreviewFrame(m_window.prize_mc.icon_mc,prizeItem,null,[prizeItem.sizeX == 1 ? 2 : 1.75],null,"","",null,new Point(0,OFFSET_OPF_Y)));
            if(Boolean(m_window.prize_mc) && Boolean(m_window.prize_mc.checkmark_mc))
            {
               addWidget(this.m_bonusCheckmark = new ZwWidget(m_window.prize_mc.checkmark_mc),false);
            }
            if(Boolean(m_window.prize_mc) && Boolean(m_window.prize_mc.bonushidden_mc))
            {
               this.m_bonusIconSilhouette = new ZwFrame(m_window.prize_mc.bonushidden_mc);
               if(m_window.prize_mc.bonushidden_mc.icontint_mc)
               {
                  this.m_bonusIconSilhouette.addWidget(new ObjectPreviewFrame(m_window.prize_mc.bonushidden_mc.icontint_mc,prizeItem,null,[prizeItem.sizeX == 1 ? 2 : 1.75],null,"","",null,new Point(0,OFFSET_OPF_Y)));
               }
               this.m_prizeFrame.addWidget(this.m_bonusIconSilhouette,false);
            }
            if(this.m_basket.isBonusItemHidden())
            {
               this.setBonusItemVisible(false);
            }
         }
         addWidget(this.m_timerFrame = new ZwFrame(m_window.timer_mc));
         this.m_timerFrame.addWidget(this.m_timerTextField = new ZwTextField(m_window.timer_mc.time_tf,this.getExpiryDateText())) as ZwTextField;
         this.changeSwitchButtonState();
         var firstTimeSeenFlag:String = this.m_featureParentName + FTUE_FLAG;
         if(!Global.player.getSeenFlag(firstTimeSeenFlag))
         {
            this.setupFTUE();
            this.showFTUE();
         }
         this.refreshItems();
      }
      
      private function setCurrencyButtonState() : void
      {
         var item:FarmItem = this.m_currencyItem;
         this.m_currencyBuyButton.enabled = false;
         if(this.m_basket.isFeatureInActivePeriod())
         {
            this.m_currencyBuyButton.enabled = true;
         }
      }
      
      private function changeSwitchButtonState() : void
      {
         var infoTooltip:FarmTextTooltip = null;
         if(this.m_replayButton)
         {
            removeWidget(this.m_replayButton);
         }
         if(this.m_changeButton)
         {
            removeWidget(this.m_changeButton);
            this.m_changeButton = null;
         }
         if(this.m_switchButtonText)
         {
            removeWidget(this.m_switchButtonText);
         }
         if(this.m_footnote)
         {
            removeWidget(this.m_footnote);
         }
         if(this.m_basket.isFeatureInActivePeriod())
         {
            if(Boolean(m_window.change_bt) && Boolean(m_window.change_bt.text_tf) && Boolean(m_window.change_tf))
            {
               if(this.m_parentBasket.hasCollectedBonus() && this.m_parentBasket.isLevelCompleted)
               {
                  addWidget(this.m_replayButton = new FarmAnimatedTextButton(m_window.change_bt,ZLocUtils.t("Dialogs",this.m_featureParentName + "_continue_btn"),this.onReplay));
                  addWidget(this.m_switchButtonText = new ZwTextField(m_window.change_bt.text_tf,ZLocUtils.t("Dialogs",this.m_featureParentName + "_slot_replay_button_text")));
                  addWidget(this.m_footnote = new ZwTextField(m_window.change_tf,ZLocUtils.t("Dialogs",this.m_featureParentName + "_slot_replay_button_footnote")));
                  this.m_replayButton.applyGrayOut = false;
                  this.m_replayButton.enabled = true;
               }
               else if(this.m_parentBasket.hasCollectedBonus() && !this.m_parentBasket.isLevelCompleted)
               {
                  addWidget(this.m_replayButton = new FarmAnimatedTextButton(m_window.change_bt,ZLocUtils.t("Dialogs",this.m_featureParentName + "_continue_btn"),null));
                  addWidget(this.m_switchButtonText = new ZwTextField(m_window.change_bt.text_tf,ZLocUtils.t("Dialogs",this.m_featureParentName + "_slot_bonus_redeem_button_text")));
                  addWidget(this.m_footnote = new ZwTextField(m_window.change_tf,ZLocUtils.t("Dialogs",this.m_featureParentName + "_slot_bonus_redeem_button_footnote")));
                  this.m_replayButton.applyGrayOut = true;
                  this.m_replayButton.enabled = false;
               }
               else if(this.m_parentBasket.canChangeDifficultyLevel())
               {
                  addWidget(this.m_changeButton = new FarmAnimatedTextButton(m_window.change_bt,ZLocUtils.t("Dialogs",this.m_featureParentName + "_continue_btn"),this.onSwitchRequest));
                  addWidget(this.m_switchButtonText = new ZwTextField(m_window.change_bt.text_tf,ZLocUtils.t("Dialogs",this.m_featureParentName + "_slot_change_button_text")));
                  addWidget(this.m_footnote = new ZwTextField(m_window.change_tf,ZLocUtils.t("Dialogs",this.m_featureParentName + "_slot_switch_button_footnote")));
                  this.m_changeButton.detachTooltip();
               }
               else
               {
                  addWidget(this.m_changeButton = new FarmAnimatedTextButton(m_window.change_bt,ZLocUtils.t("Dialogs",this.m_featureParentName + "_continue_btn"),null));
                  addWidget(this.m_switchButtonText = new ZwTextField(m_window.change_bt.text_tf,ZLocUtils.t("Dialogs",this.m_featureParentName + "_slot_change_button_text")));
                  addWidget(this.m_footnote = new ZwTextField(m_window.change_tf,ZLocUtils.t("Dialogs",this.m_featureParentName + "_slot_inactive_button_footnote")));
                  this.m_changeButton.enabled = false;
                  this.m_changeButton.applyGrayOut = true;
                  infoTooltip = new FarmTextTooltip(ZLocUtils.t("Dialogs","SwitchButtonHoverText"));
                  this.m_changeButton.attachTooltip(infoTooltip);
                  this.m_changeButton.element.mouseEnabled = this.m_changeButton.element.mouseChildren = true;
               }
            }
         }
         else if(Boolean(m_window.change2_tf) && !this.m_change2TFInitialized)
         {
            addWidget(new ZwTextField(m_window.change2_tf,ZLocUtils.t("Dialogs","AdditionalDaysBottomText")));
            this.m_change2TFInitialized = true;
         }
      }
      
      private function refresh() : void
      {
         var i:int = 0;
         var slotItems:Array = [];
         if(this.m_collectionFrame)
         {
            for(i = 0; i < this.m_basket.collectionItems.length; i++)
            {
               slotItems.push({
                  "itemData":this.m_basket.collectionItems[i],
                  "checkMarkVisible":this.m_basket.shouldShowCheckMark(this.m_basket.collectionItems[i]),
                  "toggleRedeemVisible":this.m_basket.currencyItemCount >= this.m_basket.collectionItems[i].exchangeQty,
                  "canBuyItem":this.m_basket.shouldShowItemBuyButton(this.m_basket.collectionItems[i]),
                  "showCommonBg":this.m_basket.shouldShowCommonBg(this.m_basket.collectionItems[i])
               });
            }
            this.m_collectionFrame.items = slotItems;
         }
      }
      
      override protected function release() : void
      {
         this.m_subtitleTextField = null;
         this.m_whatisthisBtn = null;
         this.m_tutorialButton = null;
         this.m_ftue = null;
         this.m_currencyFrame = null;
         this.m_postFeedTextField = null;
         this.m_currencyAskButton = null;
         this.m_currencyBuyButton = null;
         this.m_currencyCountTextField = null;
         this.m_bonusIcon = null;
         this.m_prizeNameTextField = null;
         this.m_timerTextField = null;
         this.m_prizeFrame = null;
         this.m_collectionSlots = null;
         this.m_collectionFrame = null;
         this.m_craftFrame = null;
         this.m_changeButton = null;
         this.m_replayButton = null;
         this.m_switchButtonText = null;
         this.m_footnote = null;
         super.release();
      }
      
      private function setupFTUE() : void
      {
         this.m_ftue = m_window.tutorial_mc as MovieClip;
         if(this.m_ftue)
         {
            this.m_ftue.visible = false;
            if(this.m_tutorialButton == null && this.m_ftue.hasOwnProperty("okay_bt"))
            {
               addWidget(this.m_tutorialButton = new FarmAnimatedTextButton(this.m_ftue.okay_bt,ZLocUtils.t("Dialogs","Okay"),this.onFTUEOkBtnClick));
            }
            if(this.m_ftue.hasOwnProperty("ask_anim_mc"))
            {
               addWidget(new ZwTextField(this.m_ftue.ask_anim_mc.ask_bt.generic_tf,ZLocUtils.t("Dialogs",this.m_featureParentName + "_askCurrency")));
            }
         }
      }
      
      public function toggleCurrencyAskButton() : void
      {
         var timeElapsed:Number = NaN;
         var timeLeftForNextPost:Number = NaN;
         var shouldShow:Boolean = false;
         var message:String = null;
         this.m_currencyAskButton.text = "Ask";
         this.m_currencyAskButton.detachTooltip();
         if(this.m_basket.isFeatureInActivePeriod())
         {
            timeElapsed = FarmGameUtil.secondsElapsed(Global.player.getFeatureLastShown(this.m_basket.askFeedFeatureFrequencyKey));
            timeLeftForNextPost = this.m_basket.askFeedFrequency - timeElapsed;
            shouldShow = timeLeftForNextPost <= 0;
            this.m_currencyAskButton.enabled = shouldShow;
            if(m_window.collect_mc.postTime_tf)
            {
               addWidget(this.m_postFeedTextField = new ZwTextField(m_window.collect_mc.postTime_tf,ZLocUtils.t("Dialogs",this.m_featureParentName + "_postFeed")));
            }
            else if(!shouldShow)
            {
               message = FarmGameUtil.getTooltipTextForAskButton(timeLeftForNextPost);
               FarmGameUtil.disableButtonAndShowTooltip(this.m_currencyAskButton,message);
            }
         }
         else
         {
            this.m_currencyAskButton.enabled = false;
         }
      }
      
      private function showFTUE() : void
      {
         if(!this.m_ftue)
         {
            this.setupFTUE();
         }
         this.m_tutorialScene = 1;
         this.m_ftue.gotoAndStop(this.m_tutorialScene);
         this.m_tutorialButton.text = ZLocUtils.t("Dialogs","Okay");
         this.m_ftue.visible = true;
         FarmStatsManager.count(this.m_featureName,"FTUE","start");
      }
      
      private function onFTUEOkBtnClick(event:Event) : void
      {
         var firstTimeSeenFlag:String = null;
         if(this.m_tutorialScene++ < NUM_TUTORIAL_SCENES)
         {
            (this.m_ftue as MovieClip).play();
            if(this.m_tutorialScene == NUM_TUTORIAL_SCENES)
            {
               this.m_tutorialButton.text = ZLocUtils.t("Dialogs",this.m_featureParentName + "_tutorialDone");
            }
         }
         else
         {
            firstTimeSeenFlag = this.m_featureParentName + FTUE_FLAG;
            Global.player.setSeenFlag(firstTimeSeenFlag);
            this.m_ftue.visible = false;
            FarmStatsManager.count(this.m_featureName,"FTUE","end");
         }
      }
      
      private function onWhatIsThisClick(event:Event) : void
      {
         this.showFTUE();
      }
      
      private function setBonusItemVisible(visible:Boolean) : void
      {
         if(visible)
         {
            if(this.m_bonusIconSilhouette)
            {
               this.m_bonusIconSilhouette.visible = false;
            }
            this.m_bonusIcon.visible = true;
            this.m_prizeNameTextField.visible = true;
            this.m_bonusCheckmark.visible = true;
            this.m_redeemallTextField.visible = false;
         }
         else
         {
            this.m_bonusIcon.visible = false;
            this.m_bonusIconSilhouette.visible = true;
            this.m_prizeNameTextField.visible = false;
            addWidget(new ZwTextField(m_window.prize_mc.generic_tf,ZLocUtils.t("Dialogs",this.m_featureParentName + "_bonusText")));
         }
      }
      
      protected function refreshItems() : void
      {
         this.m_currencyCountTextField.text = ZLocUtils.t("Dialogs",this.m_featureParentName + "_currencyCount",{
            "quantity":this.m_basket.currencyItemCount,
            "item":ZLocUtils.tk_pk(this.m_currencyItem.friendlyName,"",this.m_basket.currencyItemCount)
         });
         this.refresh();
         var currentTime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var featureendtime:Number = FarmGameUtil.synchronizedDateToNumber(this.m_basket.endDate) / FarmGameUtil.NUM_MSECS_IN_SECOND - CraftingBasket.REDEEM_ADDITIONAL_DAYS * FarmGameUtil.NUM_SECS_IN_DAY;
         var is_redeemperiod:Boolean = currentTime > featureendtime;
         if((this.m_basket.hasCollectedAllRewards() || this.m_parentBasket.hasCollectedBonus()) && !is_redeemperiod)
         {
            this.setBonusItemVisible(true);
            if(this.m_parentBasket)
            {
               this.changeSwitchButtonState();
            }
         }
      }
      
      override public function refreshWindow() : void
      {
         this.refreshItems();
      }
      
      public function enableWindow(enable:Boolean) : void
      {
         var enableItemsOnlyInActivePeriod:Boolean = enable && this.m_basket.isFeatureInActivePeriod();
         if(enable)
         {
            this.refreshItems();
         }
         if(m_closeButton)
         {
            m_closeButton.visible = enable;
         }
         else if(m_window.hasOwnProperty("close_bt"))
         {
            m_window.close_bt.visible = enable;
         }
         this.m_collectionFrame.enabled = enable;
         this.m_craftFrame.enabled = enableItemsOnlyInActivePeriod;
         if(this.m_currencyBuyButton)
         {
            this.m_currencyBuyButton.enabled = enableItemsOnlyInActivePeriod;
         }
         if(this.m_changeButton)
         {
            this.m_changeButton.enabled = enableItemsOnlyInActivePeriod;
         }
         if(this.m_replayButton)
         {
            this.m_replayButton.enabled = enableItemsOnlyInActivePeriod;
         }
         if(enable)
         {
            untintWindow();
         }
         else
         {
            tintWindow();
         }
      }
      
      private function getExpiryDateText() : String
      {
         return FarmGameUtil.getFeatureExpiryDateText(this.m_basket.endDate,"Generic_ExpiryText",CraftingBasket.REDEEM_ADDITIONAL_DAYS);
      }
      
      private function onAskForCurrencyItem(event:Event) : void
      {
         if(this.m_currencyAskButton.enabled)
         {
            this.enableWindow(false);
            this.m_basket.askForCurrencyItem();
         }
      }
      
      private function onBuyCurrencyItem(event:Event) : void
      {
         var x:CraftingBasketBuyWindow = new CraftingBasketBuyWindow(this.m_basket.buyDialog,this.m_featureParentName,this.m_basket.bucketPackages);
         UI.displayPopup(x,true,"",true);
         close();
      }
      
      private function onBuyItem(itemName:String) : void
      {
         var buyResult:Boolean = false;
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         if(Global.player.canBuyCash(item.cash))
         {
            buyResult = Global.player.tryBuy(null,false,item,0);
            if(buyResult)
            {
               this.enableWindow(false);
               this.m_basket.buyCollectionItem(itemName);
            }
         }
      }
      
      private function onRedeemItem(itemName:String) : void
      {
         this.m_redeemItemChoice = itemName;
         var chosenItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         var confirmationText:String = ZLocUtils.t("Dialogs",this.m_featureParentName + "RedeemDialog",{
            "numTickets":this.m_basket.getRedeemPriceForItem(itemName),
            "chosenItem":ZLocUtils.tk_pk(chosenItem.friendlyName)
         });
         var friendlyItemName:String = Global.farmGameSettingsManager.getFarmItemByName(itemName).friendlyTitle;
         confirmationText = "Are you sure you want to redeem " + friendlyItemName + "?";
         UI.displayMessage(confirmationText,GenericPopup.TYPE_ACCEPTCANCEL,this.onAcceptRedeemConfirmation,"",true,true);
      }
      
      private function onAcceptRedeemConfirmation(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            this.enableWindow(false);
            this.m_basket.redeemCollectionItem(this.m_redeemItemChoice);
         }
      }
      
      private function onCraftCurrencyItem(recipeId:String) : void
      {
         this.m_basket.resetCurrencyItemCount();
         var craftShopName:String = CraftingManager.getCraftShopNameForCurrentWorld(Global.worldManager.currentWorldType);
         CraftingManager.getInstance().openCraftingUiForRecipe(recipeId,craftShopName);
         super.close();
      }
      
      private function onSwitchRequest(e:MouseEvent) : void
      {
         var confirmationText:String = null;
         this.m_changeButton.enabled = false;
         confirmationText = ZLocUtils.t("Dialogs",this.m_featureParentName + "_level_change_confirmation_text");
         UI.displayCustomMessage(confirmationText,GenericPopup.TYPE_ACCEPTCANCEL,this.onAcceptSwitchReqConfirmation,"",true,true,"","switchOK","switchCancel","");
      }
      
      private function onReplay(e:MouseEvent) : void
      {
         this.Replay();
      }
      
      private function onAcceptSwitchReqConfirmation(event:GenericPopupEvent) : void
      {
         this.m_changeButton.enabled = true;
         if(event.button == GenericPopup.ACCEPT || event.button == GenericPopup.TYPE_CUSTOM_ACCEPTANCE)
         {
            this.enableWindow(false);
            close();
            this.m_parentBasket.updateSwitchCountAndLastLevel();
         }
      }
      
      private function Replay() : void
      {
         this.enableWindow(false);
         close();
         this.m_parentBasket.updateSwitchCountAndLastLevel(true);
      }
   }
}

