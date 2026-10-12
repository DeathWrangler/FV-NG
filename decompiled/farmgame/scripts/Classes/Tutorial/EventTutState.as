package Classes.Tutorial
{
   import Classes.Managers.HUDTutorialManager;
   import Classes.util.ZLocUtils;
   import Display.HUD.HUDWidgets.HUDTutorialWindow;
   import flash.events.Event;
   
   public class EventTutState implements IHUDTutorialState
   {
      
      private var m_completed:Boolean = false;
      
      private var m_ftueConfig:Object;
      
      public function EventTutState(ftueConfig:Object)
      {
         super();
         this.m_ftueConfig = ftueConfig;
      }
      
      public function initialize() : void
      {
         var eventType:String = this.m_ftueConfig.eventType;
         Global.world.addEventListener(eventType,this.updateProgress);
         var message:String = ZLocUtils.t_pk(this.m_ftueConfig.message);
         HUDTutorialManager.instance.hudTutorial.updateText(message,false,HUDTutorialWindow.EXTRA_LARGE_BUBBLE);
      }
      
      private function updateProgress(event:Event) : void
      {
         this.m_completed = true;
         if(this.isCompleted())
         {
            HUDTutorialManager.instance.step();
         }
      }
      
      public function isCompleted() : Boolean
      {
         return this.m_completed;
      }
      
      public function cleanUp() : void
      {
         Global.world.removeEventListener(this.m_ftueConfig.eventType,this.updateProgress);
      }
   }
}

