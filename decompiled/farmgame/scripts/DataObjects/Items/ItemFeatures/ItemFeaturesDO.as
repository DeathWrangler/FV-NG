package DataObjects.Items.ItemFeatures
{
   import DataObjects.BaseDataObject;
   
   public class ItemFeaturesDO extends BaseDataObject
   {
      
      public var feature:Array;
      
      public function ItemFeaturesDO()
      {
         super();
         this.feature = new Array();
      }
   }
}

