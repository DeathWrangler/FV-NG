package Transactions
{
   public class TGetFriendSetFriends extends TFarmTransaction
   {
      
      private var m_callback:Function;
      
      private var m_specs:Array;
      
      private var m_featureName:String;
      
      private var m_friendSetCode:String;
      
      private var m_currentFriendSet:String;
      
      public function TGetFriendSetFriends(specs:Array, featureName:String, friendSetCode:String, currentFriendSet:String, callback:Function = null)
      {
         super();
         this.m_callback = callback;
         this.m_specs = specs;
         this.m_featureName = featureName;
         this.m_friendSetCode = friendSetCode;
         this.m_currentFriendSet = currentFriendSet;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.getFriendSetFriends",this.m_specs,this.m_featureName,this.m_friendSetCode,this.m_currentFriendSet);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(null != this.m_callback)
         {
            this.m_callback(result);
         }
      }
   }
}

