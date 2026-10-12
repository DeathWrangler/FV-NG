package Classes.FeatureDataObjects
{
   public class MysteryEggFriendSet extends FeatureFriendSet
   {
      
      public static const BASE_COST:Number = 3;
      
      public static const MYSTERY_EGG_CODE:String = "FS09";
      
      private var m_rewardLinks:Array;
      
      private var m_isRare:Boolean;
      
      private var m_timeRemaining:Number = 0;
      
      public function MysteryEggFriendSet(code:String, index:Number = -2, callback:Function = null)
      {
         super(code,index,callback);
         this.m_rewardLinks = new Array();
      }
      
      override public function onInitialize(result:Object) : void
      {
         var rewardLink:String = null;
         if(result.rewardLinks != null && result.rewardLinks.length > 0)
         {
            for each(rewardLink in result.rewardLinks)
            {
               this.m_rewardLinks.push(rewardLink);
            }
         }
         if(result.isRare != null)
         {
            this.m_isRare = result.isRare;
         }
         if(result.timeRemaining != null)
         {
            this.m_timeRemaining = result.timeRemaining;
         }
         super.onInitialize(result);
      }
      
      public function get timeRemaining() : Number
      {
         return this.m_timeRemaining;
      }
      
      override public function get className() : String
      {
         return FriendSet.MYSTERY_EGG_FRIEND_SET;
      }
      
      public function get rewardLinks() : Array
      {
         return this.m_rewardLinks;
      }
   }
}

