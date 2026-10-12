package Classes.Growable
{
   import Classes.Constants.MFSConstants;
   import Classes.FeatureBuilding;
   import Classes.GrowableAnimal;
   import Classes.GrowableAnimalItem;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.ZItem.FarmItem;
   import Classes.storage.StorageItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocFailoverEntry;
   import Classes.util.ZLocUtils;
   import Display.GenericXMLDialog;
   import Display.UI;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.TransactionManager;
   import Events.FeatureMessageEvent;
   import GameMode.GMGrowableContestPlaceInvited;
   import Managers.Crafting.CraftingManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureMessagingManager;
   import Managers.FeatureOptionsManager;
   import Managers.GrowableContestManager;
   import Transactions.TGenericTransaction;
   import Transactions.TGrowableContestFeedPost;
   import Transactions.TGrowableContestScore;
   import Transactions.TSetFeatureFrequencyTimestamp;
   import Widgets.Windows.GrowableContestResultsWindow;
   import Widgets.Windows.GrowableContestWindow;
   import Widgets.Windows.MFSAskGrowablePartner;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class GrowableContest extends EventDispatcher
   {
      
      private static const DEFAULT_OBJECT_PREVIEW_SCALE:Number = 4.5;
      
      private static const GAME_SETTINGS_FEATURE_KEY:String = "growableObjectContests";
      
      public static const FEED_TYPE_GENERAL:String = "general";
      
      public static const FEED_TYPE_ACCEPT:String = "accept";
      
      public static const FEED_TYPE_COMPLETE:String = "complete";
      
      public static const FEED_TYPE_REMIND:String = "remind";
      
      public static const FEED_TYPE_PROGRESSION_SOLO:String = "progression_solo";
      
      public static const FEED_TYPE_PROGRESSION_PARTNER:String = "progression_partner";
      
      public static const STATS_COUNTER:String = "GrowableContest";
      
      public static const OBJECT_TYPE_REQUEST:String = "request";
      
      public static const OBJECT_TYPE_ACTIVE:String = "active";
      
      public static const OBJECT_TYPE_LOCKED:String = "locked";
      
      public static const OBJECT_TYPE_UNLOCKED:String = "unlocked";
      
      public static const ASSET_KEY_TOOLTIP:String = "tooltip";
      
      public static const ASSET_KEY_MAIN_WINDOW:String = "mainWindow";
      
      public static const ASSET_KEY_RESULTS_WINDOW:String = "resultsWindow";
      
      public static const CONTEST_LIST_PARTICIPATING:int = 1;
      
      public static const CONTEST_LIST_PENDING:int = 2;
      
      public static const CONTEST_LIST_ALL:int = 3;
      
      public static const SERVICE:String = GrowableConstants.SERVICE_GROWABLE_CONTEST;
      
      private var m_objectPreviewScale:Number;
      
      private var m_staticData:Object = null;
      
      private var m_contestId:String;
      
      private var m_prereqs:Array;
      
      private var m_feedData:Object;
      
      private var m_assets:Object = {};
      
      private var m_feedPostPending:Boolean;
      
      private var m_tutorial:GrowableContestTutorial;
      
      private var m_lastInviteViewed:Number = 0;
      
      private var m_numNewInvites:int;
      
      private var m_isInviteStatusLoaded:Boolean;
      
      private var m_pendingAnsweredRequests:Object = {};
      
      private var m_weighedStorageIds:Object = {};
      
      public function GrowableContest(contestId:String)
      {
         super();
         this.m_contestId = contestId;
         this.m_tutorial = new GrowableContestTutorial(this);
         this.loadStaticData();
         FeatureOptionsManager.getInstance().addEventListener(FeatureOptionsManager.EVENT_FEATURE_OPTIONS_UPDATED,this.updateStateFromServer);
      }
      
      public static function getParticipantCompletedEventName(storageKey:String) : String
      {
         return GrowableContestConstants.EVENT_PARTICIPANT_COMPLETED_PREFIX + storageKey;
      }
      
      public function get contestId() : String
      {
         return this.m_contestId;
      }
      
      public function get objectPreviewScale() : Number
      {
         return this.m_objectPreviewScale;
      }
      
      public function get zLocPrefix() : String
      {
         return this.m_staticData.zLocPrefix;
      }
      
      public function isEnabled() : Boolean
      {
         return PrerequisiteUtility.arePrerequisitesMet(this.m_prereqs);
      }
      
      public function getZLocString(pkg:String, suffix:String, attributes:Object = null) : String
      {
         return ZLocUtils.getFailoverLocString([new ZLocFailoverEntry(pkg,this.zLocPrefix + "_" + suffix),new ZLocFailoverEntry(pkg,"GrowableContest_" + suffix)],attributes);
      }
      
      public function getAssetUrl(assetKey:String) : String
      {
         var assetInfo:Object = this.m_assets[assetKey];
         return assetInfo ? assetInfo.path : null;
      }
      
      private function updateStateFromServer(e:Event) : void
      {
         if(this.currentState.lastInviteViewTime > this.m_lastInviteViewed)
         {
            this.m_lastInviteViewed = this.currentState.lastInviteViewTime;
         }
         this.updateAndNotifyNumNewInvites();
      }
      
      public function onParticipantFinishPlace(entry:IGrowableResource) : void
      {
         Global.player.setSeenFlag(this.firstParticipantPlacedSeenFlag,false,false);
         var contestEntry:Object = this.getContestEntryForKey(entry.growableMapResource.persistentDataKey);
         if(!this.m_tutorial.isCompleted())
         {
            this.m_tutorial.updateState();
         }
         else if(!contestEntry.hasOwnProperty("partner") || contestEntry.partner == 0)
         {
            this.makePartnerRequest(entry.persistentDataKey);
         }
         else
         {
            GrowableContestWindow.showWindowForContest(this);
         }
      }
      
      public function get firstParticipantPlaced() : Boolean
      {
         return Global.player.getSeenFlag(this.firstParticipantPlacedSeenFlag);
      }
      
      private function get firstParticipantPlacedSeenFlag() : String
      {
         return this.contestId + "_ParticipantPlaced";
      }
      
      public function get currentState() : Object
      {
         var newArray:Array = null;
         var i:String = null;
         var result:Object = FeatureOptionsManager.getInstance().getFeatureOption(GrowableContestManager.GROWABLE_CONTEST_STATE,this.m_contestId);
         if(!result)
         {
            this.initEmptyState();
            result = FeatureOptionsManager.getInstance().getFeatureOption(GrowableContestManager.GROWABLE_CONTEST_STATE,this.m_contestId);
         }
         if(!(result.participatingObjs is Array))
         {
            newArray = [];
            for(i in result.participatingObjs)
            {
               newArray.push(result.participatingObjs[i]);
            }
            result.participatingObjs = newArray;
         }
         return result;
      }
      
      public function set currentState(state:Object) : void
      {
         FeatureOptionsManager.getInstance().setFeatureOption(GrowableContestManager.GROWABLE_CONTEST_STATE,this.m_contestId,state);
      }
      
      private function initEmptyState() : void
      {
         var state:Object = null;
         if(!FeatureOptionsManager.getInstance().getFeatureOption(GrowableContestManager.GROWABLE_CONTEST_STATE,this.m_contestId))
         {
            state = new Object();
            state.participatingObjs = new Array();
            state.pendingObjs = new Array();
            state.completions = 0;
            state.slotsAvailable = this.m_staticData.slotsBase;
            FeatureOptionsManager.getInstance().setFeatureOption(GrowableContestManager.GROWABLE_CONTEST_STATE,this.m_contestId,state);
         }
      }
      
      private function loadStaticData() : void
      {
         var featureData:XML;
         var contestXML:XMLList = null;
         var itemCode:String = null;
         var slots:XMLList = null;
         var loot:XMLList = null;
         var table:XML = null;
         var assetXML:XML = null;
         var item:GrowableAnimalItem = null;
         var lootInfo:Object = null;
         var assetInfo:Object = null;
         this.m_staticData = new Object();
         this.m_staticData.itemCodes = new Array();
         this.m_staticData.recipeIds = new Array();
         this.m_staticData.slotsBase = 0;
         this.m_staticData.slotsMax = 0;
         this.m_staticData.slotsCost = "";
         this.m_staticData.maxAge = 0;
         this.m_staticData.scoreCalculatorClass = null;
         this.m_staticData.lootTables = new Array();
         this.m_staticData.maxConsumables = 0;
         this.m_staticData.viralFeatureName = "";
         this.m_staticData.zLocPrefix = "";
         this.m_objectPreviewScale = DEFAULT_OBJECT_PREVIEW_SCALE;
         featureData = Global.farmGameSettingsManager.getFeatureXML(GAME_SETTINGS_FEATURE_KEY);
         if(featureData != null)
         {
            contestXML = featureData.contests.contest.(@contestId == m_contestId);
            if(contestXML)
            {
               this.m_prereqs = PrerequisiteUtility.parseXmlNodePrereqs(contestXML.prereqs.prereq);
               this.m_staticData.itemCodes = [];
               for each(itemCode in contestXML.@itemCodes.toString().split(","))
               {
                  item = Global.farmGameSettingsManager.getFarmItemByCode(itemCode) as GrowableAnimalItem;
                  if(item)
                  {
                     if(item.checkExperimentGate())
                     {
                        if(!this.m_staticData.growthConsumable)
                        {
                           this.m_staticData.growthConsumable = item.growthConsumable;
                        }
                        this.m_staticData.itemCodes.push(itemCode);
                     }
                  }
                  else
                  {
                     ErrorManager.addError("GrowableContest.loadStaticData() Invalid item code " + this.m_staticData.itemCodes[0] + " in configuration for contest " + this.m_contestId);
                  }
               }
               this.m_staticData.recipeIds = contestXML.crafting.@recipeIds.toString().split(",");
               this.m_staticData.buildingId = contestXML.@buildingId.toString();
               this.m_staticData.defaultCraftingBuilding = contestXML.crafting.@defaultCraftingBuilding.toString();
               this.m_staticData.maxConsumables = int(contestXML.@maxConsumables.toString());
               this.m_staticData.viralFeatureName = contestXML.@viralFeatureName.toString();
               this.m_staticData.zLocPrefix = contestXML.@zLocPrefix.toString();
               this.m_staticData.hudIconName = contestXML.@hudIconName.toString();
               if(contestXML.hasOwnProperty("@objectPreviewScale"))
               {
                  this.m_objectPreviewScale = Number(contestXML.@objectPreviewScale.toString());
               }
               slots = contestXML.slots;
               this.m_staticData.slotsBase = int(slots.@base);
               this.m_staticData.slotsMax = int(slots.@max);
               this.m_staticData.slotsCost = int(slots.@cost);
               this.m_staticData.maxAge = int(contestXML.autoFinishAge.children()[0].toXMLString());
               loot = contestXML.child("lootTables");
               for each(table in loot)
               {
                  lootInfo = new Object();
                  lootInfo.min = table.@min as int;
                  lootInfo.max = table.@max as int;
                  lootInfo.table = String(table.@table);
                  this.m_staticData.lootTables.push(lootInfo);
               }
               for each(assetXML in contestXML.assets.asset)
               {
                  assetInfo = {};
                  assetInfo.path = String(assetXML.@path);
                  this.m_assets[assetXML.@name] = assetInfo;
               }
               this.parseFeedData(XML(contestXML.toString()));
            }
         }
         this.initEmptyState();
      }
      
      public function getMaxAge() : int
      {
         return this.m_staticData.maxAge;
      }
      
      private function parseFeedData(featureXML:XML) : void
      {
         var feedData:XML = null;
         this.m_feedData = {};
         var feedTypes:XMLList = featureXML.feedConfig.feed;
         for(var j:int = 0; j < feedTypes.length(); j++)
         {
            feedData = feedTypes[j];
            this.m_feedData[feedData.@source] = {
               "source":feedData.@source,
               "throttle":feedData.@throttle,
               "throttleTime":feedData.@throttleTime
            };
         }
      }
      
      public function checkInviteStatus() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE,"updateAllInviteStates",this.onInviteStatusLoaded,[this.contestId]));
      }
      
      public function setLastInviteViewTime() : void
      {
         this.m_lastInviteViewed = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE,"setLastInviteViewTime",null,[this.contestId]));
      }
      
      private function onInviteStatusLoaded(result:Object) : void
      {
         this.m_isInviteStatusLoaded = true;
         dispatchEvent(new Event(GrowableContestConstants.EVENT_INVITE_STATUS_LOADED));
      }
      
      public function get isInviteStatusLoaded() : Boolean
      {
         return this.m_isInviteStatusLoaded;
      }
      
      private function updateAndNotifyNumNewInvites() : void
      {
         var pending:Object = null;
         var diffNumNewInvites:int = 0;
         var messages:Object = null;
         var numNewInvites:int = 0;
         var pendingList:Array = this.getPendingList();
         for each(pending in pendingList)
         {
            if(pending.hasOwnProperty("inviteTime"))
            {
               if(pending.inviteTime > this.m_lastInviteViewed)
               {
                  numNewInvites++;
               }
            }
         }
         if(numNewInvites != this.m_numNewInvites)
         {
            diffNumNewInvites = numNewInvites - this.m_numNewInvites;
            this.m_numNewInvites = numNewInvites;
            if(diffNumNewInvites > 0)
            {
               messages = {};
               messages[FeatureMessageEvent.MESSAGES_CALLTOACTION] = this.getZLocString("Dialogs","HUD_CTA_NewRequests");
               dispatchEvent(new Event(GrowableContestConstants.EVENT_PARTNER_REQUEST_UPDATE));
               FeatureMessagingManager.getInstance().dispatchFeatureMessage(new FeatureMessageEvent(FeatureMessageEvent.FEATUREUPDATE,this.m_staticData.hudIconName,messages));
            }
         }
      }
      
      public function getNumNewInvites() : int
      {
         this.updateAndNotifyNumNewInvites();
         return this.m_numNewInvites;
      }
      
      public function getPendingList() : Array
      {
         var o:Object = null;
         var pendingList:Array = [];
         for each(o in this.currentState.pendingObjs)
         {
            if(!this.isPendingAnsweredRequest(o["storageKey"]))
            {
               o["type"] = OBJECT_TYPE_REQUEST;
               pendingList.push(o);
            }
         }
         return pendingList;
      }
      
      public function hasPendingRequests() : Boolean
      {
         return this.getPendingList().length > 0;
      }
      
      public function get participatingList() : Array
      {
         return this.currentState.participatingObjs ? this.currentState.participatingObjs : [];
      }
      
      public function locallyRemoveParticipant(entry:IGrowableResource) : void
      {
         var i:int = 0;
         var tmpParticipatingList:Array = this.participatingList;
         if(tmpParticipatingList)
         {
            for(i = 0; i < tmpParticipatingList.length; i++)
            {
               if(tmpParticipatingList[i].storageKey == entry.persistentDataKey)
               {
                  tmpParticipatingList.splice(i,1);
                  break;
               }
            }
         }
      }
      
      public function get numCompletions() : int
      {
         return this.currentState.completions;
      }
      
      public function placeEntry(storageKey:String) : void
      {
         var obj:FarmItem = null;
         var tempResource:GrowableAnimal = null;
         var entry:Object = this.getContestEntryForKey(storageKey,CONTEST_LIST_PARTICIPATING);
         if(entry)
         {
            obj = Global.farmGameSettingsManager.getFarmItemByCode(entry.code);
            tempResource = new GrowableAnimal();
            tempResource.setItem(obj);
            tempResource.setState(obj.getPreviewState());
            tempResource.attachToPersistentData(storageKey);
            tempResource.createDisplayObject();
            Global.world.addGameMode(new GMGrowableContestPlaceInvited(tempResource),true);
         }
      }
      
      public function getContestEntryForKey(storageKey:String, listToCheck:int = 3) : Object
      {
         var result:Object = null;
         var list:Array = null;
         var entry:Object = null;
         if(!GrowableContestManager.instance.isFeatureEnabled())
         {
            listToCheck = 0;
         }
         if(listToCheck & CONTEST_LIST_PARTICIPATING)
         {
            list = this.participatingList;
            for each(entry in list)
            {
               if(entry.storageKey == storageKey)
               {
                  result = entry;
                  break;
               }
            }
         }
         if(!result && Boolean(listToCheck & CONTEST_LIST_PENDING))
         {
            list = this.getPendingList();
            for each(entry in list)
            {
               if(entry.storageKey == storageKey)
               {
                  result = entry;
                  break;
               }
            }
         }
         return result;
      }
      
      public function get growthConsumable() : String
      {
         return this.m_staticData.growthConsumable;
      }
      
      public function rejectRequest(storageKey:String, callback:Function = null) : void
      {
         this.addPendingAnsweredRequest(storageKey);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE,"rejectInvite",function():void
         {
            removePendingAnsweredRequest(storageKey);
            if(callback != null)
            {
               callback();
            }
         },[storageKey]),true);
      }
      
      public function acceptRequest(storageKey:String, callback:Function) : void
      {
         this.addPendingAnsweredRequest(storageKey);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE,"acceptInvite",function(data:Object):void
         {
            removePendingAnsweredRequest(storageKey);
            callback(data);
         },[storageKey]),true);
      }
      
      private function isPendingAnsweredRequest(storageKey:String) : Boolean
      {
         return this.m_pendingAnsweredRequests[storageKey] == true;
      }
      
      private function addPendingAnsweredRequest(storageKey:String) : void
      {
         this.m_pendingAnsweredRequests[storageKey] = true;
      }
      
      private function removePendingAnsweredRequest(storageKey:String) : void
      {
         delete this.m_pendingAnsweredRequests[storageKey];
      }
      
      public function weighObject(data:Object) : void
      {
         var storageKey:String = null;
         var window:GrowableContestResultsWindow = null;
         if(data.hasOwnProperty("storageKey"))
         {
            storageKey = data["storageKey"];
            if(!this.m_weighedStorageIds.hasOwnProperty(storageKey))
            {
               this.m_weighedStorageIds[storageKey] = true;
               window = new GrowableContestResultsWindow(this,data);
               UI.displayPopup(window);
               TransactionManager.addTransaction(new TGrowableContestScore(storageKey,function(result:Object):void
               {
                  dispatchEvent(new Event(getParticipantCompletedEventName(storageKey)));
                  window.resultsCallback(result);
               }),true);
            }
         }
      }
      
      public function postGeneralFeed(type:String, callback:Function, targetId:String = null, storageKey:String = null) : void
      {
         this.m_feedPostPending = true;
         TransactionManager.addTransaction(new TGrowableContestFeedPost(this.wrapCallbackForThrottle(callback),this.m_contestId,type,targetId,storageKey),true);
      }
      
      public function canPostFeed(type:String, targetId:String = null, storageKey:String = null) : Boolean
      {
         return this.getTimeUntilPostFeedEnabled(type,targetId,storageKey) <= 0;
      }
      
      public function getTimeUntilPostFeedEnabled(type:String, targetId:String = null, storageKey:String = null) : int
      {
         var throttle:String = null;
         var timeSinceLastFeed:int = 0;
         var result:int = int.MAX_VALUE;
         var feedData:Object = this.m_feedData[type];
         if(feedData)
         {
            throttle = feedData.throttle;
            if(targetId)
            {
               throttle += "_" + targetId;
            }
            if(storageKey)
            {
               throttle += "_" + storageKey;
            }
            timeSinceLastFeed = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - Global.player.getFeatureLastShown(throttle);
            result = feedData.throttleTime - timeSinceLastFeed;
         }
         return result;
      }
      
      private function wrapCallbackForThrottle(callback:Function) : Function
      {
         return function(feedData:Object):void
         {
            m_feedPostPending = false;
            var result:* = feedData.postSuccessful;
            if(Boolean(result) && feedData.hasOwnProperty("throttle"))
            {
               TransactionManager.addTransaction(new TSetFeatureFrequencyTimestamp(feedData.throttle),true);
               Global.player.setFeatureLastShown(feedData.throttle,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,false);
            }
            callback(result);
         };
      }
      
      public function makePartnerRequest(storageKey:String) : void
      {
         var entryCode:String = null;
         var reqItem:FarmItem = null;
         var friendSpec:Object = {
            "tabNameSuggested":[MFSConstants.TYPE_SUGGESTED],
            "tabNameFarmVille":[MFSConstants.TYPE_FARMVILLE],
            "tabNameFacebook":[MFSConstants.TYPE_FACEBOOK]
         };
         var friendTabOrder:Array = ["tabNameSuggested","tabNameFarmVille","tabNameFacebook"];
         var entry:Object = this.getContestEntryForKey(storageKey);
         if(entry)
         {
            entryCode = entry.code;
            reqItem = Global.farmGameSettingsManager.getFarmItemByCode(entryCode);
            UI.displayPopup(new MFSAskGrowablePartner(friendSpec,friendTabOrder,reqItem,this.m_staticData.viralFeatureName,storageKey,this.partnerRequestMFSCallback(storageKey)),false);
            this.statCount("ask_for_help","impressions");
         }
      }
      
      public function openMakeRecipeWindow() : void
      {
         var i:int;
         var recipeId:String = null;
         var craftshopOpened:Boolean = false;
         var prompt:GenericXMLDialog = null;
         for(i = 0; i < this.m_staticData.recipeIds.length; i++)
         {
            recipeId = this.m_staticData.recipeIds[i];
            craftshopOpened = false;
            if(CraftingManager.getInstance().showCraftingWindowForRecipe(recipeId))
            {
               craftshopOpened = true;
               break;
            }
         }
         if(!craftshopOpened)
         {
            prompt = new GenericXMLDialog(null,null,null,Global.farmGameSettingsManager.getImageByName(this.m_staticData.defaultCraftingBuilding,"icon",false),100,100,this.getZLocString("Dialogs","SurfaceCraftShop_Message"),null,true,this.getZLocString("Dialogs","SurfaceCraftShop_Button"),function(event:Event):void
            {
               Global.world.enterForcePlaceMode(m_staticData.defaultCraftingBuilding,true,0,false,false,{"suppressGiftRepop":true});
            });
            UI.displayPopup(prompt,true,"",true);
         }
      }
      
      private function partnerRequestMFSCallback(obdId:String) : Function
      {
         return function(data:Array):void
         {
            TransactionManager.addTransaction(new TGenericTransaction(GrowableContest.SERVICE,"addPendingRequests",null,[obdId,data]),true);
            statCount("ask_for_help","sends",data ? data.length.toString() : "0");
         };
      }
      
      public function acceptHelp(resource:IGrowableResource, callback:Function) : void
      {
         var storageKey:String = resource.growableMapResource.persistentDataKey;
         var entry:Object = this.getContestEntryForKey(storageKey,CONTEST_LIST_PARTICIPATING);
         var altResource:IGrowableResource = null;
         if(entry.world == Global.worldManager.currentWorldType)
         {
            altResource = Global.world.getObjectById(entry.instanceId) as IGrowableResource;
         }
         var storageData:Object = resource.getGrowableInstanceData();
         if(entry.pendingPartnerAction)
         {
            entry.pendingPartnerAction = false;
            resource.refreshVisibleToActual(null);
            if(altResource)
            {
               resource.growableMapResource.reloadImage();
            }
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE,"acceptPartnerAction",callback,[resource.growableMapResource.persistentDataKey]),true);
         }
      }
      
      public function getMarketCodes() : Array
      {
         return this.m_staticData.itemCodes;
      }
      
      public function getActiveObjects() : Array
      {
         var object:Object = null;
         var newList:Array = this.participatingList.concat();
         if(!newList)
         {
            newList = new Array();
         }
         for each(object in newList)
         {
            object["type"] = OBJECT_TYPE_ACTIVE;
         }
         return this.fillInObjects(newList);
      }
      
      private function fillInObjects(newList:Array) : Array
      {
         var activeLength:int = int(newList.length);
         for(var i:int = 0; i + activeLength < this.m_staticData.slotsMax; i++)
         {
            if(activeLength + i < this.getCapacity())
            {
               newList.push({"type":OBJECT_TYPE_UNLOCKED});
            }
            else
            {
               newList.push({
                  "type":OBJECT_TYPE_LOCKED,
                  "price":this.m_staticData.slotsCost
               });
            }
         }
         return newList;
      }
      
      public function availableCapacity() : int
      {
         return this.getCapacity() - this.participatingList.length;
      }
      
      public function getCapacity() : int
      {
         return this.m_staticData.slotsMax;
      }
      
      public function getConsumableCount() : int
      {
         var s:StorageItem = Global.player.gifts[this.m_staticData.growthConsumable];
         return s ? s.quantity : 0;
      }
      
      public function get slotUnlockCost() : int
      {
         return this.m_staticData.slotsCost;
      }
      
      public function getChowCapacity() : int
      {
         return this.m_staticData.maxConsumables;
      }
      
      public function usesBuildingWithId(buildingId:String) : Boolean
      {
         return buildingId == this.m_staticData.buildingId;
      }
      
      public function canTakeParticipantItemCode(itemCode:String) : Boolean
      {
         return GrowableContestManager.instance.isFeatureEnabled() && this.getMarketCodes().indexOf(itemCode) >= 0;
      }
      
      public function getBuildingName() : String
      {
         return Global.farmGameSettingsManager.getFarmItemNameByCode(this.m_staticData.buildingId);
      }
      
      public function getBuilding() : FeatureBuilding
      {
         var result:FeatureBuilding = null;
         var buildings:Array = Global.world.getObjectsByCode(this.m_staticData.buildingId);
         if(buildings != null && buildings.length > 0 && buildings[0] is FeatureBuilding)
         {
            result = FeatureBuilding(buildings[0]);
         }
         return result;
      }
      
      public function getTutorial() : GrowableContestTutorial
      {
         return this.m_tutorial;
      }
      
      public function statCount(kingdom:String = "", phylum:String = "", zclass:String = "", family:String = "", genus:String = "", value:int = 1) : void
      {
         FarmStatsManager.count("contest_" + this.contestId,kingdom,phylum,zclass,family,genus,value);
      }
   }
}

