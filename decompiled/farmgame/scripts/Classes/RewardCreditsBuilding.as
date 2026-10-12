package Classes
{
   import Classes.Constants.Experiments;
   import Classes.Constants.MFSConstants;
   import Classes.Constants.StatsTrackingConstants;
   import Classes.Constants.ToasterIconPaths;
   import Classes.ZItem.BuildingItem;
   import Classes.ZItem.DeprecatorSettings;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.WorldIdUtil;
   import Classes.util.ZLocUtils;
   import DataSources.BaseDataSource;
   import Display.ContextMenuItem;
   import Display.GenericPopup;
   import Display.GenericXMLDialog;
   import Display.RewardCreditsBuildingDialog;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.FarmGameWorldEvent;
   import Events.GenericPopupEvent;
   import GameMode.GMCreditsBuildingItemPlace;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureMessagingManager;
   import Managers.FeatureTrackingManager;
   import Managers.MFSRequestManager;
   import Managers.OffboardingManager;
   import Managers.ToasterManager;
   import Transactions.TCancelFriendReward;
   import Transactions.TCreditsPassNeighbor;
   import Transactions.TWorldObjectFeedTransaction;
   import Widgets.Windows.ArrowIndicatorWindow;
   import Widgets.Windows.CraftingArrowIndicatorWindow;
   import Widgets.Windows.CustomFreeGiftSelectionWindow;
   import Widgets.Windows.HolidayBasketWindows.HolidayTreeWindow;
   import Widgets.Windows.HolidayBasketWindows.RewardCreditsWindow;
   import Widgets.Windows.HolidayBasketWindows.RewardCreditsWithPresentsWindow;
   import Widgets.Windows.TwoIconTitleToasterWindow;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   
   public class RewardCreditsBuilding extends CreditsBuilding implements IOffboardResource
   {
      
      protected static const CREDITS_REWARD_ACTION_STATE_CHANGE:int = 0;
      
      protected static const CREDITS_REWARD_ACTION_INTERVAL:int = 1;
      
      protected static const CREDITS_REWARD_ACTION_PASS_NEIGHBOR:int = 2;
      
      protected static const CREDITS_REWARD_INTERVAL_INVALID:int = -1;
      
      protected static const TOKEN_FIRST_TIME_PLACE:String = "FirstTimePlace";
      
      protected static const TOKEN_CAN_REDEEM_PRIZE_NOW:String = "RewardCredits_CanRedeemPrizeNow";
      
      protected static const TOKEN_CREDITS_NAME:String = "Items";
      
      protected static const DEPRECATED_TOKEN_START:String = "Start";
      
      protected static const TOKEN_PASS_NEIGHBOR:String = "PassNeighbor";
      
      protected static const TOKEN_INTERVAL:String = "Interval";
      
      protected static const BUNDLETOKEN_STATE_CHANGE:String = "Change";
      
      protected static const TOKEN_STATE_CHANGE:String = "StateChange";
      
      protected static const TOKEN_REDEEM:String = "redeem";
      
      protected static const TOKEN_REWARD_TYPE_STATECHANGE:String = "stateChange";
      
      protected static const TOKEN_REWARD_TYPE_INTERVAL:String = "interval";
      
      protected static const ARROW_X_OFFSET:int = 0;
      
      protected static const ARROW_Y_OFFSET:int = -50.3;
      
      private static var m_classCompilingArray:Array = [RewardCreditsWindow,RewardCreditsWithPresentsWindow,RewardCreditsBuildingDialog,HolidayTreeWindow];
      
      protected var m_lastRewardCode:String;
      
      protected var m_lastRewardUrl:String;
      
      protected var m_lastRewardAction:int;
      
      protected var m_friend:Friend = null;
      
      protected var m_passNeighborRank:int = 0;
      
      private var m_creditItemNames:Array = null;
      
      private var m_creditFarmItems:Array = null;
      
      private var m_hasBuyableCreditItems:Boolean = false;
      
      private var m_hasGiftableCreditItems:Boolean = false;
      
      private var m_shouldCheckCreditItemDates:Boolean = false;
      
      private var m_creditIntervalDialogOpen:Boolean;
      
      private var m_friendRewardTypes:Array = null;
      
      private var m_hasSeenRedeemItemNowPrompt:Array = null;
      
      protected var m_showRedeemableItemOnLoad:Object = null;
      
      private var m_buildingType:String;
      
      private var m_isNewPlacement:Boolean = true;
      
      protected const ASK_FOR_CREDITS:String = "askForCredits";
      
      protected const SEND_CREDITS:String = "sendCredits";
      
      protected const BUY_CREDITS:String = "buyCredits";
      
      protected var m_creditsToBuy:FarmItem = null;
      
      protected var m_arrowPositionSet:Boolean = false;
      
      protected var m_showingArrow:Boolean = false;
      
      private var m_isDelayedOffboarding:Boolean = false;
      
      public function RewardCreditsBuilding(buildingType:String = null, featureName:String = null)
      {
         var item:FarmItem = null;
         var creditItemsArr:Array = null;
         var creditItemDS:BaseDataSource = null;
         var rewardItemsArr:Array = null;
         var rewardItemDS:BaseDataSource = null;
         var creditItemXML:XML = null;
         var rewardItemXML:XML = null;
         this.m_buildingType = buildingType;
         if(featureName == null)
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(buildingType);
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               if(Boolean(item) && item.hasPropertyInDataSource("rewardCreditsBuilding"))
               {
                  featureName = item.getStringFromDataSource("rewardCreditsBuilding","name");
                  this.m_creditItemNames = new Array();
                  creditItemsArr = item.getArrayFromDataSource("rewardCreditsBuilding","creditItems","creditItem");
                  for each(creditItemDS in creditItemsArr)
                  {
                     this.m_creditItemNames.push(creditItemDS.getString("name"));
                  }
                  this.m_friendRewardTypes = new Array();
                  rewardItemsArr = item.getArrayFromDataSource("rewardCreditsBuilding","friendRewards","friendReward");
                  for each(rewardItemDS in rewardItemsArr)
                  {
                     this.m_friendRewardTypes.push(rewardItemDS.getString("type"));
                  }
               }
            }
            else if(Boolean(item) && item.xml.hasOwnProperty("rewardCreditsBuilding"))
            {
               featureName = item.xml.rewardCreditsBuilding.@name;
               this.m_creditItemNames = new Array();
               for each(creditItemXML in item.xml.rewardCreditsBuilding.creditItems.creditItem)
               {
                  this.m_creditItemNames.push(String(creditItemXML.@name));
               }
               this.m_friendRewardTypes = new Array();
               for each(rewardItemXML in item.xml.rewardCreditsBuilding.friendRewards.friendReward)
               {
                  this.m_friendRewardTypes.push(String(rewardItemXML.@type));
               }
            }
         }
         super(buildingType,featureName);
         var creditsXML:XML = this.getBuildingCreditsXml();
         if(Boolean(creditsXML) && Boolean(creditsXML.@breakDisplayDialog))
         {
            if(creditsXML.@breakDisplayDialog.toString() == "false")
            {
               m_displayDialogOnMeterBroken = false;
            }
         }
      }
      
      public static function getBasketFriendlyName(buildingName:String) : String
      {
         return getLocalizedKey(buildingName,"Title");
      }
      
      public static function getCreditItemFriendlyName(buildingName:String) : String
      {
         return getLocalizedKey(buildingName,"Item");
      }
      
      public static function getBuildableFriendlyName(buildingName:String) : String
      {
         var result:String = getLocalizedKey(buildingName,"BuildableTitle");
         if(result == "")
         {
            result = getLocalizedKey(buildingName,"Title");
         }
         return result;
      }
      
      public static function getLocalizedKey(buildingName:String, key:String, onlyReturnPackage:Boolean = false) : String
      {
         var pkg_result:String = "";
         var key_result:String = "";
         var building:BuildingItem = Global.farmGameSettingsManager.getFarmItemByName(buildingName) as BuildingItem;
         if(Boolean(building) && building.bundle)
         {
            if(ZLocUtils.hasString(buildingName,key))
            {
               pkg_result = buildingName;
               key_result = key;
            }
            else if(ZLocUtils.hasString("RewardCreditsBuilding",key))
            {
               pkg_result = "RewardCreditsBuilding";
               key_result = key;
            }
            else if(ZLocUtils.hasString("Dialogs",key))
            {
               pkg_result = "Dialogs";
               key_result = key;
            }
         }
         else if(ZLocUtils.hasString("Dialogs",buildingName + "_" + key))
         {
            pkg_result = "Dialogs";
            key_result = buildingName + "_" + key;
         }
         else if(ZLocUtils.hasString("RewardCreditsBuilding",key))
         {
            pkg_result = "RewardCreditsBuilding";
            key_result = key;
         }
         else if(ZLocUtils.hasString("Dialogs",key))
         {
            pkg_result = "Dialogs";
            key_result = key;
         }
         var result:String = "";
         if(onlyReturnPackage)
         {
            result = pkg_result;
         }
         else
         {
            result = pkg_result + ":" + key_result;
         }
         return result;
      }
      
      override public function loadObject(data:Object) : void
      {
         super.loadObject(data);
         if(Global.player.isDataLoaded)
         {
            m_alreadyOffboard = OffboardingManager.handleOffBoarding(this,m_alreadyOffboard);
         }
         else if(!this.m_isDelayedOffboarding)
         {
            this.m_isDelayedOffboarding = true;
            Global.world.addEventListener(FarmGameWorldEvent.USER_CHANGED,this.onDelayedOffboarding,false,0,true);
         }
         FeatureMessagingManager.getInstance().registerFeatureInitialized(m_itemName,this.displayStorageDialog);
      }
      
      override public function onObjectDrop() : void
      {
         super.onObjectDrop();
         FeatureMessagingManager.getInstance().registerFeatureInitialized(m_itemName,this.displayStorageDialog);
      }
      
      override public function sell() : void
      {
         FeatureMessagingManager.getInstance().unregisterFeatureInitialized(m_itemName);
         super.sell();
      }
      
      override public function detach() : void
      {
         FeatureMessagingManager.getInstance().unregisterFeatureInitialized(m_itemName);
         super.detach();
      }
      
      override public function onFinishPlace(transactionResult:Object = null) : void
      {
         super.onFinishPlace(transactionResult);
         m_alreadyOffboard = OffboardingManager.handleOffBoarding(this,m_alreadyOffboard);
         FeatureTrackingManager.instance.placement(getCreditsFeatureName());
      }
      
      public function get alreadyOffboarded() : Boolean
      {
         return m_alreadyOffboard;
      }
      
      public function set alreadyOffboarded(offboard:Boolean) : void
      {
         m_alreadyOffboard = offboard;
      }
      
      private function onDelayedOffboarding(event:FarmGameWorldEvent) : void
      {
         Global.world.removeEventListener(FarmGameWorldEvent.USER_CHANGED,this.onDelayedOffboarding);
         this.m_isDelayedOffboarding = false;
         m_alreadyOffboard = OffboardingManager.handleOffBoarding(this,m_alreadyOffboard);
      }
      
      override public function onUpdate(delta:Number) : void
      {
         super.onUpdate(delta);
         this.checkArrowIndicator();
      }
      
      override protected function replaceContent(newContent:DisplayObject, shouldRedrawMask:Boolean = false) : void
      {
         super.replaceContent(newContent,shouldRedrawMask);
         this.checkArrowIndicator();
      }
      
      public function needsOffBoardingAndReplacement() : Boolean
      {
         var deprecator:DeprecatorSettings = null;
         if(this.m_isOffboarded)
         {
            return true;
         }
         var needOffboarding:Boolean = false;
         var offBoard:Array = this.getOffBoardingData();
         if(offBoard != null && offBoard.hasOwnProperty("isOffBoard") && offBoard["isOffBoard"] == true)
         {
            deprecator = Global.farmGameSettingsManager.getDeprecatorSettings(this.getItemName());
            if(offBoard.hasOwnProperty("offboardReplaceDeco") || Boolean(offBoard.hasOwnProperty("forceOffboard") && offBoard["forceOffboard"] && Global.player.isDataLoaded && deprecator) && Boolean(deprecator.checkPrereqs()))
            {
               needOffboarding = true;
               this.m_isOffboarded = true;
            }
         }
         return needOffboarding;
      }
      
      public function getOffboardingReplacementResource() : MapResource
      {
         var replacementResource:MapResource = null;
         var deprecator:DeprecatorSettings = null;
         var offBoard:Array = this.getOffBoardingData();
         var level:int = this.getLevel();
         var resourceName:String = "";
         if(Boolean(level >= 0 && offBoard) && Boolean(offBoard["offboardReplaceDeco"] is Array) && level < (offBoard["offboardReplaceDeco"] as Array).length)
         {
            resourceName = offBoard["offboardReplaceDeco"][level];
            replacementResource = OffboardingManager.createReplacementResource(resourceName);
         }
         else
         {
            deprecator = Global.farmGameSettingsManager.getDeprecatorSettings(this.m_itemName);
            resourceName = "";
            if(deprecator != null)
            {
               resourceName = deprecator.getReplacement(level.toString());
            }
            if(resourceName != "")
            {
               replacementResource = OffboardingManager.createReplacementResource(resourceName);
            }
         }
         return replacementResource;
      }
      
      protected function checkArrowIndicator() : void
      {
         if(!this.m_showingArrow && !m_usingLoadingGraphic && !UI.isShowingPopup() && !Global.worldManager.isVisiting())
         {
            if(this.canShowPreOffboardArrow())
            {
               m_arrow = this.generatePreOffBoardingArrowIndicator();
               m_nullArrow = false;
            }
            else
            {
               m_nullArrow = true;
            }
            if(m_arrow != null && m_nullArrow == false && m_displayObject != null)
            {
               m_arrow.visible = true;
               (m_displayObject as Sprite).addChild(m_arrow);
               this.setArrowPosition();
               this.m_showingArrow = true;
            }
         }
      }
      
      protected function generatePreOffBoardingArrowIndicator() : DisplayObject
      {
         var result:ArrowIndicatorWindow = null;
         var text:String = "";
         var icon:String = this.getItem().iconRelativeUrl;
         var offBoard:Array = this.getOffBoardingData();
         if(offBoard.hasOwnProperty("timeLeftText"))
         {
            text = offBoard["timeLeftText"] + " ";
            text += ZLocUtils.t("Dialogs",ZLocUtils.getExistingLocalizationKey("Dialogs",getCreditsFeatureName() + "_Offboarding_Body","basket_Offboarding_Body"),{"item":ZLocUtils.tk_pk_asTitle(this.getItemFriendlyName())});
         }
         else
         {
            text += ZLocUtils.t("Dialogs",ZLocUtils.getExistingLocalizationKey("Dialogs",getCreditsFeatureName() + "_PostParty_Body","basket_PostParty_Body"),{"item":ZLocUtils.tk_pk_asTitle(this.getItemFriendlyName())});
         }
         return new CraftingArrowIndicatorWindow(icon,text,null,false,true);
      }
      
      protected function canShowPreOffboardArrow() : Boolean
      {
         var lastShown:int = 0;
         var featureFrequency:int = 0;
         var currentTime:int = 0;
         var result:Boolean = false;
         var offBoard:Array = this.getOffBoardingData();
         var featureFlag:String = null;
         if(offBoard != null && offBoard.hasOwnProperty("isPreOffBoard") && offBoard["isPreOffBoard"] == true)
         {
            featureFlag = this.m_creditsFeatureName + "_preOffboard_countdown";
            lastShown = Global.player.getFeatureLastShown(featureFlag);
            featureFrequency = Global.farmGameSettingsManager.getNumber(this.m_creditsFeatureName + "PreOffboardCountdownFeatureFrequency",86400);
            currentTime = GlobalEngine.serverTime / 1000;
            if(currentTime > lastShown + featureFrequency)
            {
               Global.player.setFeatureLastShown(featureFlag,currentTime,true);
               result = true;
            }
         }
         else if(offBoard != null && offBoard.hasOwnProperty("isOffBoard") && offBoard["isOffBoard"] == true)
         {
            featureFlag = this.m_creditsFeatureName + "_offboard";
            lastShown = Global.player.getFeatureLastShown(featureFlag);
            featureFrequency = Global.farmGameSettingsManager.getNumber(this.m_creditsFeatureName + "OffboardFeatureFrequency",86400);
            currentTime = GlobalEngine.serverTime / 1000;
            if(currentTime > lastShown + featureFrequency)
            {
               Global.player.setFeatureLastShown(featureFlag,currentTime,true);
               result = true;
            }
         }
         return result;
      }
      
      override protected function setArrowPosition() : void
      {
         var arrowOffsets:Array = null;
         var curArrowOffset:Number = NaN;
         var arrowOffset:Object = null;
         if(this.m_arrowPositionSet == false)
         {
            m_arrow.x = ARROW_X_OFFSET;
            m_arrow.y = ARROW_Y_OFFSET;
            arrowOffsets = new Array();
            arrowOffsets = Global.farmGameSettingsManager.getBuildingArrowOffsets(getCreditsFeatureName());
            if(null != arrowOffsets)
            {
               for(curArrowOffset = 0; curArrowOffset < arrowOffsets.length; curArrowOffset++)
               {
                  arrowOffset = arrowOffsets[curArrowOffset];
                  if(arrowOffset.name == "xOffset")
                  {
                     m_arrow.x = arrowOffset.value;
                  }
                  if(arrowOffset.name == "yOffset")
                  {
                     m_arrow.y = arrowOffset.value;
                  }
               }
            }
            this.m_arrowPositionSet = true;
         }
      }
      
      protected function buildCreditFarmItems(item:FarmItem) : void
      {
         var creditFarmItem:FarmItem = null;
         var creditItemsArr:Array = null;
         var creditItemDS:BaseDataSource = null;
         var creditItem:XML = null;
         if(this.m_creditFarmItems == null)
         {
            this.m_hasBuyableCreditItems = false;
            this.m_hasGiftableCreditItems = false;
            this.m_creditFarmItems = new Array();
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_shouldCheckCreditItemDates = item.getBoolFromDataSource("rewardCreditsBuilding","creditItems","checkCreditItemDates");
               creditItemsArr = item.getArrayFromDataSource("rewardCreditsBuilding","creditItems","creditIte");
               for each(creditItemDS in creditItemsArr)
               {
                  creditFarmItem = Global.farmGameSettingsManager.getFarmItemByCode(creditItemDS.getString("code"));
                  if(creditFarmItem)
                  {
                     if(creditFarmItem.checkDateGate())
                     {
                        if(creditFarmItem.checkExperimentGate())
                        {
                           this.addCreditFarmItem(creditFarmItem);
                        }
                     }
                  }
               }
            }
            else
            {
               this.m_shouldCheckCreditItemDates = String(item.xml.rewardCreditsBuilding.creditItems.@checkCreditItemDates) == "true";
               for each(creditItem in item.xml.rewardCreditsBuilding.creditItems.creditItem)
               {
                  creditFarmItem = Global.farmGameSettingsManager.getFarmItemByCode(String(creditItem.@code));
                  if(creditFarmItem)
                  {
                     if(creditFarmItem.checkDateGate())
                     {
                        if(creditFarmItem.checkExperimentGate())
                        {
                           this.addCreditFarmItem(creditFarmItem);
                        }
                     }
                  }
               }
            }
         }
      }
      
      protected function addCreditFarmItem(creditFarmItem:FarmItem) : void
      {
         this.m_creditFarmItems.push(creditFarmItem);
         if(creditFarmItem.buyable)
         {
            this.m_hasBuyableCreditItems = true;
         }
         if(creditFarmItem.giftable)
         {
            this.m_hasGiftableCreditItems = true;
         }
      }
      
      override public function onBuildComplete(result:Object) : void
      {
         super.onBuildComplete(result);
         if(this.hasFirstTimePlaceFeed() && !Global.player.getSeenFlag(this.getFirstTimePlacedFlagName()))
         {
            if(result)
            {
               this.m_lastRewardUrl = result["rewardUrl"] ? result["rewardUrl"] : null;
               this.m_lastRewardCode = result["rewardCode"] ? result["rewardCode"] : null;
            }
            this.showFirstTimePlacePrompt();
         }
         else if(this.hasStartFeed())
         {
            this.showStartFeedPrompt();
         }
         else
         {
            this.displayStorageDialog();
         }
      }
      
      override public function onStoreComplete(result:Object) : void
      {
         this.seedHasSeenRedeemItemNowPrompt();
         super.onStoreComplete(result);
         this.processCreditsGainedResult(result);
      }
      
      override public function addMultipleCredits(creditResource:VirtualStorageDecoration, creditCount:int = 1, isGift:Boolean = true) : Boolean
      {
         var creditsAdded:Boolean = false;
         if(!m_alreadyOffboard)
         {
            this.seedHasSeenRedeemItemNowPrompt();
            creditsAdded = super.addMultipleCredits(creditResource,creditCount,isGift);
         }
         return creditsAdded;
      }
      
      override public function onAddMultipleCreditsComplete(result:Object) : void
      {
         super.onAddMultipleCreditsComplete(result);
         this.processCreditsGainedResult(result);
      }
      
      override public function displayStorageDialog(defaultAction:String = "") : void
      {
         var swfUrl:String = null;
         var showWhatIsThis:Boolean = false;
         var farmItem:FarmItem = null;
         var dialogName:String = null;
         var dialogClass:Class = null;
         if(this.needsOffBoardingAndReplacement())
         {
            return;
         }
         var data:XML = this.getBuildingCreditsXml();
         if(data)
         {
            swfUrl = this.getLookInsideDialogSwfUrl();
            showWhatIsThis = this.getShowWhatIsThis();
            farmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_buildingType);
            if(farmItem.dialogName != "")
            {
               dialogName = farmItem.dialogName;
               dialogClass = getDefinitionByName("Widgets.Windows.HolidayBasketWindows." + dialogName) as Class;
               UI.displayPopup(new dialogClass(this,m_creditsFeatureName,swfUrl,showWhatIsThis,this.m_showRedeemableItemOnLoad));
            }
            else
            {
               UI.displayStorageDialog(new RewardCreditsBuildingDialog(this,m_creditsFeatureName,swfUrl,showWhatIsThis,false,this.m_showRedeemableItemOnLoad));
            }
            this.m_showRedeemableItemOnLoad = null;
            FeatureTrackingManager.instance.uiOpen(getCreditsFeatureName());
         }
      }
      
      override public function addItem(resource:MapResource, fromStorage:int = 0, isGift:Boolean = false, sendStoreItem:Boolean = true, force:Boolean = false) : Boolean
      {
         var itemAdded:Boolean = false;
         if(!m_alreadyOffboard)
         {
            itemAdded = super.addItem(resource,fromStorage,isGift,sendStoreItem,force);
         }
         return itemAdded;
      }
      
      override public function showMenu() : void
      {
         var hasRewardsCreditBuilding:Boolean = false;
         var disableDate:String = null;
         var endTime:Number = NaN;
         var itemPK:String = null;
         var askCreditsText:String = null;
         var sendCreditsText:String = null;
         var buyCreditsText:String = null;
         if(this.getItem())
         {
            hasRewardsCreditBuilding = false;
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               hasRewardsCreditBuilding = getItem().hasPropertyInDataSource("rewardCreditsBuilding");
            }
            else
            {
               hasRewardsCreditBuilding = this.getItem().xml.hasOwnProperty("rewardCreditsBuilding");
            }
            this.buildCreditFarmItems(this.getItem());
         }
         if(Global.experimentManager.getExperimentVariant("fv_" + this.getCreditsFeatureName()) != 0)
         {
            disableDate = Global.farmGameSettingsManager.getString(this.getCreditsFeatureName() + "AskSendDisableDate");
            endTime = FarmGameUtil.synchronizedDateToNumber(disableDate);
            if(GlobalEngine.serverTime < endTime)
            {
               if(!this.isAskCreditsContextMenuDisabled())
               {
                  askCreditsText = this.askForCreditsButtonText();
                  if(askCreditsText != "" && (!this.m_shouldCheckCreditItemDates || this.m_hasGiftableCreditItems) && !this.isAtFeatureCreditLimit())
                  {
                     m_menuItems.push({
                        "label":askCreditsText,
                        "action":this.ASK_FOR_CREDITS
                     });
                  }
               }
               if(!this.isSendCreditsContextMenuDisabled())
               {
                  sendCreditsText = "";
                  itemPK = RewardCreditsBuilding.getCreditItemFriendlyName(this.getCreditsFeatureName());
                  if("" != itemPK && ZLocUtils.isObject(itemPK))
                  {
                     sendCreditsText = ZLocUtils.t("RewardCreditsBuilding","SendCredits",{"item":ZLocUtils.tk_pk(itemPK)});
                  }
                  if(sendCreditsText != "" && (!this.m_shouldCheckCreditItemDates || this.m_hasGiftableCreditItems))
                  {
                     m_menuItems.push({
                        "label":sendCreditsText,
                        "action":this.SEND_CREDITS
                     });
                  }
               }
            }
            if(!this.isBuyCreditsMenuItemDisabled())
            {
               itemPK = RewardCreditsBuilding.getCreditItemFriendlyName(this.getCreditsFeatureName());
               if(this.getCreditsToBuyFromContextMenu() > 0)
               {
                  buyCreditsText = "";
                  itemPK = RewardCreditsBuilding.getCreditItemFriendlyName(this.getCreditsFeatureName());
                  if("" != itemPK && ZLocUtils.isObject(itemPK))
                  {
                     buyCreditsText = ZLocUtils.t("RewardCreditsBuilding","BuyCredits",{"item":ZLocUtils.tk_pk(itemPK)});
                  }
                  if(buyCreditsText != "" && (!this.m_shouldCheckCreditItemDates || this.m_hasBuyableCreditItems) && !this.isAtFeatureCreditLimit())
                  {
                     m_menuItems.push({
                        "label":buyCreditsText,
                        "action":this.BUY_CREDITS
                     });
                  }
               }
            }
         }
         super.showMenu();
      }
      
      protected function isBuyCreditsMenuItemDisabled() : Boolean
      {
         return this.needsOffBoardingAndReplacement();
      }
      
      protected function isAskCreditsContextMenuDisabled() : Boolean
      {
         return !this.isAllowedToSendR4R() && !this.isOutsideAskPostFeedThrottle();
      }
      
      protected function isSendCreditsContextMenuDisabled() : Boolean
      {
         return !this.isAllowedToSendR4R();
      }
      
      protected function getCreditsToBuyFromContextMenu() : int
      {
         var credits:int = 0;
         var walletSize:int = Global.player.cash;
         if(walletSize >= 70)
         {
            credits = 20;
         }
         else if(walletSize >= 20 && walletSize < 70)
         {
            credits = 15;
         }
         else if(walletSize >= 15 && walletSize < 20)
         {
            credits = 10;
         }
         else
         {
            credits = 5;
         }
         return credits;
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         var rewardCreditNames:Array = null;
         var treatPackSize:String = null;
         var messageText:String = null;
         var imageSize:Number = NaN;
         var centerIconUrl:String = null;
         var dialog:GenericXMLDialog = null;
         var firstUnderScoreIndex:int = 0;
         var secondUnderScoreIndex:int = 0;
         var ticketPrefix:String = null;
         if(Boolean(m_arrow) && this.m_showingArrow)
         {
            m_arrow.visible = false;
            this.m_showingArrow = false;
         }
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            switch(item.action)
            {
               case this.BUY_CREDITS:
                  FarmStatsManager.count("RewardCreditsBuilding","BuyCredits","accept");
                  rewardCreditNames = Global.storageSettings.getStorageItems(m_creditsFeatureName.toLowerCase());
                  treatPackSize = "_" + this.getCreditsToBuyFromContextMenu().toString() + "pack";
                  this.m_creditsToBuy = Global.farmGameSettingsManager.getFarmItemByName(rewardCreditNames[0].name + treatPackSize);
                  if(!this.m_creditsToBuy)
                  {
                     firstUnderScoreIndex = int(rewardCreditNames[0].name.indexOf("_"));
                     secondUnderScoreIndex = int(rewardCreditNames[0].name.indexOf("_",firstUnderScoreIndex + 1));
                     ticketPrefix = rewardCreditNames[0].name.substring(0,secondUnderScoreIndex);
                     this.m_creditsToBuy = Global.farmGameSettingsManager.getFarmItemByName(ticketPrefix + treatPackSize);
                  }
                  messageText = ZLocUtils.t("Dialogs","ConstructionBuilding_BuyConfirmation",{
                     "item":ZLocUtils.tk_pk(this.m_creditsToBuy.friendlyName),
                     "cashQuantity":this.m_creditsToBuy.cash
                  });
                  imageSize = 100;
                  centerIconUrl = Global.reverseAssetURL(this.m_creditsToBuy.icon,2);
                  dialog = new GenericXMLDialog(null,"",null,centerIconUrl,imageSize,imageSize,messageText,this.onBuyCreditsConfirmation,false,ZLocUtils.t("Dialogs","Accept"),null,ZLocUtils.t("Dialogs","Cancel"),null,null,GenericXMLDialog.NUM_DIALOG_WIDTH_MEDIUM);
                  UI.displayPopup(dialog,false);
                  break;
               case this.SEND_CREDITS:
                  FarmStatsManager.count("RewardCreditsBuilding","SendCredits","accept");
                  UI.displayPopup(new CustomFreeGiftSelectionWindow(this.m_creditItemNames));
                  break;
               case this.ASK_FOR_CREDITS:
                  this.askForCredits();
                  break;
               default:
                  super.onMenuClick(event);
            }
         }
      }
      
      public function isAllowedToPostAskFeed(creditItemName:String) : Boolean
      {
         var creditTypeData:XML = null;
         var result:Boolean = false;
         var variant:Number = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_BASKET_ASK_FEED);
         if(variant == Experiments.VARIANT_EXPERIMENT_FLASH_BASKET_ASK_FEED_AUTOPOP_OFF || variant == Experiments.VARIANT_EXPERIMENT_FLASH_BASKET_ASK_FEED_AUTOPOP_ON || variant == Experiments.VARIANT_EXPERIMENT_FLASH_BASKET_ASK_FEED_MAIN)
         {
            if(getId() < WorldIdUtil.TEMP_ID_START || getId() > WorldIdUtil.TEMP_ID_END)
            {
               if(m_creditsBuildingXml.creditType)
               {
                  creditTypeData = m_creditsBuildingXml.creditType.(@name == creditItemName)[0];
                  if(Boolean(creditTypeData) && Boolean(creditTypeData.hasOwnProperty("@enableFeed")) && creditTypeData.@enableFeed == "true")
                  {
                     result = true;
                  }
               }
            }
         }
         return result;
      }
      
      public function isAllowedToSendR4R(creditItemName:String = null) : Boolean
      {
         var creditTypeData:XML = null;
         var result:Boolean = true;
         var variant:Number = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_BASKET_ASK_R4R);
         if(variant == Experiments.VARIANT_EXPERIMENT_FLASH_BASKET_ASK_R4R_DISABLE)
         {
            if(Boolean(Global.flashHotParams["FIX_FARM_69875"]) || (getId() < WorldIdUtil.TEMP_ID_START || getId() > WorldIdUtil.TEMP_ID_END))
            {
               if(m_creditsBuildingXml.creditType)
               {
                  if(creditItemName)
                  {
                     creditTypeData = m_creditsBuildingXml.creditType.(@name == creditItemName)[0];
                  }
                  else
                  {
                     creditTypeData = m_creditsBuildingXml.creditType[0];
                  }
                  if(Boolean(creditTypeData) && Boolean(creditTypeData.hasOwnProperty("@enableR4R")) && creditTypeData.@enableR4R == "false")
                  {
                     result = false;
                  }
               }
            }
         }
         return result;
      }
      
      public function isOutsideAskPostFeedThrottle() : Boolean
      {
         var throttleSeconds:int = Global.farmGameSettingsManager.getInt(m_creditsFeatureName + "_askForCreditsFeedThrottle");
         if(throttleSeconds == 0)
         {
            throttleSeconds = Global.farmGameSettingsManager.getInt("rewardCreditsBuilding_askForCreditsFeedThrottle");
         }
         return GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND >= Global.player.getFeatureLastShown(m_creditsFeatureName + "postForCredits") + throttleSeconds;
      }
      
      public function askForCredits(creditItemName:String = null, windowCallback:Function = null) : void
      {
         var shouldPostFeed:Boolean = false;
         if(this.isOutsideAskPostFeedThrottle())
         {
            if(creditItemName)
            {
               if(this.isAllowedToPostAskFeed(creditItemName))
               {
                  shouldPostFeed = true;
               }
            }
            else
            {
               creditItemName = this.findPostableCredit();
               if(creditItemName)
               {
                  shouldPostFeed = true;
               }
            }
         }
         if(shouldPostFeed)
         {
            FarmStatsManager.count(getCreditsFeatureName(),"ask_tickets","button_click");
            TransactionManager.addTransaction(new TWorldObjectFeedTransaction(this,"createAskFriendReward",this.generateAskFriendRewardCallback(creditItemName,windowCallback),[creditItemName]),true);
         }
         else if(this.isAllowedToSendR4R())
         {
            if(creditItemName == null)
            {
               if(this.m_creditItemNames.length > 0)
               {
                  this.forceAskForCreditsRequestChannel(this.m_creditItemNames[0],MFSConstants.SOURCE_UI);
                  FeatureTrackingManager.instance.sendR4R(m_creditsFeatureName);
               }
            }
            else
            {
               this.forceAskForCreditsRequestChannel(creditItemName,MFSConstants.SOURCE_UI);
               FeatureTrackingManager.instance.sendR4R(m_creditsFeatureName);
            }
            if(windowCallback != null)
            {
               windowCallback();
            }
         }
      }
      
      private function findPostableCredit() : String
      {
         var creditType:String = null;
         var result:String = null;
         for each(creditType in this.m_creditItemNames)
         {
            if(this.isAllowedToPostAskFeed(creditType))
            {
               result = creditType;
               break;
            }
         }
         return result;
      }
      
      private function generateAskFriendRewardCallback(creditItemName:String, completionCallback:Function = null) : Function
      {
         return function(result:Object):void
         {
            if(Boolean(result) && result["postSuccessful"] == true)
            {
               FarmStatsManager.count(getCreditsFeatureName(),"ask_tickets","feed_successful");
               Global.player.setFeatureLastShown(m_creditsFeatureName + "postForCredits",GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,true);
               FeatureTrackingManager.instance.postFeed(m_creditsFeatureName);
            }
            else if(result)
            {
               FarmStatsManager.count(getCreditsFeatureName(),"ask_tickets","feed_failed");
            }
            if((Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_BASKET_ASK_FEED) == Experiments.VARIANT_EXPERIMENT_FLASH_BASKET_ASK_FEED_AUTOPOP_ON || Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_BASKET_ASK_FEED) == Experiments.VARIANT_EXPERIMENT_FLASH_BASKET_ASK_FEED_MAIN) && Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_BASKET_ASK_R4R) != Experiments.VARIANT_EXPERIMENT_FLASH_BASKET_ASK_R4R_DISABLE)
            {
               forceAskForCreditsRequestChannel(creditItemName,MFSConstants.SOURCE_AUTOPOP);
            }
            if(completionCallback != null)
            {
               completionCallback(result);
            }
         };
      }
      
      public function askForCreditsButtonText(creditItemName:String = null) : String
      {
         var lookupKey:String = null;
         var result:String = "";
         var allowedToPost:Boolean = false;
         if(this.isOutsideAskPostFeedThrottle())
         {
            if(creditItemName)
            {
               if(this.isAllowedToPostAskFeed(creditItemName))
               {
                  allowedToPost = true;
               }
            }
            else
            {
               creditItemName = this.findPostableCredit();
               if(creditItemName)
               {
                  allowedToPost = true;
               }
            }
         }
         var allowedToR4R:Boolean = true;
         if(Boolean(creditItemName) && !this.isAllowedToSendR4R(creditItemName))
         {
            allowedToR4R = false;
         }
         else if(this.m_creditItemNames.length > 0)
         {
            creditItemName = this.findPostableCredit();
            if(!this.isAllowedToSendR4R(creditItemName))
            {
               allowedToR4R = false;
            }
         }
         if(allowedToR4R)
         {
            lookupKey = allowedToPost ? "PostFeedForCredits" : "AskForCredits";
         }
         else
         {
            lookupKey = allowedToPost ? "PostFeedForCredits" : "Waiting";
         }
         var strPK:String = "RewardCreditsBuilding:AskForCredits";
         var itemPK:String = RewardCreditsBuilding.getCreditItemFriendlyName(this.getCreditsFeatureName());
         if("" != itemPK && ZLocUtils.isObject(itemPK))
         {
            strPK = RewardCreditsBuilding.getLocalizedKey(this.getCreditsFeatureName(),lookupKey);
            result = ZLocUtils.t_pk(strPK,null,{"item":ZLocUtils.tk_pk(itemPK)});
         }
         else
         {
            result = ZLocUtils.t_pk(strPK);
         }
         return result;
      }
      
      private function forceAskForCreditsRequestChannel(creditItemName:String, source:String) : void
      {
         MFSRequestManager.getInstance().makeAskCreditsRequest(getCreditsFeatureName(),source,"RewardCreditsBuilding","AskForCredits","accept",creditItemName);
      }
      
      public function getTicketStrings() : String
      {
         var ticketName:String = null;
         var result:String = "";
         var firstItem:Boolean = true;
         for each(ticketName in this.m_creditItemNames)
         {
            if(firstItem)
            {
               result = ticketName;
               firstItem = false;
            }
            else
            {
               result += "," + ticketName;
            }
         }
         return result;
      }
      
      private function onBuyCreditsConfirmation(evt:GenericPopupEvent) : void
      {
         if(evt.button == GenericPopup.ACCEPT && this.m_creditsToBuy != null)
         {
            if(Global.player.canBuyCash(this.m_creditsToBuy.cash,true))
            {
               Global.world.addGameMode(new GMCreditsBuildingItemPlace(this.m_creditsToBuy.name,false),false);
            }
         }
      }
      
      protected function getNeighborCreditsReceived(neighbor:Friend) : uint
      {
         return neighbor.getFeatureCreditsReceived(m_creditsFeatureName);
      }
      
      protected function getNeighborMultiTypeCreditsReceived(neighbor:Friend) : Object
      {
         var type:String = null;
         var result:Object = {};
         if(m_creditTypes.length > 1)
         {
            for(type in creditTypes)
            {
               result[type] = neighbor.getFeatureCreditsReceived(type);
            }
         }
         else
         {
            result[m_creditsFeatureName] = neighbor.getFeatureCreditsReceived(m_creditsFeatureName);
         }
         return result;
      }
      
      protected function getCombinedCreditsCount(credits:Object) : uint
      {
         var type:String = null;
         var result:uint = 0;
         for(type in credits)
         {
            result += credits[type];
         }
         return result;
      }
      
      protected function getMinCreditsToPassNeighbor() : uint
      {
         return Global.farmGameSettingsManager.getInt(m_creditsFeatureName + "MinCreditsToPassNeighbor");
      }
      
      public function getCreditItemNames() : Array
      {
         return this.m_creditItemNames;
      }
      
      public function getFriendRewardTypes() : Array
      {
         return this.m_friendRewardTypes;
      }
      
      public function hasFriendRewardType(typeName:String) : Boolean
      {
         var type:String = null;
         var result:Boolean = false;
         if(this.m_friendRewardTypes)
         {
            for each(type in this.m_friendRewardTypes)
            {
               if(type == typeName)
               {
                  result = true;
                  break;
               }
            }
         }
         return result;
      }
      
      public function getBundlePrefix() : String
      {
         return m_creditsFeatureName;
      }
      
      public function getBuildingImageUrl(sImageName:String) : String
      {
         var result:String = null;
         if(Boolean(m_creditsBuildingXml) && Boolean(m_creditsBuildingXml.image.(@name == sImageName)))
         {
            result = m_creditsBuildingXml.image.(@name == sImageName).@url;
         }
         return result;
      }
      
      public function getDialogSideIconUrl() : String
      {
         return this.getBuildingImageUrl("icon");
      }
      
      public function getLookInsideDialogSwfUrl() : String
      {
         return this.getBuildingImageUrl("lookInsideDialog");
      }
      
      public function getShowWhatIsThis() : Boolean
      {
         var showWhatIsThis:Boolean = false;
         if(!Global.player.getSeenFlag(m_creditsFeatureName + "Open"))
         {
            Global.player.setSeenFlag(m_creditsFeatureName + "Open");
            showWhatIsThis = true;
         }
         return showWhatIsThis;
      }
      
      public function getIntervalDialogIconUrl() : String
      {
         return this.getBuildingImageUrl("intervalIcon");
      }
      
      public function getLevelIconUrl() : String
      {
         var iconUrl:String = m_item.iconRelativeUrl;
         var firstUnderScoreIndex:int = iconUrl.indexOf("_");
         var iconPrefix:String = iconUrl.substring(0,iconUrl.indexOf("_",firstUnderScoreIndex + 1));
         return iconPrefix + "_" + getCurrentSuffix() + "_icon.png";
      }
      
      public function getIntervalFeedIconUrl() : String
      {
         return this.getBuildingImageUrl("feedIcon");
      }
      
      public function getHowDoesThisWorkImageRelUrl() : String
      {
         return this.getBuildingImageUrl("howDoesThisWork");
      }
      
      public function getChangeFeedIconUrl() : String
      {
         return this.getLevelIconUrl();
      }
      
      public function getPassNeighborFeedIconUrl() : String
      {
         return this.getIntervalFeedIconUrl();
      }
      
      public function getSubcreditsTradeFeedUrl() : String
      {
         return "";
      }
      
      protected function getNeighborPassFeedFlagName() : String
      {
         return m_creditsFeatureName + TOKEN_PASS_NEIGHBOR;
      }
      
      public function getLevelStateChange() : Number
      {
         var stateIndex:Number = NaN;
         var totalCreditsReceived:Number = getTotalCreditsReceived();
         var levelCredits:Array = getLevelCredits();
         var stateChanges:Array = this.stateChangeLevels;
         var levelStateChange:Number = 0;
         for(var index:Number = 0; index < levelCredits.length; index++)
         {
            if(totalCreditsReceived >= levelCredits[index])
            {
               for(stateIndex = 0; stateIndex < stateChanges.length; stateIndex++)
               {
                  if(index >= stateChanges[stateIndex])
                  {
                     levelStateChange = stateIndex + 1;
                  }
               }
            }
         }
         return levelStateChange;
      }
      
      protected function getNextRedeemReward() : Object
      {
         var redeemItemData:Object = null;
         var costInfo:CreditCostInfo = null;
         var redeemItems:Array = Global.farmGameSettingsManager.getBuildingRewardItems(this.m_creditsFeatureName);
         var rewardObject:Object = {};
         for(var index:Number = 0; index < redeemItems.length; index++)
         {
            redeemItemData = redeemItems[index];
            costInfo = this.getRedeemItemCostInfo(redeemItemData.cost);
            if(!costInfo.canAfford)
            {
               rewardObject.itemName = redeemItemData.name;
               rewardObject.creditsNeeded = costInfo.costToComplete;
               break;
            }
         }
         return rewardObject;
      }
      
      public function getRedeemItemByName(paramName:String) : Object
      {
         var redeemItemData:Object = null;
         var redeemItems:Array = Global.farmGameSettingsManager.getBuildingRewardItems(this.m_creditsFeatureName);
         var result:Object = null;
         for(var curItem:Number = 0; curItem < redeemItems.length; curItem++)
         {
            redeemItemData = redeemItems[curItem];
            if(redeemItemData.name == paramName)
            {
               result = redeemItemData;
               break;
            }
         }
         return result;
      }
      
      public function getRedeemItemByIndex(indexInt:int) : Object
      {
         var redeemItemData:Object = null;
         var redeemItems:Array = Global.farmGameSettingsManager.getBuildingRewardItems(this.m_creditsFeatureName);
         var result:Object = null;
         for(var curItem:Number = 0; curItem < redeemItems.length; curItem++)
         {
            redeemItemData = redeemItems[curItem];
            if(redeemItemData.index == indexInt)
            {
               result = redeemItemData;
               break;
            }
         }
         return result;
      }
      
      public function getTotalCreditsNeededToRedeemItemByIndex(indexInt:int) : Object
      {
         var redeemItemData:Object = null;
         var creditCost:Object = null;
         var creditType:String = null;
         var redeemItems:Array = Global.farmGameSettingsManager.getBuildingRewardItems(this.m_creditsFeatureName);
         var foundOne:Boolean = false;
         var result:Object = {};
         for(var curItem:Number = 0; curItem < redeemItems.length; curItem++)
         {
            redeemItemData = redeemItems[curItem];
            if(redeemItemData.hasOwnProperty("index") && redeemItemData.index <= indexInt)
            {
               creditCost = redeemItemData.cost;
               for(creditType in creditCost)
               {
                  if(result[creditType])
                  {
                     result[creditType] += creditCost[creditType];
                  }
                  else
                  {
                     result[creditType] = creditCost[creditType];
                  }
               }
               if(foundOne == false)
               {
                  foundOne = true;
               }
            }
         }
         return foundOne ? result : null;
      }
      
      public function getRedeemItemTotalCostInfo(index:int) : CreditCostInfo
      {
         var creditType:String = null;
         var result:CreditCostInfo = null;
         var amountNeeded:int = 0;
         var creditTypeToCheck:String = null;
         var missingAmount:int = 0;
         var totalCreditsNeededToUnlock:Object = this.getTotalCreditsNeededToRedeemItemByIndex(index);
         var totalReceivedCredits:Object = getMultiTypeCredits(true);
         var missingCredits:Dictionary = new Dictionary();
         var costToComplete:int = 0;
         var totalCreditCost:int = 0;
         for(creditType in totalCreditsNeededToUnlock)
         {
            amountNeeded = int(totalCreditsNeededToUnlock[creditType]);
            totalCreditCost += amountNeeded;
            creditTypeToCheck = creditType == "feature" ? m_creditsFeatureName : creditType;
            if(!totalReceivedCredits[creditTypeToCheck])
            {
               costToComplete += amountNeeded;
               missingCredits[creditTypeToCheck] = amountNeeded;
            }
            else if(totalReceivedCredits[creditTypeToCheck] < amountNeeded)
            {
               missingAmount = amountNeeded - totalReceivedCredits[creditTypeToCheck];
               costToComplete += missingAmount;
               missingCredits[creditTypeToCheck] = missingAmount;
            }
         }
         return new CreditCostInfo(costToComplete == 0,missingCredits,totalCreditCost,costToComplete);
      }
      
      public function getRedeemItemCostInfo(costData:Object) : CreditCostInfo
      {
         var creditType:String = null;
         var result:CreditCostInfo = null;
         var amountNeeded:int = 0;
         var creditTypeToCheck:String = null;
         var missingAmount:int = 0;
         var currentCredits:Object = getMultiTypeCredits(false);
         var missingCredits:Dictionary = new Dictionary();
         var costToComplete:int = 0;
         var totalCreditCost:int = 0;
         for(creditType in costData)
         {
            amountNeeded = int(costData[creditType]);
            creditTypeToCheck = creditType == "feature" ? m_creditsFeatureName : creditType;
            totalCreditCost += amountNeeded;
            if(!currentCredits[creditTypeToCheck])
            {
               costToComplete += amountNeeded;
               missingCredits[creditTypeToCheck] = amountNeeded;
            }
            else if(currentCredits[creditTypeToCheck] < amountNeeded)
            {
               missingAmount = amountNeeded - currentCredits[creditTypeToCheck];
               costToComplete += missingAmount;
               missingCredits[creditTypeToCheck] = missingAmount;
            }
         }
         return new CreditCostInfo(costToComplete == 0,missingCredits,totalCreditCost,costToComplete);
      }
      
      public function getOffBoardingData() : Array
      {
         return Global.farmGameSettingsManager.getBuildingOffBoardData(this.m_creditsFeatureName);
      }
      
      public function getTitle() : String
      {
         var index:uint = uint(getLevel());
         return getLocalizedKey(m_creditsFeatureName,"Level_" + index);
      }
      
      protected function getCreditsRewardInterval() : int
      {
         return Global.farmGameSettingsManager.getInt(m_creditsFeatureName + "CreditsRewardInterval");
      }
      
      protected function showIntervalFeedPrompt() : void
      {
         var strPK:String = RewardCreditsBuilding.getLocalizedKey(getCreditsFeatureName(),TOKEN_INTERVAL + "Body");
         var dialogText:String = this.getDialogText(strPK);
         var imageSize:Number = 100;
         var iconUrl:String = this.getDialogSideIconUrl();
         var centerIconUrl:String = this.getLevelIconUrl();
         var dialog:GenericXMLDialog = new GenericXMLDialog(ZLocUtils.t("Dialogs","Congratulations"),"",null,centerIconUrl,imageSize,imageSize,dialogText,this.onCloseFeedPrompt,true,ZLocUtils.t("Dialogs","GenericShareButton"),null,null,null,[imageSize.toString(),imageSize.toString(),iconUrl],GenericXMLDialog.NUM_DIALOG_WIDTH_MEDIUM,"RewardCreditsBuildingFeedPrompt");
         dialog.setTrackerKey("feed_" + getLocKeyPrefix() + TOKEN_INTERVAL);
         UI.displayPopup(dialog,false);
         this.m_creditIntervalDialogOpen = true;
         FarmStatsManager.count("dialog",m_creditsFeatureName + "-" + TOKEN_INTERVAL,StatsTrackingConstants.DIALOG_STATS_VIEW_PHYLUM);
      }
      
      protected function getDialogText(strPK:String) : String
      {
         var message:String = "";
         var basketPK:String = getBasketFriendlyName(getCreditsFeatureName());
         var itemPK:String = getCreditItemFriendlyName(getCreditsFeatureName());
         if("" != strPK)
         {
            if("" != basketPK && ZLocUtils.isObject(basketPK) && "" != itemPK && ZLocUtils.isObject(itemPK))
            {
               message = ZLocUtils.t_pk(strPK,null,{
                  "basket":ZLocUtils.tk_pk(basketPK),
                  "item":ZLocUtils.tk_pk(itemPK)
               });
            }
            else
            {
               message = ZLocUtils.t_pk(strPK);
            }
         }
         return message;
      }
      
      protected function getLocalizedStateChangeDialogText() : String
      {
         var levelPK:String = this.getTitle();
         var strPK:String = getLocalizedKey(getCreditsFeatureName(),TOKEN_STATE_CHANGE);
         var basketPK:String = getBasketFriendlyName(getCreditsFeatureName());
         var itemPK:String = getCreditItemFriendlyName(getCreditsFeatureName());
         var textStr:String = "";
         if("" != strPK && "" != levelPK)
         {
            if("" != basketPK && ZLocUtils.isObject(basketPK) && "" != itemPK && ZLocUtils.isObject(itemPK))
            {
               textStr = ZLocUtils.t_pk(strPK,null,{
                  "basket":ZLocUtils.tk_pk(basketPK),
                  "levelName":ZLocUtils.tk_pk_asTitle(levelPK),
                  "item":ZLocUtils.tk_pk(itemPK)
               });
            }
            else
            {
               textStr = ZLocUtils.t_pk(strPK,null,{"levelName":ZLocUtils.t_pk(levelPK)});
            }
         }
         return textStr;
      }
      
      protected function showStateChangeFeedPrompt() : void
      {
         var dialogText:String = this.getLocalizedStateChangeDialogText();
         var imageSize:Number = 100;
         var iconUrl:String = this.getDialogSideIconUrl();
         var centerIconUrl:String = this.getLevelIconUrl();
         var dialog:GenericXMLDialog = new GenericXMLDialog(ZLocUtils.t("Dialogs","Congratulations"),"",null,centerIconUrl,imageSize,imageSize,dialogText,this.onCloseFeedPrompt,true,ZLocUtils.t("Dialogs","GenericShareButton"),null,null,null,[imageSize.toString(),imageSize.toString(),iconUrl],GenericXMLDialog.NUM_DIALOG_WIDTH_MEDIUM,"RewardCreditsBuildingFeedPrompt");
         dialog.setTrackerKey("feed_" + getLocKeyPrefix() + TOKEN_STATE_CHANGE);
         UI.displayPopup(dialog,false);
         FarmStatsManager.count("dialog",m_creditsFeatureName + "-" + TOKEN_STATE_CHANGE,StatsTrackingConstants.DIALOG_STATS_VIEW_PHYLUM);
      }
      
      protected function getCenterIconVerticalDisplace() : int
      {
         return 0;
      }
      
      public function showPassNeighborFeedPrompt(neighborUid:String, rewardUrl:String) : void
      {
         var totalCreditsReceived:uint = 0;
         var neighbors:Array = null;
         var totalNeighbors:uint = 0;
         var ranking:uint = 0;
         var neighborIndex:uint = 0;
         var dialogText:String = null;
         var strPK:String = null;
         var itemPK:String = null;
         var dialog:GenericXMLDialog = null;
         var neighbor:Friend = null;
         var neighborCreditsReceived:uint = 0;
         this.m_lastRewardUrl = rewardUrl;
         this.m_friend = Global.friendManager.getFriendData(neighborUid);
         if(this.m_friend)
         {
            totalCreditsReceived = this.getCombinedCreditsCount(getMultiTypeCredits(true));
            neighbors = this.getNeighbors();
            totalNeighbors = neighbors.length;
            ranking = 1;
            for(neighborIndex = 0; neighborIndex < totalNeighbors; neighborIndex++)
            {
               neighbor = neighbors[neighborIndex];
               neighborCreditsReceived = this.getCombinedCreditsCount(this.getNeighborMultiTypeCreditsReceived(neighbor));
               if(neighborCreditsReceived > totalCreditsReceived)
               {
                  ranking++;
               }
            }
            this.m_passNeighborRank = ranking;
            dialogText = "";
            strPK = RewardCreditsBuilding.getLocalizedKey(getCreditsFeatureName(),TOKEN_PASS_NEIGHBOR + "Message");
            itemPK = RewardCreditsBuilding.getCreditItemFriendlyName(getCreditsFeatureName());
            if("" != strPK)
            {
               if("" != itemPK && ZLocUtils.isObject(itemPK))
               {
                  dialogText = ZLocUtils.t_pk(strPK,null,{
                     "item":ZLocUtils.tk_pk(itemPK),
                     "user":ZLocUtils.tn(this.m_friend.firstName,ZLocUtils.tg(this.m_friend.snUser.gender)),
                     "item_same":ZLocUtils.tk_pk(itemPK),
                     "number":ranking,
                     "quantityTotal":totalNeighbors + 1
                  });
               }
               else
               {
                  dialogText = ZLocUtils.t_pk(strPK,null,{
                     "user":ZLocUtils.tn(this.m_friend.firstName,ZLocUtils.tg(this.m_friend.snUser.gender)),
                     "number":ranking,
                     "quantityTotal":totalNeighbors + 1
                  });
               }
            }
            dialog = new GenericXMLDialog("","",null,null,NaN,NaN,dialogText,this.onCloseFeedPrompt,true,ZLocUtils.t("Dialogs","JustShare"),null,null,null,null,GenericXMLDialog.NUM_DIALOG_WIDTH_MEDIUM);
            dialog.setTrackerKey("feed_" + getLocKeyPrefix() + TOKEN_PASS_NEIGHBOR);
            UI.displayPopup(dialog,false,this.m_buildingType + "_PassNeighbor",true);
            FarmStatsManager.count("dialog",m_creditsFeatureName + "-" + TOKEN_PASS_NEIGHBOR,StatsTrackingConstants.DIALOG_STATS_VIEW_PHYLUM);
         }
      }
      
      protected function onCloseFeedPrompt(event:GenericPopupEvent) : void
      {
         var params:Object = null;
         var bundleId:String = null;
         var iconUrl:String = null;
         var rewardItem:FarmItem = null;
         if(GenericPopup.ACCEPT == event.button)
         {
            params = new Object();
            params.basketname = getBasketFriendlyName(m_creditsFeatureName);
            params.credititemname = getCreditItemFriendlyName(m_creditsFeatureName);
            params.credititemname_single = getCreditItemFriendlyName(m_creditsFeatureName);
            switch(this.m_lastRewardAction)
            {
               case CREDITS_REWARD_ACTION_STATE_CHANGE:
                  bundleId = this.getBundlePrefix() + BUNDLETOKEN_STATE_CHANGE;
                  iconUrl = Global.getAssetURL(this.getChangeFeedIconUrl());
                  params.ranktitle = this.getTitle();
                  params.rankcount = getTotalCreditsReceived();
                  this.setStateStat();
                  FarmStatsManager.count("dialog",m_creditsFeatureName + "-" + TOKEN_STATE_CHANGE,StatsTrackingConstants.DIALOG_STATS_SHARE_CLICK_PHYLUM);
                  break;
               case CREDITS_REWARD_ACTION_PASS_NEIGHBOR:
                  bundleId = this.getBundlePrefix() + TOKEN_PASS_NEIGHBOR;
                  iconUrl = Global.getAssetURL(this.getPassNeighborFeedIconUrl());
                  params.count = getTotalCreditsReceived();
                  params.rank = this.m_passNeighborRank;
                  params.totalneighbors = this.getNeighbors().length + 1;
                  params.friend = this.m_friend.firstName;
                  FarmStatsManager.count("dialog",m_creditsFeatureName + "-" + TOKEN_PASS_NEIGHBOR,StatsTrackingConstants.DIALOG_STATS_SHARE_CLICK_PHYLUM);
                  break;
               default:
                  bundleId = this.getBundlePrefix() + TOKEN_INTERVAL;
                  iconUrl = Global.getAssetURL(this.getIntervalFeedIconUrl());
                  FarmStatsManager.count("dialog",m_creditsFeatureName + "-" + TOKEN_INTERVAL,StatsTrackingConstants.DIALOG_STATS_SHARE_CLICK_PHYLUM);
            }
            params.images = [{
               "src":iconUrl,
               "href":"{SN_APP_URL}" + this.m_lastRewardUrl
            }];
            params.reward_link = this.m_lastRewardUrl;
            if(this.m_lastRewardCode)
            {
               rewardItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_lastRewardCode);
               if(rewardItem)
               {
                  params.rewardname = rewardItem.friendlyName;
               }
            }
            GlobalEngine.socialNetwork.publishFeedStory(bundleId,params,[],false);
         }
         else
         {
            TransactionManager.addTransaction(new TCancelFriendReward([this.m_lastRewardUrl]));
            switch(this.m_lastRewardAction)
            {
               case CREDITS_REWARD_ACTION_STATE_CHANGE:
                  FarmStatsManager.count("dialog",m_creditsFeatureName + "-" + TOKEN_STATE_CHANGE,StatsTrackingConstants.DIALOG_STATS_X_CLICK_PHYLUM);
                  break;
               case CREDITS_REWARD_ACTION_PASS_NEIGHBOR:
                  FarmStatsManager.count("dialog",m_creditsFeatureName + "-" + TOKEN_PASS_NEIGHBOR,StatsTrackingConstants.DIALOG_STATS_X_CLICK_PHYLUM);
                  break;
               default:
                  FarmStatsManager.count("dialog",m_creditsFeatureName + "-" + TOKEN_INTERVAL,StatsTrackingConstants.DIALOG_STATS_X_CLICK_PHYLUM);
            }
         }
         if(this.m_lastRewardAction == CREDITS_REWARD_ACTION_INTERVAL)
         {
            this.m_creditIntervalDialogOpen = false;
         }
      }
      
      protected function getBuildingCreditsXml() : XML
      {
         return Global.farmGameSettingsManager.getBuildingCreditsXml(m_creditsFeatureName);
      }
      
      public function hasMeterBreak() : Boolean
      {
         return this.getBuildingCreditsXml().@hasMeterBreak.toString() == "false" ? false : true;
      }
      
      protected function seedHasSeenRedeemItemNowPrompt() : void
      {
         var redeemItems:Array = null;
         var index:uint = 0;
         var cost:Object = null;
         var canAffordData:CreditCostInfo = null;
         if(this.m_hasSeenRedeemItemNowPrompt == null)
         {
            this.m_hasSeenRedeemItemNowPrompt = new Array();
            redeemItems = Global.farmGameSettingsManager.getBuildingRewardItems(m_creditsFeatureName);
            for(index = 0; index < redeemItems.length; index++)
            {
               cost = redeemItems[index].cost;
               canAffordData = this.getRedeemItemCostInfo(cost);
               this.setHasSeenRedeemItemNowPrompt(redeemItems[index].name,canAffordData.canAfford);
            }
         }
      }
      
      protected function getHasSeenRedeemItemNowPrompt(itemName:String) : Boolean
      {
         if(this.m_hasSeenRedeemItemNowPrompt == null)
         {
            this.seedHasSeenRedeemItemNowPrompt();
         }
         var res:Boolean = false;
         if(this.m_hasSeenRedeemItemNowPrompt[itemName] != null)
         {
            res = Boolean(this.m_hasSeenRedeemItemNowPrompt[itemName]);
         }
         return res;
      }
      
      protected function setHasSeenRedeemItemNowPrompt(itemName:String, hasSeen:Boolean) : void
      {
         if(this.m_hasSeenRedeemItemNowPrompt == null)
         {
            this.seedHasSeenRedeemItemNowPrompt();
         }
         this.m_hasSeenRedeemItemNowPrompt[itemName] = hasSeen;
      }
      
      protected function hasEarnedEnoughCreditsToRedeemPrize() : Object
      {
         var redeemItem:Object = null;
         var cost:Object = null;
         var canAffordCostData:CreditCostInfo = null;
         var currentIsAvatar:Boolean = false;
         var currentItemName:String = null;
         var startDate:String = null;
         var validToRedeem:Boolean = false;
         var redeemFarmItem:Object = null;
         var bestRedeemFarmItem:FarmItem = null;
         var folderNum:int = 0;
         var nBestItemCost:Number = 0;
         var nBestItem:Object = null;
         var nBestItemData:Object = null;
         var bBestIsAvatar:Boolean = false;
         var redeemItems:Array = Global.farmGameSettingsManager.getBuildingRewardItems(m_creditsFeatureName);
         for(var index:uint = 0; index < redeemItems.length; index++)
         {
            redeemItem = redeemItems[index];
            cost = redeemItem.cost;
            canAffordCostData = this.getRedeemItemCostInfo(cost);
            currentIsAvatar = false;
            currentItemName = redeemItem.name;
            if(redeemItem.itemId)
            {
               currentItemName = redeemItem.itemId;
            }
            startDate = redeemItem.startDate;
            validToRedeem = startDate == null || startDate == "" || FarmGameUtil.synchronizedDateToNumber(startDate) < GlobalEngine.serverTime;
            if(canAffordCostData.canAfford && canAffordCostData.totalCreditCost > nBestItemCost && validToRedeem && !this.getHasSeenRedeemItemNowPrompt(currentItemName))
            {
               redeemFarmItem = Global.farmGameSettingsManager.getFarmItemByName(redeemItem.name);
               if(redeemFarmItem == null)
               {
                  redeemFarmItem = Global.avatarConfigSettings.getItemById(redeemItem.itemId);
                  if(redeemFarmItem)
                  {
                     currentIsAvatar = true;
                  }
               }
               if(redeemFarmItem)
               {
                  nBestItemCost = canAffordCostData.totalCreditCost;
                  nBestItem = redeemFarmItem;
                  nBestItemData = redeemItem;
                  bBestIsAvatar = currentIsAvatar;
               }
            }
         }
         var redeemItemData:Object = null;
         if(nBestItem != null)
         {
            redeemItemData = new Object();
            redeemItemData.locked = nBestItemData.locked && nBestItemData.locked == "true";
            redeemItemData.cost = nBestItemData.cost;
            redeemItemData.name = nBestItem.name;
            bestRedeemFarmItem = Global.farmGameSettingsManager.getFarmItemByName(nBestItem.name);
            redeemItemData.friendlyName = bestRedeemFarmItem.friendlyName;
            if(bBestIsAvatar)
            {
               folderNum = 3;
               redeemItemData.icon = Global.reverseAssetURL(nBestItem.iconPath,folderNum);
               redeemItemData.avatarItemCode = nBestItemData.itemId;
            }
            else
            {
               redeemItemData.icon = bestRedeemFarmItem.iconRelativeUrl;
               redeemItemData.avatarItemCode = null;
            }
         }
         return redeemItemData;
      }
      
      protected function attemptShowEnoughCreditsToRedeemPrompt() : Boolean
      {
         var imageSize:Number = NaN;
         var centerIconUrl:String = null;
         var creditFriendlyName:String = null;
         var title:String = null;
         var messageTop:String = null;
         var messageBottom:String = null;
         var shareText:String = null;
         var basketIconUrl:String = null;
         var toaster:TwoIconTitleToasterWindow = null;
         var showDialog:Boolean = false;
         var itemRedeemable:Object = this.hasEarnedEnoughCreditsToRedeemPrize();
         var toasterRewardSeen:Boolean = itemRedeemable != null ? Global.player.getSeenSessionFlag(itemRedeemable.friendlyName + "_RedeemToaster") : true;
         if(Boolean(itemRedeemable) && !toasterRewardSeen)
         {
            imageSize = 100;
            centerIconUrl = itemRedeemable.icon;
            creditFriendlyName = RewardCreditsBuilding.getCreditItemFriendlyName(getCreditsFeatureName());
            title = ZLocUtils.t("Dialogs",TOKEN_CAN_REDEEM_PRIZE_NOW + "Title");
            messageTop = ZLocUtils.t("Dialogs",TOKEN_CAN_REDEEM_PRIZE_NOW + "MessageTop",{
               "item":ZLocUtils.tk_pk(creditFriendlyName),
               "reward":ZLocUtils.tk_pk(itemRedeemable.friendlyName)
            });
            messageBottom = ZLocUtils.t("Dialogs",TOKEN_CAN_REDEEM_PRIZE_NOW + "MessageBottom");
            shareText = ZLocUtils.t("Dialogs",TOKEN_CAN_REDEEM_PRIZE_NOW + "AcceptButton");
            basketIconUrl = getItem().iconUrl;
            toaster = new TwoIconTitleToasterWindow(title,messageTop,centerIconUrl,basketIconUrl,ToasterIconPaths.DIALOG_ASSET,0.5,0.5,new Point(15,8),null,this.onRedeemItemToasterClick,true,false,null,null,ZLocUtils.t("Dialogs","Okay"));
            if(itemRedeemable != null)
            {
               Global.player.setSeenSessionFlag(itemRedeemable.friendlyName + "_RedeemToaster");
            }
            ToasterManager.getInstance().add(toaster);
            FarmStatsManager.count("toaster",m_creditsFeatureName + "-" + TOKEN_REDEEM,StatsTrackingConstants.DIALOG_STATS_VIEW_PHYLUM);
         }
         return showDialog;
      }
      
      protected function onCloseEnoughCreditsToRedeemPrompt(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            UI.closeMarketDialog();
            UI.closeGifts();
            this.m_showRedeemableItemOnLoad = event.currentTarget.m_passedData;
            UI.clearPopupQueue();
            this.displayStorageDialog();
            FarmStatsManager.count("dialog",m_creditsFeatureName + "-" + TOKEN_REDEEM,StatsTrackingConstants.DIALOG_STATS_SHARE_CLICK_PHYLUM);
         }
         else
         {
            FarmStatsManager.count("dialog",m_creditsFeatureName + "-" + TOKEN_REDEEM,StatsTrackingConstants.DIALOG_STATS_X_CLICK_PHYLUM);
         }
      }
      
      protected function onRedeemItemToasterClick(event:MouseEvent) : void
      {
         UI.closeMarketDialog();
         UI.closeGifts();
         this.m_showRedeemableItemOnLoad = event.currentTarget.m_passedData;
         UI.clearPopupQueue();
         this.displayStorageDialog();
         FarmStatsManager.count("toaster",m_creditsFeatureName + "-" + TOKEN_REDEEM,StatsTrackingConstants.DIALOG_STATS_SHARE_CLICK_PHYLUM);
      }
      
      protected function setStateStat() : void
      {
         FarmStatsManager.count(m_creditsFeatureName,"state_change",this.getTitle());
      }
      
      protected function getNeighbors() : Array
      {
         return Global.friendManager.neighbors;
      }
      
      protected function hasStartFeed() : Boolean
      {
         return false;
      }
      
      protected function hasFirstTimePlaceFeed() : Boolean
      {
         return this.hasFriendRewardType(TOKEN_FIRST_TIME_PLACE);
      }
      
      protected function getFirstTimePlacedFlagName() : String
      {
         return getLocKeyPrefix() + TOKEN_FIRST_TIME_PLACE;
      }
      
      protected function showFirstTimePlacePrompt() : void
      {
         var title:String = null;
         var strPK:String = null;
         var message:String = null;
         var share:String = null;
         var popup:GenericXMLDialog = null;
         var sPlacedFlag:String = this.getFirstTimePlacedFlagName();
         if(!Global.player.getSeenFlag(sPlacedFlag))
         {
            title = ZLocUtils.t("Dialogs","Congratulations");
            strPK = RewardCreditsBuilding.getLocalizedKey(getCreditsFeatureName(),TOKEN_FIRST_TIME_PLACE + "Message");
            message = this.getDialogText(strPK);
            share = ZLocUtils.t("Dialogs","Share");
            popup = new GenericXMLDialog(title,null,null,this.getChangeFeedIconUrl(),100,100,message,this.onCloseFirstTimePlacePrompt,true,"Share");
            Global.player.setSeenFlag(sPlacedFlag);
            popup.setTrackerKey("feed-" + getLocKeyPrefix() + TOKEN_FIRST_TIME_PLACE);
            UI.displayPopup(popup,false);
            FarmStatsManager.count("dialog",m_creditsFeatureName + "-" + TOKEN_FIRST_TIME_PLACE,StatsTrackingConstants.DIALOG_STATS_VIEW_PHYLUM);
         }
      }
      
      protected function onCloseFirstTimePlacePrompt(event:GenericPopupEvent) : void
      {
         var bundleData:Object = null;
         var messageType:String = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            bundleData = {
               "reward_link":this.m_lastRewardUrl,
               "images":[{
                  "href":"{SN_APP_URL}" + "gifts.php",
                  "src":Global.getAssetURL(this.getChangeFeedIconUrl())
               }],
               "basketname":getBasketFriendlyName(m_creditsFeatureName),
               "credititemname":getCreditItemFriendlyName(m_creditsFeatureName),
               "credititemname_single":getCreditItemFriendlyName(m_creditsFeatureName)
            };
            messageType = this.getBundlePrefix() + TOKEN_FIRST_TIME_PLACE;
            GlobalEngine.socialNetwork.publishFeedStory(messageType,bundleData,[],false);
            FarmStatsManager.count("dialog",m_creditsFeatureName + "-" + TOKEN_FIRST_TIME_PLACE,StatsTrackingConstants.DIALOG_STATS_SHARE_CLICK_PHYLUM);
         }
         else
         {
            FarmStatsManager.count("dialog",m_creditsFeatureName + "-" + TOKEN_FIRST_TIME_PLACE,StatsTrackingConstants.DIALOG_STATS_X_CLICK_PHYLUM);
         }
         this.displayStorageDialog();
      }
      
      protected function showStartFeedPrompt() : void
      {
         var dialogText:String = ZLocUtils.t("Dialogs",getLocKeyPrefix() + DEPRECATED_TOKEN_START);
         var dialog:GenericPopup = new GenericPopup(dialogText,GenericPopup.TYPE_SHARECANCEL,this.onCloseStartPrompt);
         dialog.setTrackerKey("feed_" + getLocKeyPrefix() + DEPRECATED_TOKEN_START);
         UI.displayPopup(dialog);
      }
      
      protected function onCloseStartPrompt(event:GenericPopupEvent) : void
      {
         var params:Object = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            params = new Object();
            params.images = [{
               "src":Global.getAssetURL(this.getIntervalFeedIconUrl()),
               "href":"{SN_APP_URL}"
            }];
            GlobalEngine.socialNetwork.publishFeedStory(this.getBundlePrefix() + DEPRECATED_TOKEN_START,params,[],false);
         }
      }
      
      public function processCreditsGainedResult(result:Object) : Boolean
      {
         var rewardType:String = null;
         var levelReached:uint = 0;
         var levelSkipFeeds:Array = null;
         var totalCredits:uint = 0;
         var prevCreditsCount:uint = 0;
         var passNeighborUid:String = null;
         var neighbors:Array = null;
         var nidx:int = 0;
         var len:int = 0;
         var neighbor:Friend = null;
         var neighborCredits:uint = 0;
         var flagName:String = null;
         var feedPrompted:Boolean = false;
         if(result)
         {
            if(result["rewardUrl"])
            {
               this.m_lastRewardUrl = result["rewardUrl"];
               this.m_lastRewardCode = result["rewardCode"] ? result["rewardCode"] : null;
               rewardType = result["rewardType"] as String;
               if(rewardType == TOKEN_REWARD_TYPE_STATECHANGE)
               {
                  levelReached = uint(getLevel());
                  levelSkipFeeds = getLevelSkipFeeds();
                  if(levelSkipFeeds == null || !levelSkipFeeds[levelReached])
                  {
                     this.m_lastRewardAction = CREDITS_REWARD_ACTION_STATE_CHANGE;
                     FarmStatsManager.count(m_creditsFeatureName,"state_change",levelReached.toString());
                     this.showStateChangeFeedPrompt();
                     feedPrompted = true;
                  }
               }
               else if(rewardType == TOKEN_REWARD_TYPE_INTERVAL)
               {
                  if(!this.m_creditIntervalDialogOpen)
                  {
                     this.m_lastRewardAction = CREDITS_REWARD_ACTION_INTERVAL;
                     this.showIntervalFeedPrompt();
                     feedPrompted = true;
                  }
               }
            }
            else
            {
               totalCredits = this.getCombinedCreditsCount(getMultiTypeCredits(true));
               prevCreditsCount = this.getCombinedCreditsCount(m_prevCreditsReceived);
               if(totalCredits >= this.getMinCreditsToPassNeighbor())
               {
                  passNeighborUid = "0";
                  neighbors = this.getNeighbors();
                  nidx = 0;
                  len = int(neighbors.length);
                  while(nidx < len)
                  {
                     neighbor = neighbors[nidx];
                     neighborCredits = this.getCombinedCreditsCount(this.getNeighborMultiTypeCreditsReceived(neighbor));
                     if(prevCreditsCount <= neighborCredits && totalCredits > neighborCredits)
                     {
                        passNeighborUid = neighbor.uid;
                        break;
                     }
                     nidx++;
                  }
                  if(passNeighborUid != "0")
                  {
                     flagName = this.getNeighborPassFeedFlagName();
                     if(!Global.player.getSeenSessionFlag(flagName))
                     {
                        Global.player.setSeenSessionFlag(flagName);
                        this.m_lastRewardAction = CREDITS_REWARD_ACTION_PASS_NEIGHBOR;
                        this.doPastNeighborAction(passNeighborUid);
                        feedPrompted = true;
                     }
                  }
               }
            }
            this.attemptShowEnoughCreditsToRedeemPrompt();
         }
         return feedPrompted;
      }
      
      protected function doPastNeighborAction(passNeighborUid:String) : void
      {
         TransactionManager.addTransaction(new TCreditsPassNeighbor(this,passNeighborUid));
      }
      
      public function isAtFeatureCreditLimit() : Boolean
      {
         var result:Boolean = false;
         var featureCreditLimit:int = -1;
         if(Boolean(m_creditsBuildingXml) && m_creditsBuildingXml.@creditThrottleLimit.toString() != "")
         {
            featureCreditLimit = int(m_creditsBuildingXml.@creditThrottleLimit);
         }
         if(featureCreditLimit > 0)
         {
            result = this.getCurrentCredits() >= featureCreditLimit;
         }
         return result;
      }
   }
}

