package Classes.FeatureDataObjects
{
   public class ItemFeatureFriendSet extends FeatureFriendSet
   {
      
      public function ItemFeatureFriendSet(code:String, index:Number, callback:Function = null)
      {
         super(code,index,callback);
      }
      
      override public function get className() : String
      {
         return FriendSet.ITEM_FEATURE_FRIEND_SET;
      }
   }
}

