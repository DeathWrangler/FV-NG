package Classes.Quest
{
   import Classes.Constants.PrerequisiteConstants;
   import Classes.util.FarmGameUtil;
   import Managers.FarmGameSettingsManager;
   import ZQuest.Classes.QuestComponentOptions;
   import ZQuest.Init.QuestSettingsInit;
   
   public class FarmQuestSettingsInit extends QuestSettingsInit
   {
      
      private static const XML_KEY_REQUIRE_SERVER_RESPONSE:String = "@requireServerReponse";
      
      private static const KEY_QUEST_MANAGER:String = "questManager";
      
      private static const KEY_REPLAYABLE_QUESTS:String = "replayableQuests";
      
      private static const KEY_REPLAYABLE_QUEST_CACHE:String = "replayableQuestCache";
      
      private static const KEY_FIRST_QUEST_NAME:String = "@firstQuestName";
      
      private static const KEY_MAX_ACTIVE_REPLAYABLE_QUESTS:String = "maxActiveReplayableQuests";
      
      private static const KEY_QUEST_MANAGER_DIALOG_URL:String = "dialog";
      
      private static const KEY_DEFAULT_TASK_CASH_VALUE:String = "defaultTaskCashValue";
      
      private static const DEFAULT_TASK_CASH_VALUE:int = 10;
      
      private static const KEY_SORT_INDEX:String = "sortIndex";
      
      private static const DEFAULT_SORT_INDEX_VALUE:int = 0;
      
      private var m_itemCategories:Object = null;
      
      private var m_taskTransactions:Object = null;
      
      protected var m_questsById:Object = {};
      
      private var m_categoryItems:Object = null;
      
      private var m_questPriceExperimentData:Object = null;
      
      private var m_questManagerCacheFromConfigSWF:Object = null;
      
      private var m_questManagerData:Array = null;
      
      private var m_taskTypesRequiringServerSync:Object;
      
      public function FarmQuestSettingsInit(settingsUrl:String, options:QuestComponentOptions)
      {
         super(settingsUrl,options,FarmGameUtil.getXmlBackupFilename(settingsUrl));
      }
      
      public static function getInstance() : FarmQuestSettingsInit
      {
         return QuestSettingsInit.getInstance() as FarmQuestSettingsInit;
      }
      
      public function hasBeenInitialized() : Boolean
      {
         return this.m_questManagerData != null;
      }
      
      public function set questManagerCacheFromConfigSWF(configSWFCache:Object) : void
      {
         this.m_questManagerCacheFromConfigSWF = configSWFCache;
      }
      
      public function set questCategoryCacheFromConfigSWF(config:Object) : void
      {
         this.m_itemCategories = config;
      }
      
      public function appendQuestCategoryCacheFromConfigSWF(config:Object) : void
      {
         var itemCode:String = null;
         if(!this.m_itemCategories)
         {
            this.questCategoryCacheFromConfigSWF = config;
         }
         else
         {
            for(itemCode in config)
            {
               if(this.m_itemCategories.hasOwnProperty(itemCode))
               {
                  this.m_itemCategories[itemCode] = (this.m_itemCategories[itemCode] as Array).concat(config[itemCode] as Array);
               }
               else
               {
                  this.m_itemCategories[itemCode] = config[itemCode];
               }
            }
         }
      }
      
      public function parseCategories() : void
      {
         var categoryList:XMLList = null;
         var categoryEntry:XML = null;
         var categoryName:String = null;
         var itemsInCategory:Array = null;
         var itemCode:String = null;
         if(this.m_itemCategories == null)
         {
            Global.farmTimingModule.start("FQSI_parseCategories");
            this.m_itemCategories = new Object();
            categoryList = m_rawXml.categories.category;
            for each(categoryEntry in categoryList)
            {
               categoryName = String(categoryEntry.@name);
               itemsInCategory = this.getAllItemsInCategory(categoryName);
               for each(itemCode in itemsInCategory)
               {
                  this.addCategoryToItemCode(itemCode,categoryName);
               }
            }
            Global.farmTimingModule.end("FQSI_parseCategories",true);
         }
         if(this.m_categoryItems == null)
         {
            this.m_categoryItems = new Object();
         }
      }
      
      public function get itemCategories() : Object
      {
         return this.m_itemCategories;
      }
      
      public function set itemCategories(iCategories:Object) : void
      {
         this.m_itemCategories = iCategories;
      }
      
      public function forceParseCategories() : void
      {
         this.m_itemCategories = null;
         this.parseCategories();
      }
      
      public function parseQuestManager() : void
      {
         var xmlAttribute:XML = null;
         var attributeName:String = null;
         var replayableQuestsNode:XMLList = null;
         var usePrecomputedMap:Boolean = false;
         var replayableQuestNode:XML = null;
         var questObj:Object = null;
         if(m_rawXml != null)
         {
            if(this.m_questManagerData == null)
            {
               this.m_questManagerData = new Array();
               this.m_questManagerData[KEY_REPLAYABLE_QUESTS] = new Array();
               this.m_questManagerData[KEY_REPLAYABLE_QUEST_CACHE] = new Object();
               if(m_rawXml.questManager != null)
               {
                  xmlAttribute = null;
                  attributeName = null;
                  for each(xmlAttribute in m_rawXml.questManager.attributes())
                  {
                     attributeName = xmlAttribute.name();
                     this.m_questManagerData[attributeName] = String(xmlAttribute);
                  }
                  if(m_rawXml.questManager.replayableQuests != null)
                  {
                     replayableQuestsNode = m_rawXml.questManager.replayableQuests;
                     xmlAttribute = null;
                     for each(xmlAttribute in replayableQuestsNode.attributes())
                     {
                        attributeName = xmlAttribute.name();
                        this.m_questManagerData[attributeName] = String(xmlAttribute);
                     }
                     usePrecomputedMap = this.m_questManagerCacheFromConfigSWF != null;
                     if(usePrecomputedMap)
                     {
                        this.m_questManagerData[KEY_REPLAYABLE_QUEST_CACHE] = this.m_questManagerCacheFromConfigSWF;
                     }
                     for each(replayableQuestNode in m_rawXml.questManager.replayableQuests.replayableQuest)
                     {
                        if(replayableQuestNode[KEY_FIRST_QUEST_NAME] != null)
                        {
                           questObj = FarmGameSettingsManager.parseXmlAttributesToObject(replayableQuestNode,true);
                           if(questObj)
                           {
                              this.m_questManagerData[KEY_REPLAYABLE_QUESTS][replayableQuestNode[KEY_FIRST_QUEST_NAME]] = questObj;
                           }
                           if(!usePrecomputedMap)
                           {
                              this.cacheQuestManagerQuestChain(replayableQuestNode[KEY_FIRST_QUEST_NAME],replayableQuestNode[KEY_FIRST_QUEST_NAME]);
                           }
                        }
                     }
                  }
               }
            }
         }
      }
      
      public function getMaxActiveReplayableQuests() : int
      {
         var result:int = 0;
         if(Boolean(this.m_questManagerData) && this.m_questManagerData.hasOwnProperty(KEY_MAX_ACTIVE_REPLAYABLE_QUESTS))
         {
            result = int(this.m_questManagerData[KEY_MAX_ACTIVE_REPLAYABLE_QUESTS]);
         }
         return result;
      }
      
      public function getQuestManagerDialogUrl() : String
      {
         var result:String = "";
         if(Boolean(this.m_questManagerData) && this.m_questManagerData.hasOwnProperty(KEY_QUEST_MANAGER_DIALOG_URL))
         {
            result = this.m_questManagerData[KEY_QUEST_MANAGER_DIALOG_URL];
         }
         return result;
      }
      
      private function cacheQuestManagerQuestChain(currentQuestName:String, firstQuestName:String) : void
      {
         var questDescription:FarmQuest = null;
         var childArray:Vector.<Object> = null;
         var child:Object = null;
         if(currentQuestName != null && currentQuestName != "")
         {
            questDescription = this.getItemByName(currentQuestName) as FarmQuest;
            if(questDescription != null)
            {
               this.m_questManagerData[KEY_REPLAYABLE_QUEST_CACHE][currentQuestName] = firstQuestName;
               childArray = questDescription.children;
               for each(child in childArray)
               {
                  if(child["type"] == "Quest" && child["value"] != null && child["value"] != "")
                  {
                     this.cacheQuestManagerQuestChain(child["value"],firstQuestName);
                  }
               }
            }
         }
      }
      
      public function questManagerQuestChainCacheContains(anyQuestNameInChain:String) : Boolean
      {
         return null != this.questManagerGetNameOfFirstQuestInReplayableChain(anyQuestNameInChain);
      }
      
      public function questManagerGetNameOfFirstQuestInReplayableChain(anyQuestNameInChain:String) : String
      {
         var result:String = null;
         if(anyQuestNameInChain != null && anyQuestNameInChain != "")
         {
            if(Boolean(this.m_questManagerData) && this.m_questManagerData[KEY_REPLAYABLE_QUEST_CACHE][anyQuestNameInChain] != null)
            {
               result = this.m_questManagerData[KEY_REPLAYABLE_QUEST_CACHE][anyQuestNameInChain];
            }
         }
         return result;
      }
      
      public function questManagerGetReplayableQuests() : Array
      {
         var result:Array = [];
         if(this.m_questManagerData != null)
         {
            result = this.m_questManagerData[KEY_REPLAYABLE_QUESTS];
         }
         return result;
      }
      
      public function questManagerGetPrereqForReplayableQuestChain(firstQuestName:String) : String
      {
         var result:String = null;
         if(this.m_questManagerData != null && this.m_questManagerData[KEY_REPLAYABLE_QUESTS] != null && this.m_questManagerData[KEY_REPLAYABLE_QUESTS][firstQuestName] != null && this.m_questManagerData[KEY_REPLAYABLE_QUESTS][firstQuestName][PrerequisiteConstants.PREREQ_XML_TAG] != null)
         {
            result = this.m_questManagerData[KEY_REPLAYABLE_QUESTS][firstQuestName][PrerequisiteConstants.PREREQ_XML_TAG];
         }
         return result;
      }
      
      public function questManagerGetDefaultTaskCashValueForReplayableQuestChain(firstQuestName:String) : int
      {
         var result:int = DEFAULT_TASK_CASH_VALUE;
         if(this.m_questManagerData != null && this.m_questManagerData[KEY_REPLAYABLE_QUESTS] != null && this.m_questManagerData[KEY_REPLAYABLE_QUESTS][firstQuestName] != null && this.m_questManagerData[KEY_REPLAYABLE_QUESTS][firstQuestName][KEY_DEFAULT_TASK_CASH_VALUE] != null)
         {
            result = int(this.m_questManagerData[KEY_REPLAYABLE_QUESTS][firstQuestName][KEY_DEFAULT_TASK_CASH_VALUE]);
         }
         return result;
      }
      
      public function questManagerGetSortIndexForReplayableQuestChain(firstQuestName:String) : int
      {
         var result:int = DEFAULT_SORT_INDEX_VALUE;
         if(this.m_questManagerData != null && this.m_questManagerData[KEY_REPLAYABLE_QUESTS] != null && this.m_questManagerData[KEY_REPLAYABLE_QUESTS][firstQuestName] != null && this.m_questManagerData[KEY_REPLAYABLE_QUESTS][firstQuestName][KEY_SORT_INDEX] != null)
         {
            result = int(this.m_questManagerData[KEY_REPLAYABLE_QUESTS][firstQuestName][KEY_SORT_INDEX]);
         }
         return result;
      }
      
      private function parseQuestPriceExperimentData() : void
      {
         var questPriceList:XMLList = null;
         var questPriceEntry:XML = null;
         var questName:String = null;
         var questTaskList:XMLList = null;
         var taskEntry:XML = null;
         var taskAction:String = null;
         var taskType:String = null;
         var taskIndex:String = null;
         var experimentList:XMLList = null;
         var experimentEntry:XML = null;
         var length:int = 0;
         var variant:int = 0;
         var xmlKey:String = null;
         if(this.m_questPriceExperimentData == null)
         {
            this.m_questPriceExperimentData = new Object();
            questPriceList = m_rawXml.questPriceTesting.quest;
            for each(questPriceEntry in questPriceList)
            {
               questName = String(questPriceEntry.@name);
               questTaskList = m_rawXml.questPriceTesting.quest.(@name == questName).task;
               for each(taskEntry in questTaskList)
               {
                  taskAction = taskEntry.@action.toString();
                  taskType = taskEntry.@type.toString();
                  taskIndex = questName + "_" + taskAction + "_" + taskType;
                  experimentList = taskEntry.experiment;
                  for each(experimentEntry in experimentList)
                  {
                     length = experimentEntry.length();
                     if(!this.m_questPriceExperimentData.hasOwnProperty(taskIndex))
                     {
                        this.m_questPriceExperimentData[taskIndex] = new Object();
                     }
                     this.m_questPriceExperimentData[taskIndex]["name"] = experimentEntry.@name.toString();
                     variant = 0;
                     while(experimentEntry.hasOwnProperty("@variant" + variant))
                     {
                        xmlKey = "variant" + variant;
                        this.m_questPriceExperimentData[taskIndex]["variant" + variant] = experimentEntry.attribute(xmlKey).toString();
                        variant++;
                     }
                  }
               }
            }
         }
      }
      
      private function getAllItemsInCategory(categoryName:String) : Array
      {
         var itemsInCategory:Array = null;
         var referencedCategoryList:XMLList = null;
         var categoryDescription:XML = null;
         var categoryItems:XMLList = null;
         var itemEntry:XML = null;
         var categoryReferences:XMLList = null;
         var referenceEntry:XML = null;
         itemsInCategory = new Array();
         referencedCategoryList = m_rawXml.categories.category.(@name == categoryName);
         if(referencedCategoryList.length() > 0)
         {
            categoryDescription = referencedCategoryList[0];
            categoryItems = categoryDescription.item;
            for each(itemEntry in categoryItems)
            {
               itemsInCategory.push(String(itemEntry.@code));
            }
            categoryReferences = categoryDescription.reference;
            for each(referenceEntry in categoryReferences)
            {
               itemsInCategory = itemsInCategory.concat(this.getAllItemsInCategory(String(referenceEntry.@name)));
            }
         }
         return itemsInCategory;
      }
      
      private function addCategoryToItemCode(itemCode:String, categoryName:String) : void
      {
         if(this.m_itemCategories.hasOwnProperty(itemCode) == false)
         {
            this.m_itemCategories[itemCode] = new Array();
         }
         if(this.m_itemCategories[itemCode].indexOf(categoryName) < 0)
         {
            this.m_itemCategories[itemCode].push(categoryName);
         }
      }
      
      override protected function getQuestXMLByName(nameStr:String) : XML
      {
         var list:XMLList = null;
         var result:XML = null;
         if(m_rawXml != null)
         {
            list = m_rawXml.quest.(@name == nameStr);
            if(list.length())
            {
               result = list[0];
            }
         }
         return result;
      }
      
      public function getItemByCode(code:int) : FarmQuest
      {
         var xml:XML = null;
         var quest:FarmQuest = this.m_questsById[code];
         if(quest == null)
         {
            xml = this.getQuestXMLByCode(code);
            if(xml != null)
            {
               quest = m_quests[xml.@name];
               if(null == quest)
               {
                  quest = new FarmQuest(xml);
                  m_quests[quest.name] = quest;
               }
               this.m_questsById[code] = quest;
            }
         }
         return quest;
      }
      
      public function getQuestItemByName(nameStr:String) : FarmQuest
      {
         var quest:FarmQuest = null;
         var xml:XML = this.getQuestXMLByName(nameStr);
         if(xml != null)
         {
            quest = m_quests[xml.@name];
            if(quest == null)
            {
               quest = new FarmQuest(xml);
               m_quests[quest.name] = quest;
            }
         }
         return quest;
      }
      
      protected function getQuestXMLByCode(code:int) : XML
      {
         var list:XMLList = null;
         var result:XML = null;
         if(m_rawXml != null)
         {
            list = m_rawXml.quest.(@memStoreId == code);
            if(list.length())
            {
               result = list[0];
            }
         }
         return result;
      }
      
      public function getTaskImage(taskName:String, questName:String) : String
      {
         var list:XMLList = null;
         var lastUnderScoreIndex:int = 0;
         var mapXml:XML = null;
         var result:String = "";
         if(Boolean(m_rawXml) && m_rawXml.hasOwnProperty("taskToImageMaps"))
         {
            list = m_rawXml.taskToImageMaps.map.(@task == taskName);
            lastUnderScoreIndex = 0;
            while(list.length() == 0)
            {
               lastUnderScoreIndex = taskName.lastIndexOf("_");
               if(lastUnderScoreIndex == -1)
               {
                  break;
               }
               taskName = taskName.slice(0,lastUnderScoreIndex);
               list = m_rawXml.taskToImageMaps.map.(@task == taskName);
            }
            if(list.length() == 1)
            {
               result = String(list[0].@image);
            }
            else if(list.length() > 1)
            {
               for each(mapXml in list)
               {
                  if(mapXml.@questName == questName)
                  {
                     result = String(mapXml.@image);
                     break;
                  }
                  if(mapXml.@questName.length() == 0)
                  {
                     result = String(mapXml.@image);
                  }
               }
            }
         }
         return result;
      }
      
      public function getTaskTargetType(taskType:String) : String
      {
         var list:XMLList = null;
         var result:String = "any";
         if(Boolean(m_rawXml) && m_rawXml.hasOwnProperty("taskTypes"))
         {
            list = m_rawXml.taskTypes.taskType.(@name == taskType);
            if(list.length() > 0)
            {
               result = String(list[0].@type);
            }
         }
         return result;
      }
      
      public function doesTaskTypeRequireServerSync(taskType:String) : Boolean
      {
         var taskTypeNameList:XMLList = null;
         var taskTypeNameXml:XML = null;
         var result:Boolean = false;
         if(m_rawXml)
         {
            if(!this.m_taskTypesRequiringServerSync)
            {
               this.m_taskTypesRequiringServerSync = {};
               taskTypeNameList = m_rawXml.taskTypes.taskType.(attribute(XML_KEY_REQUIRE_SERVER_RESPONSE) == "true").@name;
               for each(taskTypeNameXml in taskTypeNameList)
               {
                  this.m_taskTypesRequiringServerSync[taskTypeNameXml.toString()] = true;
               }
            }
            if(this.m_taskTypesRequiringServerSync[taskType])
            {
               result = true;
            }
         }
         return result;
      }
      
      public function getNextStartOrEndTimestamp() : Number
      {
         var now:Number = NaN;
         var questList:XMLList = null;
         var quest:XML = null;
         var prereqList:XMLList = null;
         var pq:XML = null;
         var testDateTime:String = null;
         var timeArr:Array = null;
         var testTimestamp:Number = NaN;
         var best:Number = 0;
         if(Global.farmGameSettingsManager.getXML() != null)
         {
            now = GlobalEngine.serverTime;
            questList = m_rawXml.quest;
            for each(quest in questList)
            {
               if(quest.prereqs)
               {
                  prereqList = quest.prereqs.prereq;
                  for each(pq in prereqList)
                  {
                     if(pq.@type != null && (pq.@type == PrerequisiteConstants.PREREQUISITE_START_TIME || pq.@type == PrerequisiteConstants.PREREQUISITE_END_TIME))
                     {
                        testDateTime = pq.@value;
                        timeArr = testDateTime.split(":",3);
                        if(timeArr.length == 2)
                        {
                           testDateTime += ":00";
                        }
                        testTimestamp = FarmGameUtil.synchronizedDateTimeToNumber(testDateTime);
                        if(testTimestamp > now && (best == 0 || testTimestamp < best))
                        {
                           best = testTimestamp;
                        }
                     }
                  }
               }
            }
         }
         return best;
      }
      
      public function getCategoryDefaultItemCode(categoryName:String) : String
      {
         var result:String = null;
         var list:XMLList = null;
         var itemsList:XMLList = null;
         result = "";
         list = m_rawXml.categories.category.(@name == categoryName);
         if(list.length() > 0)
         {
            itemsList = list[0].item;
            if(list[0].item.length() > 0)
            {
               result = String(list[0].item[0].@code);
            }
            else if(list[0].reference.length() > 0)
            {
               result = this.getCategoryDefaultItemCode(list[0].reference[0].@name);
            }
         }
         return result;
      }
      
      public function getquestPriceTestData() : Object
      {
         this.parseQuestPriceExperimentData();
         return this.m_questPriceExperimentData;
      }
      
      public function getTaskTransactions(taskType:String) : Array
      {
         var taskTypeDescriptions:XMLList = null;
         var transactionList:XMLList = null;
         var transactionDescription:XML = null;
         var transactionObject:Object = null;
         if(this.m_taskTransactions == null)
         {
            this.m_taskTransactions = new Object();
         }
         if(this.m_taskTransactions.hasOwnProperty(taskType) == false)
         {
            this.m_taskTransactions[taskType] = new Array();
            taskTypeDescriptions = m_rawXml.taskTypes.taskType.(@name == taskType);
            if(taskTypeDescriptions.length() > 0)
            {
               transactionList = taskTypeDescriptions.transaction;
               for each(transactionDescription in transactionList)
               {
                  transactionObject = {
                     "type":String(transactionDescription.@type),
                     "action":String(transactionDescription.@action)
                  };
                  this.m_taskTransactions[taskType].push(transactionObject);
               }
            }
         }
         return this.m_taskTransactions[taskType].slice(0);
      }
      
      public function areEntriesInCategory(entries:Array, categoryName:String) : Boolean
      {
         var result:Boolean = false;
         this.parseCategories();
         for(var i:int = 0; i < entries.length; i++)
         {
            if(this.m_itemCategories.hasOwnProperty(entries[i]))
            {
               result = this.m_itemCategories[entries[i]].indexOf(categoryName) >= 0;
            }
            if(!result)
            {
               break;
            }
         }
         return result;
      }
      
      public function isItemCodeInCategory(itemCode:String, categoryName:String) : Boolean
      {
         this.parseCategories();
         var isCodeInCategory:Boolean = false;
         if(this.m_itemCategories.hasOwnProperty(itemCode))
         {
            if(this.m_itemCategories[itemCode].indexOf(categoryName) >= 0)
            {
               isCodeInCategory = true;
            }
         }
         return isCodeInCategory;
      }
      
      public function getItemCodesInCategory(categoryName:String) : Array
      {
         var itemsInCategory:Array = null;
         var itemCode:String = null;
         this.parseCategories();
         if(this.m_categoryItems.hasOwnProperty(categoryName) == false)
         {
            itemsInCategory = new Array();
            for(itemCode in this.m_itemCategories)
            {
               if(this.m_itemCategories[itemCode].indexOf(categoryName) >= 0)
               {
                  itemsInCategory.push(itemCode);
               }
            }
            this.m_categoryItems[categoryName] = itemsInCategory;
         }
         return this.m_categoryItems[categoryName];
      }
      
      public function getAllQuestsInChain(chainName:String) : XMLList
      {
         var result:XMLList = null;
         if(m_rawXml != null)
         {
            result = m_rawXml.quest.(@name.toString().indexOf(chainName + "-") >= 0);
         }
         return result;
      }
      
      public function getChapterRewardQuestAtMapLocation(chainName:String, mapLocation:int) : FarmQuest
      {
         var xmlData:XML = null;
         var result:FarmQuest = null;
         var questsInChain:XMLList = this.getAllQuestsInChain(chainName);
         var mapLocationAsString:String = mapLocation.toString();
         if(questsInChain != null && questsInChain.length() > 0)
         {
            for each(xmlData in questsInChain)
            {
               if(xmlData.mapLocation.toString().split("-")[0] == mapLocationAsString)
               {
                  if(xmlData.frontend.chapterRewardImage.toString() != "")
                  {
                     result = this.getItemByName(xmlData.@name) as FarmQuest;
                     break;
                  }
               }
            }
         }
         return result;
      }
   }
}

