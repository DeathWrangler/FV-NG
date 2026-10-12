package Classes.Idle
{
   import Managers.SurveyManager;
   
   public class SurveyIdleTask extends BaseIdleTask
   {
      
      protected var m_timeToPop:int = Global.farmGameSettingsManager.getInt("surveyOverlayDelaySeconds",10) * 1000;
      
      public function SurveyIdleTask()
      {
         super();
      }
      
      override public function fire() : void
      {
         SurveyManager.getInstance().displaySurveyOverlay();
      }
      
      override public function get canFire() : Boolean
      {
         return GlobalEngine.currentTime > this.m_timeToPop;
      }
   }
}

