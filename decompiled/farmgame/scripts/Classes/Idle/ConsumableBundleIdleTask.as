package Classes.Idle
{
   import Managers.ConsumableBundleManager;
   
   public class ConsumableBundleIdleTask extends BaseIdleTask
   {
      
      private static const ZRUNTIME_KEY_CONSUMABLE_BUNDLE_IDLE_TIME:String = "CONSUMABLE_BUNDLE_IDLE_TIME";
      
      private static const FEATURE_FLASHPARAM_CONSUMABLE_TO_SHOW:String = "CONSUMABLE_WINDOW_TO_SHOW";
      
      public static const MOUSE_IDLE_MILLISECONDS:Number = 2000;
      
      private var m_featureName:String = "consumable_bundle";
      
      public function ConsumableBundleIdleTask()
      {
         super();
         m_displaysPopup = true;
      }
      
      override public function get shouldAdd() : Boolean
      {
         return true;
      }
      
      override public function get minMouseIdleMilliseconds() : Number
      {
         var idleTimer:Number = MOUSE_IDLE_MILLISECONDS;
         if(Global.flashHotParams.hasOwnProperty(ZRUNTIME_KEY_CONSUMABLE_BUNDLE_IDLE_TIME))
         {
            idleTimer = Number(Global.flashHotParams[ZRUNTIME_KEY_CONSUMABLE_BUNDLE_IDLE_TIME]);
            idleTimer *= 1000;
         }
         return idleTimer;
      }
      
      override public function get requireActionQueueIdle() : Boolean
      {
         return false;
      }
      
      override public function get canFire() : Boolean
      {
         return ConsumableBundleManager.getInstance().canDisplayPopup() && !Global.player.getSeenSessionFlag(FEATURE_FLASHPARAM_CONSUMABLE_TO_SHOW);
      }
      
      override public function fire() : void
      {
         var wasWindowOpened:Boolean = true;
         ConsumableBundleManager.getInstance(this.m_featureName).handleHUDClick();
         IdleTaskQueue.getInstance().addTask(new ConsumableBundleIdleTask());
         if(wasWindowOpened)
         {
            Global.player.setSeenSessionFlag(FEATURE_FLASHPARAM_CONSUMABLE_TO_SHOW);
         }
      }
   }
}

