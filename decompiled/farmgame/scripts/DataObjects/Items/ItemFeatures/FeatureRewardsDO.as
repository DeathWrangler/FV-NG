package DataObjects.Items.ItemFeatures
{
   import DataObjects.BaseDataObject;
   
   public class FeatureRewardsDO extends BaseDataObject
   {
      
      public var prereqs:FeaturePrereqsDO;
      
      public var reward:Array;
      
      public function FeatureRewardsDO()
      {
         super();
      }
   }
}

