package Classes
{
   import Classes.Constants.Experiments;
   import Classes.Constants.XMLKeys;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.HarvestableItem;
   import Classes.buffs.BBushel;
   import Classes.buffs.BMasteryGeneric;
   import Classes.buffs.BMasteryPowerHour;
   import Classes.buffs.BMasteryTimed;
   import Classes.buffs.BPermanentTypeMastery;
   import DataSources.BaseDataSource;
   import Managers.FarmGameSettingsManager;
   import Managers.PowerHourManager;
   
   public class Mastery extends MasteryBase
   {
      
      public static const MASTERY_KEY_ANIMALS:String = "animal";
      
      public static const MASTERY_KEY_CROPS:String = "seed";
      
      public static const MASTERY_KEY_TREES:String = "tree";
      
      public static const MASTERED_LEVEL:Number = 2;
      
      private static const STATS_COUNTER_ANIMAL_MASTERY:String = "animal_mastery";
      
      private static const STATS_COUNTER_CROP_MASTERY:String = "crop_mastery";
      
      private static const STATS_COUNTER_TREE_MASTERY:String = "tree_mastery";
      
      private static const MASTERY_BONUS_CAP:int = 5;
      
      private var m_level:int = -1;
      
      private var m_finalGift:String;
      
      private var m_masteryTarget:String;
      
      private var m_masteryYield:int;
      
      public function Mastery(xml:XML, item:FarmItem = null)
      {
         var harvestableItem:HarvestableItem;
         var levelData:BaseDataSource = null;
         var level:XML = null;
         var isInDataSourceExperiment:Boolean = FarmGameSettingsManager.isInDataSourceExperiment();
         if(isInDataSourceExperiment)
         {
            this.m_masteryTarget = item.code;
         }
         else
         {
            m_item = Global.farmGameSettingsManager.getFarmItemByCode(xml.@code);
            this.m_masteryTarget = xml.@code;
         }
         this.m_masteryYield = 0;
         harvestableItem = m_item ? m_item as HarvestableItem : item as HarvestableItem;
         if(harvestableItem)
         {
            this.m_masteryYield = harvestableItem.masteryYield;
            if(harvestableItem.masteryTarget != "")
            {
               this.m_masteryTarget = harvestableItem.masteryTarget;
               if(isInDataSourceExperiment)
               {
                  item = Global.farmGameSettingsManager.getFarmItemByCode(this.m_masteryTarget);
               }
               else
               {
                  m_item = Global.farmGameSettingsManager.getFarmItemByCode(this.m_masteryTarget);
                  xml = m_item.xml;
               }
            }
         }
         super(xml,item);
         if(isInDataSourceExperiment)
         {
            levelData = this.finalLevelData;
            if(levelData)
            {
               this.m_finalGift = levelData.getString("gift");
            }
            else
            {
               this.m_finalGift = "";
            }
         }
         else
         {
            try
            {
               level = this.levels[this.levels.length() - 1];
               this.m_finalGift = level.@gift;
            }
            catch(error:Error)
            {
               m_finalGift = "";
            }
         }
      }
      
      public static function getTimedCraftingMasteryMult() : int
      {
         var result:int = 0;
         if(Global.player.getBuffItemsByClass(BMasteryTimed,BMasteryTimed.CRAFTING_TYPE).length > 0)
         {
            result++;
         }
         return result;
      }
      
      private static function getMasteryBonusCap() : int
      {
         var result:int = 0;
         var cap:Number = NaN;
         if(Global.flashHotParams["MASTERY_BONUS_CAP"])
         {
            cap = parseInt(Global.flashHotParams["MASTERY_BONUS_CAP"]);
         }
         if(!isNaN(cap))
         {
            result = cap;
         }
         else
         {
            result = Global.farmGameSettingsManager.getInt("masteryBonusCap",MASTERY_BONUS_CAP);
         }
         return result;
      }
      
      public static function createMasteryForItem(farmItem:FarmItem) : Mastery
      {
         var mastery:Mastery = null;
         var localFarmItem:FarmItem = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            localFarmItem = farmItem;
         }
         switch(farmItem.type)
         {
            case MASTERY_KEY_ANIMALS:
               mastery = new AnimalMastery(farmItem.xml,localFarmItem);
               break;
            case MASTERY_KEY_TREES:
               mastery = new TreeMastery(farmItem.xml,localFarmItem);
               break;
            default:
               mastery = new Mastery(farmItem.xml,localFarmItem);
         }
         return mastery;
      }
      
      override protected function getFriendlyNameLocFile() : String
      {
         return "Items";
      }
      
      public function getCurrentCount() : int
      {
         return Global.player.masteryCounters[this.code] != null ? int(parseInt(Global.player.masteryCounters[this.code])) : 0;
      }
      
      public function get code() : String
      {
         return this.m_masteryTarget;
      }
      
      public function get levels() : XMLList
      {
         return m_xml.masteryLevel;
      }
      
      public function get levelsData() : Array
      {
         return m_item.masteryLevelData;
      }
      
      private function get finalLevelData() : BaseDataSource
      {
         var dataSource:BaseDataSource = null;
         var levelsArray:Array = this.levelsData;
         if(levelsArray.length > 0)
         {
            dataSource = levelsArray[levelsArray.length - 1];
         }
         return dataSource;
      }
      
      public function get currentLevel() : int
      {
         var highestLevel:int = 0;
         if(this.m_level == -1 && Global.player.mastery[this.code] != null)
         {
            highestLevel = parseInt(Global.player.mastery[this.code]);
         }
         else
         {
            highestLevel = this.m_level;
         }
         return highestLevel;
      }
      
      public function set currentLevel(level:int) : void
      {
         this.m_level = level;
      }
      
      public function get nextLevel() : int
      {
         return this.currentLevel + 1;
      }
      
      public function get xp() : int
      {
         var xp:int = 0;
         var level:XML = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            xp = int(this.levelsData[this.currentLevel].getInt("xp"));
         }
         else
         {
            level = this.levels[this.currentLevel];
            xp = int(level.@xp);
         }
         return xp;
      }
      
      public function get gold() : int
      {
         var gold:int = 0;
         var level:XML = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            gold = int(this.levelsData[this.currentLevel].getInt("coins"));
         }
         else
         {
            level = this.levels[this.currentLevel];
            gold = int(level.@coins);
         }
         return gold;
      }
      
      public function get gift() : String
      {
         var gift:String = null;
         var level:XML = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            gift = this.levelsData[this.currentLevel].getString("gift");
         }
         else
         {
            level = this.levels[this.currentLevel];
            gift = level.@gift;
         }
         return gift;
      }
      
      public function get finalGift() : String
      {
         return this.m_finalGift;
      }
      
      public function get nextStar() : String
      {
         var starName:String = "";
         switch(this.currentLevel)
         {
            case 0:
               starName = "OneStar";
               break;
            case 1:
               starName = "TwoStars";
               break;
            case 2:
               starName = "ThreeStars";
               break;
            case -1:
            default:
               starName = "None";
         }
         return starName;
      }
      
      public function get currentStar() : String
      {
         var starName:String = "";
         switch(this.currentLevel)
         {
            case 0:
               starName = "OneStar";
               break;
            case 1:
               starName = "TwoStars";
               break;
            case 2:
               starName = "ThreeStars";
               break;
            case -1:
            default:
               starName = "None";
         }
         return starName;
      }
      
      public function get item() : FarmItem
      {
         return m_item;
      }
      
      public function hasAllMasteries() : Boolean
      {
         var masteryTarget:FarmItem = null;
         var levelsCount:int = 0;
         var result:Boolean = false;
         var isInDataSourceExperiment:Boolean = FarmGameSettingsManager.isInDataSourceExperiment();
         if((m_item as HarvestableItem).masteryTarget != "")
         {
            masteryTarget = Global.farmGameSettingsManager.getFarmItemByCode((m_item as HarvestableItem).masteryTarget);
            if(isInDataSourceExperiment)
            {
               result = new Mastery(null,masteryTarget).hasAllMasteries();
            }
            else
            {
               result = new Mastery(masteryTarget.xml).hasAllMasteries();
            }
         }
         else
         {
            if(isInDataSourceExperiment)
            {
               levelsCount = this.levelsData.length - 1;
            }
            else
            {
               levelsCount = this.levels.length() - 1;
            }
            result = this.currentLevel >= levelsCount;
         }
         return result;
      }
      
      public function get currentProgress() : int
      {
         var levelsCount:int = 0;
         var currentLevelCount:int = 0;
         var levelsDataArray:Array = null;
         var levelsXML:XMLList = null;
         var result:int = 0;
         var currentLevel:int = this.currentLevel;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            levelsDataArray = this.levelsData;
            levelsCount = int(levelsDataArray.length);
            if(currentLevel >= 0)
            {
               currentLevelCount = int(levelsDataArray[currentLevel].getInt("count"));
            }
         }
         else
         {
            levelsXML = this.levels;
            levelsCount = levelsXML.length();
            if(currentLevel >= 0)
            {
               currentLevelCount = int(levelsXML[currentLevel].@count);
            }
         }
         if(Global.player.masteryCounters[this.code] != null && levelsCount > 0 && currentLevel < 0)
         {
            result = int(Global.player.masteryCounters[this.code]);
         }
         else if(Global.player.masteryCounters[this.code] != null && levelsCount > 0 && currentLevel >= 0)
         {
            result = Global.player.masteryCounters[this.code] - currentLevelCount;
         }
         return result;
      }
      
      public function get remainingCropsToNextLevel() : int
      {
         var levelsCount:int = 0;
         var levelsXML:XMLList = null;
         var levelsDataArray:Array = null;
         var result:int = 0;
         var isInDataSourceExperiment:Boolean = FarmGameSettingsManager.isInDataSourceExperiment();
         if(isInDataSourceExperiment)
         {
            levelsDataArray = this.levelsData;
            levelsCount = int(levelsDataArray.length);
         }
         else
         {
            levelsXML = this.levels;
            levelsCount = levelsXML.length();
         }
         var level:int = Math.min(this.currentLevel + 1,levelsCount - 1);
         if(levelsCount > 0 && level < levelsCount)
         {
            if(isInDataSourceExperiment)
            {
               result = levelsDataArray[level].getInt("count") - this.getCurrentCount();
            }
            else
            {
               result = this.levels[level].@count - this.getCurrentCount();
            }
         }
         return result;
      }
      
      public function hasAnyMastery() : Boolean
      {
         return this.getCurrentCount() > 0;
      }
      
      public function get totalCropsNeeded() : int
      {
         var levelsCount:int = 0;
         var levelsXML:XMLList = null;
         var levelsDataArray:Array = null;
         var result:int = 0;
         var currentLevel:int = this.currentLevel;
         var isInDataSourceExperiment:Boolean = FarmGameSettingsManager.isInDataSourceExperiment();
         if(isInDataSourceExperiment)
         {
            levelsDataArray = this.levelsData;
            levelsCount = int(levelsDataArray.length);
         }
         else
         {
            levelsXML = this.levels;
            levelsCount = levelsXML.length();
         }
         var level1:int = Math.min(currentLevel + 1,levelsCount - 1);
         if(levelsCount > 0 && currentLevel < 0)
         {
            if(isInDataSourceExperiment)
            {
               result = int(levelsDataArray[level1].getInt("count"));
            }
            else
            {
               result = int(this.levels[level1].@count);
            }
         }
         else if(levelsCount > 0 && currentLevel >= 0)
         {
            if(isInDataSourceExperiment)
            {
               result = levelsDataArray[level1].getInt("count") - levelsDataArray[currentLevel].getInt("count");
            }
            else
            {
               result = this.levels[level1].@count - this.levels[currentLevel].@count;
            }
         }
         return result;
      }
      
      public function get totalCropsNeededMax() : int
      {
         var finalLevelData:BaseDataSource = null;
         var result:int = 0;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            finalLevelData = this.finalLevelData;
            if(finalLevelData)
            {
               result = finalLevelData.getInt("count");
            }
         }
         else if(this.levels.length() > 0)
         {
            result = int(this.levels[this.levels.length() - 1].@count);
         }
         return result;
      }
      
      public function get statsCounter() : String
      {
         var type:String = null;
         var result:String = "";
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            type = m_item.type;
         }
         else
         {
            type = this.m_xml[XMLKeys.ATTR_TYPE];
         }
         switch(type)
         {
            case MASTERY_KEY_ANIMALS:
               result = STATS_COUNTER_ANIMAL_MASTERY;
               break;
            case MASTERY_KEY_CROPS:
               result = STATS_COUNTER_CROP_MASTERY;
               break;
            case MASTERY_KEY_TREES:
               result = STATS_COUNTER_TREE_MASTERY;
         }
         return result;
      }
      
      public function capitalizeFirstChar(text:String) : String
      {
         return text.charAt(0).toUpperCase() + text.substr(1,text.length - 1);
      }
      
      public function extraMasteryWeekendEnabled(masteryType:String = "") : Boolean
      {
         return this.getBaseMasteryMultiplier(masteryType) > 1;
      }
      
      protected function getBaseMasteryMultiplier(masteryType:String = "") : int
      {
         var masteryMod:int = 1;
         var featureName:String = "";
         var multiplierName:String = "";
         var defaultModValue:String = "";
         switch(masteryType)
         {
            case "seed":
               featureName = "featureExtraMastery";
               multiplierName = "featureExtraMasteryCropMultiplier";
               defaultModValue = "extraMasteryMod";
               break;
            case "":
               break;
            default:
               featureName = "featureExtraMastery" + this.capitalizeFirstChar(masteryType);
               multiplierName = "featureExtraMastery" + this.capitalizeFirstChar(masteryType) + "Multiplier";
               defaultModValue = "extraMasteryMod" + this.capitalizeFirstChar(masteryType);
         }
         if(featureName.length > 0 && GlobalEngine.getFlashVar(featureName) == 1)
         {
            if(GlobalEngine.getFlashVar(multiplierName))
            {
               masteryMod = int(GlobalEngine.getFlashVar(multiplierName));
            }
            else
            {
               masteryMod = Global.farmGameSettingsManager.getNumber(defaultModValue);
            }
         }
         return masteryMod;
      }
      
      protected function getBushelMasteryMultiplier() : int
      {
         var result:int = 0;
         if(BBushel.getBushelBuff(m_item.code) == BBushel.TYPE_MASTERY)
         {
            result = Global.farmGameSettingsManager.getInt("bushelMasteryBonus",1);
         }
         return result;
      }
      
      protected function getBuffMasteryMultiplier() : int
      {
         var powerHourMasteryBuffs:Array = null;
         var result:int = 0;
         var genericMasteryBuffs:Array = Global.player.getBuffsByClass(BMasteryGeneric);
         if(genericMasteryBuffs.length > 0)
         {
            result = Global.farmGameSettingsManager.getInt("genericMasteryBuffBonus",1) * genericMasteryBuffs.length;
         }
         if(PowerHourManager.inExperiment())
         {
            powerHourMasteryBuffs = Global.player.getBuffsByClass(BMasteryPowerHour);
            if(powerHourMasteryBuffs.length > 0)
            {
               result = Global.farmGameSettingsManager.getInt("genericMasteryBuffBonus",1);
            }
         }
         return result;
      }
      
      protected function getPermanentBuffMasteryMultiplier() : int
      {
         var buff:Buff = null;
         var masteryTypeDataArray:Array = null;
         var masteryTypeData:BaseDataSource = null;
         var typeList:XMLList = null;
         var validType:XML = null;
         var result:int = 0;
         var permanentMasteryBuffs:Array = Global.player.getBuffsByClass(BPermanentTypeMastery);
         for each(buff in permanentMasteryBuffs)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               masteryTypeDataArray = buff.getItem().masteryTypeData;
               for each(masteryTypeData in masteryTypeDataArray)
               {
                  if(m_item.type == masteryTypeData.getString("type"))
                  {
                     result++;
                  }
               }
            }
            else
            {
               typeList = buff.getItem().xml.masteryTypes.masteryType;
               for each(validType in typeList)
               {
                  if(m_item.type == validType.@type)
                  {
                     result++;
                  }
               }
            }
         }
         return result;
      }
      
      protected function getTimedBuffMasteryMultipliers() : int
      {
         var result:int = 0;
         var timedMasteryBuffs:Array = new Array();
         timedMasteryBuffs = Global.player.getBuffItemsByClass(BMasteryTimed,BMasteryTimed.TREE_TYPE);
         if(timedMasteryBuffs.length > 0)
         {
            result = 1;
         }
         return result;
      }
      
      public function calculateMasteryYield(masteryYieldMultiplier:int = 1) : int
      {
         var masteryMultiplier:int = 0;
         var permanentBuffMult:int = 0;
         var result:int = 0;
         if(m_item is HarvestableItem)
         {
            if(this.m_masteryYield > 0)
            {
               if(FarmGameSettingsManager.isInDataSourceExperiment())
               {
                  masteryMultiplier = this.getBaseMasteryMultiplier(m_item.type);
               }
               else
               {
                  masteryMultiplier = this.getBaseMasteryMultiplier(m_xml.@type);
               }
               permanentBuffMult = this.getPermanentBuffMasteryMultiplier();
               masteryMultiplier += this.getBushelMasteryMultiplier();
               masteryMultiplier += this.getBuffMasteryMultiplier();
               masteryMultiplier += permanentBuffMult;
               if((Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_TIMED_CONSUMABLE_ANIMAL) > 1 || Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_TIMED_CONSUMABLE_TREE) > 1) && permanentBuffMult == 0)
               {
                  masteryMultiplier += this.getTimedBuffMasteryMultipliers();
               }
               result = this.m_masteryYield * masteryMultiplier;
               result *= masteryYieldMultiplier;
            }
         }
         var cap:int = getMasteryBonusCap();
         if(result > cap)
         {
            result = cap;
         }
         else if(result < 0)
         {
            result = 0;
         }
         return result;
      }
      
      public function lastMasteryLevel() : Boolean
      {
         var isLastLevel:Boolean = false;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            isLastLevel = this.currentLevel >= this.levelsData.length - 2;
         }
         else
         {
            isLastLevel = this.currentLevel >= this.levels.length() - 2;
         }
         return isLastLevel;
      }
   }
}

