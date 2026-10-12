package DataObjects.Items.ItemFeatures
{
   public class StorageFeatureDO extends ItemFeatureDO
   {
      
      public var capacity:int;
      
      public var limitedEnd:String;
      
      public var storageSize:int;
      
      public var suppressDialog:Boolean;
      
      public var surfaceBuildingOnFull:Boolean;
      
      public var surfaceExpandOnFull:Boolean;
      
      public function StorageFeatureDO()
      {
         super();
      }
   }
}

