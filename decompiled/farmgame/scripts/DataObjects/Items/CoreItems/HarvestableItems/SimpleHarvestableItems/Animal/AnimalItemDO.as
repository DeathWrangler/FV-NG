package DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.Animal
{
   import DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.SimpleHarvestableItemDO;
   
   public class AnimalItemDO extends SimpleHarvestableItemDO
   {
      
      [XmlAttribute]
      public var canAdopt:Boolean;
      
      [XmlAttribute]
      public var collection:String;
      
      [XmlAttribute]
      public var consumable:Boolean;
      
      [XmlAttribute]
      public var customizable:Boolean;
      
      [XmlAttribute(§default§="-2147483648")]
      public var lostAnimalProbWeight:int;
      
      [XmlAttribute]
      public var rescue:Boolean;
      
      public var adult:String;
      
      public var animalLevel:int;
      
      public var animalType:String;
      
      public var brandPromoName:String;
      
      public var breedingAdult:String;
      
      public var breedingBuildingType:String;
      
      public var calf:String;
      
      public var disallowWander:int;
      
      public var feedItem:String;
      
      public var foal:String;
      
      public var giftAcceptFooter:String;
      
      public var growCompleteDialogString:String;
      
      public var growDialogDisplayString:String;
      
      public var growPrice:String;
      
      public var imageProgressionClass:String;
      
      public var imageScaleAdult:Number;
      
      public var kibbleBonus:int;
      
      public var max:int;
      
      public var patterns:String;
      
      public var petLootTable:String;
      
      public var rasterThreshold:int;
      
      public var stallion:Boolean;
      
      public var storageDialog:String;
      
      public var substitution_string:String;
      
      public var transform:String;
      
      public var truffleType:String;
      
      public var wanderSpeed:int;
      
      public var shareFeedRewardItem:String;
      
      public function AnimalItemDO()
      {
         super();
      }
   }
}

