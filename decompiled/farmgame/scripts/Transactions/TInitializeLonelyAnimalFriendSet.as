package Transactions
{
   import Classes.FeatureDataObjects.FriendSet;
   
   public class TInitializeLonelyAnimalFriendSet extends TFarmTransaction
   {
      
      protected var m_friendSet:FriendSet;
      
      public function TInitializeLonelyAnimalFriendSet(dataObj:FriendSet)
      {
         this.m_friendSet = dataObj;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("LonelyAnimalFriendSetService.getLonelyAnimalFriendSetData",this.m_friendSet.code,this.m_friendSet.index);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(Boolean(result.uids) && Boolean(result.pending))
         {
            this.m_friendSet.onInitialize(result);
         }
      }
   }
}

