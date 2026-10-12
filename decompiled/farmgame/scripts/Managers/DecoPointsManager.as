package Managers
{
   import Classes.Constants.Experiments;
   import Classes.Farmstamatic.IFarmstamaticFeatureComponent;
   import Classes.Idle.GenericCallbackIdleTask;
   import Classes.Idle.IdleTaskQueue;
   import Classes.ItemInstance;
   import Classes.Leaderboard.Leaderboard;
   import Classes.PhotoContestScoreData;
   import Classes.PhotoGalleryImageData;
   import Classes.ZItem.FarmItem;
   import Classes.util.UserRewardUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Classes.WorldObject;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import GameMode.GMFarmstamatic;
   import GameMode.GameMode;
   import Transactions.TActOnContestGalleryData;
   import Transactions.TransactionWithCallBack;
   import Widgets.Windows.DecoPoints.DecoPointsFarmstamaticDialog;
   import Widgets.Windows.DecoPoints.DecoPointsMainWindow;
   import Widgets.Windows.DecoPoints.DecoPointsVoteTab;
   import Widgets.Windows.FarmstamaticTakePhoto;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.geom.Rectangle;
   
   public class DecoPointsManager extends EventDispatcher implements IFarmstamaticFeatureComponent
   {
      
      private static const m_instance:DecoPointsManager = new DecoPointsManager(SingletonLock);
      
      public static const MAX_NUM_ITEMS_FROM_PHOTO:int = 20;
      
      public static const MODE_VOTE:String = "vote";
      
      public static const MODE_SCORE:String = "score";
      
      public static const DIALOG_PHOTO_UI:String = "photoUI";
      
      public static const SUBMIT_GALLERY_UNSEEN:int = 0;
      
      public static const SUBMIT_GALLERY_SEEN:int = 1;
      
      public static const SUBMIT_GALLERY_VOTE:int = 2;
      
      public static const SUBMIT_GALLERY_ABUSE:int = 3;
      
      public static const REFETCH_GALLERY_TIMER:int = 300;
      
      private static const FEATURE_NAME:String = "photocontest";
      
      private static const IMAGE_URL_PREFIX_DEV:String = "http://farmville.s3.amazonaws.com/ugcImages_dev/";
      
      private static const IMAGE_URL_PREFIX_PROD:String = "ugcImages/";
      
      private static const IMAGE_URL_REMOVE_STRING:String = "assets/hashed/";
      
      public static const IMAGE_URL_SUFFIX:String = ".png";
      
      public static const FEATURE_OPTION_KEY_URL:String = "url";
      
      public static const FEATURE_OPTION_KEY_PROMOTE:String = "Promote";
      
      public static const PROMOTE_KEY_START:String = "start";
      
      private static const FEATURE_OPTION_KEY_ALLOW_SHOW_PROFILE_IMAGE:String = "allowShowProfileImage";
      
      public static const MODE_TOPPHOTOS:String = "topPhotos";
      
      public static const DECOPOINTS_FEED:String = "feed";
      
      public static const DECOPOINTSCLASS:String = "DecoPoints";
      
      public static const DECOPOINTS_COUNTER:String = "deco_points";
      
      public static const DECOPOINTS_TOPBAR:String = "hud_top_bar";
      
      public static const DECOPOINTS_ACTIONMENU:String = "action_menu";
      
      public static const DECOPOINTS_AUTOPOP:String = "auto_pop";
      
      public static const DECOPOINTS_POINTS_PHYLUM:String = "points";
      
      public static const DECOPOINTS_POINTS_DECO:String = "deco";
      
      public static const DECOPOINTS_DIALOG:String = "dialog";
      
      public static const DECOPOINTS_DIALOG_VIEW:String = "view";
      
      public static const DECOPOINTS_DIALOG_CLICK:String = "click";
      
      public static const DECOPOINTS_DIALOG_CANCEL:String = "cancel";
      
      public static const DECOPOINTS_DIALOG_TAKE_PIC:String = "take_picture";
      
      public static const DECOPOINTS_DIALOG_FLAG_CONTENT:String = "flag_content";
      
      public static const DECOPOINTS_DIALOG_ASK_VOTES:String = "ask_votes";
      
      public static const DECOPOINTS_DIALOG_WHATSTHIS:String = "what_is_this";
      
      public static const DECOPOINTS_DIALOG_SUBMIT_PIC:String = "submit_picture";
      
      public static const DECOPOINTS_POINTS_GALLERY:String = "gallery";
      
      public static const DECOPOINTS_POINTS_GALLERY_SUBMIT:String = "submit";
      
      public static const DECOPOINTS_POINTS_GALLERY_VOTE:String = "vote";
      
      public static const DECOPOINTS_POINTS_GALLERY_RECEIVE:String = "received";
      
      public static const DECOPOINTS_CONTEST_DATA_LOADED:String = "decopoints_contest_data_loaded";
      
      private const PROMOTE_DURATION_STRING:String = "PhotoContestPromoteDuration";
      
      private var m_currentWeeklyContestName:String = null;
      
      private var m_galleryImageData:Array = null;
      
      private var m_photoContestScoreData:PhotoContestScoreData = null;
      
      private var m_mainDecoPointsUI:DecoPointsMainWindow = null;
      
      private var m_waitOnTransaction:Boolean = false;
      
      private var m_isInitialized:Boolean;
      
      private var m_hasStartedInit:Boolean;
      
      private var m_topPhotos:Array;
      
      private var m_allowShowProfileImage:Boolean;
      
      public function DecoPointsManager(lock:Class)
      {
         super();
         if(lock != SingletonLock)
         {
            throw new Error("Invalid DecoPointsManager Singleton access. Use DecoPointsManager.instance");
         }
      }
      
      public static function get instance() : DecoPointsManager
      {
         return m_instance;
      }
      
      public static function closeMainWindowOnPurchase(event:Event) : void
      {
         instance.closeMainWindow();
      }
      
      public static function sortOnPrice(item1:FarmItem, item2:FarmItem) : int
      {
         var result:int = 0;
         var realCashResult:int = 0;
         if(item1.realCashCost > item2.realCashCost)
         {
            realCashResult = 1;
         }
         else if(item1.realCashCost < item2.realCashCost)
         {
            realCashResult = -1;
         }
         else
         {
            realCashResult = 0;
         }
         if(item1.isCash)
         {
            if(item2.isCash)
            {
               result = realCashResult;
            }
            else
            {
               result = 1;
            }
         }
         else if(item2.isCash)
         {
            result = -1;
         }
         else if(item1.buyableWithCash())
         {
            if(item2.buyableWithCash())
            {
               result = realCashResult;
            }
            else
            {
               result = 1;
            }
         }
         else if(item2.buyableWithCash())
         {
            result = -1;
         }
         else if(item1.realCost > item2.realCost)
         {
            result = 1;
         }
         else if(item1.realCost < item2.realCost)
         {
            result = -1;
         }
         else
         {
            result = 0;
         }
         return result;
      }
      
      public static function validateAndSortItemCodes(itemCodes:Array) : Array
      {
         var item:FarmItem = null;
         var j:int = 0;
         var items:Array = new Array();
         var numItemCodes:int = int(itemCodes.length);
         for(var i:int = 0; i < numItemCodes; i++)
         {
            item = Global.farmGameSettingsManager.getFarmItemByCode(itemCodes[i]);
            if(Boolean(item) && item.isVisible)
            {
               items.push(item);
            }
         }
         itemCodes = new Array();
         numItemCodes = int(items.length);
         if(numItemCodes > 0)
         {
            items.sort(sortOnPrice,Array.DESCENDING);
            i = 0;
            j = 0;
            while(j < MAX_NUM_ITEMS_FROM_PHOTO && i < numItemCodes)
            {
               if(itemCodes.indexOf(items[i].code) == -1)
               {
                  itemCodes.push(items[i].code);
                  j++;
               }
               i++;
            }
         }
         return itemCodes;
      }
      
      public static function getFullImageUrl(url:String) : String
      {
         var constructedUrl:String = getImagePrefix() + url + IMAGE_URL_SUFFIX;
         if(!Config.DEBUG_MODE)
         {
            constructedUrl = GlobalEngine.getAssetUrl(constructedUrl);
            constructedUrl = constructedUrl.replace(IMAGE_URL_REMOVE_STRING,"");
         }
         return constructedUrl;
      }
      
      private static function getImagePrefix() : String
      {
         return (Config.DEBUG_MODE ? IMAGE_URL_PREFIX_DEV : IMAGE_URL_PREFIX_PROD) + FEATURE_NAME + "/";
      }
      
      public static function requestContestDataWithCallback(callback:Function, checkPhotoContestPrereqs:Boolean = true) : Boolean
      {
         var transaction:TransactionWithCallBack = null;
         var success:Boolean = false;
         var leaderboard:Leaderboard = Global.leaderboardConfigSettings.getActivePhotoContest(checkPhotoContestPrereqs);
         if(leaderboard != null && leaderboard.name != null)
         {
            transaction = new TransactionWithCallBack("PhotoContestService.onGetContestData",callback,leaderboard.name);
            TransactionManager.addTransaction(transaction);
            success = true;
         }
         return success;
      }
      
      public static function parsePhotoContestData(contestData:Object) : Object
      {
         var result:Object = new Object();
         if(contestData.hasOwnProperty("gallery"))
         {
            result["gallery"] = parseGalleryDataFromRawData(contestData["gallery"]);
         }
         if(contestData.hasOwnProperty("topPhotos"))
         {
            result["topPhotos"] = parseTopPhotosDataFromRawData(contestData["topPhotos"]);
         }
         if(contestData.hasOwnProperty("user"))
         {
            result["user"] = parseUserDataFromRawData(contestData["user"]);
         }
         return result;
      }
      
      private static function parseGalleryDataFromRawData(result:Object) : Array
      {
         var galleryData:Object = null;
         var photoGalleryData:PhotoGalleryImageData = null;
         var key:String = null;
         var instData:Object = null;
         var photoData:Array = new Array();
         if(result.hasOwnProperty("galleryData") && result["galleryData"] != null)
         {
            galleryData = result["galleryData"];
            for(key in galleryData)
            {
               instData = galleryData[key];
               instData["key"] = key;
               photoGalleryData = new PhotoGalleryImageData(instData);
               photoData.push(photoGalleryData);
            }
         }
         return photoData;
      }
      
      private static function parseUserDataFromRawData(result:Object) : PhotoContestScoreData
      {
         var photoScore:PhotoContestScoreData = new PhotoContestScoreData();
         if(result.hasOwnProperty("votes") && result["votes"] != null)
         {
            photoScore.score = result["votes"];
         }
         if(result.hasOwnProperty("url") && result["url"] != null)
         {
            photoScore.imageUrl = DecoPointsManager.getFullImageUrl(result["url"]);
            photoScore.key = result["url"];
         }
         if(result.hasOwnProperty("rewardData") && result["rewardData"].length > 0)
         {
            UserRewardUtil.grantUserRewardsFromArray(result["rewardData"]);
         }
         if(result.hasOwnProperty("isAbusive"))
         {
            photoScore.isAbusive = result["isAbusive"];
         }
         return photoScore;
      }
      
      private static function parseTopPhotosDataFromRawData(result:Array) : Array
      {
         var topPhoto:Object = null;
         for each(topPhoto in result)
         {
            if(topPhoto.hasOwnProperty("itemCodes") && topPhoto["itemCodes"] != null)
            {
               topPhoto["itemCodes"] = validateAndSortItemCodes(topPhoto["itemCodes"]);
            }
         }
         return result;
      }
      
      private static function getPurchasableItemsInPhoto() : Array
      {
         var photoRect:Rectangle = null;
         var objectsInViewport:Array = null;
         var worldObject:WorldObject = null;
         var itemInst:ItemInstance = null;
         var itemCodes:Array = new Array();
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_DP_ITEM_TAGGING) >= 1)
         {
            photoRect = new Rectangle(GlobalEngine.viewport.getBitmapData().rect.width / 2 - FarmstamaticTakePhoto.PHOTO_SIZE_X / 2,GlobalEngine.viewport.getBitmapData().rect.height / 2 - FarmstamaticTakePhoto.PHOTO_SIZE_Y / 2,FarmstamaticTakePhoto.PHOTO_SIZE_X,FarmstamaticTakePhoto.PHOTO_SIZE_Y);
            objectsInViewport = Global.world.getVisibleObjects();
            for each(worldObject in objectsInViewport)
            {
               if(!worldObject.hasOwnProperty("gender"))
               {
                  if(worldObject.isWithinRect(photoRect))
                  {
                     itemInst = worldObject as ItemInstance;
                     itemCodes.push(Global.farmGameSettingsManager.getFarmItemCodeByName(itemInst.getItemName()));
                  }
               }
            }
            itemCodes = validateAndSortItemCodes(itemCodes);
         }
         return itemCodes;
      }
      
      public function hasMainWindow() : Boolean
      {
         return this.m_mainDecoPointsUI != null;
      }
      
      public function closeMainWindow() : void
      {
         if(this.m_mainDecoPointsUI)
         {
            this.m_mainDecoPointsUI.close();
         }
      }
      
      private function removeMainWindowReference(event:Event) : void
      {
         if(this.m_mainDecoPointsUI != null)
         {
            this.m_mainDecoPointsUI.removeEventListener(Event.CLOSE,this.removeMainWindowReference);
         }
         this.m_mainDecoPointsUI = null;
      }
      
      public function getWeeklyPhotoContestTitle() : String
      {
         var prefix:String = this.getWeeklyContestName() + "ContestTitle";
         return ZLocUtils.t("Dialogs",prefix);
      }
      
      public function isGalleryImagesAvailableToVote(fetch:Boolean = false) : Boolean
      {
         var result:Boolean = this.m_galleryImageData != null && this.m_galleryImageData[DecoPointsVoteTab.LEFT_IMAGE_INDEX] != null && this.m_galleryImageData[DecoPointsVoteTab.RIGHT_IMAGE_INDEX] != null;
         if(fetch && !result)
         {
            this.getGalleryImagesForVoting();
         }
         return result;
      }
      
      public function waitingOnCallBack() : Boolean
      {
         return this.m_waitOnTransaction == true;
      }
      
      public function getNextContestPhotoToVote(index:Number) : PhotoGalleryImageData
      {
         var photoGalleryImageData:PhotoGalleryImageData = null;
         if(this.isGalleryImagesAvailableToVote())
         {
            photoGalleryImageData = this.m_galleryImageData[index];
         }
         else
         {
            this.m_galleryImageData = null;
         }
         return photoGalleryImageData;
      }
      
      public function actOnGalleryData(obj:Object) : void
      {
         if(obj != null)
         {
            TransactionManager.addTransaction(new TActOnContestGalleryData(obj));
            if(this.isGalleryImagesAvailableToVote())
            {
               this.askPlayerToSubmitPhoto();
               this.m_galleryImageData.shift();
               this.m_galleryImageData.shift();
            }
         }
      }
      
      private function askPlayerToSubmitPhoto() : void
      {
         if(this.shouldAskPhotoSubmission())
         {
            UI.displayMessage(ZLocUtils.t("Dialogs","DPVoteTab_EncouragePhotoSubmission"),GenericPopup.TYPE_YESNO,this.submitContestPhoto);
         }
      }
      
      private function shouldAskPhotoSubmission() : Boolean
      {
         return this.m_galleryImageData != null && this.m_galleryImageData.length <= 2 && this.getCurrentContestPhoto() == null && !Global.player.getSeenFlag(this.getSeenFlagForSubmitPhoto());
      }
      
      private function submitContestPhoto(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.YES)
         {
            FarmStatsManager.count(DecoPointsManager.DECOPOINTS_COUNTER,"",DecoPointsManager.DECOPOINTS_DIALOG,DecoPointsManager.DECOPOINTS_DIALOG_TAKE_PIC,MODE_VOTE);
            this.startFarmstamaticGameMode();
         }
         Global.player.setSeenFlag(this.getSeenFlagForSubmitPhoto());
      }
      
      private function getSeenFlagForSubmitPhoto() : String
      {
         return this.getCurrentContestPhoto() + "_promptSubmit";
      }
      
      public function isBlockedFromPosting() : Boolean
      {
         var isBlocked:Boolean = false;
         if(this.m_photoContestScoreData != null)
         {
            isBlocked = this.m_photoContestScoreData.isAbusive;
         }
         return isBlocked;
      }
      
      public function getCurrentContestPhoto() : String
      {
         var featureOptionData:Object = null;
         var imageUrl:String = null;
         if(this.m_photoContestScoreData != null)
         {
            imageUrl = this.m_photoContestScoreData.imageUrl;
         }
         else
         {
            featureOptionData = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.PHOTO_CONTEST,this.getWeeklyContestName());
            if(Boolean(featureOptionData != null) && Boolean(featureOptionData[FEATURE_OPTION_KEY_URL]) && featureOptionData[FEATURE_OPTION_KEY_URL] != "")
            {
               imageUrl = DecoPointsManager.getFullImageUrl(featureOptionData[FEATURE_OPTION_KEY_URL]);
            }
         }
         return imageUrl;
      }
      
      public function isPromotePhotoActive() : Boolean
      {
         var promoteData:Object = null;
         var startTime:int = 0;
         var currentTime:Number = NaN;
         var result:Boolean = false;
         var featureName:String = this.getWeeklyContestName();
         var featureOptionData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.PHOTO_CONTEST,featureName);
         if(Global.player.getSeenFlag(featureName + FEATURE_OPTION_KEY_PROMOTE))
         {
            result = true;
         }
         else if(Boolean(featureOptionData != null) && Boolean(featureOptionData[FEATURE_OPTION_KEY_PROMOTE]) && featureOptionData[FEATURE_OPTION_KEY_PROMOTE] != null)
         {
            promoteData = featureOptionData[FEATURE_OPTION_KEY_PROMOTE];
            startTime = int(promoteData[PROMOTE_KEY_START]);
            currentTime = GlobalEngine.serverTime / 1000;
            result = currentTime < startTime + Global.farmGameSettingsManager.getNumber(this.PROMOTE_DURATION_STRING);
         }
         return result;
      }
      
      public function setPromotePhotoActive() : void
      {
         var featureName:String = this.getWeeklyContestName();
         TransactionManager.addTransaction(new TransactionWithCallBack("PhotoContestService.onBuyPromoteUser",null,featureName));
         Global.player.setSeenFlag(featureName + FEATURE_OPTION_KEY_PROMOTE,true,true);
      }
      
      public function getHashKeyOfActiveContestPhoto() : String
      {
         var result:String = "";
         if(this.m_photoContestScoreData != null)
         {
            result = this.m_photoContestScoreData.key;
         }
         return result;
      }
      
      public function getWeeklyContestName() : String
      {
         var leaderboard:Leaderboard = null;
         if(this.m_currentWeeklyContestName == null)
         {
            leaderboard = Global.leaderboardConfigSettings.getActivePhotoContest();
            if(leaderboard != null)
            {
               this.m_currentWeeklyContestName = leaderboard.name;
            }
         }
         return this.m_currentWeeklyContestName;
      }
      
      public function getWeeklyPhotoContestTheme() : String
      {
         var prefix:String = this.getWeeklyContestName() + "ContestTheme";
         return ZLocUtils.t("Dialogs",prefix);
      }
      
      public function getTotalVotes() : Number
      {
         var score:Number = 0;
         if(this.m_photoContestScoreData != null)
         {
            score = this.m_photoContestScoreData.score;
         }
         return score;
      }
      
      public function getGalleryImagesForVoting() : void
      {
         if(!this.waitingOnCallBack())
         {
            TransactionManager.addTransaction(new TransactionWithCallBack("PhotoContestService.onGetGalleryForVote",this.onGalleryLoaded,this.getWeeklyContestName()));
            this.m_waitOnTransaction = true;
         }
      }
      
      public function getTopPhotos() : Array
      {
         return this.m_topPhotos;
      }
      
      public function hasStartedInit() : Boolean
      {
         return this.m_hasStartedInit;
      }
      
      public function init() : void
      {
         var transaction:TransactionWithCallBack = null;
         var featureOptionsManager:FeatureOptionsManager = null;
         var currentContest:String = this.getWeeklyContestName();
         if(!this.m_hasStartedInit && Boolean(currentContest))
         {
            this.m_hasStartedInit = true;
            this.m_waitOnTransaction = true;
            transaction = new TransactionWithCallBack("PhotoContestService.onGetContestData",this.onContestDataLoaded,currentContest);
            TransactionManager.addTransaction(transaction);
            this.m_allowShowProfileImage = true;
            featureOptionsManager = FeatureOptionsManager.getInstance();
            if(featureOptionsManager.loaded)
            {
               this.readInFeatureOptions();
            }
            else
            {
               featureOptionsManager.addEventListener(FeatureOptionsManager.EVENT_FEATURE_OPTIONS_LOADED,this.onFeatureOptionsLoaded);
            }
         }
      }
      
      private function onFeatureOptionsLoaded(event:Event) : void
      {
         FeatureOptionsManager.getInstance().removeEventListener(FeatureOptionsManager.EVENT_FEATURE_OPTIONS_LOADED,this.onFeatureOptionsLoaded);
         this.readInFeatureOptions();
      }
      
      private function readInFeatureOptions() : void
      {
         var featureOptionData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.PHOTO_CONTEST,this.getWeeklyContestName());
         if(featureOptionData != null && featureOptionData.hasOwnProperty(FEATURE_OPTION_KEY_ALLOW_SHOW_PROFILE_IMAGE))
         {
            this.m_allowShowProfileImage = featureOptionData[FEATURE_OPTION_KEY_ALLOW_SHOW_PROFILE_IMAGE];
         }
         else
         {
            this.m_allowShowProfileImage = true;
         }
      }
      
      public function resetInitState() : void
      {
         if(this.isInitialized())
         {
            this.m_hasStartedInit = false;
            this.m_isInitialized = false;
         }
      }
      
      public function isInitialized() : Boolean
      {
         return this.m_isInitialized;
      }
      
      private function refreshCurrentContestPhoto(url:String, fullUrl:Boolean = false) : void
      {
         if(url != null)
         {
            url = fullUrl ? url : DecoPointsManager.getFullImageUrl(url);
            if(this.m_photoContestScoreData == null)
            {
               this.m_photoContestScoreData = new PhotoContestScoreData();
            }
            this.m_photoContestScoreData.imageUrl = url;
            this.m_photoContestScoreData.key = fullUrl ? this.getImageKeyFromS3(url) : url;
            this.m_photoContestScoreData.isAbusive = false;
         }
      }
      
      private function getImageKeyFromS3(url:String) : String
      {
         var startIndex:Number = url.indexOf(FEATURE_NAME) + FEATURE_NAME.length;
         var endIndex:Number = url.length - IMAGE_URL_SUFFIX.length;
         return url.substring(startIndex + 1,endIndex);
      }
      
      public function openDecoPointsMainUI(askForVotes:Boolean = false) : void
      {
         this.init();
         if(this.getWeeklyContestName() != null)
         {
            this.m_mainDecoPointsUI = new DecoPointsMainWindow(MODE_SCORE,askForVotes);
            UI.displayPopup(this.m_mainDecoPointsUI,false,"DecoPointsMain",true);
            this.m_mainDecoPointsUI.addEventListener(Event.CLOSE,this.removeMainWindowReference);
         }
         else
         {
            UI.displayMessage(ZLocUtils.t("Dialogs","WeeklyPhotoContest_not_active"));
         }
      }
      
      public function startFarmstamaticGameMode() : void
      {
         if(this.m_mainDecoPointsUI)
         {
            this.m_mainDecoPointsUI.close();
            Global.world.addGameMode(new GMFarmstamatic(false,true,this),true);
         }
      }
      
      private function onContestDataLoaded(results:Object) : void
      {
         if(results.hasOwnProperty("gallery"))
         {
            this.loadGalleryDataFromRawData(results["gallery"]);
         }
         if(results.hasOwnProperty("topPhotos"))
         {
            this.loadTopPhotosDataFromRawData(results["topPhotos"]);
         }
         if(results.hasOwnProperty("user"))
         {
            this.loadUserDataFromRawData(results["user"]);
         }
         this.m_isInitialized = true;
         if(this.isGalleryImagesAvailableToVote(false) == false)
         {
            IdleTaskQueue.getInstance().addTask(new GenericCallbackIdleTask(this.resetInitState,REFETCH_GALLERY_TIMER));
         }
         this.m_waitOnTransaction = false;
         if(this.m_mainDecoPointsUI)
         {
            this.m_mainDecoPointsUI.onDataLoaded();
         }
      }
      
      public function onGalleryLoaded(results:Object) : void
      {
         this.loadGalleryDataFromRawData(results);
         this.m_waitOnTransaction = false;
         if(this.m_mainDecoPointsUI)
         {
            this.m_mainDecoPointsUI.onGalleryLoaded();
         }
      }
      
      private function loadGalleryDataFromRawData(result:Object) : void
      {
         var galleryImageData:Array = parseGalleryDataFromRawData(result);
         if(galleryImageData.length > 0)
         {
            this.m_galleryImageData = galleryImageData;
         }
      }
      
      private function loadUserDataFromRawData(result:Object) : void
      {
         this.m_photoContestScoreData = parseUserDataFromRawData(result);
      }
      
      private function loadTopPhotosDataFromRawData(result:Array) : void
      {
         this.m_topPhotos = parseTopPhotosDataFromRawData(result);
      }
      
      public function enableVoteTab() : void
      {
         if(this.m_mainDecoPointsUI)
         {
            this.m_mainDecoPointsUI.enableVoteTab();
         }
      }
      
      public function set allowShowProfileImage(allow:Boolean) : void
      {
         this.m_allowShowProfileImage = allow;
      }
      
      public function get allowShowProfileImage() : Boolean
      {
         return this.m_allowShowProfileImage;
      }
      
      public function getSubmitPhotoParams() : Object
      {
         return {
            "featureEventId":this.getWeeklyContestName(),
            "allowShowProfileImage":this.m_allowShowProfileImage,
            "itemCodes":getPurchasableItemsInPhoto()
         };
      }
      
      public function onSubmitPhotoResult(result:Object) : void
      {
         if(result.hasOwnProperty("rewardData") && result["rewardData"].length > 0)
         {
            FarmStatsManager.count(DecoPointsManager.DECOPOINTS_COUNTER,"",DecoPointsManager.DECOPOINTS_POINTS_PHYLUM,DecoPointsManager.DECOPOINTS_POINTS_GALLERY,DECOPOINTS_POINTS_GALLERY_SUBMIT);
            UserRewardUtil.grantUserRewardsFromArray(result["rewardData"]);
         }
         if(result.hasOwnProperty("imagePath"))
         {
            this.refreshCurrentContestPhoto(result["imagePath"],true);
         }
         var seenFlag:String = this.getSeenFlagForNudgeAskVotes();
         if(!Global.player.getSeenFlag(seenFlag))
         {
            Global.player.setSeenFlag(seenFlag);
            UI.displayMessage(ZLocUtils.t("Dialogs","DPScoreTab_NudgeAskForVotes"),GenericPopup.TYPE_YESNO,this.openUIAndPostFeed);
         }
         FarmStatsManager.count(DecoPointsManager.DECOPOINTS_COUNTER,"",DecoPointsManager.DECOPOINTS_DIALOG,DecoPointsManager.DECOPOINTS_DIALOG_SUBMIT_PIC);
      }
      
      private function openUIAndPostFeed(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.YES)
         {
            this.openDecoPointsMainUI(true);
         }
         Global.player.setSeenFlag(this.getSeenFlagForSubmitPhoto());
      }
      
      private function getSeenFlagForNudgeAskVotes() : String
      {
         return this.getWeeklyContestName() + "_AskVotes";
      }
      
      public function getSubmitPhotoTransactionData() : Object
      {
         return {"photoContest":true};
      }
      
      public function createFarmstamaticDialog(gameMode:GameMode) : Sprite
      {
         return new DecoPointsFarmstamaticDialog(gameMode,this) as Sprite;
      }
      
      public function getFeatureName() : String
      {
         return FEATURE_NAME;
      }
   }
}

class SingletonLock
{
   
   public function SingletonLock()
   {
      super();
   }
}
