package Cache.Classes
{
   import Engine.Managers.LoadingManager;
   import flash.events.IEventDispatcher;
   
   public class LoadContext
   {
      
      private var m_options:Object;
      
      private var m_priority:int;
      
      private var m_url:String;
      
      private var m_loader:IEventDispatcher;
      
      private var m_listener:SmartListener;
      
      public function LoadContext(param1:Object, param2:String, param3:IEventDispatcher, param4:SmartListener)
      {
         super();
         this.m_options = param1;
         this.m_url = param2;
         this.m_priority = param1.hasOwnProperty("priority") ? int(param1.priority) : LoadingManager.PRIORITY_NORMAL;
         this.m_loader = param3;
         this.m_listener = param4;
      }
      
      public function get options() : Object
      {
         return this.m_options;
      }
      
      public function get priority() : int
      {
         return this.m_priority;
      }
      
      public function get url() : String
      {
         return this.m_url;
      }
      
      public function get loader() : IEventDispatcher
      {
         return this.m_loader;
      }
      
      public function get listener() : SmartListener
      {
         return this.m_listener;
      }
   }
}

