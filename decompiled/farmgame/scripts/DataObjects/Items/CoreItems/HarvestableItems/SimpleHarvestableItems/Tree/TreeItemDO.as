package DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.Tree
{
   import DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.SimpleHarvestableItemDO;
   
   public class TreeItemDO extends SimpleHarvestableItemDO
   {
      
      [XmlAttribute]
      public var thankYouGift:String;
      
      public var excludeSeedling:Boolean;
      
      public var nextLevel:String;
      
      public function TreeItemDO()
      {
         super();
      }
   }
}

