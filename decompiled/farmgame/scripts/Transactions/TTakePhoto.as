package Transactions
{
   public class TTakePhoto extends TFarmTransaction
   {
      
      private var m_userid:String;
      
      public function TTakePhoto(userid:String)
      {
         this.m_userid = userid;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("FarmService.takePhoto",this.m_userid);
      }
   }
}

