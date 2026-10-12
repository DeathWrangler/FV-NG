package DataObjects.Items
{
   import DataObjects.BaseDataObject;
   
   public class ItemRequirementsDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var compare:String;
      
      public var requirement:Array;
      
      public function ItemRequirementsDO()
      {
         super();
      }
   }
}

