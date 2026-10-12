package Classes.FeatureDataObjects
{
   import Engine.Helpers.IntVector2;
   import Managers.EquipmentSettingsManager;
   
   public class EquipmentDataObject
   {
      
      private var m_itemCodes:Array;
      
      private var m_levels:Array;
      
      private var m_energyCost:int;
      
      private var m_energyCostExperiment:String;
      
      private var m_energyCostVariants:Array;
      
      private var m_resourceFilters:Array;
      
      private var m_resourceSize:IntVector2;
      
      public function EquipmentDataObject(rawXML:XML)
      {
         var attributeName:String = null;
         var codeXML:XML = null;
         var levelsXMLList:XMLList = null;
         var levelXML:XML = null;
         var levelObject:Object = null;
         var levelAttributesXMLList:XMLList = null;
         var levelAttributeXML:XML = null;
         var patternsXMLList:XMLList = null;
         var patterns:Array = null;
         var patternXML:XML = null;
         var patternObject:Object = null;
         var patternAttributesXMLList:XMLList = null;
         var patternAttributeXML:XML = null;
         var variantsXMLList:XMLList = null;
         var variantXML:XML = null;
         var variant:Object = null;
         var variantAttributesXMLList:XMLList = null;
         var variantAttributeXML:XML = null;
         var resourceFilterXML:XML = null;
         var resourceFilterObject:Object = null;
         var resourceFilterAttributesXMLList:XMLList = null;
         var resourceFilterAttributeXML:XML = null;
         super();
         this.m_itemCodes = new Array();
         var itemCodesXMLList:XMLList = rawXML.items.code;
         for each(codeXML in itemCodesXMLList)
         {
            this.m_itemCodes.push(codeXML.toString());
         }
         this.m_levels = new Array();
         levelsXMLList = rawXML.levels.level;
         if(levelsXMLList.length() > 0)
         {
            for each(levelXML in levelsXMLList)
            {
               levelObject = {};
               levelAttributesXMLList = levelXML.attributes();
               for each(levelAttributeXML in levelAttributesXMLList)
               {
                  attributeName = levelAttributeXML.name();
                  levelObject[attributeName] = levelAttributeXML.toString();
               }
               patternsXMLList = levelXML.pattern;
               if(patternsXMLList.length() > 0)
               {
                  patterns = [];
                  for each(patternXML in patternsXMLList)
                  {
                     patternObject = {};
                     patternAttributesXMLList = patternXML.attributes();
                     for each(patternAttributeXML in patternAttributesXMLList)
                     {
                        attributeName = patternAttributeXML.name();
                        patternObject[attributeName] = patternAttributeXML.toString();
                     }
                     patterns.push(patternObject);
                  }
                  levelObject.patterns = patterns;
               }
               this.m_levels.push(levelObject);
            }
         }
         this.m_energyCost = parseInt(rawXML.energyCost.toString());
         if(isNaN(this.m_energyCost) || this.m_energyCost <= 0)
         {
            this.m_energyCost = EquipmentSettingsManager.DEFAULT_ENERGY_COST;
         }
         this.m_energyCostExperiment = rawXML.energyCostExperiment.toString();
         if(this.m_energyCostExperiment)
         {
            variantsXMLList = rawXML.energyCostVariants.variant;
            if(variantsXMLList.length() > 0)
            {
               this.m_energyCostVariants = [];
               for each(variantXML in variantsXMLList)
               {
                  variant = {};
                  variantAttributesXMLList = variantXML.attributes();
                  for each(variantAttributeXML in variantAttributesXMLList)
                  {
                     attributeName = variantAttributeXML.name();
                     variant[attributeName] = variantAttributeXML.toString();
                  }
                  this.m_energyCostVariants.push(variant);
               }
            }
         }
         this.m_resourceFilters = new Array();
         var resourceFiltersXMLList:XMLList = rawXML.resourceFilters.resourceFilter;
         if(resourceFiltersXMLList.length() > 0)
         {
            for each(resourceFilterXML in resourceFiltersXMLList)
            {
               resourceFilterObject = {};
               resourceFilterAttributesXMLList = resourceFilterXML.attributes();
               for each(resourceFilterAttributeXML in resourceFilterAttributesXMLList)
               {
                  attributeName = resourceFilterAttributeXML.name();
                  resourceFilterObject[attributeName] = resourceFilterAttributeXML.toString();
               }
               this.m_resourceFilters.push(resourceFilterObject);
            }
         }
         var resourceSizeX:int = parseInt(rawXML.resourceSizeX.toString());
         if(isNaN(resourceSizeX) || resourceSizeX <= 0)
         {
            resourceSizeX = EquipmentSettingsManager.DEFAULT_RESOURCE_X;
         }
         var resourceSizeY:int = parseInt(rawXML.resourceSizeY.toString());
         if(isNaN(resourceSizeY) || resourceSizeY <= 0)
         {
            resourceSizeY = EquipmentSettingsManager.DEFAULT_RESOURCE_Y;
         }
         this.m_resourceSize = new IntVector2(resourceSizeX,resourceSizeY);
      }
      
      public function get itemCodes() : Array
      {
         return this.m_itemCodes;
      }
      
      public function get levels() : Array
      {
         return this.m_levels;
      }
      
      public function get energyCost() : int
      {
         var experimentVariant:int = 0;
         var costVariant:Object = null;
         var result:int = this.m_energyCost;
         if(Boolean(this.m_energyCostExperiment) && Boolean(this.m_energyCostVariants))
         {
            experimentVariant = Global.experimentManager.getExperimentVariant(this.m_energyCostExperiment);
            for each(costVariant in this.m_energyCostVariants)
            {
               if(parseInt(costVariant.number) == experimentVariant)
               {
                  result = parseInt(costVariant.cost);
                  break;
               }
            }
         }
         return result;
      }
      
      public function get resourceFilters() : Array
      {
         return this.m_resourceFilters;
      }
      
      public function get resourceSize() : IntVector2
      {
         return this.m_resourceSize;
      }
   }
}

