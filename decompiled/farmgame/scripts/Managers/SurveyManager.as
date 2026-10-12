package Managers
{
   import Classes.AdItem;
   import Classes.Idle.IdleTaskQueue;
   import Classes.Idle.SurveyIdleTask;
   import Widgets.Windows.GenericAdToaster;
   import flash.external.ExternalInterface;
   
   public class SurveyManager
   {
      
      private static var m_instance:SurveyManager = null;
      
      private static const SURVEY_STATS_COUNTER:String = "survey";
      
      private var m_overlaySurveyURL:String;
      
      public function SurveyManager()
      {
         super();
      }
      
      public static function getInstance() : SurveyManager
      {
         if(null == m_instance)
         {
            m_instance = new SurveyManager();
         }
         return m_instance;
      }
      
      public function initializeSurveyOverlay(surveyURL:String) : void
      {
         if(surveyURL)
         {
            this.m_overlaySurveyURL = surveyURL;
            IdleTaskQueue.getInstance().addTask(new SurveyIdleTask());
            FarmStatsManager.count(SurveyManager.SURVEY_STATS_COUNTER,"survey idle task added to queue");
         }
      }
      
      public function displaySurveyOverlay() : void
      {
         if(Boolean(this.m_overlaySurveyURL) && ExternalInterface.available)
         {
            ExternalInterface.call("theFarmOverlay.showSurveyOverlay",this.m_overlaySurveyURL);
            FarmStatsManager.count(SurveyManager.SURVEY_STATS_COUNTER,"survey overlay triggered");
         }
      }
      
      public function displaySurveyToaster(adItem:AdItem) : void
      {
         if(!Global.player.getSeenFlag("surveySeen"))
         {
            ToasterManager.getInstance().add(new GenericAdToaster(adItem));
            Global.player.setSeenFlag("surveySeen",true);
            FarmStatsManager.count(SurveyManager.SURVEY_STATS_COUNTER,"survey toaster triggered");
         }
      }
   }
}

