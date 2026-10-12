package Transactions
{
   public class TSetFriendSetSeen extends TFarmTransaction
   {
      
      protected var m_code:String;
      
      public function TSetFriendSetSeen(code:String)
      {
         super();
         this.m_code = code;
      }
      
      override public function perform() : void
      {
         signedCall("WallToWallFeatureService.setFriendSetSeen",this.m_code);
      }
   }
}

