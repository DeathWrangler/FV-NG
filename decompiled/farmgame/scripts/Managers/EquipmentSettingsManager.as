package Managers
{
   import Classes.FeatureDataObjects.EquipmentDataObject;
   import Classes.Quest.FarmQuestSettingsInit;
   import Engine.Helpers.IntVector2;
   import flash.utils.Dictionary;
   
   public class EquipmentSettingsManager
   {
      
      private static const FEATURE_NAME:String = "equipment";
      
      private static const OPTION_PATTERN:String = "pattern";
      
      public static const DEFAULT_ITEM_CODE:String = "default";
      
      public static const DEFAULT_PATTERN_NAME:String = "default";
      
      public static const DEFAULT_ACTION_X:int = 2;
      
      public static const DEFAULT_ACTION_Y:int = 2;
      
      public static const DEFAULT_ENERGY_COST:int = 1;
      
      public static const DEFAULT_RESOURCE_X:int = 4;
      
      public static const DEFAULT_RESOURCE_Y:int = 4;
      
      private static var m_instance:EquipmentSettingsManager = null;
      
      private static var m_canInstantiate:Boolean = false;
      
      protected static var m_equipmentDataXml:XMLList = null;
      
      private var m_settings:Dictionary = null;
      
      public function EquipmentSettingsManager()
      {
         super();
         if(m_canInstantiate)
         {
            m_equipmentDataXml = Global.farmGameSettingsManager.getRawEquipmentDataXml();
            this.parseEquipmentData();
            return;
         }
         throw new Error("Cannot call constructor directly - use getInstance() instead.");
      }
      
      public static function getInstance() : EquipmentSettingsManager
      {
         if(!m_instance)
         {
            m_canInstantiate = true;
            m_instance = new EquipmentSettingsManager();
            m_canInstantiate = false;
         }
         return m_instance;
      }
      
      private function parseEquipmentData() : void
      {
         var equipmentXML:XML = null;
         var equipmentDataObject:EquipmentDataObject = null;
         var itemCodes:Array = null;
         var code:String = null;
         this.m_settings = new Dictionary();
         var equipmentXmlList:XMLList = m_equipmentDataXml.equipment;
         if(equipmentXmlList)
         {
            for each(equipmentXML in equipmentXmlList)
            {
               equipmentDataObject = new EquipmentDataObject(equipmentXML);
               itemCodes = equipmentDataObject.itemCodes;
               if(itemCodes)
               {
                  for each(code in itemCodes)
                  {
                     if(this.m_settings[code] == null)
                     {
                        this.m_settings[code] = equipmentDataObject;
                     }
                  }
               }
            }
         }
      }
      
      public function getEquipmentDataByItemCode(itemCode:String = "default") : EquipmentDataObject
      {
         var result:EquipmentDataObject = null;
         var equipmentDataObject:EquipmentDataObject = null;
         if(this.m_settings[itemCode])
         {
            result = this.m_settings[itemCode];
         }
         else if(this.m_settings[DEFAULT_ITEM_CODE])
         {
            result = this.m_settings[DEFAULT_ITEM_CODE];
         }
         return result;
      }
      
      public function getEnergyCost(itemCode:String = "default") : int
      {
         var result:int = DEFAULT_ENERGY_COST;
         var equipmentDataObject:EquipmentDataObject = this.getEquipmentDataByItemCode(itemCode);
         if(equipmentDataObject)
         {
            result = equipmentDataObject.energyCost;
         }
         return result;
      }
      
      public function getAllLevelsByItemCode(itemCode:String = "default") : Array
      {
         var result:Array = new Array();
         var equipmentDataObject:EquipmentDataObject = this.getEquipmentDataByItemCode(itemCode);
         if(equipmentDataObject)
         {
            result = equipmentDataObject.levels;
         }
         return result;
      }
      
      private function getLevelByActionSize(actionSizeX:int, actionSizeY:int, itemCode:String = "default") : Object
      {
         var level:Object = null;
         var result:Object = null;
         var allLevels:Array = this.getAllLevelsByItemCode(itemCode);
         if(allLevels)
         {
            for each(level in allLevels)
            {
               if(level.actionSizeX == actionSizeX && level.actionSizeY == actionSizeY)
               {
                  result = level;
                  break;
               }
            }
         }
         return result;
      }
      
      public function getLevelByPartCount(currentPartCount:int, itemCode:String = "default") : Object
      {
         var level:Object = null;
         var result:Object = null;
         var allLevels:Array = this.getAllLevelsByItemCode(itemCode);
         if(Boolean(allLevels) && allLevels.length > 0)
         {
            result = allLevels[0];
            for each(level in allLevels)
            {
               if(currentPartCount < level.partsNeeded)
               {
                  break;
               }
               result = level;
            }
         }
         return result;
      }
      
      public function getNextLevelByPartCount(currentPartCount:int, itemCode:String = "default") : Object
      {
         var level:Object = null;
         var result:Object = null;
         var allLevels:Array = this.getAllLevelsByItemCode(itemCode);
         if(allLevels)
         {
            for each(level in allLevels)
            {
               if(currentPartCount < level.partsNeeded)
               {
                  result = level;
                  break;
               }
            }
         }
         return result;
      }
      
      public function getMaxLevel(itemCode:String = "default") : Object
      {
         var result:Object = null;
         var allLevels:Array = this.getAllLevelsByItemCode(itemCode);
         if(Boolean(allLevels) && allLevels.length > 0)
         {
            result = allLevels[allLevels.length - 1];
         }
         return result;
      }
      
      public function getLevelById(id:int, itemCode:String = "default") : Object
      {
         var level:Object = null;
         var result:Object = null;
         var allLevels:Array = this.getAllLevelsByItemCode(itemCode);
         if(allLevels)
         {
            for each(level in allLevels)
            {
               if(level.id == id)
               {
                  result = level;
                  break;
               }
            }
         }
         return result;
      }
      
      public function getPartCountByActionSize(actionSizeX:int, actionSizeY:int, itemCode:String = "default") : int
      {
         var result:int = 0;
         var level:Object = this.getLevelByActionSize(actionSizeX,actionSizeY,itemCode);
         if(level)
         {
            result = int(level.partsNeeded);
         }
         return result;
      }
      
      public function getActionSizeByPartCount(currentPartCount:int, itemCode:String = "default") : IntVector2
      {
         var patternName:String = null;
         var pattern:Object = null;
         var result:IntVector2 = null;
         var level:Object = this.getLevelByPartCount(currentPartCount,itemCode);
         if(level)
         {
            if(level.patterns)
            {
               patternName = this.getPatternOption(itemCode);
               for each(pattern in level.patterns)
               {
                  if(pattern.name == patternName)
                  {
                     result = new IntVector2(pattern.actionSizeX,pattern.actionSizeY);
                     break;
                  }
               }
            }
            if(!result)
            {
               result = new IntVector2(level.actionSizeX,level.actionSizeY);
            }
         }
         if(!result)
         {
            result = new IntVector2(DEFAULT_ACTION_X,DEFAULT_ACTION_Y);
         }
         return result;
      }
      
      public function canEquipmentActOnResource(resourceItemCode:String, equipmentItemCode:String = "default") : Boolean
      {
         var resourceFilters:Array = null;
         var resourceFilter:Object = null;
         var filterType:String = null;
         var filterValue:String = null;
         var result:Boolean = false;
         var equipmentDataObject:EquipmentDataObject = this.getEquipmentDataByItemCode(equipmentItemCode);
         if(equipmentDataObject)
         {
            resourceFilters = equipmentDataObject.resourceFilters;
            if(resourceFilters)
            {
               for each(resourceFilter in resourceFilters)
               {
                  filterType = resourceFilter["type"];
                  filterValue = resourceFilter["value"];
                  if(Boolean(filterType) && Boolean(filterValue))
                  {
                     switch(filterType)
                     {
                        case "category":
                           if(!FarmQuestSettingsInit.getInstance().isItemCodeInCategory(resourceItemCode,filterValue))
                           {
                              break;
                           }
                           result = true;
                     }
                  }
               }
            }
         }
         return result;
      }
      
      public function getResourceSize(itemCode:String = "default") : IntVector2
      {
         var result:IntVector2 = null;
         var equipmentDataObject:EquipmentDataObject = this.getEquipmentDataByItemCode(itemCode);
         if(equipmentDataObject)
         {
            result = equipmentDataObject.resourceSize;
         }
         else
         {
            result = new IntVector2(DEFAULT_RESOURCE_X,DEFAULT_RESOURCE_Y);
         }
         return result;
      }
      
      public function getPatterns(currentPartCount:int, itemCode:String = "default") : Array
      {
         var result:Array = null;
         var level:Object = this.getLevelByPartCount(currentPartCount,itemCode);
         if(Boolean(level) && Boolean(level.patterns))
         {
            result = level.patterns;
         }
         return result;
      }
      
      public function hasPatterns(currentPartCount:int, itemCode:String = "default") : Boolean
      {
         var result:Boolean = false;
         var patterns:Array = this.getPatterns(currentPartCount,itemCode);
         if(patterns)
         {
            result = true;
         }
         return result;
      }
      
      public function getPatternOption(itemCode:String = "default") : String
      {
         var result:String = DEFAULT_PATTERN_NAME;
         var patternOptions:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_NAME,OPTION_PATTERN);
         if(Boolean(patternOptions) && Boolean(patternOptions[itemCode]))
         {
            result = patternOptions[itemCode];
         }
         return result;
      }
      
      public function setPatternOption(patternName:String, itemCode:String = "default") : void
      {
         var patternOptions:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_NAME,OPTION_PATTERN);
         if(!patternOptions)
         {
            patternOptions = {};
         }
         patternOptions[itemCode] = patternName;
         FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_NAME,OPTION_PATTERN,patternOptions);
         FeatureOptionsManager.getInstance().saveSingleFeature(FEATURE_NAME,OPTION_PATTERN);
      }
   }
}

