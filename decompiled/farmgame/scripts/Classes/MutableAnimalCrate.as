package Classes
{
   import Classes.Constants.MFSConstants;
   import Classes.Constants.StatsTrackingConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Helpers.Vector2;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.MFSRequestManager;
   import Transactions.TTransformBuilding;
   import com.adobe.serialization.json.JSON;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   
   public class MutableAnimalCrate extends ConstructionBuilding
   {
      
      public static const BREEDING_FEED:String = "animalfeedtrough_feed";
      
      protected static const OVERLAY_URL:String = "assets/overlays/effect_sapling_sparkling.swf";
      
      protected static const TRANSFORM_OVERLAY_URL:String = "assets/effects/effect_mysterycrate.swf";
      
      private static const OVERLAY_OFFSET:Vector2 = new Vector2(0,-90);
      
      private static const TRANSFORM_OVERLAY_OFFSET:Vector2 = new Vector2(20,25);
      
      private static const TRANSFORM_OVERLAY_SCALE:Number = 2.5;
      
      private static const STORAGE_CONTENT:String = "storageContent";
      
      private static const FULLY_BUILT:String = "fullyBuilt";
      
      private static const ADULT_CODE:String = "adultCode";
      
      public static const MINI_MARKET_ITEMS:Array = new Array(BREEDING_FEED,"pkg_animalFeedTrough_feed_10","pkg_animalFeedTrough_feed_15","pkg_animalFeedTrough_feed_20","pkg_animalFeedTrough_feed_30","pkg_animalFeedTrough_feed_40","pkg_animalFeedTrough_feed_50","pkg_animalFeedTrough_feed_60","pkg_animalFeedTrough_feed_70","pkg_animalFeedTrough_feed_80");
      
      private const STATE_STATIC:String = "static";
      
      protected const ASK_FOR_FEED:String = "askForFeed";
      
      protected const FEED_ANIMAL:String = "feedAnimal";
      
      protected const COMPLETE_NOW:String = "completeNow";
      
      protected var m_adultCode:String = "";
      
      public function MutableAnimalCrate(buildingType:String = null)
      {
         super(buildingType);
         setState(this.STATE_STATIC);
         m_surfacingKeyword = this.getItem().className;
      }
      
      public static function chooseInstanceToAddItemTo(buildingName:String, metadataArr:Array, partId:String) : String
      {
         var index:String = null;
         var remaining:int = 0;
         var instance:MutableAnimalCrate = new MutableAnimalCrate(buildingName);
         var highestFeedIndex:String = "";
         var highestFeedCount:int = instance.capacity;
         for(index in metadataArr)
         {
            if(highestFeedIndex == "")
            {
               highestFeedIndex = index;
            }
            instance.setMetadata(metadataArr[index]);
            remaining = instance.capacity - instance.count;
            if(remaining < highestFeedCount)
            {
               highestFeedCount = remaining;
               highestFeedIndex = index;
            }
         }
         return highestFeedIndex;
      }
      
      public static function createStoredFeatureInstance(buildingType:String = null, metadata:String = "") : MutableAnimalCrate
      {
         var instance:MutableAnimalCrate = new MutableAnimalCrate(buildingType);
         instance.isStoredFeature = true;
         if(metadata != "")
         {
            instance.setMetadata(metadata);
         }
         return instance;
      }
      
      override public function loadObject(data:Object) : void
      {
         super.loadObject(data);
         if(data.hasOwnProperty(ADULT_CODE) && data.adultCode != null && data.adultCode != "")
         {
            this.m_adultCode = data.adultCode;
         }
      }
      
      override protected function updateToolTipText() : void
      {
         var capacityText:String = null;
         var toolTip:String = null;
         if(isHighlighted())
         {
            if(Global.worldManager.isVisiting() == false)
            {
               capacityText = ZLocUtils.t("Items",m_item.name + "_capacity",{
                  "quantity":m_count,
                  "maximum":capacity
               });
               if(!isFullyBuilt())
               {
                  capacityText = ZLocUtils.t("Items",m_item.name + "_mats",{
                     "quantity":m_count,
                     "maximum":capacity
                  });
               }
               switch(state)
               {
                  case STATE_CONSTRUCTION:
                     toolTip = ZLocUtils.t("FarmGame","AnimalBuilding_capacity",{
                        "item":ZLocUtils.tk_pk(m_item.friendlyName),
                        "capacityStr":capacityText
                     });
                     break;
                  default:
                     toolTip = ZLocUtils.tk_pk_asTitle(m_item.friendlyName);
               }
            }
            else if(Global.worldManager.isVisiting() == true)
            {
               toolTip = ZLocUtils.tk_pk_asTitle(m_item.friendlyName);
            }
            if(state == STATE_BUILT)
            {
               toolTip = ZLocUtils.tk_pk_asTitle(getBuiltToolTipText());
            }
         }
         setToolTip(toolTip);
         updateToolTipPosition();
      }
      
      override public function getOverlayUrl() : String
      {
         var url:String = OVERLAY_URL;
         if(isFullyBuilt())
         {
            url = TRANSFORM_OVERLAY_URL;
         }
         return url;
      }
      
      override protected function getOverlayOffset() : Vector2
      {
         var offset:Vector2 = OVERLAY_OFFSET;
         if(isFullyBuilt())
         {
            offset = TRANSFORM_OVERLAY_OFFSET;
         }
         return offset;
      }
      
      override protected function getOverlayScale() : Number
      {
         var scale:Number = super.getOverlayScale();
         if(isFullyBuilt())
         {
            scale = TRANSFORM_OVERLAY_SCALE;
         }
         return scale;
      }
      
      override public function addItem(resource:MapResource, fromStorage:int = 0, isGift:Boolean = false, sendStoreItem:Boolean = true, force:Boolean = false) : Boolean
      {
         if(m_isStoredFeature)
         {
            sendStoreItem = false;
         }
         var result:Boolean = super.addItem(resource,fromStorage,isGift,sendStoreItem,force);
         if(isFullyBuilt())
         {
            this.dispOverlay(this.getOverlayUrl());
         }
         return result;
      }
      
      public function atGrowthMilestone() : Boolean
      {
         var result:Boolean = false;
         if(m_count == int(getMaterialsNeeded() / 2) || this.state == STATE_BUILT)
         {
            result = true;
         }
         return result;
      }
      
      override public function showMenu() : void
      {
         if(!m_isFullyBuilt)
         {
            m_menuItems.push({
               "label":ZLocUtils.t("Dialogs","CompleteNowCamel"),
               "action":this.COMPLETE_NOW
            });
            m_menuItems.push({
               "label":ZLocUtils.t("FarmGame","FeedBaby"),
               "action":this.FEED_ANIMAL
            });
            m_menuItems.push({
               "label":ZLocUtils.t("FarmGame","AskForFeed"),
               "action":this.ASK_FOR_FEED
            });
            super.showMenu();
         }
      }
      
      override public function canRotate() : Boolean
      {
         return false;
      }
      
      private function onAskForFeed() : void
      {
         MFSRequestManager.getInstance().makeAskMatsRequest(this.getItem().name,BREEDING_FEED,BREEDING_FEED,"",MFSConstants.SOURCE_DIALOG_CLICKED,getItem().statsCounter,"maturation","ask_for_feed");
      }
      
      override public function onCompleteNow() : void
      {
         UI.displayMessage(ZLocUtils.t("Dialogs",m_dialogName + "CompleteNow",{"quantity":this.calculateCashNeeded()}),GenericPopup.TYPE_ACCEPTCANCEL,this.onAcceptCompleteNowPopup);
      }
      
      protected function calculateCashNeeded(partCost:int = 1) : int
      {
         return int(partCost * (getMaterialsNeeded() - m_count));
      }
      
      protected function onAcceptCompleteNowPopup(event:GenericPopupEvent) : void
      {
         var cashCost:int = 0;
         var remainingFeed:int = 0;
         var buyResult:Boolean = false;
         var i:int = 0;
         var realXp:int = 0;
         if(event.button == GenericPopup.YES)
         {
            cashCost = this.calculateCashNeeded();
            remainingFeed = getMaterialsNeeded() - m_count;
            if(Global.player.canBuyCash(cashCost))
            {
               buyResult = false;
               for(i = 0; i < remainingFeed; i++)
               {
                  buyResult = Global.player.tryBuy(null,false,Global.farmGameSettingsManager.getFarmItemByName(BREEDING_FEED),0);
                  if(!buyResult)
                  {
                     break;
                  }
               }
               if(buyResult)
               {
                  realXp = Global.player.calculateAndAddXp(this.getItem().buyXp);
                  this.displayStatus(ZLocUtils.t("FarmGame","Status_BuyCash",{
                     "cashNum":cashCost,
                     "xpNum":realXp
                  }));
                  m_isFullyBuilt = true;
                  state = STATE_BUILT;
                  TransactionManager.addTransaction(new TTransformBuilding(this,true));
                  this.dispOverlay(this.getOverlayUrl());
               }
            }
            FarmStatsManager.count(getItem().statsCounter,"maturation","complete_now","accept",cashCost.toString());
         }
         else
         {
            FarmStatsManager.count(getItem().statsCounter,"maturation","complete_now","cancel");
         }
      }
      
      override protected function showStorageContextMenu() : Boolean
      {
         return false;
      }
      
      override public function getCurrentImageName() : String
      {
         return this.STATE_STATIC;
      }
      
      override public function getFinishedItem() : FarmItem
      {
         return Global.farmGameSettingsManager.getFarmItemByCode(this.m_adultCode);
      }
      
      override public function onFullyFinished(result:Object, transformedObj:MapResource = null) : void
      {
         var item:FarmItem = this.getItem();
         var statsKingdom:String = item.name + "_" + StatsTrackingConstants.DIALOG_STATE_EXPANSION_COMPLETE_KINGDOM;
         var finishedItem:FarmItem = null;
         var feedActionName:String = null;
         var dialogName:String = null;
         var fallbackKey:String = null;
         var fullyBuilt:String = "FullyBuilt";
         var sendToGiftBox:String = "SentToGiftBox";
         if(transformedObj != null)
         {
            feedActionName = m_buildingName + fullyBuilt;
            dialogName = m_dialogName + fullyBuilt;
            finishedItem = transformedObj.getItem();
         }
         else
         {
            if(finishedItem == null)
            {
               finishedItem = getFinishedItemFromResult(result);
            }
            feedActionName = m_buildingName + fullyBuilt;
            dialogName = m_dialogName + sendToGiftBox;
            fallbackKey = "AnimalBreedingGenericBaby" + sendToGiftBox;
         }
         createRewardFeed(feedActionName,statsKingdom,result.rewardLink,finishedItem.getImageByName("icon",false),null,finishedItem.iconUrl,statCountConstructableComplete,null,{
            "item":ZLocUtils.tk_pk(finishedItem.friendlyName),
            "animalName":ZLocUtils.tk_pk(finishedItem.friendlyName)
         },"",dialogName,finishedItem.name,fallbackKey);
      }
      
      public function onFeedAnimal() : void
      {
         var marketItems:Array = null;
         var i:int = 0;
         var name:String = null;
         var testItem:FarmItem = null;
         var feedItem:FarmItem = null;
         var numApplied:Number = NaN;
         var itemLimit:Number = NaN;
         var numNeeded:Number = NaN;
         var feedCount:Number = Global.player.getGiftCountForItem(BREEDING_FEED);
         if(feedCount <= 0)
         {
            marketItems = new Array();
            for(i = 0; i < MINI_MARKET_ITEMS.length; i++)
            {
               name = MINI_MARKET_ITEMS[i];
               testItem = Global.farmGameSettingsManager.getFarmItemByName(name);
               if(FarmGameSettingsManager.isInDataSourceExperiment())
               {
                  if(testItem.checkExperimentGate())
                  {
                     marketItems.push(testItem.name);
                  }
               }
               else if(testItem.checkExperimentGate(testItem.xml))
               {
                  marketItems.push(testItem.name);
               }
            }
            UI.displayMiniMarketDialog(marketItems);
            FarmStatsManager.count(getItem().statsCounter,"maturation","open_buy_feed_market");
         }
         else
         {
            feedItem = Global.farmGameSettingsManager.getFarmItemByName(BREEDING_FEED);
            if(feedItem != null)
            {
               numApplied = this.getAmount(feedItem.code);
               itemLimit = this.getItemLimit(feedItem);
               numNeeded = itemLimit - numApplied;
               if(numNeeded > feedCount)
               {
                  numNeeded = feedCount;
               }
               feedItem.onUse(this.getId(),{
                  "isGift":true,
                  "suppressGiftRepop":true,
                  "storageBuilding":this,
                  "numParts":numNeeded
               });
               FarmStatsManager.count(getItem().statsCounter,"maturation","feed_bottle",String(numNeeded));
            }
         }
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            switch(item.action)
            {
               case this.ASK_FOR_FEED:
                  this.onAskForFeed();
                  break;
               case this.FEED_ANIMAL:
                  this.onFeedAnimal();
                  break;
               case this.COMPLETE_NOW:
                  this.onCompleteNow();
                  break;
               default:
                  super.onMenuClick(event);
            }
         }
      }
      
      override public function getMetadata() : Object
      {
         return com.adobe.serialization.json.JSON.encode(this.packMetadata());
      }
      
      override public function setMetadata(value:Object) : void
      {
         var metadata:Object = null;
         if(value is String && (Boolean(value == "") || Boolean(Global.farmGameSettingsManager.getFarmItemByCode(value as String))))
         {
            this.m_adultCode = value as String;
         }
         else
         {
            metadata = com.adobe.serialization.json.JSON.decode(value as String);
            this.setStorageStateFromMetadata(metadata);
         }
      }
      
      override public function getMetadataKey() : String
      {
         return Global.farmGameSettingsManager.getFarmItemCodeByName(this.getItemName());
      }
      
      private function setStorageStateFromMetadata(metadata:Object) : void
      {
         setState(STATE_CONSTRUCTION);
         if(Boolean(metadata[ADULT_CODE]) && metadata[ADULT_CODE] != "")
         {
            this.m_adultCode = metadata.adultCode;
         }
         if(metadata.hasOwnProperty(STORAGE_CONTENT))
         {
            this.initStorageFromMetadata(metadata.storageContent);
         }
         if(metadata.hasOwnProperty(FULLY_BUILT))
         {
            this.m_isFullyBuilt = metadata.fullyBuilt;
            if(m_isFullyBuilt)
            {
               setState(STATE_BUILT);
            }
         }
      }
      
      private function initStorageFromMetadata(storageContent:Array) : void
      {
         var i:int = 0;
         var partCode:String = null;
         m_contents = new Dictionary();
         for(m_count = 0; i < storageContent.length; )
         {
            if(Boolean(storageContent[i].hasOwnProperty("itemCode")) && Boolean(storageContent[i].hasOwnProperty("numItem")))
            {
               partCode = storageContent[i].itemCode;
               m_contents[partCode] = storageContent[i].numItem;
               m_count += storageContent[i].numItem;
            }
            i++;
         }
      }
      
      private function packMetadata() : Object
      {
         var metadata:Object = new Object();
         metadata[STORAGE_CONTENT] = this.packStorageMetadata();
         metadata[FULLY_BUILT] = m_isFullyBuilt;
         metadata[ADULT_CODE] = this.m_adultCode;
         return metadata;
      }
      
      private function packStorageMetadata() : Array
      {
         var key:String = null;
         var part:Object = null;
         var result:Array = new Array();
         for(key in m_contents)
         {
            part = new Object();
            part["itemCode"] = key;
            part["numItem"] = m_contents[key];
            result.push(part);
         }
         return result;
      }
      
      override public function packStoreItemMetaData() : Object
      {
         return this.getMetadata();
      }
      
      override public function dispOverlay(url:String, overlayParams:Object = null) : void
      {
         if(!m_isStoredFeature)
         {
            super.dispOverlay(url,overlayParams);
         }
      }
      
      public function getDefaultMetadata() : Object
      {
         return this.getMetadata();
      }
   }
}

