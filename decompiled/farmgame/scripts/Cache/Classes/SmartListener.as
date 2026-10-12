package Cache.Classes
{
   import flash.events.Event;
   import flash.events.IEventDispatcher;
   
   public class SmartListener
   {
      
      private var m_eventDispatcher:IEventDispatcher;
      
      private var m_listeners:Object;
      
      public function SmartListener(param1:IEventDispatcher)
      {
         super();
         if(param1)
         {
            this.m_eventDispatcher = param1;
            this.m_listeners = new Object();
            return;
         }
         throw new Error("Cannot listen smartly on a null event dispatcher!");
      }
      
      public function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:Boolean = false, param5:Array = null) : void
      {
         var _loc6_:Object = null;
         if(param2 != null)
         {
            _loc6_ = {
               "callback":param2,
               "onetime":param3,
               "removeAll":param4,
               "callbackArgs":param5
            };
            if(this.m_listeners.hasOwnProperty(param1))
            {
               this.m_listeners[param1].push(_loc6_);
            }
            else
            {
               this.m_listeners[param1] = [_loc6_];
               this.m_eventDispatcher.addEventListener(param1,this.onEvent);
            }
         }
      }
      
      private function onEvent(param1:Event) : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:Array = null;
         var _loc4_:Object = null;
         var _loc5_:Array = null;
         if(this.m_listeners.hasOwnProperty(param1.type))
         {
            _loc2_ = false;
            _loc3_ = new Array();
            for each(_loc4_ in this.m_listeners[param1.type])
            {
               _loc5_ = _loc4_.callbackArgs ? _loc4_.callbackArgs : new Array();
               _loc5_.unshift(param1);
               _loc4_.callback.apply(null,_loc5_);
               if(!_loc4_.onetime)
               {
                  _loc3_.push(_loc4_);
               }
               _loc2_ ||= Boolean(_loc4_.removeAll);
            }
            if(_loc2_)
            {
               this.removeAllListeners();
            }
            else if(_loc3_.length == 0)
            {
               delete this.m_listeners[param1.type];
               this.m_eventDispatcher.removeEventListener(param1.type,this.onEvent);
            }
            else
            {
               this.m_listeners[param1.type] = _loc3_;
            }
         }
      }
      
      public function removeAllListeners() : void
      {
         var _loc1_:String = null;
         for(_loc1_ in this.m_listeners)
         {
            this.m_eventDispatcher.removeEventListener(_loc1_,this.onEvent);
         }
         this.m_listeners = new Object();
      }
   }
}

