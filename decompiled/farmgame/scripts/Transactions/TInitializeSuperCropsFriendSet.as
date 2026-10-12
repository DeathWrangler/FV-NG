package Transactions
{
   import Classes.FeatureDataObjects.SuperCropFriendSet;
   
   public class TInitializeSuperCropsFriendSet extends TFarmTransaction
   {
      
      protected var m_friendSet:SuperCropFriendSet;
      
      public function TInitializeSuperCropsFriendSet(dataObj:SuperCropFriendSet)
      {
         this.m_friendSet = dataObj;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("SuperCropsService.getProgress",this.m_friendSet.cropCode);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(Boolean(result.uids) && Boolean(result.pending) || Boolean(result.error))
         {
            this.m_friendSet.onInitialize(result);
         }
      }
   }
}

