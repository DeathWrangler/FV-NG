package DataObjects.Items.ItemFeatures
{
   import DataObjects.Items.ItemFriendRewardsDO;
   
   public class ExpandFeatureDO extends ItemFeatureDO
   {
      
      public var awardDialog:String;
      
      public var awardDialogBackground:String;
      
      public var awardExperiment:FeatureAwardExperimentDO;
      
      public var expandPriceTest:FeatureExpandPriceTestDO;
      
      public var experimentGate:String;
      
      public var frictionless:Boolean;
      
      public var friendRewards:ItemFriendRewardsDO;
      
      public var icon:String;
      
      public var inAppPurchase:Boolean;
      
      public var infiniteUpgradeData:FeatureInfiniteUpgradeDataDO;
      
      public var showExpansionOnBuild:Boolean;
      
      public var upgradeMax:int;
      
      public var upgrade:Array;
      
      public function ExpandFeatureDO()
      {
         super();
      }
   }
}

