package Managers
{
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   
   public class MultiDonateManager
   {
      
      private static const CHARITY_SERVICE:String = "CharityService";
      
      private static const DONATE_CALL:String = "multiDonateClaimRewardItem";
      
      private static const FEATURE_NAME:String = "MultiDonate";
      
      private static var s_instances:Object = {};
      
      private var m_featureName:String;
      
      private var m_bonusItemName:String;
      
      private var m_rewardItemNames:Array;
      
      private var m_rewardItemCosts:Array;
      
      private var m_charityNames:Array;
      
      private var m_featureOptions:Object;
      
      private var m_initialized:Boolean = false;
      
      public function MultiDonateManager(multitonEnforcer:MultitonEnforcer, featureName:String)
      {
         var itemList:XMLList = null;
         var length:int = 0;
         var i:int = 0;
         var rewardItem:XML = null;
         super();
         if(multitonEnforcer == null)
         {
            throw new Error("MultiDonateManagers: use MultiDonateManagers.instanceForFeature()");
         }
         var featureConfig:XML = Global.farmGameSettingsManager.getFeatureXML(featureName);
         if(Boolean(featureConfig) && featureConfig.@type == "FC_MULTI")
         {
            this.m_featureName = featureName;
            this.m_bonusItemName = featureConfig.bonusReward.@name;
            this.m_rewardItemNames = [];
            this.m_rewardItemCosts = [];
            this.m_charityNames = [];
            itemList = featureConfig.items.item;
            length = itemList.length();
            for(i = 0; i < length; i++)
            {
               rewardItem = itemList[i];
               this.m_rewardItemNames[i] = rewardItem.@name.toString();
               this.m_rewardItemCosts[i] = rewardItem.@cost.toString();
               this.m_charityNames[i] = rewardItem.@message.toString();
            }
            this.m_featureOptions = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_NAME,featureName);
            if(!this.m_featureOptions)
            {
               this.m_featureOptions = this.createFeatureOptions();
            }
            this.m_initialized = true;
         }
      }
      
      public static function getInstance(featureName:String) : MultiDonateManager
      {
         var manager:MultiDonateManager = null;
         if(featureName != null && featureName != "")
         {
            if(!s_instances.hasOwnProperty(featureName))
            {
               manager = new MultiDonateManager(new MultitonEnforcer(),featureName);
               if(manager.initialized)
               {
                  s_instances[featureName] = manager;
               }
               else
               {
                  manager = null;
               }
            }
            else
            {
               manager = s_instances[featureName];
            }
         }
         return manager;
      }
      
      public function isClaimed(itemName:String) : Boolean
      {
         var returnValue:Boolean = false;
         if(this.m_featureOptions != null && this.m_featureOptions.hasOwnProperty(itemName))
         {
            returnValue = (this.m_featureOptions[itemName] as Array).length > 0;
         }
         return returnValue;
      }
      
      public function charityForItemName(itemName:String) : String
      {
         var index:int = 0;
         var charityName:String = null;
         if(this.m_rewardItemNames != null)
         {
            index = this.m_rewardItemNames.indexOf(itemName);
            if(index >= 0 && this.m_charityNames != null)
            {
               charityName = this.m_charityNames[index];
            }
         }
         return charityName;
      }
      
      public function get bonusItemName() : String
      {
         return this.m_bonusItemName;
      }
      
      public function get rewardItemNames() : Array
      {
         return this.m_rewardItemNames;
      }
      
      public function get rewardItemCosts() : Array
      {
         return this.m_rewardItemCosts;
      }
      
      public function get charityNames() : Array
      {
         return this.m_charityNames;
      }
      
      public function get featureName() : String
      {
         return this.m_featureName;
      }
      
      public function canClaimRewardBonus() : Boolean
      {
         var numBonusRewarded:Number = NaN;
         var i:int = 0;
         var numDonations:Number = NaN;
         var returnValue:Boolean = false;
         var min:Number = NaN;
         if(Boolean(this.m_featureOptions) && Boolean(this.m_bonusItemName != null) && this.m_featureOptions.hasOwnProperty(this.m_bonusItemName))
         {
            numBonusRewarded = (this.m_featureOptions[this.m_bonusItemName] as Array).length;
            for(i = 0; i < this.m_rewardItemNames.length; i++)
            {
               numDonations = (this.m_featureOptions[this.m_rewardItemNames[i]] as Array).length;
               if(isNaN(min) || numDonations < min)
               {
                  min = numDonations;
               }
            }
            if(!isNaN(min) && min > numBonusRewarded)
            {
               returnValue = true;
            }
         }
         return returnValue;
      }
      
      public function tryClaimRewardBonus() : Boolean
      {
         var returnValue:Boolean = false;
         if(this.canClaimRewardBonus())
         {
            Global.player.addGift(this.m_bonusItemName);
            (this.m_featureOptions[this.m_bonusItemName] as Array).push(GlobalEngine.serverTime);
            returnValue = true;
         }
         return returnValue;
      }
      
      public function buyItemForCharity(rewardItemName:String, callback:Function = null) : Boolean
      {
         var index:int = 0;
         var cost:int = 0;
         var returnValue:Boolean = false;
         if(this.m_rewardItemNames != null && rewardItemName != null && this.m_featureOptions != null && this.m_featureOptions.hasOwnProperty(rewardItemName))
         {
            index = this.m_rewardItemNames.indexOf(rewardItemName);
            if(index >= 0)
            {
               cost = int(this.m_rewardItemCosts[index]);
               if(cost >= 0 && Global.player.canBuyCash(cost))
               {
                  Global.player.cash -= cost;
                  Global.player.addGift(rewardItemName);
                  (this.m_featureOptions[rewardItemName] as Array).push(GlobalEngine.serverTime);
                  TransactionManager.addTransaction(new TGenericTransaction(CHARITY_SERVICE,DONATE_CALL,callback,[this.m_featureName,rewardItemName]),true);
                  returnValue = true;
               }
            }
         }
         return returnValue;
      }
      
      private function createFeatureOptions() : Object
      {
         var itemName:String = null;
         var featureOptions:Object = null;
         if(this.m_bonusItemName != null && this.m_rewardItemNames != null)
         {
            featureOptions = {};
            featureOptions[this.m_bonusItemName] = [];
            for each(itemName in this.m_rewardItemNames)
            {
               featureOptions[itemName] = [];
            }
         }
         return featureOptions;
      }
      
      public function get initialized() : Boolean
      {
         return this.m_initialized;
      }
   }
}

class MultitonEnforcer
{
   
   public function MultitonEnforcer()
   {
      super();
   }
}
