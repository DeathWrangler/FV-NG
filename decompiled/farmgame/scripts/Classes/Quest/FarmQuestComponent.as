package Classes.Quest
{
   import Classes.Constants.Experiments;
   import ZQuest.Classes.QuestComponent;
   import ZQuest.Classes.QuestComponentOptions;
   import ZQuest.Init.QuestInit;
   
   public class FarmQuestComponent extends QuestComponent
   {
      
      public static const QUESTS_URL:String = "quest_url";
      
      public static const QUESTS_MIN_URL:String = "quest_min_url";
      
      private static const questManagerClass:Class = FarmQuestManager;
      
      public function FarmQuestComponent(options:QuestComponentOptions = null)
      {
         super(options);
      }
      
      override public function initialize() : void
      {
         var questSettingsUrl:String = Global.getXMLPath() + "questSettings.xml.gz";
         if(GlobalEngine.getFlashVar("quest_url"))
         {
            questSettingsUrl = GlobalEngine.getFlashVar(FarmQuestComponent.QUESTS_URL) as String;
         }
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_OPS_QUEST_SETTINGS_REDUCTION) == Experiments.VARIANT_OPS_QUEST_SETTINGS_REDUCTION)
         {
            if(GlobalEngine.getFlashVar(FarmQuestComponent.QUESTS_MIN_URL))
            {
               questSettingsUrl = GlobalEngine.getFlashVar(FarmQuestComponent.QUESTS_MIN_URL) as String;
            }
            else
            {
               questSettingsUrl = Global.getXMLPath() + "questSettings_min.xml.gz";
            }
         }
         var fqsi:FarmQuestSettingsInit = this.initializeFarmQuestSettingsinit(questSettingsUrl);
         GlobalEngine.initializationManager.add(fqsi);
         GlobalEngine.initializationManager.add(new QuestInit(questManagerClass));
      }
      
      public function initializeFarmQuestSettingsinit(questSettingsUrl:String) : FarmQuestSettingsInit
      {
         var options:QuestComponentOptions = new QuestComponentOptions();
         options.questClass = FarmQuest;
         options.questManager = questManagerClass;
         options.questUtility = FarmQuestUtility;
         return new FarmQuestSettingsInit(questSettingsUrl,options);
      }
   }
}

