package Managers
{
   import Classes.Constants.PrerequisiteConstants;
   import Classes.util.FarmGameUtil;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.LightningDealsCongratsWindow;
   import Widgets.Windows.LightningDealsMainWindow;
   import flash.utils.Dictionary;
   
   public class LightningDealManager extends BaseFeatureManager
   {
      
      public static const FEATURE_NAME:String = "lightning_deals";
      
      private static const DEALS:String = "deals";
      
      private static const DEALTIME:String = "dealTime";
      
      private static const DEPLETIONTIME:String = "depletionTime";
      
      private static const FEATURESTARTTIME:String = "featureStartTime";
      
      private static const DEPLETIONRATE:String = "depletionRate";
      
      private static const TUNINGS:String = "tunings";
      
      private var m_featureXml:XML;
      
      private var m_featureConfigData:Object;
      
      private var m_featureRuntimeData:Object;
      
      private var m_presentDealIndex:int = -1;
      
      private var m_selectedTab:int = 1;
      
      private var m_claimedPercent:int = 0;
      
      private var depletionCounts:int = 0;
      
      private var m_dealCounts:int = 0;
      
      private var m_ldmw:LightningDealsMainWindow;
      
      private var m_disabledDealTypes:Dictionary;
      
      private var m_bundleIndexBoughtInDeal:int = 0;
      
      private var m_count:int = 0;
      
      public function LightningDealManager(featureName:String, featureConfig:XML = null)
      {
         super(featureName,featureConfig);
         this.m_featureXml = Global.farmGameSettingsManager.getFeatureXML(m_featureName);
         this.m_featureConfigData = new Object();
         this.m_featureRuntimeData = new Object();
         this.setConfigData();
         this.updateDealIndices();
         this.sendTuningTransaction();
         this.updateClaimedPercentage();
      }
      
      public static function getInstance(featureName:String = "lightning_deals") : LightningDealManager
      {
         return BaseFeatureManager.getInstanceOfClass(featureName,LightningDealManager) as LightningDealManager;
      }
      
      private function getFeatureStartTime() : Number
      {
         var startTime:String = null;
         var requirement:Object = null;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("lightning_deals_feature_enabled");
         var requirementsArray:Array = prereq[FarmGameSettingsManager.XML_CHILDREN_FIELD];
         for each(requirement in requirementsArray)
         {
            if(requirement.type == PrerequisiteConstants.PREREQUISITE_START_TIME)
            {
               startTime = requirement.value;
               break;
            }
         }
         return FarmGameUtil.synchronizedDateTimeToNumber(startTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
      }
      
      public function getFeatureOption() : Object
      {
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_NAME,FEATURE_NAME);
         if(!featureData)
         {
            featureData = new Object();
            FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_NAME,FEATURE_NAME,featureData);
         }
         return featureData;
      }
      
      public function setFeatureOption(featureData:Object) : void
      {
         FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_NAME,FEATURE_NAME,featureData);
      }
      
      public function set bundleIndexBoughtInDeal(index:int) : void
      {
         this.m_bundleIndexBoughtInDeal = index;
      }
      
      public function get bundleIndexBoughtInDeal() : int
      {
         return this.m_bundleIndexBoughtInDeal;
      }
      
      public function showMainUI() : void
      {
         UI.displayPopup(this.m_ldmw = new LightningDealsMainWindow(FEATURE_NAME,"assets/dialogs/LightningDeals2017/FV_LightningDeals2017.swf"));
      }
      
      public function set selectedTab(selectedTab:int) : void
      {
         this.m_selectedTab = selectedTab;
      }
      
      public function get selectedTab() : int
      {
         return this.m_selectedTab;
      }
      
      private function setConfigData() : void
      {
         var deal:XML = null;
         var dealNumber:String = null;
         var item:XML = null;
         var boughtFlag:Boolean = false;
         this.m_featureConfigData[DEALTIME] = int(this.m_featureXml.constants.@visibleLevel.toString());
         this.m_featureConfigData[FEATURESTARTTIME] = this.getFeatureStartTime();
         this.m_featureConfigData[DEPLETIONRATE] = int(this.m_featureXml.constants.@replenishRate.toString()) / 1000;
         this.m_featureConfigData[DEPLETIONTIME] = int(this.m_featureXml.constants.@harvestThrottleSeconds.toString());
         this.m_featureConfigData[DEALS] = new Object();
         var m_featureData:Object = this.getFeatureOption();
         for each(deal in this.m_featureXml.divisions.division)
         {
            dealNumber = deal.@index;
            ++this.m_dealCounts;
            this.m_featureConfigData[DEALS][deal.@index] = new Array();
            for each(item in deal.items.item)
            {
               boughtFlag = false;
               if(m_featureData.hasOwnProperty(item.@code.toString()) && m_featureData[item.@code.toString()] > 0)
               {
                  boughtFlag = true;
               }
               this.m_featureConfigData[DEALS][deal.@index].push({
                  "dealIndex":dealNumber,
                  "index":item.@index.toString(),
                  "code":item.@code.toString(),
                  "bundleName":"bundle" + deal.@index,
                  "claimed":"55",
                  "bought":boughtFlag,
                  "factor":1,
                  "cost":item.@cost.toString(),
                  "maxCap":0
               });
            }
         }
      }
      
      public function updateBoughtStatus(code:String) : void
      {
         var bundleItemIndex:String = null;
         for(bundleItemIndex in this.m_featureConfigData[DEALS][this.m_presentDealIndex])
         {
            if(this.m_featureConfigData[DEALS][this.m_presentDealIndex][bundleItemIndex]["code"] == code)
            {
               this.m_featureConfigData[DEALS][this.m_presentDealIndex][bundleItemIndex]["bought"] = true;
               break;
            }
         }
      }
      
      private function updateClaimedPercentage(updateMainWindowFlag:Boolean = true) : void
      {
         var timePresentInCurrentDeal:Number = this.getTimeInPresentDeal();
         var newDepletionCount:int = timePresentInCurrentDeal / this.m_featureConfigData[DEPLETIONTIME];
         if(newDepletionCount != this.depletionCounts)
         {
            this.depletionCounts = newDepletionCount;
            this.m_claimedPercent = this.depletionCounts * this.m_featureConfigData[DEPLETIONRATE];
            if(updateMainWindowFlag)
            {
               this.updateMainWindow();
            }
         }
      }
      
      private function updateCurrentDealsTabTag() : void
      {
         var timePresentInCurrentDeal:Number = NaN;
         var newDealFlag:Boolean = false;
         var expiringDealFlag:Boolean = false;
         if(this.m_ldmw)
         {
            timePresentInCurrentDeal = this.getTimeInPresentDeal();
            newDealFlag = timePresentInCurrentDeal < FarmGameUtil.NUM_SECS_IN_HOUR;
            expiringDealFlag = this.m_featureConfigData[DEALTIME] - timePresentInCurrentDeal < FarmGameUtil.NUM_SECS_IN_HOUR;
            this.m_ldmw.updateNewTag(newDealFlag);
            this.m_ldmw.updateExpiryTag(expiringDealFlag);
         }
      }
      
      public function get claimPercent() : int
      {
         return this.m_claimedPercent;
      }
      
      public function getTimeInPresentDeal() : Number
      {
         var currentTime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         return currentTime - this.m_featureConfigData[FEATURESTARTTIME] - (this.m_presentDealIndex - 1) * this.m_featureConfigData[DEALTIME];
      }
      
      public function getTimeLeftInPresentDeal() : Number
      {
         return this.m_featureConfigData[DEALTIME] - this.getTimeInPresentDeal();
      }
      
      private function updateDealIndices() : void
      {
         var dealNumber:int = this.getDealIndex();
         if(this.m_presentDealIndex != dealNumber)
         {
            this.m_presentDealIndex = dealNumber;
            this.updateClaimedPercentage(false);
            this.updateAndGetDisabledDealTypes();
            this.updateMainWindow();
         }
      }
      
      public function updateAndGetDisabledDealTypes() : Dictionary
      {
         this.m_disabledDealTypes = null;
         this.m_disabledDealTypes = new Dictionary();
         if(this.m_presentDealIndex - 1 < 1 || this.m_presentDealIndex - 1 > this.m_dealCounts)
         {
            this.m_disabledDealTypes["0"] = true;
         }
         if(this.m_presentDealIndex < 1 || this.m_presentDealIndex > this.m_dealCounts)
         {
            this.m_disabledDealTypes["1"] = true;
         }
         if(this.m_presentDealIndex + 1 < 1 || this.m_presentDealIndex + 1 > this.m_dealCounts)
         {
            this.m_disabledDealTypes["2"] = true;
         }
         return this.m_disabledDealTypes;
      }
      
      public function getDealDataByType(dealType:int = 1) : Array
      {
         var dealNumber:int = this.m_presentDealIndex - 1 + dealType;
         if(this.m_featureConfigData[DEALS].hasOwnProperty(dealNumber))
         {
            return this.m_featureConfigData[DEALS][dealNumber];
         }
         return null;
      }
      
      private function sendTuningTransaction() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction("LightningDealService","getRuntimeData",this.updateTuning,[FEATURE_NAME]));
      }
      
      private function updateTuning(result:Object) : void
      {
         var code:String = null;
         var m_newRuntimeData:Boolean = false;
         for(code in result[TUNINGS])
         {
            if(!this.m_featureRuntimeData.hasOwnProperty(code))
            {
               this.m_featureRuntimeData[code] = new Array();
               this.m_featureRuntimeData[code][0] = 0;
               this.m_featureRuntimeData[code][1] = "";
               m_newRuntimeData = true;
            }
            if(this.m_featureRuntimeData.hasOwnProperty(code) && (this.m_featureRuntimeData[code][0] != result[TUNINGS][code][0] || this.m_featureRuntimeData[code][1] != result[TUNINGS][code][1]))
            {
               this.m_featureRuntimeData[code][0] = result[TUNINGS][code][0];
               this.m_featureRuntimeData[code][1] = result[TUNINGS][code][1];
               m_newRuntimeData = true;
            }
         }
         if(m_newRuntimeData)
         {
            this.updateConfigData();
            this.updateMainWindow();
         }
      }
      
      private function updateConfigData() : void
      {
         var dealIndex:String = null;
         var bundleItemIndex:String = null;
         var code:String = null;
         for(dealIndex in this.m_featureConfigData[DEALS])
         {
            for(bundleItemIndex in this.m_featureConfigData[DEALS][dealIndex])
            {
               code = this.m_featureConfigData[DEALS][dealIndex][bundleItemIndex]["code"];
               if(this.m_featureRuntimeData.hasOwnProperty(code))
               {
                  this.m_featureConfigData[DEALS][dealIndex][bundleItemIndex]["factor"] = this.m_featureRuntimeData[code][0];
                  this.m_featureConfigData[DEALS][dealIndex][bundleItemIndex]["maxCap"] = this.m_featureRuntimeData[code][1];
               }
            }
         }
      }
      
      private function updateMainWindow() : void
      {
         if(this.m_ldmw)
         {
            this.m_ldmw.updateUI(this.getDealDataByType(this.m_selectedTab),this.m_disabledDealTypes);
         }
      }
      
      private function getDealIndex() : int
      {
         var currentTime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var timeDiff:Number = currentTime - this.m_featureConfigData[FEATURESTARTTIME];
         return int(timeDiff / this.m_featureConfigData[DEALTIME] + 1);
      }
      
      public function updateOnRewardBuy(bundleFriendlyName:String, bundleName:String) : void
      {
         var code:String = Global.farmGameSettingsManager.getFarmItemCodeByName(bundleName);
         var fd:Object = this.getFeatureOption();
         fd[code] = 1;
         this.setFeatureOption(fd);
         this.updateBoughtStatus(code);
         Global.player.addGift(bundleName);
         UI.displayPopup(new LightningDealsCongratsWindow("assets/dialogs/LightningDeals2017/FV_LightningDeals2017_Congrats.swf",this.bundleIndexBoughtInDeal,bundleFriendlyName,bundleName),false);
      }
      
      public function updateFeature() : void
      {
         this.updateClaimedPercentage();
         if(this.m_count++ > 2)
         {
            this.sendTuningTransaction();
            this.m_count = 0;
         }
         this.updateDealIndices();
         this.updateCurrentDealsTabTag();
      }
   }
}

