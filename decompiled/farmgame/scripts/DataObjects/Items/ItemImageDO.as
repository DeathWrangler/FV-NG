package DataObjects.Items
{
   import DataObjects.BaseDataObject;
   
   public class ItemImageDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var name:String;
      
      [XmlAttribute]
      public var url:String;
      
      [XmlAttribute]
      public var loadClass:String;
      
      [XmlAttribute]
      public var prefix:String;
      
      [XmlAttribute]
      public var fv_perf_multiple_buildable_swfs:Boolean;
      
      [XmlAttribute]
      public var trackAnimation:String;
      
      [XmlAttribute]
      public var label:String;
      
      [XmlAttribute(§default§="-2147483648")]
      public var lowResBitmapFrame:int;
      
      [XmlAttribute]
      public var prefixUrl:String;
      
      [XmlAttribute]
      public var suffixUrl:String;
      
      [XmlAttribute]
      public var embeddedSound:Boolean;
      
      [XmlAttribute]
      public var rasterUrl:String;
      
      [XmlAttribute]
      public var pixelPerfectPick:String;
      
      public function ItemImageDO()
      {
         super();
      }
   }
}

