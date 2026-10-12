package DataObjects.Items.Vehicle
{
   import DataObjects.BaseDataObject;
   
   public class SimpleZAttributeTagsPlaneFlightGrantDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var isOneTimeOnly:Boolean;
      
      [XmlAttribute(§default§="-2147483648")]
      public var number:int;
      
      public function SimpleZAttributeTagsPlaneFlightGrantDO()
      {
         super();
      }
   }
}

