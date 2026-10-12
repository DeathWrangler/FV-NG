package Transactions
{
   import Display.MysteryBoxBalloonDialog;
   
   public class TGetMysteryLoot extends TFarmTransaction
   {
      
      private var m_mbox:MysteryBoxBalloonDialog;
      
      private var m_boxName:String;
      
      public function TGetMysteryLoot(mbox:MysteryBoxBalloonDialog, boxName:String)
      {
         super();
         this.m_mbox = mbox;
         this.m_boxName = boxName;
      }
      
      override public function perform() : void
      {
         signedCall("MysteryBoxBalloonService.getMysteryLoot",this.m_boxName);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result != null)
         {
            this.m_mbox.onLootDataReturn(result);
         }
      }
   }
}

