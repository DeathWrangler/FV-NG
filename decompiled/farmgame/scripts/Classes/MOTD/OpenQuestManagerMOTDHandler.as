package Classes.MOTD
{
   import Managers.QuestManagerDisplay;
   
   public class OpenQuestManagerMOTDHandler extends CustomWindowMOTDHandler
   {
      
      public function OpenQuestManagerMOTDHandler(currentMOTD:Object)
      {
         super(currentMOTD);
      }
      
      override protected function acceptMOTD() : void
      {
         super.acceptMOTD();
         QuestManagerDisplay.getInstance().openQuestManagerWindow(true);
      }
   }
}

