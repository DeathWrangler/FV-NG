package Classes.Idle
{
   import Managers.CollectionsManager;
   
   public class CollectionsIdleTask extends BaseIdleTask
   {
      
      public function CollectionsIdleTask()
      {
         super();
      }
      
      override public function get shouldAdd() : Boolean
      {
         return true;
      }
      
      override public function get requireActionQueueIdle() : Boolean
      {
         return false;
      }
      
      override public function get canFire() : Boolean
      {
         return CollectionsManager.getInstance().canDisplaySharePopup;
      }
      
      override public function fire() : void
      {
         CollectionsManager.getInstance().displayShareCollectiblePopup();
         IdleTaskQueue.getInstance().addTask(new CollectionsIdleTask());
      }
   }
}

