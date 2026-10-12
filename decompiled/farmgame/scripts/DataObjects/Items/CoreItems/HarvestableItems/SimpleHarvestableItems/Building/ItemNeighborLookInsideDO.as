package DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.Building
{
   import DataObjects.BaseDataObject;
   
   public class ItemNeighborLookInsideDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var experiment:String;
      
      public var canLookInside:String;
      
      public function ItemNeighborLookInsideDO()
      {
         super();
      }
      
      override public function toString() : String
      {
         return _toString(this.canLookInside);
      }
   }
}

