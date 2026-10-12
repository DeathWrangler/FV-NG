package Display
{
   import Classes.ChickenCoopBuilding;
   import Classes.Constants.CrossPromoConstants;
   import Classes.Constants.Experiments;
   import Classes.Constants.StatsTrackingConstants;
   import Classes.DealOfDayHelper;
   import Classes.EnglandOnboardingController;
   import Classes.Friend;
   import Classes.HorseStableBuilding;
   import Classes.Idle.IdleTaskQueue;
   import Classes.Idle.PromoIdleTask;
   import Classes.Idle.RemoveHUDIconTask;
   import Classes.Minigames.MinigameManager;
   import Classes.PremiumHudAd;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.VisitorManager;
   import Classes.ZItem.ContentAccessSettings;
   import Classes.ZItem.FarmItem;
   import Classes.instagrow.InstagrowUtils;
   import Classes.util.FarmGameUtil;
   import Classes.util.MovieClipUtils;
   import Classes.util.ZLocUtils;
   import Display.Dialogs.InGameCurrencyConversion;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.TransactionManager;
   import Events.DynamicObjectEvent;
   import GameMode.GMHalloweenTrick;
   import Managers.BingoManager;
   import Managers.BuildableCompletionPackagesManager;
   import Managers.BuyFromFeedsManager;
   import Managers.CrossPromoManager;
   import Managers.EmailManager;
   import Managers.FaceOffManager;
   import Managers.FarmRunQuestManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureConfigManager;
   import Managers.FinishAllBuildingsUtil;
   import Managers.HangingGardensManager;
   import Managers.HolidayCountdownManager;
   import Managers.ItemContestManager;
   import Managers.LESurfacingManager;
   import Managers.LimitedSaleUtility;
   import Managers.LotteryManager;
   import Managers.OrderBoard.BobBerryManager;
   import Managers.OrderBoard.DreamWorldInnovationManager;
   import Managers.PerformanceExperimentManager;
   import Managers.PetManager;
   import Managers.PphToDoListManager;
   import Managers.QuestManagerDisplay;
   import Managers.Requests2InterstitialManager;
   import Managers.SocialPlumbingManager;
   import Managers.SpendometerManager;
   import Managers.TaskListManager;
   import Managers.UnicornMusicPlayerManager;
   import Managers.WhitewinterInnovationManager;
   import Transactions.TGetMOTD;
   import Widgets.Constants.Market.Currency;
   import Widgets.Windows.Carnival.CarnivalBoothWindow;
   import Widgets.Windows.Expansion.ExpansionOnboardingWindow;
   import Widgets.Windows.FCSlotMachineWindow;
   import Widgets.Windows.FreeGiftSelectionWindow;
   import Widgets.Windows.LESlotMachineWindow;
   import Widgets.Windows.LimitedGifting.LimitedGiftingRecipientWindow;
   import Widgets.Windows.LimitedGifting.LimitedGiftingWindow;
   import Widgets.Windows.Lottery.LotteryMainWindow;
   import Widgets.Windows.MOTD.BuyFromFeedsOfferWindow;
   import Widgets.Windows.MOTD.FarmExpressMOTDWindow;
   import Widgets.Windows.Market.MarketWindow;
   import Widgets.Windows.PrizeMachine.PrizeMachineWindow;
   import Widgets.Windows.ScratchCardWindow;
   import Widgets.Windows.SocialPlumbing.SocialPlumbingTodoList;
   import Widgets.Windows.TargetedLimitedSaleWindow;
   import Widgets.Windows.ThemedQuestWindow;
   import fl.motion.easing.Bounce;
   import fl.motion.easing.Cubic;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.BlendMode;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.DropShadowFilter;
   import flash.geom.Matrix;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.utils.Dictionary;
   import gs.TweenLite;
   
   public class QueuedIcon extends FarmGameSprite
   {
      
      public static const BUTTON_SIZE:Number = 50;
      
      public static const BUTTON_PADDING:Number = 9;
      
      public static const TWEEN_UP:int = 0;
      
      public static const TWEEN_DOWN:int = 1;
      
      public static const ICON_CODE_COCONUTS:String = "184";
      
      public static const ICON_CODE_JADE:String = "185";
      
      public static const ICON_CODE_STARTER_XAS:String = "209";
      
      public static const ICON_CODE_CONTENT_ACCESS:String = "207";
      
      public static const ICON_TYPE_FLASH_GIFT:String = "FlashGift";
      
      public static const ICON_TYPE_FEATURE_CRAFTING:String = "FeatureCrafting";
      
      public static const ICON_TYPE_LEADERBOARD:String = "Leaderboard";
      
      public static const ICON_TYPE_LEADERBOARD_DYNAMIC:String = "LeaderboardDynamic";
      
      public static const ICON_TYPE_MULTI_TASK_LEADERBOARD:String = "MultiTaskLeaderboard";
      
      public static const ICON_TYPE_FACEOFF:String = "FaceOff";
      
      public static const ICON_TYPE_QUEST:String = "Quest";
      
      public static const ICON_TYPE_HOLIDAY_COUNTDOWN_MESSAGE_ICON:String = "HolidayCountdownMessageIcon";
      
      public static const ICON_TYPE_FEATURE_OF_THE_WEEK:String = "GenericFeatureOfTheWeek";
      
      public static const ICON_TYPE_BEAT_EXPANSION:String = "BeatExpansionQueuedIcon";
      
      public static const ICON_TYPE_TIMED_GIVEAWAY:String = "TimedGiveawayIcon";
      
      public static const ICON_TYPE_DAILY_DRIP:String = "DailyDripIcon";
      
      public static const ICON_TYPE_QUEUED_ICON_WITH_ARROW:String = "QueuedIconWithArrow";
      
      public static const ICON_TYPE_MULTIPLE_TOOLTIP:String = "MultipleToolTipIcon";
      
      public var code:String;
      
      public var iconName:String;
      
      public var motdVersion:int;
      
      public var priority:int;
      
      public var group:String;
      
      public var persists:Boolean;
      
      public var imageUrl:String;
      
      public var action:String;
      
      public var m_actionParams:Dictionary = null;
      
      public var minLevel:int;
      
      public var marketCategory:String;
      
      public var marketSubcategory:String;
      
      public var hasPopup:Boolean;
      
      public var removeOnClick:Boolean;
      
      public var isWithinStartAndEndDates:Boolean = true;
      
      public var itemList:Array;
      
      public var extraData:Object;
      
      public var actionUrl:String;
      
      public var actionTarget:String;
      
      public var runtimeSwitch:String;
      
      protected var m_isLoaded:Boolean;
      
      protected var m_contentManip:Function;
      
      protected var m_expirationTime:int = -1;
      
      protected var m_category:String = null;
      
      protected var m_loadCompleteCallback:Function = null;
      
      protected const STORAGE_FEED_URL:String;
      
      protected var m_Loader:Loader;
      
      protected var m_currentTween:TweenLite = null;
      
      public var alphaMask:MovieClip;
      
      private var m_visibilityPrereqs:Array = null;
      
      protected var m_side:int;
      
      public var m_crossPromoGameId:String;
      
      public function QueuedIcon(xml:XML)
      {
         var itemIdx:int = 0;
         var item:XML = null;
         var paramLen:uint = 0;
         var iParam:int = 0;
         var paramXML:XML = null;
         this.STORAGE_FEED_URL = Global.getAssetURL("assets/newsfeed/storage_increase.png");
         super();
         this.code = xml.@code.toString();
         this.iconName = xml.@name.toString();
         this.motdVersion = xml.@motd.toString();
         this.priority = parseInt(xml.priority.toString());
         this.group = xml.group.toString();
         var persistsInt:int = parseInt(xml.persists.toString());
         this.persists = persistsInt == 0 ? false : true;
         this.imageUrl = xml.image.@url.toString();
         this.action = xml.action.toString();
         this.hasPopup = parseInt(xml.hasPopup.toString()) != 0;
         this.removeOnClick = parseInt(xml.removeOnClick.toString()) != 0;
         this.marketCategory = xml.marketCategory.toString();
         this.marketSubcategory = xml.marketSubcategory.toString();
         this.actionUrl = xml.actionUrl.toString();
         this.runtimeSwitch = xml.runtimeSwitch.toString();
         this.m_category = xml.category != null ? xml.category.toString() : null;
         this.m_contentManip = null;
         this.m_crossPromoGameId = xml.crossPromoGameId.toString();
         this.m_isLoaded = false;
         this.actionTarget = "_blank";
         if("@openInSameWindow" in xml.actionUrl && xml.actionUrl.@openInSameWindow == "true")
         {
            this.actionTarget = "_top";
         }
         if(xml.hasOwnProperty("prereqs"))
         {
            this.m_visibilityPrereqs = PrerequisiteUtility.parseXmlNodePrereqs(xml.prereqs);
         }
         var xmlMinLevel:String = xml.minLevel;
         if(xmlMinLevel != "")
         {
            this.minLevel = parseInt(xmlMinLevel);
         }
         else
         {
            this.minLevel = Global.farmGameSettingsManager.getInt("iconQueueMinLevel");
         }
         var xmlStartDateValue:String = xml.startDate;
         var xmlStartDate:Date = new Date();
         var hasStartDate:Boolean = false;
         if(xmlStartDateValue != "")
         {
            xmlStartDate = new Date(xmlStartDateValue);
            hasStartDate = true;
         }
         var xmlEndDateValue:String = xml.endDate;
         var xmlEndDate:Date = new Date();
         var hasEndDate:Boolean = false;
         if(xmlEndDateValue != "")
         {
            xmlEndDate = new Date(xmlEndDateValue);
            hasEndDate = true;
         }
         var xmlStartTime:Number = xmlStartDate.valueOf();
         var xmlEndTime:Number = xmlEndDate.valueOf();
         var currentTime:Number = GlobalEngine.serverTime;
         if(hasStartDate)
         {
            this.isWithinStartAndEndDates = this.isWithinStartAndEndDates && currentTime > xmlStartTime;
         }
         if(hasEndDate)
         {
            this.isWithinStartAndEndDates = this.isWithinStartAndEndDates && currentTime < xmlEndTime;
         }
         var list:XMLList = null;
         this.itemList = new Array();
         list = xml.itemList.item;
         if(list)
         {
            for(itemIdx = 0; itemIdx < xml.itemList.item.length(); itemIdx++)
            {
               item = xml.itemList.item[itemIdx];
               this.itemList.push(item.toString());
            }
         }
         if(xml.hasOwnProperty("actionParams"))
         {
            this.m_actionParams = new Dictionary();
            list = xml.actionParams.param;
            if(list)
            {
               paramLen = uint(list.length());
               for(iParam = 0; iParam < paramLen; iParam++)
               {
                  paramXML = list[iParam];
                  this.m_actionParams[paramXML.@key.toString()] = paramXML.@value.toString();
               }
            }
         }
         this.buttonMode = true;
         this.scaleX = this.scaleY = 1;
         this.normalScale = 1;
         this.rollOverScale = 1.1;
         if(PerformanceExperimentManager.isInExtremePerformanceLimiterExperiment)
         {
            this.filters = [];
         }
         else
         {
            this.filters = [new DropShadowFilter()];
         }
      }
      
      public function init() : void
      {
         if(Boolean(this.extraData) && int(this.extraData["expirationTime"]) > 0)
         {
            this.m_expirationTime = int(this.extraData["expirationTime"]);
            IdleTaskQueue.getInstance().addTask(new RemoveHUDIconTask(this.iconName,this.m_expirationTime));
         }
      }
      
      public function dispose() : void
      {
         var dispObjBitmap:Bitmap = null;
         var alphaMaskBitmap:Bitmap = null;
         this.m_isLoaded = false;
         for(var index:int = 0; index < this.numChildren; index++)
         {
            dispObjBitmap = this.getChildAt(index) as Bitmap;
            if(dispObjBitmap)
            {
               dispObjBitmap.bitmapData.dispose();
            }
            dispObjBitmap = null;
         }
         if(this.alphaMask)
         {
            alphaMaskBitmap = this.alphaMask.getChildAt(0) as Bitmap;
            alphaMaskBitmap.bitmapData.dispose();
            alphaMaskBitmap = null;
         }
      }
      
      public function finishClick(parent:DynamicIconQueue) : void
      {
         var numFriends:Number = NaN;
         var farmItem:FarmItem = null;
         var iconUrl:String = null;
         var images:Array = null;
         var url:String = null;
         var remaining:int = 0;
         var params:Object = null;
         var chickenCoop:ChickenCoopBuilding = null;
         var i:int = 0;
         var friendID:String = null;
         var friend:Friend = null;
         var mysteryBoxTokenName:String = null;
         var m_mysteryBoxBalloonDialog:MysteryBoxBalloonDialog = null;
         var lotteryWindow:LotteryMainWindow = null;
         var featureName:String = null;
         var dialog:LimitedGiftingWindow = null;
         var recipientFeatureConfig:FeatureConfigManager = null;
         var recipientPopup:LimitedGiftingRecipientWindow = null;
         var contentAccessSettings:ContentAccessSettings = null;
         var contentPurchaseWindow:ExpansionOnboardingWindow = null;
         var themedQuestWindow:ThemedQuestWindow = null;
         switch(this.action)
         {
            case "market":
               MarketWindow.previousPage = 0;
               if("" == this.marketSubcategory)
               {
                  UI.displayMarketDialog("hudIcon",this.marketCategory);
               }
               else
               {
                  UI.displayMarketDialog("hudIcon",this.marketCategory,null,this.marketSubcategory);
               }
               break;
            case "recentFriendsOverlay":
               if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FEED_INTERSTITIAL_V2) == 2)
               {
                  Requests2InterstitialManager.displayRecentlyPlayedFriendsGiftWindow("HUD_clicked",false,true);
               }
               else
               {
                  Requests2InterstitialManager.displayRecentlyPlayedFriendsGiftWindow("HUD_clicked");
               }
               numFriends = Requests2InterstitialManager.getNumFriendsDisplayed();
               FarmStatsManager.count("fv_recently_played_friends_gifting_overlay","HUD_clicked",numFriends.toString());
               break;
            case "inactiveRequestFriendsOverlay":
               FarmStatsManager.sample(100,"fv_fbml_depr_inspect","inactiveRequestFriendsOverlay","called");
               break;
            case "pphToDoList":
               PphToDoListManager.getInstance().doAction();
               break;
            case "musicPlayer":
               FarmStatsManager.count("Uni_music_HUD","HUD_clicks");
               Global.hud.optionsMenu.disableSounds();
               UnicornMusicPlayerManager.getInstance().showMusicPlayerPopUp();
               break;
            case "socialPlumbingTodoList":
               FarmStatsManager.count(SocialPlumbingManager.MAIN_STATS_COUNTER,"to_do_list_opens");
               UI.displayPopup(new SocialPlumbingTodoList());
               break;
            case "miniMarket":
               UI.displayMiniMarketDialog(this.itemList,"hudIcon",this.marketCategory,null,true,false,false,true);
               break;
            case "miniMarketWithDealOfDay":
               farmItem = DealOfDayHelper.getDealOfDayItem();
               if(farmItem)
               {
                  UI.displayMiniMarketDialog([farmItem.name],"hudIcon",this.marketCategory);
               }
               break;
            case "giftBox":
               UI.displayGiftBoxWindow();
               break;
            case "giftPage":
               parent.saveIcons();
               FreeGiftSelectionWindow.popWindow();
               break;
            case "wishlist":
               parent.saveIcons();
               FarmStatsManager.sample(100,"fv_fbml_depr_inspect","r1FlowCalled","wishlist_hud");
               GlobalEngine.socialNetwork.redirect("gifts.php?template=wishlist&ref=hud_icon");
               break;
            case FarmExpressMOTDWindow.FVWEB_HUD_FVXPROMO:
               FarmStatsManager.count("hud_icon","xpromo","click","63","fvx_xpromo");
               Global.player.setSeenFlag(FarmExpressMOTDWindow.FVWEB_HUD_FVXPROMO_CLICK);
               GlobalEngine.socialNetwork.redirect("farmexpress.php?ref=xpromo&creative=webgame",null,"_blank");
               break;
            case "externalLink":
               if("" != this.actionUrl)
               {
                  navigateToURL(new URLRequest(this.actionUrl),"_blank");
               }
               break;
            case "inGameLink":
               if("" != this.actionUrl)
               {
                  parent.saveIcons();
                  GlobalEngine.socialNetwork.redirect(this.actionUrl);
               }
               break;
            case "unwitherPromote":
               iconUrl = Global.getAssetURL("assets/newsfeed/unwither_feed.png");
               images = [{
                  "src":iconUrl,
                  "href":"{SN_APP_URL}"
               }];
               GlobalEngine.socialNetwork.publishFeedStory("PromoteUnwither",{"images":images},[],false);
               break;
            case "PremiumHudAd":
               PremiumHudAd.hudIconClicked();
               break;
            case "StorageUpgrade":
               url = Global.getAssetURL("assets/newsfeed/storage_increase.png");
               remaining = Global.farmGameSettingsManager.getInt("storageExpansionFriendRequirement",10) - Global.player.upgradeStatus.numHelped;
               params = {
                  "numRemaining":remaining,
                  "reward_link":Global.player.upgradeStatus.url,
                  "images":[{
                     "src":url,
                     "href":"{SN_APP_URL}" + Global.player.upgradeStatus.url
                  }]
               };
               GlobalEngine.socialNetwork.publishFeedStory("StorageUpgradeAskForHelp",params,[],false);
               break;
            case "ChickenFeed":
               FarmStatsManager.sample(100,VisitorManager.NEIGHBOR_VISIT_COUNTER,VisitorManager.NEIGHBOR_VISIT_HUDICON_COUNTER,"chicken_coop","clicks");
               chickenCoop = VisitorManager.getInstance().getHungryChickenCoop();
               if(chickenCoop)
               {
                  chickenCoop.centerOn();
                  chickenCoop.onClick();
               }
               break;
            case "TrickNeighbor":
               i = 0;
               for(i = 0; i < Global.world.getActiveGameModes().length; i++)
               {
                  if(Global.world.getActiveGameModes()[i] is GMHalloweenTrick)
                  {
                     VisitorManager.getInstance().setDefaultGameMode();
                     break;
                  }
               }
               if(i == Global.world.getActiveGameModes().length)
               {
                  VisitorManager.getInstance().onNeighborTrick();
               }
               break;
            case "NeighborVisitGift":
               FarmStatsManager.sample(100,"fv_fbml_depr_inspect","NeighborVisitGift","called");
               friendID = Global.worldManager.getVisiting();
               friend = Global.friendManager.getAppFriendData(friendID);
               if(Boolean(friend) && !Global.worldManager.isVisitingCommunityNeighbor())
               {
                  VisitorManager.getInstance().onNeighborGift();
               }
               break;
            case "NeighborVisitFarmActions":
               FarmStatsManager.sample(100,VisitorManager.NEIGHBOR_VISIT_COUNTER,VisitorManager.NEIGHBOR_VISIT_HUDICON_COUNTER,"farm_action","clicks");
               UI.displayPopup(new GenericPopup(ZLocUtils.t("Dialogs","NeighborVisitFarmActions_iconPopup"),GenericPopup.TYPE_OK));
               VisitorManager.getInstance().setDefaultGameMode();
               break;
            case "EmailPermission":
               FarmStatsManager.count("emailPermission","hud_icon_clicked");
               EmailManager.displayEmailPermissionPrompt(EmailPopup.EMAIL_HUD_ICON);
               break;
            case "mysteryGift":
               FreeGiftSelectionWindow.popWindow();
               break;
            case "Collections":
               UI.displayPopup(new Collections());
               break;
            case "SweetSeeds":
               Global.ui.chooseSweetSeedsDisplayDialog();
               break;
            case "bookmark":
               GlobalEngine.socialNetwork.showBookmarkDialog();
               break;
            case "PetVilleCrossPromo":
               UI.displayPopup(new PetVilleCrossPromo());
               break;
            case "pound":
               PetManager.getInstance().showRescuePopup();
               break;
            case "fuelForCoinsPopup":
               UI.displayPopup(new GenericPopup(ZLocUtils.t("Dialogs","fuelHudIconMessage"),GenericPopup.TYPE_OK),false);
               break;
            case "stable":
               HorseStableBuilding.onClickStableExpansionPromo();
               break;
            case "mustang":
               FarmStatsManager.count("wild_mustang","hud_icon","clicked");
               break;
            case "claimcrosspromoreward":
               CrossPromoManager.getInstance().claimReward(this.iconName);
               break;
            case "mysteryboxgame":
               mysteryBoxTokenName = this.iconName;
               m_mysteryBoxBalloonDialog = new MysteryBoxBalloonDialog(mysteryBoxTokenName);
               UI.displayPopup(m_mysteryBoxBalloonDialog,false);
               break;
            case "beginoutboundcrosspromo":
               CrossPromoManager.getInstance().getOutBoundPromoUrl(this.iconName);
               break;
            case "PromoBuyerAbandonment":
               FarmStatsManager.count("rev_abandonment","great_value_promo","fifty_percent_off_promo","hud_icon_clicks");
               PromoIdleTask.navigateToMoneyPage();
               break;
            case "avatarClothes":
               Global.world.displayAvatarCustomizationScreen(false);
               break;
            case "UnwitherOptimization":
               UnwitherDialog.showUnwitherDialogIfAppropriate();
               InstagrowUtils.conditionallyShowInstagrowIcon();
               break;
            case "buyFromFeeds":
               FarmStatsManager.count(BuyFromFeedsManager.STATS_COUNTER,StatsTrackingConstants.HUD_ICON,StatsTrackingConstants.CLICKS);
               BuyFromFeedsOfferWindow.show();
               break;
            case InstagrowUtils.INSTA_GROW_HUD_ICON_NAME:
               InstagrowUtils.handleHudIconClick();
               break;
            case EnglandOnboardingController.RECAPTURE_ICON_ACTION:
               FarmStatsManager.count(EnglandOnboardingController.ENGLAND_ONBOARDING_STATS_COUNTER,"step1_start","recapture_hudicon");
               EnglandOnboardingController.getInstance().startOnboarding();
               break;
            case LimitedSaleUtility.LIMITED_SALE_ICON_NAME:
               LimitedSaleUtility.instance().conditionallyOpenSaleDialog();
               FarmStatsManager.count(TargetedLimitedSaleWindow.SALE_ACTIVITY_COUNTER,"hud_icon","click");
               break;
            case LESurfacingManager.HUD_ICON_ACTION_KEY:
               LESurfacingManager.instance.showUI();
               FarmStatsManager.count("le_display_promo","hud_icon","le_display_" + LESurfacingManager.MAX_NUMBER_SLOTS,"click");
               break;
            case "CastleXPromoAction":
               FarmStatsManager.count("right_HUD","xpromo","click","223");
               GlobalEngine.socialNetwork.redirect(CrossPromoConstants.CASTLE_XPROMO_URL,null,"_blank",false);
               break;
            case "limitedGifting":
               if(this.extraData != null && this.extraData.hasOwnProperty("giftingUIUrl") && this.extraData.hasOwnProperty("friendsList") && this.extraData.hasOwnProperty("featureName"))
               {
                  FarmStatsManager.count("dialog",this.extraData.featureName,"sender","HUD_click");
                  dialog = new LimitedGiftingWindow(this.extraData);
                  UI.displayPopup(dialog,false,this.extraData.featureName,true);
               }
               break;
            case "limitedGiftingRecipient":
               if(this.extraData != null)
               {
                  FarmStatsManager.count("dialog",this.extraData.featureName,"recipient","HUD_click");
                  recipientFeatureConfig = FeatureConfigManager.getFeatureConfiguration(this.extraData.featureName + "Recipient");
                  recipientPopup = new LimitedGiftingRecipientWindow(this.extraData);
                  UI.displayPopup(recipientPopup,false,this.extraData.featureName + "Recipient",true);
               }
               break;
            case HolidayCountdownManager.DEFAULT_FEATURE_NAME:
               HolidayCountdownManager.recordHudIconStats("clicks");
               HolidayCountdownManager.displayDialog();
               break;
            case FaceOffManager.DEFAULT_FEATURE_NAME:
               FaceOffManager.getInstance().displayDialog();
               break;
            case "HCXPromoAction":
               FarmStatsManager.count("right_HUD","xpromo","click","115");
               GlobalEngine.socialNetwork.redirect(CrossPromoConstants.HC_XPROMO_URL,null,"_blank",false);
               break;
            case "BingoPromoAction":
               FarmStatsManager.count("right_HUD","xpromo","click","235");
               GlobalEngine.socialNetwork.redirect(CrossPromoConstants.BINGO_XPROMO_URL,null,"_blank",false);
               break;
            case "SlingoPromoAction":
               FarmStatsManager.count("right_HUD","xpromo","click","114");
               GlobalEngine.socialNetwork.redirect(CrossPromoConstants.SLINGO_XPROMO_URL_HUD,null,"_blank",false);
               break;
            case "BubblePromoAction":
               FarmStatsManager.count("hud_icon","xpromo","launch_game_click","243");
               GlobalEngine.socialNetwork.redirect(CrossPromoConstants.BUBBLE_XPROMO_URL_HUD,null,"_blank",false);
               break;
            case "TheVillePromoAction":
               FarmStatsManager.count("hud_icon","xpromo","launch_game_click","90");
               GlobalEngine.socialNetwork.redirect(CrossPromoConstants.THEVILLE_XPROMO_URL_HUD,null,"_blank",false);
               break;
            case "ChefVillePromoAction":
               FarmStatsManager.count("hud_icon","xpromo","launch_game_click","240");
               GlobalEngine.socialNetwork.redirect(CrossPromoConstants.CHEFVILLE_XPROMO_URL_HUD,null,"_blank",false);
               break;
            case "FarmVille2PromoAction":
               FarmStatsManager.count("hud_icon","xpromo","launch_game_click","118");
               GlobalEngine.socialNetwork.redirect(CrossPromoConstants.FARMVILLE2_XPROMO_URL_HUD,null,"_top",false);
               break;
            case "XPromoAction":
               FarmStatsManager.count("hud_icon","xpromo","launch_game_click",this.m_crossPromoGameId);
               GlobalEngine.socialNetwork.redirect(this.actionUrl,null,this.actionTarget,false);
               break;
            case "LESlotMachineLaunch":
               UI.displayPopup(new LESlotMachineWindow());
               Global.player.resetBackoffInterval(LESlotMachineWindow.EXPERIMENT_NAME);
               break;
            case "FCSlotMachineLaunch":
               FarmStatsManager.count("right_HUD","slots","click");
               UI.displayPopup(new FCSlotMachineWindow(FCSlotMachineWindow.ENTRY_POINT_HUD),true,FCSlotMachineWindow.WINDOW_NAME,true);
               break;
            case "TaskListLaunch":
               TaskListManager.getInstance().openTaskListWindow();
               break;
            case "SpendometerLaunch":
               SpendometerManager.instance.dispatchEvent(new DynamicObjectEvent(SpendometerManager.SHOW_SPENDOMETER_DIALOG,{"source":"hud"}));
               break;
            case "QuestManagerLaunch":
               UI.setCursor(null);
               QuestManagerDisplay.getInstance().openQuestManagerWindow();
               break;
            case "lottery":
               LotteryManager.instance.logLotteryStats("dialog","hud","click");
               lotteryWindow = new LotteryMainWindow();
               UI.displayPopup(lotteryWindow,false,"lotteryMain",true);
               break;
            case "ContentAccess":
               if(Boolean(this.extraData) && Boolean(this.extraData.contentAccessSettingsName))
               {
                  contentAccessSettings = Global.farmGameSettingsManager.getContentAccessSettings(this.extraData.contentAccessSettingsName);
                  if(contentAccessSettings)
                  {
                     contentPurchaseWindow = new ExpansionOnboardingWindow(contentAccessSettings.dialogURL,ZLocUtils.t("Dialogs","BuyContentAccess"),this.unlockEarlyExpansionContent);
                     UI.displayPopup(contentPurchaseWindow,false,"ContentAccess",true);
                  }
               }
               break;
            case "ScratchCardAction":
               UI.displayPopup(new ScratchCardWindow(ScratchCardWindow.SCRATCH_CARD_ENTRY_DESCRIPTOR_HUD),true,ScratchCardWindow.POPUP_NAME,true);
               break;
            case "CocoIconAction":
               FarmStatsManager.count("dialog","coconut_hud","click");
               InGameCurrencyConversion.showImpulseBuy(Currency.COCONUTS);
               break;
            case "CarnivalBoothWindow":
               FarmStatsManager.count("carnivalbooth","hud_icon","click");
               CarnivalBoothWindow.launchCarnivalBooth();
               break;
            case "OpenGenericMinigame":
               MinigameManager.instance.launchMinigameWindow(this.m_actionParams["minigameName"],"unique_icon");
               break;
            case "finishAllBuildingsWindow":
               FinishAllBuildingsUtil.conditionallyShowMOTD();
               break;
            case "OpenGenericThemedQuest":
               featureName = this.m_actionParams["themedQuestFeatureName"];
               if(featureName)
               {
                  themedQuestWindow = new ThemedQuestWindow(featureName);
                  UI.displayPopup(themedQuestWindow,false);
               }
               break;
            case "OpenItemContestWindow":
               FarmStatsManager.count(ItemContestManager.FEATURE_NAME,"surface_hud","view");
               ItemContestManager.getInstance().displayDialog();
               break;
            case "PrizeMachineWindow":
               FarmStatsManager.count(PrizeMachineWindow.STAT_COUNTER,"surface_hud","view");
               UI.displayPopup(new PrizeMachineWindow(),true,"PrizeMachineWindow",true);
               break;
            case "HangingGardens4Panel":
               if(HangingGardensManager.isInHangingGardensExperiment())
               {
                  FarmStatsManager.featureSample("Hanging_Gardens","HUD","clicks","FTUE / 4 Panel Dialog");
                  HangingGardensManager.instance.displayFourPanelDialog();
               }
               break;
            case "HangingGardensMOTD":
               if(false && HangingGardensManager.isInHangingGardensExperiment())
               {
                  TransactionManager.addTransaction(new TGetMOTD("MOTD_HANGING_GARDENS_2013",HangingGardensManager.instance.showHangingGardensMOTD),true);
               }
               break;
            case "OpenBingoWindow":
               BingoManager.getInstance().displayBingo();
               break;
            case "openCompletionPack":
               FarmStatsManager.count("HUD","clicks",BuildableCompletionPackagesManager.HUD_ICON_STAT);
               BuildableCompletionPackagesManager.getInstance().displayMainWindow();
               break;
            case "OpenBobBerryWindow":
               FarmStatsManager.count(this.iconName,"hud_icon","click");
               BobBerryManager.getInstance(this.iconName).showBobAndOpenWindow();
               break;
            case "OpenFarmRunWindow":
               FarmStatsManager.count(this.iconName,"hud_icon","click");
               FarmRunQuestManager.getInstance().openFarmRunQuestUI();
               break;
            case "OpenDreamWorldInnovation":
               FarmStatsManager.count(this.iconName,"hud_icon","click");
               DreamWorldInnovationManager.getInstance(this.iconName).showMainUI();
               break;
            case "OpenWhitewinterInnovation":
               FarmStatsManager.count(this.iconName,"hud_icon","click");
               WhitewinterInnovationManager.getInstance(this.iconName).showMainUI();
               break;
            case "":
               break;
            default:
               if(Config.DEBUG_MODE)
               {
                  UI.displayPopup(new GenericPopup("icon.action not recognized: " + this.action + "\nIf this icon is a proper subclass you can probably ignore this"));
               }
         }
         this.toolTip = "";
      }
      
      private function unlockEarlyExpansionContent() : void
      {
         if(Boolean(this.extraData) && Boolean(this.extraData.contentAccessSettingsName))
         {
            Global.player.purchaseContentAccess(this.extraData.contentAccessSettingsName);
            Global.hud.rightSideIconQueue.removeIconByName(this.iconName);
         }
      }
      
      public function load() : void
      {
         if(this.imageUrl.indexOf("http://") == 0 || this.imageUrl.indexOf("https://") == 0 || this.imageUrl.indexOf("//") == 0)
         {
            this.m_Loader = LoadingManager.load(this.imageUrl,this.onButtonIconLoaded);
         }
         else
         {
            this.m_Loader = LoadingManager.load(Global.getAssetURL(this.imageUrl),this.onButtonIconLoaded);
         }
      }
      
      public function getContent() : DisplayObject
      {
         var result:DisplayObject = null;
         if(Boolean(this.m_Loader) && Boolean(this.m_Loader.content))
         {
            result = this.m_Loader.content;
         }
         return result;
      }
      
      protected function onButtonIconLoaded(event:Event) : void
      {
         var scale:Number = NaN;
         var xPadding:int = 0;
         var yPadding:int = 0;
         var clip:Bitmap = null;
         var mask:BitmapData = null;
         var matrix:Matrix = null;
         this.m_isLoaded = true;
         var content:DisplayObject = this.m_Loader.content;
         if(content != null)
         {
            scale = Math.min(BUTTON_SIZE / content.width * content.scaleX,BUTTON_SIZE / content.height * content.scaleY);
            content.scaleX = content.scaleY = scale;
            if(this.m_contentManip != null)
            {
               this.m_contentManip(content);
            }
            this.addChild(content);
            xPadding = 5;
            yPadding = 5;
            clip = new Bitmap();
            mask = new BitmapData(2 * xPadding + BUTTON_SIZE,2 * yPadding + BUTTON_SIZE,true,0);
            matrix = new Matrix();
            matrix.translate(xPadding,yPadding);
            mask.draw(this,matrix);
            clip.bitmapData = mask;
            this.alphaMask = new MovieClip();
            this.alphaMask.blendMode = BlendMode.ALPHA;
            this.alphaMask.addChild(clip);
            this.alphaMask.x = -BUTTON_SIZE / 2 - xPadding;
            this.alphaMask.y = -BUTTON_SIZE / 2 - yPadding;
            content.x = -BUTTON_SIZE / 2;
            content.y = -BUTTON_SIZE / 2;
            this.tweenIn();
            if(this.m_loadCompleteCallback != null)
            {
               this.m_loadCompleteCallback();
            }
         }
      }
      
      public function setExtraData(data:Object) : void
      {
         this.extraData = data;
      }
      
      public function tweenIn() : void
      {
         if(this.m_currentTween)
         {
            this.scaleY = this.scaleX = 1;
            TweenLite.removeTween(this.m_currentTween);
            this.m_currentTween = null;
         }
         else if(PerformanceExperimentManager.isInExtremePerformanceLimiterExperiment)
         {
            this.scaleY = this.scaleX = 1;
            MovieClipUtils.recursiveStop(this);
         }
         else
         {
            this.scaleY = this.scaleX = 0.1;
            this.m_currentTween = new TweenLite(this,0.25,{
               "scaleY":1,
               "scaleX":1,
               "ease":Cubic.easeOut,
               "onComplete":function():void
               {
                  m_currentTween = null;
               }
            });
         }
      }
      
      public function tweenDirection(oldIndex:int, direction:int) : void
      {
         var easing:Function = null;
         var newIndex:int = direction == TWEEN_UP ? int(oldIndex - 1) : int(oldIndex + 1);
         if(Boolean(this.m_currentTween) || !this.isLoaded)
         {
            this.y = (BUTTON_SIZE + BUTTON_PADDING) * newIndex;
            if(this.m_currentTween)
            {
               this.m_currentTween.complete(true);
            }
            this.m_currentTween = null;
         }
         else
         {
            this.y = (BUTTON_SIZE + BUTTON_PADDING) * oldIndex;
            easing = direction == TWEEN_DOWN ? Bounce.easeOut : Cubic.easeOut;
            this.m_currentTween = new TweenLite(this,1,{
               "y":(BUTTON_SIZE + BUTTON_PADDING) * newIndex,
               "ease":easing,
               "onComplete":function():void
               {
                  m_currentTween = null;
               }
            });
         }
      }
      
      public function tweenToY(newY:Number) : void
      {
         var easing:Function = null;
         if(!this.isLoaded || this.m_currentTween != null)
         {
            if(this.m_currentTween)
            {
               this.m_currentTween.complete(false);
            }
            this.y = newY;
         }
         else
         {
            easing = newY > this.y ? Cubic.easeOut : Bounce.easeOut;
            this.m_currentTween = new TweenLite(this,1,{
               "y":newY,
               "ease":easing,
               "onComplete":function():void
               {
                  m_currentTween = null;
               }
            });
         }
      }
      
      public function set loadCompleteCallback(callback:Function) : void
      {
         this.m_loadCompleteCallback = callback;
      }
      
      public function tweenOut() : void
      {
         var scale:Number;
         var icon:QueuedIcon = null;
         if(this.m_currentTween)
         {
            TweenLite.removeTween(this.m_currentTween);
            this.m_currentTween = null;
         }
         scale = this.scaleX;
         icon = this;
         this.m_currentTween = new TweenLite(this,0.25,{
            "scaleY":0,
            "scaleX":0,
            "ease":Cubic.easeOut,
            "onComplete":function():void
            {
               if(icon.parent)
               {
                  icon.parent.removeChild(icon);
               }
               scaleX = scaleY = 1;
               y = 0;
               m_currentTween = null;
            }
         });
      }
      
      public function set contentManip(imageManipulator:Function) : void
      {
         this.m_contentManip = imageManipulator;
      }
      
      public function get isLoaded() : Boolean
      {
         return this.m_isLoaded;
      }
      
      public function get visibilityPrereqs() : Array
      {
         return this.m_visibilityPrereqs;
      }
      
      public function displayPopup(callback:Function = null) : void
      {
         var popupType:int = 0;
         if(this.action != "")
         {
            popupType = GenericPopup.TYPE_ACCEPTCANCEL;
         }
         else
         {
            popupType = GenericPopup.TYPE_OK;
         }
         UI.displayPopup(new GenericPopup(ZLocUtils.t("Dialogs",this.iconName + "_iconPopup"),popupType,callback));
      }
      
      public function doClickStats() : void
      {
      }
      
      override protected function onRollOver(event:MouseEvent) : void
      {
         var timeLeft:int = 0;
         if(Boolean(this.extraData) && Boolean(this.extraData.iconTooltip))
         {
            toolTip = this.extraData.iconTooltip;
         }
         else
         {
            timeLeft = Math.max(0,this.m_expirationTime - GlobalEngine.currentTime);
            toolTip = ZLocUtils.t("Dialogs",this.iconName + "_iconTooltip",{"quantity":FarmGameUtil.toFriendlyTime(timeLeft / 1000)});
         }
         super.onRollOver(event);
      }
      
      public function set category(setCategory:String) : void
      {
         this.m_category = setCategory;
      }
      
      public function get category() : String
      {
         var result:String = null;
         if(this.m_category != null && this.m_category != "")
         {
            result = this.m_category;
         }
         else
         {
            result = CategorizedDynamicIconQueue.ICON_TYPE_MARKETING;
         }
         return result;
      }
      
      public function set side(side:int) : void
      {
         this.m_side = side;
      }
   }
}

