package Widgets.Core.Base
{
   import Widgets.Core.Interfaces.IZwEventHandling;
   import Widgets.Core.Managers.ZwEventManager;
   import flash.display.DisplayObject;
   import flash.events.EventDispatcher;
   
   public class ZwEventWidget extends ZwBaseWidget implements IZwEventHandling
   {
      
      public static var ICON_PREVIEW_EVENT_LISTENER:String = "iconLoaded";
      
      protected var m_eventManager:ZwEventManager = new ZwEventManager();
      
      public function ZwEventWidget(element:DisplayObject)
      {
         super(element);
      }
      
      override public function release() : void
      {
         if(this.m_eventManager)
         {
            this.m_eventManager.release();
         }
         this.m_eventManager = null;
         super.release();
      }
      
      final public function registerEventListener(eventType:String, callback:Function) : void
      {
         if(this.m_eventManager)
         {
            this.m_eventManager.registerEventListener(m_element as EventDispatcher,eventType,callback);
         }
      }
      
      final public function unregisterEventListener(eventType:String, callback:Function) : void
      {
         if(this.m_eventManager)
         {
            this.m_eventManager.unregisterEventListener(m_element as EventDispatcher,eventType,callback);
         }
      }
   }
}

