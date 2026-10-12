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
   import GameMode.GMBuildingPart;
   import Managers.FarmStatsManager;
   import Managers.LandBundleUnlockFeatureHelper;
   import Managers.LandBundleUnlockFeatureManager;
   import Transactions.TGenericTransaction;
   import Transactions.TTransformTreasureLandBundle;
   import Widgets.Windows.LandBundleRewardWindow;
   import Widgets.Windows.LandBundleUnlockFeatureBonusRewardWindow;
   import Widgets.Windows.MultiTreasurePayerLandBundleHoverOverWindow;
   
   public class MultiRewardTreasurePayerLandBundleConstructionBuilding extends MultiRewardTreasureConstructionBuilding
   {
      
      private static const SERVICE_NAME:String = "LandBundleService";
      
      protected static var m_hoverWindows3:Object = new Object();
      
      public static var BUNDLE_TILES_ARRAY:Array = new Array("xpu_rubbletreasure_payer8","xpu_rubbletreasure_payer9","xpu_rubbletreasure_payer10","xpu_rubbletreasure_payer11");
      
      private var m_rewardItem:FarmItem;
      
      private var m_tilesArray:Array = [];
      
      private var m_finalPrice:int = 0;
      
      private var m_currentWorld:String;
      
      public var m_rewardCount:int = 1;
      
      public var m_featureName:String = "LandBundlePumpkin";
      
      public var m_worldName:String = "Pumpkin";
      
      private var m_startTime:String = "11/02/2020";
      
      private var m_endTime:String = "11/13/2020";
      
      private var m_bundleWindow:* = "assets/dialogs/pumpkin/landbundle/FV_xpu_landBundle.swf";
      
      private var m_bundleName:* = "land_pkg_pumpkin_EA";
      
      public var m_rewardCode:String = "2qcy";
      
      public function MultiRewardTreasurePayerLandBundleConstructionBuilding(itemName:String)
      {
         super(itemName);
         this.m_currentWorld = Global.worldManager.currentWorldType;
         if(this.checkWorldForFeature())
         {
            this.m_bundleWindow = this.manager.BUNDLE_DIALOG_URL;
            this.m_rewardCode = this.manager.REWARD_ITEM_CODE;
            this.m_startTime = this.manager.START_DATE;
            this.m_endTime = this.manager.END_DATE;
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
         var tileName:String = null;
         var result:Boolean = true;
         if(LandBundleUnlockFeatureHelper.getInstance().worldHasLandBundleFeature(Global.worldManager.currentWorldType))
         {
            result = LandBundleUnlockFeatureManager.getInstance().shouldFeatureContinue();
         }
         else
         {
            for each(tileName in BUNDLE_TILES_ARRAY)
            {
               if(isTileLocked(tileName) == false)
               {
                  result = false;
                  break;
               }
            }
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
         var bundleDetails:Object = null;
         var n1:Number = NaN;
         var n2:Number = NaN;
         if(this.checkWorldForFeature())
         {
            this.m_tilesArray = tilesArray;
            this.m_finalPrice = finalPrice;
            bundleDetails = new Object();
            m_currentWindowAsset = m_hoverOverWindowAssetLocked;
            if(isBundleAvailable())
            {
               m_currentWindowAsset = this.m_bundleWindow;
               bundleDetails.type = "bundle";
               this.completeNowFirstBundleCallback();
            }
         }
         else
         {
            bundleDetails = new Object();
            m_currentWindowAsset = m_hoverOverWindowAssetLocked;
            n1 = (GlobalEngine.serverTime - FarmGameUtil.synchronizedDateToNumber(this.m_startTime)) / FarmGameUtil.NUM_MSECS_IN_SECOND;
            if(n1 > 0)
            {
               n2 = (GlobalEngine.serverTime - FarmGameUtil.synchronizedDateToNumber(this.m_endTime)) / FarmGameUtil.NUM_MSECS_IN_SECOND;
               if(n2 < 0 && isBundleAvailable())
               {
                  m_currentWindowAsset = this.m_bundleWindow;
                  bundleDetails.type = "bundle";
                  if(m_hoverCallbackObject)
                  {
                     m_hoverCallbackObject.onClickCompleteNow1 = this.completeNowFirstBundleCallback;
                  }
               }
               else
               {
                  bundleDetails.type = "normal";
               }
            }
            else if(Global.worldManager.currentWorldType != this.m_worldName.toLowerCase())
            {
               bundleDetails.type = "normal";
            }
            else
            {
               bundleDetails.type = "comingsoon";
            }
         }
         return bundleDetails;
      }
      
      public function isNonPayerTileQuestComplete() : Boolean
      {
         var result:Boolean = false;
         if(this.checkWorldForFeature() && m_payerTile == false)
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
         var bundlePrice:int = 190;
         if(this.checkWorldForFeature())
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
            bundleName = this.m_bundleName;
            if(this.checkWorldForFeature())
            {
               cash = this.m_finalPrice;
               if(Global.player.canBuyCash(cash,true))
               {
                  Global.player.cash -= cash;
                  m_transformStarted = true;
                  TransactionManager.addTransaction(new TTransformTreasureLandBundle(tiles,transformBuildingOnComplete,bundleName,this.m_featureName,null));
                  this.m_rewardCode = this.manager.REWARD_ITEM_CODE;
                  this.m_rewardItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_rewardCode);
                  if(this.m_rewardItem)
                  {
                     UI.displayPopup(new LandBundleUnlockFeatureBonusRewardWindow("assets/dialogs/expansion/FV_RewardDialog.swf",this.m_featureName,this.m_rewardItem,null,this.manager.REWARD_DIALOG_URL,this.manager.REWARD_ICON_URL),false);
                     Global.player.addGift(this.m_rewardItem.name);
                     TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"grantBonusReward",null,[this.m_featureName]),true);
                  }
                  this.manager.addFarmStatsPurchase(cash,this.m_tilesArray);
               }
            }
            else
            {
               cash = 190;
               if(Global.player.canBuyCash(cash,true))
               {
                  Global.player.cash -= cash;
                  m_transformStarted = true;
                  TransactionManager.addTransaction(new TTransformTreasureLandBundle(tiles,transformBuildingOnComplete,bundleName,this.m_featureName,null));
                  Global.player.setSeenFlag(this.m_worldName + "_LandBundle_unlocked");
                  Global.player.addGift("pkg_landbundle_reward_pumpkin");
                  UI.displayPopup(new LandBundleRewardWindow(this.m_worldName,this.m_rewardCode,this.m_rewardCount));
                  FarmStatsManager.count(this.m_worldName + "LandBundle","BuyBundle",cash.toString());
                  if(Global.hud)
                  {
                     Global.hud.removeHudLandBundle();
                  }
               }
            }
         }
      }
      
      private function getTileArray(type:String) : Array
      {
         var tileName:String = null;
         var result:Array = new Array();
         var tilesArray:Array = [];
         if(this.checkWorldForFeature())
         {
            tilesArray = this.m_tilesArray;
         }
         else
         {
            tilesArray = BUNDLE_TILES_ARRAY;
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
            FarmStatsManager.count(this.m_currentWorld + "LandBundle","CancelPurchase");
         }
      }
      
      override public function onClick() : void
      {
         var bundleDetails:Object = null;
         var itemPackageHash:Object = null;
         var rewards:Array = null;
         var itemName:String = null;
         if(!this.checkWorldForFeature())
         {
            if(!Global.worldManager.isVisiting() && !m_transformStarted)
            {
               isDatePreqMet = false;
               m_allPrereqDetails = {};
               m_allPrereqDetails[SHOULD_SHOW_ADJACENT_TEXT] = false;
               updateDataFromPrereq(m_prereqObject);
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
                  showHoverMenu3(this,m_allPrereqDetails,m_hoverCallbackObject,m_currentWindowAsset,HOVER_MENU_TIME_MS,m_payerTile,bundleDetails,this.m_worldName);
               }
            }
         }
         else
         {
            super.onClick();
         }
      }
      
      private function checkWorldForFeature() : Boolean
      {
         return LandBundleUnlockFeatureHelper.getInstance().worldHasLandBundleFeature(this.m_currentWorld);
      }
      
      private function get manager() : LandBundleUnlockFeatureManager
      {
         return LandBundleUnlockFeatureManager.getInstance("LandBundleUnlockFeature");
      }
   }
}

