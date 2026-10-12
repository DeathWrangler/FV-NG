package Classes.Idle
{
   import Display.FarmDynamicDialog;
   import Managers.FreezeManager;
   
   public class FarmDynamicDialogIdleTask extends BaseIdleTask
   {
      
      protected var m_minTimeUntilDisplay:Number = 0;
      
      private var m_timeCreated:Number = 0;
      
      private var m_dialogToDisplay:FarmDynamicDialog = null;
      
      private var m_showCallback:Function = null;
      
      public function FarmDynamicDialogIdleTask(dialog:FarmDynamicDialog, minTimeUntilDisplay:Number = 0, onShowCallback:Function = null)
      {
         this.m_dialogToDisplay = dialog;
         this.m_minTimeUntilDisplay = minTimeUntilDisplay;
         this.m_showCallback = onShowCallback;
         super();
      }
      
      override public function fire() : void
      {
         if(this.m_dialogToDisplay != null)
         {
            this.m_dialogToDisplay.show(true);
         }
         if(this.m_showCallback != null)
         {
            this.m_showCallback();
         }
      }
      
      override public function get canFire() : Boolean
      {
         return GlobalEngine.currentTime > this.m_timeAddedMilliseconds + this.m_minTimeUntilDisplay && !FreezeManager.isAnythingFrozen();
      }
   }
}

