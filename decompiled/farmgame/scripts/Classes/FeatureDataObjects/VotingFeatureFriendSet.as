package Classes.FeatureDataObjects
{
   public class VotingFeatureFriendSet extends FeatureFriendSet
   {
      
      protected var m_metaInfo:Array = new Array();
      
      public function VotingFeatureFriendSet(code:String, index:Number = -2, callback:Function = null)
      {
         super(code,index,callback);
      }
      
      override public function get className() : String
      {
         return FriendSet.VOTING_FEATURE_FRIEND_SET;
      }
      
      override public function onInitialize(result:Object) : void
      {
         var metaInfo:Object = null;
         var friends:String = null;
         var emptyData:Array = null;
         if(result.metaInfo != null)
         {
            metaInfo = result.metaInfo;
            for(friends in metaInfo)
            {
               this.m_metaInfo[friends] = metaInfo[friends];
            }
         }
         else
         {
            emptyData = new Array();
            emptyData.push(new Array());
            emptyData.push(new Array());
            this.m_metaInfo = emptyData;
         }
         super.onInitialize(result);
      }
      
      override public function get votingFriends() : Array
      {
         return this.m_metaInfo;
      }
      
      override public function votingFriendsByIndex(voteIndex:int) : Array
      {
         var result:Array = [];
         if(this.m_metaInfo[voteIndex])
         {
            result = this.m_metaInfo[voteIndex];
         }
         return result;
      }
   }
}

