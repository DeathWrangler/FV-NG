package Transactions
{
   import Display.MysteryBoxBalloonDialog;
   
   public class TBuyMysteryGiftTurn extends TFarmTransaction
   {
      
      private var m_targetID:int;
      
      private var m_mbox:MysteryBoxBalloonDialog;
      
      private var m_boxName:String;
      
      public function TBuyMysteryGiftTurn(targetID:int, mbox:MysteryBoxBalloonDialog, boxName:String)
      {
         super();
         this.m_mbox = mbox;
         this.m_targetID = targetID;
         this.m_boxName = boxName;
      }
      
      override public function perform() : void
      {
         signedCall("MysteryBoxBalloonService.play",this.m_boxName,this.m_targetID);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result != null)
         {
            if(result.complete)
            {
               this.m_mbox.onDataReturn(result);
            }
         }
      }
   }
}

