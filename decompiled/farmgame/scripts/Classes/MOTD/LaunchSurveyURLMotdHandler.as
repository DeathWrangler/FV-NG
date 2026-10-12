package Classes.MOTD
{
   public class LaunchSurveyURLMotdHandler extends LaunchURLMotdHandler
   {
      
      public function LaunchSurveyURLMotdHandler(currentMOTD:Object)
      {
         super(currentMOTD);
         if(m_url)
         {
            m_url = m_url.replace("%UID%",Global.player.uid);
         }
      }
   }
}

