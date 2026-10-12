package DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.Building
{
   import DataObjects.BaseDataObject;
   
   public class ItemTierDO extends BaseDataObject
   {
      
      [XmlAttribute(§default§="-2147483648")]
      public var id:int;
      
      [XmlAttribute]
      public var market:String;
      
      public var additionalStorage:int;
      
      public var levelRequired:int;
      
      public var cost:int;
      
      public var buyXp:int;
      
      public var neighborKey:String;
      
      public var additionalNeighbors:int;
      
      public var neighborMinimum:int;
      
      public var neighborMaximum:int;
      
      public var sellPrice:int;
      
      public var cash:int;
      
      public function ItemTierDO()
      {
         super();
      }
   }
}

