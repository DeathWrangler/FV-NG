package Managers
{
   public class LimitedGiftingManager
   {
      
      protected var m_featureName:String = "";
      
      private var m_featureConfig:FeatureConfigManager;
      
      private var m_preselectIndices:Array;
      
      public function LimitedGiftingManager(featureName:String)
      {
         super();
         this.m_featureName = featureName;
         this.m_featureConfig = FeatureConfigManager.getFeatureConfiguration(this.m_featureName);
         this.getFeatureConfiguration();
      }
      
      private function getFeatureConfiguration() : void
      {
         var child:XML = null;
         var node:XML = Global.farmGameSettingsManager.getFeatureXML(this.m_featureName);
         if(node)
         {
            if(node.hasOwnProperty("preselectExperiments"))
            {
               for each(child in node.preselectExperiments.children())
               {
                  if(child.@variant == Global.experimentManager.getExperimentVariant(child.@experiment))
                  {
                     this.m_preselectIndices = child.@value.split(",");
                     break;
                  }
               }
            }
         }
      }
      
      public function get preselectIndices() : Array
      {
         return this.m_preselectIndices;
      }
      
      public function get giftingCurrency() : String
      {
         return this.m_featureConfig.getStringConstant("giftingCurrency");
      }
      
      public function get isGiftingWithChoice() : Boolean
      {
         return this.m_featureConfig.getBooleanConstant("isGiftingWithChoice");
      }
      
      public function isFeatureVisible() : Boolean
      {
         return this.m_featureConfig.isFeatureVisible();
      }
      
      public function get giftableItems() : Array
      {
         if(this.m_featureConfig.getStringConstant("giftableItems") != null)
         {
            return this.m_featureConfig.getStringConstant("giftableItems").split(",");
         }
         return null;
      }
      
      public function get giftableItem() : String
      {
         return this.m_featureConfig.getStringConstant("giftableItem");
      }
      
      public function get appreciationItem() : String
      {
         return this.m_featureConfig.getStringConstant("appreciationItem");
      }
      
      public function get location() : String
      {
         return this.m_featureConfig.getStringConstant("location");
      }
      
      public function get npcUrl() : String
      {
         return this.m_featureConfig.getStringConstant("npcUrl");
      }
      
      public function getUSDCost() : Number
      {
         return this.m_featureConfig.getNumberConstant("USDCost");
      }
   }
}

