package Widgets.Core.Base
{
   import Widgets.Core.Interfaces.IZwEventHandling;
   import Widgets.Core.Managers.ZwEventManager;
   
   public class ZwEventObject extends ZwObject implements IZwEventHandling
   {
      
      protected var m_eventManager:ZwEventManager = new ZwEventManager();
      
      public function ZwEventObject()
      {
         super();
      }
      
      override public function release() : void
      {
         this.m_eventManager.release();
         this.m_eventManager = null;
         super.release();
      }
      
      final public function registerEventListener(eventType:String, callback:Function) : void
      {
         this.m_eventManager.registerEventListener(this,eventType,callback);
      }
      
      final public function unregisterEventListener(eventType:String, callback:Function) : void
      {
         this.m_eventManager.unregisterEventListener(this,eventType,callback);
      }
   }
}

