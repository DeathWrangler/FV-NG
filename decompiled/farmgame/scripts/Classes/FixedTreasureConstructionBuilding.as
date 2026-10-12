package Classes
{
   import Cache.Classes.ZCacheUtil;
   import Classes.Constants.Experiments;
   import Classes.Constants.MFSConstants;
   import Classes.Constants.StatsTrackingConstants;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.ZItem.ConsumableItem;
   import Classes.ZItem.FarmItem;
   import Classes.storage.PartItem;
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Display.GenericFrictionlessBuyPopup;
   import Display.GenericPopup;
   import Display.TutorialUI;
   import Display.UI;
   import Engine.Helpers.Vector2;
   import Engine.Helpers.Vector3;
   import Engine.IsoMath;
   import Events.GenericPopupEvent;
   import GameMode.GMBuildingPart;
   import GameMode.GMConstructBuilding;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsInventoryManager;
   import Managers.HangingGardensManager;
   import Managers.JMInnovationManager;
   import Managers.MFSRequestManager;
   import Widgets.Windows.TreasureCompleteWindow;
   import Widgets.Windows.TreasureHoverOverWindow;
   import Widgets.Windows.WishingFountainWindow;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   public class FixedTreasureConstructionBuilding extends FixedConstructionBuilding
   {
      
      public static const USE_BUTTON_CLICKED:String = "treasure_use_buttone_clicked";
      
      public static const FULLY_BUILT_DIALOG_TEXT:String = "FixedTreasureFullyBuilt";
      
      public static const FEED_STATUS_READY:String = "ready";
      
      public static const FEED_STATUS_POSTED:String = "posted";
      
      public static const FEED_STATUS_POSTING:String = "posting";
      
      public static const ASK_PARTS_FEED:String = "feed";
      
      public static const ASK_PARTS_MFS_ASKITEMS_REACTS:String = "MFSAskItemsReacts";
      
      public static const ASK_PARTS_DEFAULT:String = "default";
      
      public static const CRAFT_PARTS:String = "craft";
      
      private static const HOVER_MENU_TIME_MS:int = 800;
      
      private static const WHAT_IS_THIS:String = "whatIsThis";
      
      private static const FEED_TREASURE_DEFINITON:String = "asianTreasureAskPart";
      
      private static const CURRENCY_ITEMS_TO_USE:int = 1;
      
      private static const HOVER_OVER_WINDOW_ASSET:String = "_hover_over_window_asset";
      
      private static var m_hoverWindows:Object = new Object();
      
      private const REWARD_WINDOW_ASSET:String = "RewardWindowAsset";
      
      private var m_cashBuyKingdom:String = "";
      
      private var m_hoveringContextMenuState:String;
      
      private var m_frictionlessBuyActive:Boolean = false;
      
      private var m_feedPostingState:String = "posted";
      
      private var m_hoverCallbackObject:Object = null;
      
      protected var m_transformStarted:Boolean = false;
      
      private var m_hoverOverWindowAsset:String = "assets/dialogs/Asia/FV_xas_treasureTip.swf";
      
      private var m_unlockedTreasure:FarmItem;
      
      private var m_showPopupSideCard:Boolean = false;
      
      private var m_consumableGrantCount:int = 0;
      
      public function FixedTreasureConstructionBuilding(buildingType:String = null)
      {
         var hoverWindowAsset:String = null;
         var worldHoverWindowAsset:String = null;
         super(buildingType);
         m_displayStorageDialog = false;
         if(!Global.worldManager.isVisiting())
         {
            hoverWindowAsset = Global.farmGameSettingsManager.getString(buildingType + HOVER_OVER_WINDOW_ASSET);
            worldHoverWindowAsset = Global.farmGameSettingsManager.getString(Global.worldManager.currentWorldType + HOVER_OVER_WINDOW_ASSET);
            if(hoverWindowAsset)
            {
               this.m_hoverOverWindowAsset = hoverWindowAsset;
            }
            else if(worldHoverWindowAsset)
            {
               this.m_hoverOverWindowAsset = worldHoverWindowAsset;
            }
            this.m_hoveringContextMenuState = getHoveringContextMenuState();
            this.m_frictionlessBuyActive = useFrictionlessBuy();
            this.m_hoverCallbackObject = {
               "noPartsCallback":this.onNoPartsClick,
               "whatIsThisCallback":this.onWhatIsThisClick,
               "completeNowCallback":this.completeNow,
               "getCashNeededCallback":getCashNeeded,
               "inventoryPartCountUseableCallback":getInventoryPartCountUseable,
               "getTotalPartsCallback":getItemLimit,
               "getCurrentPartsCallback":getAmount,
               "usePartsCallback":this.onUseClick,
               "getNoPartsLabel":this.getNoPartsLabel,
               "getTrackingID":this.getTrackingId
            };
         }
      }
      
      private static function showHoverMenu(treasure:FixedTreasureConstructionBuilding, feedState:String, hoverCallbackObject:Object, requestTypeToUse:String, hoverOverWindowAsset:String, timerTime:int = -1) : void
      {
         if(m_hoverWindows[hoverOverWindowAsset] != null && Boolean(m_hoverWindows[hoverOverWindowAsset].isLoaded()))
         {
            m_hoverWindows[hoverOverWindowAsset].updateAndShow(treasure,feedState,hoverCallbackObject,requestTypeToUse,timerTime);
         }
         else if(m_hoverWindows[hoverOverWindowAsset] == null)
         {
            m_hoverWindows[hoverOverWindowAsset] = new TreasureHoverOverWindow(treasure,feedState,hoverCallbackObject,requestTypeToUse,timerTime,hoverOverWindowAsset);
            UI.addHoverWindow(m_hoverWindows[hoverOverWindowAsset]);
         }
      }
      
      private function requestTypeToUse() : String
      {
         var requestType:Object = null;
         var prereqName:String = null;
         var result:String = null;
         var requestTypes:Array = getRequestTypes(this.getMostNeededItem().item.name);
         if(Boolean(requestTypes) && requestTypes.length > 0)
         {
            for each(requestType in requestTypes)
            {
               prereqName = requestType.prereq;
               if(PrerequisiteUtility.checkPrereqByName(prereqName))
               {
                  result = requestType.type;
                  break;
               }
            }
         }
         if(result == null)
         {
            result = ASK_PARTS_DEFAULT;
         }
         return result;
      }
      
      protected function get tutorialImagePrefix() : String
      {
         return m_tutorialImagePrefix;
      }
      
      override public function transformBuilding(resultData:Object = null) : MapResource
      {
         var position:Vector3 = null;
         var screen:Vector2 = null;
         var assetUrl:String = null;
         var displayPoint:Point = null;
         var finishedItem:FarmItem = null;
         var packagedItems:Object = null;
         var pkgItemName:String = null;
         var item:FarmItem = null;
         var callbackFunction:Function = null;
         var itemName:String = null;
         var windowAsset:String = null;
         var result:MapResource = null;
         if(null != resultData)
         {
            position = this.getPosition();
            screen = IsoMath.tilePosToPixelPos(position.x,position.y,position.z);
            assetUrl = Global.getAssetURL(LootableDecoration.OPEN_OVERLAY_URL_DEFAULT);
            displayPoint = new Point(screen.x,screen.y);
            finishedItem = getFinishedItemFromResult(resultData);
            packagedItems = finishedItem.getItemPackageHash();
            if(packagedItems)
            {
               if(JMInnovationManager.getInstance().isActive())
               {
                  this.m_showPopupSideCard = true;
               }
               for(pkgItemName in packagedItems)
               {
                  item = Global.farmGameSettingsManager.getFarmItemByName(pkgItemName);
                  if(item is ConsumableItem && (item as ConsumableItem).isAutoConsumable())
                  {
                     this.m_consumableGrantCount = packagedItems[pkgItemName];
                     FeatureOptionsInventoryManager.getInstance().addCount(item.code,packagedItems[pkgItemName]);
                  }
                  else if(Boolean(resultData) && resultData.hasOwnProperty("finishedName"))
                  {
                     resultData.finishedName = pkgItemName;
                  }
               }
            }
            if(HangingGardensManager.isInHangingGardensExperiment())
            {
               callbackFunction = null;
               itemName = this.getItemName();
               windowAsset = Global.farmGameSettingsManager.getString(itemName + this.REWARD_WINDOW_ASSET,"");
               if(windowAsset != "")
               {
                  callbackFunction = ZCacheUtil.applyPartial(this.showWindowAsset,this,[windowAsset,itemName,resultData]);
               }
               else
               {
                  callbackFunction = ZCacheUtil.applyPartial(this.popTransformFeed,this,[resultData]);
               }
               Global.ui.displayOverlaySWF(assetUrl,displayPoint,null,-100,callbackFunction);
            }
            else
            {
               Global.ui.displayOverlaySWF(assetUrl,displayPoint,null,-100,function():Boolean
               {
                  var statsKingdom:String = getItem().resourcePrefix + "_" + StatsTrackingConstants.DIALOG_STATE_EXPANSION_COMPLETE_KINGDOM;
                  var treasureItem:FarmItem = getFinishedItemFromResult(resultData);
                  var giftItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(resultData.gift);
                  var locParams:Object = {
                     "treasure":ZLocUtils.tk_pk(treasureItem.friendlyName),
                     "finishedReward":ZLocUtils.tk_pk(giftItem.friendlyName)
                  };
                  var statsClass:String = treasureItem.friendlyTitle;
                  var dialogTextKey:String = FULLY_BUILT_DIALOG_TEXT;
                  var hasLocalization:Boolean = ZLocUtils.hasString("Dialogs",FULLY_BUILT_DIALOG_TEXT + "_" + Global.worldManager.currentWorldType);
                  if(hasLocalization)
                  {
                     dialogTextKey = FULLY_BUILT_DIALOG_TEXT + "_" + Global.worldManager.currentWorldType;
                  }
                  createRewardFeed(m_buildingName + "FullyBuilt",statsKingdom,resultData.rewardLink,treasureItem.iconRelativeUrl,null,treasureItem.iconUrl,null,treasureItem.friendlyTitle,locParams,statsClass,dialogTextKey);
                  return false;
               });
            }
            result = super.transformBuilding(resultData);
         }
         this.m_transformStarted = true;
         return result;
      }
      
      private function showWindowAsset(windowAsset:String, itemName:String, resultData:Object) : Boolean
      {
         UI.displayPopup(new TreasureCompleteWindow(windowAsset,itemName,resultData),true,"TransformBuildingCompleteWindow",false);
         return false;
      }
      
      private function popTransformFeed(resultData:Object) : Boolean
      {
         var statsKingdom:String = getItem().resourcePrefix + "_" + StatsTrackingConstants.DIALOG_STATE_EXPANSION_COMPLETE_KINGDOM;
         var treasureItem:FarmItem = getFinishedItemFromResult(resultData);
         var giftItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(resultData.gift);
         var locParams:Object = null;
         var friendlyTitle:String = "";
         var relativeUrl:String = "";
         var iconUrl:String = "";
         var giftFriendlyName:String = "";
         if(treasureItem != null)
         {
            if(giftItem != null)
            {
               giftFriendlyName = ZLocUtils.tk_pk_asTitle(giftItem.friendlyName);
            }
            locParams = {
               "treasure":ZLocUtils.tk_pk(treasureItem.friendlyName),
               "finishedReward":giftFriendlyName
            };
            friendlyTitle = treasureItem.friendlyTitle;
            relativeUrl = treasureItem.iconRelativeUrl;
            iconUrl = treasureItem.iconUrl;
         }
         else if(giftItem != null)
         {
            giftFriendlyName = ZLocUtils.tk_pk_asTitle(giftItem.friendlyName);
            locParams = {"finishedReward":giftFriendlyName};
            friendlyTitle = giftItem.friendlyTitle;
            relativeUrl = giftItem.iconRelativeUrl;
            iconUrl = giftItem.iconUrl;
         }
         var statsClass:String = friendlyTitle;
         var dialogTextKey:String = FULLY_BUILT_DIALOG_TEXT;
         var hasLocalization:Boolean = ZLocUtils.hasString("Dialogs",FULLY_BUILT_DIALOG_TEXT + "_" + Global.worldManager.currentWorldType);
         if(hasLocalization)
         {
            dialogTextKey = FULLY_BUILT_DIALOG_TEXT + "_" + Global.worldManager.currentWorldType;
         }
         createRewardFeed(m_buildingName + "FullyBuilt",statsKingdom,resultData.rewardLink,relativeUrl,null,iconUrl,null,friendlyTitle,locParams,statsClass,dialogTextKey);
         return false;
      }
      
      private function onBuyUnlockItem(data:Object = null) : void
      {
         if(data.button)
         {
            UI.displayMiniMarketDialog([this.m_unlockedTreasure.name],"building");
         }
      }
      
      override public function onFullyFinished(result:Object, transformedObj:MapResource = null) : void
      {
         grantFinishedReward(result);
         FarmStatsManager.count("fixed_treasure",this.getItemName(),"complete",this.getTrackingId());
      }
      
      private function getNoPartsLabel() : String
      {
         var requestType:String = null;
         var result:String = "";
         if(HangingGardensManager.isInHangingGardensExperiment() && m_hoverWindowAction != null)
         {
            switch(m_hoverWindowAction)
            {
               case "lookInside":
                  result = ZLocUtils.t("Dialogs",m_hoverWindowActionValue + "NoPartsLabel");
            }
         }
         else
         {
            requestType = this.requestTypeToUse();
            if(requestType == FixedTreasureConstructionBuilding.CRAFT_PARTS)
            {
               result = ZLocUtils.t("Dialogs","FeatureBuildingCraftParts");
            }
            else if(this.m_feedPostingState == FEED_STATUS_READY || requestType != ASK_PARTS_FEED)
            {
               if(this.m_hoveringContextMenuState != HOVERING_CONTEXT_OFF)
               {
                  result = ZLocUtils.t("Dialogs","storage_ask_for_parts");
               }
               else
               {
                  result = ZLocUtils.t("Dialogs","FixedTreasure_Menu_AskPart",{"partName":ZLocUtils.tk_pk(getMostNeededItem().item.friendlyName)});
               }
            }
            else if(this.m_feedPostingState == FEED_STATUS_POSTING)
            {
               result = ZLocUtils.t("Quests","Helper_AskForHelp_InProgress");
            }
            else if(this.m_feedPostingState == FEED_STATUS_POSTED)
            {
               result = ZLocUtils.t("Quests","Helper_AskForHelp_Sent");
            }
         }
         return result;
      }
      
      override public function showMenu() : void
      {
         var mostNeededItem:PartItem = null;
         var partsCount:int = 0;
         var usePartsLabel:String = null;
         var neededPartCount:int = 0;
         var displayPartCount:String = null;
         if(!Global.worldManager.isVisiting())
         {
            if(this.m_hoveringContextMenuState == HOVERING_CONTEXT_OFF)
            {
               m_menuItems.push({
                  "label":this.getCompleteNowContextString(),
                  "action":"completeNow"
               });
               mostNeededItem = getMostNeededItem();
               partsCount = getInventoryPartCount(mostNeededItem);
               if(partsCount > 0)
               {
                  usePartsLabel = "";
                  if(partsCount > 1)
                  {
                     neededPartCount = getPartsNeeded(mostNeededItem);
                     displayPartCount = neededPartCount.toString();
                     if(neededPartCount > partsCount)
                     {
                        displayPartCount = partsCount.toString();
                     }
                     usePartsLabel = ZLocUtils.t("Dialogs","FixedTreasure_Menu_UseParts",{
                        "partName":ZLocUtils.tk_pk(mostNeededItem.item.friendlyName),
                        "count":displayPartCount
                     });
                  }
                  else
                  {
                     usePartsLabel = ZLocUtils.t("Dialogs","FixedTreasure_Menu_UsePart",{"partName":ZLocUtils.tk_pk(getMostNeededItem().item.friendlyName)});
                  }
                  m_menuItems.push({
                     "label":usePartsLabel,
                     "action":"usePart"
                  });
               }
               m_menuItems.push({
                  "label":this.getNoPartsLabel(),
                  "action":"noParts"
               });
               m_menuItems.push({
                  "label":ZLocUtils.t("Dialogs","MoreInfo"),
                  "action":WHAT_IS_THIS
               });
               UI.displayMenu(m_menuItems,this.onMenuClick);
            }
         }
      }
      
      override public function sortMenu() : void
      {
         var whatIsThisArr:Array = null;
         for(var menuIdx:int = 0; menuIdx < m_menuItems.length; menuIdx++)
         {
            if(m_menuItems[menuIdx]["action"] == WHAT_IS_THIS)
            {
               whatIsThisArr = m_menuItems.splice(menuIdx,1);
               m_menuItems.push(whatIsThisArr[0]);
            }
         }
      }
      
      override public function onMouseOut() : void
      {
         if(!Global.worldManager.isVisiting())
         {
            if(m_hoverWindows[this.m_hoverOverWindowAsset] != null)
            {
               m_hoverWindows[this.m_hoverOverWindowAsset].beginCloseTimer();
            }
         }
         super.onMouseOut();
      }
      
      override public function onMouseOver(event:MouseEvent) : void
      {
         super.onMouseOver(event);
         if(HangingGardensManager.isInHangingGardensExperiment() && this.m_hoveringContextMenuState == HOVERING_CONTEXT_OFF)
         {
            this.setHighlighted(false);
         }
      }
      
      override public function onClick() : void
      {
         if(!Global.worldManager.isVisiting())
         {
            if(canRequestPartFeed(this.getMostNeededItem().item.code) && this.m_feedPostingState != FEED_STATUS_POSTING)
            {
               this.m_feedPostingState = FEED_STATUS_READY;
            }
            if(HangingGardensManager.isInHangingGardensExperiment())
            {
               this.m_hoveringContextMenuState = getHoveringContextMenuState();
            }
            if(this.m_hoveringContextMenuState == HOVERING_CONTEXT_MOUSE_OVER && getState() == STATE_CONSTRUCTION && !(Global.world.getTopGameMode() is GMBuildingPart))
            {
               showHoverMenu(this,this.m_feedPostingState,this.m_hoverCallbackObject,this.requestTypeToUse(),this.m_hoverOverWindowAsset,HOVER_MENU_TIME_MS);
            }
         }
         super.onClick();
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            switch(item.action)
            {
               case WHAT_IS_THIS:
                  this.onWhatIsThisClick();
                  break;
               case "noParts":
                  this.onNoPartsClick();
                  break;
               case "usePart":
                  this.onUseClick();
                  break;
               case "completeNow":
                  this.completeNow();
                  break;
               default:
                  super.onMenuClick(event);
            }
            this.trackMenuClick(item.action);
         }
      }
      
      private function completeNow() : void
      {
         if(!this.m_transformStarted && Global.player.canBuyCash(getCashNeeded(),true,"fixed_treasure"))
         {
            if(this.m_frictionlessBuyActive)
            {
               this.frictionlessCompleteNow(true);
            }
            else
            {
               UI.displayMessage(ZLocUtils.t("Dialogs","FinishConstructionBuildingPopup",{
                  "cashQuantity":this.getCashNeeded().toString(),
                  "item":ZLocUtils.tk_pk(getItemFriendlyName())
               }),GenericPopup.TYPE_ACCEPTCANCEL,this.onConfirmCompletePopupClose,"",true);
            }
         }
         this.m_cashBuyKingdom = "context_menu_complete";
      }
      
      private function onConfirmCompletePopupClose(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.YES)
         {
            FarmStatsManager.count("fixed_treasure",this.getItemName(),"confirm_dialog","accept",this.getTrackingId());
            this.frictionlessCompleteNow(true);
         }
         else
         {
            FarmStatsManager.count("fixed_treasure",this.getItemName(),"confirm_dialog","cancel",this.getTrackingId());
         }
      }
      
      override public function frictionlessCompleteNow(transformBuildingOnComplete:Boolean = false, callback:Function = null) : void
      {
         if(!this.m_transformStarted)
         {
            setState(STATE_BUSY);
            FarmStatsManager.count("fv_cash_buy","fixed_treasure",this.getItemName(),this.getCashNeeded().toString(),this.m_cashBuyKingdom);
            super.frictionlessCompleteNow(transformBuildingOnComplete,callback);
         }
      }
      
      protected function onNoPartsClick() : void
      {
         var lookInsideItems:Array = null;
         var building:StorageBuilding = null;
         var requestType:String = null;
         var part:PartItem = null;
         var friendSpec:Object = null;
         var friendTabOrder:Array = null;
         var bundleName:String = null;
         if(!this.m_transformStarted)
         {
            if(HangingGardensManager.isInHangingGardensExperiment() && m_hoverWindowAction != null)
            {
               switch(m_hoverWindowAction)
               {
                  case "lookInside":
                     lookInsideItems = Global.world.getObjectsByCode(m_hoverWindowActionValue);
                     if(lookInsideItems.length > 0 && lookInsideItems[0] is StorageBuilding)
                     {
                        building = lookInsideItems[0] as StorageBuilding;
                        building.displayStorageDialog();
                        FarmStatsManager.count("fixed_treasure",this.getItemName(),"lookInside",building.getItemName());
                     }
               }
            }
            else
            {
               requestType = this.requestTypeToUse();
               switch(requestType)
               {
                  case CRAFT_PARTS:
                     part = this.getMostNeededItem();
                     WishingFountainWindow.openMakeRecipeWindow(this.buildingName,part.item.code);
                     break;
                  case ASK_PARTS_FEED:
                     if(this.m_feedPostingState == FEED_STATUS_READY && m_hoverWindows[this.m_hoverOverWindowAsset] != null)
                     {
                        bundleName = Global.farmGameSettingsManager.getString(this.buildingName + "Bundle");
                        if(bundleName == "" || !Global.flashHotParams["MP_TREASURE_FEED_BUNDLE"])
                        {
                           bundleName = FEED_TREASURE_DEFINITON;
                        }
                        generateRequestExpansionPartFeed(this.getMostNeededItem().item,this.updateFeedVisuals,bundleName);
                        this.m_feedPostingState = FEED_STATUS_POSTING;
                        m_hoverWindows[this.m_hoverOverWindowAsset].updateButtonStatesFromFeed(this.m_feedPostingState);
                     }
                     FarmStatsManager.count("feed","feed",this.getItemName(),this.getMostNeededItem().item.name,"feed");
                     break;
                  case ASK_PARTS_MFS_ASKITEMS_REACTS:
                     friendSpec = {"tabNameRecommended":[MFSConstants.TYPE_TRIPLE_PARTS,MFSConstants.TYPE_REACTIVATION]};
                     friendTabOrder = ["tabNameRecommended"];
                     MFSRequestManager.getInstance().makeAskItemsRequest(this.getItemName(),this.getPartsString(),"","","",friendSpec,friendTabOrder);
                     FarmStatsManager.count("request","request_more",this.getItemName(),this.getMostNeededItem().item.name,"MFS_recommended");
                     break;
                  default:
                     MFSRequestManager.getInstance().makeAskItemsRequest(this.getItemName(),this.getPartsString());
                     FarmStatsManager.count("request","request_more",this.getItemName(),this.getMostNeededItem().item.name,"MFS_3x1x");
               }
            }
         }
      }
      
      private function updateFeedVisuals(result:Object) : void
      {
         if(result["postSuccessful"])
         {
            this.m_feedPostingState = FEED_STATUS_POSTED;
         }
         else
         {
            this.m_feedPostingState = FEED_STATUS_READY;
         }
         if(this.m_hoveringContextMenuState != HOVERING_CONTEXT_OFF && m_hoverWindows[this.m_hoverOverWindowAsset] != null && Boolean(m_hoverWindows[this.m_hoverOverWindowAsset].isShown()))
         {
            m_hoverWindows[this.m_hoverOverWindowAsset].updateButtonStatesFromFeed(this.m_feedPostingState);
         }
      }
      
      protected function onUseClick() : void
      {
         var mostNeededItem:PartItem = null;
         var partCountToUse:int = 0;
         if(!this.m_transformStarted)
         {
            mostNeededItem = getMostNeededItem();
            partCountToUse = 0;
            if(mostNeededItem.getCurrency() != null)
            {
               partCountToUse = CURRENCY_ITEMS_TO_USE;
            }
            else
            {
               partCountToUse = getInventoryPartCountUseable(mostNeededItem);
            }
            Global.world.addGameMode(new GMConstructBuilding(mostNeededItem.item.name,this,true,true,false,partCountToUse,false),false);
            Global.world.dispatchEvent(new Event(USE_BUTTON_CLICKED));
         }
      }
      
      protected function onWhatIsThisClick() : void
      {
         TutorialUI.displayBundleTutorialWindow("Dialogs",this.buildingName,this.tutorialImagePrefix);
      }
      
      override protected function updateToolTipText() : void
      {
         var partItem:PartItem = null;
         var capacityText:String = null;
         var toolTip:String = null;
         var item:FarmItem = null;
         if(this.m_hoveringContextMenuState != HOVERING_CONTEXT_OFF)
         {
            partItem = this.getMostNeededItem();
            capacityText = null;
            if(partItem.getCurrency() == null)
            {
               capacityText = getBuildingPartCapacityToolTipText(partItem.item.name);
            }
            else
            {
               item = partItem.item;
               capacityText = ZLocUtils.t("Items","buildingpart_capacity",{
                  "item":ZLocUtils.tk_pk(partItem.friendlyName),
                  "quantity":getAmount(item.code),
                  "maximum":getItemLimit(item)
               });
            }
            toolTip = ZLocUtils.t("FarmGame","AnimalBuilding_capacity",{
               "item":ZLocUtils.tk_pk(m_item.friendlyName),
               "capacityStr":capacityText
            });
            setToolTip(toolTip);
            updateToolTipPosition();
         }
      }
      
      private function onWindowClose(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            FarmStatsManager.count("fixed_treasure",this.getItemName(),"dialog_out_of_parts","accept_clicked",this.getCashNeeded().toString());
            this.m_cashBuyKingdom = "dialog_post_parts_complete";
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FIXED_TREASURE_COMPLETE_FRICTION) == Experiments.VARIANT_FIXED_TREASURE_FRICTION_ENABLED)
            {
               UI.displayMessage(ZLocUtils.t("Dialogs","FinishConstructionBuildingPopup",{
                  "cashQuantity":this.getCashNeeded().toString(),
                  "item":ZLocUtils.tk_pk(getItemFriendlyName())
               }),GenericPopup.TYPE_ACCEPTCANCEL,this.onConfirmCompletePopupClose,"",true);
            }
            else
            {
               this.frictionlessCompleteNow(true);
            }
         }
         else if(event.button == GenericPopup.ASK)
         {
            this.onNoPartsClick();
            FarmStatsManager.count("fixed_treasure",this.getItemName(),"dialog_out_of_parts","ask_clicked",this.getCashNeeded().toString());
         }
         else
         {
            FarmStatsManager.count("fixed_treasure",this.getItemName(),"dialog_out_of_parts","close_clicked",this.getCashNeeded().toString());
         }
         var popup:GenericFrictionlessBuyPopup = GenericFrictionlessBuyPopup(event.target);
         if(popup)
         {
            popup.close();
         }
      }
      
      public function onMCFinishPlaying() : Boolean
      {
         return false;
      }
      
      private function trackMenuClick(menuAction:String) : void
      {
         FarmStatsManager.count("fixed_treasure",this.getItemName(),"context_menu_clicked",menuAction,this.getTrackingId());
      }
      
      private function getTrackingId() : String
      {
         return getItemLimit(getMostNeededItem().item).toString() + "_" + this.m_position.x.toString() + "_" + this.m_position.y.toString() + "_" + this.m_outer.getGridWidth().toString();
      }
      
      private function getCompleteNowContextString() : String
      {
         return ZLocUtils.t("Dialogs","FixedTreasure_Menu_Complete_FC",{"cashCost":getCashNeeded().toString()});
      }
      
      override public function addItem(resource:MapResource, fromStorage:int = 0, isGift:Boolean = false, sendStoreItem:Boolean = true, force:Boolean = false) : Boolean
      {
         if(this.count == 0)
         {
            FarmStatsManager.count("fixed_treasure",this.getItemName(),"start",this.getTrackingId());
         }
         return super.addItem(resource,fromStorage,isGift,sendStoreItem,force);
      }
      
      override public function showPopUpSideCard() : Boolean
      {
         return this.m_showPopupSideCard;
      }
      
      override public function sideCardAdditionalText() : String
      {
         return "x" + this.m_consumableGrantCount;
      }
   }
}

