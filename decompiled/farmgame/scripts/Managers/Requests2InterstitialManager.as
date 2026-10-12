package Managers
{
   import Classes.Constants.Experiments;
   import Classes.EmbeddedArt;
   import Classes.Minigames.MinigameConstants;
   import Classes.Minigames.MinigameManager;
   import Classes.ZItem.FarmItem;
   import Classes.util.ExternalUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.MysteryBoxBalloonDialog;
   import Display.QueuedIcon;
   import Display.UI;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Transactions.TR2InterstitialPostInit;
   import Widgets.Windows.FCSlotMachineWindow;
   import Widgets.Windows.IconTitleToasterWindow;
   import Widgets.Windows.MFSAddNeighborRoulette;
   import Widgets.Windows.MFSFreeGiftsRoulette;
   import Widgets.Windows.MFSNeighborReactivation;
   import Widgets.Windows.MFSRecentlyPlayed;
   import Widgets.Windows.PrizeMachine.PrizeMachineWindow;
   import Widgets.Windows.ScratchCardWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.geom.Point;
   
   public class Requests2InterstitialManager
   {
      
      private static const R2_INTERSTITIAL_POPUP_FREQUENCY_FLAG:String = "r2InterstitialPop";
      
      private static const RECENTLY_PLAYED_FRIENDS_HUD_ICON_NAME:String = "RecentlyPlayedFriends";
      
      private static const EXPERIMENT_FLASH_RECENTLY_PLAYED_INTERSTITIAL:String = "fv_recently_played_interstitial";
      
      private static var m_numRecentlyPlayedFriends:Number = 0;
      
      public static var m_zmcMessageShown:Boolean = false;
      
      public static var m_zmcMessageFirstTime:Boolean = true;
      
      public static const R2INTERSTITIAL_TYPE_RECENTLY_PLAYED:String = "r2_recently_played";
      
      public static const R2INTERSTITIAL_TYPE_FREE_GIFTS:String = "r2_free_gifts";
      
      public static const R2INTERSTITIAL_TYPE_INVITE:String = "r2_add_neighbor";
      
      public static const R2INTERSTITIAL_TYPE_REACTIVATION:String = "r2_neighbor_react";
      
      public static const R2INTERSITIAL_TYPE_REVENUE:String = "r2_revenue";
      
      public static const FEATURE_LAST_SHOWN_PREFIX:String = "R2Interstitial_";
      
      public static const SOURCE_R2_INTERSTITIAL_SOURCE:String = "reqs2_interstitial_roulette";
      
      public static const NO_FRIENDLIST_CAP:Number = -1;
      
      public static const DEFAULT_NUM_FRIENDS_CAP_ON_RECENTLYPLAYED_INTERSTITIAL:Number = -1;
      
      private static var m_requestItems:Array = new Array();
      
      private static var m_feedItems:Array = new Array();
      
      private static var m_selectedMinigame:int = 0;
      
      private static var m_recentlyPlayedFriendsCount:int = 0;
      
      public static const DEFAULT_NUM_FRIENDS_CAP_ON_FREEGIFTS_INTERSTITIAL:Number = -1;
      
      public static const DEFAULT_NUM_FRIENDS_CAP_ON_INVITE_INTERSTITIAL:Number = 24;
      
      public static const DEFAULT_NUM_FRIENDS_CAP_ON_REACTIVATION_INTERSTITIAL:Number = 48;
      
      public static const MINIGAME_MYSTERY_GAME:int = 1;
      
      public static const MINIGAME_HAYSTACK:int = 2;
      
      public static const MINIGAME_SCRATCH_CARDS:int = 3;
      
      public static const MINIGAME_SPIN_WIN:int = 4;
      
      public static const MINIGAME_PRIZE_MACHINE:int = 5;
      
      public static const REVENUE_FEATURE_NAME:String = "reqs3_interstitial_roulette";
      
      private static const REVENUE_LE_VARIANT:int = 2;
      
      private static const REVENUE_MINIGAME_VARIANT:int = 3;
      
      private static const REVENUE_FARMCASH_VARIANT:int = 4;
      
      public function Requests2InterstitialManager()
      {
         super();
      }
      
      public static function conditionallyDisplayR2Interstitial(interstitialTypeIndex:String, friendNumberCount:int) : void
      {
         var minNumberOfFriends:int = 0;
         var popupCooldown:int = 0;
         var lastPopupSeen:int = 0;
         var currentTime:int = 0;
         var timeSinceLastSeen:int = 0;
         var source:String = null;
         var revenueVariant:int = 0;
         var supressForPopupFramework:Boolean = false;
         supressForPopupFramework = Global.player.level <= 3;
         if(!Global.postInitActionsManager.dialogSupress && !supressForPopupFramework)
         {
            minNumberOfFriends = Global.farmGameSettingsManager.getInt("r2InterstitialPopupMinFriends",5000);
            if(friendNumberCount >= minNumberOfFriends)
            {
               popupCooldown = Global.farmGameSettingsManager.getInt("r2InterstitialPopupCooldown",64800);
               lastPopupSeen = Global.player.getFeatureLastShown(R2_INTERSTITIAL_POPUP_FREQUENCY_FLAG);
               currentTime = GlobalEngine.serverTime / 1000;
               timeSinceLastSeen = currentTime - lastPopupSeen;
               if(timeSinceLastSeen > popupCooldown && m_zmcMessageShown == false)
               {
                  if(Global.player.getItemFlag("r2InterstitialForce") == null)
                  {
                     Global.player.setFeatureLastShown(R2_INTERSTITIAL_POPUP_FREQUENCY_FLAG,currentTime,true);
                     Global.player.setFeatureLastShown(FEATURE_LAST_SHOWN_PREFIX + interstitialTypeIndex,currentTime,true);
                  }
                  switch(interstitialTypeIndex)
                  {
                     case R2INTERSTITIAL_TYPE_RECENTLY_PLAYED:
                        source = SOURCE_R2_INTERSTITIAL_SOURCE;
                        displayRecentlyPlayedFriendsGiftWindow(source,true,true);
                        break;
                     case R2INTERSTITIAL_TYPE_FREE_GIFTS:
                        displayFreeGiftsWindow(SOURCE_R2_INTERSTITIAL_SOURCE);
                        break;
                     case R2INTERSTITIAL_TYPE_INVITE:
                        displayNeighborAddWindow(SOURCE_R2_INTERSTITIAL_SOURCE);
                        break;
                     case R2INTERSTITIAL_TYPE_REACTIVATION:
                        displayNeighborReactWindow(SOURCE_R2_INTERSTITIAL_SOURCE);
                        break;
                     case R2INTERSITIAL_TYPE_REVENUE:
                        revenueVariant = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_REQS2_REVENUE);
                        if(revenueVariant == REVENUE_LE_VARIANT)
                        {
                           displayLERevenueWindow();
                        }
                        if(revenueVariant == REVENUE_MINIGAME_VARIANT)
                        {
                           displayMinigameWindow();
                        }
                        if(revenueVariant == REVENUE_FARMCASH_VARIANT)
                        {
                           displayFarmCashWindow();
                        }
                  }
               }
            }
         }
      }
      
      private static function onClickRecentlyPlayedFriends(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            displayRecentlyPlayedFriendsGiftWindow("dialog_clicked");
            FarmStatsManager.count("fv_recently_played_friends_gifting_overlay","dialog_clicked",getNumFriendsDisplayed().toString());
         }
      }
      
      public static function addHUDIcon(numRecentlyPlayedFriends:int, recentlyPlayedFriendsInfo:Array) : void
      {
         var qued:QueuedIcon = null;
         var iconFiller:Function = null;
         var extraData:Object = null;
         var numOtherFriends:Number = NaN;
         if(Boolean(numRecentlyPlayedFriends > 0) && Boolean(recentlyPlayedFriendsInfo) && recentlyPlayedFriendsInfo.length > 0)
         {
            qued = Global.hud.iconQueue.addIconToTop(RECENTLY_PLAYED_FRIENDS_HUD_ICON_NAME);
            iconFiller = function(content:DisplayObject):void
            {
               var pic:DisplayObject = null;
               var urlPic:String = null;
               var mc:MovieClip = content as MovieClip;
               if(mc)
               {
                  if(Boolean(numRecentlyPlayedFriends) && Boolean(mc.friendNumber_tf))
                  {
                     mc.friendNumber_tf.text = numRecentlyPlayedFriends.toString();
                  }
                  if(Boolean(recentlyPlayedFriendsInfo) && Boolean(recentlyPlayedFriendsInfo[0].pic_square) && Boolean(mc.icon_mc))
                  {
                     urlPic = recentlyPlayedFriendsInfo[0].pic_square;
                     if(urlPic)
                     {
                        pic = LoadingManager.load(urlPic,null,LoadingManager.PRIORITY_LOW);
                     }
                     if(pic == null)
                     {
                        pic = new EmbeddedArt.hud_no_profile_pic();
                        pic.width = 48;
                        pic.height = 48;
                     }
                     mc.icon_mc.addChild(pic);
                  }
               }
            };
            qued.contentManip = iconFiller;
            extraData = new Object();
            if(numRecentlyPlayedFriends > 1)
            {
               numOtherFriends = numRecentlyPlayedFriends - 1;
               extraData.iconTooltip = ZLocUtils.t("Dialogs","RecentlyPlayedFriendsMultiple_iconTooltip",{
                  "user":ZLocUtils.tn(recentlyPlayedFriendsInfo[0].first_name,ZLocUtils.tg(recentlyPlayedFriendsInfo[0].sex)),
                  "quantity":numOtherFriends.toString()
               });
            }
            else
            {
               extraData.iconTooltip = ZLocUtils.t("Dialogs","RecentlyPlayedFriendsSingle_iconTooltip",{"user":ZLocUtils.tn(recentlyPlayedFriendsInfo[0].first_name,ZLocUtils.tg(recentlyPlayedFriendsInfo[0].sex))});
            }
            qued.extraData = extraData;
            Global.hud.markDirty();
         }
      }
      
      public static function setNumFriendsDisplayed(value:Number) : void
      {
         var iconContent:MovieClip = null;
         m_numRecentlyPlayedFriends = value;
         var icon:QueuedIcon = Global.hud.iconQueue.getIconByName(RECENTLY_PLAYED_FRIENDS_HUD_ICON_NAME);
         if(icon)
         {
            if(m_numRecentlyPlayedFriends > 0)
            {
               iconContent = icon.getContent() as MovieClip;
               if(iconContent)
               {
                  iconContent.friendNumber_tf.text = m_numRecentlyPlayedFriends.toString();
               }
            }
            else
            {
               Global.hud.iconQueue.removeIconByName(RECENTLY_PLAYED_FRIENDS_HUD_ICON_NAME);
            }
         }
      }
      
      public static function getNumFriendsDisplayed() : Number
      {
         return m_numRecentlyPlayedFriends;
      }
      
      public static function getRecentlyPlayedGift() : FarmItem
      {
         var result:FarmItem = null;
         var itemName:String = Global.flashHotParams["RECENTLY_PLAYED_GIFT_ITEM_NAME"];
         if(itemName)
         {
            result = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         }
         return result;
      }
      
      public static function displayRecentlyPlayedFriendsGiftWindow(source:String, limitFriends:Boolean = false, showFeedDialog:Boolean = false) : void
      {
         var itemName:String = null;
         var feedItem:FarmItem = null;
         var item:FarmItem = getRecentlyPlayedGift();
         var feedItems:Array = new Array();
         for each(itemName in m_feedItems)
         {
            feedItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
            if(feedItem != null)
            {
               feedItems.push(feedItem);
            }
         }
         if(item)
         {
            UI.displayPopup(new MFSRecentlyPlayed(item,feedItems,source,limitFriends,displayRecentlyPlayedFriendsCompleteToaster,showFeedDialog));
         }
         else
         {
            ErrorManager.addError("Unable to find gift item.",ErrorManager.ERROR_UNKNOWN);
         }
      }
      
      public static function displayNeighborReactWindow(source:String) : void
      {
         var item:FarmItem = getRecentlyPlayedGift();
         if(m_requestItems != null && m_requestItems.length > 0)
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(m_requestItems[0]);
         }
         if(item)
         {
            UI.displayPopup(new MFSNeighborReactivation(item,source,null));
         }
         else
         {
            ErrorManager.addError("Unable to find gift item: " + m_requestItems[0],ErrorManager.ERROR_UNKNOWN);
         }
      }
      
      public static function displayLERevenueWindow() : void
      {
         LESurfacingManager.instance.show(REVENUE_FEATURE_NAME);
      }
      
      public static function displayFarmCashWindow() : void
      {
      }
      
      public static function displayMinigameWindow() : void
      {
         var prizeMachineWindow:PrizeMachineWindow = null;
         switch(m_selectedMinigame)
         {
            case MINIGAME_MYSTERY_GAME:
               StatsManager.count(REVENUE_FEATURE_NAME,"fv_mysterygame","impressions");
               MysteryBoxBalloonDialog.openDefaultMysteryGame(null);
               break;
            case MINIGAME_HAYSTACK:
               if(MinigameManager.instance.launchMinigameWindow(MinigameConstants.MINIGAME_KEY_HAYSTACK,null))
               {
                  StatsManager.count(REVENUE_FEATURE_NAME,"haystack_game","impressions");
               }
               else
               {
                  ErrorManager.addError("Requests2InterstitialManager.as :: displayMinigameWindow() error: failed launchMinigameWindow(" + MinigameConstants.MINIGAME_KEY_HAYSTACK + ").");
               }
               break;
            case MINIGAME_SCRATCH_CARDS:
               StatsManager.count(REVENUE_FEATURE_NAME,"scratchcard","impressions");
               UI.displayPopup(new ScratchCardWindow(ScratchCardWindow.SCRATCH_CARD_ENTRY_DESCRIPTOR_GAMETENT),true,ScratchCardWindow.POPUP_NAME,true);
               break;
            case MINIGAME_SPIN_WIN:
               StatsManager.count(REVENUE_FEATURE_NAME,"slots","impressions");
               UI.displayPopup(new FCSlotMachineWindow(FCSlotMachineWindow.ENTRY_POINT_GAME_TENT),true,FCSlotMachineWindow.WINDOW_NAME,true);
               break;
            case MINIGAME_PRIZE_MACHINE:
               StatsManager.count(REVENUE_FEATURE_NAME,"prize_machine","impressions");
               prizeMachineWindow = new PrizeMachineWindow();
               UI.displayPopup(prizeMachineWindow,false,"PrizeMachineWindow",true);
         }
      }
      
      public static function displayFreeGiftsWindow(source:String) : void
      {
         var itemName:String = null;
         var item:FarmItem = null;
         var feedItem:FarmItem = null;
         var giftItems:Array = new Array();
         for each(itemName in m_requestItems)
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(itemName);
            if(item != null)
            {
               giftItems.push(item);
            }
         }
         if(giftItems.length >= 1)
         {
            feedItem = getRecentlyPlayedGift();
            UI.displayPopup(new MFSFreeGiftsRoulette(giftItems,feedItem,source,null,true));
         }
         else
         {
            ErrorManager.addError("Invalid giftItems array for Free Gifts window",ErrorManager.ERROR_UNKNOWN);
         }
      }
      
      public static function displayNeighborAddWindow(source:String) : void
      {
         UI.displayPopup(new MFSAddNeighborRoulette(source,null));
      }
      
      public static function displayRecentlyPlayedFriendsCompleteToaster(numGiftsSent:int) : void
      {
         var item:FarmItem = null;
         var title:String = null;
         var message:String = null;
         var icon:String = null;
         if(numGiftsSent > 0)
         {
            item = getRecentlyPlayedGift();
            if(item)
            {
               title = ZLocUtils.t("Dialogs","RecentlyPlayedFriendsCompleteToaster_Title");
               message = ZLocUtils.t("Dialogs","RecentlyPlayedFriendsCompleteToaster_Message",{"sentCount":numGiftsSent});
               icon = item.getImageByName("icon");
               ToasterManager.getInstance().add(new IconTitleToasterWindow(title,message,icon,"assets/dialogs/FV_PlacementMode_BannerAd.swf",0.5,new Point(15,8)));
            }
            else
            {
               ErrorManager.addError("Unable to find gift item.",ErrorManager.ERROR_UNKNOWN);
            }
         }
      }
      
      public static function set requestItems(items:Array) : void
      {
         if(items != null)
         {
            m_requestItems = items;
         }
      }
      
      public static function set feedItems(items:Array) : void
      {
         if(items != null)
         {
            m_feedItems = items;
         }
      }
      
      public static function set minigameIndex(minigameIndex:int) : void
      {
         m_selectedMinigame = minigameIndex;
      }
      
      public static function set recentlyPlayedFriendsCount(recentlyPlayedFriendsCount:int) : void
      {
         m_recentlyPlayedFriendsCount = recentlyPlayedFriendsCount;
      }
      
      public static function hookZMCPostInit() : void
      {
         ExternalUtil.instance.addCallback("ZMCOpen",onMessageCenterOpen);
         ExternalUtil.instance.addCallback("ZMCClose",onMessageCenterClose);
         ExternalUtil.instance.call("onPostInit");
      }
      
      private static function onMessageCenterOpen() : void
      {
         m_zmcMessageShown = true;
      }
      
      private static function onMessageCenterClose() : void
      {
         if(m_zmcMessageShown && m_recentlyPlayedFriendsCount > 0 && m_zmcMessageFirstTime)
         {
            m_zmcMessageFirstTime = false;
            conditionallyDisplayR2Interstitial(R2INTERSTITIAL_TYPE_RECENTLY_PLAYED,m_recentlyPlayedFriendsCount);
         }
         m_zmcMessageShown = false;
      }
      
      public static function interstitialPostInitSeq() : void
      {
         TransactionManager.addTransaction(new TR2InterstitialPostInit());
      }
   }
}

