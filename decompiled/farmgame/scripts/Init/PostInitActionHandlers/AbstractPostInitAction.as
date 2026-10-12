package Init.PostInitActionHandlers
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   
   public class AbstractPostInitAction implements IEventDispatcher
   {
      
      protected var m_callback:Function = null;
      
      protected var m_executionStart:Number = 0;
      
      protected var m_isFinished:Boolean = false;
      
      private var m_dispatcher:EventDispatcher = null;
      
      private var m_activeListeners:Array = new Array();
      
      public function AbstractPostInitAction(callback:Function = null)
      {
         super();
         this.m_callback = callback;
         this.m_dispatcher = new EventDispatcher(this);
      }
      
      public function get executionStart() : Number
      {
         return this.m_executionStart;
      }
      
      public function set executionStart(time:Number) : void
      {
         this.m_executionStart = time;
      }
      
      public function execute() : void
      {
         throw new Error("Must override execute when extending AbstractPostInitAction");
      }
      
      public function hasFinished() : Boolean
      {
         return this.m_isFinished;
      }
      
      public function release() : void
      {
         this.m_callback = null;
      }
      
      public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false) : void
      {
         this.m_dispatcher.addEventListener(type,listener,useCapture,priority);
         this.m_activeListeners.push(new StoredEventListener(type,listener,useCapture));
      }
      
      public function dispatchEvent(evt:Event) : Boolean
      {
         return this.m_dispatcher.dispatchEvent(evt);
      }
      
      public function hasEventListener(type:String) : Boolean
      {
         return this.m_dispatcher.hasEventListener(type);
      }
      
      public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false) : void
      {
         this.m_dispatcher.removeEventListener(type,listener,useCapture);
         this.m_activeListeners = this.m_activeListeners.filter(function(elem:*, idx:int, arr:Array):Boolean
         {
            return elem.m_type != type || elem.m_listener != listener || elem.m_useCapture != useCapture;
         });
      }
      
      public function willTrigger(type:String) : Boolean
      {
         return this.m_dispatcher.willTrigger(type);
      }
      
      public function removeAllEventListeners() : void
      {
         var curListener:StoredEventListener = null;
         while(this.m_activeListeners.length > 0)
         {
            curListener = this.m_activeListeners.pop();
            this.m_dispatcher.removeEventListener(curListener.m_type,curListener.m_listener,curListener.m_useCapture);
         }
      }
   }
}

class StoredEventListener
{
   
   public var m_type:String = null;
   
   public var m_listener:Function = null;
   
   public var m_useCapture:Boolean = false;
   
   public function StoredEventListener(type:String, listener:Function, useCapture:Boolean = false)
   {
      super();
      this.m_type = type;
      this.m_listener = listener;
      this.m_useCapture = useCapture;
   }
}
