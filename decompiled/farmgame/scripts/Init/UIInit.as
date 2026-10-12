package Init
{
   import Display.UI;
   import Engine.Init.InitializationAction;
   import Managers.PopupManager;
   import flash.events.Event;
   
   public class UIInit extends InitializationAction
   {
      
      public static const INIT_ID:String = "UIInit";
      
      public function UIInit()
      {
         super(INIT_ID);
         addDependency(ZGameSettingsInit.INIT_ID);
         addDependency(AvatarSettingsInit.INIT_ID);
         addDependency(GlobalsInit.INIT_ID);
      }
      
      override public function execute() : void
      {
         var ui:UI = new UI();
         Global.popupManager = new PopupManager();
         dispatchEvent(new Event(Event.COMPLETE));
      }
   }
}

