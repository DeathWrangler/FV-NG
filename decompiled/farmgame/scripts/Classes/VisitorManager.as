package Classes
{
   import Classes.Avatar.FarmAvatar;
   import Classes.Avatar.FriendAvatar;
   import Classes.NeighborActions.BaseNeighborAction;
   import Classes.NeighborActions.NeighborActionConstants;
   import Classes.NeighborActions.NeighborActionDataStore;
   import Classes.NeighborActions.NeighborActionLimits;
   import Classes.NeighborActions.NeighborVisit;
   import Classes.UGC.UGCItemData;
   import Classes.ZItem.BuildingItem;
   import Classes.ZItem.FarmItem;
   import Display.DynamicIconQueue;
   import Display.HUD.FarmNameDisplay;
   import Display.QueuedIcon;
   import Display.QueuedIconIncrementer;
   import Display.UI;
   import Engine.Classes.ObjectLayer;
   import Engine.Classes.WorldObject;
   import Engine.Helpers.Vector3;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import GameMode.GMHalloweenTrick;
   import GameMode.GMModelFarmVisit;
   import GameMode.GMNPCVisit;
   import GameMode.GMVisit;
   import Managers.FarmStatsManager;
   import Managers.FeatureConfigManager;
   import Managers.NPCManager;
   import Managers.NeighborUnwitherManager;
   import Managers.TrickOrTreatManager;
   import Transactions.NeighborActions.TDepositNeighborAnimalFeed;
   import Transactions.NeighborActions.TSendNeighborGift;
   import Widgets.Windows.NeighborVisit.AddCommunityNeighborWindow;
   import flash.external.ExternalInterface;
   import flash.utils.getDefinitionByName;
   
   public class VisitorManager
   {
      
      private static var m_instance:VisitorManager;
      
      public static const VISIT_MODE_FRIEND:int = 0;
      
      public static const VISIT_MODE_NPC:int = 1;
      
      private static const HUD_ICON_FARM_ACTIONS:String = "NeighborVisitFarmActions";
      
      public static const HUD_ICON_FEED_CHICKENS:String = "Chicken_Feed";
      
      public static const HUD_ICON_TRICK_NEIGHBOR:String = "Trick_Neighbor";
      
      private static const HUD_ICON_NEIGHBOR_GIFT:String = "NeighborVisitGift";
      
      public static const NEIGHBOR_VISIT_COUNTER:String = "neighbor_visit";
      
      public static const NEIGHBOR_VISIT_HUDICON_COUNTER:String = "help_neighbor_hud_icons";
      
      public static const NEIGHBOR_VISIT_AVATAR_COUNTER:String = "neighbor_avatar_confirmations";
      
      private static const DEFAULT_VISIT_GIFT:String = "mysterygift";
      
      private static const DECLARE_GMNPC:Array = [GMNPCVisit,GMModelFarmVisit];
      
      private static var m_neighborActionDataStore:NeighborActionDataStore = null;
      
      private const HALLOWEEN_SEENFLAG:String = "tricking";
      
      private const STR_GAMESETTINGS_TRICK_DISABLE_DATE:String = "halloweenTrickDisableDate";
      
      private var m_neighborActionLimits:NeighborActionLimits = new NeighborActionLimits(null,null);
      
      private var m_visitedUserId:String = "";
      
      private var m_visitedUserName:String = "";
      
      private var m_visitedAvatar:FarmAvatar = null;
      
      private var m_visigtedUgcItemData:UGCItemData;
      
      private var m_instanceDataStore:Object = null;
      
      private var m_farmActionIconIncrementer:QueuedIconIncrementer = null;
      
      private var m_visitGiftItem:FarmItem = null;
      
      private var m_visitWorkedObjects:Array = null;
      
      private var m_avatarPlacedByObjects:Array = null;
      
      private var m_visitMode:int = 0;
      
      private var m_neighborUnwitherManager:NeighborUnwitherManager;
      
      private var m_disableUnwitherOffer:Boolean = false;
      
      private var m_isVisitedCraftShopCrewMember:Boolean = false;
      
      public function VisitorManager()
      {
         super();
      }
      
      public static function getInstance() : VisitorManager
      {
         if(null == m_instance)
         {
            m_instance = new VisitorManager();
         }
         return m_instance;
      }
      
      public function loadUGCItemData(ugcItemData:Object) : void
      {
         if(this.m_visigtedUgcItemData == null)
         {
            this.m_visigtedUgcItemData = new UGCItemData();
         }
         this.m_visigtedUgcItemData.loadData(ugcItemData,true);
      }
      
      public function get ugcItemData() : UGCItemData
      {
         if(this.m_visigtedUgcItemData == null)
         {
            this.m_visigtedUgcItemData = new UGCItemData();
         }
         return this.m_visigtedUgcItemData;
      }
      
      public function loadInstnaceDataStore(store:Object) : void
      {
         this.m_instanceDataStore = store;
      }
      
      public function get instanceDataStore() : Object
      {
         return this.m_instanceDataStore;
      }
      
      public function initNeighborActionData(neighborActionData:Object) : void
      {
         m_neighborActionDataStore = new NeighborActionDataStore(neighborActionData);
      }
      
      public function initNeighborActionLimits(neighborActionLimitData:Object, actionableFeatureBuildings:Array) : void
      {
         this.m_neighborActionLimits = new NeighborActionLimits(neighborActionLimitData,actionableFeatureBuildings);
      }
      
      public function placeNeighborVisitAvatars() : void
      {
         var currentWorldType:String = null;
         var neighborVisit:NeighborVisit = null;
         var avatarPosition:Vector3 = null;
         var neighborAvatar:NeighborVisitAvatar = null;
         var numAvatarsPlaced:int = 0;
         var objLayer:ObjectLayer = new ObjectLayer(NeighborVisitAvatar.NEIGHBOR_AVATAR_LAYER);
         Global.world.addLayer(objLayer);
         if(m_neighborActionDataStore)
         {
            this.m_avatarPlacedByObjects = new Array();
            currentWorldType = Global.worldManager.currentWorldType;
            for each(neighborVisit in m_neighborActionDataStore.neighborVisits)
            {
               if(neighborVisit.isValid(currentWorldType))
               {
                  avatarPosition = this.calculateAvatarPosition(neighborVisit);
                  neighborAvatar = new NeighborVisitAvatar(neighborVisit,this.m_visitedUserName);
                  if(neighborAvatar.hasValidFriendData())
                  {
                     Global.world.addAvatar(neighborAvatar,avatarPosition);
                     FarmStatsManager.count(NEIGHBOR_VISIT_COUNTER,NEIGHBOR_VISIT_AVATAR_COUNTER,"avatar_neighbor_placed");
                     StatsManager.social("notify",String(neighborVisit.neighborId),NEIGHBOR_VISIT_COUNTER,"help");
                     numAvatarsPlaced++;
                  }
                  else
                  {
                     FarmStatsManager.count(NEIGHBOR_VISIT_COUNTER,NEIGHBOR_VISIT_AVATAR_COUNTER,"avatar_neighbor_skipped","invalid_friend_data");
                  }
               }
            }
         }
         if(Global.worldManager.isVisiting())
         {
            if(numAvatarsPlaced > 0)
            {
               FarmStatsManager.count("mutual_neighbor_click_exp","neighbor_visit","visit_with_avatars",numAvatarsPlaced.toString());
            }
            else
            {
               FarmStatsManager.count("mutual_neighbor_click_exp","neighbor_visit","visit_without_avatars");
            }
         }
         else
         {
            FarmStatsManager.count(NEIGHBOR_VISIT_COUNTER,NEIGHBOR_VISIT_AVATAR_COUNTER,"avatar_neighbor_count",numAvatarsPlaced.toString());
         }
      }
      
      private function calculateAvatarPosition(neighborVisit:NeighborVisit) : Vector3
      {
         var workedObject:WorldObject = null;
         var searchIndex:int = 0;
         var result:Vector3 = Global.world.getWorldCenter();
         var workedObjects:Array = neighborVisit.getWorkedObjectsByWorldType(Global.worldManager.currentWorldType);
         for(var objectIndex:* = int(workedObjects.length - 1); objectIndex >= 0; objectIndex--)
         {
            workedObject = workedObjects[objectIndex];
            if(workedObject)
            {
               searchIndex = this.m_avatarPlacedByObjects.indexOf(workedObject);
               if(searchIndex == -1)
               {
                  this.m_avatarPlacedByObjects.push(workedObject);
                  result = workedObject.getPosition();
                  --result.x;
                  break;
               }
            }
         }
         return result;
      }
      
      public function initForVisit(targetUserData:Object, giftableItem:FarmItem = null) : void
      {
         var farmNameDisplay:FarmNameDisplay = null;
         this.m_visitedUserId = targetUserData.id;
         this.m_visitedUserName = Global.worldManager.getVisitName();
         TrickOrTreatManager.instance.hasSeenToaster = false;
         if(Boolean(targetUserData.firstName) && (targetUserData.firstName != null || targetUserData.firstName != ""))
         {
            this.m_visitedUserName = targetUserData.firstName;
            farmNameDisplay = Global.hud.farmNameDisplay;
            farmNameDisplay.setFarmNameFromPlayerName(this.m_visitedUserName);
         }
         this.m_visitWorkedObjects = new Array();
         if(this.getVisitMode() != VISIT_MODE_NPC)
         {
            if(!this.m_visitedUserName)
            {
               this.m_visitedUserName = "your friend";
            }
            if(giftableItem)
            {
               this.m_visitGiftItem = giftableItem;
            }
            else
            {
               this.m_visitGiftItem = Global.farmGameSettingsManager.getFarmItemByName(DEFAULT_VISIT_GIFT);
            }
            if(this.m_neighborActionLimits)
            {
               this.m_neighborActionLimits.loadActionLimits(this.m_visitedUserId);
            }
            this.initHudIcons();
            this.initBuildings();
            this.initPopups();
            if(Boolean(targetUserData.avatar) && targetUserData.avatar != null)
            {
               this.loadAvatar(targetUserData.avatar,this.m_visitedUserName);
            }
            else
            {
               this.loadAvatar();
            }
            if(Global.worldManager.isVisitingCommunityNeighbor())
            {
               UI.displayPopup(new AddCommunityNeighborWindow(this.m_visitedUserId,this.m_visitedUserName,this.m_visitedAvatar));
            }
            else
            {
               if(this.m_neighborUnwitherManager == null)
               {
                  this.m_neighborUnwitherManager = new NeighborUnwitherManager();
               }
               this.m_neighborUnwitherManager.offerFullFarmUnwither(targetUserData,this.m_visitedUserName);
            }
         }
         else
         {
            Global.hud.toggleMessageSignEnable(false);
            Global.hud.showMessageCenterButton(false);
            Global.hud.setIconQueuesVisibility(false);
            this.m_visitedUserName = "McDonald";
         }
      }
      
      private function initHudIcons() : void
      {
         var farmActionsIcon:QueuedIcon = null;
         var extraParams:Object = null;
         var iconUrl:String = null;
         var availableFarmActions:int = this.m_neighborActionLimits.getAvailableActionCount(NeighborActionConstants.LIMIT_TYPE_FARM_ACTION);
         var availableFeedActions:int = this.m_neighborActionLimits.getAvailableActionCount(NeighborActionConstants.LIMIT_TYPE_FEED_ACTION);
         var availableGiftActions:int = this.m_neighborActionLimits.getAvailableActionCount(NeighborActionConstants.LIMIT_TYPE_GIFT_ACTION);
         var availableTrickActions:int = this.m_neighborActionLimits.getAvailableActionCount(NeighborActionConstants.LIMIT_TYPE_TRICK_NEIGHBOR_ACTION);
         var visitIconQueue:DynamicIconQueue = Global.hud.visitIconQueue;
         visitIconQueue.clearIcons();
         visitIconQueue.visibleIcons = 4;
         if(availableFarmActions > 0)
         {
            farmActionsIcon = visitIconQueue.addIconToTop(HUD_ICON_FARM_ACTIONS);
            FarmStatsManager.sample(100,NEIGHBOR_VISIT_COUNTER,NEIGHBOR_VISIT_HUDICON_COUNTER,"farm_action","impressions");
            this.m_farmActionIconIncrementer = new QueuedIconIncrementer(farmActionsIcon,availableFarmActions);
         }
         if(availableFeedActions > 0 && null != this.getHungryChickenCoop())
         {
            visitIconQueue.addIconToTop(HUD_ICON_FEED_CHICKENS);
            FarmStatsManager.sample(100,NEIGHBOR_VISIT_COUNTER,NEIGHBOR_VISIT_HUDICON_COUNTER,"chicken_coop","impressions");
         }
         if(availableGiftActions > 0 && Boolean(this.m_visitGiftItem))
         {
            extraParams = {"name":this.m_visitedUserName};
            iconUrl = this.m_visitGiftItem.icon;
            visitIconQueue.addIconToTop(HUD_ICON_NEIGHBOR_GIFT,iconUrl,extraParams);
            FarmStatsManager.sample(100,NEIGHBOR_VISIT_COUNTER,NEIGHBOR_VISIT_HUDICON_COUNTER,"gift_send","impressions");
         }
         if(FeatureConfigManager.getFeatureConfiguration(TrickOrTreatManager.instance.featureCreditName).isFeatureVisible() && !TrickOrTreatManager.instance.isOffBoarding())
         {
            TrickOrTreatManager.instance.enterGameMode();
         }
         visitIconQueue.setVisible(true);
         Global.hud.toggleMessageSignEnable(true);
         Global.hud.showMessageCenterButton(true);
         Global.hud.setIconQueuesVisibility(true);
         Global.selectedAvatar.getStateMachine().popState();
      }
      
      public function updateBuildingsFeedGlow() : void
      {
         var actionableFeatureBuilding:FeatureBuilding = null;
         var actionableFeatureBuildings:Array = this.getActionableFeatureBuildings();
         if(actionableFeatureBuildings)
         {
            for each(actionableFeatureBuilding in actionableFeatureBuildings)
            {
               if(!actionableFeatureBuilding.canBeClickedOnVisit())
               {
                  actionableFeatureBuilding.showFeedGlow(false);
               }
            }
         }
      }
      
      private function initBuildings() : void
      {
         var chickenCoop:ChickenCoopBuilding = null;
         var hhhb:HalloweenHauntedHouseBuilding = null;
         var hcdb:HalloweenCastleDuckulaBuilding = null;
         var actionableFeatureBuilding:FeatureBuilding = null;
         var featureBuilding:FeatureBuilding = null;
         if(this.m_neighborActionLimits.getAvailableActionCount(NeighborActionConstants.LIMIT_TYPE_FEED_ACTION) > 0)
         {
            chickenCoop = this.getHungryChickenCoop();
            if(chickenCoop)
            {
               chickenCoop.showFeedGlow(true);
            }
         }
         if(this.m_neighborActionLimits.getAvailableActionCount(NeighborActionConstants.LIMIT_TYPE_HARVEST_HALLOWEEN_CANDY) > 0)
         {
            hhhb = this.getHalloweenHauntedHouse();
            if(Boolean(hhhb) && Boolean(hhhb.getItem().checkDateGate()) && hhhb.getItem().isInExperiment)
            {
               hhhb.showFeedGlow(true);
            }
         }
         if(this.m_neighborActionLimits.getAvailableActionCount(NeighborActionConstants.LIMIT_TYPE_HARVEST_HALLOWEEN_TICKETS) > 0)
         {
            hcdb = this.getHalloweenCastleDuckula();
            if(Boolean(hcdb) && Boolean(hcdb.getItem().checkDateGate()) && hcdb.getItem().isInExperiment)
            {
               hcdb.showFeedGlow(true);
            }
         }
         var actionableFeatureBuildings:Array = this.getActionableFeatureBuildings();
         if(actionableFeatureBuildings)
         {
            for each(actionableFeatureBuilding in actionableFeatureBuildings)
            {
               if(actionableFeatureBuilding.canBeClickedOnVisit())
               {
                  actionableFeatureBuilding.showFeedGlow(true);
               }
            }
         }
         var lookInsideFeatureBuildings:Array = this.getNeighborLookInsideFeatureBuildings();
         if(lookInsideFeatureBuildings)
         {
            for each(featureBuilding in lookInsideFeatureBuildings)
            {
               featureBuilding.showFeedGlow(true);
            }
         }
      }
      
      private function initPopups() : void
      {
         if(Global.player.hasVisitFriend == 0)
         {
            Global.player.hasVisitFriend = 1;
            StatsManager.milestone("sign_post_md");
         }
      }
      
      private function loadAvatar(avatarData:Object = null, friendName:String = "") : void
      {
         var pos:Vector3 = null;
         var pathablePos:Vector3 = null;
         var visitId:String = Global.worldManager.getVisiting();
         if(Boolean(Global.worldManager.isVisiting()) && Boolean(visitId) && visitId.length > 1)
         {
            if(avatarData != null)
            {
               this.m_visitedAvatar = new FriendAvatar(visitId,avatarData,friendName);
            }
            else
            {
               this.m_visitedAvatar = new FriendAvatar(visitId);
            }
            pos = Global.world.getDefaultAvatarPosition();
            pos.x += pos.x / 10;
            pos.y -= pos.y / 10;
            pathablePos = Global.world.getPathablePointRelativeToThePosition(pos.x,pos.y);
            pos = pathablePos == null ? pos : pathablePos;
            this.m_visitedAvatar.createDisplayObject();
            Global.world.addAvatar(this.m_visitedAvatar,pos);
            this.m_visitedAvatar.showAvatar();
         }
      }
      
      public function getVisitMode() : int
      {
         return this.m_visitMode;
      }
      
      public function setVisitMode(mode:int = 0) : void
      {
         this.m_visitMode = mode;
      }
      
      public function getVisitGM() : GMVisit
      {
         var hostId:String = null;
         var result:GMVisit = null;
         var npcData:NPCConfigData = null;
         var gmClass:Class = null;
         hostId = Global.worldManager.getVisiting();
         var visitMode:int = this.getVisitMode();
         switch(visitMode)
         {
            case VISIT_MODE_NPC:
               npcData = NPCManager.getInstance().getNPC(hostId);
               gmClass = getDefinitionByName("GameMode." + npcData.gamemode) as Class;
               result = new gmClass(hostId);
               break;
            default:
               ExternalInterface.call("sendPromoBarMessage","showComments",[hostId,this.m_visitedUserName,Global.player.feedImage]);
               result = new GMVisit(hostId);
         }
         return result;
      }
      
      public function setDefaultGameMode() : void
      {
         Global.world.addGameMode(this.getVisitGM());
      }
      
      public function canPerformAction(object:WorldObject, limitType:String, actionKey:String = null) : Boolean
      {
         var result:Boolean = false;
         if(Boolean(object) && Boolean(limitType) && !Global.worldManager.isVisitingCommunityNeighbor())
         {
            if(this.hasActionTypeLeft(limitType,actionKey) && !this.hasAlreadyWorkedObject(object))
            {
               result = true;
            }
         }
         return result;
      }
      
      public function hasAlreadyWorkedObject(object:WorldObject) : Boolean
      {
         var workedObject:WorldObject = null;
         var result:Boolean = false;
         if(object)
         {
            for each(workedObject in this.m_visitWorkedObjects)
            {
               if(workedObject == object)
               {
                  result = true;
                  break;
               }
            }
         }
         return result;
      }
      
      public function hasActionTypeLeft(limitType:String, actionKey:String = null) : Boolean
      {
         var result:Boolean = false;
         if(Boolean(limitType) && Boolean(this.m_neighborActionLimits) && !Global.worldManager.isVisitingCommunityNeighbor())
         {
            result = this.m_neighborActionLimits.checkWithinActionLimitsQueued(limitType,actionKey);
         }
         return result;
      }
      
      public function getNeighborActionsLeft(limitType:String, actionKey:String = null) : int
      {
         var result:int = 0;
         if(Boolean(limitType) && Boolean(this.m_neighborActionLimits) && !Global.worldManager.isVisitingCommunityNeighbor())
         {
            result = this.m_neighborActionLimits.getAvailableActionCount(limitType,actionKey);
         }
         return result;
      }
      
      public function queueActionType(worldObject:WorldObject, limitType:String, actionKey:String = null) : void
      {
         if(Boolean(limitType) && Boolean(this.m_neighborActionLimits))
         {
            this.m_neighborActionLimits.queueAction(limitType,actionKey);
            this.m_visitWorkedObjects.push(worldObject);
         }
      }
      
      public function doAction(action:BaseNeighborAction) : void
      {
         var limitType:String = null;
         var actionKey:String = null;
         if(action)
         {
            limitType = action.getLimitType();
            actionKey = action.getActionKey();
            if(this.m_neighborActionLimits.checkWithinActionLimits(limitType,actionKey))
            {
               action.execute();
               this.m_neighborActionLimits.incrementActionCount(limitType,actionKey);
               if(limitType == NeighborActionConstants.LIMIT_TYPE_FARM_ACTION)
               {
                  this.m_farmActionIconIncrementer.decrementCount(1,true);
               }
            }
         }
      }
      
      public function onNeighborGift() : void
      {
         FarmStatsManager.sample(100,NEIGHBOR_VISIT_COUNTER,NEIGHBOR_VISIT_HUDICON_COUNTER,"gift_send","clicks");
         this.m_neighborActionLimits.incrementActionCount(NeighborActionConstants.LIMIT_TYPE_GIFT_ACTION);
         TransactionManager.addTransaction(new TSendNeighborGift(this.m_visitedUserId),true);
      }
      
      public function onNeighborFillFeedTrough(building:FeedTroughBuilding) : void
      {
         FarmStatsManager.count(FeedTroughBuilding.ANIMAL_FEED_TROUGH_COUNTER,NEIGHBOR_VISIT_COUNTER,"give_animal_feed");
         this.m_neighborActionLimits.incrementActionCount(NeighborActionConstants.LIMIT_TYPE_SEND_ANIMAL_FEED);
         TransactionManager.addTransaction(new TDepositNeighborAnimalFeed(building));
      }
      
      public function onGoHome() : void
      {
         if(FeatureConfigManager.getFeatureConfiguration(TrickOrTreatManager.instance.featureCreditName).isFeatureVisible() && !TrickOrTreatManager.instance.isOffBoarding())
         {
            TrickOrTreatManager.instance.exitGameMode();
         }
         Global.hud.visitIconQueue.visible = false;
         this.m_visitWorkedObjects = null;
         this.m_visitedUserId = "";
         this.m_visitedUserName = "";
         this.placeNeighborVisitAvatars();
         Global.hud.toggleMessageSignEnable(true);
         Global.hud.showMessageCenterButton(true);
         Global.hud.setIconQueuesVisibility(true);
         Global.selectedAvatar.getStateMachine().popState();
         ExternalInterface.call("sendPromoBarMessage","showComments",[Global.player.uid,null,Global.player.feedImage]);
      }
      
      public function onNeighborTrick() : void
      {
         if(FeatureConfigManager.getFeatureConfiguration(TrickOrTreatManager.instance.featureCreditName).isFeatureVisible() && this.m_neighborActionLimits.getAvailableActionCount(NeighborActionConstants.LIMIT_TYPE_TRICK_NEIGHBOR_ACTION) > 0)
         {
            Global.world.addGameMode(new GMHalloweenTrick());
         }
      }
      
      public function getHungryChickenCoop() : ChickenCoopBuilding
      {
         var chickenCoop:ChickenCoopBuilding = null;
         var result:ChickenCoopBuilding = null;
         var allChickenCoops:Array = Global.world.getObjectsByClass(ChickenCoopBuilding);
         for each(chickenCoop in allChickenCoops)
         {
            if(chickenCoop.canFeedOnVisit())
            {
               result = chickenCoop;
               break;
            }
         }
         return result;
      }
      
      private function getPigpen() : PigpenBuilding
      {
         var pigpen:PigpenBuilding = null;
         var pigpens:Array = Global.world.getObjectsByClass(PigpenBuilding);
         if(pigpens.length > 0)
         {
            pigpen = pigpens[0];
         }
         return pigpen;
      }
      
      private function getHalloweenHauntedHouse() : HalloweenHauntedHouseBuilding
      {
         var hhhb:HalloweenHauntedHouseBuilding = null;
         var hhhbs:Array = Global.world.getObjectsByClass(HalloweenHauntedHouseBuilding);
         if(hhhbs.length > 0)
         {
            hhhb = hhhbs[0];
         }
         return hhhb;
      }
      
      private function getHalloweenCastleDuckula() : HalloweenCastleDuckulaBuilding
      {
         var hcdb:HalloweenCastleDuckulaBuilding = null;
         var hcdbs:Array = Global.world.getObjectsByClass(HalloweenCastleDuckulaBuilding);
         if(hcdbs.length > 0)
         {
            hcdb = hcdbs[0];
         }
         return hcdb;
      }
      
      private function getFeedTrough() : FeedTroughBuilding
      {
         var result:FeedTroughBuilding = null;
         var feedTroughs:Array = Global.world.getObjectsByClass(FeedTroughBuilding);
         if(feedTroughs.length > 0)
         {
            result = feedTroughs[0];
         }
         return result;
      }
      
      private function getActionableFeatureBuildings() : Array
      {
         var featureBuilding:FeatureBuilding = null;
         var actionableFeatureBuildings:Array = new Array();
         var allFeatureBuildings:Array = Global.world.getObjectsByClass(FeatureBuilding);
         if(allFeatureBuildings)
         {
            for each(featureBuilding in allFeatureBuildings)
            {
               if((featureBuilding.getItem() as BuildingItem).neighborAction)
               {
                  actionableFeatureBuildings.push(featureBuilding);
               }
            }
         }
         return actionableFeatureBuildings;
      }
      
      private function getNeighborLookInsideFeatureBuildings() : Array
      {
         var featureBuilding:FeatureBuilding = null;
         var lookInsideNeighborFeatureBuildings:Array = new Array();
         var allFeatureBuildings:Array = Global.world.getObjectsByClass(FeatureBuilding);
         if(allFeatureBuildings)
         {
            for each(featureBuilding in allFeatureBuildings)
            {
               if((featureBuilding.getItem() as BuildingItem).neighborLookInside)
               {
                  lookInsideNeighborFeatureBuildings.push(featureBuilding);
               }
            }
         }
         return lookInsideNeighborFeatureBuildings;
      }
      
      public function set visitedUserId(id:String) : void
      {
         this.m_visitedUserId = id;
      }
      
      public function get visitedUserId() : String
      {
         return this.m_visitedUserId;
      }
      
      public function get visitedUserName() : String
      {
         return this.m_visitedUserName;
      }
      
      public function set isVisitedCraftShopCrewMember(isCrewMember:Boolean) : void
      {
         this.m_isVisitedCraftShopCrewMember = isCrewMember;
      }
      
      public function get isVisitedCraftShopCrewMember() : Boolean
      {
         return this.m_isVisitedCraftShopCrewMember;
      }
   }
}

