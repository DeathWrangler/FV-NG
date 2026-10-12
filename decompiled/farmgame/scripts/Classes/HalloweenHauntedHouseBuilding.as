package Classes
{
   import AvatarMode.AMFeedAnimals;
   import Classes.Avatar.FarmAvatar;
   import Classes.NeighborActions.HarvestHalloweenCandyNeighborAction;
   import Classes.NeighborActions.NeighborActionConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import DataSources.BaseDataSource;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.HalloweenHauntedHouseWithdrawal;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmGameSettingsManager;
   import Transactions.TCancelFriendReward;
   import flash.display.DisplayObjectContainer;
   import flash.display.Loader;
   import flash.display.Sprite;
   
   public class HalloweenHauntedHouseBuilding extends AnimalStorageBuilding
   {
      
      public static const EXPAND_IMAGE_ICON_URL_PREFIX:String = "assets/buildings/building_hauntedhouse2010_";
      
      public static const EXPAND_IMAGE_ICON_URL_SUFFIX:String = "_icon.png";
      
      public static const EXPAND_PART_IMAGE_ICON_PREFIX:String = "assets/newsfeed/hauntedhouse2010_";
      
      protected var m_bundleData:Object = null;
      
      protected var m_feedAction:String = "";
      
      protected var m_rewardObj:Object;
      
      public function HalloweenHauntedHouseBuilding(buildingType:String = null)
      {
         super(buildingType);
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
               if(buildingList[0].buildingName == "HalloweenHauntedHouse")
               {
                  isPlaced = true;
                  break;
               }
            }
         }
         return isPlaced;
      }
      
      override protected function onVisitClick() : void
      {
         if(this.canFeedOnVisit())
         {
            VisitorManager.getInstance().queueActionType(this,NeighborActionConstants.LIMIT_TYPE_HARVEST_HALLOWEEN_CANDY);
            Global.selectedAvatar.getStateMachine().addState(new AMFeedAnimals(Global.selectedAvatar,this),true);
         }
      }
      
      override public function onHarvestComplete(result:Object) : void
      {
         var message:String = null;
         var m_congratsWindow:GenericPopup = null;
         super.onHarvestComplete(result);
         this.m_rewardObj = new Object();
         if(result.candyYield != null)
         {
            this.m_rewardObj.levelNum = result.candyYield;
            if(result.data.rewardLink != null)
            {
               this.m_rewardObj.rewardUrl = result.data.rewardLink;
               message = ZLocUtils.t("Dialogs","HalloweenHauntedHouse_completeHarvestOwn",{
                  "quantity":this.storageLevel,
                  "wordcandy":ZLocUtils.tk("Dialogs","HalloweenHauntedHouse_word_candy","",this.storageLevel),
                  "item":ZLocUtils.tk_pk(this.getItemFriendlyName())
               });
               m_congratsWindow = new GenericPopup(message,GenericPopup.TYPE_SHARE,this.onShare);
               UI.displayPopup(m_congratsWindow,false);
            }
            Global.player.addGift(result.data.rewardItem,"0",int(result.candyYield));
         }
      }
      
      protected function onShare(event:GenericPopupEvent) : void
      {
         var bundleData:Object = null;
         var feedStoryBundleID:String = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            bundleData = {
               "user":Global.player.firstName,
               "levelTitle":"Dialogs:HalloweenHauntedHouse_modifier_level_" + this.storageLevel.toString(),
               "reward_link":this.m_rewardObj.rewardUrl,
               "images":[{
                  "href":"{SN_APP_URL}" + this.m_rewardObj.rewardUrl,
                  "src":Global.getAssetURL("assets/decorations/deco_halloweencandy_icon.png")
               }]
            };
            feedStoryBundleID = "HalloweenHarvestSelf";
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
            friendlyName = ZLocUtils.t("Dialogs","HalloweenHauntedHouse_modifier_level_" + this.storageLevel.toString(),{"item":ZLocUtils.tk_pk(m_item.friendlyName)});
         }
         return friendlyName;
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
         UI.displayStorageDialog(new HalloweenHauntedHouseWithdrawal(this));
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
         this.m_feedAction = "HalloweenHauntedHouseExpandComplete";
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
         var message:String = ZLocUtils.t("Dialogs","HalloweenHauntedHouse_completeExpandComplete");
         var dialog:GenericIconPopup = new GenericIconPopup(message,GenericPopup.TYPE_SHARE,this.onShareExpansionReward,feedImage);
         dialog.setTrackerKey("feed-hauntedhouse-upgrade_complete");
         UI.displayPopup(dialog,false);
      }
      
      override protected function onCompleteHalfExpansion(rewardLink:String) : void
      {
         var iconUrl:String = EXPAND_IMAGE_ICON_URL_PREFIX + this.storageLevel.toString() + EXPAND_IMAGE_ICON_URL_SUFFIX;
         this.m_feedAction = "HalloweenHauntedHouseExpandHalfComplete";
         var feedImage:String = Global.getAssetURL(iconUrl);
         this.m_bundleData = {
            "reward_link":rewardLink,
            "images":[{
               "href":"{SN_APP_URL}" + rewardLink,
               "src":feedImage
            }]
         };
         var message:String = ZLocUtils.t("Dialogs","HalloweenHauntedHouse_completeExpandHalfComplete");
         var dialog:GenericIconPopup = new GenericIconPopup(message,GenericPopup.TYPE_SHARE,this.onShareExpansionReward,feedImage);
         dialog.setTrackerKey("feed-hauntedhouse-upgrade_halfway");
         UI.displayPopup(dialog,false);
      }
      
      override protected function onCompleteExpansionPart(rewardLink:String, itemName:String) : void
      {
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         var iconUrl:String = EXPAND_IMAGE_ICON_URL_PREFIX + this.storageLevel.toString() + EXPAND_IMAGE_ICON_URL_SUFFIX;
         this.m_feedAction = "HalloweenHauntedHouseExpandCompletePart";
         var itemFriendlyName:String = farmItem.friendlyName;
         var feedImage:String = Global.getAssetURL(EXPAND_PART_IMAGE_ICON_PREFIX + itemName + ".png");
         var partImage:String = farmItem.iconUrl;
         var dialogImage:String = Global.getAssetURL(partImage);
         this.m_bundleData = {
            "item":itemFriendlyName,
            "reward_link":rewardLink,
            "images":[{
               "href":"{SN_APP_URL}" + rewardLink,
               "src":feedImage
            }]
         };
         var message:String = ZLocUtils.t("Dialogs","HalloweenHauntedHouse_completeExpandPartComplete",{"items":ZLocUtils.tk_pk(itemFriendlyName)});
         var dialog:GenericIconPopup = new GenericIconPopup(message,GenericPopup.TYPE_SHARE,this.onShareExpansionReward,dialogImage);
         dialog.setTrackerKey("feed-hauntedhouse-upgrade_material_complete");
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
         VisitorManager.getInstance().doAction(new HarvestHalloweenCandyNeighborAction(this));
      }
      
      override public function getHarvestAmount() : int
      {
         return this.m_storageLevel;
      }
      
      override public function doHarvestDropOff(avatar:FarmAvatar, showStatus:Boolean = true) : Object
      {
         var result:Object = new Object();
         result.coinYield = this.getHarvestAmount();
         if(showStatus)
         {
            avatar.displayStatus(ZLocUtils.t("FarmGame","Status_HarvestHalloweenCandy",{"coinNum":result.coinYield}));
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
         return !this.m_animalsFed && VisitorManager.getInstance().canPerformAction(this,NeighborActionConstants.ACTION_TYPE_HARVEST_HALLOWEEN_CANDY) && getItem().checkDateGate() && getItem().isInExperiment;
      }
      
      override protected function updateToolTipText() : void
      {
         var capacityText:String = null;
         var growPercentage:int = 0;
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
            toolTip = ZLocUtils.tk_pk_asTitle(this.getItemFriendlyName());
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
   }
}

