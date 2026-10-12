package Transactions
{
   public class TTopFriends extends TFarmTransaction
   {
      
      private static const DEFAULT_NUM_FRIENDS:int = 30;
      
      private var m_callback:Function;
      
      private var m_featureName:String;
      
      public function TTopFriends(callback:Function, featureName:String)
      {
         super();
         this.m_callback = callback;
         this.m_featureName = featureName;
      }
      
      override public function perform() : void
      {
         signedCall("FriendService.getGiftingFriends",DEFAULT_NUM_FRIENDS,this.m_featureName);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var friendIDs:Array = null;
         var friend:Object = null;
         if(result != null && this.m_callback != null)
         {
            friendIDs = new Array();
            for(friend in result)
            {
               if(Global.friendManager.neighborUids.indexOf(result[friend].uid) >= 0)
               {
                  friendIDs.push(result[friend]);
               }
            }
            this.m_callback(friendIDs);
         }
      }
   }
}

