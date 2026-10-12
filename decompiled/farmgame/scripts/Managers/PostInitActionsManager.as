package Managers
{
   import Init.PostInitActionHandlers.AbstractPostInitAction;
   import Init.PostInitActionHandlers.PostInitPopup;
   
   public class PostInitActionsManager
   {
      
      private var m_stack:Array = new Array();
      
      private var m_deferred:Boolean = false;
      
      private var m_dialogSupress:Boolean = false;
      
      public function PostInitActionsManager(supressPopups:Boolean)
      {
         super();
         this.m_dialogSupress = supressPopups;
         this.m_deferred = true;
      }
      
      public function addInitAction(action:AbstractPostInitAction, putOnTopOfStack:Boolean = true) : void
      {
         if(this.m_deferred)
         {
            if(putOnTopOfStack)
            {
               this.m_stack.push(action);
            }
            else
            {
               this.m_stack.unshift(action);
            }
         }
         else
         {
            action.execute();
            action.release();
         }
      }
      
      public function executeStack() : void
      {
         var currentAction:AbstractPostInitAction = null;
         this.m_deferred = false;
         while(this.m_stack.length > 0)
         {
            currentAction = this.getNextAction();
            if(currentAction)
            {
               if(currentAction.hasFinished())
               {
                  currentAction.release();
                  currentAction.removeAllEventListeners();
                  currentAction = null;
               }
               else
               {
                  if(currentAction.executionStart == 0)
                  {
                     currentAction.execute();
                     currentAction.executionStart = GlobalEngine.currentTime;
                  }
                  this.m_stack.unshift(currentAction);
               }
            }
         }
      }
      
      public function get dialogSupress() : Boolean
      {
         return this.m_dialogSupress;
      }
      
      public function set dialogSupress(suppress:Boolean) : void
      {
         this.m_dialogSupress = suppress;
      }
      
      private function getNextAction() : AbstractPostInitAction
      {
         var m_action:AbstractPostInitAction = this.m_stack.pop();
         if(m_action is PostInitPopup && this.m_dialogSupress)
         {
            m_action = null;
         }
         return m_action;
      }
   }
}

