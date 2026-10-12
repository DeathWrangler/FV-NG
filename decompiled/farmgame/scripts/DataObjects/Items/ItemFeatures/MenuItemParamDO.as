package DataObjects.Items.ItemFeatures
{
   import DataObjects.BaseDataObject;
   
   public class MenuItemParamDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var name:String;
      
      [XmlAttribute]
      public var value:String;
      
      public function MenuItemParamDO()
      {
         super();
      }
   }
}

