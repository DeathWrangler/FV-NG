package Classes.MOTD
{
   import Managers.FarmRunQuestManager;
   import Managers.FarmStatsManager;
   
   public class FarmRunQuestsMOTDHandler extends CustomWindowMOTDHandler
   {
      
      public function FarmRunQuestsMOTDHandler(currentMOTD:Object)
      {
         super(currentMOTD);
      }
      
      override protected function acceptMOTD() : void
      {
         super.acceptMOTD();
         FarmRunQuestManager.getInstance().openFarmRunQuestUI();
      }
      
      private function logButtonClick() : void
      {
         FarmStatsManager.count("FarmRunQuests","MOTD_Button_Clicked");
      }
   }
}

