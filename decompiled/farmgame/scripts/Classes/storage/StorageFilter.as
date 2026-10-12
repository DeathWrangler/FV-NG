package Classes.storage
{
   import Classes.GrowableAnimal;
   import Classes.MapResource;
   import Classes.Quest.PrerequisiteUtility;
   import Managers.FarmGameSettingsManager;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   
   public class StorageFilter
   {
      
      private var m_name:String;
      
      private var m_maxCap:int = -1;
      
      private var m_maxUGCInventoryCap:int = -1;
      
      private var m_allowClasses:Array;
      
      private var m_denyClasses:Array;
      
      private var m_allowKeywords:Array;
      
      private var m_allowedKeywordLimit:Object;
      
      private var m_denyKeywords:Array;
      
      private var m_itemNames:XMLList = null;
      
      private var m_itemNamesList:Array;
      
      private var m_conditionalItemNames:XMLList;
      
      private var m_conditionalItemNamesList:Array;
      
      private var m_conditionalStorageFilters:Array;
      
      private var m_prereqKey:String;
      
      public function StorageFilter(xml:XML, storageConfig:Object)
      {
         var elem:XML = null;
         var processedItemNames:Dictionary = null;
         var conditional:XML = null;
         var allowClassObj:Object = null;
         var experimentName:String = null;
         var allowSubclass:String = null;
         var elemObj:Object = null;
         var storageData:* = undefined;
         var conditionalObj:Object = null;
         var conditionalData:* = undefined;
         this.m_allowClasses = [];
         this.m_denyClasses = [];
         this.m_allowKeywords = [];
         this.m_allowedKeywordLimit = {};
         this.m_denyKeywords = [];
         this.m_itemNamesList = [];
         this.m_conditionalItemNamesList = [];
         super();
         if(xml)
         {
            this.m_name = xml.@name;
            this.m_prereqKey = xml.@prereq;
            for each(elem in xml.elements("allowedClass"))
            {
               allowClassObj = {"name":elem.@type};
               experimentName = String(elem.@experiment);
               if(experimentName)
               {
                  allowClassObj.experiment = experimentName;
               }
               allowSubclass = String(elem.@allowSubclass);
               if(allowSubclass == "false")
               {
                  allowClassObj.allowSubclass = false;
               }
               else
               {
                  allowClassObj.allowSubclass = true;
               }
               this.m_allowClasses.push(allowClassObj);
            }
            for each(elem in xml.elements("nonStorableClass"))
            {
               this.m_denyClasses.push(elem.toString());
            }
            for each(elem in xml.elements("allowKeyword"))
            {
               this.m_allowKeywords.push(elem.toString());
               if(elem.hasOwnProperty("@limit"))
               {
                  this.m_allowedKeywordLimit[elem.toString()] = elem.@limit;
               }
            }
            for each(elem in xml.elements("denyKeyword"))
            {
               this.m_denyKeywords.push(elem.toString());
            }
            this.m_itemNames = new XMLList();
            this.m_conditionalItemNames = new XMLList();
            processedItemNames = new Dictionary();
            for each(elem in xml.elements("itemName"))
            {
               this.addItemName(elem,null,processedItemNames,false);
            }
            for each(conditional in xml.elements("conditional"))
            {
               for each(elem in conditional.elements("itemName"))
               {
                  this.addItemName(elem,null,processedItemNames,true);
               }
            }
            for each(elem in xml.@*)
            {
               if(elem.name() == "limit")
               {
                  this.m_maxCap = int(elem);
               }
               if(elem.name() == "maxUGCAnimals")
               {
                  this.m_maxUGCInventoryCap = int(elem);
               }
            }
            this.m_conditionalStorageFilters = new Array();
            for each(elem in xml.elements("conditional"))
            {
               this.m_conditionalStorageFilters.push(new StorageFilter(elem,null));
            }
         }
         else if(storageConfig)
         {
            this.m_name = storageConfig["name"];
            this.m_prereqKey = storageConfig["prereq"];
            storageData = storageConfig["allowedClass"];
            for each(elemObj in storageData)
            {
               if(getQualifiedClassName(storageData) == "Array")
               {
                  allowClassObj = {"name":elemObj["type"]};
                  if(elemObj["experiment"])
                  {
                     allowClassObj.experiment = elemObj["experiment"];
                  }
                  allowSubclass = String(elemObj["allowSubclass"]);
                  if(allowSubclass == "false")
                  {
                     allowClassObj.allowSubclass = false;
                  }
                  else
                  {
                     allowClassObj.allowSubclass = true;
                  }
               }
               else
               {
                  allowClassObj = {"name":storageData["type"]};
                  if(storageData["experiment"])
                  {
                     allowClassObj.experiment = storageData["experiment"];
                  }
                  allowSubclass = String(storageData["allowSubclass"]);
                  if(allowSubclass == "false")
                  {
                     allowClassObj.allowSubclass = false;
                  }
                  else
                  {
                     allowClassObj.allowSubclass = true;
                  }
               }
               this.m_allowClasses.push(allowClassObj);
            }
            storageData = storageConfig["nonStorableClass"];
            if(getQualifiedClassName(storageData) == "Array")
            {
               for(elemObj in storageData)
               {
                  this.m_denyClasses.push(storageData[elemObj].toString());
               }
            }
            else if(storageData)
            {
               this.m_denyClasses.push(storageData.toString());
            }
            storageData = storageConfig["allowKeyword"];
            if(getQualifiedClassName(storageData) == "Array")
            {
               for(elemObj in storageData)
               {
                  this.m_allowKeywords.push(storageData[elemObj].toString());
                  if(storageData["limit"])
                  {
                     this.m_allowedKeywordLimit[elemObj.toString()] = storageData["limit"];
                  }
               }
            }
            else if(storageData)
            {
               this.m_allowKeywords.push(storageData.toString());
               if(storageData == "limit")
               {
                  this.m_allowedKeywordLimit["limit"] = storageData.toString();
               }
            }
            storageData = storageConfig["denyKeyword"];
            if(getQualifiedClassName(storageData) == "Array")
            {
               for(elemObj in storageData)
               {
                  this.m_denyKeywords.push(storageData[elemObj].toString());
               }
            }
            else if(storageData)
            {
               this.m_denyKeywords.push(storageData.toString());
            }
            processedItemNames = new Dictionary();
            storageData = storageConfig["itemName"];
            if(getQualifiedClassName(storageData) == "Array")
            {
               for each(elemObj in storageData)
               {
                  this.addItemName(null,elemObj,processedItemNames,false);
               }
            }
            else if(storageData)
            {
               this.addItemName(null,storageData,processedItemNames,false);
            }
            conditionalData = storageConfig["conditional"];
            if(getQualifiedClassName(conditionalData) == "Array")
            {
               for each(conditionalObj in conditionalData)
               {
                  this.addItemNames(conditionalObj,processedItemNames);
               }
            }
            else if(conditionalData)
            {
               this.addItemNames(conditionalData,processedItemNames);
            }
            for(elemObj in storageConfig)
            {
               if(elemObj == "limit")
               {
                  this.m_maxCap = int(storageConfig[elemObj]);
               }
               else if(elemObj == "maxUGCAnimals")
               {
                  this.m_maxUGCInventoryCap = int(storageConfig[elemObj]);
               }
            }
            this.m_conditionalStorageFilters = new Array();
            if(storageConfig["conditional"])
            {
               if(getQualifiedClassName(storageConfig["conditional"]) == "Array")
               {
                  for each(elemObj in storageConfig["conditional"])
                  {
                     this.m_conditionalStorageFilters.push(new StorageFilter(null,elemObj));
                  }
               }
               else
               {
                  this.m_conditionalStorageFilters.push(new StorageFilter(null,storageConfig["conditional"]));
               }
            }
         }
      }
      
      public function addItemNames(conditionalObj:Object, processedItemNames:Dictionary) : void
      {
         var itemNameIndex:* = undefined;
         var itemNames:* = conditionalObj["itemName"];
         if(Boolean(itemNames) && getQualifiedClassName(itemNames) == "Array")
         {
            for(itemNameIndex in itemNames)
            {
               this.addItemName(null,itemNames[itemNameIndex],processedItemNames,true);
            }
         }
         else if(itemNames)
         {
            this.addItemName(null,itemNames,processedItemNames,true);
         }
      }
      
      public function addItemName(elem:XML, elemObj:Object, processedItemNames:Dictionary, isConditional:Boolean) : void
      {
         var elemText:String = null;
         if(elem)
         {
            elemText = elem.toString();
            if(!processedItemNames[elemText])
            {
               processedItemNames[elemText] = true;
               if(!isConditional)
               {
                  this.m_itemNames += elem;
               }
               else
               {
                  this.m_conditionalItemNames += elem;
               }
            }
         }
         else if(elemObj)
         {
            if(elemObj.hasOwnProperty("value"))
            {
               elemText = elemObj["value"].toString();
            }
            else
            {
               elemText = elemObj.toString();
            }
            if(!processedItemNames[elemText])
            {
               processedItemNames[elemText] = true;
               if(!isConditional)
               {
                  this.m_itemNamesList.push(elemObj);
               }
               else
               {
                  this.m_conditionalItemNamesList.push(elemObj);
               }
            }
         }
      }
      
      public function get name() : String
      {
         return this.m_name;
      }
      
      public function get prereqKey() : String
      {
         return this.m_prereqKey;
      }
      
      public function get maxCapacity() : int
      {
         return this.m_maxCap;
      }
      
      public function get maxUGCCapacity() : int
      {
         return this.m_maxUGCInventoryCap;
      }
      
      public function get allItemsIncludingConditionals() : XMLList
      {
         return this.m_itemNames + this.m_conditionalItemNames;
      }
      
      public function get allItemsIncludingConditionalsOpt() : Array
      {
         return this.m_itemNamesList.concat(this.m_conditionalItemNamesList);
      }
      
      public function get itemNames() : XMLList
      {
         return this.m_itemNames;
      }
      
      public function get itemNamesOpt() : Array
      {
         return this.m_itemNamesList;
      }
      
      public function get allowedClasses() : Array
      {
         var allowClassObj:Object = null;
         var result:Array = new Array();
         for each(allowClassObj in this.m_allowClasses)
         {
            if(!allowClassObj.experiment || Global.experimentManager.getExperimentVariant(allowClassObj.experiment) > 0)
            {
               result.push(allowClassObj.name);
            }
         }
         return result;
      }
      
      public function canTake(item:MapResource) : Boolean
      {
         var allowClassObj:Object = null;
         var denyClass:String = null;
         var keywords:Array = null;
         var keyword:String = null;
         var allowKeyword:String = null;
         var denyKeyword:String = null;
         var itemNameIndex:int = 0;
         var itemName:XML = null;
         var storageFilter:StorageFilter = null;
         var growableAnimal:GrowableAnimal = null;
         var result:Boolean = false;
         for each(allowClassObj in this.m_allowClasses)
         {
            if(Boolean(allowClassObj.allowSubclass) && Boolean(this.isSubclassOf(allowClassObj.name,item)) || !allowClassObj.allowSubclass && item.getClassName() == allowClassObj.name)
            {
               if(!allowClassObj.experiment || Global.experimentManager.getExperimentVariant(allowClassObj.experiment) > 0)
               {
                  result = true;
               }
               break;
            }
         }
         if(result)
         {
            for each(denyClass in this.m_denyClasses)
            {
               if(this.isSubclassOf(denyClass,item))
               {
                  result = false;
                  break;
               }
            }
         }
         if(item.getItem())
         {
            keywords = item.getItem().keywords;
            for each(allowKeyword in this.m_allowKeywords)
            {
               for each(keyword in keywords)
               {
                  if(allowKeyword == keyword)
                  {
                     result = true;
                     break;
                  }
               }
            }
            if(result)
            {
               for each(denyKeyword in this.m_denyKeywords)
               {
                  for each(keyword in keywords)
                  {
                     if(denyKeyword == keyword)
                     {
                        result = false;
                        break;
                     }
                  }
               }
            }
            if(!result)
            {
               if(FarmGameSettingsManager.isInStorageConfigAMFExperiment())
               {
                  for(itemNameIndex = 0; itemNameIndex < this.m_itemNamesList.length; itemNameIndex++)
                  {
                     if(Boolean(this.m_itemNamesList[itemNameIndex].hasOwnProperty("value")) && Boolean(this.m_itemNamesList[itemNameIndex]["value"].toString() == item.getItem().name) || this.m_itemNamesList[itemNameIndex].toString() == item.getItem().name)
                     {
                        result = true;
                        break;
                     }
                  }
               }
               else
               {
                  for each(itemName in this.m_itemNames)
                  {
                     if(itemName.toString() == item.getItem().name)
                     {
                        result = true;
                        break;
                     }
                  }
               }
            }
            if(!result)
            {
               for each(storageFilter in this.m_conditionalStorageFilters)
               {
                  if(storageFilter.prereqKey != "")
                  {
                     if(storageFilter.canTake(item) && PrerequisiteUtility.checkPrereqByName(storageFilter.prereqKey,item))
                     {
                        result = true;
                        break;
                     }
                  }
               }
            }
         }
         if(result)
         {
            growableAnimal = item as GrowableAnimal;
            if(growableAnimal)
            {
               result = growableAnimal.isStorable();
            }
         }
         return result;
      }
      
      public function isSubclassOf(className:String, item:MapResource) : Boolean
      {
         var classRef:Class = null;
         var result:Boolean = false;
         try
         {
            classRef = getDefinitionByName("Classes." + className) as Class;
            if(item is classRef)
            {
               result = true;
            }
         }
         catch(error:Error)
         {
         }
         return result;
      }
      
      public function keywordLimit(keyword:String) : int
      {
         var result:int = 0;
         if(this.m_allowedKeywordLimit.hasOwnProperty(keyword))
         {
            result = int(this.m_allowedKeywordLimit[keyword]);
         }
         return result;
      }
      
      public function updateValuesFromExtensionBase(baseStorageFilter:StorageFilter) : void
      {
         this.m_allowClasses = this.m_allowClasses.concat(baseStorageFilter.m_allowClasses);
         this.m_denyClasses = this.m_denyClasses.concat(baseStorageFilter.m_denyClasses);
         this.m_allowKeywords = this.m_allowKeywords.concat(baseStorageFilter.m_allowKeywords);
         this.m_denyKeywords = this.m_denyKeywords.concat(baseStorageFilter.m_denyKeywords);
         if(FarmGameSettingsManager.isInStorageConfigAMFExperiment())
         {
            this.m_itemNamesList = this.m_itemNamesList.concat(baseStorageFilter.itemNamesOpt);
         }
         else
         {
            this.m_itemNames += baseStorageFilter.itemNames;
         }
         if(this.m_maxCap < 0)
         {
            this.m_maxCap = baseStorageFilter.maxCapacity;
         }
      }
   }
}

