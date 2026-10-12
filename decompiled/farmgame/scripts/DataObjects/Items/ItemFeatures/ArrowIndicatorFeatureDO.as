package DataObjects.Items.ItemFeatures
{
   public class ArrowIndicatorFeatureDO extends ItemFeatureDO
   {
      
      public var craftSkill:String;
      
      public var craftSpecialization:String;
      
      public var featureFrequency:FeatureFrequencyDO;
      
      public var onbydefault:String;
      
      public var sessionSeenFlag:String;
      
      public var showInterval:int;
      
      public var state:Array;
      
      public function ArrowIndicatorFeatureDO()
      {
         super();
      }
   }
}

