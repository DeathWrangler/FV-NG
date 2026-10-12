package Managers
{
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmQuestManager;
   import Classes.util.FarmGameUtil;
   import Widgets.Windows.ContextMenuQuestToaster;
   import ZQuest.Classes.Quest;
   
   public class ContextMenuQuestManager
   {
      
      private static var s_instance:ContextMenuQuestManager;
      
      private static const FEATURE_NAME:String = "contextMenuQuests";
      
      private static const SEEN_UI_FLAG:String = "contextWindowShown_";
      
      private static const DEFAULT_REACTIVATION_WAIT_DAYS:int = 2;
      
      public static const MAP_TRIGGER_REACTIVATION_IDLE_TASK_DELAY:int = 60;
      
      private var m_questMapping:Object;
      
      private var m_loadedData:Boolean;
      
      public function ContextMenuQuestManager(enforcer:SingletonEnforcer)
      {
         super();
         GlobalEngine.assert(enforcer != null,"ContextMenuQuestManager is a singleton. Use ContextMenuQuestManager.instance");
      }
      
      public static function get instance() : ContextMenuQuestManager
      {
         if(!s_instance)
         {
            s_instance = new ContextMenuQuestManager(new SingletonEnforcer());
         }
         return s_instance;
      }
      
      private function initMapping() : void
      {
         var quests:XMLList = null;
         var quest:XML = null;
         var questName:String = null;
         var itemName:XML = null;
         var xmlConfig:XML = Global.farmGameSettingsManager.getFeatureXML(FEATURE_NAME);
         if(xmlConfig)
         {
            this.m_questMapping = {};
            quests = xmlConfig.quest;
            for each(quest in quests)
            {
               if(quest.hasOwnProperty("@chainName"))
               {
                  questName = quest.@chainName.toString();
                  for each(itemName in quest.item)
                  {
                     this.m_questMapping[itemName.toString()] = questName;
                  }
               }
            }
            this.m_loadedData = true;
         }
      }
      
      public function hasActiveQuest(itemName:String) : Boolean
      {
         return this.getQuestForItemName(itemName) != null;
      }
      
      public function getQuestForItemName(itemName:String) : FarmQuest
      {
         var activeQuests:Vector.<Quest> = null;
         var quest:FarmQuest = null;
         var result:FarmQuest = null;
         if(!this.m_loadedData)
         {
            this.initMapping();
         }
         var questChainName:String = this.m_questMapping[itemName];
         if(questChainName)
         {
            activeQuests = FarmQuestManager.getInstance().getActiveQuests();
            if(activeQuests)
            {
               for each(quest in activeQuests)
               {
                  if(questChainName == quest.chain && !FarmQuestManager.getInstance().isQuestComplete(quest.name))
                  {
                     result = quest;
                     break;
                  }
               }
            }
         }
         return result;
      }
      
      public function openQuest(itemName:String) : void
      {
         var quest:FarmQuest = this.getQuestForItemName(itemName);
         if(quest)
         {
            this.setWindowOpenBackoff(quest.chain);
            quest.showProgress();
         }
      }
      
      public function mainUIOpenFlag(quest:FarmQuest) : String
      {
         return quest.chain + "_uiOpen";
      }
      
      public function setWindowOpenBackoff(questChain:String) : void
      {
         Global.player.setFeatureLastShown(SEEN_UI_FLAG + questChain,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,true);
      }
      
      public function conditionallyShowActivationToaster(itemName:String) : void
      {
         var reactivationWaitDays:int = 0;
         var quest:FarmQuest = this.getQuestForItemName(itemName);
         if(quest)
         {
            reactivationWaitDays = Global.farmGameSettingsManager.getInt("ContextMenuQuestReactivationWait_" + quest.chain,DEFAULT_REACTIVATION_WAIT_DAYS);
            if(Global.player.canShowFeatureWithFeatureFrequency(SEEN_UI_FLAG + quest.chain,reactivationWaitDays))
            {
               this.setWindowOpenBackoff(quest.chain);
               ToasterManager.getInstance().add(new ContextMenuQuestToaster(quest,0,ContextMenuQuestToaster.STATE_REACTIVATE));
            }
         }
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
