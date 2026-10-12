package Classes
{
   import Classes.Quest.PrerequisiteUtility;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.LandBundleUnlockFeatureManager;
   import Transactions.TGenericTransaction;
   import Transactions.TTransformTreasureLandBundle;
   import Widgets.Windows.LandBundleRewardWindow;
   import Widgets.Windows.LandBundleUnlockFeatureBonusRewardWindow;
   import Widgets.Windows.MultiTreasurePayerLandBundleHoverOverWindow;
   
   public class LandBundleUnlockFeatureTreasureConstructionBuilding extends MultiRewardTreasureConstructionBuilding
   {
      
      public static const LAND_BUNDLE_UNLOCKED:String = "Caribbean_LandBundle_unlocked";
      
      private static const FEATURE_TRACKING:String = "landbundle";
      
      private static const SERVICE_NAME:String = "LandBundleService";
      
      public static const WORLD_LAND_BUNDLE_UNLOCKED:String = "Southindia_LandBundle_unlocked";
      
      protected static var m_hoverWindows3:Object = new Object();
      
      public var m_featureName:String = "LandBundleIreland";
      
      public var m_worldName:String = "Alaska";
      
      private var m_startTime:String = "09/16/2019";
      
      private var m_endTime:String = "09/25/2019";
      
      private var m_bundleWindow:* = "assets/dialogs/alaska/landbundle/FV_xsu_LandBundle.swf";
      
      private var m_bundleName:* = "land_pkg_alaska_EA";
      
      public var m_rewardCode:String = "n5sv";
      
      private var m_rewardItem:FarmItem;
      
      public var m_rewardCount:int = 1;
      
      private var m_tilesArray:Array = [];
      
      private var m_finalPrice:int = 0;
      
      private var INNOVATION_NAME:String = "IrelandInnovation";
      
      public function LandBundleUnlockFeatureTreasureConstructionBuilding(itemName:String)
      {
         super(itemName);
         if(Global.worldManager.currentWorldType == "ireland")
         {
            if(this.manager.isTilePayer(itemName))
            {
               m_payerTile = true;
            }
         }
         else
         {
            m_payerTile = true;
         }
      }
      
      public static function isBundleAvailable() : Boolean
      {
         var result:Boolean = false;
         if(Global.worldManager.currentWorldType == "ireland")
         {
            result = LandBundleUnlockFeatureManager.getInstance().shouldFeatureContinue();
         }
         return result;
      }
      
      private static function isTileLocked(tileName:String) : Boolean
      {
         var result:Boolean = false;
         if(Global.world.getObjectsByName(tileName).length > 0)
         {
            result = true;
         }
         return result;
      }
      
      protected static function showHoverMenu3(treasure:MultiRewardTreasureConstructionBuilding, treasureQuestDetails:Object, hoverCallbackObject:Object, hoverOverWindowAsset:String, timerTime:int = -1, payerTile:Boolean = false, firstSecondBundleData:Object = null, worldName:String = null) : void
      {
         if(m_hoverWindows3[hoverOverWindowAsset] != null && Boolean(m_hoverWindows3[hoverOverWindowAsset].isLoaded()))
         {
            m_hoverWindows3[hoverOverWindowAsset].updateAndShowBundle(treasure,treasureQuestDetails,hoverCallbackObject,timerTime,payerTile,firstSecondBundleData);
         }
         else if(m_hoverWindows3[hoverOverWindowAsset] == null)
         {
            m_hoverWindows3[hoverOverWindowAsset] = new MultiTreasurePayerLandBundleHoverOverWindow(treasure,treasureQuestDetails,hoverCallbackObject,timerTime,hoverOverWindowAsset,payerTile,firstSecondBundleData,worldName);
            UI.addHoverWindow(m_hoverWindows3[hoverOverWindowAsset]);
         }
      }
      
      public function setupBundleDetails(tilesArray:Array = null, finalPrice:int = 0) : Object
      {
         var n2:Number = NaN;
         if(Global.worldManager.currentWorldType == "ireland")
         {
            this.m_tilesArray = tilesArray;
            this.m_finalPrice = finalPrice;
         }
         var bundleDetails:Object = new Object();
         m_currentWindowAsset = m_hoverOverWindowAssetLocked;
         var n1:Number = (GlobalEngine.serverTime - FarmGameUtil.synchronizedDateToNumber(this.m_startTime)) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         if(Global.worldManager.currentWorldType == "ireland" && isBundleAvailable())
         {
            m_currentWindowAsset = this.m_bundleWindow;
            bundleDetails.type = "bundle";
            this.completeNowFirstBundleCallback();
         }
         else if(n1 > 0)
         {
            n2 = (GlobalEngine.serverTime - FarmGameUtil.synchronizedDateToNumber(this.m_endTime)) / FarmGameUtil.NUM_MSECS_IN_SECOND;
            if(n2 < 0 && isBundleAvailable())
            {
               m_currentWindowAsset = this.m_bundleWindow;
               bundleDetails.type = "bundle";
               this.completeNowFirstBundleCallback();
            }
         }
         return bundleDetails;
      }
      
      public function isNonPayerTileQuestComplete() : Boolean
      {
         var result:Boolean = false;
         if(Global.worldManager.currentWorldType == "ireland" && m_payerTile == false)
         {
            if(PrerequisiteUtility.isPrerequisiteMet(m_prereqObject))
            {
               result = true;
            }
         }
         return result;
      }
      
      protected function completeNowFirstBundleCallback() : void
      {
         var bundlePrice:int = 0;
         if(Global.worldManager.currentWorldType == "ireland")
         {
            bundlePrice = this.m_finalPrice;
         }
         if(!m_transformStarted && Global.player.canBuyCash(bundlePrice,true,"expand_treasure_farm"))
         {
            if(m_frictionlessBuyActive)
            {
               this.frictionlessCompleteNowLandBundle(true);
            }
            else
            {
               UI.displayMessage(ZLocUtils.t("Dialogs","FinishConstructionBuildingPopup",{
                  "cashQuantity":bundlePrice,
                  "item":"bundle of 4 tiles"
               }),GenericPopup.TYPE_ACCEPTCANCEL,this.onConfirmCompletePopupClose1,"",true);
            }
         }
      }
      
      protected function frictionlessCompleteNowLandBundle(transformBuildingOnComplete:Boolean = false) : void
      {
         var tiles:Array = null;
         var cash:int = 0;
         var bundleName:String = null;
         if(!m_transformStarted)
         {
            tiles = this.getTileArray("");
            cash = 0;
            if(Global.worldManager.currentWorldType == "ireland")
            {
               cash = this.m_finalPrice;
            }
            bundleName = this.m_bundleName;
            if(Global.player.canBuyCash(cash,true))
            {
               Global.player.cash -= cash;
               m_transformStarted = true;
               TransactionManager.addTransaction(new TTransformTreasureLandBundle(tiles,transformBuildingOnComplete,bundleName,this.m_featureName,null));
               Global.player.setSeenFlag(WORLD_LAND_BUNDLE_UNLOCKED);
               this.m_rewardItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_rewardCode);
               if(Global.worldManager.currentWorldType == "ireland")
               {
                  if(this.m_rewardItem)
                  {
                     UI.displayPopup(new LandBundleUnlockFeatureBonusRewardWindow("assets/dialogs/expansion/FV_RewardDialog.swf",this.m_featureName,this.m_rewardItem,null,"assets/dialogs/ireland/RewardDialog.png","assets/dialogs/ireland/LandBundle/Deploy/cnsum_icon_200.png"),false);
                     Global.player.addGift(this.m_rewardItem.name);
                     TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"grantBonusReward",null,[this.m_featureName]),true);
                  }
               }
               else
               {
                  UI.displayPopup(new LandBundleRewardWindow(this.m_worldName,this.m_rewardCode,this.m_rewardCount));
               }
               if(Global.worldManager.currentWorldType == "ireland")
               {
                  this.manager.addFarmStatsPurchase(cash,this.m_tilesArray);
               }
            }
         }
      }
      
      private function getTileArray(type:String) : Array
      {
         var tileName:String = null;
         var result:Array = new Array();
         var tilesArray:Array = [];
         if(Global.worldManager.currentWorldType == "ireland")
         {
            tilesArray = this.m_tilesArray;
         }
         for each(tileName in tilesArray)
         {
            result[tileName] = Global.world.getObjectsByName(tileName)[0];
         }
         return result;
      }
      
      protected function onConfirmCompletePopupClose1(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.YES)
         {
            this.frictionlessCompleteNowLandBundle(true);
         }
         else
         {
            FarmStatsManager.count("IrelandLandBundle","CancelPurchase");
         }
      }
      
      private function get manager() : LandBundleUnlockFeatureManager
      {
         return LandBundleUnlockFeatureManager.getInstance(this.m_featureName);
      }
   }
}

