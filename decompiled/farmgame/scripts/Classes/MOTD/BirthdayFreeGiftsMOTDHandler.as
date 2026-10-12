package Classes.MOTD
{
   import Managers.BirthdayFreeGiftsManager;
   
   public class BirthdayFreeGiftsMOTDHandler extends CustomWindowMOTDHandler
   {
      
      public function BirthdayFreeGiftsMOTDHandler(currentMotd:Object)
      {
         super(currentMotd);
      }
      
      override public function execute() : void
      {
         this.acceptMOTD();
         m_isFinished = true;
      }
      
      override protected function acceptMOTD() : void
      {
         super.acceptMOTD();
         BirthdayFreeGiftsManager.getInstance().displayDialog();
      }
   }
}

