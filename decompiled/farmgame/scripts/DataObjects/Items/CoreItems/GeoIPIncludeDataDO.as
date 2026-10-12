package DataObjects.Items.CoreItems
{
   import DataObjects.BaseDataObject;
   
   public class GeoIPIncludeDataDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var country:String;
      
      public function GeoIPIncludeDataDO()
      {
         super();
      }
   }
}

