package ZQuest.Classes
{
   import Engine.Interfaces.IEngineComponent;
   import ZQuest.Init.QuestInit;
   import ZQuest.Init.QuestSettingsInit;
   
   public class QuestComponent implements IEngineComponent
   {
      
      protected var m_options:QuestComponentOptions;
      
      public function QuestComponent(param1:QuestComponentOptions = null)
      {
         super();
         if(param1 == null)
         {
            param1 = new QuestComponentOptions();
         }
         this.m_options = param1;
      }
      
      public function initialize() : void
      {
         var _loc1_:String = Config.BASE_PATH + "questSettings.xml";
         if(GlobalEngine.getFlashVar("quest_url"))
         {
            _loc1_ = GlobalEngine.getFlashVar("quest_url") as String;
         }
         GlobalEngine.initializationManager.add(new QuestSettingsInit(_loc1_,this.m_options));
         GlobalEngine.initializationManager.add(new QuestInit(this.m_options.questManager));
      }
   }
}

