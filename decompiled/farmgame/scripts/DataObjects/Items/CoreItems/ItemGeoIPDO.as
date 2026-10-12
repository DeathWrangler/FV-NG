package DataObjects.Items.CoreItems
{
   import DataObjects.BaseDataObject;
   
   public class ItemGeoIPDO extends BaseDataObject
   {
      
      public var includeData:Array;
      
      public var excludeArea:GeoIPExcludeAreaDO;
      
      public var includeArea:GeoIPIncludeAreaDO;
      
      public function ItemGeoIPDO()
      {
         super();
      }
   }
}

