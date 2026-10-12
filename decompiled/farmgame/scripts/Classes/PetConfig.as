package Classes
{
   import Classes.ZItem.PetFarmItem;
   import Classes.util.ZLocUtils;
   
   public class PetConfig
   {
      
      public function PetConfig()
      {
         super();
      }
      
      public static function getPetItemsBySet(itemName:String) : Array
      {
         var petFarmItem:PetFarmItem = null;
         var petSets:XMLList = null;
         var petSet:XML = null;
         var item:XML = null;
         var petItems:Array = [];
         var petDataXml:XMLList = Global.farmGameSettingsManager.getPetDataXml();
         if(petDataXml.pets.pet)
         {
            petSets = petDataXml.pets.pet.(@name == itemName);
            if(petSets)
            {
               petSet = petSets[0];
               if(petSet.item)
               {
                  for each(item in petSet.item)
                  {
                     petFarmItem = Global.farmGameSettingsManager.getFarmItemByName(item.@name) as PetFarmItem;
                     if(petFarmItem)
                     {
                        petFarmItem.init(petSet,item);
                        petItems.push(petFarmItem);
                     }
                  }
               }
            }
         }
         return petItems;
      }
      
      public static function getPetItem(itemName:String) : PetFarmItem
      {
         var petSets:XMLList = null;
         var petSet:XML = null;
         var petItems:XMLList = null;
         var items:XMLList = null;
         var petFarmItem:PetFarmItem = null;
         var petDataXml:XMLList = Global.farmGameSettingsManager.getPetDataXml();
         if(petDataXml.pets.pet)
         {
            petSets = petDataXml.pets.pet;
            if(petSets)
            {
               for each(petSet in petSets)
               {
                  petItems = petSet.item;
                  if(petItems)
                  {
                     items = petItems.(@name == itemName);
                     if(items.length())
                     {
                        petFarmItem = Global.farmGameSettingsManager.getFarmItemByName(items[0].@name) as PetFarmItem;
                        if(petFarmItem)
                        {
                           petFarmItem.init(petSet,items[0]);
                        }
                        break;
                     }
                  }
               }
            }
         }
         return petFarmItem;
      }
      
      public static function getMaxLevel() : int
      {
         var levelXml:XML = null;
         var maxLevel:int = 0;
         var petDataXml:XMLList = Global.farmGameSettingsManager.getPetDataXml();
         if(petDataXml.levels.level)
         {
            for each(levelXml in petDataXml.levels.level)
            {
               if(levelXml.@num > maxLevel)
               {
                  maxLevel = int(levelXml.@num);
               }
            }
         }
         return maxLevel;
      }
      
      public static function getTotalTreatsToLevel(level:int) : int
      {
         var totalTreats:int = 0;
         var levelXml:XML = getLevelXml(level);
         if(levelXml)
         {
            totalTreats = int(levelXml.@treatsNeeded);
         }
         return totalTreats;
      }
      
      public static function getTrickFriendlyName(trickName:String) : String
      {
         return ZLocUtils.t("Dialogs","PetTrick_" + trickName);
      }
      
      private static function getLevelXml(level:int) : XML
      {
         var matchingLevels:XMLList = null;
         var levelXml:XML = null;
         var petDataXml:XMLList = Global.farmGameSettingsManager.getPetDataXml();
         if(petDataXml.levels.level)
         {
            matchingLevels = petDataXml.levels.level.(@num == level);
            if(matchingLevels.length())
            {
               levelXml = matchingLevels[0];
            }
         }
         return levelXml;
      }
      
      public static function isTrickAnimationOnly(trickName:String) : Boolean
      {
         var isAnimationOnly:Boolean = false;
         var trickXml:XML = getTrickXml(trickName);
         if(trickXml != null)
         {
            isAnimationOnly = trickXml.@isAnimationOnly == "true";
         }
         return isAnimationOnly;
      }
      
      public static function getTrickAnimationLength(trickName:String) : int
      {
         var length:int = 0;
         var trickXml:XML = getTrickXml(trickName);
         if(trickXml != null && trickXml.@animationLength != null)
         {
            length = int(trickXml.@animationLength);
         }
         return length;
      }
      
      public static function getTrickClassName(trickName:String) : String
      {
         var className:String = "";
         var trickXml:XML = getTrickXml(trickName);
         if(trickXml != null && trickXml.@className != null)
         {
            className = trickXml.@className;
         }
         return className;
      }
      
      private static function getTrickXml(trickName:String) : XML
      {
         var tricks:XMLList = null;
         var trickXml:XML = null;
         var petDataXml:XMLList = Global.farmGameSettingsManager.getPetDataXml();
         if(petDataXml.tricks.trick)
         {
            tricks = petDataXml.tricks.trick.(@name == trickName);
            if(tricks.length())
            {
               trickXml = tricks[0];
            }
         }
         return trickXml;
      }
   }
}

