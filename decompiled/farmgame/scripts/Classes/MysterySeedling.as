package Classes
{
   import Classes.Constants.Experiments;
   import Classes.Constants.MFSConstants;
   import Classes.Constants.StatsTrackingConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Constants;
   import Engine.Helpers.Vector2;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.MFSRequestManager;
   import Transactions.TTransformBuilding;
   import com.adobe.serialization.json.JSON;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   
   public class MysterySeedling extends ConstructionBuilding
   {
      
      protected static const OVERLAY_URL:String = "assets/overlays/effect_sapling_sparkling.swf";
      
      private static const OVERLAY_OFFSET:Vector2 = new Vector2(0,-42);
      
      public static const WATERING_CAN:String = "wateringcan";
      
      public static const MINI_MARKET_ITEMS:Array = new Array(WATERING_CAN,"pkg_wateringcan_15","pkg_wateringcan_20","pkg_wateringcan_30","pkg_wateringcan_50","pkg_wateringcan_75");
      
      private static const MYSTERY_SEEDLING_IMAGE_NAME:String = "construct_1";
      
      private static const WATERING_GROWTH_SCALE_MULTIPLIER:Number = 0.08;
      
      private static const STORAGE_CONTENT:String = "storageContent";
      
      private static const FULLY_BUILT:String = "fullyBuilt";
      
      private static const SEED_TYPE:String = "seedType";
      
      protected const ASK_FOR_WATER:String = "askForWater";
      
      protected const BUY_WATER:String = "buyWater";
      
      protected const COMPLETE_NOW:String = "completeNow";
      
      protected const ADD_ALL_WATERING_CANS:String = "add_all_watering_cans";
      
      private var m_seedType:String = "";
      
      private var m_highlightedForWatering:Boolean;
      
      public function MysterySeedling(buildingType:String = null)
      {
         FarmStatsManager.sample(100,"fv_fbml_depr_inspect","MysterySeedling","called");
         super(buildingType);
         m_surfacingKeyword = this.getItem().className;
      }
      
      public static function chooseInstanceToAddItemTo(buildingName:String, metadataArr:Array, partId:String) : String
      {
         var index:String = null;
         var remaining:int = 0;
         var instance:MysterySeedling = new MysterySeedling(buildingName);
         var highestWaterIndex:String = "";
         var highestWaterCount:int = instance.capacity;
         for(index in metadataArr)
         {
            if(highestWaterIndex == "")
            {
               highestWaterIndex = index;
            }
            instance.setMetadata(metadataArr[index]);
            remaining = instance.capacity - instance.count;
            if(remaining < highestWaterCount)
            {
               highestWaterCount = remaining;
               highestWaterIndex = index;
            }
         }
         return highestWaterIndex;
      }
      
      public static function createStoredFeatureInstance(buildingType:String = null, metadata:String = "") : MysterySeedling
      {
         var instance:MysterySeedling = new MysterySeedling(buildingType);
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
         if(data.hasOwnProperty(SEED_TYPE) && data.seedType != null && data.seedType != "")
         {
            this.m_seedType = data.seedType;
         }
      }
      
      override public function onBuildComplete(result:Object) : void
      {
         setState(STATE_CONSTRUCTION);
         var statsKingdom:String = this.getItem().name + "_" + StatsTrackingConstants.DIALOG_STATE_PLACE_KINGDOM;
         createRewardFeed(m_buildingName + "BeginBuilding",statsKingdom,result.rewardLink,this.getItem().getImageByName("startIcon",false),this.displayStorageDialog,null,null,null,null,"",null,"","",null,true);
      }
      
      override public function addItem(resource:MapResource, fromStorage:int = 0, isGift:Boolean = false, sendStoreItem:Boolean = true, force:Boolean = false) : Boolean
      {
         if(m_isStoredFeature)
         {
            sendStoreItem = false;
         }
         return Boolean(super.addItem(resource,fromStorage,isGift,sendStoreItem,force));
      }
      
      override protected function onHalfWayFinished(result:Object) : void
      {
         var statsKingdom:String = null;
         var halfDialogIcon:String = null;
         var dialogIcon:String = null;
         if(Global.player.inExperimentFeedCheckBoxV2())
         {
            statsKingdom = this.getItem().resourcePrefix + "_" + StatsTrackingConstants.DIALOG_STATE_HALFWAY_COMPLETE_KINGDOM;
            halfDialogIcon = getItem().getImageByName("halfDialogIcon",false);
            dialogIcon = halfDialogIcon != null ? Global.getAssetURL(halfDialogIcon) : this.getItem().icon;
            createRewardFeed(m_buildingName + "HalfBuilt",statsKingdom,result.rewardLink,getItem().getImageByName("halfIcon",false),null,dialogIcon,statCountConstructableHalfway,null,null,StatsTrackingConstants.DIALOG_STATE_HALFWAY_COMPLETE_KINGDOM,m_dialogName + "HalfBuilt","",FALLBACK_KEY + "HalfBuilt",{"subcategory":m_item.name},false,true,ZLocUtils.t("Dialogs","MysterySeedlingHalfway_checkboxText"));
         }
         else
         {
            super.onHalfWayFinished(result);
         }
      }
      
      override public function getOverlayUrl() : String
      {
         return MysterySeedling.OVERLAY_URL;
      }
      
      override protected function getOverlayOffset() : Vector2
      {
         return MysterySeedling.OVERLAY_OFFSET;
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
         m_menuItems.push({
            "label":ZLocUtils.t("FarmGame","AskForWater"),
            "action":this.ASK_FOR_WATER
         });
         m_menuItems.push({
            "label":ZLocUtils.t("FarmGame","BuyWater"),
            "action":this.BUY_WATER
         });
         m_menuItems.push({
            "label":ZLocUtils.t("Dialogs","CompleteNowCamel"),
            "action":this.COMPLETE_NOW
         });
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_TREE_HARVEST_ORCHARD_PROMO) > 1)
         {
            m_menuItems.push({
               "label":ZLocUtils.t("FarmGame","WaterSeedling"),
               "action":this.ADD_ALL_WATERING_CANS
            });
         }
         super.showMenu();
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            switch(item.action)
            {
               case this.ASK_FOR_WATER:
                  this.onAskForWater();
                  break;
               case this.BUY_WATER:
                  this.onBuyWater();
                  break;
               case this.COMPLETE_NOW:
                  this.onCompleteNow();
                  break;
               case this.ADD_ALL_WATERING_CANS:
                  onApplyMaxPossibleBuildingParts(WATERING_CAN,MINI_MARKET_ITEMS);
                  break;
               default:
                  super.onMenuClick(event);
            }
         }
      }
      
      private function onBuyWater() : void
      {
         UI.displayMiniMarketDialog(MINI_MARKET_ITEMS,"MysterySeedling","tree");
      }
      
      private function onAskForWater() : void
      {
         FarmStatsManager.sample(100,"fv_fbml_depr_inspect","r2FlowCalled","MysterySeedling");
         MFSRequestManager.getInstance().makeAskMatsRequest("mysteryseedling",WATERING_CAN,"mysteryseedling","",MFSConstants.SOURCE_CONTEXT_MENU);
      }
      
      override public function onCompleteNow() : void
      {
         UI.displayMessage(ZLocUtils.t("Dialogs","FinishConstructionBuildingPopup",{
            "cashQuantity":this.calculateCashNeeded(),
            "item":ZLocUtils.tk_pk(getItemFriendlyName())
         }),GenericPopup.TYPE_ACCEPTCANCEL,this.onAcceptCompleteNowPopup);
      }
      
      protected function calculateCashNeeded(partCost:int = 1) : int
      {
         return int(partCost * (getMaterialsNeeded() - m_count));
      }
      
      protected function onAcceptCompleteNowPopup(event:GenericPopupEvent) : void
      {
         var remainingWater:int = 0;
         var cashCost:int = 0;
         var buyResult:Boolean = false;
         var i:int = 0;
         var realXp:int = 0;
         if(event.button == GenericPopup.YES)
         {
            remainingWater = getMaterialsNeeded() - m_count;
            cashCost = this.calculateCashNeeded();
            if(Global.player.canBuyCash(cashCost))
            {
               buyResult = false;
               for(i = 0; i < remainingWater; i++)
               {
                  buyResult = Global.player.tryBuy(null,false,Global.farmGameSettingsManager.getFarmItemByName(WATERING_CAN),0);
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
         }
      }
      
      override protected function showStorageContextMenu() : Boolean
      {
         return false;
      }
      
      override public function displayStorageDialog(defaultAction:String = "") : void
      {
      }
      
      public function highlightForWatering(highlightOn:Boolean) : void
      {
         this.showHighlight(highlightOn,Constants.COLOR_HIGHLIGHT_BLUE);
         this.m_highlightedForWatering = highlightOn;
      }
      
      override public function onMouseOut() : void
      {
         super.onMouseOut();
         if(this.m_highlightedForWatering)
         {
            this.showHighlight(true,Constants.COLOR_HIGHLIGHT_BLUE);
         }
      }
      
      override public function getFinishedItem() : FarmItem
      {
         return Global.farmGameSettingsManager.getFarmItemByCode(this.m_seedType);
      }
      
      override public function onFullyFinished(result:Object, transformedObj:MapResource = null) : void
      {
         var feedIcon:String = null;
         var checkboxText:String = null;
         var dialogName:String = null;
         var fallbackKey:String = null;
         var fullyBuilt:String = "FullyBuilt";
         var sendToGiftBox:String = "SentToGiftBox";
         var statsKingdom:String = this.getItem().name + "_" + StatsTrackingConstants.DIALOG_STATE_EXPANSION_COMPLETE_KINGDOM;
         var feedActionName:String = m_buildingName + fullyBuilt;
         var finishedItem:FarmItem = getFinishedItemFromResult(result);
         if(finishedItem)
         {
            this.m_seedType = finishedItem.code;
            if(transformedObj != null)
            {
               dialogName = m_dialogName + fullyBuilt;
            }
            else
            {
               dialogName = m_dialogName + sendToGiftBox;
               fallbackKey = this.getItem().name + sendToGiftBox;
            }
            feedIcon = finishedItem.getImageByName("icon",false);
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FACEBOOK_FEED_ICONS) > 1)
            {
               feedIcon = getItem().getImageByName("feed",true);
            }
            if(Global.player.inExperimentFeedCheckBoxV2())
            {
               dialogName += "_v2";
               checkboxText = ZLocUtils.t("Dialogs","MysterySeedlingCompletion_checkboxText");
               createRewardFeed(feedActionName,statsKingdom,result.rewardLink,feedIcon,null,finishedItem.icon,statCountConstructableComplete,finishedItem.friendlyName,{"tree":ZLocUtils.tk_pk(finishedItem.friendlyName)},"",dialogName,finishedItem.name,fallbackKey,null,false,true,checkboxText);
            }
            else
            {
               createRewardFeed(feedActionName,statsKingdom,result.rewardLink,feedIcon,null,finishedItem.icon,statCountConstructableComplete,finishedItem.friendlyName,{"tree":ZLocUtils.tk_pk(finishedItem.friendlyName)},"",dialogName,finishedItem.name,fallbackKey);
            }
         }
      }
      
      override protected function onIncrementFinished(result:Object) : void
      {
      }
      
      override protected function getImageScaleFactor() : Number
      {
         var scaleFactor:int = 0;
         var result:Number = 1;
         if(m_usingLoadingGraphic)
         {
            result = LOADING_GRAPHIC_SCALE;
         }
         else
         {
            scaleFactor = this.count - this.capacity / 2;
            scaleFactor = scaleFactor < -4 ? -4 : scaleFactor;
            scaleFactor = scaleFactor > -4 ? 4 : scaleFactor;
            result += scaleFactor * WATERING_GROWTH_SCALE_MULTIPLIER;
         }
         return result;
      }
      
      override public function getCurrentImageName() : String
      {
         var imageName:String = MYSTERY_SEEDLING_IMAGE_NAME;
         if(m_arrow != null)
         {
            m_hideArrow = false;
         }
         return imageName;
      }
      
      override public function canTakeItem(item:MapResource, isMouseOver:Boolean = true) : Boolean
      {
         var wateringCan:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(WATERING_CAN);
         return item.getItem().className == wateringCan.className;
      }
      
      override public function isUnderItemLimit(resourceItem:FarmItem) : Boolean
      {
         var wateringCan:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(WATERING_CAN);
         return resourceItem.className == wateringCan.className;
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
            this.m_seedType = value as String;
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
         if(Boolean(metadata) && Boolean(metadata[SEED_TYPE]) && metadata[SEED_TYPE] != "")
         {
            this.m_seedType = metadata.seedType;
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
         metadata[SEED_TYPE] = this.m_seedType;
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

