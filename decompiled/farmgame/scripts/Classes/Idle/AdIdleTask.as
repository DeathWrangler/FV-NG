package Classes.Idle
{
   import Classes.AdItem;
   import Classes.TutController;
   import Managers.SurveyManager;
   
   public class AdIdleTask extends BaseIdleTask
   {
      
      protected static var m_shouldShow:Boolean = true;
      
      protected var m_mouseDelay:Number = 15000;
      
      protected var m_ad:AdItem = null;
      
      public function AdIdleTask()
      {
         var hasFlashVars:Boolean = false;
         super();
         m_displaysPopup = true;
         if(m_shouldShow)
         {
            hasFlashVars = GlobalEngine.getFlashVar("showAd") != null && GlobalEngine.getFlashVar("showAd") == true;
            if(hasFlashVars)
            {
               this.m_ad = Global.farmGameSettingsManager.getRandomAdBySN();
               this.m_mouseDelay = this.m_ad.delay * 1000;
            }
            if(null == this.m_ad)
            {
               m_shouldShow = false;
            }
         }
      }
      
      override public function get shouldAdd() : Boolean
      {
         if(!super.isEligibleForPopups())
         {
            return false;
         }
         return m_shouldShow;
      }
      
      override public function get requireActionQueueIdle() : Boolean
      {
         return false;
      }
      
      override public function get minMouseIdleMilliseconds() : Number
      {
         return this.m_mouseDelay;
      }
      
      override public function get canFire() : Boolean
      {
         return TutController.hasFinishedTutorial();
      }
      
      override public function fire() : void
      {
         SurveyManager.getInstance().displaySurveyToaster(this.m_ad);
         m_shouldShow = false;
      }
   }
}

