package Classes.FeatureDataObjects
{
   import Managers.PartyManager;
   
   public class NeighborFeatureFriendSet extends FeatureFriendSet
   {
      
      public function NeighborFeatureFriendSet(code:String, index:Number = -2, callback:Function = null)
      {
         super(code,index,callback);
      }
      
      override public function onInitialize(result:Object) : void
      {
         super.onInitialize(result);
         PartyManager.getInstance().placeBuildingPartyAvatars(m_code);
      }
      
      override public function get className() : String
      {
         return FriendSet.NEIGHBOR_FEATURE_FRIEND_SET;
      }
      
      override public function getDifficultyForLevel(level:int, min:int, max:int) : int
      {
         var numNeighbors:int = Global.friendManager.neighborCount ? Global.friendManager.neighborCount : 1;
         var result:int = max;
         switch(level)
         {
            case 1:
               result = numNeighbors / 8;
               break;
            case 2:
               result = numNeighbors / 4;
               break;
            case 3:
               result = numNeighbors / 2;
               break;
            case 4:
               result = numNeighbors;
         }
         return max;
      }
   }
}

