package Display
{
   import Classes.CMysteryBoxGameDartAutoConsumable;
   import Classes.Constants.Experiments;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.ZItem.FarmItem;
   import Classes.consumables.CMysteryBoxGameDart;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.HUD.HUD;
   import Engine.Events.LoaderEvent;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.TransactionManager;
   import Engine.Utilities;
   import Events.GenericPopupEvent;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsInventoryManager;
   import Managers.MiniDartsManager;
   import Transactions.TBuyMysteryGiftGameItem;
   import Transactions.TBuyMysteryGiftTurn;
   import Transactions.TGetMysteryLoot;
   import Transactions.TUseMysteryBoxDartAutoConsumable;
   import Transactions.TUseMysteryBoxDartConsumable;
   import Widgets.Windows.Carnival.CarnivalBoothWindow;
   import Widgets.Windows.MysteryGame.MysteryGameCongratsWindow;
   import Widgets.Windows.MysteryGame.MysteryGameInfoWindow;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.ColorTransform;
   import flash.text.TextField;
   import flash.ui.Mouse;
   import flash.utils.Timer;
   import gs.TweenLite;
   
   public class MysteryBoxBalloonDialog extends Dialog
   {
      
      public static const FREE_GAME_DART_COUNTER:String = "SECURE_freeMysteryGameDartCount";
      
      public static const FREE_GAME_POP_UP_COUNTER:String = "freeMysteryGamePopup";
      
      public static const FREE_GAME_POP_UP_VERSION:String = "MYSTERY_GAME_FREEDART_POPUP";
      
      public static const PAYER_POPUP_VERSION:String = "MYSTERY_GAME_POP_UP_PAYERS";
      
      private static const MYSTERY_ID_SET_BONUS:int = -1;
      
      private static const EXP_VARIANT_UI_REFRESH:int = 2;
      
      private static const SEEN_FLAG_COLLECTION_INFO:String = "seeMgCollect";
      
      private static const SEEN_FLAG_NEW_COLLECTION_INFO:String = "seeNewMgCollect";
      
      private static const SEEN_FLAG_NEW_PRIZES:String = "seeMgNew";
      
      public static const SEEN_FLAG_BUY_MORE:String = "mbbd_buy_more";
      
      private static const CONSUMABLE_DART_ITEM_NAMES:Array = new Array("consume_mystery_game_dart","slingoxpromo_mystery_dart");
      
      private static const UI_REFRESH_OFFSET_X:int = 20;
      
      private static const UI_REFRESH_OFFSET_Y:int = 60;
      
      private static const REWARD_PANEL_DROP_DELAY_MS:int = 1000;
      
      private static const PRIZE_DISPLAY_DURATION_S:int = 4;
      
      private static const LOADER_SCREEN_PLAY_FRAME:int = 2;
      
      private static const CROSSHAIR_PLAY_FRAME:int = 2;
      
      private static const CROSSHAIR_READY_FRAME:int = 1;
      
      private static const REWARD_FRAME_OUTRO:String = "outro";
      
      private static const REWARD_FRAME_INTRO:String = "intro";
      
      private static const REWARD_FRAME_HIDE:int = 0;
      
      private static const PREREQ_MYSTERY_GAME_DISABLE_NON_PAYER_FRICTIONLESS:String = "mysterygame_1clickpurchase_disable_non_payer";
      
      private static var USER_ENTERS_STATE:int = 0;
      
      private static var DART_MODE:int = 1;
      
      private static const BALLOON_FULL_FRAMENUM:int = 1;
      
      private static const BALLOON_POPPED_FRAMENUM:int = 2;
      
      private static const GIFT_UNWRAP_FRAMENUM:int = 35;
      
      private static const BALLOON_COUNT:int = 25;
      
      private static const TILE_COUNT:int = 6;
      
      private static const RIGHTPANEL_STATE_PLAY:String = "play";
      
      private static const RIGHTPANEL_STATE_REWARD:String = "reward";
      
      private static const TILE_STATE_NOT_WON:int = 0;
      
      private static const TILE_STATE_WON:int = 1;
      
      private static const TARGET_STATE_POPPED:int = 0;
      
      private static const TARGET_STATE_UNPOPPED:int = 1;
      
      private static const TILE_BUY_STATE_WON:int = 1;
      
      private static const TILE_BUY_STATE_NOT_WON:int = 2;
      
      private static const FREE_DART_MSG_FLAG:String = "freeDartWarningMessage";
      
      private static const PLAY_FAIL:int = 0;
      
      private static const PLAY_FREE:int = 1;
      
      private static const PLAY_CONSUMABLE:int = 2;
      
      private static const PLAY_CASH:int = 3;
      
      public static var buyMoreOverride:int = -1;
      
      private static var m_dimColorTransform:ColorTransform = new ColorTransform(0.5,0.5,0.5,1,0,0,0,0);
      
      private static var m_normalColorTransform:ColorTransform = new ColorTransform();
      
      private static const MASTER_LOOT_TABLE:String = "MasterMysteryGameLootTable";
      
      private static const NEW_MYSTERY_GAME_URL:String = "assets/dialogs/FV_mysteryGame_5.swf";
      
      public static const IN_LOOT_TABLE_VARIANT:Boolean = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_MG_LOOT_TABLE) > 1;
      
      private static const GARDEN_OF_GIFT_GAME_URL:String = "assets/dialogs/FV_GardenOfGifts_2015.swf";
      
      private static const GARDEN_OF_GIFT_GAME_COMPLETE_URL:String = "assets/dialogs/FV_GardenOfGifts_2015_Complete.swf";
      
      private static const SEEN_FLAG_REVAMP_COLLECTION_INFO:String = "seeRevampMgCollect";
      
      public static const TOTAL_HELPERS:int = 5;
      
      private static const CONSUMABLE_MYSTERY_GAME_REVAMAP_ITEM:String = "pkg_mystery_game_revamp_dart_v2";
      
      private static const REVAMP_LOOT_TABLE:String = "mysteryGameRevampLootTable";
      
      private static var m_consumable_dart_item_name:String = "consume_mystery_game_revamp_dart_v2";
      
      private var m_balloonArray:Array;
      
      private var m_buyButtonArray:Array;
      
      private var m_buyMoreButtonArray:Array;
      
      private var m_tileArray:Array;
      
      private var m_tileStatesArray:Array;
      
      private var m_tileTitlesArray:Array;
      
      private var m_itemPricesArray:Array;
      
      private var m_tileBackgroundsArray:Array;
      
      private var m_rewardItemsArray:Array = new Array();
      
      private var m_gameState:int = USER_ENTERS_STATE;
      
      private var m_inPopup:Boolean = false;
      
      private var m_isMaxGift:Boolean = false;
      
      private var m_isShown:Boolean = false;
      
      private var m_genPop:Boolean = false;
      
      private var m_dispObj:DisplayObject;
      
      private var m_playButton:GenericButton;
      
      private var m_playAgainButton:GenericButton;
      
      private var m_whatIsThis:GenericButton;
      
      private var m_index:int;
      
      private var m_buyIndex:int;
      
      private var m_cash:int;
      
      private var m_buyPrice:int;
      
      private var m_crosshair:MovieClip;
      
      private var m_rightPanelPlay:MovieClip;
      
      private var m_rewardPanel:MovieClip;
      
      private var m_rewardedItem:MovieClip;
      
      private var m_purchasedToaster:MovieClip;
      
      private var m_purchasedToasterClose:GenericButton;
      
      private var m_gameObject:FarmItem;
      
      private var m_miniGames:Object;
      
      private var m_returnedGameData:Object;
      
      private var m_initResults:Object;
      
      private var m_gameTokenName:String;
      
      private var m_cost_tf:TextField;
      
      private var m_escapable:Boolean;
      
      private var m_wasFreeGame:Boolean;
      
      private var m_open:Boolean;
      
      private var m_congratsWindow:MysteryGameCongratsWindow;
      
      private var m_results:XML;
      
      private var m_MouseShow:Boolean;
      
      private var m_dartConsumable:Object;
      
      private var m_showDartCount:Boolean;
      
      private var m_messageCount:int;
      
      private var m_enteringViaMarket:Boolean;
      
      private var m_gameFinished:Boolean = false;
      
      private var m_initialToasterY:Number = 0;
      
      private var m_usingRefreshedUI:Boolean = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_MYSTERYGAME_UI_REFRESH) == EXP_VARIANT_UI_REFRESH;
      
      private var m_rewardPanelFrame:MovieClip;
      
      private var m_loaderScreen:MovieClip;
      
      private var m_windowOffsetX:int = 0;
      
      private var m_windowOffsetY:int = 0;
      
      private var m_dropDownTimer:Timer;
      
      private const DEFAULT_DART_COST:int = 15;
      
      private var m_freeplay:TextField;
      
      private var m_dartCount:MovieClip;
      
      private var m_buyDartButton:GenericButton;
      
      private var m_askTokenButton:CustomMouseButton;
      
      private var m_helpCounter:MovieClip;
      
      private const DEFAULT_NEW_MG_DART_COST:int = 15;
      
      private var m_featureManager:MiniDartsManager;
      
      private var m_isRevampGame:Boolean = MiniDartsManager.getInstance().isFeatureActive();
      
      private var m_endDate:String = "";
      
      private var m_timer:Timer;
      
      private var m_newPlayButton:GenericButton;
      
      private var m_currentFarm:String = Global.worldManager.currentWorldType;
      
      private var m_showRevampMotd:Boolean = false;
      
      private var m_mysteryBox2TargetStates:Array = new Array();
      
      private var m_mysteryBox2TileStates:Array = new Array();
      
      public function MysteryBoxBalloonDialog(gameTokenName:String, dartConsumable:Object = null, enteringViaMarket:Boolean = false)
      {
         if(this.m_usingRefreshedUI)
         {
            m_dialogAsset = "assets/dialogs/FV_mysteryGame_4.swf";
            this.m_windowOffsetX = UI_REFRESH_OFFSET_X;
            this.m_windowOffsetY = UI_REFRESH_OFFSET_Y;
         }
         else
         {
            m_dialogAsset = "assets/dialogs/animation_mysteryGame_v1_1.swf";
         }
         if(this.m_isRevampGame)
         {
            m_dialogAsset = GARDEN_OF_GIFT_GAME_URL;
            this.m_windowOffsetX = UI_REFRESH_OFFSET_X;
            this.m_windowOffsetY = UI_REFRESH_OFFSET_Y;
            this.m_miniGames = Global.player.miniGames[REVAMP_LOOT_TABLE];
            this.m_gameTokenName = REVAMP_LOOT_TABLE;
            this.m_featureManager = MiniDartsManager.getInstance();
            this.m_endDate = this.m_featureManager.FEATURE_END_DATE != "" ? this.m_featureManager.FEATURE_END_DATE : this.m_endDate;
            this.m_cash = this.m_featureManager ? this.m_featureManager.dartItemCost : this.DEFAULT_NEW_MG_DART_COST;
            m_consumable_dart_item_name = this.m_featureManager.REWARD_ITEM_NAME;
         }
         else if(IN_LOOT_TABLE_VARIANT)
         {
            m_dialogAsset = NEW_MYSTERY_GAME_URL;
            this.m_miniGames = Global.player.miniGames[MASTER_LOOT_TABLE];
            this.m_gameTokenName = MASTER_LOOT_TABLE;
            this.m_cash = this.DEFAULT_DART_COST;
         }
         else
         {
            this.m_gameObject = Global.farmGameSettingsManager.getFarmItemByName(gameTokenName);
            if(this.m_gameObject)
            {
               this.m_cash = this.m_gameObject.cash;
            }
            this.m_miniGames = Global.player.miniGames[gameTokenName];
            this.m_gameTokenName = gameTokenName;
         }
         this.m_dartConsumable = dartConsumable;
         this.m_showDartCount = this.m_dartConsumable ? true : false;
         this.m_enteringViaMarket = enteringViaMarket;
         this.m_rewardItemsArray = [null,null,null,null,null,null];
         this.m_itemPricesArray = [0,0,0,0,0,0];
         this.m_escapable = false;
         this.m_open = false;
         this.m_MouseShow = true;
         super(true);
      }
      
      public static function openDefaultMysteryGame(gameTokenName:String = null, throughInterstitial:Boolean = false) : void
      {
         var items:Array = null;
         var item:FarmItem = null;
         if(gameTokenName == null)
         {
            if(MiniDartsManager.getInstance().isFeatureActive())
            {
               gameTokenName = REVAMP_LOOT_TABLE;
            }
            else if(IN_LOOT_TABLE_VARIANT)
            {
               gameTokenName = MASTER_LOOT_TABLE;
            }
            else
            {
               items = Global.farmGameSettingsManager.getFarmItemsArray(FarmGameSettingsManager.TYPE_GAME_TOKEN);
               if(Boolean(items) && items.length > 0)
               {
                  for each(item in items)
                  {
                     if(item.isMysteryItem && item.checkDateGate())
                     {
                        gameTokenName = item.name;
                        break;
                     }
                  }
               }
            }
         }
         if(gameTokenName)
         {
            UI.displayPopup(new MysteryBoxBalloonDialog(gameTokenName,getValidDartConsumableFromGiftbox(gameTokenName),throughInterstitial),true);
         }
      }
      
      public static function hasWonCurrent() : Boolean
      {
         var item:FarmItem = null;
         var wonItems:Array = null;
         var i:int = 0;
         var hasWon:Boolean = false;
         var items:Array = Global.farmGameSettingsManager.getFarmItemsArray(FarmGameSettingsManager.TYPE_GAME_TOKEN);
         if(Boolean(items) && items.length > 0)
         {
            for each(item in items)
            {
               if(item.isMysteryItem)
               {
                  if(Boolean(Global.player.miniGames) && Global.player.miniGames.hasOwnProperty(item.name))
                  {
                     wonItems = Global.player.miniGames[item.name].wonItems;
                     for(i = 0; i < wonItems.length; i++)
                     {
                        if(wonItems[i] > 0)
                        {
                           hasWon = true;
                           break;
                        }
                     }
                  }
               }
            }
         }
         return hasWon;
      }
      
      private static function getValidDartConsumableFromGiftbox(gameTokenName:String = null) : Object
      {
         var index:int = 0;
         var result:Object = null;
         if(gameTokenName == REVAMP_LOOT_TABLE)
         {
            result = new CMysteryBoxGameDartAutoConsumable(m_consumable_dart_item_name);
         }
         else
         {
            while(!result && index < CONSUMABLE_DART_ITEM_NAMES.length)
            {
               if(Global.player.getGiftCountForItem(CONSUMABLE_DART_ITEM_NAMES[index]) > 0)
               {
                  result = new CMysteryBoxGameDart(CONSUMABLE_DART_ITEM_NAMES[index]);
               }
               index++;
            }
         }
         return result;
      }
      
      public static function getCurrentTokenName() : String
      {
         var farmItem:FarmItem = Global.farmGameSettingsManager.findCurrentMysteryGame();
         return farmItem ? farmItem.name : null;
      }
      
      private function getMoneyMC(tileIndex:int) : MovieClip
      {
         var result:MovieClip = null;
         if(Boolean(this.m_tileArray[tileIndex]) && Boolean(this.m_tileArray[tileIndex].hasOwnProperty("money_mc")))
         {
            result = this.m_tileArray[tileIndex].money_mc as MovieClip;
         }
         if(Boolean(!result) && Boolean(this.m_tileArray[tileIndex]) && Boolean(this.m_tileArray[tileIndex].hasOwnProperty("rebuycost_mc")))
         {
            result = this.m_tileArray[tileIndex].rebuycost_mc as MovieClip;
         }
         return result;
      }
      
      private function setCostVisibility(tileIndex:int, visible:Boolean) : void
      {
         var moneyMC:MovieClip = this.getMoneyMC(tileIndex);
         moneyMC.visible = visible;
      }
      
      override protected function onLoadComplete() : void
      {
         var genButton:CustomMouseButton = null;
         var toaster:MovieClip = null;
         super.onLoadComplete();
         this.m_open = true;
         if(!this.m_isRevampGame)
         {
            ZLocUtils.setText(m_window,"title_tf","Dialogs","MysteryBoxGameTitle");
            ZLocUtils.setText(m_window,"rightPanelPlay_mc.playButton_mc.generic_tf","Dialogs","MysteryBoxGameFreeGameButton");
            if(this.m_usingRefreshedUI)
            {
               ZLocUtils.setText(m_window,"rightPanelPlay_mc.instructions_tf","Dialogs","FV_mysteryGame_buy.key5");
            }
            else
            {
               ZLocUtils.setText(m_window,"rightPanelPlay_mc.instructions_tf","Dialogs","FV_mysteryGame_buy.key2");
            }
            if(m_window.rightPanelPlay_mc.instructions2_tf)
            {
               ZLocUtils.setText(m_window,"rightPanelPlay_mc.instructions2_tf","Dialogs","FV_mysteryGame_buy.key3");
            }
            if(m_window.panel_0.cardBackground_mc)
            {
               ZLocUtils.setText(m_window,"panel_0.cardBackground_mc.generic_tf","Dialogs","FV_mysteryGame_buy.key4");
               ZLocUtils.setText(m_window,"panel_1.cardBackground_mc.generic_tf","Dialogs","FV_mysteryGame_buy.key4");
               ZLocUtils.setText(m_window,"panel_2.cardBackground_mc.generic_tf","Dialogs","FV_mysteryGame_buy.key4");
               ZLocUtils.setText(m_window,"panel_3.cardBackground_mc.generic_tf","Dialogs","FV_mysteryGame_buy.key4");
               ZLocUtils.setText(m_window,"panel_4.cardBackground_mc.generic_tf","Dialogs","FV_mysteryGame_buy.key4");
               ZLocUtils.setText(m_window,"panel_5.cardBackground_mc.generic_tf","Dialogs","FV_mysteryGame_buy.key4");
            }
            ZLocUtils.setText(m_window,"subHead_txt","Dialogs","MysteryBoxGameSetCollectionInfo",{"quantity":TILE_COUNT});
            if(IN_LOOT_TABLE_VARIANT)
            {
               ZLocUtils.setText(m_window,"subHead_txt","Dialogs","MysteryBoxGameSetCollectionInfoV2",{"quantity":TILE_COUNT});
            }
            if(m_window.rightPanelReward_mc)
            {
               ZLocUtils.setText(m_window,"rightPanelReward_mc.youWin_tf","Dialogs","MysteryBoxGameYouWin");
               ZLocUtils.setText(m_window,"rightPanelReward_mc.playAgain_tf","Dialogs","GiftboxFind");
            }
            if(m_window.moreInfo_bt.generic_tf)
            {
               ZLocUtils.setText(m_window,"moreInfo_bt.generic_tf","Dialogs","WhatIsThis");
            }
            ZLocUtils.setText(m_window,"rightPanel_mc.freePlay_tf","Dialogs","MysteryBoxGameFreePlay");
         }
         else
         {
            this.setZlocText();
         }
         if(!this.m_isRevampGame || !IN_LOOT_TABLE_VARIANT)
         {
            if(m_window.prize_mc)
            {
               m_window.prize_mc.visible = false;
            }
            if(m_window.prizename_txt)
            {
               m_window.prizename_txt.visible = false;
            }
            if(m_window.free_tf)
            {
               m_window.free_tf.visible = false;
            }
         }
         if(this.m_isRevampGame)
         {
            if(m_window.rightPanel_mc.freePlay_tf)
            {
               this.m_freeplay = m_window.rightPanel_mc.freePlay_tf;
               this.m_freeplay.visible = false;
            }
            if(m_window.rightPanel_mc.dartCount_mc)
            {
               this.m_dartCount = m_window.rightPanel_mc.dartCount_mc;
               this.m_dartCount.visible = false;
            }
         }
         else
         {
            m_window.rightPanel_mc.freePlay_tf.visible = false;
            m_window.rightPanel_mc.dartCost_mc.visible = false;
         }
         this.m_buyButtonArray = new Array();
         this.m_tileArray = new Array();
         this.m_tileTitlesArray = new Array();
         this.m_tileStatesArray = new Array();
         this.m_itemPricesArray = new Array();
         var rare:String = ZLocUtils.t("Dialogs","MysteryBoxGameRare");
         var uncommon:String = ZLocUtils.t("Dialogs","MysteryBoxGameUncommon");
         var common:String = ZLocUtils.t("Dialogs","MysteryBoxGameCommon");
         this.m_tileTitlesArray = [rare,rare,uncommon,uncommon,common,common];
         for(var tile_idx:int = 0; tile_idx < TILE_COUNT; tile_idx++)
         {
            if(m_window["panel_" + tile_idx])
            {
               this.m_tileArray.push(m_window["panel_" + tile_idx]);
               if(IN_LOOT_TABLE_VARIANT || this.m_isRevampGame)
               {
                  this.m_tileArray[tile_idx].visible = true;
               }
               else
               {
                  this.m_tileArray[tile_idx].visible = false;
               }
               this.setCostVisibility(tile_idx,false);
               genButton = this.getBuyButtonForSlot(tile_idx);
               this.m_buyButtonArray.push(genButton);
            }
         }
         if(this.m_usingRefreshedUI || this.m_isRevampGame)
         {
            this.m_loaderScreen = m_window.loader_mc;
            if(!IN_LOOT_TABLE_VARIANT || !this.m_isRevampGame)
            {
               if(m_window.prize_mc)
               {
                  m_window.prize_mc.visible = true;
               }
               if(m_window.prizename_txt)
               {
                  m_window.prizename_txt.visible = true;
               }
               if(m_window.free_tf)
               {
                  m_window.free_tf.visible = true;
               }
            }
            if(m_window.rightPanel_mc.dartsLeft_tf)
            {
               m_window.rightPanel_mc.dartsLeft_tf.visible = false;
            }
         }
         m_window.gameBoard_mc.visible = false;
         TransactionManager.addTransaction(new TGetMysteryLoot(this,this.m_gameTokenName),true);
         this.m_whatIsThis = new GenericButton(m_window.moreInfo_bt,this.onWhatIsThisClick);
         this.m_crosshair = m_window.crosshair_mc;
         Utilities.toggleInputOnlySelf(this.m_crosshair,false);
         this.m_crosshair.visible = false;
         if(this.m_usingRefreshedUI || this.m_isRevampGame)
         {
            this.m_rightPanelPlay = m_window.rightPanelPlay_mc;
            this.m_rewardPanelFrame = m_window.youWin_mc;
            this.m_rewardPanel = m_window.youWin_mc.rightPanelReward_mc;
            this.m_rewardedItem = m_window.youWin_mc.rightPanelReward_mc.icon_mc;
            this.m_rewardPanelFrame.gotoAndStop(REWARD_FRAME_HIDE);
         }
         else
         {
            this.m_rightPanelPlay = m_window.rightPanelPlay_mc;
            this.m_rightPanelPlay.visible = false;
            this.m_rewardPanel = m_window.rightPanelReward_mc;
            this.m_rewardPanel.visible = false;
            this.m_rewardedItem = m_window.icon_mc;
            this.m_rewardedItem.visible = false;
         }
         if(!this.m_isRevampGame)
         {
            this.m_playButton = new GenericButton(this.m_rightPanelPlay.playButton_mc,this.onPlayClick);
            this.m_playButton.turnOff(false);
            this.m_playAgainButton = new GenericButton(this.m_rightPanelPlay.playAgainButton_mc,this.onPlayClick);
            if(this.m_usingRefreshedUI)
            {
               this.m_playAgainButton.disabled = true;
               this.m_playAgainButton.useGrayOnDisabled = true;
            }
            else
            {
               this.m_playAgainButton.turnOff(false);
            }
            this.m_cost_tf = m_window.rightPanel_mc.dartCost_mc.cost_tf;
            this.m_cost_tf.text = String(this.m_cash);
         }
         else
         {
            this.setNewGameButtons();
         }
         this.m_purchasedToaster = m_window.hasOwnProperty("purchasedToaster_mc") ? m_window.purchasedToaster_mc : null;
         if(this.m_purchasedToaster)
         {
            toaster = this.m_purchasedToaster;
            this.m_initialToasterY = toaster.y;
            this.m_purchasedToaster.visible = false;
            if(this.m_purchasedToaster.hasOwnProperty("hitbox_mc"))
            {
               this.m_purchasedToaster.hitbox_mc.visible = false;
               this.m_purchasedToaster.hitbox_mc.mouseEnabled = false;
            }
            this.m_purchasedToaster.toasterclose_bt.addEventListener(MouseEvent.CLICK,this.onCloseToasterClick);
         }
         this.m_messageCount = 0;
         this.syncDisplayedCash();
         m_window.x += this.m_windowOffsetX;
         m_window.y += this.m_windowOffsetY;
         FarmStatsManager.count("fv_mysterygame","open");
      }
      
      private function setZlocText() : void
      {
         if(m_window.title_tf)
         {
            ZLocUtils.setText(m_window,"title_tf","Dialogs","minidarts_revamp_title");
         }
         if(m_window.timer1_tf)
         {
            ZLocUtils.setText(m_window,"timer1_tf","Dialogs","minidarts_revamp_footnote",{"time":this.getExpiryDateText()});
         }
         if(m_window.timer_mc)
         {
            m_window.timer_mc.visible = false;
         }
         if(m_window.rightPanelPlay_mc)
         {
            if(m_window.rightPanelPlay_mc.instructions_tf)
            {
               ZLocUtils.setText(m_window,"rightPanelPlay_mc.instructions_tf","Dialogs","minidarts_revamp_body");
            }
         }
         ZLocUtils.setText(m_window,"rightPanelPlay_mc.playButton_mc.generic_tf","Dialogs","MysteryBoxGameFreeGameButton");
      }
      
      private function setNewGameButtons() : void
      {
         var featureLastShown:Number = NaN;
         var timeRemaining:Number = NaN;
         var shouldShow:Boolean = false;
         if(m_window.mask_mc)
         {
            (m_window.mask_mc as MovieClip).mouseEnabled = false;
            (m_window.mask_mc as MovieClip).mouseChildren = false;
         }
         if(m_window.youWin_mc)
         {
            (m_window.youWin_mc as MovieClip).mouseEnabled = false;
            (m_window.youWin_mc as MovieClip).mouseChildren = false;
         }
         if(m_window.rightPanelPlay_mc.playButton_mc)
         {
            this.m_newPlayButton = new GenericButton(this.m_rightPanelPlay.playButton_mc,this.onNewPlayClick);
            this.m_newPlayButton.useGrayOnDisabled = true;
            if(this.canPlay() == PLAY_FAIL || this.canPlay() == PLAY_CASH)
            {
               this.m_newPlayButton.disabled = true;
            }
            else
            {
               this.m_newPlayButton.disabled = false;
            }
         }
         if(m_window.rightPanelPlay_mc.asktoken_bt)
         {
            this.m_askTokenButton = new CustomMouseButton(this.m_rightPanelPlay.asktoken_bt,this.onAskButtonClick,function(e:MouseEvent):void
            {
               onAskBtnTooltipToggle(true);
            },function(e:MouseEvent):void
            {
               onAskBtnTooltipToggle();
            });
            this.m_askTokenButton.mouseOverEnabled = true;
            featureLastShown = Global.player.getFeatureLastShown(this.m_featureManager.ASK_FEED_FREQUENCY_KEY);
            timeRemaining = Math.round(GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - featureLastShown);
            shouldShow = timeRemaining >= this.m_featureManager.ASK_FEED_FREQUENCY;
            this.m_askTokenButton.useGrayOnDisabled = true;
            this.m_askTokenButton.disabled = !shouldShow;
            if(Boolean(m_window.rightPanelPlay_mc.toolTip_mc) && Boolean(m_window.rightPanelPlay_mc.toolTip_mc.toolTip_tf))
            {
               m_window.rightPanelPlay_mc.toolTip_mc.visible = false;
               m_window.rightPanelPlay_mc.toolTip_mc.toolTip_tf.text = ZLocUtils.t("Dialogs","minidarts_revamp_askbtn_hover");
            }
         }
         if(this.m_rightPanelPlay.helpcounter_mc)
         {
            this.m_helpCounter = this.m_rightPanelPlay.helpcounter_mc;
            this.displayHelpCounter();
         }
         if(this.m_rightPanelPlay.buyDart_bt)
         {
            this.m_buyDartButton = new GenericButton(this.m_rightPanelPlay.buyDart_bt,this.onBuyDartClick);
            this.m_buyDartButton.useGrayOnDisabled = true;
            if(Boolean(this.m_rightPanelPlay.buyDart_bt) && Boolean(this.m_rightPanelPlay.buyDart_bt.amount_tf))
            {
               this.m_rightPanelPlay.buyDart_bt.amount_tf.text = this.m_cash;
            }
         }
         this.enableBuyDartButton();
         this.startTimer();
      }
      
      private function displayHelpCounter(val:int = 0) : void
      {
         var indx:int = 0;
         var counter:MovieClip = null;
         if(this.m_helpCounter)
         {
            for(indx = 0; indx < TOTAL_HELPERS; indx++)
            {
               counter = this.m_helpCounter["helpcount_mc_" + indx];
               if(Boolean(counter) && Boolean(counter.on_mc))
               {
                  if(indx < val)
                  {
                     counter.on_mc.visible = true;
                  }
                  else
                  {
                     counter.on_mc.visible = false;
                  }
               }
            }
         }
      }
      
      private function onAskButtonClick(evt:MouseEvent) : void
      {
         if(this.m_askTokenButton)
         {
            this.m_askTokenButton.disabled = true;
            Global.player.setFeatureLastShown(this.m_featureManager.ASK_FEED_FREQUENCY_KEY,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,false);
         }
         if(this.m_featureManager)
         {
            this.m_featureManager.askForCurrencyItem();
            FarmStatsManager.count("click","ask","DARTGAMEv2","","",this.m_currentFarm);
         }
      }
      
      private function turnOnDartCountRefreshedUI() : void
      {
         m_window.rightPanel_mc.dartCost_mc.visible = false;
         m_window.rightPanel_mc.dartsLeft_tf.visible = true;
         m_window.rightPanel_mc.dartsLeft_tf.text = ZLocUtils.t("Dialogs","MysteryBoxGameDartsLeft",{"quantity":this.inventoryDartCount()});
      }
      
      private function toggleDartCountDisplayText(toggle:Boolean = true) : void
      {
         this.m_freeplay.visible = !toggle;
         this.m_dartCount.visible = toggle;
         if(toggle && Boolean(this.m_dartCount.count_tf))
         {
            this.m_dartCount.count_tf.text = this.inventoryDartCount().toString();
         }
      }
      
      private function updateRightPanelElements(showFreePlay:Boolean) : void
      {
         if(this.m_isRevampGame)
         {
            if(showFreePlay)
            {
               this.toggleDartCountDisplayText(this.checkShouldDisplayDartCount());
            }
            else
            {
               this.toggleDartCountDisplayText(true);
            }
         }
         else if(this.m_usingRefreshedUI)
         {
            if(showFreePlay == true)
            {
               if(this.checkShouldDisplayDartCount())
               {
                  this.turnOnDartCountRefreshedUI();
               }
               else
               {
                  m_window.rightPanel_mc.freePlay_tf.visible = true;
                  m_window.rightPanel_mc.dartCost_mc.visible = false;
                  m_window.rightPanel_mc.dartsLeft_tf.visible = false;
               }
            }
            else
            {
               m_window.rightPanel_mc.freePlay_tf.visible = false;
               if(this.checkShouldDisplayDartCount())
               {
                  this.turnOnDartCountRefreshedUI();
               }
               else
               {
                  m_window.rightPanel_mc.dartCost_mc.visible = true;
                  m_window.rightPanel_mc.dartsLeft_tf.visible = false;
               }
            }
         }
         else if(showFreePlay == true)
         {
            if(this.checkShouldDisplayDartCount())
            {
               m_window.rightPanel_mc.freePlay_tf.text = ZLocUtils.t("Dialogs","MysteryBoxGameDartsLeft",{"quantity":this.inventoryDartCount()});
            }
            m_window.rightPanel_mc.freePlay_tf.visible = true;
            m_window.rightPanel_mc.dartCost_mc.visible = false;
         }
         else if(this.checkShouldDisplayDartCount())
         {
            m_window.rightPanel_mc.freePlay_tf.text = ZLocUtils.t("Dialogs","MysteryBoxGameDartsLeft",{"quantity":this.inventoryDartCount()});
            m_window.rightPanel_mc.freePlay_tf.visible = true;
            m_window.rightPanel_mc.dartCost_mc.visible = false;
         }
         else
         {
            m_window.rightPanel_mc.freePlay_tf.visible = false;
            m_window.rightPanel_mc.dartCost_mc.visible = true;
         }
      }
      
      private function checkShouldDisplayDartCount() : Boolean
      {
         return this.inventoryDartCount() > 0 && this.m_showDartCount;
      }
      
      private function onCloseToasterClick(e:Event) : void
      {
         this.m_purchasedToaster.visible = false;
      }
      
      private function getBuyButtonForSlot(idx:Number) : CustomMouseButton
      {
         var buyMC:MovieClip = null;
         buyMC = m_window["buy_" + idx];
         var onBuyClick:Function = this.onBuyClickFactory(idx);
         var genButton:CustomMouseButton = new CustomMouseButton(buyMC,onBuyClick,function(e:MouseEvent):void
         {
            setCostVisibility(idx,true);
         },function(e:MouseEvent):void
         {
            setCostVisibility(idx,false);
         });
         genButton.text = ZLocUtils.t("Dialogs","Buy");
         genButton.turnOff(false);
         return genButton;
      }
      
      private function getInitStates() : void
      {
         var newInfoWindow:MysteryGameInfoWindow = null;
         var dataIdx:int = 0;
         var tileDataIdx:int = 0;
         var initIdx:int = 0;
         var tileInitIdx:int = 0;
         this.m_balloonArray = new Array();
         for(var idx:int = 0; idx < BALLOON_COUNT; idx++)
         {
            this.m_balloonArray.push(m_window.gameBoard_mc["target_" + idx]);
         }
         if(!this.m_isRevampGame && (Global.player.getSeenFlag(SEEN_FLAG_COLLECTION_INFO) == false || IN_LOOT_TABLE_VARIANT && Global.player.getSeenFlag(SEEN_FLAG_NEW_COLLECTION_INFO) == false))
         {
            newInfoWindow = new MysteryGameInfoWindow();
            UI.displayPopup(newInfoWindow,false);
            Global.player.setSeenFlag(SEEN_FLAG_COLLECTION_INFO);
            if(IN_LOOT_TABLE_VARIANT)
            {
               Global.player.setSeenFlag(SEEN_FLAG_NEW_COLLECTION_INFO);
            }
         }
         var hasFreeGame:Boolean = this.checkForFreeGame();
         this.m_wasFreeGame = hasFreeGame;
         if(hasFreeGame && this.m_enteringViaMarket)
         {
            if(!this.m_isRevampGame)
            {
               this.popFreeGameDialog();
            }
         }
         this.updateRightPanelElements(hasFreeGame);
         if(this.m_isRevampGame)
         {
            this.setBalloonStates();
         }
         else if(this.m_miniGames == null && Global.player.mysteryBox2TargetStates.length == 0)
         {
            if(hasFreeGame == false && !IN_LOOT_TABLE_VARIANT && !this.m_isRevampGame)
            {
               this.popWhatIsMessage();
            }
            for(dataIdx = 0; dataIdx < BALLOON_COUNT; dataIdx++)
            {
               Global.player.mysteryBox2TargetStates.push(TARGET_STATE_UNPOPPED);
            }
            for(tileDataIdx = 0; tileDataIdx < TILE_COUNT; tileDataIdx++)
            {
               Global.player.mysteryBox2TileStates.push(TILE_STATE_NOT_WON);
            }
         }
         else if(!Global.player.isMysteryGameInitialized)
         {
            for(initIdx = 0; initIdx < BALLOON_COUNT; initIdx++)
            {
               if(Boolean(this.m_miniGames) && Boolean(this.m_miniGames.board))
               {
                  if(this.m_initResults["resetBoard"])
                  {
                     Global.player.mysteryBox2TargetStates.push(TARGET_STATE_UNPOPPED);
                  }
                  else
                  {
                     Global.player.mysteryBox2TargetStates.push(this.m_miniGames.board[initIdx]);
                  }
               }
               else if(Boolean(this.m_miniGames) && Boolean(this.m_miniGames.m_board))
               {
                  if(this.m_initResults["resetBoard"])
                  {
                     Global.player.mysteryBox2TargetStates.push(TARGET_STATE_UNPOPPED);
                  }
                  else
                  {
                     Global.player.mysteryBox2TargetStates.push(this.m_miniGames.m_board[initIdx]);
                  }
               }
            }
            for(tileInitIdx = 0; tileInitIdx < TILE_COUNT; tileInitIdx++)
            {
               if(this.m_miniGames)
               {
                  if(IN_LOOT_TABLE_VARIANT)
                  {
                     if(Boolean(this.m_initResults[tileInitIdx]) && this.m_initResults[tileInitIdx].won != true)
                     {
                        Global.player.mysteryBox2TileStates.push(TILE_STATE_NOT_WON);
                     }
                     else
                     {
                        Global.player.mysteryBox2TileStates.push(TILE_STATE_WON);
                     }
                  }
                  else if(Boolean(this.m_initResults[tileInitIdx]) && this.m_initResults[tileInitIdx].itemName == null)
                  {
                     Global.player.mysteryBox2TileStates.push(TILE_STATE_NOT_WON);
                  }
                  else
                  {
                     Global.player.mysteryBox2TileStates.push(TILE_STATE_WON);
                  }
               }
            }
            Global.player.isMysteryGameInitialized = true;
         }
      }
      
      private function setBalloonStates() : void
      {
         var dataIdx:int = 0;
         var tileDataIdx:int = 0;
         var initIdx:int = 0;
         if(!this.m_miniGames)
         {
            this.setMiniGameData();
         }
         if(Boolean(this.m_miniGames == null) && Boolean(this.m_mysteryBox2TargetStates) && this.m_mysteryBox2TargetStates.length == 0)
         {
            for(dataIdx = 0; dataIdx < BALLOON_COUNT; dataIdx++)
            {
               this.m_mysteryBox2TargetStates.push(TARGET_STATE_UNPOPPED);
            }
            for(tileDataIdx = 0; tileDataIdx < TILE_COUNT; tileDataIdx++)
            {
               this.m_mysteryBox2TargetStates.push(TILE_STATE_NOT_WON);
            }
         }
         else
         {
            this.m_mysteryBox2TargetStates = new Array();
            this.m_mysteryBox2TileStates = new Array();
            for(initIdx = 0; initIdx < BALLOON_COUNT; initIdx++)
            {
               if(Boolean(this.m_miniGames) && Boolean(this.m_miniGames.board))
               {
                  if(this.m_initResults["resetBoard"])
                  {
                     this.m_mysteryBox2TargetStates.push(TARGET_STATE_UNPOPPED);
                  }
                  else
                  {
                     this.m_mysteryBox2TargetStates.push(this.m_miniGames.board[initIdx]);
                  }
               }
               else if(Boolean(this.m_miniGames) && Boolean(this.m_miniGames.m_board))
               {
                  if(this.m_initResults["resetBoard"])
                  {
                     this.m_mysteryBox2TargetStates.push(TARGET_STATE_UNPOPPED);
                  }
                  else
                  {
                     this.m_mysteryBox2TargetStates.push(this.m_miniGames.m_board[initIdx]);
                  }
               }
            }
         }
         for(var tileInitIdx:int = 0; tileInitIdx < TILE_COUNT; tileInitIdx++)
         {
            if(this.m_initResults)
            {
               if(Boolean(this.m_initResults[tileInitIdx]) && this.m_initResults[tileInitIdx].won != true)
               {
                  this.m_mysteryBox2TileStates.push(TILE_STATE_NOT_WON);
               }
               else
               {
                  this.m_mysteryBox2TileStates.push(TILE_STATE_WON);
               }
            }
         }
      }
      
      private function enableBalloons() : void
      {
         var idx:int = 0;
         if(this.m_isRevampGame)
         {
            for(idx = 0; idx < BALLOON_COUNT; idx++)
            {
               if(this.m_mysteryBox2TargetStates[idx] == TARGET_STATE_UNPOPPED)
               {
                  this.m_balloonArray[idx].buttonMode = true;
                  this.m_balloonArray[idx].addEventListener(MouseEvent.CLICK,this.onBalloonClick);
               }
            }
         }
         else
         {
            for(idx = 0; idx < BALLOON_COUNT; idx++)
            {
               if(Global.player.mysteryBox2TargetStates[idx] == TARGET_STATE_UNPOPPED)
               {
                  this.m_balloonArray[idx].buttonMode = true;
                  this.m_balloonArray[idx].addEventListener(MouseEvent.CLICK,this.onBalloonClick);
               }
            }
         }
      }
      
      private function disableBalloons() : void
      {
         for(var idx:int = 0; idx < BALLOON_COUNT; idx++)
         {
            this.m_balloonArray[idx].buttonMode = false;
            this.m_balloonArray[idx].removeEventListener(MouseEvent.CLICK,this.onBalloonClick);
         }
      }
      
      private function resetGameBoard() : void
      {
         for(var idx:int = 0; idx < BALLOON_COUNT; idx++)
         {
            this.m_balloonArray[idx].gotoAndStop(BALLOON_FULL_FRAMENUM);
         }
      }
      
      private function setGameBoardState() : void
      {
         var idx:int = 0;
         if(this.m_isRevampGame)
         {
            for(idx = 0; idx < BALLOON_COUNT; idx++)
            {
               if(this.m_mysteryBox2TargetStates[idx] == TARGET_STATE_POPPED)
               {
                  this.m_balloonArray[idx].gotoAndStop(GIFT_UNWRAP_FRAMENUM);
               }
               else
               {
                  this.m_balloonArray[idx].gotoAndStop(BALLOON_FULL_FRAMENUM);
               }
            }
         }
         else
         {
            for(idx = 0; idx < BALLOON_COUNT; idx++)
            {
               if(Global.player.mysteryBox2TargetStates[idx] == TARGET_STATE_POPPED)
               {
                  this.m_balloonArray[idx].gotoAndStop(BALLOON_POPPED_FRAMENUM);
               }
               else
               {
                  this.m_balloonArray[idx].gotoAndStop(BALLOON_FULL_FRAMENUM);
               }
            }
         }
         this.enablePlayButton();
      }
      
      private function showRewardDropdown(state:String) : void
      {
         if(this.m_usingRefreshedUI || this.m_isRevampGame)
         {
            if(state == RIGHTPANEL_STATE_PLAY)
            {
               this.setGameBoardState();
               while(this.m_rewardedItem.numChildren)
               {
                  this.m_rewardedItem.removeChildAt(0);
               }
               this.m_rewardPanelFrame.gotoAndPlay(REWARD_FRAME_OUTRO);
            }
            else if(state == RIGHTPANEL_STATE_REWARD)
            {
               if(this.m_playButton)
               {
                  this.m_playButton.turnOff(false);
               }
               this.m_rewardPanelFrame.gotoAndPlay(REWARD_FRAME_INTRO);
               if(this.m_isRevampGame && Boolean(this.m_newPlayButton))
               {
                  this.m_newPlayButton.disabled = true;
               }
            }
         }
         else if(state == RIGHTPANEL_STATE_PLAY)
         {
            this.m_rightPanelPlay.visible = true;
            this.setGameBoardState();
            while(this.m_rewardedItem.numChildren)
            {
               this.m_rewardedItem.removeChildAt(0);
            }
            this.m_rewardedItem.visible = false;
            this.m_rewardPanel.visible = false;
         }
         else if(state == RIGHTPANEL_STATE_REWARD)
         {
            this.m_rightPanelPlay.visible = false;
            if(this.m_playButton)
            {
               this.m_playButton.turnOff(false);
            }
            this.m_rewardedItem.visible = false;
            this.m_rewardPanel.visible = true;
         }
      }
      
      private function addRewardItem(item:FarmItem, index:int) : void
      {
         this.m_rewardItemsArray[index] = item;
         this.addTileIcon(item.icon,index);
      }
      
      private function addRewardIcon(path:String) : void
      {
         var icon:Loader = null;
         var url:String = path;
         icon = LoadingManager.load(url,function(event:Event):void
         {
            if(Boolean(icon) && Boolean(icon.content))
            {
               m_dispObj = icon.content;
               m_dispObj.scaleX = m_dispObj.scaleY = 1;
               m_dispObj.y = 10;
               m_dispObj.x = 0;
               m_rewardedItem.addChild(m_dispObj);
               m_rewardedItem.visible = true;
            }
         });
         this.showPrize();
      }
      
      private function addTileIcon(path:String, idx:int) : void
      {
         var icon:Loader = null;
         var url:String = path;
         icon = LoadingManager.load(url,function(event:Event):void
         {
            var dispObjSmall:* = undefined;
            if(Boolean(icon) && Boolean(icon.content))
            {
               Utilities.removeAllChildren(m_tileArray[idx].icon_mc);
               dispObjSmall = icon.content;
               dispObjSmall.scaleX = dispObjSmall.scaleY = 0.5;
               dispObjSmall.x = dispObjSmall.y = 0;
               m_tileArray[idx].icon_mc.addChild(dispObjSmall);
               m_tileArray[idx].icon_mc.visible = true;
            }
         });
      }
      
      private function setTileStates() : void
      {
         var idx:int = 0;
         if(this.m_isRevampGame)
         {
            for(idx = 0; idx < TILE_COUNT; idx++)
            {
               if(this.m_mysteryBox2TileStates[idx] == TILE_STATE_NOT_WON)
               {
                  this.setItemSlotState(idx,false);
               }
               else if(this.m_mysteryBox2TileStates[idx] == TILE_STATE_WON)
               {
                  this.setItemSlotState(idx,true);
               }
            }
         }
         else
         {
            for(idx = 0; idx < TILE_COUNT; idx++)
            {
               if(Global.player.mysteryBox2TileStates[idx] == TILE_STATE_NOT_WON)
               {
                  this.setItemSlotState(idx,false);
               }
               else if(Global.player.mysteryBox2TileStates[idx] == TILE_STATE_WON)
               {
                  this.setItemSlotState(idx,true);
               }
            }
         }
      }
      
      private function setItemSlotState(idx:Number, won:Boolean = false) : void
      {
         var itemFriendlyName:String = null;
         var slotMC:MovieClip = this.m_tileArray[idx];
         if(IN_LOOT_TABLE_VARIANT || this.m_isRevampGame)
         {
            if(this.m_rewardItemsArray[idx])
            {
               itemFriendlyName = ZLocUtils.tk_pk_asTitle(this.m_rewardItemsArray[idx].friendlyName);
            }
            else
            {
               itemFriendlyName = this.m_tileTitlesArray[idx];
            }
            slotMC.greenText_tf.text = itemFriendlyName;
            if(slotMC.hasOwnProperty("title"))
            {
               slotMC.title.visible = true;
            }
            if(slotMC.hasOwnProperty("won_mc"))
            {
               slotMC.won_mc.visible = won;
               slotMC.won_mc.won_tf.text = ZLocUtils.t("Dialogs","MysteryBoxGameWon");
            }
            if(slotMC.hasOwnProperty("checkmark_mc"))
            {
               slotMC.checkmark_mc.visible = won;
            }
            slotMC.greenText_tf.visible = true;
            slotMC.greyText_tf.visible = false;
            slotMC.darkBackground_mc.visible = false;
            slotMC.lightBackground_mc.visible = true;
            slotMC.questionMark_mc.visible = false;
            slotMC.icon_mc.visible = true;
            slotMC.visible = true;
         }
         else
         {
            if(won)
            {
               if(this.m_rewardItemsArray[idx])
               {
                  itemFriendlyName = ZLocUtils.tk_pk_asTitle(this.m_rewardItemsArray[idx].friendlyName);
               }
               else
               {
                  itemFriendlyName = this.m_tileTitlesArray[idx];
               }
               slotMC.greenText_tf.text = itemFriendlyName;
            }
            else
            {
               slotMC.greyText_tf.text = this.m_tileTitlesArray[idx];
            }
            if(slotMC.hasOwnProperty("title"))
            {
               slotMC.title.visible = won;
            }
            if(slotMC.hasOwnProperty("won_mc"))
            {
               slotMC.won_mc.visible = won;
               slotMC.won_mc.won_tf.text = ZLocUtils.t("Dialogs","MysteryBoxGameWon");
            }
            if(slotMC.hasOwnProperty("checkmark_mc"))
            {
               slotMC.checkmark_mc.visible = won;
            }
            slotMC.greenText_tf.visible = won;
            slotMC.greyText_tf.visible = !won;
            slotMC.darkBackground_mc.visible = !won;
            slotMC.lightBackground_mc.visible = won;
            slotMC.questionMark_mc.visible = !won;
            slotMC.icon_mc.visible = won;
            slotMC.visible = true;
         }
      }
      
      private function addHandlers() : void
      {
         m_window.close_bt.addEventListener(MouseEvent.CLICK,this.onCloseClick);
         if(this.m_isRevampGame)
         {
            Global.stage.addEventListener(MiniDartsManager.MINI_DART_REFRESH_EVENT,this.onRefreshTokens);
         }
      }
      
      private function onRefreshTokens(event:Event) : void
      {
         var totalCount:int = 0;
         var remainingTokens:int = 0;
         if(this.m_featureManager)
         {
            totalCount = this.m_featureManager.getCurrencyCount();
            remainingTokens = totalCount % MiniDartsManager.TOTAL_TOKEN_COUNT;
            this.displayHelpCounter(remainingTokens);
         }
      }
      
      private function syncDisplayedCash() : void
      {
         if(m_window.hasOwnProperty("fcValue_tf"))
         {
            m_window.fcValue_tf.text = Utilities.formatNumber(Global.player.cash);
         }
      }
      
      private function deductCash() : void
      {
         this.disableCloseButton();
         if(this.checkForFreeGame() == false && this.m_dartConsumable == null)
         {
            Global.player.cash -= this.m_cash;
            FarmStatsManager.count("fv_mysterygame","dartpurchased");
            this.syncDisplayedCash();
         }
      }
      
      private function disableCloseButton() : void
      {
         m_window.close_bt.removeEventListener(MouseEvent.CLICK,this.onCloseClick);
         m_window.close_bt.visible = false;
      }
      
      private function enableBuyDartButton(toggle:Boolean = true) : void
      {
         if(this.m_buyDartButton)
         {
            this.m_buyDartButton.disabled = !toggle;
         }
      }
      
      public function enableCloseButton() : void
      {
         m_window.close_bt.addEventListener(MouseEvent.CLICK,this.onCloseClick);
         m_window.close_bt.visible = true;
      }
      
      private function throwDart() : void
      {
         if(this.m_escapable)
         {
            this.disableCloseButton();
         }
         this.m_crosshair.visible = true;
         this.m_crosshair.gotoAndPlay(CROSSHAIR_PLAY_FRAME);
         this.m_crosshair.addEventListener(Event.ENTER_FRAME,this.onCrosshairEnterFrame);
         if(this.m_usingRefreshedUI || this.m_isRevampGame)
         {
            this.m_dropDownTimer = new Timer(REWARD_PANEL_DROP_DELAY_MS,1);
            this.m_dropDownTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.rewardDropDownHandler);
            this.m_dropDownTimer.start();
         }
      }
      
      private function rewardDropDownHandler(event:TimerEvent) : void
      {
         this.m_rewardPanel.spinner_mc.visible = true;
         this.m_rewardPanel.itemTitle_tf.text = "";
         this.m_rewardPanel.multiplier_tf.text = "";
         this.showRewardDropdown(RIGHTPANEL_STATE_REWARD);
         this.m_dropDownTimer.stop();
         this.m_dropDownTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.rewardDropDownHandler);
      }
      
      private function showPrize() : void
      {
         TweenLite.to(this,PRIZE_DISPLAY_DURATION_S,{"onComplete":this.reEnableGame});
      }
      
      private function onCrosshairEnterFrame(evt:Event) : void
      {
         if(this.m_crosshair.currentFrame == this.m_crosshair.totalFrames)
         {
            this.m_crosshair.removeEventListener(Event.ENTER_FRAME,this.onCrosshairEnterFrame);
            this.m_balloonArray[this.m_index].gotoAndPlay(BALLOON_FULL_FRAMENUM);
            this.m_crosshair.visible = false;
         }
      }
      
      private function reEnableGame() : void
      {
         this.m_gameState = USER_ENTERS_STATE;
         if(!this.m_escapable)
         {
            this.enableCloseButton();
         }
         this.m_whatIsThis.turnOn();
         this.showRewardDropdown(RIGHTPANEL_STATE_PLAY);
         this.m_crosshair.visible = false;
         this.m_crosshair.gotoAndStop(CROSSHAIR_READY_FRAME);
         var hasFreeGame:Boolean = this.checkForFreeGame();
         if(this.m_dartConsumable != null)
         {
            this.m_dartConsumable = null;
         }
         else if(hasFreeGame == true)
         {
            if(!this.m_isRevampGame)
            {
               this.popFreeGameCongratsDialog();
            }
         }
         UI.stopPopups(false);
         if(this.m_escapable && !this.m_wasFreeGame && this.canPlay() != PLAY_FAIL)
         {
            this.enterDartMode();
         }
         this.m_wasFreeGame = hasFreeGame;
         if(this.m_wasFreeGame)
         {
            Global.player.setActionCount(FREE_GAME_DART_COUNTER,0);
         }
         if(this.m_isRevampGame)
         {
            this.enablePlayButton();
         }
         this.updateRightPanelElements(false);
      }
      
      private function onBalloonClick(evt:MouseEvent) : void
      {
         if(this.m_escapable && !this.m_isRevampGame)
         {
            this.deductCash();
         }
         this.useCursor();
         this.disableBalloons();
         this.m_index = int(evt.currentTarget.name.split("_")[1]);
         if(this.m_isRevampGame)
         {
            this.m_mysteryBox2TargetStates[this.m_index] = TARGET_STATE_POPPED;
            if(Boolean(this.m_miniGames) && Boolean(this.m_miniGames.m_board))
            {
               this.m_miniGames.m_board[this.m_index] = TARGET_STATE_POPPED;
            }
            else if(Boolean(this.m_miniGames) && Boolean(this.m_miniGames.board))
            {
               this.m_miniGames.board[this.m_index] = TARGET_STATE_POPPED;
            }
            if(this.m_miniGames)
            {
               Global.player.miniGames[REVAMP_LOOT_TABLE] = this.m_miniGames;
            }
         }
         else
         {
            Global.player.mysteryBox2TargetStates[this.m_index] = TARGET_STATE_POPPED;
         }
         if(this.shouldUseDartConsumable())
         {
            if(this.m_isRevampGame)
            {
               TransactionManager.addTransaction(new TUseMysteryBoxDartAutoConsumable(this.m_dartConsumable as CMysteryBoxGameDartAutoConsumable,this,this.m_index),true);
            }
            else
            {
               TransactionManager.addTransaction(new TUseMysteryBoxDartConsumable(this.m_dartConsumable as CMysteryBoxGameDart,this,this.m_index),true);
            }
         }
         else
         {
            TransactionManager.addTransaction(new TBuyMysteryGiftTurn(this.m_index,this,this.m_gameTokenName),true);
         }
         this.throwDart();
      }
      
      private function canPlay() : int
      {
         var iResult:int = PLAY_FAIL;
         var hasFreeGame:Boolean = this.checkForFreeGame();
         if(!hasFreeGame)
         {
            if(this.inventoryDartCount() > 0 && this.m_showDartCount)
            {
               if(this.m_isRevampGame)
               {
                  this.m_dartConsumable = getValidDartConsumableFromGiftbox(REVAMP_LOOT_TABLE);
               }
               else
               {
                  this.m_dartConsumable = getValidDartConsumableFromGiftbox();
               }
            }
            else if(Global.player.canBuyCash(this.m_cash,false))
            {
               this.useCursor();
            }
         }
         if(hasFreeGame)
         {
            iResult = PLAY_FREE;
         }
         else if(this.shouldUseDartConsumable())
         {
            iResult = PLAY_CONSUMABLE;
         }
         else if(Global.player.canBuyCash(this.m_cash,false))
         {
            iResult = PLAY_CASH;
         }
         return iResult;
      }
      
      private function shouldUseDartConsumable() : Boolean
      {
         return this.m_dartConsumable != null && this.inventoryDartCount() > 0;
      }
      
      private function useCrossHairs() : void
      {
         this.m_MouseShow = false;
         Global.stage.addEventListener(MouseEvent.MOUSE_MOVE,this.onWindowMouseMove);
         this.m_crosshair.x = mouseX - this.m_windowOffsetX;
         this.m_crosshair.y = mouseY - this.m_windowOffsetY;
         this.m_crosshair.visible = true;
      }
      
      private function useCursor() : void
      {
         this.m_MouseShow = true;
         Global.stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.onWindowMouseMove);
         Mouse.show();
         this.m_crosshair.visible = false;
         this.m_crosshair.gotoAndStop(CROSSHAIR_READY_FRAME);
      }
      
      private function enterDartMode() : void
      {
         UI.stopPopups(true);
         this.disableBuyButtons(true);
         this.m_gameState = DART_MODE;
         this.enableBalloons();
         if(!this.m_inPopup)
         {
            this.useCrossHairs();
         }
         if(this.m_playButton)
         {
            this.m_playButton.turnOff(false);
         }
         if(this.m_isRevampGame)
         {
            this.m_newPlayButton.disabled = true;
         }
         else if(this.m_usingRefreshedUI)
         {
            this.m_playAgainButton.disabled = true;
         }
         else
         {
            this.m_playAgainButton.turnOff(false);
         }
         this.enableBuyDartButton(false);
         this.m_whatIsThis.turnOff(false);
      }
      
      override public function onCloseClick(evt:MouseEvent) : void
      {
         super.onCloseClick(evt);
         this.close();
      }
      
      private function onConfirmPurchaseClose(genericPopupEvent:GenericPopupEvent) : void
      {
         this.unpause();
         if(genericPopupEvent.button > 0)
         {
            this.confirmPlay();
            if(this.m_usingRefreshedUI)
            {
               this.m_playAgainButton.disabled = false;
            }
            else
            {
               this.m_playAgainButton.turnOn();
            }
         }
      }
      
      private function confirmPlay() : void
      {
         this.enterDartMode();
         if(!this.m_escapable)
         {
            this.disableCloseButton();
            if(!this.m_isRevampGame)
            {
               this.deductCash();
            }
         }
      }
      
      private function onNewPlayClick(evt:MouseEvent) : void
      {
         var balanceDarts:String = null;
         var iPlay:int = this.canPlay();
         if(iPlay == PLAY_CONSUMABLE || iPlay == PLAY_FREE)
         {
            balanceDarts = this.inventoryDartCount().toString();
            FarmStatsManager.count("click","dart_playv2","",balanceDarts,"",this.m_currentFarm);
            this.confirmPlay();
         }
      }
      
      private function onPlayClick(evt:MouseEvent) : void
      {
         this.atMaxGifts();
         var iPlay:int = this.canPlay();
         if(iPlay != PLAY_FAIL)
         {
            if(iPlay == PLAY_CASH && PrerequisiteUtility.checkPrereqByName(PREREQ_MYSTERY_GAME_DISABLE_NON_PAYER_FRICTIONLESS))
            {
               this.pause();
               UI.displayMessage(ZLocUtils.t("Dialogs","MysteryGame_BuyDart_Confirm",{"cost":this.m_cash}),GenericPopup.TYPE_YESNO,this.onConfirmPurchaseClose,"MysteryGameBuyDart",true);
            }
            else
            {
               this.confirmPlay();
            }
         }
      }
      
      private function onBuyDartClick(event:MouseEvent) : void
      {
         UI.displayMessage(ZLocUtils.t("Dialogs","minidarts_revamp_buy_confirm",{"cost":this.m_cash}),GenericPopup.TYPE_YESNO,this.onConfirmBuyDart,"MysteryGameBuyDart",true);
         this.m_buyDartButton.disabled = true;
      }
      
      private function onConfirmBuyDart(genericPopupEvent:GenericPopupEvent) : void
      {
         var farmItem:FarmItem = null;
         var cash:int = 0;
         var canBuy:Boolean = false;
         this.m_buyDartButton.disabled = false;
         if(genericPopupEvent.button > 0)
         {
            farmItem = Global.farmGameSettingsManager.getFarmItemByName(CONSUMABLE_MYSTERY_GAME_REVAMAP_ITEM);
            cash = farmItem.cash;
            canBuy = this.m_featureManager.onBuyDartItem(farmItem.name,cash);
            if(canBuy)
            {
               this.m_newPlayButton.disabled = false;
               this.m_showDartCount = true;
               this.m_dartCount.count_tf.text = this.inventoryDartCount().toString();
            }
         }
      }
      
      private function onSuccessBuyCallBack(result:Object) : void
      {
         if(result)
         {
            if(this.m_dartCount.count_tf)
            {
               this.m_newPlayButton.disabled = false;
               this.m_showDartCount = true;
               this.m_dartCount.count_tf.text = this.inventoryDartCount().toString();
            }
         }
      }
      
      private function updateToaster(idx:Number) : void
      {
         var toaster:MovieClip = null;
         var icon:Loader = null;
         var item:FarmItem = this.m_rewardItemsArray[idx];
         if(item)
         {
            toaster = this.m_purchasedToaster;
            toaster.toastername_tf.text = "";
            icon = LoadingManager.load(item.iconUrl,function(event:Event):void
            {
               var dispObjSmall:* = undefined;
               var fadeOut:* = undefined;
               if(Boolean(icon) && Boolean(icon.content))
               {
                  Utilities.removeAllChildren(toaster.toastericon_mc);
                  dispObjSmall = icon.content;
                  dispObjSmall.scaleX = dispObjSmall.scaleY = 0.75;
                  dispObjSmall.x = dispObjSmall.y = 0;
                  toaster.toastericon_mc.addChild(dispObjSmall);
                  toaster.toastericon_mc.visible = true;
                  toaster.y = m_initialToasterY + 200;
                  toaster.alpha = 0;
                  toaster.visible = true;
                  fadeOut = function(e:Event = null):void
                  {
                     TweenLite.to(toaster,10,{"alpha":0});
                  };
                  TweenLite.to(toaster,3,{
                     "alpha":1,
                     "y":"-100",
                     "onComplete":fadeOut
                  });
               }
            });
         }
      }
      
      private function onBuyClickFactory(idx:Number) : Function
      {
         var parentDialog:MysteryBoxBalloonDialog = null;
         parentDialog = this;
         return function(evt:MouseEvent):void
         {
            if(Global.player.canBuyCash(m_itemPricesArray[idx],true))
            {
               Global.player.mysteryBox2TileStates[idx] = TILE_STATE_WON;
               disableBuyButtons(true);
               if(m_playButton)
               {
                  m_playButton.turnOff(false);
               }
               if(m_isRevampGame)
               {
                  m_newPlayButton.disabled = true;
               }
               else if(m_usingRefreshedUI)
               {
                  m_playAgainButton.disabled = true;
               }
               else
               {
                  m_playAgainButton.turnOff(false);
               }
               TransactionManager.addTransaction(new TBuyMysteryGiftGameItem(idx,parentDialog,m_gameTokenName));
               Global.player.cash -= m_itemPricesArray[idx];
               syncDisplayedCash();
               updateToaster(idx);
               onFinishBuy(idx);
            }
         };
      }
      
      private function disableBuyButtons(disable:Boolean = false) : void
      {
         for(var tile_idx:int = 0; tile_idx < TILE_COUNT; tile_idx++)
         {
            if(disable && Global.player.mysteryBox2TileStates[tile_idx] == TILE_STATE_WON)
            {
               if(this.m_buyButtonArray[tile_idx])
               {
                  this.m_buyButtonArray[tile_idx].disabled = true;
               }
            }
            else if(this.m_buyButtonArray[tile_idx])
            {
               this.m_buyButtonArray[tile_idx].disabled = false;
               this.m_buyButtonArray[tile_idx].turnOff();
            }
         }
      }
      
      private function onWhatIsThisClick(evt:MouseEvent) : void
      {
         this.popWhatIsMessage();
      }
      
      private function popWhatIsMessage() : void
      {
         if(this.m_isRevampGame)
         {
            this.popMessageDialogZLoc("minidarts_revamp_whatIsThis",null,"MysteryBoxGameLetsGo");
         }
         else
         {
            this.popMessageDialogZLoc("MysteryBoxGameWhatIsThis",{"quantity":this.m_cash},"MysteryBoxGameLetsGo");
         }
      }
      
      private function popFreeGameDialog() : void
      {
         if(this.m_isRevampGame)
         {
            this.popMessageDialogZLoc("minidarts_revamp_freeplay_body",null,"PearUp_GameOverAcceptButton");
         }
         else
         {
            this.popMessageDialogZLoc("MysteryBoxGameFreeGameInfo",{"quantity":this.m_cash},"PearUp_GameOverAcceptButton");
         }
      }
      
      private function popFreeGameCongratsDialog() : void
      {
         if(this.m_isRevampGame)
         {
            this.popMessageDialogZLoc("minidarts_revamp_freeplay_congrats_body",null,"MysteryBoxGameLetsGo");
            this.useCursor();
         }
         else
         {
            this.popMessageDialogZLoc("MysteryBoxGameFreeGameCongrats",null,"MysteryBoxGameLetsGo");
         }
      }
      
      private function popNewPrizesDialog() : void
      {
         this.popMessageDialogZLoc("MysteryBoxGameNewPrizes");
      }
      
      private function popMessageDialogZLoc(localeStringName:String, oParams:Object = null, acceptBtnText:String = "") : void
      {
         this.m_inPopup = true;
         this.useCursor();
         this.disableButtonsForOverlayDialog();
         var text:String = ZLocUtils.t("Dialogs",localeStringName,oParams);
         var genPop:GenericPopup = new GenericPopup(text,GenericPopup.TYPE_OK,this.onGenPopClose);
         if(acceptBtnText.length != 0)
         {
            genPop.setAcceptTextName(acceptBtnText);
         }
         Global.stage.addChild(genPop);
         genPop.show();
         this.m_genPop = true;
         ++this.m_messageCount;
      }
      
      public function disableButtonsForOverlayDialog() : void
      {
         if(this.m_playButton)
         {
            this.m_playButton.turnOff(false);
         }
         if(this.m_isRevampGame)
         {
            this.m_newPlayButton.disabled = true;
         }
         else if(this.m_usingRefreshedUI)
         {
            this.m_playAgainButton.disabled = true;
         }
         else
         {
            this.m_playAgainButton.turnOff(false);
         }
         this.disableCloseButton();
      }
      
      public function onGenPopClose(evt:Event) : void
      {
         this.m_inPopup = false;
         this.m_genPop = false;
         --this.m_messageCount;
         if(this.m_messageCount < 0)
         {
            this.m_messageCount = 0;
         }
         if(this.m_messageCount == 0)
         {
            if(this.m_gameState == USER_ENTERS_STATE)
            {
               this.enablePlayButton();
            }
            else if(this.m_inPopup == false)
            {
               this.useCrossHairs();
            }
            this.enableCloseButton();
         }
         this.useCursor();
      }
      
      public function enablePlayButton() : void
      {
         var idx:int = 0;
         var popCount:int = 0;
         var unpopCount:int = 0;
         if(this.m_isRevampGame)
         {
            for(idx = 0; idx < BALLOON_COUNT; idx++)
            {
               if(this.m_mysteryBox2TargetStates[idx] == TARGET_STATE_UNPOPPED)
               {
                  unpopCount++;
               }
               else if(this.m_mysteryBox2TargetStates[idx] == TARGET_STATE_POPPED)
               {
                  popCount++;
               }
            }
         }
         else
         {
            for(idx = 0; idx < BALLOON_COUNT; idx++)
            {
               if(Global.player.mysteryBox2TargetStates[idx] == TARGET_STATE_UNPOPPED)
               {
                  unpopCount++;
               }
               else if(Global.player.mysteryBox2TargetStates[idx] == TARGET_STATE_POPPED)
               {
                  popCount++;
               }
            }
         }
         if(popCount == 0 && unpopCount == BALLOON_COUNT)
         {
            if(this.m_isRevampGame)
            {
               if(this.canPlay() == PLAY_FAIL || this.canPlay() == PLAY_CASH)
               {
                  this.m_newPlayButton.disabled = true;
               }
               else
               {
                  this.m_newPlayButton.disabled = false;
               }
            }
            else if(this.m_playButton)
            {
               this.m_playButton.turnOn();
            }
         }
         else if(popCount == BALLOON_COUNT && unpopCount == 0)
         {
            if(!this.m_isShown || this.m_isRevampGame)
            {
               this.onAllBalloonsPopped();
            }
         }
         else if(this.m_isRevampGame)
         {
            this.m_newPlayButton.disabled = true;
            if(this.checkShouldDisplayDartCount() || this.checkForFreeGame())
            {
               this.m_newPlayButton.disabled = false;
            }
            this.enableBuyDartButton();
         }
         else if(this.m_usingRefreshedUI)
         {
            this.m_playAgainButton.disabled = false;
         }
         else
         {
            this.m_playAgainButton.turnOn();
         }
      }
      
      public function onAllBalloonsPopped() : void
      {
         var miniDartsPopup:MiniDartsPopup = null;
         var popText:String = null;
         var genPop:GenericPopup = null;
         if(this.m_playButton)
         {
            this.m_playButton.turnOff(false);
         }
         if(this.m_isRevampGame)
         {
            this.m_newPlayButton.disabled = true;
         }
         else if(this.m_usingRefreshedUI)
         {
            this.m_playAgainButton.disabled = true;
         }
         else
         {
            this.m_playAgainButton.turnOff(false);
         }
         this.enableBuyDartButton(false);
         this.disableCloseButton();
         if(!this.m_gameFinished)
         {
            this.useCursor();
            if(this.m_isRevampGame)
            {
               miniDartsPopup = new MiniDartsPopup(ZLocUtils.t("Dialogs","minidarts_revamp_finish_body"),GenericPopup.TYPE_OK,this.onGameFinishClicked,GARDEN_OF_GIFT_GAME_COMPLETE_URL);
               Global.stage.addChild(miniDartsPopup);
               miniDartsPopup.show();
               this.enableCloseButton();
               FarmStatsManager.count("View","ingame_popup","BoardCompletion","","",this.m_currentFarm);
            }
            else
            {
               popText = ZLocUtils.t("Dialogs","MysteryBoxGameOver");
               genPop = new GenericPopup(popText,0,this.onMaxGiftClose);
               Global.stage.addChild(genPop);
               genPop.show();
            }
            this.m_inPopup = true;
            this.m_genPop = true;
            this.m_isShown = true;
         }
         this.m_gameFinished = true;
      }
      
      public function onMaxGiftClose(evt:Event) : void
      {
         this.m_inPopup = false;
         this.m_genPop = false;
         this.m_isShown = false;
         this.close();
      }
      
      private function onGameFinishClicked(evt:Event) : void
      {
         this.m_inPopup = false;
         this.m_genPop = false;
         this.m_isShown = false;
         this.setMiniGameData();
         Global.player.miniGames[REVAMP_LOOT_TABLE] = this.m_miniGames;
         this.m_mysteryBox2TargetStates = new Array();
         this.m_mysteryBox2TileStates = new Array();
         MiniDartsManager.getInstance().openMiniDartUI();
         this.close();
      }
      
      private function setMiniGameData() : void
      {
         this.m_miniGames = {};
         this.m_miniGames.board = new Array();
         this.m_miniGames.wonItems = new Array();
         for(var dataIdx:int = 0; dataIdx < BALLOON_COUNT; dataIdx++)
         {
            this.m_miniGames.board[dataIdx] = TARGET_STATE_UNPOPPED;
         }
         for(var tileInitIdx:int = 0; tileInitIdx < TILE_COUNT; tileInitIdx++)
         {
            this.m_miniGames.wonItems[tileInitIdx] = TILE_STATE_NOT_WON;
         }
      }
      
      private function atMaxGifts() : void
      {
         this.m_isMaxGift = !Global.player.hasGiftBoxCapacity();
      }
      
      private function onWindowMouseMove(evt:MouseEvent) : void
      {
         if(!this.m_MouseShow && this.m_open)
         {
            Mouse.hide();
         }
         this.m_crosshair.x = mouseX - this.m_windowOffsetX;
         this.m_crosshair.y = mouseY - this.m_windowOffsetY;
      }
      
      public function onDataReturn(result:Object) : void
      {
         var setBonusItem:FarmItem = null;
         if(this.m_wasFreeGame && !Global.player.getSeenFlag(FREE_DART_MSG_FLAG))
         {
            Global.player.setSeenFlag(FREE_DART_MSG_FLAG);
            if(!this.m_isRevampGame)
            {
               this.showWarningMessage();
            }
            else
            {
               this.showNewWarningMsg();
            }
         }
         this.m_returnedGameData = result;
         var count:int = int(this.m_returnedGameData.quantity);
         for(var idx:int = 0; idx < count; idx++)
         {
            Global.player.addGift(result.itemName);
         }
         if(this.m_isRevampGame)
         {
            this.m_mysteryBox2TileStates[result.mysteryId] = TILE_STATE_WON;
            FeatureOptionsInventoryManager.getInstance().removeCountByName(m_consumable_dart_item_name,1);
         }
         else
         {
            Global.player.mysteryBox2TileStates[result.mysteryId] = TILE_STATE_WON;
         }
         var itemObject:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(result.itemName);
         if(this.m_usingRefreshedUI || this.m_isRevampGame)
         {
            this.m_rewardPanel.spinner_mc.visible = false;
         }
         else
         {
            this.showRewardDropdown(RIGHTPANEL_STATE_REWARD);
         }
         this.addRewardItem(itemObject,result.mysteryId);
         this.addRewardIcon(itemObject.icon);
         this.m_rewardPanel.itemTitle_tf.text = itemObject.friendlyTitle;
         this.m_rewardPanel.multiplier_tf.text = ZLocUtils.t("Dialogs","BuyingMultiple",{"quantity":count});
         this.setTileStates();
         if(result.setBonus != null)
         {
            setBonusItem = Global.farmGameSettingsManager.getFarmItemByName(result.setBonus);
            if(setBonusItem != null)
            {
               this.m_congratsWindow = new MysteryGameCongratsWindow(setBonusItem.iconUrl);
               this.useCursor();
               this.m_congratsWindow.addEventListener(Event.CLOSE,this.onCongratsClose);
               UI.displayPopup(this.m_congratsWindow,false);
               Global.player.addGift(setBonusItem.name);
            }
         }
         if(this.m_escapable)
         {
            this.enableCloseButton();
         }
      }
      
      private function onCongratsClose(event:Event) : void
      {
         this.m_congratsWindow.removeEventListener(Event.CLOSE,this.onCongratsClose);
         if(this.m_escapable && this.m_open)
         {
            this.useCrossHairs();
         }
      }
      
      private function showNewWarningMsg() : void
      {
         var msg:String = ZLocUtils.t("Dialogs","minidarts_revamp_freeplay_body");
         var dialog:GenericXMLDialog = new GenericXMLDialog(null,null,null,null,NaN,NaN,msg,null,false,"Okay",this.onNewWarningMsgClose,null,null,null,GenericXMLDialog.NUM_DIALOG_WIDTH_MEDIUM);
         UI.displayPopup(dialog,false);
      }
      
      private function onNewWarningMsgClose(event:Event) : void
      {
         this.popFreeGameCongratsDialog();
         this.useCursor();
      }
      
      private function showWarningMessage() : void
      {
         var msg:String = ZLocUtils.t("Dialogs","MysteryBoxFreeDartWarning",{"quantity":this.m_cash});
         var dialog:GenericXMLDialog = new GenericXMLDialog(null,null,null,null,NaN,NaN,msg,null,false,"Okay",null,null,null,null,GenericXMLDialog.NUM_DIALOG_WIDTH_MEDIUM);
         UI.displayPopup(dialog,false);
      }
      
      private function onFinishBuy(index:int, count:int = 1) : void
      {
         var itemObject:FarmItem = this.m_rewardItemsArray[index];
         Global.player.addGift(itemObject.name,"0",count);
         Global.player.mysteryBox2TileStates[index] = TILE_STATE_WON;
         this.m_rewardPanel.itemTitle_tf.text = itemObject.friendlyTitle;
         this.m_rewardPanel.multiplier_tf.text = "x" + count;
         this.addRewardItem(itemObject,index);
         this.setTileStates();
         this.reEnableGame();
      }
      
      private function onOpenCurtains(e:Event) : void
      {
         if(this.m_loaderScreen.currentFrame == this.m_loaderScreen.totalFrames)
         {
            this.m_loaderScreen.removeEventListener(Event.ENTER_FRAME,this.onOpenCurtains);
            m_window.removeChild(m_window.loader_mc);
            this.m_loaderScreen = null;
            if(!this.visible)
            {
               this.visible = true;
            }
            if(this.m_showRevampMotd)
            {
               this.visible = false;
            }
         }
      }
      
      public function onLootDataReturn(result:Object) : void
      {
         var mc:MovieClip = null;
         var price:String = null;
         var itemObject:FarmItem = null;
         if(this.m_usingRefreshedUI || this.m_isRevampGame)
         {
            if(this.m_loaderScreen)
            {
               this.m_loaderScreen.gotoAndPlay(LOADER_SCREEN_PLAY_FRAME);
               this.m_loaderScreen.addEventListener(Event.ENTER_FRAME,this.onOpenCurtains,false,0,true);
            }
         }
         this.m_initResults = result;
         for(var idx:int = 0; idx < TILE_COUNT; idx++)
         {
            if(result[idx])
            {
               this.m_itemPricesArray[idx] = result[idx].cost;
               mc = this.getMoneyMC(idx);
               if(mc.hasOwnProperty("cost_tf"))
               {
                  price = String(this.m_itemPricesArray[idx]);
                  mc.cost_tf.text = price;
               }
               if(result[idx].itemName)
               {
                  itemObject = Global.farmGameSettingsManager.getFarmItemByName(result[idx].itemName);
                  this.addRewardItem(itemObject,idx);
               }
            }
         }
         this.m_rewardedItem.visible = true;
         this.getInitStates();
         this.resetGameBoard();
         this.setGameBoardState();
         this.showRewardDropdown(RIGHTPANEL_STATE_PLAY);
         this.setTileStates();
         if(!IN_LOOT_TABLE_VARIANT && !this.m_isRevampGame)
         {
            this.setUpCollectionPrizeFrame(result as Array);
         }
         this.addHandlers();
         this.onRefreshTokens(null);
         m_window.gameBoard_mc.visible = true;
         if(this.m_showRevampMotd)
         {
            hide();
         }
      }
      
      private function setUpCollectionPrizeFrame(lootDataResult:Array) : void
      {
         var lootItem:Object = null;
         var itemObject:FarmItem = null;
         var icon:Loader = null;
         var collectionPrizeItemName:String = null;
         for each(lootItem in lootDataResult)
         {
            if(lootItem.mysteryId == MYSTERY_ID_SET_BONUS)
            {
               collectionPrizeItemName = lootItem.itemName;
               break;
            }
         }
         itemObject = Global.farmGameSettingsManager.getFarmItemByName(collectionPrizeItemName);
         m_window.prizename_txt.visible = true;
         m_window.prizename_txt.text = itemObject.friendlyTitle;
         m_window.free_tf.visible = true;
         m_window.free_tf.text = ZLocUtils.t("Dialogs","UnwitherFree");
         icon = LoadingManager.load(itemObject.iconUrl,function(event:Event):void
         {
            var dispObjSmall:* = undefined;
            if(Boolean(icon) && Boolean(icon.content))
            {
               Utilities.removeAllChildren(m_window.prize_mc);
               dispObjSmall = icon.content;
               dispObjSmall.scaleX = dispObjSmall.scaleY = 0.75;
               dispObjSmall.x = 0;
               dispObjSmall.y = 10;
               m_window.prize_mc.addChild(dispObjSmall);
               m_window.prize_mc.visible = true;
            }
         });
      }
      
      private function checkForFreeGame() : Boolean
      {
         var result:Boolean = false;
         if(Global.player.level >= Global.farmGameSettingsManager.getNumber("mysteryBoxFreeGameMinLevel",6))
         {
            if(Global.player.getActionCount(FREE_GAME_DART_COUNTER) > 0)
            {
               if(!this.m_isRevampGame)
               {
                  result = true;
               }
            }
         }
         return result;
      }
      
      private function inventoryDartCount() : int
      {
         var dartItemName:String = null;
         var total:int = 0;
         if(this.m_isRevampGame)
         {
            total = FeatureOptionsInventoryManager.getInstance().getCountByName(m_consumable_dart_item_name);
         }
         else
         {
            for each(dartItemName in CONSUMABLE_DART_ITEM_NAMES)
            {
               total += Global.player.getGiftCountForItem(dartItemName);
            }
         }
         return total;
      }
      
      override public function close() : void
      {
         this.useCursor();
         UI.stopPopups(false);
         this.m_open = false;
         super.close();
         FarmStatsManager.count("fv_mysterygame","x_cancel");
         CarnivalBoothWindow.promoteCarnivalBooth();
         UI.refreshGiftBoxWindow();
         if(this.m_enteringViaMarket)
         {
            UI.displayMarketDialog("mystery_game_repop",null);
         }
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this.m_timer = null;
         }
         Global.stage.removeEventListener(MiniDartsManager.MINI_DART_REFRESH_EVENT,this.onRefreshTokens);
      }
      
      public function pause() : void
      {
         transform.colorTransform = m_dimColorTransform;
         Utilities.toggleInputAndChildren(this,false);
      }
      
      public function unpause() : void
      {
         transform.colorTransform = m_normalColorTransform;
         Utilities.toggleInputAndChildren(this,true);
      }
      
      private function getExpiryDateText() : String
      {
         var result:String = "";
         var timeRemaining:Number = (FarmGameUtil.synchronizedDateToNumber(this.m_endDate) - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var numDays:int = Math.ceil(timeRemaining / FarmGameUtil.NUM_SECS_IN_DAY);
         if(!isNaN(timeRemaining))
         {
            if(numDays > 1)
            {
               result = numDays.toString() + " days";
            }
            else
            {
               result = HUD.getformattedTimeLeft(timeRemaining);
            }
         }
         return result;
      }
      
      private function setFeedTimer() : void
      {
         var locText:String = null;
         var lastShown:Number = NaN;
         var timeRemaining:Number = NaN;
         var countDown:Number = NaN;
         if(m_window.rightPanelPlay_mc.ask_tf)
         {
            locText = ZLocUtils.t("Dialogs","minidarts_revamp_askbtn2",{"time":HUD.getformattedTimeLeft(this.m_featureManager.ASK_FEED_FREQUENCY)});
            if(this.m_askTokenButton.disabled)
            {
               lastShown = Global.player.getFeatureLastShown(this.m_featureManager.ASK_FEED_FREQUENCY_KEY);
               timeRemaining = Math.round(GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - lastShown);
               countDown = this.m_featureManager.ASK_FEED_FREQUENCY - timeRemaining;
               if(countDown > 0 && timeRemaining > 0)
               {
                  locText = ZLocUtils.t("Dialogs","minidarts_revamp_askbtn2",{"time":HUD.getformattedTimeLeft(countDown)});
               }
               else if(timeRemaining > this.m_featureManager.ASK_FEED_FREQUENCY)
               {
                  this.m_askTokenButton.disabled = false;
               }
            }
            m_window.rightPanelPlay_mc.ask_tf.text = locText;
         }
      }
      
      private function startTimer() : void
      {
         if(this.m_timer == null)
         {
            this.m_timer = new Timer(REWARD_PANEL_DROP_DELAY_MS);
            this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer);
            this.m_timer.start();
         }
      }
      
      private function onTimer(event:TimerEvent) : void
      {
         var timeRemaining:Number = (FarmGameUtil.synchronizedDateToNumber(this.m_endDate) - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var numDays:int = Math.ceil(timeRemaining / FarmGameUtil.NUM_SECS_IN_DAY);
         if(!isNaN(timeRemaining))
         {
            if(numDays > 3)
            {
               if(m_window.timer1_tf)
               {
                  ZLocUtils.setText(m_window,"timer1_tf","Dialogs","minidarts_revamp_footnote",{"time":this.getExpiryDateText()});
               }
               if(m_window.timer_mc)
               {
                  m_window.timer_mc.visible = false;
               }
            }
            else
            {
               m_window.timer1_tf.visible = false;
               if(m_window.timer_mc)
               {
                  m_window.timer_mc.visible = true;
                  ZLocUtils.setText(m_window,"timer_mc.timerAnim_mc.timer2_tf","Dialogs","minidarts_revamp_footnote",{"time":this.getExpiryDateText()});
               }
            }
         }
         this.setFeedTimer();
      }
      
      private function showRevampMotd() : void
      {
         if(this.m_isRevampGame && Global.player.getSeenFlag(SEEN_FLAG_REVAMP_COLLECTION_INFO) == false)
         {
            this.addEventListener(LoaderEvent.LOADED,this.onDialogLoaded);
            hide();
            this.visible = false;
            this.m_showRevampMotd = true;
            this.onMotdCloseCallback();
         }
      }
      
      private function onDialogLoaded(event:Event) : void
      {
         this.removeEventListener(LoaderEvent.LOADED,this.onDialogLoaded);
         hide();
      }
      
      public function onMotdCloseCallback() : void
      {
         show();
         this.visible = true;
         if(this.m_initResults)
         {
            if(this.m_loaderScreen)
            {
               this.m_loaderScreen.gotoAndPlay(LOADER_SCREEN_PLAY_FRAME);
               this.m_loaderScreen.addEventListener(Event.ENTER_FRAME,this.onOpenCurtains,false,0,true);
            }
         }
         this.m_showRevampMotd = false;
      }
      
      private function onAskBtnTooltipToggle(val:Boolean = false) : void
      {
         if(m_window.rightPanelPlay_mc.toolTip_mc)
         {
            m_window.rightPanelPlay_mc.toolTip_mc.visible = val;
         }
      }
   }
}

