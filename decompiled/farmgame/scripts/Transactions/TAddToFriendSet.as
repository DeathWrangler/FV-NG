package Transactions
{
   public class TAddToFriendSet extends TFarmTransaction
   {
      
      protected var m_code:String;
      
      protected var m_uids:Array = [];
      
      public function TAddToFriendSet(code:String, uids:Array)
      {
         super();
         this.m_code = code;
         this.m_uids = uids;
      }
      
      override public function perform() : void
      {
         signedCall("WallToWallFeatureService.recordFriendSetAddition",this.m_uids,this.m_code);
      }
   }
}

