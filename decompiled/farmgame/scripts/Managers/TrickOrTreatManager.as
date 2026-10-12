package Managers
{
   import Classes.Friend;
   import Classes.MapResource;
   import Classes.NeighborActions.BaseNeighborAction;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Classes.WorldObject;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import GameMode.GMHalloweenTrick;
   import Transactions.TCancelFriendReward;
   import Transactions.TTrickOrTreatOffBoard;
   import Widgets.HUD.TrickOrTreatHUD;
   import Widgets.Windows.TrickOrTreatWindow;
   import flash.utils.getQualifiedClassName;
   
   public class TrickOrTreatManager
   {
      
      public static const FEATURE_NAME:String = "trickortreat";
      
      public static const TOKEN_OFFBOARDING:String = "OffBoardingV2";
      
      public static const TOKEN_PASS_NEIGHBOR:String = "PassNeighbor";
      
      public static const TRICKED_NEIGHBOR_ACTION:String = "TrickNeighborAction";
      
      private static const m_instance:TrickOrTreatManager = new TrickOrTreatManager(SingletonLock);
      
      private var m_configuration:FeatureConfigManager;
      
      private var m_gmHalloweenTrick:GMHalloweenTrick;
      
      private var m_rewardLink:String;
      
      private var m_latestReward:String;
      
      private var m_latestFeedId:String;
      
      private var m_hasSeenToaster:Boolean = false;
      
      private var m_trickOrTreatDialog:TrickOrTreatWindow;
      
      public function TrickOrTreatManager(lock:Class)
      {
         super();
         if(lock != SingletonLock)
         {
            throw new Error("Invalid TrickOrTreatManager Singleton access. Use TrickOrTreatManager.instance");
         }
      }
      
      public static function get instance() : TrickOrTreatManager
      {
         return m_instance;
      }
      
      public function get featureName() : String
      {
         return FEATURE_NAME;
      }
      
      public function get featureCreditName() : String
      {
         return this.featureName;
      }
      
      public function get altGraphicCreditName() : String
      {
         return this.featureName;
      }
      
      public function set trickOrTreatDialog(dialog:TrickOrTreatWindow) : void
      {
         this.m_trickOrTreatDialog = dialog;
      }
      
      public function get trickOrTreatDialog() : TrickOrTreatWindow
      {
         return this.m_trickOrTreatDialog;
      }
      
      public function init(data:Object) : void
      {
         var shouldShowHUD:Boolean = false;
         var expiredHUDClicked:Number = NaN;
         var timeLapsedHUDClicked:Number = NaN;
         if(this.m_configuration == null)
         {
            this.m_configuration = FeatureConfigManager.getFeatureConfiguration(this.featureCreditName);
            shouldShowHUD = true;
            if(this.m_configuration.isFeatureVisible())
            {
               if(this.isOffBoarding())
               {
                  expiredHUDClicked = Global.player.getFeatureLastShown(this.featureCreditName + TOKEN_OFFBOARDING);
                  timeLapsedHUDClicked = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - expiredHUDClicked;
                  if(expiredHUDClicked != 0 && timeLapsedHUDClicked > FarmGameUtil.NUM_SECS_IN_DAY)
                  {
                     shouldShowHUD = false;
                  }
               }
            }
            else
            {
               shouldShowHUD = false;
            }
            if(shouldShowHUD)
            {
               Global.hud.trickOrTreatIcon = new TrickOrTreatHUD();
            }
         }
      }
      
      public function isOffBoarding() : Boolean
      {
         var timeLeft:Array = null;
         if(this.m_configuration == null)
         {
            this.init(null);
         }
         var result:Boolean = false;
         if(this.m_configuration.isFeatureVisible())
         {
            timeLeft = this.m_configuration.getTimeRemaining();
            if(timeLeft[0] < this.m_configuration.getNumberConstant("offBoardingTime"))
            {
               result = true;
            }
         }
         return result;
      }
      
      public function offBoardUser() : void
      {
         TransactionManager.addTransaction(new TTrickOrTreatOffBoard(this.featureCreditName,this.shareDialog));
         Global.player.setFeatureLastShown(this.featureCreditName + TOKEN_OFFBOARDING,GlobalEngine.currentTime,true);
      }
      
      public function shareDialog(result:Object) : void
      {
         var farmItem:FarmItem = null;
         var dialogKey:String = null;
         var stringReplacements:Object = null;
         var message:String = null;
         var popup:GenericIconPopup = null;
         var friend:Friend = null;
         if(result != null && result.gift != null)
         {
            this.m_latestReward = result.gift;
            this.m_rewardLink = result.reward_link;
            this.m_latestFeedId = result.shareFeedId;
            farmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_latestReward);
            dialogKey = this.m_configuration.getStringConstant(this.m_latestFeedId);
            stringReplacements = {"rewardItem":ZLocUtils.tk_pk_asTitle(farmItem.friendlyName)};
            if(result.friendID != null)
            {
               friend = Global.friendManager.getFriendData(result.friendID);
               stringReplacements["friendName"] = ZLocUtils.tn(friend.firstName,ZLocUtils.tg(friend.snUser.gender));
            }
            message = ZLocUtils.t("Dialogs",dialogKey,stringReplacements);
            popup = new GenericIconPopup(message,GenericPopup.TYPE_SHARE,this.onShare,farmItem.icon);
            UI.displayPopup(popup,false);
         }
      }
      
      private function onShare(event:GenericPopupEvent) : void
      {
         var farmItem:FarmItem = null;
         var bundleData:Object = null;
         var messageType:String = null;
         if(event.button == GenericPopup.ACCEPT && this.m_latestReward != null)
         {
            farmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_latestReward);
            bundleData = {
               "reward_link":this.m_rewardLink,
               "rewardItem":ZLocUtils.tk_pk_asTitle(farmItem.friendlyName),
               "prize":ZLocUtils.tk_pk_asTitle(farmItem.friendlyName),
               "images":[{
                  "href":"{SN_APP_URL}" + this.m_rewardLink,
                  "src":farmItem.icon
               }]
            };
            messageType = this.m_configuration.getStringConstant(this.m_latestFeedId);
            GlobalEngine.socialNetwork.publishFeedStory(messageType,bundleData,[],false);
         }
         else
         {
            TransactionManager.addTransaction(new TCancelFriendReward([this.m_rewardLink]));
         }
      }
      
      public function getTotalTricks() : int
      {
         return Global.player.numAltGraphicCredits(this.altGraphicCreditName);
      }
      
      public function updateTotalTrickLicenses() : void
      {
         if(this.m_trickOrTreatDialog != null)
         {
            this.m_trickOrTreatDialog.updateLicensesText();
         }
      }
      
      public function getOverlayStates() : Array
      {
         var overlayList:XMLList = null;
         var overlay:XML = null;
         var overlayName:String = null;
         var xmlConfiguration:XML = Global.farmGameSettingsManager.getFeatureXML(this.featureCreditName);
         var validOverlays:Array = new Array();
         if(xmlConfiguration)
         {
            if(xmlConfiguration.hasOwnProperty("alternativeGraphics"))
            {
               overlayList = xmlConfiguration.alternativeGraphics[0].altGraphic;
               for each(overlay in overlayList)
               {
                  overlayName = overlay.@name;
                  validOverlays.push(overlayName);
               }
            }
         }
         return validOverlays;
      }
      
      public function clearAllAltGraphics() : void
      {
         var message:String = null;
         var popup:GenericPopup = null;
         if(!Global.worldManager.isVisiting())
         {
            message = ZLocUtils.t("FarmGame","AltGraphicClearAll");
            popup = new GenericPopup(message,GenericPopup.TYPE_YESNO,this.onClearAllClose);
            UI.displayPopup(popup,false);
         }
      }
      
      public function clearNeighborActionAltGraphics(neighborActions:Array) : void
      {
         var action:BaseNeighborAction = null;
         var worldObject:WorldObject = null;
         var object:MapResource = null;
         if(neighborActions != null)
         {
            for each(action in neighborActions)
            {
               worldObject = Global.world.getObjectById(action.objectId) as WorldObject;
               if(Boolean(worldObject) && getQualifiedClassName(action).indexOf(TRICKED_NEIGHBOR_ACTION) != -1)
               {
                  object = worldObject as MapResource;
                  this.removeGraphicOrOverlay(object);
                  object.setHighlighted(false);
               }
            }
         }
      }
      
      private function onClearAllClose(event:GenericPopupEvent) : void
      {
         var objects:Array = null;
         var objectIdx:int = 0;
         var object:MapResource = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            objects = Global.world.getObjects();
            for(objectIdx = 0; objectIdx < objects.length; objectIdx++)
            {
               object = objects[objectIdx] as MapResource;
               if(object != null)
               {
                  this.removeGraphicOrOverlay(object);
               }
            }
         }
      }
      
      private function removeGraphicOrOverlay(object:MapResource) : void
      {
         var validOverlays:Array = this.getOverlayStates();
         for(var i:int = 0; i < validOverlays.length; i++)
         {
            if(object.getAlternativeGraphic() == validOverlays[i])
            {
               object.removeAlternativeGraphic(object.getAlternativeGraphic(),true,true);
               break;
            }
            if(object.overlay == validOverlays[i])
            {
               object.removeOverlay(true);
               break;
            }
         }
      }
      
      public function getRewards() : Array
      {
         var rewardsList:XMLList = null;
         var reward:XML = null;
         var rewardName:String = null;
         var requiredCredits:Number = NaN;
         var rewardObj:Object = null;
         var xmlConfiguration:XML = Global.farmGameSettingsManager.getFeatureXML(this.featureCreditName);
         var rewardsArray:Array = new Array();
         if(xmlConfiguration)
         {
            rewardsList = xmlConfiguration.rewards[0].reward;
            for each(reward in rewardsList)
            {
               rewardName = reward.@name;
               requiredCredits = Number(reward.@cost);
               rewardObj = new Object();
               rewardObj["name"] = rewardName;
               rewardObj["cost"] = requiredCredits;
               rewardsArray.push(rewardObj);
            }
         }
         return rewardsArray;
      }
      
      public function getOffBoardingPrizes() : Array
      {
         var rewardsList:XMLList = null;
         var reward:XML = null;
         var rewardName:String = null;
         var xmlConfiguration:XML = Global.farmGameSettingsManager.getFeatureXML(this.featureCreditName);
         var prizes:Array = new Array();
         if(xmlConfiguration)
         {
            rewardsList = xmlConfiguration.offBoardingReward[0].reward;
            for each(reward in rewardsList)
            {
               rewardName = reward.@name;
               prizes.push(rewardName);
            }
         }
         return prizes;
      }
      
      public function enterGameMode() : void
      {
         this.m_gmHalloweenTrick = new GMHalloweenTrick();
         Global.world.addGameMode(this.m_gmHalloweenTrick);
         Global.hud.trickOrTreatIcon.active = true;
      }
      
      public function exitGameMode() : void
      {
         Global.world.removeGameMode(this.m_gmHalloweenTrick);
         Global.world.setDefaultGameMode();
         Global.hud.trickOrTreatIcon.active = false;
         this.m_gmHalloweenTrick = null;
      }
      
      public function get isGameModeActive() : Boolean
      {
         return this.m_gmHalloweenTrick != null;
      }
      
      public function get hasSeenToaster() : Boolean
      {
         return this.m_hasSeenToaster;
      }
      
      public function set hasSeenToaster(hasSeen:Boolean) : void
      {
         this.m_hasSeenToaster = hasSeen;
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
