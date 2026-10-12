package Classes.Idle
{
   import Managers.FarmStatsManager;
   import Managers.NoPopupManager;
   import flash.utils.getQualifiedClassName;
   
   public class BaseIdleTask
   {
      
      public static const DEFAULT_QUEUE_COOLDOWN_MILLISECONDS:Number = 1000;
      
      public static const DEFAULT_MOUSE_MILLISECONDS:Number = 5000;
      
      public static const DEFAULT_ACTION_QUEUE_MILLISECONDS:Number = 5000;
      
      public static const DEFAULT_POPUP_QUEUE_MILLISECONDS:Number = 5000;
      
      protected var m_timeAddedMilliseconds:Number;
      
      protected var m_displaysPopup:Boolean = false;
      
      public function BaseIdleTask(params:Object = null)
      {
         super();
      }
      
      public function get requireMouseIdle() : Boolean
      {
         return true;
      }
      
      public function get minMouseIdleMilliseconds() : Number
      {
         return DEFAULT_MOUSE_MILLISECONDS;
      }
      
      public function get requireActionQueueIdle() : Boolean
      {
         return true;
      }
      
      public function get minActionIdleMilliseconds() : Number
      {
         return DEFAULT_ACTION_QUEUE_MILLISECONDS;
      }
      
      public function get requirePopupQueueEmpty() : Boolean
      {
         return true;
      }
      
      public function get minPopupIdleMilliseconds() : Number
      {
         return DEFAULT_POPUP_QUEUE_MILLISECONDS;
      }
      
      public function get queueCoolDownMilliseconds() : Number
      {
         return DEFAULT_QUEUE_COOLDOWN_MILLISECONDS;
      }
      
      public function get singleton() : Boolean
      {
         return true;
      }
      
      public function get singletonClobber() : Boolean
      {
         return false;
      }
      
      public function get canHaveDuplicates() : Boolean
      {
         return false;
      }
      
      public function get shouldAdd() : Boolean
      {
         if(!this.isEligibleForPopups())
         {
            return false;
         }
         return true;
      }
      
      public function isEligibleForPopups() : Boolean
      {
         var className:String = null;
         var dispObjArr:Array = null;
         var passReq:Boolean = true;
         if(this.m_displaysPopup)
         {
            if(Global.nopopupManager.isEligible())
            {
               passReq = false;
               className = getQualifiedClassName(this);
               dispObjArr = className.split("::");
               className = dispObjArr[dispObjArr.length - 1];
               FarmStatsManager.count(NoPopupManager.NOPOPUPS_COUNTER,"suppressed",className);
            }
         }
         return passReq;
      }
      
      public function get canFire() : Boolean
      {
         return true;
      }
      
      public function fire() : void
      {
         throw new Error("BaseIdleTask fire() must be overwritten!");
      }
      
      final public function submit() : void
      {
         IdleTaskQueue.getInstance().addTask(this);
      }
      
      public function set timeAdded(timeMilliseconds:int) : void
      {
         this.m_timeAddedMilliseconds = timeMilliseconds;
      }
   }
}

