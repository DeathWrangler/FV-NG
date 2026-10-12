package Classes
{
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import GameMode.GMBuildingPart;
   import Managers.FarmStatsManager;
   import Managers.WorldSeasonsManager;
   import Transactions.TTransformTreasureBundle;
   import Widgets.Windows.MultiTreasurePayerBundleHoverOverWindow;
   
   public class MultiRewardTreasurePayerBundleConstructionBuilding extends MultiRewardTreasureConstructionBuilding
   {
      
      public static const FIRST_BUNDLE_TYPE:String = "4";
      
      public static const SECOND_BUNDLE_TYPE:String = "2";
      
      public static const EA_SUFFIX:String = "_EA";
      
      public static const GA_SUFFIX:String = "_GA";
      
      public static const EA_BUY:String = "EA";
      
      public static const GA_BUY:String = "GA";
      
      public static const NORMAL_BUY:String = "NORMAL";
      
      protected static var m_hoverWindows2:Object = new Object();
      
      private var m_eaStartTime:Number = 0;
      
      private var m_gaStartTime:Number = 0;
      
      private var m_bundle:Object;
      
      private var m_landBuyType:String = "";
      
      private var m_bundleDiscountPrice:Object;
      
      private var m_bundleNameByType:Object;
      
      private var m_bundleBackgroundByType:Object;
      
      public function MultiRewardTreasurePayerBundleConstructionBuilding(itemName:String)
      {
         super(itemName);
         m_payerTile = true;
         this.m_bundle = new Object();
         this.m_bundleDiscountPrice = new Object();
         this.m_bundleNameByType = new Object();
         this.m_bundleBackgroundByType = new Object();
         if(m_hoverCallbackObject)
         {
            m_hoverCallbackObject.completeNowFirstBundleCallback = this.completeNowFirstBundleCallback;
            m_hoverCallbackObject.completeNowSecondBundleCallback = this.completeNowSecondBundleCallback;
         }
         this.setLandBundleData(EA_SUFFIX);
         this.setLandBundleData(GA_SUFFIX);
         this.setupExpansionDates();
      }
      
      protected static function showHoverMenu2(treasure:MultiRewardTreasureConstructionBuilding, treasureQuestDetails:Object, hoverCallbackObject:Object, hoverOverWindowAsset:String, timerTime:int = -1, payerTile:Boolean = false, firstSecondBundleData:Object = null) : void
      {
         if(m_hoverWindows2[hoverOverWindowAsset] != null && Boolean(m_hoverWindows2[hoverOverWindowAsset].isLoaded()))
         {
            m_hoverWindows2[hoverOverWindowAsset].updateAndShowBundle(treasure,treasureQuestDetails,hoverCallbackObject,timerTime,payerTile,firstSecondBundleData);
         }
         else if(m_hoverWindows2[hoverOverWindowAsset] == null)
         {
            m_hoverWindows2[hoverOverWindowAsset] = new MultiTreasurePayerBundleHoverOverWindow(treasure,treasureQuestDetails,hoverCallbackObject,timerTime,hoverOverWindowAsset,payerTile,firstSecondBundleData);
            UI.addHoverWindow(m_hoverWindows2[hoverOverWindowAsset]);
         }
      }
      
      private function setWindowAsset() : void
      {
         if(this.m_landBuyType != NORMAL_BUY)
         {
            m_currentWindowAsset = Global.farmGameSettingsManager.getImageByName(m_itemName,"bundle",false);
         }
      }
      
      public function isBundleBuyAvailable(bundleType:String) : Boolean
      {
         var bundleName:String = null;
         var tileName:String = null;
         var result:Boolean = true;
         if(this.m_bundle.hasOwnProperty(bundleType))
         {
            var _loc5_:int = 0;
            var _loc6_:* = this.m_bundle[bundleType];
            for(bundleName in _loc6_)
            {
               for each(tileName in this.m_bundle[bundleType][bundleName])
               {
                  if(this.isTileLocked(tileName) == false)
                  {
                     result = false;
                     break;
                  }
               }
            }
         }
         else
         {
            result = false;
         }
         return result;
      }
      
      public function getPercent() : String
      {
         var result:String = "";
         if(this.m_landBuyType == EA_BUY)
         {
            result = "30%";
         }
         else if(this.m_landBuyType == GA_BUY)
         {
            result = "20%";
         }
         return result;
      }
      
      private function setupExpansionDates() : void
      {
         var worldType:String = Global.worldManager.currentWorldType;
         var eaStartDate:String = WorldSeasonsManager.getInstance().getEarlyExpansionAccessData(worldType).getStartDate();
         this.m_eaStartTime = FarmGameUtil.synchronizedDateToNumber(eaStartDate);
         var gaStartDate:String = WorldSeasonsManager.getInstance().getGeneralExpansionAccessData(worldType).getStartDate();
         this.m_gaStartTime = FarmGameUtil.synchronizedDateToNumber(gaStartDate);
      }
      
      public function setLandBuyType() : String
      {
         var result:String = NORMAL_BUY;
         var worldType:String = Global.worldManager.currentWorldType;
         if(WorldSeasonsManager.getInstance().isEAWeek(worldType))
         {
            result = EA_BUY;
         }
         else if(WorldSeasonsManager.getInstance().isGAFirstWeek(worldType))
         {
            result = GA_BUY;
         }
         this.m_landBuyType = result;
         return result;
      }
      
      public function getDaysLeft() : String
      {
         var difference:Number = NaN;
         var currentTime:Number = GlobalEngine.serverTime;
         if(this.m_landBuyType == EA_BUY)
         {
            difference = currentTime - this.m_eaStartTime;
         }
         else if(this.m_landBuyType == GA_BUY)
         {
            difference = currentTime - this.m_gaStartTime;
         }
         difference = 7 * FarmGameUtil.NUM_MSECS_IN_DAY - difference;
         difference /= FarmGameUtil.NUM_MSECS_IN_DAY;
         return Math.floor(difference).toString();
      }
      
      public function getLastDate() : Number
      {
         var result:Number = 0;
         if(this.m_landBuyType == EA_BUY)
         {
            result = this.m_eaStartTime;
         }
         else if(this.m_landBuyType == GA_BUY)
         {
            result = this.m_gaStartTime;
         }
         return result + 7 * FarmGameUtil.NUM_MSECS_IN_DAY;
      }
      
      public function setLandBundleData(bundleSuffix:String) : void
      {
         var bundlePrefix:String = null;
         var type:String = null;
         var fullBundleName:String = null;
         var bundleItem:FarmItem = null;
         var itemPackages:Object = null;
         var itemPackage:String = null;
         var bundlePrefixes:Object = getItem().getItemLandBundleObject();
         for(bundlePrefix in bundlePrefixes)
         {
            type = bundlePrefixes[bundlePrefix];
            if(!this.m_bundle.hasOwnProperty(type))
            {
               this.m_bundle[type] = new Object();
            }
            fullBundleName = bundlePrefix + bundleSuffix;
            bundleItem = Global.farmGameSettingsManager.getFarmItemByName(fullBundleName);
            this.m_bundleBackgroundByType[type] = Global.farmGameSettingsManager.getImageByName(fullBundleName,"icon",false);
            itemPackages = bundleItem.getItemPackageHash();
            if(itemPackages != null)
            {
               this.m_bundle[type][fullBundleName] = new Array();
               for(itemPackage in itemPackages)
               {
                  this.m_bundle[type][fullBundleName].push(itemPackage);
               }
            }
         }
      }
      
      public function isTileLocked(tileName:String) : Boolean
      {
         var result:Boolean = false;
         if(Global.world.getObjectsByName(tileName).length > 0)
         {
            result = true;
         }
         return result;
      }
      
      public function setBundlePrice(type:String) : String
      {
         var result:String = null;
         var bundleName:String = null;
         var bundleItem:FarmItem = null;
         var currentBundleType:Object = this.m_bundle[type];
         for(bundleName in currentBundleType)
         {
            if(bundleName.indexOf(this.m_landBuyType) != -1)
            {
               bundleItem = Global.farmGameSettingsManager.getFarmItemByName(bundleName);
               result = bundleItem.realCashCost.toString();
               break;
            }
         }
         this.m_bundleDiscountPrice[type] = result;
         return result;
      }
      
      public function setBundleName(type:String) : String
      {
         var result:String = null;
         var bundleName:String = null;
         var currentBundleType:Object = this.m_bundle[type];
         for(bundleName in currentBundleType)
         {
            if(bundleName.indexOf(this.m_landBuyType) != -1)
            {
               result = bundleName;
               break;
            }
         }
         this.m_bundleNameByType[type] = result;
         return result;
      }
      
      public function getOriginalPrice(type:String) : String
      {
         var bundleName:String = null;
         var tileName:String = null;
         var totalPrice:int = 0;
         var currentBundleType:Object = this.m_bundle[type];
         var _loc6_:int = 0;
         var _loc7_:* = currentBundleType;
         for(bundleName in _loc7_)
         {
            for each(tileName in currentBundleType[bundleName])
            {
               totalPrice += Global.farmGameSettingsManager.getFarmItemByName(tileName).realCashCost;
            }
         }
         return totalPrice.toString();
      }
      
      private function getTileArray(type:String) : Array
      {
         var bundleName:String = null;
         var tileName:String = null;
         var result:Array = new Array();
         var currentBundleType:Object = this.m_bundle[type];
         var _loc6_:int = 0;
         var _loc7_:* = currentBundleType;
         for(bundleName in _loc7_)
         {
            for each(tileName in currentBundleType[bundleName])
            {
               result[tileName] = Global.world.getObjectsByName(tileName)[0];
            }
         }
         return result;
      }
      
      protected function completeNowFirstBundleCallback() : void
      {
         var bundlePrice:int = int(this.m_bundleDiscountPrice[FIRST_BUNDLE_TYPE]);
         if(!m_transformStarted && Global.player.canBuyCash(bundlePrice,true,"expand_treasure_farm"))
         {
            if(m_frictionlessBuyActive)
            {
               this.frictionlessCompleteNowLandBundle(true,FIRST_BUNDLE_TYPE);
            }
            else
            {
               UI.displayMessage(ZLocUtils.t("Dialogs","FinishConstructionBuildingPopup",{
                  "cashQuantity":bundlePrice,
                  "item":"bundle of " + FIRST_BUNDLE_TYPE + " tiles"
               }),GenericPopup.TYPE_ACCEPTCANCEL,this.onConfirmCompletePopupClose1,"",true);
            }
         }
      }
      
      protected function onConfirmCompletePopupClose1(event:GenericPopupEvent) : void
      {
         var bundleFriendlyName:String = Global.farmGameSettingsManager.getFarmItemByName(this.m_bundleNameByType[FIRST_BUNDLE_TYPE]).friendlyTitle;
         if(event.button == GenericPopup.YES)
         {
            FarmStatsManager.count("expand_treasure_farm",bundleFriendlyName,"confirm_dialog","accept");
            this.frictionlessCompleteNowLandBundle(true,FIRST_BUNDLE_TYPE);
         }
         else
         {
            FarmStatsManager.count("expand_treasure_farm",bundleFriendlyName,"confirm_dialog","cancel");
         }
      }
      
      protected function onConfirmCompletePopupClose2(event:GenericPopupEvent) : void
      {
         var bundleFriendlyName:String = Global.farmGameSettingsManager.getFarmItemByName(this.m_bundleNameByType[SECOND_BUNDLE_TYPE]).friendlyTitle;
         if(event.button == GenericPopup.YES)
         {
            FarmStatsManager.count("expand_treasure_farm",bundleFriendlyName,"confirm_dialog","accept");
            this.frictionlessCompleteNowLandBundle(true,SECOND_BUNDLE_TYPE);
         }
         else
         {
            FarmStatsManager.count("expand_treasure_farm",bundleFriendlyName,"confirm_dialog","cancel");
         }
      }
      
      protected function completeNowSecondBundleCallback() : void
      {
         if(!m_transformStarted && Global.player.canBuyCash(int(this.m_bundleDiscountPrice[SECOND_BUNDLE_TYPE]),true,"expand_treasure_farm"))
         {
            if(m_frictionlessBuyActive)
            {
               this.frictionlessCompleteNowLandBundle(true,SECOND_BUNDLE_TYPE);
            }
            else
            {
               UI.displayMessage(ZLocUtils.t("Dialogs","FinishConstructionBuildingPopup",{
                  "cashQuantity":this.m_bundleDiscountPrice[SECOND_BUNDLE_TYPE],
                  "item":"bundle of " + SECOND_BUNDLE_TYPE + " tiles"
               }),GenericPopup.TYPE_ACCEPTCANCEL,this.onConfirmCompletePopupClose2,"",true);
            }
         }
      }
      
      protected function frictionlessCompleteNowLandBundle(transformBuildingOnComplete:Boolean = false, subType:String = "") : void
      {
         var tiles:Array = null;
         var cash:int = 0;
         var bundleName:String = null;
         if(!m_transformStarted)
         {
            tiles = this.getTileArray(subType);
            cash = int(this.m_bundleDiscountPrice[subType]);
            bundleName = this.m_bundleNameByType[subType];
            if(Global.player.canBuyCash(cash,true))
            {
               Global.player.cash -= cash;
               m_transformStarted = true;
               TransactionManager.addTransaction(new TTransformTreasureBundle(tiles,transformBuildingOnComplete,bundleName,null));
            }
         }
      }
      
      private function setupBundleDetails() : Object
      {
         this.setLandBuyType();
         this.setWindowAsset();
         this.setBundlePrice(FIRST_BUNDLE_TYPE);
         this.setBundlePrice(SECOND_BUNDLE_TYPE);
         this.setBundleName(FIRST_BUNDLE_TYPE);
         this.setBundleName(SECOND_BUNDLE_TYPE);
         var bundleDetails:Object = new Object();
         bundleDetails.firstBundleDiscountPrice = this.m_bundleDiscountPrice[FIRST_BUNDLE_TYPE];
         bundleDetails.firstBundleOriginalPrice = this.getOriginalPrice(FIRST_BUNDLE_TYPE);
         bundleDetails.firstBundleAvailable = this.isBundleBuyAvailable(FIRST_BUNDLE_TYPE);
         bundleDetails.firstBundleDiscount = this.getPercent();
         bundleDetails.firstBundleBG = this.m_bundleBackgroundByType[FIRST_BUNDLE_TYPE];
         bundleDetails.secondBundleDiscountPrice = this.m_bundleDiscountPrice[SECOND_BUNDLE_TYPE];
         bundleDetails.secondBundleOriginalPrice = this.getOriginalPrice(SECOND_BUNDLE_TYPE);
         bundleDetails.secondBundleAvailable = this.isBundleBuyAvailable(SECOND_BUNDLE_TYPE);
         bundleDetails.secondBundleDiscount = this.getPercent();
         bundleDetails.secondBundleBG = this.m_bundleBackgroundByType[SECOND_BUNDLE_TYPE];
         bundleDetails.daysLeft = this.getDaysLeft();
         bundleDetails.lastDate = this.getLastDate();
         bundleDetails.landBuyType = this.m_landBuyType;
         bundleDetails.showBundleBuyUI = bundleDetails.landBuyType != NORMAL_BUY ? true : false;
         return bundleDetails;
      }
      
      override public function onClick() : void
      {
         var bundleDetails:Object = null;
         var itemPackageHash:Object = null;
         var rewards:Array = null;
         var itemName:String = null;
         if(!Global.worldManager.isVisiting() && !m_transformStarted)
         {
            isDatePreqMet = false;
            m_allPrereqDetails = {};
            m_allPrereqDetails[SHOULD_SHOW_ADJACENT_TEXT] = false;
            updateDataFromPrereq(m_prereqObject);
            m_currentWindowAsset = m_hoverOverWindowAssetLocked;
            bundleDetails = this.setupBundleDetails();
            itemPackageHash = this.getItem().getItemPackageHash();
            if(itemPackageHash != null)
            {
               rewards = new Array();
               for(itemName in itemPackageHash)
               {
                  rewards.push(itemName);
               }
               m_allPrereqDetails[REWARDS] = rewards;
            }
            m_hoveringContextMenuState = getHoveringContextMenuState();
            if(m_hoveringContextMenuState == HOVERING_CONTEXT_MOUSE_OVER && !(Global.world.getTopGameMode() is GMBuildingPart))
            {
               showHoverMenu2(this,m_allPrereqDetails,m_hoverCallbackObject,m_currentWindowAsset,HOVER_MENU_TIME_MS,m_payerTile,bundleDetails);
            }
         }
      }
   }
}

