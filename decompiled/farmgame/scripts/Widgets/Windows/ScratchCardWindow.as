package Widgets.Windows
{
   import Classes.Constants.QuestConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.UserRewardUtil;
   import Classes.util.ZLocUtils;
   import Engine.Managers.SoundManager;
   import Engine.Managers.TransactionManager;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ScratchCardTileFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Icons.FarmItemIcon;
   import Widgets.Windows.Carnival.CarnivalBoothWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class ScratchCardWindow extends FarmWindow
   {
      
      protected static const NUM_THIS_WEEK_PRIZES:int = 6;
      
      protected static const NUM_TILES_FOR_MATCH:int = 3;
      
      protected static const SIDE_PANEL_WIN_INDEX:int = 0;
      
      protected static const SIDE_PANEL_LOSE_INDEX:int = 1;
      
      protected static const SIDE_PANEL_PLAYING_INDEX:int = 2;
      
      public static const SCRATCH_CARD_ENTRY_DESCRIPTOR_HUD:String = "HUD";
      
      public static const SCRATCH_CARD_ENTRY_DESCRIPTOR_MOTD:String = "MOTD";
      
      public static const SCRATCH_CARD_ENTRY_DESCRIPTOR_AD:String = "market_ad";
      
      public static const SCRATCH_CARD_ENTRY_DESCRIPTOR_CARD:String = "market_card";
      
      public static const SCRATCH_CARD_ENTRY_DESCRIPTOR_GAMETENT:String = "gaming_tent";
      
      protected static const HARDCODED_MYSTERY_REWARD_ICON_OFFSET:int = 10;
      
      protected static const SFX_SCRATCH_SINGLE_URL:String = "assets/sounds/scratch_single.mp3";
      
      protected static const SFX_SCRATCH_SINGLE_ID:String = "scratch_single";
      
      protected static const SFX_SCRATCH_MULTI_URL:String = "assets/sounds/scratch_multi.mp3";
      
      protected static const SFX_SCRATCH_MULTI_ID:String = "scratch_multi";
      
      protected static const SFX_SCRATCH_WIN_URL:String = "assets/sounds/end_success.mp3";
      
      protected static const SFX_SCRATCH_WIN_ID:String = "end_success";
      
      protected static const SFX_SCRATCH_CHIME_URL:String = "assets/sounds/chime_rev_02_14_12.mp3";
      
      protected static const SFX_SCRATCH_CHIME_ID:String = "scratch_chime";
      
      public static const POPUP_NAME:String = "scratchCardWindow";
      
      protected static const DIALOG_ASSET:String = "assets/dialogs/FV_ScratchOff.swf";
      
      protected static const SCRATCH_CASH_ICON:String = "assets/consumables/consume_cash_icon.png";
      
      protected static const SCRATCH_COIN_ONE_MIL_ICON:String = "assets/dialogs/FV_Support/FV_ScratchOff/icon_coins.png";
      
      protected static const ONE_MILLION:int = 1000000;
      
      protected static const SCRATCH_COIN_TWO_MIL_ICON:String = "assets/dialogs/FV_Support/FV_ScratchOff/icon_coins2.png";
      
      protected static const TWO_MILLION:int = 2000000;
      
      protected static const SCRATCH_COCONUT_ICON:String = "assets/consumables/consume_coconuts_icon.png";
      
      protected static const SCRATCH_CARD_ICON:String = "assets/consumables/scratch_card_icon.png";
      
      protected static const BACKGROUND_ASSETS:Array = ["assets/dialogs/FV_Support/FV_ScratchOff/card_tractor.png","assets/dialogs/FV_Support/FV_ScratchOff/card_sheep.png","assets/dialogs/FV_Support/FV_ScratchOff/card_farmer.png","assets/dialogs/FV_Support/FV_ScratchOff/card_duck.png","assets/dialogs/FV_Support/FV_ScratchOff/card_cow.png"];
      
      protected const START_FRAME_WIN_EFFECT:int = 2;
      
      protected var m_winEntryData:Object;
      
      protected var m_cardData:Array;
      
      protected var m_almostWonData:Object;
      
      protected var m_mysteryGiftsData:Array;
      
      protected var m_pricePerCard:int = 99;
      
      protected var m_freeCard:Boolean = false;
      
      protected var m_scratchAllBtn:FarmAnimatedTextButton = null;
      
      protected var m_playAgainBtn:FarmAnimatedCashButton = null;
      
      protected var m_toggleUnlockBtn:FarmAnimatedCashButton = null;
      
      protected var m_freePlayBtn:FarmAnimatedTextButton = null;
      
      protected var m_middleFrame:ZwFrame = null;
      
      protected var m_scratchTilesContainer:ScratchCardTileFrame = null;
      
      protected var m_lockScreen:ZwFrame;
      
      protected var m_sideWinPanel:ZwFrame = null;
      
      protected var m_winPanelIcon:FarmItemIcon = null;
      
      protected var m_winPanelText:ZwTextField = null;
      
      protected var m_winEffectMc:ZwFrame = null;
      
      protected var m_sideLosePanel:ZwFrame = null;
      
      protected var m_losePanelIcon:FarmItemIcon = null;
      
      protected var m_losePanelQuantity:ZwTextField = null;
      
      protected var m_sidePlayingPanel:ZwFrame = null;
      
      protected var m_weekPrizeIcons:Array = null;
      
      protected var m_largePrizeIcon:FarmItemIcon = null;
      
      protected var m_prizeTextMc:ZwFrame = null;
      
      protected var m_magnifiedItemTf:ZwTextField = null;
      
      protected var m_backgroundFrame:FarmIcon = null;
      
      protected var m_entryPoint:String = "";
      
      public function ScratchCardWindow(entryPoint:String)
      {
         super(DIALOG_ASSET);
         this.name = POPUP_NAME;
         this.m_weekPrizeIcons = [];
         this.m_entryPoint = entryPoint;
      }
      
      public static function loadItemIconWithScratchData(itemIcon:FarmItemIcon, scratchData:Object, animated:Boolean = false) : int
      {
         var itemCode:String = null;
         var quantity:int = 1;
         if(scratchData != null)
         {
            switch(scratchData["type"])
            {
               case QuestConstants.REWARD_GRANT_ITEM:
                  itemCode = scratchData["value"] as String;
                  itemIcon.reloadItem(Global.farmGameSettingsManager.getFarmItemByCode(itemCode),animated);
                  quantity = getItemQuantity(itemCode);
                  if(scratchData["quantity"] != null)
                  {
                     quantity *= int(parseInt(scratchData["quantity"]));
                  }
                  break;
               case QuestConstants.REWARD_CASH_FROM_SCRATCH_CARD:
                  itemIcon.loadIconUrl(SCRATCH_CASH_ICON);
                  quantity = int(parseInt(scratchData["value"]));
                  break;
               case QuestConstants.REWARD_COINS:
                  quantity = int(parseInt(scratchData["value"]));
                  if(quantity == ONE_MILLION)
                  {
                     itemIcon.loadIconUrl(SCRATCH_COIN_ONE_MIL_ICON);
                  }
                  else if(quantity == TWO_MILLION)
                  {
                     itemIcon.loadIconUrl(SCRATCH_COIN_TWO_MIL_ICON);
                  }
                  quantity = 1;
                  break;
               case QuestConstants.REWARD_SCRATCH_CARD:
                  itemIcon.loadIconUrl(SCRATCH_CARD_ICON);
                  break;
               case QuestConstants.REWARD_WORLD_CURRENCY:
                  quantity = int(parseInt(scratchData["value"]));
                  itemIcon.loadIconUrl(SCRATCH_COCONUT_ICON);
            }
         }
         return quantity;
      }
      
      protected static function getItemQuantity(itemCode:String) : int
      {
         var result:int = 1;
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
         var itemPackageCount:int = 0;
         if(item != null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               itemPackageCount = item.getIntFromDataSource("itemPackage","amount");
            }
            else if(item.xml.itemPackage != null && item.xml.itemPackage.@amount != null)
            {
               itemPackageCount = int(item.xml.itemPackage.@amount);
            }
            if(item.count > 1)
            {
               result = item.count;
            }
            else if(itemPackageCount != 0)
            {
               result = itemPackageCount;
            }
         }
         return result;
      }
      
      public static function compareScratchObjects(object1:Object, object2:Object) : Boolean
      {
         var result:Boolean = true;
         if(Boolean(object1["value"] != null && object2["value"]) && Boolean(object1["value"] != object2["value"]) || Boolean(object1["type"] != null && object2["type"]) && Boolean(object1["type"] != object2["type"]) || object1["quantity"] != null && object2["quantity"] != null && object1["quantity"] != object2["quantity"])
         {
            result = false;
         }
         return result;
      }
      
      override protected function postLoadComplete() : void
      {
         var bgHolder:ZwFrame;
         var prizesFrame:ZwFrame;
         super.postLoadComplete();
         bgHolder = addWidget(new ZwFrame(m_window.back_mc)) as ZwFrame;
         this.m_backgroundFrame = bgHolder.addWidget(new FarmIcon(bgHolder.element.background_mc)) as FarmIcon;
         this.m_backgroundFrame.loadIcon(this.getRandomBackgroundURL());
         this.m_middleFrame = addWidget(new ZwFrame(m_window.middle_mc)) as ZwFrame;
         this.m_scratchTilesContainer = this.m_middleFrame.addWidget(new ScratchCardTileFrame(this.m_middleFrame.element.container_mc,[])) as ScratchCardTileFrame;
         this.m_scratchTilesContainer.repopulateData([{},{},{},{},{},{},{},{},{}]);
         this.m_scratchTilesContainer.setSlotClickCallbacks(this.onSlotClick);
         this.m_lockScreen = this.m_middleFrame.addWidget(new ZwFrame(this.m_middleFrame.element.intro_mc)) as ZwFrame;
         this.m_toggleUnlockBtn = this.m_lockScreen.addWidget(new FarmAnimatedCashButton(this.m_lockScreen.element.start_bt,ZLocUtils.t("Dialogs","ScratchCard_playNow"),this.m_pricePerCard.toString(),this.onUnlock)) as FarmAnimatedCashButton;
         prizesFrame = addWidget(new ZwFrame(m_window.prizeSlot_mc)) as ZwFrame;
         if(this.m_sidePlayingPanel == null && prizesFrame.element.prizes_mc != null)
         {
            this.m_sidePlayingPanel = prizesFrame.addWidget(new ZwFrame(prizesFrame.element.prizes_mc)) as ZwFrame;
            this.loadPlayingFrame();
         }
         if(this.m_sideWinPanel == null && prizesFrame.element.won_mc != null)
         {
            this.m_sideWinPanel = prizesFrame.addWidget(new ZwFrame(prizesFrame.element.won_mc)) as ZwFrame;
            this.loadWinFrame();
         }
         if(this.m_sideLosePanel == null && prizesFrame.element.lost_mc != null)
         {
            this.m_sideLosePanel = prizesFrame.addWidget(new ZwFrame(prizesFrame.element.lost_mc)) as ZwFrame;
            this.loadLoseFrame();
         }
         if(m_window.header_tf != null)
         {
            addWidget(new ZwTextField(m_window.header_tf,ZLocUtils.t("Dialogs","ScratchCard_header")));
         }
         if(m_window.title_tf != null)
         {
            addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","ScratchCard_title")));
         }
         if(m_window.playAgain_bt != null)
         {
            this.m_playAgainBtn = addWidget(new FarmAnimatedCashButton(m_window.playAgain_bt,ZLocUtils.t("Dialogs","ScratchCard_playAgain"),this.m_pricePerCard.toString(),this.onPlayAgain)) as FarmAnimatedCashButton;
         }
         if(m_window.freeplay_bt != null)
         {
            this.m_freePlayBtn = addWidget(new FarmAnimatedTextButton(m_window.freeplay_bt,ZLocUtils.t("Dialogs","ScratchCard_freePlay"),this.onPlayAgain)) as FarmAnimatedTextButton;
         }
         if(m_window.scratch_bt != null)
         {
            this.m_scratchAllBtn = addWidget(new FarmAnimatedTextButton(m_window.scratch_bt,ZLocUtils.t("Dialogs","ScratchCard_scratchAll"),this.onScratchAll)) as FarmAnimatedTextButton;
         }
         this.changeSidePanel(SIDE_PANEL_PLAYING_INDEX);
         this.m_scratchAllBtn.visible = false;
         this.toggleLockScreen(true);
         this.m_middleFrame.enabled = false;
         this.m_lockScreen.alpha = 0.5;
         this.m_toggleUnlockBtn.visible = false;
         TransactionManager.addTransaction(new TGenericTransaction("ScratchCardService","getScratchCardData",function(result:Object):void
         {
            if(m_window != null && result != null)
            {
               m_lockScreen.alpha = 1;
               m_toggleUnlockBtn.visible = true;
               m_middleFrame.enabled = true;
               if(result["card"] != null)
               {
                  FarmStatsManager.count("dialog","scratchcard","impression","unlocked",m_entryPoint);
                  resetGame(result);
                  toggleLockScreen(false);
               }
               else
               {
                  reloadDataFromBackend(result);
                  FarmStatsManager.count("dialog","scratchcard","impression","locked",m_entryPoint);
               }
            }
         },[false]),true);
      }
      
      public function grantFreeCard() : void
      {
         this.m_freeCard = true;
      }
      
      protected function changeSidePanel(sidePanelIndex:int) : void
      {
         this.m_sidePlayingPanel.visible = this.m_sideWinPanel.visible = this.m_sideLosePanel.visible = false;
         this.m_scratchAllBtn.visible = this.m_playAgainBtn.visible = this.m_freePlayBtn.visible = false;
         switch(sidePanelIndex)
         {
            case SIDE_PANEL_WIN_INDEX:
               this.loadWinFrame();
               this.m_sideWinPanel.visible = true;
               this.m_playAgainBtn.visible = true;
               break;
            case SIDE_PANEL_LOSE_INDEX:
               this.loadLoseFrame();
               this.m_sideLosePanel.visible = true;
               this.m_playAgainBtn.visible = true;
               break;
            case SIDE_PANEL_PLAYING_INDEX:
               this.loadPlayingFrame();
               this.m_sidePlayingPanel.visible = true;
               this.m_scratchAllBtn.visible = true;
         }
      }
      
      protected function scratchAll() : void
      {
         var quantityAlmostWon:int = 0;
         var rewardVector:Vector.<Object> = null;
         this.m_scratchTilesContainer.scratchAllTiles();
         if(this.m_almostWonData != null)
         {
            this.changeSidePanel(SIDE_PANEL_LOSE_INDEX);
            FarmStatsManager.count("dialog","scratchcard_loss","impression","",this.m_entryPoint);
            this.m_playAgainBtn.text = ZLocUtils.t("Dialogs","ScratchCard_tryAgain");
            quantityAlmostWon = loadItemIconWithScratchData(this.m_losePanelIcon,this.m_almostWonData,true);
            this.m_losePanelQuantity.text = ZLocUtils.t("Dialogs","GiftAmount",{"quantity":quantityAlmostWon.toString()});
            TransactionManager.addTransaction(new TGenericTransaction("ScratchCardService","clearCard"),true);
         }
         else if(this.m_winEntryData != null)
         {
            this.changeSidePanel(SIDE_PANEL_WIN_INDEX);
            FarmStatsManager.count("dialog","scratchcard_win","impression","",this.m_entryPoint);
            this.m_scratchTilesContainer.setWinningItem(this.m_winEntryData);
            rewardVector = new Vector.<Object>();
            rewardVector.push(this.m_winEntryData);
            UserRewardUtil.grantUserRewards(rewardVector);
            this.m_playAgainBtn.text = ZLocUtils.t("Dialogs","ScratchCard_playAgain");
            if(this.m_freeCard == true)
            {
               this.m_playAgainBtn.setAmountText("0");
               this.m_freePlayBtn.visible = true;
               this.m_playAgainBtn.visible = false;
            }
            this.playSound(SFX_SCRATCH_WIN_ID,SFX_SCRATCH_WIN_URL);
            (this.m_winEffectMc.element as MovieClip).gotoAndStop(this.START_FRAME_WIN_EFFECT);
            TransactionManager.addTransaction(new TGenericTransaction("ScratchCardService","grantReward"),true);
         }
      }
      
      protected function reloadDataFromBackend(result:Object) : void
      {
         if(result != null)
         {
            if(result["mysteryGifts"] != null)
            {
               this.m_mysteryGiftsData = result["mysteryGifts"];
               this.loadPlayingFrame();
            }
            this.m_almostWonData = result["almostWon"];
            this.m_cardData = result["card"];
            if(this.m_cardData != null)
            {
               this.playSound(SFX_SCRATCH_CHIME_ID,SFX_SCRATCH_CHIME_URL);
               this.m_scratchTilesContainer.repopulateData(this.m_cardData);
               (this.m_winEffectMc.element as MovieClip).gotoAndStop(1);
            }
            this.m_winEntryData = result["winEntry"];
            if(result["price_per_card"] != null)
            {
               this.m_pricePerCard = int(parseInt(result["price_per_card"]));
               if(this.m_toggleUnlockBtn != null)
               {
                  this.m_toggleUnlockBtn.setAmountText(this.m_pricePerCard.toString());
               }
               if(this.m_playAgainBtn != null)
               {
                  this.m_playAgainBtn.setAmountText(this.m_pricePerCard.toString());
               }
            }
         }
      }
      
      protected function resetGame(backendData:Object) : void
      {
         if(this.m_window != null)
         {
            this.toggleButton(this.m_playAgainBtn,true);
            this.toggleButton(this.m_freePlayBtn,true);
            this.m_scratchTilesContainer.resetTiles();
            this.reloadDataFromBackend(backendData);
            this.changeSidePanel(SIDE_PANEL_PLAYING_INDEX);
            this.m_backgroundFrame.loadIcon(this.getRandomBackgroundURL());
         }
      }
      
      private function loadWinFrame() : void
      {
         var quantity:int = 0;
         var prizeString:String = null;
         var itemCode:String = null;
         if(this.m_winPanelIcon == null)
         {
            this.m_winPanelIcon = new FarmItemIcon(this.m_sideWinPanel,this.m_sideWinPanel.element.weeklyPrize_mc);
         }
         if(this.m_winEntryData != null)
         {
            quantity = loadItemIconWithScratchData(this.m_winPanelIcon,this.m_winEntryData,true);
            if(this.m_winPanelIcon.getActiveWidget() is FarmIcon)
            {
               (this.m_winPanelIcon.getActiveWidget() as FarmIcon).setSmoothing(true);
            }
            if(this.m_winPanelText == null)
            {
               this.m_winPanelText = this.m_sideWinPanel.addWidget(new ZwTextField(this.m_sideWinPanel.element.prize_tf)) as ZwTextField;
            }
            prizeString = "";
            switch(this.m_winEntryData["type"])
            {
               case QuestConstants.REWARD_GRANT_ITEM:
                  itemCode = this.m_winEntryData["value"] as String;
                  prizeString = ZLocUtils.tk_pk_asTitle(Global.farmGameSettingsManager.getFarmItemByCode(itemCode).friendlyName);
                  quantity /= getItemQuantity(itemCode);
                  break;
               case QuestConstants.REWARD_CASH_FROM_SCRATCH_CARD:
                  prizeString = ZLocUtils.t("Dialogs","ScratchCard_farmCashPrize");
                  break;
               case QuestConstants.REWARD_COINS:
                  prizeString = ZLocUtils.t("Dialogs","ScratchCard_coinsPrize");
                  break;
               case QuestConstants.REWARD_SCRATCH_CARD:
                  prizeString = ZLocUtils.t("Dialogs","ScratchCard_scratchCardPrize");
                  break;
               case QuestConstants.REWARD_WORLD_CURRENCY:
                  prizeString = ZLocUtils.t("FarmGame","Currency_Coconuts");
            }
            this.m_winPanelText.text = prizeString;
            if(quantity > 1)
            {
               this.m_winPanelText.text += " " + ZLocUtils.t("Dialogs","GiftAmount",{"quantity":quantity.toString()});
            }
         }
         if(this.m_sideWinPanel.getWidget(this.m_sideWinPanel.element.title_tf) == null)
         {
            this.m_sideWinPanel.addWidget(new ZwTextField(this.m_sideWinPanel.element.title_tf,ZLocUtils.t("Dialogs","ScratchCard_winTitle")));
         }
         if(this.m_winEffectMc == null && this.m_sideWinPanel.element.effect_mc != null)
         {
            this.m_winEffectMc = this.m_sideWinPanel.addWidget(new ZwFrame(this.m_sideWinPanel.element.effect_mc)) as ZwFrame;
         }
      }
      
      private function loadLoseFrame() : void
      {
         if(this.m_sideLosePanel.getWidget(this.m_sideLosePanel.element.prize_tf) == null)
         {
            this.m_sideLosePanel.addWidget(new ZwTextField(this.m_sideLosePanel.element.prize_tf,ZLocUtils.t("Dialogs","ScratchCard_loseTitle")));
         }
         if(this.m_sideLosePanel.element.icon_mc != null && this.m_losePanelIcon == null)
         {
            this.m_losePanelIcon = new FarmItemIcon(this.m_sideLosePanel,this.m_sideLosePanel.element.icon_mc);
         }
         if(this.m_sideLosePanel.element.quantity_tf != null && this.m_losePanelQuantity == null)
         {
            this.m_losePanelQuantity = this.m_sideLosePanel.addWidget(new ZwTextField(this.m_sideLosePanel.element.quantity_tf,"")) as ZwTextField;
         }
      }
      
      private function loadPlayingFrame() : void
      {
         var i:int = 0;
         var prizePreviewsContainer:ZwFrame = this.m_sidePlayingPanel.getWidget(this.m_sidePlayingPanel.element.prizes_mc) as ZwFrame;
         if(prizePreviewsContainer == null)
         {
            prizePreviewsContainer = this.m_sidePlayingPanel.addWidget(new ZwFrame(this.m_sidePlayingPanel.element.prizes_mc)) as ZwFrame;
         }
         var iconMovieClips:Array = [prizePreviewsContainer.element.p0_mc,prizePreviewsContainer.element.p1_mc,prizePreviewsContainer.element.p2_mc,prizePreviewsContainer.element.p3_mc,prizePreviewsContainer.element.p4_mc,prizePreviewsContainer.element.p5_mc];
         if(this.m_weekPrizeIcons.length == 0)
         {
            i = 0;
            while(i < iconMovieClips.length && i < NUM_THIS_WEEK_PRIZES)
            {
               (iconMovieClips[i] as MovieClip).x += HARDCODED_MYSTERY_REWARD_ICON_OFFSET;
               (iconMovieClips[i] as MovieClip).y += HARDCODED_MYSTERY_REWARD_ICON_OFFSET;
               this.m_weekPrizeIcons.push(new FarmItemIcon(prizePreviewsContainer,iconMovieClips[i]));
               (iconMovieClips[i] as MovieClip).addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOverIcon);
               (iconMovieClips[i] as MovieClip).addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOutIcon);
               i++;
            }
         }
         if(this.m_mysteryGiftsData != null)
         {
            i = 0;
            while(i < this.m_mysteryGiftsData.length && i < this.m_weekPrizeIcons.length)
            {
               (this.m_weekPrizeIcons[i] as FarmItemIcon).reloadItem(Global.farmGameSettingsManager.getFarmItemByCode(this.m_mysteryGiftsData[i].value),false);
               i++;
            }
         }
         if(this.m_largePrizeIcon == null && this.m_sidePlayingPanel.element.largePrize_mc != null)
         {
            this.m_largePrizeIcon = new FarmItemIcon(this.m_sidePlayingPanel,this.m_sidePlayingPanel.element.largePrize_mc);
            this.m_largePrizeIcon.reloadItem(Global.farmGameSettingsManager.getFarmItemByName("horse"));
            this.m_largePrizeIcon.getActiveWidget().visible = false;
         }
         if(this.m_magnifiedItemTf == null && this.m_sidePlayingPanel.element.largePrize_tf != null)
         {
            this.m_magnifiedItemTf = this.m_sidePlayingPanel.addWidget(new ZwTextField(this.m_sidePlayingPanel.element.largePrize_tf,""),false) as ZwTextField;
         }
         if(this.m_prizeTextMc == null && this.m_sidePlayingPanel.element.bottom_mc != null)
         {
            this.m_prizeTextMc = this.m_sidePlayingPanel.addWidget(new ZwFrame(this.m_sidePlayingPanel.element.bottom_mc)) as ZwFrame;
         }
         if(this.m_sidePlayingPanel.getWidget(this.m_sidePlayingPanel.element.title_tf) == null)
         {
            this.m_sidePlayingPanel.addWidget(new ZwTextField(this.m_sidePlayingPanel.element.title_tf,ZLocUtils.t("Dialogs","ScratchCard_playingTitle")));
         }
      }
      
      private function onMouseOverIcon(event:MouseEvent) : void
      {
         this.m_prizeTextMc.visible = false;
         var frameIndex:int = int(parseInt((event.currentTarget.name as String).charAt(1)));
         loadItemIconWithScratchData(this.m_largePrizeIcon,this.m_mysteryGiftsData[frameIndex],true);
         this.m_magnifiedItemTf.text = ZLocUtils.tk_pk_asTitle(Global.farmGameSettingsManager.getFarmItemByCode(this.m_mysteryGiftsData[frameIndex]["value"]).friendlyName);
         this.m_magnifiedItemTf.visible = true;
         this.m_largePrizeIcon.getActiveWidget().visible = true;
      }
      
      private function onMouseOutIcon(event:MouseEvent) : void
      {
         this.m_prizeTextMc.visible = true;
         this.m_magnifiedItemTf.visible = false;
         this.m_largePrizeIcon.getActiveWidget().visible = false;
      }
      
      protected function onSlotClick(event:MouseEvent = null) : void
      {
         var numSimilar:int = 0;
         var itemTested:Object = null;
         var status:Array = this.m_scratchTilesContainer.getTileScratchedStatus();
         var numScratched:int = 0;
         var scratchedItems:Array = [];
         for(var i:int = 0; i < status.length; i++)
         {
            if(status[i][ScratchCardTileFrame.KEY_STATUS_SCRATCHED] == true)
            {
               numScratched++;
               scratchedItems.push(status[i][ScratchCardTileFrame.KEY_STATUS_TILE_ITEM]);
            }
         }
         this.playSound(SFX_SCRATCH_SINGLE_ID,SFX_SCRATCH_SINGLE_URL);
         if(scratchedItems.length > 0 && numScratched != this.m_scratchTilesContainer.NUM_TILES)
         {
            scratchedItems.sortOn("value");
            numSimilar = 1;
            itemTested = scratchedItems[0];
            for(i = 1; i < scratchedItems.length; i++)
            {
               if(compareScratchObjects(itemTested,scratchedItems[i]) == false)
               {
                  numSimilar = 1;
                  itemTested = scratchedItems[i];
               }
               else if(++numSimilar == NUM_TILES_FOR_MATCH)
               {
                  this.scratchAll();
                  this.playSound(SFX_SCRATCH_MULTI_ID,SFX_SCRATCH_MULTI_URL);
                  break;
               }
            }
         }
         else if(numScratched == this.m_scratchTilesContainer.NUM_TILES)
         {
            this.scratchAll();
         }
      }
      
      protected function onPlayAgain(event:Event = null) : void
      {
         if(this.m_freeCard == true || Global.player.canBuyCash(this.m_pricePerCard,true,"scratchcard") == true)
         {
            TransactionManager.addTransaction(new TGenericTransaction("ScratchCardService","getScratchCardData",this.onPlayAgainReturned,[!this.m_freeCard]),true);
            this.toggleButton(this.m_playAgainBtn,false);
            this.toggleButton(this.m_freePlayBtn,false);
            this.toggleButton(m_closeButton,false);
            if(this.m_sideWinPanel.visible == true)
            {
               FarmStatsManager.count("dialog","scratchcard_win","click","playagain",this.m_entryPoint);
            }
            else
            {
               FarmStatsManager.count("dialog","scratchcard_loss","click","playagain",this.m_entryPoint);
            }
         }
      }
      
      protected function onPlayAgainReturned(result:Object) : void
      {
         if(this != null)
         {
            this.resetGame(result);
            this.toggleButton(m_closeButton,true);
            if(this.m_freeCard == false)
            {
               Global.player.cash -= this.m_pricePerCard;
            }
            else
            {
               this.m_freeCard = false;
            }
         }
      }
      
      protected function onUnlock(event:Event = null) : void
      {
         if(Global.player.canBuyCash(this.m_pricePerCard,true,"scratchcard"))
         {
            TransactionManager.addTransaction(new TGenericTransaction("ScratchCardService","getScratchCardData",this.onUnlockReturned,[true]),true);
            this.toggleButton(this.m_toggleUnlockBtn,false);
            this.toggleButton(m_closeButton,false);
            FarmStatsManager.count("dialog","scratchcard","click","unlocked",this.m_entryPoint);
         }
      }
      
      protected function onUnlockReturned(result:Object) : void
      {
         if(this.m_window != null)
         {
            this.toggleButton(this.m_toggleUnlockBtn,true);
            this.reloadDataFromBackend(result);
            this.toggleLockScreen(false);
            this.toggleButton(m_closeButton,true);
            this.m_backgroundFrame.loadIcon(this.getRandomBackgroundURL());
         }
         Global.player.cash -= this.m_pricePerCard;
      }
      
      protected function onScratchAll(event:Event) : void
      {
         FarmStatsManager.count("dialog","scratchcard","click","scratch_all",this.m_entryPoint);
         this.scratchAll();
         this.playSound(SFX_SCRATCH_MULTI_ID,SFX_SCRATCH_MULTI_URL);
      }
      
      override protected function onClose(event:Event) : void
      {
         CarnivalBoothWindow.promoteCarnivalBooth();
         FarmStatsManager.count("dialog","scratchcard","click","close",this.m_entryPoint);
         for(var i:int = 0; i < this.m_weekPrizeIcons.length; i++)
         {
            (this.m_weekPrizeIcons[i] as FarmItemIcon).element.removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOverIcon);
            (this.m_weekPrizeIcons[i] as FarmItemIcon).element.removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOutIcon);
         }
         super.onClose(event);
      }
      
      private function toggleButton(btn:FarmButton, enabled:Boolean) : void
      {
         btn.enabled = enabled;
         btn.applyGrayOut = !enabled;
      }
      
      private function playSound(id:String, relativeUrl:String) : void
      {
         SoundManager.addSound(id,Global.getAssetURL(relativeUrl));
         SoundManager.playSound(id);
      }
      
      private function getRandomBackgroundURL() : String
      {
         return BACKGROUND_ASSETS[int(Math.floor(Math.random() * BACKGROUND_ASSETS.length))];
      }
      
      private function toggleLockScreen(locked:Boolean) : void
      {
         this.m_lockScreen.visible = locked;
         this.m_scratchAllBtn.visible = !locked;
         this.loadPlayingFrame();
      }
   }
}

