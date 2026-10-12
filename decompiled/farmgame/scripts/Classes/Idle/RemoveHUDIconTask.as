package Classes.Idle
{
   public class RemoveHUDIconTask extends BaseIdleTask
   {
      
      protected var m_iconName:String = "";
      
      protected var m_fireTime:Number = 0;
      
      public function RemoveHUDIconTask(iconName:String, fireTime:int)
      {
         super();
         this.m_iconName = iconName;
         this.m_fireTime = fireTime;
      }
      
      override public function get requireActionQueueIdle() : Boolean
      {
         return false;
      }
      
      override public function get minMouseIdleMilliseconds() : Number
      {
         return 0;
      }
      
      override public function get canFire() : Boolean
      {
         return GlobalEngine.currentTime > this.m_fireTime;
      }
      
      override public function fire() : void
      {
         Global.hud.iconQueue.removeIconByName(this.m_iconName);
      }
   }
}

