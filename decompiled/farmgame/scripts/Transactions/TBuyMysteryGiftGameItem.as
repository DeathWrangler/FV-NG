package Transactions
{
   import Display.MysteryBoxBalloonDialog;
   
   public class TBuyMysteryGiftGameItem extends TFarmTransaction
   {
      
      private var m_tileID:int;
      
      private var m_mbox:MysteryBoxBalloonDialog;
      
      private var m_boxName:String;
      
      public function TBuyMysteryGiftGameItem(tileID:int, mbox:MysteryBoxBalloonDialog, boxName:String)
      {
         super();
         this.m_mbox = mbox;
         this.m_tileID = tileID;
         this.m_boxName = boxName;
      }
      
      override public function perform() : void
      {
         signedCall("MysteryBoxBalloonService.buyMysteryItem",this.m_boxName,this.m_tileID);
      }
   }
}

