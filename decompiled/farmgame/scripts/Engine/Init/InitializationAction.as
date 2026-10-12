package Engine.Init
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class InitializationAction extends EventDispatcher
   {
      
      protected var _id:String;
      
      protected var _dependencies:Array;
      
      public var startTime:int;
      
      public function InitializationAction(param1:String)
      {
         super();
         this.setActionId(param1);
         this._dependencies = new Array();
      }
      
      public function addDependency(param1:String) : void
      {
         if(this._dependencies.indexOf(param1) < 0)
         {
            this._dependencies.push(param1);
         }
      }
      
      public function getDependencies() : Array
      {
         return this._dependencies;
      }
      
      public function setActionId(param1:String) : void
      {
         this._id = param1;
      }
      
      public function getActionId() : String
      {
         return this._id;
      }
      
      public function isReady() : Boolean
      {
         var _loc1_:Boolean = true;
         var _loc2_:int = 0;
         while(_loc2_ < this._dependencies.length)
         {
            if(!InitializationManager.getInstance().hasActionCompleted(this._dependencies[_loc2_]))
            {
               _loc1_ = false;
               break;
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      public function hasCompleted() : Boolean
      {
         return InitializationManager.getInstance().hasActionCompleted(this._id);
      }
      
      public function execute() : void
      {
         dispatchEvent(new Event(Event.COMPLETE));
      }
   }
}

