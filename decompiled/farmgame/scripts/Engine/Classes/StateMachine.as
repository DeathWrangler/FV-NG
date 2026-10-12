package Engine.Classes
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.getQualifiedClassName;
   
   public class StateMachine extends EventDispatcher
   {
      
      protected var m_states:Array = [];
      
      public function StateMachine()
      {
         super();
         this.m_states = [];
      }
      
      public function addState(param1:State, param2:Boolean = false) : Boolean
      {
         var _loc6_:Array = null;
         var _loc3_:State = this.getState();
         var _loc4_:int = State.NORMAL_INTERRUPT;
         var _loc5_:Boolean = false;
         if(param2)
         {
            _loc6_ = [param1];
            this.m_states = _loc6_.concat(this.m_states);
            param1.added();
            if(_loc3_ == null)
            {
               param1.enter();
            }
            _loc5_ = true;
         }
         else
         {
            if(_loc3_)
            {
               _loc4_ = _loc3_.getInterrupt();
               if(_loc4_ != State.NO_INTERRUPT)
               {
                  if(_loc4_ == State.FULL_INTERRUPT)
                  {
                     this.removeState(_loc3_);
                  }
                  else
                  {
                     _loc3_.exit();
                  }
                  _loc5_ = true;
               }
            }
            if(_loc4_ != State.NO_INTERRUPT)
            {
               this.m_states.push(param1);
               param1.added();
               param1.enter();
               _loc5_ = true;
            }
         }
         if(_loc5_)
         {
            dispatchEvent(new Event(Event.CHANGE));
         }
         if(param1)
         {
            GlobalEngine.log("StateMachine","Add: " + getQualifiedClassName(param1) + " (states: " + this.m_states.length + ")");
         }
         return _loc5_;
      }
      
      public function removeState(param1:State) : void
      {
         var _loc4_:State = null;
         var _loc2_:State = this.getState();
         var _loc3_:int = 0;
         while(_loc3_ < this.m_states.length)
         {
            if(this.m_states[_loc3_] == param1)
            {
               if(this.m_states[_loc3_] == _loc2_)
               {
                  this.m_states[_loc3_].exit();
               }
               param1.removed();
               this.m_states.splice(_loc3_,1);
               _loc4_ = this.getState();
               if((Boolean(_loc4_)) && _loc4_ != _loc2_)
               {
                  _loc4_.reenter();
               }
               dispatchEvent(new Event(Event.CHANGE));
               break;
            }
            _loc3_++;
         }
         if(param1)
         {
            GlobalEngine.log("StateMachine","Remove: " + getQualifiedClassName(param1) + " (states: " + this.m_states.length + ")");
         }
      }
      
      public function removeAllStates() : void
      {
         var _loc3_:State = null;
         var _loc1_:State = this.getState();
         if(_loc1_)
         {
            _loc1_.exit();
            dispatchEvent(new Event(Event.CHANGE));
         }
         var _loc2_:int = 0;
         while(_loc2_ < this.m_states.length)
         {
            _loc3_ = this.m_states[_loc2_] as State;
            _loc3_.removed();
            _loc2_++;
         }
         this.m_states = [];
         GlobalEngine.log("StateMachine","Remove all states");
      }
      
      public function getState() : State
      {
         var _loc1_:State = null;
         if(this.m_states.length)
         {
            _loc1_ = this.m_states[this.m_states.length - 1];
         }
         return _loc1_;
      }
      
      public function getStates() : Array
      {
         return this.m_states;
      }
      
      public function popState() : void
      {
         if(this.m_states.length)
         {
            this.removeState(this.m_states[this.m_states.length - 1] as State);
         }
      }
      
      public function update(param1:Number) : void
      {
         var _loc2_:State = this.getState();
         if(_loc2_)
         {
            _loc2_.update(param1);
         }
      }
   }
}

