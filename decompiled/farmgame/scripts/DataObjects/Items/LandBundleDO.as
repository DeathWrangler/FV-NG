package DataObjects.Items
{
   import DataObjects.BaseDataObject;
   
   public class LandBundleDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var name:String;
      
      [XmlAttribute]
      public var subtype:String;
      
      public function LandBundleDO()
      {
         super();
      }
   }
}

