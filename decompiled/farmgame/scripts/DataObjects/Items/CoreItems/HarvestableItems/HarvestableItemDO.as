package DataObjects.Items.CoreItems.HarvestableItems
{
   import DataObjects.Items.CoreItems.CoreItemDO;
   
   public class HarvestableItemDO extends CoreItemDO
   {
      
      public var bypassMasteryLevelLock:int;
      
      public var harvestItem:String;
      
      public var harvestItemChance:Number;
      
      public var masteryTarget:String;
      
      public function HarvestableItemDO()
      {
         super();
      }
   }
}

