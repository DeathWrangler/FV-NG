package Classes
{
   import Classes.Constants.Experiments;
   import Classes.Constants.WorldsConstants;
   import Classes.FeatureComponents.IExpandComponent;
   import Classes.FeatureDataObjects.BuildingExpansionData;
   import Classes.FeatureDataObjects.FeatureExpansionState;
   import Classes.ZItem.FarmItem;
   import Classes.crafting.CraftingStatsManager;
   import Classes.storage.PartItem;
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Display.CraftingUI;
   import Display.GenericPopup;
   import Display.TutorialUI;
   import Display.UI;
   import Events.GenericPopupEvent;
   import GameMode.GMBuild;
   import Managers.Crafting.CraftingConstants;
   import Managers.Crafting.CraftingManager;
   import Managers.ExpansionFeedManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsManager;
   import Transactions.TCompleteNow;
   import Widgets.Windows.ArrowIndicatorWindow;
   import Widgets.Windows.CraftingArrowIndicatorWindow;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.xml.XMLNode;
   import flash.xml.XMLNodeType;
   
   public class MarketStallBuilding extends StorageBuilding
   {
      
      public static var m_rewardNotificationIds:Array;
      
      private static var m_expand:FeatureExpansionState = null;
      
      protected static const ACTION_MANAGE_STALL:String = "MANAGE_STALL";
      
      protected static const TUTORIAL_SEEN_FLAG:String = "CrForcedTutorial";
      
      public static const SHOW_EXPAND_TAB:String = "Expand";
      
      private static const EXPANSION_STARTED_FEEDIMAGE:String = "assets/newsfeed/marketstall_expansion_01.png";
      
      private static const EXPANSION_PROGRESS_FEEDIMAGE:String = "assets/newsfeed/marketstall_expansion_02.png";
      
      private static const EXPANSION_HALFWAY_FEEDIMAGE:String = "assets/newsfeed/marketstall_expansion_03.png";
      
      private static const EXPANSION_COMPLETE_FEEDIMAGE:String = "assets/newsfeed/marketstall_expansion_complete.png";
      
      private static const EXPANSION_AWNING_FEEDIMAGE:String = "assets/newsfeed/marketstall_awning_icon.png";
      
      private static const EXPANSION_BASKET_FEEDIMAGE:String = "assets/newsfeed/marketstall_basket_icon.png";
      
      private static const EXPANSION_PRICECARD_FEEDIMAGE:String = "assets/newsfeed/marketstall_pricesign_icon.png";
      
      private var m_BushelItemCode:String = null;
      
      private var m_ServerTimeClosed:Number = 0;
      
      private var m_IsConfigured:Boolean = false;
      
      private var m_RenderedAsOpen:Boolean = false;
      
      private var m_expandCompleteCallback:Function = null;
      
      private var m_expandCancelCallback:Function = null;
      
      public function MarketStallBuilding(buildingType:String = null)
      {
         super(buildingType);
         this.m_hideArrow = true;
         this.m_arrowArt = GOLD_ARROW;
         if(!m_expand)
         {
            m_expand = new FeatureExpansionState(FeatureOptionsManager.FEATURE_MARKET_STALL);
            m_expand.initialize(this.frictionlessExpand,this.beginCompleteExpansionFlow);
         }
         m_originalItemName = buildingType;
      }
      
      public static function maxExpansionLevel() : int
      {
         return m_expand.maxExpansionLevel();
      }
      
      protected function onAcceptCompleteExpansionFlowCallback(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            this.frictionlessExpand();
            if(this.m_expandCompleteCallback != null)
            {
               this.m_expandCompleteCallback();
               this.m_expandCompleteCallback = null;
            }
         }
         else if(this.m_expandCancelCallback != null)
         {
            this.m_expandCancelCallback();
            this.m_expandCancelCallback = null;
         }
      }
      
      public function beginCompleteExpansionFlow(source:int = 0, expandCompleteCallback:Function = null, expandCancelCallback:Function = null) : void
      {
         var buildingName:String = null;
         var expansionCashNeeded:Number = this.getExpandCashNeeded();
         if(expansionCashNeeded > 0)
         {
            this.m_expandCompleteCallback = expandCompleteCallback;
            this.m_expandCancelCallback = expandCancelCallback;
            FarmStatsManager.count("dialog","marketstall_full_expand","view","generic_expand");
            buildingName = getItemFriendlyName();
            if(ZLocUtils.hasString("Dialogs","ExpandConstructionBuildingPopup" + "_" + getItemName()))
            {
               UI.displayMessage(ZLocUtils.t("Dialogs","ExpandConstructionBuildingPopup" + "_" + getItemName(),{
                  "cashQuantity":expansionCashNeeded,
                  "item":ZLocUtils.tk_pk(buildingName)
               }),GenericPopup.TYPE_ACCEPTCANCEL,this.onAcceptCompleteExpansionFlowCallback,"",true);
            }
            else
            {
               UI.displayMessage(ZLocUtils.t("Dialogs","ExpandConstructionBuildingPopup",{
                  "cashQuantity":expansionCashNeeded,
                  "item":ZLocUtils.tk_pk(buildingName)
               }),GenericPopup.TYPE_ACCEPTCANCEL,this.onAcceptCompleteExpansionFlowCallback,"",true);
            }
         }
      }
      
      override public function loadObject(data:Object) : void
      {
         super.loadObject(data);
         this.bushelItemCode = data.currentBushelItemCode;
         this.serverTimeClosed = data.dateClosed;
         this.isConfigured = data.isConfigured;
         var currentGMs:Array = Global.world.getActiveGameModes();
         this.m_hideArrow = Global.worldManager.isVisiting() || !CraftingManager.getInstance().hasPendingMarketReward() || CraftingManager.getInstance().hasSeenRewardsPopup || currentGMs[0] is GMBuild;
      }
      
      public function get serverTimeClosed() : Number
      {
         return this.m_ServerTimeClosed;
      }
      
      public function set serverTimeClosed(newServerTimeClosed:Number) : void
      {
         this.m_ServerTimeClosed = newServerTimeClosed;
      }
      
      public function set bushelItemCode(newBushelItemCode:String) : void
      {
         this.m_BushelItemCode = newBushelItemCode;
      }
      
      public function get bushelItemCode() : String
      {
         return this.m_BushelItemCode;
      }
      
      public function get bushelItem() : FarmItem
      {
         return Global.farmGameSettingsManager.getFarmItemByCode(this.m_BushelItemCode);
      }
      
      public function set isConfigured(newConfigured:Boolean) : void
      {
         this.m_IsConfigured = newConfigured;
      }
      
      public function get secondsTillClosed() : Number
      {
         var serverTime:Number = Math.floor(GlobalEngine.serverTime / 1000);
         if(this.serverTimeClosed > serverTime)
         {
            return this.serverTimeClosed - serverTime;
         }
         return 0;
      }
      
      public function get isConfigured() : Boolean
      {
         return this.m_IsConfigured;
      }
      
      public function closeStall() : void
      {
         this.m_ServerTimeClosed = 0;
         this.m_BushelItemCode = null;
         this.m_IsConfigured = false;
         this.reloadImage();
         this.hideArrowDisplay();
      }
      
      override public function showMenu() : void
      {
         if(Global.worldManager.isWorldSwapStable)
         {
            if(CraftingManager.getInstance().hasPendingMarketReward() && !CraftingManager.getInstance().hasSeenRewardsPopup)
            {
               CraftingManager.getInstance().beginForceRewardsFlow(this);
            }
            else
            {
               m_menuItems.push({
                  "label":ZLocUtils.t("Crafting","MarketStall_ActionManageStall"),
                  "action":ACTION_MANAGE_STALL
               });
               if(this.readyToExpand())
               {
                  m_menuItems.push({
                     "label":ZLocUtils.t("Dialogs","ExpandNow"),
                     "action":"FrictionExpand"
                  });
               }
               super.showMenu();
            }
         }
      }
      
      override public function hasReachedMaxExpansionLevel() : Boolean
      {
         return m_expand.hasReachedMaxExpansionLevel();
      }
      
      public function readyToExpand() : Boolean
      {
         return !this.hasReachedMaxExpansionLevel();
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         if(Global.worldManager.isWorldSwapStable)
         {
            if(event.target is ContextMenuItem)
            {
               item = event.target as ContextMenuItem;
               switch(item.action)
               {
                  case ACTION_MANAGE_STALL:
                     this.displayStorageDialog();
                     CraftingStatsManager.recordMarketStallContextMenuClick();
                     break;
                  case SELL_OBJECT:
                     if(!this.isSellable())
                     {
                        UI.displayPopup(new GenericPopup(ZLocUtils.t("Crafting","General_SellMarketStallFailure")));
                     }
                     else
                     {
                        super.onMenuClick(event);
                     }
                     break;
                  case "FrictionExpand":
                     this.beginCompleteExpansionFlow();
                     break;
                  default:
                     super.onMenuClick(event);
               }
            }
         }
      }
      
      override public function displayStorageDialog(defaultAction:String = "") : void
      {
         if(defaultAction == SHOW_EXPAND_TAB)
         {
            CraftingUI.displayMarketStallWindow(this,false,null,true);
         }
         else
         {
            CraftingUI.displayMarketStallWindow(this);
         }
      }
      
      public function htmlEscape(str:String) : String
      {
         return XML(new XMLNode(XMLNodeType.TEXT_NODE,str)).toXMLString();
      }
      
      override protected function onVisitClick() : void
      {
         if(Global.player.level >= CraftingConstants.CRAFTING_UNLOCK_LEVEL && (Global.player.craftingState.inventoryState.placedMarketStallCount >= 1 || Global.player.craftingState.inventoryState.placedCraftingCottageCount >= 1) && !Global.worldManager.isVisitingCommunityNeighbor())
         {
            CraftingUI.displayVisitingMarketStallWindow(Global.worldManager.getVisiting(),"bushels");
         }
      }
      
      override public function canBeClickedOnVisit() : Boolean
      {
         return true;
      }
      
      override public function isInventoryBuilding() : Boolean
      {
         return false;
      }
      
      override protected function updateToolTipText() : void
      {
         var toolTip:String = null;
         if(Global.worldManager.isWorldSwapStable)
         {
            if(isHighlighted())
            {
               if(this.bushelItemCode != null && this.secondsTillClosed > 0)
               {
                  toolTip = ZLocUtils.t("Crafting","MarketStallMouseOver_HasContents",{"item":ZLocUtils.tk_pk(this.bushelItem.friendlyName)});
               }
               else
               {
                  toolTip = ZLocUtils.t("Crafting","MarketStallMouseOver_Empty");
               }
            }
         }
         else
         {
            toolTip = ZLocUtils.t("FarmGame","LoadingFarm");
         }
         setToolTip(toolTip);
         updateToolTipPosition();
      }
      
      override public function onUpdate(delta:Number) : void
      {
         super.onUpdate(delta);
         var currentGMs:Array = Global.world.getActiveGameModes();
         this.m_hideArrow = Global.worldManager.isVisiting() || !CraftingManager.getInstance().hasPendingMarketReward() || CraftingManager.getInstance().hasSeenRewardsPopup || currentGMs[0] is GMBuild;
         if(this.m_RenderedAsOpen && this.secondsTillClosed <= 0)
         {
            this.reloadImage();
         }
      }
      
      override public function getCurrentImageName() : String
      {
         var currentWorldType:String = null;
         var imageName:String = null;
         if(this.bushelItemCode != null && this.secondsTillClosed > 0)
         {
            imageName = "built_" + this.bushelItemCode;
            this.m_RenderedAsOpen = true;
         }
         else
         {
            currentWorldType = Global.worldManager.currentWorldType;
            if(Boolean(currentWorldType) && currentWorldType != WorldsConstants.WORLD_ID_HOME)
            {
               imageName = "empty_" + currentWorldType;
               this.m_RenderedAsOpen = false;
            }
            else
            {
               imageName = "empty";
               this.m_RenderedAsOpen = false;
            }
         }
         if(m_arrow == null)
         {
            m_arrow = this.createArrowIndicator();
         }
         return imageName;
      }
      
      override public function onMouseOver(event:MouseEvent) : void
      {
         super.onMouseOver(event);
         this.updateArrowIndicator();
      }
      
      override public function onMouseOut() : void
      {
         super.onMouseOut();
         this.updateArrowIndicator();
      }
      
      private function updateArrowIndicator() : void
      {
         var arrowIndicatorWindow:ArrowIndicatorWindow = null;
         if(Global.selectedAvatar)
         {
            arrowIndicatorWindow = m_arrow as ArrowIndicatorWindow;
            if(arrowIndicatorWindow)
            {
               arrowIndicatorWindow.showRolloverText(isHighlighted());
            }
         }
      }
      
      override public function showArrowDisplay() : void
      {
         this.m_hideArrow = false;
         if(m_arrow == null)
         {
            m_arrow = this.createArrowIndicator();
         }
         if(m_arrow)
         {
            m_arrow.visible = true;
            (m_displayObject as Sprite).addChild(m_arrow);
            this.setArrowPosition();
         }
      }
      
      private function createArrowIndicator() : DisplayObject
      {
         var failMessage:String = null;
         var i:int = 0;
         var friendData:Friend = null;
         var messagePrefered:String = null;
         var messagePrefered2:String = null;
         var alternativeStrings:Array = null;
         var arrowIndicator:DisplayObject = null;
         var pendingRewards:Array = Global.player.craftingState.pendingRewards;
         var usedArrows:int = m_rewardNotificationIds ? int(m_rewardNotificationIds.length) : 0;
         if(pendingRewards.length > usedArrows)
         {
            failMessage = ZLocUtils.t("Crafting","MarketStallArrowIndicator_Message_FailbookCase",{
               "quantity":pendingRewards.length,
               "friendword":ZLocUtils.tk("Achievements","helpfriends_word","",pendingRewards.length)
            });
            i = 0;
            while(i < pendingRewards.length && arrowIndicator == null)
            {
               if(!(Boolean(m_rewardNotificationIds) && m_rewardNotificationIds.indexOf(pendingRewards[i].visitorUid) != -1))
               {
                  friendData = Global.friendManager.getFriendData(pendingRewards[i].visitorUid);
                  if(Boolean(arrowIndicator == null && friendData) && Boolean(friendData.name) && Boolean(friendData.picture))
                  {
                     if(!m_rewardNotificationIds)
                     {
                        m_rewardNotificationIds = new Array();
                     }
                     m_rewardNotificationIds.push(pendingRewards[i].visitorUid);
                     alternativeStrings = new Array();
                     if(pendingRewards.length > 1)
                     {
                        messagePrefered = ZLocUtils.t("Crafting","MarketStallArrowIndicator_Message_Multiple",{
                           "user":ZLocUtils.tn(friendData.name,ZLocUtils.tg(friendData.snUser.gender)),
                           "quantity":pendingRewards.length - 1,
                           "friendword":ZLocUtils.tk("Achievements","helpfriends_word","",pendingRewards.length - 1)
                        });
                        if(friendData.firstName)
                        {
                           messagePrefered2 = ZLocUtils.t("Crafting","MarketStallArrowIndicator_Message_Multiple",{
                              "user":ZLocUtils.tn(friendData.firstName,ZLocUtils.tg(friendData.snUser.gender)),
                              "quantity":pendingRewards.length - 1,
                              "friendword":ZLocUtils.tk("Achievements","helpfriends_word","",pendingRewards.length - 1)
                           });
                           alternativeStrings.push(messagePrefered2);
                        }
                     }
                     else
                     {
                        messagePrefered = ZLocUtils.t("Crafting","MarketStallArrowIndicator_Message_Single",{"user":ZLocUtils.tn(friendData.name,ZLocUtils.tg(friendData.snUser.gender))});
                        if(friendData.firstName)
                        {
                           messagePrefered2 = ZLocUtils.t("Crafting","MarketStallArrowIndicator_Message_Single",{"user":ZLocUtils.tn(friendData.firstName,ZLocUtils.tg(friendData.snUser.gender))});
                           alternativeStrings.push(messagePrefered2);
                        }
                     }
                     alternativeStrings.push(failMessage);
                     arrowIndicator = new CraftingArrowIndicatorWindow(friendData.picture,messagePrefered,String(pendingRewards.length),false,false,alternativeStrings);
                  }
                  else if(arrowIndicator)
                  {
                     break;
                  }
               }
               i++;
            }
            if(arrowIndicator == null)
            {
               failMessage = ZLocUtils.t("Crafting","MarketStallArrowIndicator_Message_FailbookCase",{
                  "quantity":pendingRewards.length - 1,
                  "friendword":ZLocUtils.tk("Achievements","helpfriends_word","",pendingRewards.length - 1)
               });
               arrowIndicator = new CraftingArrowIndicatorWindow(Player.NO_PROFILE_PIC_URL,failMessage,String(pendingRewards.length));
            }
         }
         return arrowIndicator;
      }
      
      override protected function setArrowPosition() : void
      {
         var spr:Sprite = null;
         if(Boolean(m_arrow) && Boolean(m_displayObject))
         {
            spr = m_displayObject as Sprite;
            m_arrow.scaleX = ARROW_SCALE / m_displayObject.scaleX;
            m_arrow.scaleY = ARROW_SCALE / m_displayObject.scaleY;
            if(spr.getChildAt(0))
            {
               m_arrow.y = -50;
               m_arrow.x = 50;
            }
         }
      }
      
      override protected function onBuilt() : void
      {
         super.onBuilt();
         if(CraftingManager.getInstance().reconfigureOnPlace && CraftingManager.getInstance().lastBushelFound != null)
         {
            CraftingManager.getInstance().reconfigureOnPlace = false;
            CraftingManager.getInstance().reconfigureMarketStallInitial(this,CraftingManager.getInstance().lastBushelFound);
         }
         CraftingStatsManager.recordStallPlaced();
         if(!Global.player.getSeenFlag(TUTORIAL_SEEN_FLAG))
         {
            Global.player.setSeenFlag(TUTORIAL_SEEN_FLAG);
            TutorialUI.displayNewMarketStallTutorialWindow();
         }
         ++Global.player.craftingState.inventoryState.placedMarketStallCount;
      }
      
      override public function getSaveObject() : Object
      {
         var obj:Object = super.getSaveObject();
         obj.itemName = m_originalItemName;
         return obj;
      }
      
      override public function onSell() : void
      {
         super.onSell();
         CraftingStatsManager.recordStallSold();
         --Global.player.craftingState.inventoryState.placedMarketStallCount;
      }
      
      override public function isSellable() : Boolean
      {
         var result:Boolean = super.isSellable();
         if(CraftingManager.getInstance().getPlacedMarketStalls() == 1 && Global.player.craftingState.inventoryState.currentCapacity > 0 && Global.player.craftingState.inventoryState.placedCraftingCottageCount == 0)
         {
            result = false;
         }
         return result;
      }
      
      override public function isClearable() : Boolean
      {
         var result:Boolean = true;
         if(CraftingManager.getInstance().getPlacedMarketStalls() == 1 && Global.player.craftingState.inventoryState.currentCapacity > 0)
         {
            result = false;
         }
         return result;
      }
      
      override public function onDelete() : void
      {
         super.onDelete();
         CraftingStatsManager.recordStallDeleted();
         --Global.player.craftingState.inventoryState.placedMarketStallCount;
      }
      
      public function get expandManager() : IExpandComponent
      {
         return m_expand;
      }
      
      override public function isFullyBuilt() : Boolean
      {
         return true;
      }
      
      override public function isValidExpansionPart(resource:MapResource) : Boolean
      {
         return m_expand.isValidExpansionPart(resource);
      }
      
      override public function getNextExpansionData() : XML
      {
         return m_expand.getNextExpansionData();
      }
      
      override public function getNextBuildingExpansionData() : BuildingExpansionData
      {
         return m_expand.getNextBuildingExpansionData();
      }
      
      override public function getExpansionPartCount(itemCode:String) : int
      {
         return m_expand.getExpansionPartCount(itemCode);
      }
      
      override public function getTotalExpansionPartCount() : int
      {
         return m_expand.getTotalExpansionPartCount();
      }
      
      override public function getExpansionPartLimit(itemCode:String) : int
      {
         return m_expand.getExpansionPartLimit(itemCode);
      }
      
      public function getExpandCashNeeded() : int
      {
         return m_expand.getExpandCashNeeded();
      }
      
      override public function addExpansionPart(resource:MapResource) : Boolean
      {
         var result:Boolean = m_expand.addExpansionPart(resource);
         var oldCapacity:int = parseInt(Global.craftConfigSettings.getFeatureParam("globalInventoryBushelCapacity"));
         var level:int = m_expand.getExpansionLevel();
         m_expand.storageLevel = level;
         var capBonus:int = parseInt(Global.craftConfigSettings.getFeatureParam("marketStallExpansionCapacity"));
         Global.player.craftingState.inventoryState.baseCapacity = oldCapacity + capBonus * level;
         storageLevel = level;
         return result;
      }
      
      override protected function completeExpansionLevel() : void
      {
         m_expand.completeExpansionLevel();
      }
      
      override public function addItem(resource:MapResource, fromStorage:int = 0, isGift:Boolean = false, sendStoreItem:Boolean = true, force:Boolean = false) : Boolean
      {
         var itemName:String = resource.getItem().name;
         return super.addItem(resource,fromStorage,isGift,sendStoreItem,force);
      }
      
      override public function canTakeItem(item:MapResource, isMouseOver:Boolean = true) : Boolean
      {
         return super.isValidExpansionPart(item);
      }
      
      override public function getItemLimit(item:FarmItem) : Number
      {
         var max:int = m_expand.getExpansionPartLimit(item.code);
         var onhand:int = m_expand.getExpansionPartCount(item.code);
         return max - onhand;
      }
      
      override public function getCurrentLevelConstructionItemCount(itemCode:String) : int
      {
         return this.getExpansionPartCount(itemCode);
      }
      
      override public function getTotalPartsNeededForItem(itemCode:String) : int
      {
         return m_expand.getExpansionPartLimit(itemCode);
      }
      
      override public function getConstructionItems() : Array
      {
         var partInfo:Object = null;
         var item:FarmItem = null;
         var partItem:PartItem = null;
         var resultItems:Array = [];
         var info:Array = m_expand.getConstructionInfo();
         for each(partInfo in info)
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(partInfo[FeatureExpansionState.PARTINFO_NAME_KEY]);
            partItem = new PartItem(item,partInfo[FeatureExpansionState.PARTINFO_NEED_KEY]);
            partItem.onHand = partInfo[FeatureExpansionState.PARTINFO_ONHAND_KEY];
            resultItems.push(partItem);
         }
         return resultItems;
      }
      
      public function conditionallySurfaceExpandFeed() : void
      {
         var statsKingdom:String = null;
         var message:String = null;
         var feedImage:String = null;
         var neededItems:Array = null;
         var info:Array = null;
         var partInfo:Object = null;
         var rewardLink:String = null;
         var expansionFlag:String = FeatureOptionsManager.FEATURE_MARKET_STALL + "_expand_" + m_expand.storageLevel;
         if(Global.player.getFeatureLastShown(expansionFlag) == 0)
         {
            statsKingdom = expansionFlag;
            message = ZLocUtils.t("Dialogs",FeatureOptionsManager.FEATURE_MARKET_STALL + "ExpandMessage");
            feedImage = Global.getAssetURL(EXPANSION_STARTED_FEEDIMAGE);
            neededItems = [];
            info = m_expand.getConstructionInfo();
            for each(partInfo in info)
            {
               neededItems.push(partInfo[FeatureExpansionState.PARTINFO_NAME_KEY]);
            }
            rewardLink = "gifts.php?giftRecipient=" + Global.player.snUser.uid + "&selectedGift=" + m_expand.getExpansionPartString();
            ExpansionFeedManager.shareStartExpansion(expansionFlag,statsKingdom,message,feedImage,FeatureOptionsManager.FEATURE_MARKET_STALL + "ExpandAsk",rewardLink);
         }
      }
      
      override protected function onCompleteExpansion(rewardLink:String, itemName:String) : void
      {
         var farmItem:FarmItem = this.getItem();
         var feedImage:String = Global.getAssetURL(EXPANSION_COMPLETE_FEEDIMAGE);
         var itemFriendlyName:String = Global.farmGameSettingsManager.getFarmItemByName(itemName).friendlyName;
         var propertyKey:String = FeatureOptionsManager.FEATURE_MARKET_STALL + "_expansionComplete";
         var quantity:int = Global.player.craftingState.inventoryState.maxCapacity;
         var message:String = ZLocUtils.t("Dialogs",propertyKey,{
            "building":ZLocUtils.tk_pk(farmItem.friendlyName),
            "quantity":quantity
         });
         ExpansionFeedManager.onCompleteExpansionMilestone(rewardLink,propertyKey,feedImage,"feed-craftingmarketstall-upgrade_complete",message,farmItem.friendlyName,itemFriendlyName,this.onFinishShareExpansionReward);
      }
      
      override protected function onCompleteHalfExpansion(rewardLink:String) : void
      {
         var farmItem:FarmItem = this.getItem();
         var feedImage:String = Global.getAssetURL(EXPANSION_HALFWAY_FEEDIMAGE);
         var propertyKey:String = FeatureOptionsManager.FEATURE_MARKET_STALL + "_halfwayComplete";
         var message:String = ZLocUtils.t("Dialogs",propertyKey,{"building":ZLocUtils.tk_pk(farmItem.friendlyName)});
         ExpansionFeedManager.onCompleteExpansionMilestone(rewardLink,propertyKey,feedImage,"feed-craftingmarketstall-upgrade-halfway",message,farmItem.friendlyName,"",this.onFinishShareExpansionReward);
      }
      
      override protected function onCompleteExpansionPart(rewardLink:String, itemName:String) : void
      {
         var farmItem:FarmItem = this.getItem();
         var feedImage:String = EXPANSION_PROGRESS_FEEDIMAGE;
         switch(itemName)
         {
            case "stall_awning":
               feedImage = EXPANSION_AWNING_FEEDIMAGE;
               break;
            case "stall_basket":
               feedImage = EXPANSION_BASKET_FEEDIMAGE;
               break;
            case "stall_pricecard":
               feedImage = EXPANSION_PRICECARD_FEEDIMAGE;
         }
         feedImage = Global.getAssetURL(feedImage);
         var itemFriendlyName:String = Global.farmGameSettingsManager.getFarmItemByName(itemName).friendlyName;
         var propertyKey:String = FeatureOptionsManager.FEATURE_MARKET_STALL + "_partComplete";
         var message:String = ZLocUtils.t("Dialogs",propertyKey,{
            "building":ZLocUtils.tk_pk(farmItem.friendlyName),
            "item":ZLocUtils.tk_pk(itemFriendlyName)
         });
         ExpansionFeedManager.onCompleteExpansionMilestone(rewardLink,propertyKey,feedImage,"feed-craftingmarketstall-upgrade_material_complete",message,farmItem.friendlyName,itemFriendlyName,this.onFinishShareExpansionReward);
      }
      
      override protected function onCompleteExpansionPartsInterval(rewardLink:String, itemName:String) : void
      {
         var farmItem:FarmItem = this.getItem();
         var feedImage:String = Global.getAssetURL(EXPANSION_PROGRESS_FEEDIMAGE);
         var itemFriendlyName:String = Global.farmGameSettingsManager.getFarmItemByName(itemName).friendlyName;
         var propertyKey:String = FeatureOptionsManager.FEATURE_MARKET_STALL + "_partsInterval";
         var message:String = ZLocUtils.t("Dialogs",propertyKey,{"building":ZLocUtils.tk_pk(farmItem.friendlyName)});
         ExpansionFeedManager.onCompleteExpansionMilestone(rewardLink,propertyKey,feedImage,"feed-craftingmarketstall-upgrade_material_interval",message,farmItem.friendlyName,itemFriendlyName,this.onFinishShareExpansionReward);
      }
      
      private function onFinishShareExpansionReward(feedAction:String, bundleData:Object) : void
      {
      }
      
      public function frictionlessExpand(callBack:Function = null) : void
      {
         var expansionCashNeeded:Number = m_expand.getExpandCashNeeded();
         if(expansionCashNeeded > 0)
         {
            if(Global.player.canBuyCash(expansionCashNeeded))
            {
               if(this.expandToNextStorageLevel() == true)
               {
                  addTransaction(new TCompleteNow(this,null,callBack));
                  if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_BUILDING_UI_CASH_BUY_COUNTER) > 0)
                  {
                     FarmStatsManager.sample(100,"fv_cash_buy","building",getItemName() + storageLevel.toString(),"complete_now",expansionCashNeeded.toString());
                  }
                  Global.player.cash -= expansionCashNeeded;
               }
            }
         }
      }
   }
}

