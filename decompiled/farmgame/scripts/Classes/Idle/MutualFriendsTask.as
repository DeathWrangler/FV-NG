package Classes.Idle
{
   import Engine.Managers.TransactionManager;
   import Managers.WorldManager;
   import Transactions.TMutualFriends;
   
   public class MutualFriendsTask extends BaseIdleTask
   {
      
      protected static const MIN_MOUSE_IDLE_MS:int = 3 * 1000;
      
      public function MutualFriendsTask()
      {
         super();
      }
      
      override public function get requireMouseIdle() : Boolean
      {
         return true;
      }
      
      override public function get minMouseIdleMilliseconds() : Number
      {
         return MIN_MOUSE_IDLE_MS;
      }
      
      override public function get requireActionQueueIdle() : Boolean
      {
         return false;
      }
      
      override public function get canFire() : Boolean
      {
         return TMutualFriends.canFire();
      }
      
      override public function fire() : void
      {
         if(!Global.worldManager.isVisitingCommunityNeighbor() && WorldManager.INVALID_VISIT_ID != Global.worldManager.getVisiting())
         {
            TransactionManager.addTransaction(new TMutualFriends(Global.worldManager.getVisiting()));
         }
      }
   }
}

