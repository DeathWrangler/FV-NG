package Classes.FeatureDataObjects
{
   public class LonelyAnimalFeatureFriendSet extends FeatureFriendSet
   {
      
      public static const NUM_DAYS_ACTIVE:Number = 3;
      
      private var m_rewardLink:String = "";
      
      public function LonelyAnimalFeatureFriendSet(code:String, index:Number, callback:Function = null)
      {
         super(code,index,callback);
      }
      
      override public function onInitialize(result:Object) : void
      {
         if(result.rewardLink != null && result.rewardLink != "")
         {
            this.m_rewardLink = result.rewardLink;
         }
         super.onInitialize(result);
      }
      
      override public function get className() : String
      {
         return FriendSet.LONELYANIMAL_FEATURE_FRIEND_SET;
      }
      
      public function get rewardLink() : String
      {
         return this.m_rewardLink;
      }
      
      override public function completionSeen() : void
      {
         super.completionSeen();
      }
   }
}

