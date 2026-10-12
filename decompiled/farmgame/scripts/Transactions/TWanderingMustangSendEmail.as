package Transactions
{
   public class TWanderingMustangSendEmail extends TFarmTransaction
   {
      
      public var m_friendList:Array;
      
      public var m_rewardId:String;
      
      public function TWanderingMustangSendEmail(friendList:Array, rewardId:String)
      {
         super();
         this.m_friendList = friendList;
         this.m_rewardId = rewardId;
      }
      
      override public function perform() : void
      {
         signedCall("WanderingAnimalService.onWanderingMustangSendEmail",this.m_friendList,this.m_rewardId);
      }
   }
}

