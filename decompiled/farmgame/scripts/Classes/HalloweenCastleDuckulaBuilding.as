package Classes
{
   import AvatarMode.AMFeedAnimals;
   import Classes.Avatar.FarmAvatar;
   import Classes.Constants.MFSConstants;
   import Classes.FeatureDataObjects.BuildingExpansionData;
   import Classes.NeighborActions.HarvestHalloweenTicketsNeighborAction;
   import Classes.NeighborActions.NeighborActionConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import DataSources.BaseDataSource;
   import Display.ContextMenuItem;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.HalloweenCastleDuckulaWithdrawal;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import GameMode.GMBuild;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.MFSRequestManager;
   import Transactions.TCancelFriendReward;
   import Transactions.TCompleteNow;
   import flash.display.DisplayObjectContainer;
   import flash.display.Loader;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   
   public class HalloweenCastleDuckulaBuilding extends AnimalStorageBuilding
   {
      
      public static const EXPAND_IMAGE_ICON_URL_PREFIX:String = "assets/buildings/building_duckulascastle2011_finished_";
      
      public static const EXPAND_IMAGE_ICON_URL_SUFFIX:String = "_icon.png";
      
      public static const EXPAND_PART_IMAGE_ICON_PREFIX:String = "assets/newsfeed/task_";
      
      public static const MAX_LEVEL:Number = 6;
      
      protected var m_bundleData:Object = null;
      
      protected var m_feedAction:String = "";
      
      protected var m_rewardObj:Object;
      
      protected var m_data:Array = [];
      
      protected var m_creditsBuildingName:String = "";
      
      public function HalloweenCastleDuckulaBuilding(buildingType:String = null)
      {
         super(buildingType);
         this.updateMData();
      }
      
      public static function isPlaced() : Boolean
      {
         var buildingIndex:int = 0;
         var isPlaced:Boolean = false;
         var buildingList:Array = Global.world.getObjectsByClass(ConstructionBuilding);
         if(buildingList.length)
         {
            for(buildingIndex = 0; buildingIndex < buildingList.length; buildingIndex++)
            {
               if(buildingList[0].buildingName == "HalloweenCastleDuckula")
               {
                  isPlaced = true;
                  break;
               }
            }
         }
         return isPlaced;
      }
      
      private function updateMData() : void
      {
         var buildingExpansionData:BuildingExpansionData = null;
         var upgradeDataSource:BaseDataSource = null;
         var partDataArray:Array = null;
         var partDataSource:BaseDataSource = null;
         var partFarmItem:FarmItem = null;
         var partDataObject:Object = null;
         var upgradeData:XML = null;
         var partXml:XML = null;
         var partItem:FarmItem = null;
         var partData:Object = null;
         this.m_data = [];
         if(isDynamicPartsExperimentOn())
         {
            buildingExpansionData = this.getNextBuildingExpansionData();
            if(buildingExpansionData)
            {
               this.m_data = buildingExpansionData.generateWithdrawalUIData(this,false);
            }
         }
         else if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            upgradeDataSource = getNextExpansionDataSource();
            if(upgradeDataSource)
            {
               partDataArray = upgradeDataSource.getArray("part");
               if(partDataArray.length > 0)
               {
                  for each(partDataSource in partDataArray)
                  {
                     partFarmItem = Global.farmGameSettingsManager.getFarmItemByName(partDataSource.getString("name"));
                     if(partFarmItem)
                     {
                        partDataObject = {};
                        partDataObject.sendGiftsToFriends = false;
                        partDataObject.itemCode = partFarmItem.code;
                        partDataObject.name = partFarmItem.name;
                        partDataObject.needCount = partDataSource.getInt("need");
                        partDataObject.currentCount = getExpansionPartCount(partFarmItem.code);
                        partDataObject.friendlyName = partFarmItem.friendlyName;
                        partDataObject.icon = partFarmItem.icon;
                        partDataObject.cost = String(partFarmItem.cash);
                        this.m_data.push(partDataObject);
                     }
                  }
               }
            }
         }
         else
         {
            upgradeData = this.getNextExpansionData();
            if(Boolean(upgradeData) && Boolean(upgradeData.part))
            {
               for each(partXml in upgradeData.part)
               {
                  partItem = Global.farmGameSettingsManager.getFarmItemByName(partXml.@name);
                  if(partItem)
                  {
                     partData = new Object();
                     partData.sendGiftsToFriends = false;
                     partData.itemCode = partItem.code;
                     partData.name = partItem.name;
                     partData.needCount = parseInt(partXml.@need);
                     partData.currentCount = this.getExpansionPartCount(partItem.code);
                     partData.friendlyName = partItem.friendlyName;
                     partData.icon = partItem.icon;
                     partData.cost = String(partItem.cash);
                     this.m_data.push(partData);
                  }
               }
            }
         }
      }
      
      override public function hasReachedMaxExpansionLevel() : Boolean
      {
         return this.storageLevel == MAX_LEVEL;
      }
      
      override public function onFinishPlace(transactionResult:Object = null) : void
      {
         super.onFinishPlace(transactionResult);
         if(this.storageLevel == 0)
         {
            FarmStatsManager.count("constructable","place_structure","level0halloweencastle");
         }
      }
      
      override protected function onVisitClick() : void
      {
         if(this.canFeedOnVisit())
         {
            VisitorManager.getInstance().queueActionType(this,NeighborActionConstants.LIMIT_TYPE_HARVEST_HALLOWEEN_TICKETS);
            Global.selectedAvatar.getStateMachine().addState(new AMFeedAnimals(Global.selectedAvatar,this),true);
         }
      }
      
      override public function onHarvestComplete(result:Object) : void
      {
         var message:String = null;
         var m_congratsWindow:GenericPopup = null;
         super.onHarvestComplete(result);
         this.m_rewardObj = new Object();
         if(result.ticketYield != null)
         {
            if(result.data.rewardLink != null)
            {
               this.m_rewardObj.rewardUrl = result.data.rewardLink;
               message = ZLocUtils.t("Dialogs","HalloweenCastleDuckula_completeHarvestOwn",{
                  "quantity":result.ticketYield,
                  "wordticket":ZLocUtils.tk("Dialogs","HalloweenCastleDuckula_word_ticket","",this.storageLevel),
                  "item":ZLocUtils.tk_pk(this.getItemFriendlyName())
               });
               m_congratsWindow = new GenericPopup(message,GenericPopup.TYPE_SHARE,this.onShare);
               UI.displayPopup(m_congratsWindow,false);
            }
            Global.player.addGift(result.data.rewardItem,"0",int(result.ticketYield));
            this.tryForcePlacement(result.data.rewardItem);
         }
      }
      
      override public function addItem(resource:MapResource, fromStorage:int = 0, isGift:Boolean = false, sendStoreItem:Boolean = true, force:Boolean = false) : Boolean
      {
         var success:Boolean = super.addItem(resource,fromStorage,isGift,sendStoreItem,force);
         if(!isGift && this.storageLevel < MAX_LEVEL - 1)
         {
            this.displayStorageDialog();
         }
         return success;
      }
      
      override public function buildStatusMessage(messageData:Array) : String
      {
         if(messageData.length < 2)
         {
            return "";
         }
         return ZLocUtils.t("FarmGame","Status_AddPart",{
            "quantity":messageData[0],
            "item":ZLocUtils.tk_pk(messageData[1])
         });
      }
      
      protected function onShare(event:GenericPopupEvent) : void
      {
         var bundleData:Object = null;
         var feedStoryBundleID:String = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            bundleData = {
               "user":Global.player.firstName,
               "levelTitle":"Dialogs:HalloweenCastleDuckula_modifier_level_" + this.storageLevel.toString(),
               "reward_link":this.m_rewardObj.rewardUrl,
               "images":[{
                  "href":"{SN_APP_URL}" + this.m_rewardObj.rewardUrl,
                  "src":Global.getAssetURL("assets/decorations/deco_halloweenbasket2011_icon.png")
               }]
            };
            feedStoryBundleID = "HalloweenHarvestSelf2011";
            FarmStatsManager.count("feed","feed","Harvest_own_duckula_castle","level" + this.storageLevel.toString());
            GlobalEngine.socialNetwork.publishFeedStory(feedStoryBundleID,bundleData,[],false);
         }
         else
         {
            TransactionManager.addTransaction(new TCancelFriendReward([this.m_rewardObj.rewardUrl]));
         }
      }
      
      override public function getItemFriendlyName() : String
      {
         var friendlyName:String = "";
         if(m_item)
         {
            friendlyName = m_item.friendlyName;
         }
         return friendlyName;
      }
      
      override public function sell() : void
      {
         FarmStatsManager.count(this.getItem().name,"context_menu","sell");
         var dialog:GenericPopup = new GenericPopup(ZLocUtils.t("Dialogs","HalloweenCastleDuckula_Sell"),GenericPopup.TYPE_ACCEPTCANCEL,this.onSellHandler);
         UI.displayPopup(dialog);
      }
      
      private function onSellHandler(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            super.sell();
         }
      }
      
      override public function showMenu() : void
      {
         if(this.storageLevel != MAX_LEVEL)
         {
            m_menuItems.push({
               "label":"Complete Now",
               "action":"CompleteNow"
            });
            m_menuItems.push({
               "label":"Ask For Parts",
               "action":"AskForParts"
            });
         }
         super.showMenu();
      }
      
      override protected function canShowStoreMenuItem() : Boolean
      {
         if(Global.player.hasInventorySpace())
         {
            return true;
         }
         return false;
      }
      
      protected function onClickAcceptPopup(event:GenericPopupEvent) : void
      {
         var m_cashNeeded:int = 0;
         var partcost:int = 0;
         var index:int = 0;
         var buildingName:String = null;
         var data:Object = null;
         var buildingPart:BuildingPart = null;
         var parts:int = 0;
         if(event.button == GenericPopup.YES)
         {
            this.updateMData();
            FarmStatsManager.count("Constructable","ui_button_click","level" + this.storageLevel.toString() + "halloweencastle","complete_now");
            m_cashNeeded = 0;
            partcost = 1;
            for(index = 0; index < this.m_data.length; index++)
            {
               if(!this.m_data[index].sendGiftsToFriends)
               {
                  m_cashNeeded += (this.m_data[index].needCount - this.m_data[index].currentCount) * partcost;
               }
            }
            FarmStatsManager.count("fv_cash_buy","duckula_castle","duckula_castle_" + this.storageLevel.toString() + "_upgrade_complete",m_cashNeeded.toString());
            buildingName = this.getItemFriendlyName();
            if(m_cashNeeded > 0)
            {
               if(Global.player.canBuyCash(m_cashNeeded))
               {
                  for each(data in this.m_data)
                  {
                     if(data.sendGiftsToFriends == false)
                     {
                        if(data.currentCount < data.needCount)
                        {
                           buildingPart = new BuildingPart(data.name);
                           for(parts = int(data.currentCount); parts < data.needCount; parts++)
                           {
                              this.addItem(buildingPart,0,false,false);
                           }
                        }
                     }
                  }
                  FarmStatsManager.count("fv_cash_buy","complete_now",this.getItem().name + this.storageLevel.toString(),m_cashNeeded.toString());
                  TransactionManager.addTransaction(new TCompleteNow(this));
                  Global.player.cash -= m_cashNeeded;
               }
            }
         }
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         var m_cashNeeded:int = 0;
         var partcost:int = 0;
         var itemNum:Number = NaN;
         var index:int = 0;
         var data2:Object = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            switch(item.action)
            {
               case "CompleteNow":
                  this.updateMData();
                  FarmStatsManager.count("Constructable","ui_button_click","level" + this.storageLevel.toString() + "halloweencastle","complete_now");
                  m_cashNeeded = 0;
                  partcost = 1;
                  for(index = 0; index < this.m_data.length; index++)
                  {
                     if(!this.m_data[index].sendGiftsToFriends)
                     {
                        m_cashNeeded += (this.m_data[index].needCount - this.m_data[index].currentCount) * partcost;
                     }
                  }
                  UI.displayMessage(ZLocUtils.t("Dialogs","FinishConstructionBuildingPopup",{
                     "cashQuantity":m_cashNeeded,
                     "item":ZLocUtils.tk_pk(this.getItemFriendlyName())
                  }),GenericPopup.TYPE_ACCEPTCANCEL,this.onClickAcceptPopup,"",true);
                  break;
               case "AskForParts":
                  this.updateMData();
                  itemNum = 0;
                  for each(data2 in this.m_data)
                  {
                     if(data2.currentCount < data2.needCount)
                     {
                        break;
                     }
                     itemNum++;
                  }
                  MFSRequestManager.getInstance().makeAskMatsRequest(this.getItem().name,this.m_data[itemNum].name,this.getItem().name,"",MFSConstants.SOURCE_DIALOG_CLICKED,"Constructable","ui_button_click",this.getItem().name,"ask_for_more");
                  break;
               default:
                  super.onMenuClick(event);
            }
         }
      }
      
      public function getItemShortName() : String
      {
         var shortName:String = "";
         if(m_item)
         {
            shortName = m_item.friendlyName;
         }
         return shortName;
      }
      
      override public function displayStorageDialog(defaultAction:String = "") : void
      {
         UI.displayStorageDialog(new HalloweenCastleDuckulaWithdrawal(this,defaultAction));
      }
      
      override protected function sanitizeData(data:Object) : Object
      {
         if(data.usesAltGraphic)
         {
            data.usesAltGraphic = false;
         }
         return data;
      }
      
      override public function isHarvestable() : Boolean
      {
         var bool1:Boolean = super.isHarvestable();
         var bool2:Boolean = getItem().checkDateGate();
         var bool3:Boolean = getItem().isInExperiment;
         return bool1 && bool2 && bool3;
      }
      
      override public function canBeClickedOnVisit() : Boolean
      {
         return this.canFeedOnVisit();
      }
      
      override public function canUpdateCursorOnVisit() : Boolean
      {
         return this.canFeedOnVisit();
      }
      
      override protected function onCompleteExpansion(rewardLink:String, itemName:String) : void
      {
         this.reloadImage();
         var iconUrl:String = EXPAND_IMAGE_ICON_URL_PREFIX + this.storageLevel.toString() + EXPAND_IMAGE_ICON_URL_SUFFIX;
         this.m_feedAction = "HalloweenCastleDuckulaExpandComplete";
         var feedImage:String = Global.getAssetURL(iconUrl);
         this.m_bundleData = {
            "reward_link":rewardLink,
            "images":[{
               "href":"{SN_APP_URL}" + rewardLink,
               "src":feedImage
            }]
         };
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         var itemFriendlyName:String = farmItem.friendlyName;
         var message:String = ZLocUtils.t("Dialogs","HalloweenCastleDuckula_completeExpandComplete");
         var dialog:GenericIconPopup = new GenericIconPopup(message,GenericPopup.TYPE_SHARE,this.onShareExpansionReward,feedImage);
         dialog.setTrackerKey("feed-castleduckula-upgrade_complete");
         UI.displayPopup(dialog,false);
         FarmStatsManager.count("Constructable","constructible_state_change","level" + this.storageLevel.toString() + "halloweencastle","complete");
      }
      
      override protected function onCompleteHalfExpansion(rewardLink:String) : void
      {
         var iconUrl:String = EXPAND_IMAGE_ICON_URL_PREFIX + this.storageLevel.toString() + EXPAND_IMAGE_ICON_URL_SUFFIX;
         this.m_feedAction = "HalloweenCastleDuckulaExpandHalfComplete";
         var feedImage:String = Global.getAssetURL(iconUrl);
         this.m_bundleData = {
            "reward_link":rewardLink,
            "images":[{
               "href":"{SN_APP_URL}" + rewardLink,
               "src":feedImage
            }]
         };
         var message:String = ZLocUtils.t("Dialogs","HalloweenCastleDuckula_completeExpandHalfComplete");
         var dialog:GenericIconPopup = new GenericIconPopup(message,GenericPopup.TYPE_SHARE,this.onShareExpansionReward,feedImage);
         dialog.setTrackerKey("feed-castleduckula-upgrade_halfway");
         UI.displayPopup(dialog,false);
         FarmStatsManager.count("Constructable","constructible_state_change","level" + this.storageLevel.toString() + "halloweencastle","halfway");
      }
      
      override protected function onCompleteExpansionPart(rewardLink:String, itemName:String) : void
      {
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         var iconUrl:String = EXPAND_IMAGE_ICON_URL_PREFIX + this.storageLevel.toString() + EXPAND_IMAGE_ICON_URL_SUFFIX;
         this.m_feedAction = "HalloweenCastleDuckulaExpandCompletePart";
         var itemFriendlyName:String = farmItem.friendlyName;
         var feedImage:String = Global.getAssetURL(EXPAND_PART_IMAGE_ICON_PREFIX + itemName + ".png");
         var partImage:String = farmItem.iconUrl;
         var dialogImage:String = partImage;
         this.m_bundleData = {
            "item":itemFriendlyName,
            "reward_link":rewardLink,
            "images":[{
               "href":"{SN_APP_URL}" + rewardLink,
               "src":feedImage
            }]
         };
         var message:String = ZLocUtils.t("Dialogs","HalloweenCastleDuckula_completeExpandPartComplete",{"items":ZLocUtils.tk_pk(itemFriendlyName)});
         var dialog:GenericIconPopup = new GenericIconPopup(message,GenericPopup.TYPE_SHARE,this.onShareExpansionReward,dialogImage);
         dialog.setTrackerKey("feed-castleduckula-upgrade_material_complete");
         UI.displayPopup(dialog,false);
      }
      
      private function onShareExpansionReward(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            GlobalEngine.socialNetwork.publishFeedStory(this.m_feedAction,this.m_bundleData,[],false);
         }
         else
         {
            TransactionManager.addTransaction(new TCancelFriendReward([this.m_bundleData["reward_link"]]));
         }
      }
      
      override public function feedAnimals() : void
      {
         m_animalsFed = true;
         VisitorManager.getInstance().doAction(new HarvestHalloweenTicketsNeighborAction(this));
      }
      
      override public function getHarvestAmount() : int
      {
         var total:Number = 0;
         switch(this.m_storageLevel)
         {
            case 1:
            case 2:
               total = 1;
               break;
            case 3:
            case 4:
               total = 2;
               break;
            case 5:
               total = 3;
               break;
            case 6:
               total = 4;
         }
         return total;
      }
      
      override public function doHarvestDropOff(avatar:FarmAvatar, showStatus:Boolean = true) : Object
      {
         var result:Object = new Object();
         if(showStatus)
         {
            avatar.displayStatus(ZLocUtils.t("FarmGame","Status_HarvestHalloweenTickets",{"quantity":this.getHarvestAmount()}));
         }
         m_isInHarvestQueue = false;
         return result;
      }
      
      override public function loadObject(data:Object) : void
      {
         var upgradeDataSource:BaseDataSource = null;
         var upgradeData:XML = null;
         var code:String = null;
         super.loadObject(data);
         if(data.paintColor)
         {
            m_paintColor = data.paintColor;
         }
         this.setState(STATE_BARE);
         if(data.hasOwnProperty("isFullyBuilt"))
         {
            m_isFullyBuilt = data.isFullyBuilt;
            if(!m_isFullyBuilt)
            {
               this.setState(STATE_CONSTRUCTION);
            }
         }
         if(data.expansionLevel > 1)
         {
            m_storageLevel = data.expansionLevel;
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               upgradeDataSource = getItem().getUpgradeDataSource(m_storageLevel);
               if(upgradeDataSource)
               {
                  m_capacity = upgradeDataSource.getInt("capacity");
               }
            }
            else
            {
               upgradeData = getItem().getUpgradeData(m_storageLevel);
               if(upgradeData)
               {
                  m_capacity = upgradeData.@capacity;
               }
            }
         }
         if(data.expansionParts)
         {
            for(code in data.expansionParts)
            {
               m_expansionParts[code] = data.expansionParts[code];
            }
         }
      }
      
      override public function setState(value:String) : void
      {
         if(value == STATE_BUILT)
         {
            value = STATE_BARE;
         }
         super.setState(value);
      }
      
      override public function canFeedOnVisit() : Boolean
      {
         var m_variant:Number = Global.experimentManager.getExperimentVariant("fv_halloweenbasket2011");
         return !this.m_animalsFed && VisitorManager.getInstance().canPerformAction(this,NeighborActionConstants.ACTION_TYPE_HARVEST_HALLOWEEN_TICKETS) && getItem().checkDateGate() && getItem().isInExperiment && m_variant == 1;
      }
      
      override protected function updateToolTipText() : void
      {
         var capacityText:String = null;
         var growPercentage:int = 0;
         var growPercentage2:int = 0;
         var toolTip:String = null;
         if(isHighlighted() && Global.worldManager.isVisiting() == false && this.isHarvestable() == true)
         {
            capacityText = "";
            if(!isFullyBuilt())
            {
               capacityText = ZLocUtils.t("Items",m_item.name + "_mats",{
                  "quantity":m_count,
                  "maximum":capacity
               });
            }
            switch(state)
            {
               case STATE_RIPE:
                  toolTip = ZLocUtils.t("FarmGame","AnimalBuilding_ready",{
                     "item":ZLocUtils.tk_pk(this.getItemFriendlyName()),
                     "capacityStr":capacityText
                  });
                  break;
               case STATE_BARE:
                  growPercentage = getGrowPercentage();
                  toolTip = ZLocUtils.t("FarmGame","AnimalBuilding_toolTip",{
                     "item":ZLocUtils.tk_pk(this.getItemFriendlyName()),
                     "quantity":growPercentage,
                     "capacityStr":capacityText
                  });
                  break;
               case STATE_CONSTRUCTION:
               case STATE_BUILT:
                  toolTip = ZLocUtils.t("FarmGame","AnimalBuilding_capacity",{
                     "item":ZLocUtils.tk_pk(this.getItemFriendlyName()),
                     "capacityStr":capacityText
                  });
                  break;
               default:
                  toolTip = ZLocUtils.tk_pk_asTitle(this.getItemFriendlyName());
            }
         }
         else if(isHighlighted() && Global.worldManager.isVisiting() == true || this.isHarvestable() == false)
         {
            toolTip = ZLocUtils.t("Dialogs","HalloweenCastleDuckula_modifier_level_" + this.storageLevel.toString(),{}) + " " + ZLocUtils.tk_pk_asTitle(this.getItemFriendlyName());
            if(getItem().checkDateGate())
            {
               growPercentage2 = getGrowPercentage();
               toolTip += ZLocUtils.t("Dialogs","HalloweenCastleDuckulaPercentReady",{"quantity":growPercentage2});
            }
         }
         setToolTip(toolTip);
         updateToolTipPosition();
      }
      
      override public function getActionText() : String
      {
         return ZLocUtils.t("FarmGame","Harvesting");
      }
      
      override public function conditionallyAttachFedOverlay() : void
      {
         var parent:DisplayObjectContainer = null;
         if(!Global.worldManager.isVisiting() && m_friendFedAnimalBuildingCount > 0)
         {
            if(!m_fedOverlayRequested && m_fedOverlay == null)
            {
               m_fedOverlayLoader.getContent(onFedOverlayLoad);
               m_fedOverlayRequested = true;
            }
            else if(m_fedOverlay != null && (this.m_displayObject as Sprite).numChildren > 0)
            {
               (this.m_displayObject as Sprite).addChild(m_fedOverlay);
               m_fedOverlay.scaleX = 2;
               m_fedOverlay.scaleY = 2;
            }
         }
         else if(m_fedOverlay != null && m_fedOverlay.parent != null)
         {
            parent = m_fedOverlay.parent;
            if(!(parent is Loader))
            {
               parent.removeChild(m_fedOverlay);
               m_fedOverlay = null;
            }
         }
      }
      
      override public function getCurrentSuffix() : int
      {
         var result:int = 0;
         var numImageStates:int = m_numImageStates;
         var capacity:int = m_capacity;
         if(!m_isFullyBuilt)
         {
            numImageStates = m_numConstructImageStates;
            capacity = getMaterialsNeeded();
            if(m_count < capacity)
            {
               numImageStates++;
            }
         }
         if(numImageStates > 1)
         {
            if(m_storageLevel)
            {
               result = m_storageLevel - 1;
            }
         }
         return result;
      }
      
      protected function tryForcePlacement(harvestGift:String) : void
      {
         var worldObjects:Array = null;
         var popup:GenericIconPopup = null;
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(harvestGift);
         var buildingItem:FarmItem = null;
         var message:String = "";
         if(Boolean(farmItem) && Boolean(farmItem.basket))
         {
            buildingItem = Global.farmGameSettingsManager.getFarmItemByName(farmItem.basket);
            if(Boolean(buildingItem) && buildingItem.isInExperiment)
            {
               this.m_creditsBuildingName = buildingItem.name;
               worldObjects = Global.world.getObjectsByName(buildingItem.name);
               if(worldObjects.length == 0)
               {
                  if(ZLocUtils.hasString(buildingItem.name,"CreditsNoBuilding_placeNow"))
                  {
                     message = ZLocUtils.t(buildingItem.name,"CreditsNoBuilding_placeNow",{"item":ZLocUtils.tk_pk_asTitle(buildingItem.friendlyName)});
                  }
                  else
                  {
                     message = ZLocUtils.t("Dialogs","CreditsNoBuilding_placeNow",{"item":ZLocUtils.tk_pk_asTitle(buildingItem.friendlyName)});
                  }
                  popup = new GenericIconPopup(message,GenericPopup.TYPE_OK,this.onEnterForcedPlacement,buildingItem.icon,false,false);
                  popup.setAcceptTextName("GenericPlaceButton");
                  UI.displayPopup(popup);
               }
            }
         }
      }
      
      private function onEnterForcedPlacement(event:GenericPopupEvent) : void
      {
         var hasGift:Boolean = false;
         if(this.m_creditsBuildingName != "")
         {
            hasGift = Global.player.getGiftCountForItem(this.m_creditsBuildingName) > 0;
            Global.world.addGameMode(new GMBuild(this.m_creditsBuildingName,hasGift,0,true,null));
            UI.closeGifts();
         }
      }
   }
}

