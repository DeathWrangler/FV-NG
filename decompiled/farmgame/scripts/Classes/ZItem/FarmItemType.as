package Classes.ZItem
{
   import Classes.GrowableAnimalItem;
   import Classes.LandBundleUnlockFeatureTreasureConstructionBuilding;
   import DataObjects.Items.BaseItemDO;
   
   public class FarmItemType
   {
      
      private static var s_typeClassHash:Object;
      
      public static const ANIMAL:String = "animal";
      
      public static const BUFF:String = "buff";
      
      public static const BUILDING:String = "building";
      
      public static const BUSHEL:String = "bushel";
      
      public static const CHANGE_FARM:String = "change_farm";
      
      public static const CLOTHING:String = "clothing";
      
      public static const CONSUMABLE:String = "consumable";
      
      public static const CRAFTED:String = "crafted";
      
      public static const CURRENCY_EXCHANGE:String = "currency_exchange";
      
      public static const DECORATION:String = "decoration";
      
      public static const EGG:String = "egg";
      
      public static const FUEL:String = "fuel";
      
      public static const ITEM_BUFF:String = "itembuff";
      
      public static const LIMITED:String = "limited";
      
      public static const MESSAGE_SIGN:String = "messageSign";
      
      public static const MISSION:String = "mission";
      
      public static const PLOT:String = "plot";
      
      public static const SEED:String = "seed";
      
      public static const STARTER_PACK:String = "starter_pack";
      
      public static const TREE:String = "tree";
      
      public static const TURBO:String = "turbo";
      
      public static const UGC_ITEM_PART:String = "ugc_part";
      
      public static const VEHICLE:String = "vehicle";
      
      public static const BLOOM:String = "bloom";
      
      public static const GOPHER:String = "gopher";
      
      public static const EXPANSION_ACCESS:String = "expansionAccess";
      
      public static const BLOSSOM:String = "blossom";
      
      public static const PORTAL:String = "portal";
      
      public function FarmItemType()
      {
         super();
      }
      
      private static function populateTypeHash() : void
      {
         s_typeClassHash = new Object();
         s_typeClassHash[ANIMAL] = AnimalItem;
         s_typeClassHash[BUFF] = BuffItem;
         s_typeClassHash[BUILDING] = BuildingItem;
         s_typeClassHash[BUSHEL] = BushelItem;
         s_typeClassHash[CHANGE_FARM] = ChangeFarmItem;
         s_typeClassHash[CLOTHING] = ClothingItem;
         s_typeClassHash[CONSUMABLE] = ConsumableItem;
         s_typeClassHash[CURRENCY_EXCHANGE] = ExchangeCurrencyItem;
         s_typeClassHash[DECORATION] = DecorationItem;
         s_typeClassHash[FUEL] = FuelItem;
         s_typeClassHash[SEED] = SeedItem;
         s_typeClassHash[STARTER_PACK] = StarterPackItem;
         s_typeClassHash[TURBO] = TurboItem;
         s_typeClassHash[TREE] = TreeItem;
         s_typeClassHash[VEHICLE] = EquipmentItem;
         s_typeClassHash[BLOOM] = BuildingItem;
         s_typeClassHash[GOPHER] = GopherItem;
         s_typeClassHash[EXPANSION_ACCESS] = ExpansionAccessItem;
         s_typeClassHash[ANIMAL + "Pet"] = PetFarmItem;
         s_typeClassHash[ANIMAL + "UGCAnimal"] = UGCAnimalItem;
         s_typeClassHash[BUILDING + "MarketStallBuilding"] = MarketStallBuildingItem;
         s_typeClassHash[DECORATION + "UGCDecoration"] = UGCDecorationItem;
         s_typeClassHash[ANIMAL + "GrowableAnimal"] = GrowableAnimalItem;
         s_typeClassHash[ANIMAL + "EvolutionAnimal"] = EvolutionAnimalItem;
         s_typeClassHash[BUILDING + "MultiRewardTreasurePayerConstructionBuilding"] = MultiRewardTreasureConstructionBuildingItem;
         s_typeClassHash[BUILDING + "MultiRewardTreasurePayerBundleConstructionBuilding"] = MultiRewardTreasureConstructionBuildingItem;
         s_typeClassHash[BUILDING + "MultiRewardTreasurePayerLandBundleConstructionBuilding"] = MultiRewardTreasureConstructionBuildingItem;
         s_typeClassHash[BUILDING + "LandBundleUnlockFeatureTreasureConstructionBuilding"] = LandBundleUnlockFeatureTreasureConstructionBuilding;
         s_typeClassHash[BUILDING + "MultiRewardTreasureConstructionBuilding"] = MultiRewardTreasureConstructionBuildingItem;
         s_typeClassHash[ANIMAL + "MutableDragon"] = MutableDragonItem;
         s_typeClassHash[PORTAL + "stencil"] = StencilPortalItem;
         s_typeClassHash[BLOSSOM] = BuildingItem;
      }
      
      public static function getItemClassByType(xml:XML, dataObject:BaseItemDO = null, optItem:Object = null) : Class
      {
         var type:String = null;
         var className:String = null;
         var itemClass:Class = null;
         if(s_typeClassHash == null)
         {
            populateTypeHash();
         }
         if(optItem)
         {
            type = optItem.type;
            className = optItem.className;
         }
         else if(dataObject)
         {
            type = dataObject.type;
            className = dataObject.className;
         }
         else
         {
            type = xml.@type;
            className = xml.@className;
         }
         if(s_typeClassHash[type + className])
         {
            itemClass = s_typeClassHash[type + className];
         }
         else if(s_typeClassHash[type])
         {
            itemClass = s_typeClassHash[type];
         }
         else
         {
            itemClass = FarmItem;
         }
         return itemClass;
      }
   }
}

