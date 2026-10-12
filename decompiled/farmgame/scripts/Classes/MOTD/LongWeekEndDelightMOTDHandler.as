package Classes.MOTD
{
   import Managers.WeekendDelightManager;
   
   public class LongWeekEndDelightMOTDHandler extends CustomWindowMOTDHandler
   {
      
      public function LongWeekEndDelightMOTDHandler(currentMOTD:Object)
      {
         super(currentMOTD);
      }
      
      override protected function acceptMOTD() : void
      {
         super.acceptMOTD();
         WeekendDelightManager.getInstance().grantItemOfTheDay();
         WeekendDelightManager.getInstance().removeFeatureHudIcon();
      }
   }
}

