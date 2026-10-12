package DataObjects.Items.CoreItems
{
   import DataObjects.BaseDataObject;
   
   public class GeoIPIncludeAreaDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var area:String;
      
      public function GeoIPIncludeAreaDO()
      {
         super();
      }
   }
}

