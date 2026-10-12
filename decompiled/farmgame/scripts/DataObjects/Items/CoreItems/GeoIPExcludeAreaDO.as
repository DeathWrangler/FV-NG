package DataObjects.Items.CoreItems
{
   import DataObjects.BaseDataObject;
   
   public class GeoIPExcludeAreaDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var area:String;
      
      public function GeoIPExcludeAreaDO()
      {
         super();
      }
   }
}

