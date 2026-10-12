package Widgets.Core.Managers
{
   import Widgets.Core.Base.ZwObject;
   import flash.events.EventDispatcher;
   
   public class ZwEventManager extends ZwObject
   {
      
      protected static const OBJECT:String = "object";
      
      protected static const EVENT:String = "event";
      
      protected static const CALLBACK:String = "callback";
      
      protected var m_registeredEvents:Array = new Array();
      
      public function ZwEventManager()
      {
         super();
      }
      
      override public function release() : void
      {
         this.removeAllEventListeners();
         this.m_registeredEvents = null;
         super.release();
      }
      
      final public function registerEventListener(object:EventDispatcher, eventType:String, callback:Function) : void
      {
         var eventObject:Object = null;
         if(null != callback)
         {
            if(!this.getRegisteredEventListener(object,eventType,callback))
            {
               eventObject = new Object();
               eventObject[OBJECT] = object;
               eventObject[EVENT] = eventType;
               eventObject[CALLBACK] = callback;
               this.m_registeredEvents.push(eventObject);
               object.addEventListener(eventType,callback);
            }
         }
      }
      
      final public function unregisterEventListener(object:EventDispatcher, eventType:String, callback:Function) : void
      {
         var registeredEventListener:Object = null;
         if(null != callback)
         {
            registeredEventListener = this.getRegisteredEventListener(object,eventType,callback);
            if(registeredEventListener)
            {
               this.m_registeredEvents.splice(this.m_registeredEvents.indexOf(registeredEventListener),1);
               registeredEventListener = null;
               object.removeEventListener(eventType,callback);
            }
         }
      }
      
      final public function removeAllEventListeners() : void
      {
         var eventObject:Object = null;
         var object:EventDispatcher = null;
         var event:String = null;
         var callback:Function = null;
         for(var index:uint = 0; index < this.m_registeredEvents.length; index++)
         {
            eventObject = this.m_registeredEvents[index];
            object = eventObject[OBJECT];
            event = eventObject[EVENT];
            callback = eventObject[CALLBACK];
            object.removeEventListener(event,callback);
         }
         this.m_registeredEvents = new Array();
      }
      
      final private function getRegisteredEventListener(object:EventDispatcher, eventType:String, callback:Function) : Object
      {
         var eventObject:Object = null;
         var registeredEventListener:Object = null;
         for(var index:uint = 0; index < this.m_registeredEvents.length; index++)
         {
            eventObject = this.m_registeredEvents[index];
            if(eventObject[OBJECT] == object && eventObject[EVENT] == eventType && eventObject[CALLBACK] == callback)
            {
               registeredEventListener = eventObject;
               break;
            }
         }
         return registeredEventListener;
      }
   }
}

