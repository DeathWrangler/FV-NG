package Init
{
   import Engine.Init.InitializationAction;
   import flash.events.Event;
   
   public class ActionQueue
   {
      
      protected var m_theQ:Array;
      
      public function ActionQueue()
      {
         super();
         this.m_theQ = new Array();
      }
      
      public function add(action:InitializationAction) : void
      {
         this.m_theQ.push(action);
      }
      
      public function execute() : void
      {
         this.doNextAction();
      }
      
      public function cancel() : void
      {
         this.m_theQ = new Array();
      }
      
      protected function onActionCompleted(e:Event = null) : void
      {
         this.doNextAction();
      }
      
      protected function doNextAction() : void
      {
         var action:InitializationAction = null;
         if(this.m_theQ.length > 0)
         {
            action = this.m_theQ.shift();
            action.addEventListener(Event.COMPLETE,this.onActionCompleted);
            action.execute();
         }
      }
   }
}

