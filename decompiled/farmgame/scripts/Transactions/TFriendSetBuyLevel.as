package Transactions
{
   import Classes.FeatureDataObjects.FriendSet;
   
   public class TFriendSetBuyLevel extends TCompleteFriendSet
   {
      
      private static const STATUS_BUY_FRIENDS_SUCCESS:Number = 1;
      
      private static const STATUS_BUY_ALREADY_COMPLETE:Number = 2;
      
      private var m_level:int = 0;
      
      public function TFriendSetBuyLevel(dataObj:FriendSet, level:int, callback:Function = null)
      {
         super(dataObj,callback);
         this.m_level = level;
      }
      
      override public function perform() : void
      {
         signedCall("FriendSetService.buyLevel",this.m_friendSet.code,this.m_level);
      }
   }
}

