package MyLife.Events
{
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   
   public class GlobalEventManager extends EventDispatcher
   {
      
      protected static var _instance:GlobalEventManager;
      
      public function GlobalEventManager(param1:IEventDispatcher = null)
      {
         super(param1);
      }
      
      public static function getInstance() : GlobalEventManager
      {
         if(!_instance)
         {
            _instance = new GlobalEventManager();
         }
         return _instance;
      }
   }
}

