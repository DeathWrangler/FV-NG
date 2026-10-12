package DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.Building
{
   import DataObjects.BaseDataObject;
   
   public class PartRequestTypeRequestDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var type:String;
      
      [XmlAttribute]
      public var prereq:String;
      
      public function PartRequestTypeRequestDO()
      {
         super();
      }
   }
}

