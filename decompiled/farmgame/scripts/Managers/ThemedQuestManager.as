package Managers
{
   import Classes.Constants.Experiments;
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmQuestManager;
   import Classes.Quest.FarmQuestSettingsInit;
   
   public class ThemedQuestManager
   {
      
      private static var s_instance:ThemedQuestManager;
      
      private static const QUESTS:String = "quests";
      
      private static const BACKGROUND:String = "background";
      
      private static const TYPE:String = "type";
      
      private static const INDEX:String = "index";
      
      private static const TOTAL_QUESTS:String = "totalQuests";
      
      public static const INSTANCE_PREFIX:String = "taskGroup";
      
      public static const INSTANCE_POSTFIX:String = "_mc";
      
      private static const UBER:String = "uber";
      
      private var m_featureData:Object;
      
      public function ThemedQuestManager(key:SingletonEnforcer)
      {
         super();
         GlobalEngine.assert(key != null,"[ThemedQuestManager] :: Use ThemedQuestManager.instance");
         this.m_featureData = {};
      }
      
      public static function get instance() : ThemedQuestManager
      {
         if(!s_instance)
         {
            s_instance = new ThemedQuestManager(new SingletonEnforcer());
         }
         return s_instance;
      }
      
      public static function getInstanceNameForActiveQuest(questName:String) : String
      {
         var result:String = null;
         var quest:FarmQuest = FarmQuestManager.getInstance().getActiveQuestByName(questName);
         if(Boolean(quest) && Boolean(quest.farmTasks))
         {
            result = INSTANCE_PREFIX + String(quest.farmTasks.length) + INSTANCE_POSTFIX;
         }
         return result;
      }
      
      private function getData(featureName:String) : Object
      {
         var featureXML:XML = null;
         var quests:Object = null;
         var questsXmlList:XMLList = null;
         var totalQuests:int = 0;
         var questXml:XML = null;
         if(!this.m_featureData.hasOwnProperty(featureName))
         {
            featureXML = Global.farmGameSettingsManager.getFeatureXML(featureName);
            if(featureXML)
            {
               quests = {};
               questsXmlList = featureXML.quest;
               totalQuests = 0;
               for each(questXml in questsXmlList)
               {
                  quests[questXml.@name.toString()] = {
                     "name":questXml.@name.toString(),
                     "background":questXml.@background.toString(),
                     "instance":questXml.@instance.toString(),
                     "type":questXml.@type.toString(),
                     "index":questXml.@index.toString()
                  };
                  totalQuests++;
               }
               this.m_featureData[featureName] = {
                  "quests":quests,
                  "swf":featureXML.@swf.toString(),
                  "totalQuests":totalQuests
               };
            }
         }
         return this.m_featureData[featureName];
      }
      
      public function getWindowAssetforFeatureName(featureName:String) : String
      {
         var result:String = "";
         var data:Object = this.getData(featureName);
         if(data)
         {
            result = data.swf;
         }
         return result;
      }
      
      public function getQuestsForFeature(featureName:String) : Array
      {
         var questName:String = null;
         var questIndex:int = 0;
         var quest:FarmQuest = null;
         var result:Array = null;
         var data:Object = this.getData(featureName);
         if(data)
         {
            result = new Array(data[TOTAL_QUESTS]);
            for(questName in data[QUESTS])
            {
               questIndex = int(data[QUESTS][questName][INDEX]);
               quest = FarmQuestSettingsInit.getInstance().getItemByName(questName) as FarmQuest;
               if(quest)
               {
                  result[questIndex] = quest;
               }
            }
         }
         return result;
      }
      
      private function isAnyQuestInFeatureActive(featureName:String) : Boolean
      {
         var questName:String = null;
         var quest:FarmQuest = null;
         var result:Boolean = false;
         var data:Object = this.getData(featureName);
         if(data)
         {
            for(questName in data[QUESTS])
            {
               quest = FarmQuestManager.getInstance().getActiveQuestByName(questName) as FarmQuest;
               if(quest)
               {
                  result = true;
                  break;
               }
            }
         }
         return result;
      }
      
      private function isAnyQuestInFeatureComplete(featureName:String) : Boolean
      {
         var questName:String = null;
         var result:Boolean = false;
         var data:Object = this.getData(featureName);
         if(data)
         {
            for(questName in data[QUESTS])
            {
               if(FarmQuestManager.getInstance().hasReplayableQuestBeenCompleted(questName))
               {
                  result = true;
                  break;
               }
            }
         }
         return result;
      }
      
      public function isFeatureActive(featureName:String) : Boolean
      {
         return Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_THEMED_QUESTS_PUZZLE) >= 1 && (this.isAnyQuestInFeatureActive(featureName) || this.isAnyQuestInFeatureComplete(featureName));
      }
      
      public function isThemedUberQuest(featureName:String, questName:String) : Boolean
      {
         var result:Boolean = false;
         var data:Object = this.getData(featureName);
         if(data)
         {
            result = data[QUESTS][questName][TYPE] == UBER;
         }
         return result;
      }
      
      public function getUberQuestForFeature(featureName:String) : FarmQuest
      {
         var questName:String = null;
         var result:FarmQuest = null;
         var data:Object = this.getData(featureName);
         if(data)
         {
            for(questName in data[QUESTS])
            {
               if(data[QUESTS][questName][TYPE] == UBER)
               {
                  result = FarmQuestSettingsInit.getInstance().getItemByName(questName) as FarmQuest;
                  break;
               }
            }
         }
         return result;
      }
      
      public function getBackgroundForFeatureQuest(featureName:String, questName:String) : String
      {
         var result:String = "";
         var data:Object = this.getData(featureName);
         if(data)
         {
            result = data[QUESTS][questName][BACKGROUND];
         }
         return result;
      }
   }
}

class SingletonEnforcer
{
   
   public function SingletonEnforcer()
   {
      super();
   }
}
