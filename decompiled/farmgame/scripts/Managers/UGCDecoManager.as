package Managers
{
   import Classes.Constants.MFSConstants;
   import Classes.Friend;
   import Classes.MapResource;
   import Classes.UGC.UGCConstants;
   import Classes.WorldObjectTypes;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.IUGCItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Events.DynamicObjectEvent;
   import Transactions.TGenericTransaction;
   import Transactions.TSetFeatureFrequencyTimestamp;
   import Transactions.UGCDeco.TUGCDecoFeedPost;
   import Widgets.Constants.Market.Currency;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.MFSAskItems;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   
   public class UGCDecoManager extends EventDispatcher
   {
      
      private static var s_instance:UGCDecoManager;
      
      public static const DEFAULT_FEATURE_NAME:String = "UGCDeco";
      
      public static const UGC_MATERIALS_INDEX:String = "ugc_materials";
      
      public static const UGC_COMPLETED_INDEX:String = "ugc_completed";
      
      public static const UGC_LAST_EDITED_DECO_INDEX:String = "ugc_lastEdited";
      
      public static const UGCDECOSERVICE:String = "UGCDecoService";
      
      public static const PURCHASEPART:String = "purchasePart";
      
      public static const SETLASTBLUEPRINT:String = "setLastEditedBlueprint";
      
      public static const ARROWSELECTION:String = "onArrowSelection";
      
      public static const ARROWSHOWN:String = "onShowRecentHelpArrow";
      
      public static const SOURCE_UI:String = "ui";
      
      public static const UGC_DEFAULT_BLUEPRINT:String = "ugc_deco_shack";
      
      private static const UGC_DECO_WORKSHOP:String = "ugc_deco_workshop";
      
      private var m_data:Object;
      
      private var m_dropTables:Dictionary;
      
      private var m_blacklistedItems:Array;
      
      private var m_minCoinCost:int = 500;
      
      private var m_materials:Dictionary = null;
      
      private var m_feedData:Object = {};
      
      private var m_feedLocks:Object = {};
      
      private var m_onUnlockCallbacks:Object = {};
      
      private var m_isDataLoaded:Boolean = false;
      
      private const R4R_TYPE_NORMAL:String = "normal";
      
      private const R4R_TYPE_REACT:String = "react";
      
      private const R4R_TYPE_NEW:String = "new";
      
      private const DEFAULT_MAX_BY_MATERIAL:int = 100;
      
      private var m_featureXML:XML = null;
      
      public function UGCDecoManager(key:SingletonEnforcer)
      {
         super();
         GlobalEngine.assert(key != null,"[UGCDecoManager] :: Use GetInstance()");
      }
      
      public static function get instance() : UGCDecoManager
      {
         if(!s_instance)
         {
            s_instance = new UGCDecoManager(new SingletonEnforcer());
         }
         return s_instance;
      }
      
      public function init() : void
      {
         this.m_data = s_instance.getFeatureData();
         if(!this.m_featureXML)
         {
            this.m_featureXML = Global.farmGameSettingsManager.getFeatureXML(DEFAULT_FEATURE_NAME);
         }
         if(Global.flashHotParams["UGC_DECO_RECYCLE_MINCOIN"])
         {
            this.m_minCoinCost = parseInt(Global.flashHotParams["UGC_DECO_RECYCLE_MINCOIN"]);
         }
         this.parseMaterials();
         this.parseDropTables(this.m_featureXML);
         this.parseBlacklistedItems(this.m_featureXML);
         this.parseFeedData(this.m_featureXML);
         this.m_isDataLoaded = true;
      }
      
      private function parseBlacklistedItems(featureXML:XML) : void
      {
         var itemName:String = null;
         var runtimeBlacklist:String = null;
         var items:XMLList = null;
         this.m_blacklistedItems = [];
         if(Global.flashHotParams["UGC_DECO_RECYCLE_BLACKLIST"])
         {
            runtimeBlacklist = Global.flashHotParams["UGC_DECO_RECYCLE_BLACKLIST"];
            this.m_blacklistedItems = runtimeBlacklist.split(",");
         }
         if(Boolean(featureXML) && Boolean(featureXML.blacklistedItems))
         {
            items = featureXML.blacklistedItems.item;
            for each(itemName in items)
            {
               this.m_blacklistedItems.push(itemName.toString());
            }
         }
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
      
      public function getBlueprints(featureName:String) : XML
      {
         var result:XML = null;
         this.m_featureXML = Global.farmGameSettingsManager.getFeatureXML(featureName);
         if(this.m_featureXML)
         {
            result = this.m_featureXML.blueprints.layer[0] as XML;
         }
         return result;
      }
      
      private function parseMaterials() : void
      {
         var material:XML = null;
         if(this.m_materials == null)
         {
            this.m_materials = new Dictionary();
         }
         var materials:XMLList = Global.farmGameSettingsManager.getAllFeatureXMLMaterials();
         for each(material in materials)
         {
            this.m_materials[material.@name.toString()] = {
               "name":material.@name.toString(),
               "max":material.@max.toString(),
               "ask":material.@ask.toString(),
               "askFilter":material.@askFilter.toString(),
               "feedSource":material.@feedSource.toString(),
               "recyclable":material.@recyclable.toString()
            };
         }
      }
      
      public function getMaxByMaterial(material:String) : int
      {
         return this.m_materials.hasOwnProperty(material) ? int(this.m_materials[material].max) : this.DEFAULT_MAX_BY_MATERIAL;
      }
      
      public function getDropTable(type:String) : Array
      {
         var result:Array = null;
         if(this.m_dropTables.hasOwnProperty(type))
         {
            result = this.m_dropTables[type];
         }
         else
         {
            result = new Array();
         }
         return result;
      }
      
      private function parseDropTables(feature:XML) : void
      {
         var dropRateItems:XMLList = null;
         var j:int = 0;
         var table:XML = null;
         var lootTables:XMLList = null;
         var lootTableLength:int = 0;
         var tables:Array = null;
         this.m_dropTables = new Dictionary();
         var dropRates:XMLList = feature.dropTables.weights.weightTable;
         var dropRateLength:int = dropRates.length();
         var drops:Object = new Object();
         for(var i:int = 0; i < dropRateLength; i++)
         {
            dropRateItems = dropRates[i].lootItem;
            for(j = 0; j < dropRateItems.length(); j++)
            {
               drops[String(dropRates[i].@name)] = String(dropRateItems[j].@itemName);
            }
         }
         var list:XMLList = feature.dropTables.dropTable;
         var listLength:int = list.length();
         for(i = 0; i < listLength; i++)
         {
            table = list[i];
            lootTables = table.lootTable;
            lootTableLength = lootTables.length();
            tables = new Array();
            for(j = 0; j < lootTableLength; j++)
            {
               tables.push(this.m_materials[String(drops[lootTables[j].@name])]);
            }
            this.m_dropTables[String(table.@name)] = tables;
         }
      }
      
      public function postUGCDecoFeed(friendReward:String, source:String, featureName:String, identifier:String = null, callback:Function = null) : void
      {
         TransactionManager.addTransaction(new TUGCDecoFeedPost(callback,identifier,source,friendReward,featureName),true);
      }
      
      public function makeAskItemsRequest(itemName:String, source:String = "") : void
      {
         var friendSpec:Object = {};
         switch(this.m_materials[itemName]["askFilter"])
         {
            case this.R4R_TYPE_NORMAL:
               friendSpec["tabNameRecommended"] = [MFSConstants.TYPE_SINGLE_PARTS,MFSConstants.TYPE_REACTIVATION];
               break;
            case this.R4R_TYPE_REACT:
               friendSpec["tabNameRecommended"] = [MFSConstants.TYPE_REACTIVATION];
               break;
            case this.R4R_TYPE_NEW:
               friendSpec["tabNameRecommended"] = [MFSConstants.TYPE_REACTIVATION];
         }
         var friendTabOrder:Array = ["tabNameRecommended"];
         var reqItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         UI.displayPopup(new MFSAskItems(friendSpec,friendTabOrder,reqItem,UGCDecoManager.DEFAULT_FEATURE_NAME,source,null),false);
      }
      
      public function doSocialRequest(itemName:String, source:String, featureName:String, callback:Function = null) : void
      {
         var itemCode:String = null;
         switch(this.m_materials[itemName]["ask"])
         {
            case "r4r":
               this.makeAskItemsRequest(itemName,source);
               StatsManager.count(UGCConstants.STATS_COUNTER,"send_request",itemName);
               break;
            case "feed":
               if(this.canTakePostAction(source))
               {
                  itemCode = Global.farmGameSettingsManager.getFarmItemCodeByName(itemName);
                  this.postUGCDecoFeed("UGCDecoMaterialFriendReward",source,featureName,itemCode,callback);
                  StatsManager.count(UGCConstants.STATS_COUNTER,"send_feed",itemName);
               }
         }
      }
      
      public function showUGCDecoDialog(gameSettingsFeatureName:String, ugcItem:IUGCItem) : void
      {
         var dialogConfig:Object = Global.farmGameSettingsManager.getBuildingDialogConfig(UGC_DECO_WORKSHOP);
         GlobalEngine.assert(Boolean(dialogConfig) && Boolean(dialogConfig.redirectClassName),"[FeatureBuidingShimWindow] redirectClassName was not found in dialog config.");
         var dialogClassName:String = dialogConfig.redirectClassName;
         var dialogClass:Class = getDefinitionByName(dialogClassName) as Class;
         var buildingDialog:FarmWindow = new dialogClass(ugcItem,null,gameSettingsFeatureName);
         UI.displayPopup(buildingDialog,true,dialogClassName,true);
      }
      
      public function getMaterialAsk(materialName:String) : String
      {
         var result:String = "";
         if(this.m_materials.hasOwnProperty(materialName))
         {
            if(this.m_materials[materialName]["ask"])
            {
               result = this.m_materials[materialName]["ask"];
            }
         }
         return result;
      }
      
      public function getMaterialFeedSource(materialName:String) : String
      {
         var result:String = "";
         if(this.m_materials.hasOwnProperty(materialName))
         {
            if(this.m_materials[materialName]["feedSource"])
            {
               result = this.m_materials[materialName]["feedSource"];
            }
         }
         if(result == "")
         {
            result = SOURCE_UI;
         }
         return result;
      }
      
      public function purchaseMaterial(item:FarmItem, callback:Function) : void
      {
         if(this.m_materials.hasOwnProperty(item.name))
         {
            if(Global.player.canBuyCash(item.cash))
            {
               TransactionManager.addTransaction(new TGenericTransaction(UGCDECOSERVICE,PURCHASEPART,this.makeFunction(callback),[item.name,1]));
               Global.player.cash -= item.cash;
               if(this.m_data[UGC_MATERIALS_INDEX].hasOwnProperty(item.name))
               {
                  this.m_data[UGC_MATERIALS_INDEX][item.name] += 1;
               }
               else
               {
                  this.m_data[UGC_MATERIALS_INDEX][item.name] = 1;
               }
            }
         }
      }
      
      private function makeFunction(callback:Function) : Function
      {
         return function(result:Object):void
         {
            callback(result);
         };
      }
      
      public function getPartCount(partName:String) : int
      {
         return this.m_data[UGC_MATERIALS_INDEX].hasOwnProperty(partName) ? int(this.m_data[UGC_MATERIALS_INDEX][partName]) : 0;
      }
      
      public function getRecyclableMaterials() : Array
      {
         var material:String = null;
         var result:Array = [];
         for(material in this.m_materials)
         {
            if(this.m_materials[material])
            {
               if(this.m_materials[material].recyclable == "true")
               {
                  result.push(this.m_materials[material]);
               }
            }
         }
         return result;
      }
      
      public function getFeatureData() : Object
      {
         var data:Object = FeatureOptionsManager.getInstance().getFeatureOption(DEFAULT_FEATURE_NAME,DEFAULT_FEATURE_NAME);
         if(!data)
         {
            data = this.createFeatureData();
         }
         return data;
      }
      
      public function setFeatureData(data:Object) : void
      {
         var material:String = null;
         var eventData:Object = null;
         if(this.m_data)
         {
            for(material in data[UGC_MATERIALS_INDEX])
            {
               if(data[UGC_MATERIALS_INDEX][material] != this.m_data[UGC_MATERIALS_INDEX][material])
               {
                  eventData = {
                     "material":material,
                     "oldAmt":this.m_data[UGC_MATERIALS_INDEX][material],
                     "newAmt":data[UGC_MATERIALS_INDEX][material]
                  };
                  dispatchEvent(new DynamicObjectEvent(UGCConstants.EVENT_MATERIAL_COUNT_MODIFIED,eventData));
               }
            }
            this.m_data = data;
            FeatureOptionsManager.getInstance().setFeatureOption(DEFAULT_FEATURE_NAME,DEFAULT_FEATURE_NAME,data);
         }
      }
      
      private function createFeatureData() : Object
      {
         var materials:Object = new Object();
         var data:Object = {};
         data[UGC_MATERIALS_INDEX] = materials;
         data[UGC_COMPLETED_INDEX] = [];
         return data;
      }
      
      public function getMinRecyclePrice() : int
      {
         return this.m_minCoinCost;
      }
      
      public function isItemBlacklisted(itemName:String) : Boolean
      {
         return this.m_blacklistedItems.indexOf(itemName) != -1;
      }
      
      public function findRecyclableObjectsInWorld() : Array
      {
         var item:FarmItem = null;
         var resource:MapResource = null;
         var dropTable:String = null;
         var recyclableItems:Array = [];
         var types:int = WorldObjectTypes.BUILDING | WorldObjectTypes.TREE | WorldObjectTypes.DECORATION;
         var objects:Array = Global.world.getObjectsByType(types);
         var objIdx:int = 0;
         var objLen:uint = objects.length;
         while(objIdx < objLen)
         {
            resource = objects[objIdx] as MapResource;
            if(Boolean(resource) && resource.isClearable())
            {
               item = resource.getItem();
               if(item)
               {
                  if(!this.isItemBlacklisted(item.name))
                  {
                     dropTable = "";
                     switch(resource.getObjectType())
                     {
                        case WorldObjectTypes.DECORATION:
                           dropTable = "decoration";
                           break;
                        case WorldObjectTypes.TREE:
                           dropTable = "tree";
                           break;
                        case WorldObjectTypes.BUILDING:
                           dropTable = "building";
                     }
                     if(dropTable != "")
                     {
                        if(item.currency == Currency.COINS || item.currency == Currency.COCONUTS || item.currency == Currency.JADE)
                        {
                           if(item.cost >= this.getMinRecyclePrice())
                           {
                              recyclableItems.push({
                                 "obj":resource,
                                 "table":dropTable
                              });
                           }
                        }
                        else if(item.buyableWithCash())
                        {
                           recyclableItems.push({
                              "obj":resource,
                              "table":dropTable + "_premium"
                           });
                        }
                     }
                  }
               }
            }
            objIdx++;
         }
         return recyclableItems;
      }
      
      public function canTakePostAction(source:String) : Boolean
      {
         return this.m_isDataLoaded && this.secondsLeftToNextPostAction(source) == 0 && !this.isFeedLocked(source);
      }
      
      public function secondsLeftToNextPostAction(source:String) : int
      {
         var timeSinceLastFeed:int = 0;
         var seconds:int = 0;
         var feedData:Object = this.m_feedData[source];
         if(feedData)
         {
            timeSinceLastFeed = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - Global.player.getFeatureLastShown(feedData.throttle);
            seconds = feedData.throttleTime - timeSinceLastFeed;
            if(seconds < 0)
            {
               seconds = 0;
            }
         }
         return seconds;
      }
      
      public function setAskThrottle(source:String) : void
      {
         var feedData:Object = this.m_feedData[source];
         if(feedData)
         {
            TransactionManager.addTransaction(new TSetFeatureFrequencyTimestamp(feedData.throttle),true);
            Global.player.setFeatureLastShown(feedData.throttle,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,false);
         }
      }
      
      public function lockUGCDecoFeedPost(source:String) : void
      {
         var feedData:Object = this.m_feedData[source];
         if(feedData)
         {
            this.m_feedLocks[feedData.throttle] = 1;
         }
      }
      
      public function unlockUGCDecoFeedPost(source:String) : void
      {
         var func:Function = null;
         var feedData:Object = this.m_feedData[source];
         if(feedData)
         {
            func = this.m_onUnlockCallbacks[source] as Function;
            if(func != null)
            {
               func();
            }
            this.m_onUnlockCallbacks[source] = null;
            this.m_feedLocks[feedData.throttle] = null;
         }
      }
      
      public function isFeedLocked(source:String) : Boolean
      {
         var result:Boolean = false;
         var feedData:Object = this.m_feedData[source];
         if(feedData)
         {
            result = this.m_feedLocks[feedData.throttle] == 1;
         }
         return result;
      }
      
      public function registerOnUnlockCallback(source:String, func:Function) : void
      {
         this.m_onUnlockCallbacks[source] = func;
      }
      
      public function prerequisiteMet(blueprintName:String) : Boolean
      {
         return this.m_data ? Boolean(this.m_data[UGC_COMPLETED_INDEX].hasOwnProperty(blueprintName)) : false;
      }
      
      public function getArrowStateData() : Object
      {
         var result:Object = null;
         var curTime:int = 0;
         var recentHelpTime:int = 0;
         var helpedItem:FarmItem = null;
         var friend:Friend = null;
         var matCount:int = 0;
         if(Boolean(this.m_data) && Boolean(this.m_data["recentHelp"]))
         {
            curTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            recentHelpTime = int(this.m_data["recentHelp"]["time"]);
            if(recentHelpTime > 0 && recentHelpTime < curTime)
            {
               helpedItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_data["recentHelp"]["type"]);
               if(helpedItem)
               {
                  result = {
                     "title":ZLocUtils.t("Dialogs","UGCDecoWorkshop_arrow_mat_title"),
                     "desc":ZLocUtils.t("Dialogs","UGCDecoWorkshop_arrow_mat_desc"),
                     "icon":helpedItem.icon
                  };
                  if(this.m_data["recentHelp"]["uid"])
                  {
                     friend = Global.friendManager.getFriendData(this.m_data["recentHelp"]["uid"]);
                     if(friend)
                     {
                        result.title = ZLocUtils.t("Dialogs","UGCDecoWorkshop_arrow_crew_title",{
                           "name":friend.firstName,
                           "count":String(UGCDecoManager.instance.getPartCount(helpedItem.name) - 1)
                        });
                        result.icon = friend.picture;
                        matCount = this.getPartCount(helpedItem.name);
                        if(matCount > 1)
                        {
                           result.desc = ZLocUtils.t("Dialogs","UGCDecoWorkshop_arrow_crew_desc",{
                              "name":friend.firstName,
                              "count":matCount.toString()
                           });
                        }
                        else
                        {
                           result.desc = ZLocUtils.t("Dialogs","UGCDecoWorkshop_arrow_crew_desc_singular",{"name":friend.firstName});
                        }
                     }
                  }
               }
            }
         }
         return result;
      }
      
      public function getLastEditedBlueprint(gameSettingsFeatureName:String) : String
      {
         var savedResult:String = null;
         var farmItem:FarmItem = null;
         var result:String = this.getDefaultBlueprint(gameSettingsFeatureName);
         if(Boolean(this.m_data) && Boolean(this.m_data.hasOwnProperty(UGC_LAST_EDITED_DECO_INDEX)) && Boolean(this.m_data[UGC_LAST_EDITED_DECO_INDEX].hasOwnProperty(gameSettingsFeatureName)))
         {
            savedResult = this.m_data[UGC_LAST_EDITED_DECO_INDEX][gameSettingsFeatureName].toString();
            if(savedResult != null && savedResult != "")
            {
               farmItem = Global.farmGameSettingsManager.getFarmItemByName(savedResult);
               if(Boolean(farmItem) && farmItem.gameSettingsFeatureName == gameSettingsFeatureName)
               {
                  result = savedResult;
               }
            }
         }
         return result;
      }
      
      public function getDefaultBlueprint(featureName:String) : String
      {
         var blueprintXML:XML = null;
         var result:String = UGC_DEFAULT_BLUEPRINT;
         var blueprintsXML:XML = this.getBlueprints(featureName);
         if(blueprintsXML)
         {
            for each(blueprintXML in blueprintsXML.items.item)
            {
               if(Boolean(blueprintXML.hasOwnProperty("@default")) && Boolean(blueprintXML["@default"] == "true") && blueprintXML.hasOwnProperty("@name"))
               {
                  result = blueprintXML["@name"];
                  break;
               }
            }
         }
         return result;
      }
      
      public function setLastEditedBlueprint(gameSettingsFeatureName:String, itemName:String) : void
      {
         var tmpUGCDeco:String = null;
         var doUpdate:Boolean = false;
         if(this.m_data)
         {
            if(!this.m_data.hasOwnProperty(UGC_LAST_EDITED_DECO_INDEX))
            {
               this.m_data[UGC_LAST_EDITED_DECO_INDEX] = new Object();
               doUpdate = true;
            }
            else if(this.m_data[UGC_LAST_EDITED_DECO_INDEX] is String)
            {
               tmpUGCDeco = this.m_data[UGC_LAST_EDITED_DECO_INDEX];
               this.m_data[UGC_LAST_EDITED_DECO_INDEX] = null;
               this.m_data[UGC_LAST_EDITED_DECO_INDEX] = new Object();
               this.m_data[UGC_LAST_EDITED_DECO_INDEX][UGCDecoManager.DEFAULT_FEATURE_NAME] = tmpUGCDeco;
               doUpdate = true;
            }
            if(doUpdate || this.m_data[UGC_LAST_EDITED_DECO_INDEX][gameSettingsFeatureName] != itemName)
            {
               this.m_data[UGC_LAST_EDITED_DECO_INDEX][gameSettingsFeatureName] = itemName;
               TransactionManager.addTransaction(new TGenericTransaction(UGCDECOSERVICE,SETLASTBLUEPRINT,null,[gameSettingsFeatureName,itemName]));
            }
         }
      }
   }
}

class SingletonEnforcer
{
   
   public function SingletonEnforcer()
   {
      super();
   }
}
