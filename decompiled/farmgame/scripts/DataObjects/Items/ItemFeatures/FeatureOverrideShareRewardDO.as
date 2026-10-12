package DataObjects.Items.ItemFeatures
{
   import DataObjects.BaseDataObject;
   
   public class FeatureOverrideShareRewardDO extends BaseDataObject
   {
      
      public var isOverride:String;
      
      [XmlAttribute]
      public var lootTableName:String;
      
      public function FeatureOverrideShareRewardDO()
      {
         super();
      }
      
      override public function toString() : String
      {
         if(this.isOverride == null)
         {
            this.isOverride = "false";
         }
         return this.isOverride;
      }
   }
}

