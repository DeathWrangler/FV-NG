package Classes.Idle
{
   public class WatchAdWhenAvailableIdleTask extends BaseIdleTask
   {
      
      protected var m_placementId:String = "";
      
      protected var MILLISECONDS_IDLE:Number = 500;
      
      public function WatchAdWhenAvailableIdleTask(placementId:String)
      {
         super();
         this.m_placementId = placementId;
         m_displaysPopup = true;
      }
      
      override public function get shouldAdd() : Boolean
      {
         if(!super.isEligibleForPopups())
         {
            return false;
         }
         return true;
      }
      
      override public function get minActionIdleMilliseconds() : Number
      {
         return this.MILLISECONDS_IDLE;
      }
      
      override public function get canFire() : Boolean
      {
         return false;
      }
      
      override public function fire() : void
      {
         Global.watchToEarn.startActivity(this.m_placementId);
      }
   }
}

