package Transactions
{
   import Classes.FeatureDataObjects.FriendSet;
   
   public class TMarkLonelyAnimalFriendSet extends TFarmTransaction
   {
      
      public static const LONELY_ANIMAL_PROGRESS_NEW:int = 0;
      
      public static const LONELY_ANIMAL_PROGRESS_STARTED:int = 1;
      
      public static const LONELY_ANIMAL_PROGRESS_END:int = 2;
      
      protected var m_friendSet:FriendSet;
      
      protected var m_progress:int;
      
      public function TMarkLonelyAnimalFriendSet(dataObj:FriendSet, progress:int)
      {
         this.m_friendSet = dataObj;
         this.m_progress = progress;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("LonelyAnimalFriendSetService.markLonelyAnimalFriendSet",this.m_progress,this.m_friendSet.code,this.m_friendSet.index);
      }
   }
}

