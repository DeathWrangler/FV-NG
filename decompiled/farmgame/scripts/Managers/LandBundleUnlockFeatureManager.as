package Managers
{
   import Classes.MultiRewardTreasurePayerLandBundleConstructionBuilding;
   import Classes.util.FarmGameUtil;
   import Display.UI;
   import Widgets.Windows.LandBundleUnlockFeatureWindow;
   
   public class LandBundleUnlockFeatureManager extends BaseFeatureManager
   {
      
      private static const FEATURE_TRACKING:String = "landbundle";
      
      private static const FIRST_DISCOUNT:Number = 0.1;
      
      private static const SECOND_DISCOUNT:Number = 0.2;
      
      private static const THIRD_DISCOUNT:Number = 0.3;
      
      private static const KEY_PAYER_TILE:String = "payer";
      
      protected static var m_instance:Object = {};
      
      private static var m_selectedTileList:Array = [];
      
      public static const FEATURE_NAME:String = "LandBundleUnlockFeature";
      
      private static const KEY_ACTIVE_TILE_LIST:String = "active_tile_list";
      
      public const REWARD_DIALOG_URL:String = "assets/dialogs/borabora/RewardDialog.png";
      
      public const REWARD_ICON_URL:String = "assets/dialogs/borabora/landbundle/cnsum_icon_200.png";
      
      public const BUNDLE_DIALOG_URL:String = "assets/dialogs/alaska/landbundle/FV_xbb_LandBundle.swf";
      
      public const START_DATE:String = "05/04/2020";
      
      public const END_DATE:String = "05/14/2020";
      
      public const REWARD_ITEM_CODE:String = "n5sv";
      
      public const CURRENT_FEATURE_WORLD:String = "borabora";
      
      public const COUNT_NON_PAYER_TILES:int = 8;
      
      public const COUNT_PAYER_TILES:int = 16;
      
      protected var m_featureConfigData:Object;
      
      private var m_mainWindow:LandBundleUnlockFeatureWindow;
      
      private var m_bundleFirstTile:String;
      
      private var m_tilesByName:Object;
      
      private var m_tileFinalPrice:int = 0;
      
      private var totalTileCost:int = 0;
      
      public function LandBundleUnlockFeatureManager(featureName:String)
      {
         super(featureName);
         this.parseTilesDataFromConfig();
         this.m_featureConfigData = new Object();
      }
      
      public static function getInstance(featureName:String = "LandBundleUnlockFeature") : LandBundleUnlockFeatureManager
      {
         return BaseFeatureManager.getInstanceOfClass(featureName,LandBundleUnlockFeatureManager) as LandBundleUnlockFeatureManager;
      }
      
      public function getFeatureData() : Object
      {
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,m_featureName);
         if(!featureData)
         {
            featureData = {};
            featureData[KEY_ACTIVE_TILE_LIST] = [];
         }
         return featureData;
      }
      
      protected function getFeatureOptionsKey(optionName:String) : Object
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,optionName);
      }
      
      protected function saveFeatureOptionsKey(optionName:String, optionsValue:Object) : void
      {
         FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,optionName,optionsValue);
      }
      
      protected function parseTilesDataFromConfig() : void
      {
         var tile:XML = null;
         var tilesConfig:XML = Global.farmGameSettingsManager.getXML().LandBundleUnlockFeatureConfig[0];
         if(tilesConfig.hasOwnProperty("TilesConfigData"))
         {
            this.m_tilesByName = {};
            for each(tile in tilesConfig["TilesConfigData"]["tile"])
            {
               this.m_tilesByName[tile.@name] = tile;
            }
         }
      }
      
      public function getTileData(tileName:String) : XML
      {
         if(this.m_tilesByName)
         {
            return this.m_tilesByName[tileName];
         }
         return null;
      }
      
      public function getTileCost(tileName:String) : Number
      {
         var tileData:XML = this.getTileData(tileName);
         return tileData.@cost;
      }
      
      public function isTilePayer(tileName:String) : Boolean
      {
         var result:Boolean = false;
         var tileData:XML = this.getTileData(tileName);
         if(tileData)
         {
            if(tileData.@type == KEY_PAYER_TILE)
            {
               result = true;
            }
         }
         if(Global.worldManager.currentWorldType != this.CURRENT_FEATURE_WORLD)
         {
            result = true;
         }
         return result;
      }
      
      public function getTotalTilesCost() : int
      {
         var tileName:String = null;
         var tilesList:Array = this.getTileSelectionList();
         var cost:int = 0;
         for each(tileName in tilesList)
         {
            cost += this.getTileCost(tileName);
         }
         return cost;
      }
      
      public function onTileSelected(tileName:String) : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.enableRemoveButton();
         }
         if(m_selectedTileList.length < 4)
         {
            m_selectedTileList.push(tileName);
            this.totalTileCost += this.getTileCost(tileName);
         }
         if(m_selectedTileList.length == 4 && Boolean(this.m_mainWindow))
         {
            this.m_mainWindow.showSelectedTilesMenu();
         }
         FarmStatsManager.count(FEATURE_TRACKING,"tile_select",tileName);
      }
      
      public function onTileUnselected(tileName:String) : void
      {
         var tileIndex:int = m_selectedTileList.indexOf(tileName);
         if(tileIndex != -1 && Boolean(this.m_mainWindow))
         {
            m_selectedTileList.splice(tileIndex,1);
            this.totalTileCost -= this.getTileCost(tileName);
            this.m_mainWindow.showSelectTilesMenu();
         }
         if(Boolean(this.m_mainWindow) && m_selectedTileList.length == 0)
         {
            this.m_mainWindow.disableRemoveButton();
         }
         FarmStatsManager.count(FEATURE_TRACKING,"tile_remove",tileName);
      }
      
      public function canSelectBundle() : Boolean
      {
         var result:Boolean = true;
         if(m_selectedTileList.length == 4 || !this.shouldFeatureContinue())
         {
            result = false;
         }
         return result;
      }
      
      public function shouldFeatureContinue() : Boolean
      {
         var tileData:XML = null;
         var result:Boolean = false;
         var tileLockedCount:Number = 0;
         for each(tileData in this.m_tilesByName)
         {
            if(Global.world.getObjectsByName(tileData.@name).length > 0)
            {
               tileLockedCount++;
            }
         }
         if(tileLockedCount >= 4)
         {
            result = true;
         }
         return result;
      }
      
      public function allTilesPurchased() : Boolean
      {
         var tileData:XML = null;
         var result:Boolean = false;
         var tileLockedCount:Number = 0;
         for each(tileData in this.m_tilesByName)
         {
            if(Global.world.getObjectsByName(tileData.@name).length > 0)
            {
               tileLockedCount++;
            }
         }
         if(tileLockedCount <= 0)
         {
            result = true;
         }
         return result;
      }
      
      public function isTileSelected(tileName:String) : Boolean
      {
         var index:int = m_selectedTileList.indexOf(tileName);
         var result:Boolean = false;
         if(index != -1)
         {
            result = true;
         }
         return result;
      }
      
      public function getDiscountedFinalPrice(tilesArray:Array) : int
      {
         var tileName:String = null;
         var totalCost:int = 0;
         for each(tileName in tilesArray)
         {
            totalCost += this.getTileCost(tileName);
         }
         if(totalCost <= 249)
         {
            totalCost -= totalCost * FIRST_DISCOUNT;
         }
         else if(totalCost <= 399)
         {
            totalCost -= totalCost * SECOND_DISCOUNT;
         }
         else
         {
            totalCost -= totalCost * THIRD_DISCOUNT;
         }
         this.m_tileFinalPrice = totalCost;
         return totalCost;
      }
      
      public function getDiscountPercentage() : int
      {
         var totalCost:Number = this.getTotalTilesCost();
         var discount:int = 0;
         if(totalCost <= 249)
         {
            discount = 10;
         }
         else if(totalCost <= 399)
         {
            discount = 20;
         }
         else
         {
            discount = 30;
         }
         return discount;
      }
      
      public function get mainWindow() : LandBundleUnlockFeatureWindow
      {
         return this.m_mainWindow;
      }
      
      public function onBuyBundleClick(tileArray:Array, finalPrice:int) : void
      {
         this.m_bundleFirstTile = tileArray[0];
         var item:* = Global.world.getObjectsByName(this.m_bundleFirstTile)[0];
         if(item)
         {
            (item as MultiRewardTreasurePayerLandBundleConstructionBuilding).setupBundleDetails(tileArray,finalPrice);
         }
      }
      
      public function isNonPayerTilePrereqMet(itemName:String) : Boolean
      {
         var result:Boolean = false;
         var item:* = Global.world.getObjectsByName(itemName)[0];
         if(item)
         {
            result = (item as MultiRewardTreasurePayerLandBundleConstructionBuilding).isNonPayerTileQuestComplete();
         }
         return result;
      }
      
      public function showMainWindow() : void
      {
         this.m_mainWindow = new LandBundleUnlockFeatureWindow("LandBundleUnlockFeatureWindow","assets/dialogs/borabora/landbundle/FV_xbb_landbundle_main.swf",false);
         UI.displayPopup(this.m_mainWindow,false);
         FarmStatsManager.count(FEATURE_TRACKING,"mainui","open");
      }
      
      public function resetSelectedTileList() : void
      {
         m_selectedTileList = [];
      }
      
      public function getFeatureEndDaysLeftText() : String
      {
         var endTime:Number = NaN;
         var timeLeft:Number = NaN;
         var days:int = 0;
         var dayExpiredTime:Number = NaN;
         var currenttime:Number = NaN;
         endTime = FarmGameUtil.synchronizedDateTimeToNumber(this.END_DATE);
         timeLeft = (endTime - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var result:String = "";
         if(timeLeft < 0)
         {
            timeLeft = 0;
         }
         var timeLeftArray:Array = FarmGameUtil.parseTimeLeft(timeLeft);
         if(Boolean(timeLeftArray) && timeLeftArray.length > 3)
         {
            days = int(timeLeftArray[0]);
            result = days.toString();
            if(days == 1)
            {
               result += " Day left!";
            }
            else if(days == 0)
            {
               dayExpiredTime = FarmGameUtil.getMidnightTimestamp() / 1000 + 86400;
               currenttime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
               timeLeft = dayExpiredTime - currenttime;
               result = timeLeftArray[1] + " Hours left!";
            }
            else
            {
               result += " Days left!";
            }
         }
         return result;
      }
      
      public function addFarmStatsPurchase(cost:int, tilesArray:Array) : void
      {
         var discount:int = 0;
         var tileName:String = null;
         var originalPrice:int = 0;
         for each(tileName in tilesArray)
         {
            originalPrice += this.getTileCost(tileName);
         }
         if(originalPrice <= 249)
         {
            discount = 5;
         }
         else if(originalPrice <= 399)
         {
            discount = 25;
         }
         else
         {
            discount = 35;
         }
         FarmStatsManager.count(FEATURE_TRACKING,"Purchase","",cost.toString(),discount.toString(),"",originalPrice);
      }
      
      public function getTileSelectionList() : Array
      {
         return m_selectedTileList;
      }
   }
}

