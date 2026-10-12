package Classes.Idle
{
   import Classes.Quest.PrerequisiteUtility;
   import Managers.ToasterManager;
   import Widgets.Windows.ToasterWindow;
   
   public class GenericToasterIdleTask extends BaseIdleTask
   {
      
      protected var m_toasterWindow:ToasterWindow = null;
      
      protected var m_minTimeUntilDisplay:Number = 5000;
      
      protected var m_namedPrereq:String = null;
      
      public function GenericToasterIdleTask(toaster:ToasterWindow, minTimeUntilDisplay:Number = 5000, namedPrereq:String = null)
      {
         super();
         this.m_toasterWindow = toaster;
         this.m_minTimeUntilDisplay = minTimeUntilDisplay;
         this.m_namedPrereq = namedPrereq;
         m_displaysPopup = true;
      }
      
      override public function get shouldAdd() : Boolean
      {
         var prereq:Object = null;
         if(!super.isEligibleForPopups())
         {
            return false;
         }
         var result:Boolean = false;
         if(this.m_toasterWindow != null)
         {
            if(this.m_namedPrereq != null && this.m_namedPrereq != "")
            {
               prereq = Global.farmGameSettingsManager.getPrereqByName(this.m_namedPrereq);
               if(PrerequisiteUtility.isPrerequisiteMet(prereq))
               {
                  result = true;
               }
            }
            else
            {
               result = true;
            }
         }
         return result;
      }
      
      override public function get canFire() : Boolean
      {
         return GlobalEngine.currentTime > this.m_timeAddedMilliseconds + this.m_minTimeUntilDisplay;
      }
      
      override public function fire() : void
      {
         ToasterManager.getInstance().add(this.m_toasterWindow);
      }
   }
}

