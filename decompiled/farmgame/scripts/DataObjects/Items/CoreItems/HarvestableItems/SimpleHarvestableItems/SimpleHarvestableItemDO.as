package DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems
{
   import DataObjects.Items.CoreItems.HarvestableItems.HarvestableItemDO;
   
   public class SimpleHarvestableItemDO extends HarvestableItemDO
   {
      
      [XmlAttribute]
      public var dontUseAnimation:Boolean;
      
      [XmlAttribute]
      public var placementFeed:Boolean;
      
      [XmlAttribute]
      public var shareFeed:Boolean;
      
      public var addDefaultItemsOnce:Boolean;
      
      public var aoe:ItemAOEDO;
      
      public var baby:String;
      
      public var bypassLimitedEndForHarvest:Boolean;
      
      public var coin:int;
      
      public var featureFriendSet:String;
      
      public var hasLights:int;
      
      public var hasMetadata:Boolean;
      
      public var initialExpansionLevel:int;
      
      public var labCraftingLootTable:String;
      
      public var resourcePrefix:String;
      
      public var sounds:ItemSoundsDO;
      
      public var statsCounter:String;
      
      public var ugcTransforms:ItemUGCTransformsDO;
      
      public function SimpleHarvestableItemDO()
      {
         super();
      }
   }
}

