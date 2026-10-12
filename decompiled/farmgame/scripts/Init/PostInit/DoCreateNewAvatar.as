package Init.PostInit
{
   import Engine.Init.InitializationAction;
   import MyLife.Events.GlobalEventManager;
   import MyLife.Events.SaveAvatarEvent;
   import flash.events.Event;
   
   public class DoCreateNewAvatar extends InitializationAction
   {
      
      public static const INIT_ID:String = "CreateAvatarIfNew";
      
      public function DoCreateNewAvatar()
      {
         super(INIT_ID);
      }
      
      override public function execute() : void
      {
         GlobalEventManager.getInstance().addEventListener(SaveAvatarEvent.SAVE,this.onAvatarCreated);
         Global.world.displayAvatarCustomizationScreen();
      }
      
      protected function onAvatarCreated(e:SaveAvatarEvent) : void
      {
         GlobalEventManager.getInstance().removeEventListener(SaveAvatarEvent.SAVE,this.onAvatarCreated);
         dispatchEvent(new Event(Event.COMPLETE));
      }
   }
}

