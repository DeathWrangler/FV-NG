package Widgets.Windows.Pigo
{
   import Classes.Constants.Experiments;
   import Classes.Pigo.PigoEngine;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Pigo.PigoControlFrame;
   import Widgets.Frames.Pigo.PigoLastPrizeFrame;
   import Widgets.Frames.Pigo.PigoTokenDropWidget;
   import Widgets.Icons.FarmIcon;
   import Widgets.Slots.Pigo.PigoPrizeSlot;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class PigoWindow extends FarmWindow
   {
      
      public static const TOKEN_CONSUMABLE_ITEM_NAME:String = "consume_pigo_game_token";
      
      public static const TOKEN_PACKAGE_COUNT:int = 3;
      
      public static const TOKEN_PACKAGE_DISCOUNT:Number = 0.1;
      
      private static const MORE_INFO_POP_SEEN_FLAG:String = "pigoMoreInfoPop";
      
      private static const FREE_PLAY_MIN_LEVEL_SETTING:String = "pigoFreePlayMinLevel";
      
      private static const DEFAULT_FREE_PLAY_MIN_LEVEL:int = 6;
      
      private static const FREE_PLAY_COUNTER:String = "SECURE_pigoFreePlayCount";
      
      private static const PREREQ_CARNIVAL_DISABLE_NON_PAYER_FRICTIONLESS:String = "pigo_1clickpurchase_disable_non_payer";
      
      private static const ICON_SIZE:int = 100;
      
      private static const NUM_PRIZE_SLOTS:int = 6;
      
      private var m_loadingFrame:ZwFrame;
      
      private var m_loadingText:ZwWidget;
      
      private var m_titleWidget:ZwWidget;
      
      private var m_controlFrame:PigoControlFrame;
      
      private var m_tokenDropWidget:PigoTokenDropWidget;
      
      private var m_lastPrizeFrame:PigoLastPrizeFrame;
      
      private var m_bonusPrizeArrow:ZwWidget;
      
      private var m_bonusPrizeName:ZwTextField;
      
      private var m_bonusPrizeIcon:FarmIcon;
      
      private var m_bulbsAnimation:ZwWidget;
      
      private var m_bonusPrizeText:ZwTextField;
      
      private var m_prizeAnimations:Array;
      
      private var m_prizeSlots:Array;
      
      private var m_engine:PigoEngine;
      
      private var m_gameItem:FarmItem;
      
      private var m_hasEarnedSetBonus:Boolean;
      
      private var m_setBonusItemName:String;
      
      private var m_tokenPrice:int;
      
      private var m_tokenPackageCount:int;
      
      private var m_tokenPackagePrice:int;
      
      private var m_userInitiated:Boolean = false;
      
      private var m_source:String = null;
      
      public function PigoWindow(gameItem:FarmItem, source:String, userInitiated:Boolean)
      {
         super("assets/dialogs/FV_Pigo2.swf");
         this.m_gameItem = gameItem;
         this.m_userInitiated = userInitiated;
         this.m_source = source;
      }
      
      public static function displayActiveGame(source:String, userInitiated:Boolean) : PigoWindow
      {
         var window:PigoWindow = null;
         var activeGameItem:FarmItem = Global.farmGameSettingsManager.getActivePigoGameItem();
         if(activeGameItem)
         {
            window = new PigoWindow(activeGameItem,source,userInitiated);
            if(userInitiated)
            {
               displayAlreadyCreatedWindow(source,window);
            }
         }
         else
         {
            UI.displayMessage(ZLocUtils.t("Dialogs","PigoWindow_NoActiveGamesMessage"),GenericPopup.TYPE_OK,null,"PigoDisabled",true);
         }
         return window;
      }
      
      public static function displayAlreadyCreatedWindow(source:String, window:PigoWindow) : void
      {
         UI.displayPopup(window,true,"Pigo",true);
         FarmStatsManager.count("fv_pigo","open",window.m_source);
      }
      
      override protected function postLoadComplete() : void
      {
         var isMysteryPrizesEnabled:Boolean = false;
         this.getGameSettings();
         var backgroundWidget:ZwWidget = addWidget(new ZwWidget(m_window.back_mc)) as ZwWidget;
         this.m_loadingFrame = addWidget(new ZwFrame(m_window.loader_mc)) as ZwFrame;
         this.m_loadingText = this.m_loadingFrame.addWidget(new ZwWidget(m_window.loader_mc.loading_mc)) as ZwWidget;
         (this.m_loadingText.element as MovieClip).gotoAndPlay(1);
         this.m_titleWidget = addWidget(new ZwWidget(m_window.logo_mc)) as ZwWidget;
         this.stopTitleAnimation();
         this.initTokenPricing();
         addWidget(new FarmAnimatedButton(m_window.moreInfo_bt,this.onMoreInfoButtonClick));
         var numTokensOwned:int = Global.player.getGiftCountForItem(TOKEN_CONSUMABLE_ITEM_NAME);
         this.m_controlFrame = addWidget(new PigoControlFrame(m_window.hud_mc,this.m_tokenPrice,numTokensOwned,this.checkForFreePlay(),this.m_tokenPackageCount,this.m_tokenPackagePrice)) as PigoControlFrame;
         this.m_controlFrame.setCallbacks(this.onPlayButtonClick,this.onBuyTokenButtonClick,this.onBuyTokenPackageButtonClick);
         this.m_bonusPrizeText = addWidget(new ZwTextField(m_window.subHead_txt," ")) as ZwTextField;
         this.m_bonusPrizeArrow = addWidget(new ZwWidget(m_window.arrow_mc)) as ZwWidget;
         this.m_bonusPrizeName = addWidget(new ZwTextField(m_window.prizename_txt," ")) as ZwTextField;
         this.m_bonusPrizeIcon = addWidget(new FarmIcon(m_window.prize_mc)) as FarmIcon;
         this.m_bonusPrizeIcon.setIconSize(ICON_SIZE,ICON_SIZE);
         this.m_bulbsAnimation = addWidget(new ZwWidget(m_window.bulbs_mc)) as ZwWidget;
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_PIGO_MYSTERY_PRIZES) == 2)
         {
            isMysteryPrizesEnabled = true;
         }
         else
         {
            isMysteryPrizesEnabled = false;
         }
         this.m_prizeAnimations = new Array(NUM_PRIZE_SLOTS);
         this.m_prizeSlots = new Array(NUM_PRIZE_SLOTS);
         for(var i:int = 0; i < NUM_PRIZE_SLOTS; i++)
         {
            this.m_prizeAnimations[i] = addWidget(new ZwWidget(m_window["animation" + i + "_mc"] as DisplayObject)) as ZwWidget;
            this.m_prizeSlots[i] = addWidget(new PigoPrizeSlot(m_window["panel_" + i] as DisplayObject,isMysteryPrizesEnabled)) as PigoPrizeSlot;
         }
         this.m_lastPrizeFrame = addWidget(new PigoLastPrizeFrame(m_window.youWin_mc)) as PigoLastPrizeFrame;
         this.m_engine = new PigoEngine(this.onEngineDropComplete);
         this.m_engine.mask = m_window.mask_mc as MovieClip;
         this.m_engine.x = 257;
         this.m_engine.y = 91;
         var engineZIndex:int = m_window.getChildIndex(m_window.back_mc) + 1;
         m_window.addChildAt(this.m_engine,engineZIndex);
         var engineBounds:Rectangle = this.m_engine.getBounds(m_window);
         this.m_tokenDropWidget = addWidget(new PigoTokenDropWidget(m_window.pig_mc,engineBounds.left + 40,engineBounds.right - 40)) as PigoTokenDropWidget;
      }
      
      override protected function release() : void
      {
         this.m_gameItem = null;
         this.m_bonusPrizeArrow = null;
         this.m_bonusPrizeIcon = null;
         this.m_bonusPrizeName = null;
         this.m_bonusPrizeText = null;
         this.m_bulbsAnimation = null;
         this.m_controlFrame = null;
         this.m_engine.release();
         this.m_engine = null;
         this.m_lastPrizeFrame = null;
         this.m_loadingFrame = null;
         this.m_loadingText = null;
         this.m_prizeAnimations = null;
         this.m_prizeSlots = null;
         this.m_titleWidget = null;
         this.m_tokenDropWidget.stop();
         this.m_tokenDropWidget = null;
         super.release();
      }
      
      override protected function onClose(event:Event) : void
      {
         if(m_closeButton.enabled)
         {
            super.onClose(event);
            FarmStatsManager.count("fv_pigo","x_cancel");
         }
      }
      
      private function initTokenPricing() : void
      {
         var tokenPackageFullPrice:Number = NaN;
         var tokenPackageDiscount:Number = NaN;
         if(this.m_gameItem)
         {
            this.m_tokenPrice = this.m_gameItem.cash;
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_PIGO_TOKEN_PACKAGE) == 2)
            {
               this.m_tokenPackageCount = TOKEN_PACKAGE_COUNT;
               tokenPackageFullPrice = this.m_tokenPrice * this.m_tokenPackageCount;
               tokenPackageDiscount = Math.ceil(tokenPackageFullPrice * TOKEN_PACKAGE_DISCOUNT);
               this.m_tokenPackagePrice = tokenPackageFullPrice - tokenPackageDiscount;
            }
         }
      }
      
      private function displayFreePlayDialog() : void
      {
         enableInput = false;
         UI.displayMessage(ZLocUtils.t("Dialogs","PigoWindow_FreePlayMessage"),GenericPopup.TYPE_OK,this.onFreePlayDialogClose,"PigoFreePlay",true);
      }
      
      private function onFreePlayDialogClose(event:Event) : void
      {
         enableInput = true;
      }
      
      private function onMoreInfoButtonClick(event:MouseEvent) : void
      {
         this.displayMoreInfoDialog();
      }
      
      private function displayMoreInfoDialog() : void
      {
         enableInput = false;
         UI.displayMessage(ZLocUtils.t("Dialogs","PigoWindow_MoreInfoMessage",{"amount":this.m_tokenPrice}),GenericPopup.TYPE_OK,this.onMoreInfoDialogClose,"PigoMoreInfo",true);
      }
      
      private function onMoreInfoDialogClose(event:Event) : void
      {
         enableInput = true;
      }
      
      private function onBuyTokenButtonClick() : void
      {
         if(PrerequisiteUtility.checkPrereqByName(PREREQ_CARNIVAL_DISABLE_NON_PAYER_FRICTIONLESS))
         {
            this.pause();
            UI.displayMessage(ZLocUtils.t("Dialogs","PigoWindow_BuyToken_Confirm",{"cost":this.m_tokenPrice}),GenericPopup.TYPE_YESNO,this.onBuyTokenDialogClose,"PigoBuyToken",true);
         }
         else
         {
            this.buyToken();
         }
      }
      
      private function onBuyTokenDialogClose(genericPopupEvent:GenericPopupEvent) : void
      {
         this.unpause();
         if(genericPopupEvent.button > 0)
         {
            this.buyToken();
         }
      }
      
      private function onBuyTokenPackageButtonClick() : void
      {
         if(PrerequisiteUtility.checkPrereqByName(PREREQ_CARNIVAL_DISABLE_NON_PAYER_FRICTIONLESS))
         {
            this.pause();
            UI.displayMessage(ZLocUtils.t("Dialogs","PigoWindow_BuyTokenPackage_Confirm",{
               "cost":this.m_tokenPackagePrice,
               "count":this.m_tokenPackageCount
            }),GenericPopup.TYPE_YESNO,this.onBuyTokenPackageDialogClose,"PigoBuyTokenPackage",true);
         }
         else
         {
            this.buyTokenPackage();
         }
      }
      
      private function onBuyTokenPackageDialogClose(genericPopupEvent:GenericPopupEvent) : void
      {
         this.unpause();
         if(genericPopupEvent.button > 0)
         {
            this.buyTokenPackage();
         }
      }
      
      private function attemptBuyAndUseToken() : Boolean
      {
         var bCanPlay:Boolean = this.buyToken();
         if(bCanPlay)
         {
            --this.m_controlFrame.tokenCount;
         }
         return bCanPlay;
      }
      
      private function onPlayButtonClick() : void
      {
         var canPlay:Boolean = false;
         if(this.m_controlFrame.hasFreePlay)
         {
            canPlay = true;
            this.m_controlFrame.hasFreePlay = false;
            Global.player.setActionCount(FREE_PLAY_COUNTER,0);
         }
         else if(this.m_controlFrame.tokenCount > 0)
         {
            canPlay = true;
            --this.m_controlFrame.tokenCount;
         }
         else if(PrerequisiteUtility.checkPrereqByName(PREREQ_CARNIVAL_DISABLE_NON_PAYER_FRICTIONLESS))
         {
            this.pause();
            UI.displayMessage(ZLocUtils.t("Dialogs","PigoWindow_BuyAndUseToken_Confirm",{"cost":this.m_tokenPrice}),GenericPopup.TYPE_YESNO,this.onBuyTokenAndPlayDialogClose,"PigoBuyAndUseToken",true);
         }
         else
         {
            canPlay = this.attemptBuyAndUseToken();
         }
         if(canPlay)
         {
            this.dropToken();
         }
      }
      
      private function onBuyTokenAndPlayDialogClose(genericPopupEvent:GenericPopupEvent) : void
      {
         this.unpause();
         if(genericPopupEvent.button > 0 && this.attemptBuyAndUseToken())
         {
            this.dropToken();
         }
      }
      
      private function dropToken() : void
      {
         var pigCoords:Point = new Point(this.m_tokenDropWidget.x,this.m_tokenDropWidget.y);
         var tokenCoords:Point = this.m_engine.globalToLocal(m_window.localToGlobal(pigCoords));
         this.m_engine.dropToken(tokenCoords);
         this.m_controlFrame.tokensInPlay += 1;
         Global.player.removeGiftWithKey(Global.farmGameSettingsManager.getFarmItemCodeByName(TOKEN_CONSUMABLE_ITEM_NAME));
         m_closeButton.enabled = false;
      }
      
      public function pause() : void
      {
         if(m_window)
         {
            tintWindow();
            enableInput = false;
         }
      }
      
      public function unpause() : void
      {
         if(m_window)
         {
            untintWindow();
            enableInput = true;
         }
      }
      
      private function onEngineDropComplete(slotIndex:int) : void
      {
         this.grantReward(slotIndex);
      }
      
      private function getGameSettings() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction("PigoService","getGameSettings",this.getGameSettingsTransactionCallback,[this.m_gameItem.name]),true);
      }
      
      private function getGameSettingsTransactionCallback(result:Object) : void
      {
         var loadingFrameElement:MovieClip = null;
         var lootItem:Object = null;
         var slotIndex:int = 0;
         var mysteryId:int = 0;
         var itemName:String = null;
         var item:FarmItem = null;
         if(m_window)
         {
            if(Boolean(result) && result is Array)
            {
               for each(lootItem in result)
               {
                  slotIndex = int.MAX_VALUE;
                  mysteryId = int(lootItem["mysteryId"]);
                  switch(mysteryId)
                  {
                     case -1:
                        slotIndex = -1;
                        break;
                     case 0:
                        slotIndex = 0;
                        break;
                     case 1:
                        slotIndex = 5;
                        break;
                     case 2:
                        slotIndex = 1;
                        break;
                     case 3:
                        slotIndex = 4;
                        break;
                     case 4:
                        slotIndex = 2;
                        break;
                     case 5:
                        slotIndex = 3;
                  }
                  if(slotIndex == -1)
                  {
                     itemName = lootItem["itemName"];
                     item = Global.farmGameSettingsManager.getFarmItemByName(itemName);
                     if(item)
                     {
                        this.hasEarnedSetBonus = lootItem["winCount"] > 0 ? true : false;
                        this.m_setBonusItemName = itemName;
                        this.m_bonusPrizeIcon.loadIcon(item.iconUrl);
                        this.m_bonusPrizeName.text = item.friendlyTitle;
                     }
                  }
                  else if(slotIndex < NUM_PRIZE_SLOTS)
                  {
                     (this.m_prizeSlots[slotIndex] as PigoPrizeSlot).populate(lootItem);
                  }
               }
            }
            (this.m_loadingText.element as MovieClip).stop();
            loadingFrameElement = this.m_loadingFrame.element as MovieClip;
            loadingFrameElement.addEventListener(Event.ENTER_FRAME,this.onLoadingFrameEnterFrame);
            loadingFrameElement.gotoAndPlay(2);
            if(!this.m_userInitiated)
            {
               PigoWindow.displayAlreadyCreatedWindow(this.m_source,this);
            }
         }
      }
      
      private function grantReward(slotIndex:int) : void
      {
         var slot:PigoPrizeSlot = null;
         var itemName:String = null;
         if(slotIndex < this.m_prizeSlots.length)
         {
            slot = this.m_prizeSlots[slotIndex] as PigoPrizeSlot;
            slot.incrementCount();
            itemName = slot.itemName;
            TransactionManager.addTransaction(new TGenericTransaction("PigoService","grantReward",this.grantRewardTransactionCallback,[this.m_gameItem.name,itemName]),true);
            Global.player.addGift(itemName);
            this.m_lastPrizeFrame.queueItem(itemName);
            if(this.checkForSetBonus())
            {
               this.hasEarnedSetBonus = true;
               Global.player.addGift(this.m_setBonusItemName);
               this.m_lastPrizeFrame.queueItem(this.m_setBonusItemName);
            }
            --this.m_controlFrame.tokensInPlay;
            if(this.m_controlFrame.tokensInPlay <= 0)
            {
               m_closeButton.enabled = true;
            }
            (this.m_bulbsAnimation.element as MovieClip).gotoAndPlay(2);
            this.playPrizeAnimation(slotIndex);
            this.playTitleAnimation();
         }
      }
      
      private function grantRewardTransactionCallback(result:Object) : void
      {
         if(m_window)
         {
            if(!(result.hasOwnProperty("complete") && Boolean(result["complete"])))
            {
               FarmStatsManager.count("fv_pigo","error","grantReward");
               close();
            }
         }
      }
      
      private function buyToken() : Boolean
      {
         var result:Boolean = false;
         if(Global.player.canBuyCash(this.m_tokenPrice,true))
         {
            result = true;
            TransactionManager.addTransaction(new TGenericTransaction("PigoService","buyToken",this.buyTokenTransactionCallback,[this.m_gameItem.name]),true);
            FarmStatsManager.count("fv_pigo","tokens_purchased","1",String(this.m_tokenPrice));
            Global.player.cash -= this.m_tokenPrice;
            this.m_controlFrame.tokenCount += 1;
            Global.player.addGift(TOKEN_CONSUMABLE_ITEM_NAME);
         }
         return result;
      }
      
      private function buyTokenTransactionCallback(result:Object) : void
      {
         if(m_window)
         {
            if(result != "success")
            {
               FarmStatsManager.count("fv_pigo","error","buyToken");
               close();
            }
         }
      }
      
      private function buyTokenPackage() : Boolean
      {
         var result:Boolean = false;
         if(Global.player.canBuyCash(this.m_tokenPackagePrice,true))
         {
            result = true;
            TransactionManager.addTransaction(new TGenericTransaction("PigoService","buyTokenPackage",this.buyTokenPackageTransactionCallback,[this.m_gameItem.name]),true);
            FarmStatsManager.count("fv_pigo","tokens_purchased",String(this.m_tokenPackageCount),String(this.m_tokenPackagePrice));
            Global.player.cash -= this.m_tokenPackagePrice;
            this.m_controlFrame.tokenCount += this.m_tokenPackageCount;
            Global.player.addGift(TOKEN_CONSUMABLE_ITEM_NAME,"0",this.m_tokenPackageCount);
         }
         return result;
      }
      
      private function buyTokenPackageTransactionCallback(result:Object) : void
      {
         if(m_window)
         {
            if(result != "success")
            {
               FarmStatsManager.count("fv_pigo","error","buyTokenPackage");
               close();
            }
         }
      }
      
      private function checkForFreePlay() : Boolean
      {
         var result:Boolean = false;
         if(Global.player.level >= Global.farmGameSettingsManager.getNumber(FREE_PLAY_MIN_LEVEL_SETTING,DEFAULT_FREE_PLAY_MIN_LEVEL))
         {
            if(Global.player.getActionCount(FREE_PLAY_COUNTER) > 0)
            {
               result = true;
            }
         }
         return result;
      }
      
      private function checkForSetBonus() : Boolean
      {
         var slot:PigoPrizeSlot = null;
         var result:Boolean = this.m_setBonusItemName != null && this.m_setBonusItemName != "" && !this.m_hasEarnedSetBonus;
         if(result)
         {
            for each(slot in this.m_prizeSlots)
            {
               if(slot.count <= 0)
               {
                  result = false;
                  break;
               }
            }
         }
         return result;
      }
      
      private function set hasEarnedSetBonus(value:Boolean) : void
      {
         this.m_hasEarnedSetBonus = value;
         if(this.m_hasEarnedSetBonus)
         {
            (this.m_bonusPrizeArrow.element as MovieClip).gotoAndStop(2);
            this.m_bonusPrizeText.text = ZLocUtils.t("Dialogs","PigoWindow_PrizeSlot_Won");
         }
         else
         {
            (this.m_bonusPrizeArrow.element as MovieClip).gotoAndStop(1);
            this.m_bonusPrizeText.text = ZLocUtils.t("Dialogs","PigoWindow_SetBonusLabel");
         }
      }
      
      private function onLoadingFrameEnterFrame(event:Event) : void
      {
         var loadingFrameElement:MovieClip = this.m_loadingFrame.element as MovieClip;
         if(loadingFrameElement.currentFrame == loadingFrameElement.framesLoaded)
         {
            loadingFrameElement.removeEventListener(Event.ENTER_FRAME,this.onLoadingFrameEnterFrame);
            this.m_loadingFrame.visible = false;
            this.playTitleAnimation();
            this.m_tokenDropWidget.hasToken = true;
            this.m_tokenDropWidget.start();
            if(this.checkForFreePlay())
            {
               addEventListener(Event.ENTER_FRAME,this.conditionallyShowFreePlayDialog);
            }
            if(!Global.player.getSeenFlag(MORE_INFO_POP_SEEN_FLAG))
            {
               addEventListener(Event.ENTER_FRAME,this.conditionallyShowInfoDialog);
            }
         }
      }
      
      private function conditionallyShowFreePlayDialog(e:Event = null) : void
      {
         if(UI.getCurrentPopup() === this)
         {
            removeEventListener(Event.ENTER_FRAME,this.conditionallyShowFreePlayDialog);
            this.displayFreePlayDialog();
         }
      }
      
      private function conditionallyShowInfoDialog(e:Event = null) : void
      {
         if(!Global.player.getSeenFlag(MORE_INFO_POP_SEEN_FLAG))
         {
            if(UI.getCurrentPopup() === this)
            {
               Global.player.setSeenFlag(MORE_INFO_POP_SEEN_FLAG);
               this.displayMoreInfoDialog();
            }
         }
         if(Global.player.getSeenFlag(MORE_INFO_POP_SEEN_FLAG))
         {
            removeEventListener(Event.ENTER_FRAME,this.conditionallyShowInfoDialog);
         }
      }
      
      private function playTitleAnimation() : void
      {
         var child:MovieClip = null;
         var titleElement:MovieClip = this.m_titleWidget.element as MovieClip;
         for(var i:int = 0; i < titleElement.numChildren; i++)
         {
            child = titleElement.getChildAt(i) as MovieClip;
            if(child)
            {
               child.gotoAndPlay(1);
            }
         }
      }
      
      private function stopTitleAnimation() : void
      {
         var child:MovieClip = null;
         var titleElement:MovieClip = this.m_titleWidget.element as MovieClip;
         for(var i:int = 0; i < titleElement.numChildren; i++)
         {
            child = titleElement.getChildAt(i) as MovieClip;
            if(child)
            {
               child.stop();
            }
         }
      }
      
      private function playPrizeAnimation(slotIndex:int) : void
      {
         var prizeAnimation:ZwWidget = null;
         if(slotIndex < this.m_prizeAnimations.length)
         {
            prizeAnimation = this.m_prizeAnimations[slotIndex] as ZwWidget;
            (prizeAnimation.element as MovieClip).gotoAndPlay(2);
         }
      }
      
      private function stopPrizeAnimation(slotIndex:int) : void
      {
         var prizeAnimation:ZwWidget = null;
         if(slotIndex < this.m_prizeAnimations.length)
         {
            prizeAnimation = this.m_prizeAnimations[slotIndex] as ZwWidget;
            (prizeAnimation.element as MovieClip).gotoAndStop(1);
         }
      }
   }
}

