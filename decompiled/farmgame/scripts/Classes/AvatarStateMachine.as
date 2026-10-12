package Classes
{
   import AvatarMode.AMEquipment;
   import AvatarMode.AMMultiPlotAction;
   import AvatarMode.AvatarState;
   import Engine.Classes.State;
   import Engine.Classes.StateMachine;
   import flash.events.Event;
   
   public class AvatarStateMachine extends StateMachine
   {
      
      public var noPath:Boolean = false;
      
      public function AvatarStateMachine()
      {
         super();
      }
      
      public function getNumActionsPending() : int
      {
         var state:AvatarState = null;
         var result:int = 0;
         for(var stateIdx:int = 0; stateIdx < m_states.length; stateIdx++)
         {
            state = m_states[stateIdx] as AvatarState;
            if(state)
            {
               result += state.getNumActions();
            }
         }
         return result;
      }
      
      override public function removeState(state:State) : void
      {
         super.removeState(state);
         if(0 == m_states.length)
         {
            Global.player.setHasSeenCoinsPopup(false);
         }
      }
      
      override public function removeAllStates() : void
      {
         AMEquipment.clearStaticStates();
         super.removeAllStates();
      }
      
      public function removeMachineStates() : void
      {
         var state:AMMultiPlotAction = null;
         var oldState:State = getState();
         var stateIdx:int = 0;
         while(stateIdx < m_states.length)
         {
            state = m_states[stateIdx] as AMMultiPlotAction;
            if(state != null)
            {
               if(m_states[stateIdx] == oldState)
               {
                  m_states[stateIdx].exit();
               }
               state.removed();
               m_states.splice(stateIdx,1);
            }
            else
            {
               stateIdx++;
            }
         }
         var currentState:State = getState();
         if(Boolean(currentState) && currentState != oldState)
         {
            currentState.reenter();
         }
         dispatchEvent(new Event(Event.CHANGE));
      }
   }
}

