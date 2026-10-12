package Engine.Classes.Observer
{
   import flash.utils.Dictionary;
   
   public class ObserverComponent
   {
      
      protected var m_observers:Dictionary;
      
      protected var m_events:Vector.<String>;
      
      public function ObserverComponent(param1:Vector.<String>)
      {
         super();
         this.m_observers = new Dictionary();
         this.m_events = param1;
      }
      
      public function addObserver(param1:IObserver, param2:Vector.<String> = null) : void
      {
         this.observerHelper(param1,param2);
      }
      
      public function removeObserver(param1:IObserver, param2:Vector.<String> = null) : void
      {
         this.observerHelper(param1,param2,false);
      }
      
      protected function observerHelper(param1:IObserver, param2:Vector.<String>, param3:Boolean = true) : void
      {
         var _loc5_:String = null;
         var _loc6_:Vector.<IObserver> = null;
         var _loc7_:int = 0;
         if(!param2)
         {
            param2 = this.m_events;
         }
         var _loc4_:int = 0;
         while(_loc4_ < param2.length)
         {
            _loc5_ = param2[_loc4_];
            if(!(!this.m_observers.hasOwnProperty(_loc5_) && !param3))
            {
               _loc6_ = this.m_observers[_loc5_];
               if(!_loc6_)
               {
                  _loc6_ = this.m_observers[_loc5_] = new Vector.<IObserver>();
               }
               _loc7_ = _loc6_.indexOf(param1);
               if(param3)
               {
                  if(_loc7_ == -1)
                  {
                     _loc6_.push(param1);
                  }
               }
               else if(_loc7_ != -1)
               {
                  _loc6_.splice(_loc7_,1);
               }
            }
            _loc4_++;
         }
      }
      
      public function notifyObservers(param1:String, param2:Object) : void
      {
         var _loc3_:Vector.<IObserver> = null;
         var _loc4_:int = 0;
         var _loc5_:IObserver = null;
         if(this.m_observers.hasOwnProperty(param1))
         {
            _loc3_ = this.m_observers[param1];
            _loc4_ = 0;
            while(_loc4_ < _loc3_.length)
            {
               _loc5_ = _loc3_[_loc4_];
               _loc5_.notify(param1,param2);
               _loc4_++;
            }
         }
      }
   }
}

