package DataObjects.Items.ItemFeatures
{
   public class GrowableFeatureDO extends ItemFeatureDO
   {
      
      public var growthConsumable:String;
      
      public var maxConsumables:int;
      
      public var growthMastery:Boolean;
      
      public var stages:FeatureStagesDO;
      
      public function GrowableFeatureDO()
      {
         super();
      }
   }
}

