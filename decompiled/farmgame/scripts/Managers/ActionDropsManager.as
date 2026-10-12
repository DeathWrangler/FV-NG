package Managers
{
   import Engine.Events.TransactionEvent;
   import Engine.Managers.TransactionManager;
   import Events.DynamicObjectEvent;
   import flash.events.EventDispatcher;
   
   public class ActionDropsManager extends EventDispatcher
   {
      
      private static var m_objInstance:ActionDropsManager;
      
      public static const EVENT_ACTION_DROPS_UPDATED:String = "eventActionDropsUpdated";
      
      public static const EVENT_DOOBER_PROGRESS:String = "eventDooberProgress";
      
      private static var m_initialized:Boolean = false;
      
      public function ActionDropsManager(objEnforcer:SingletonEnforcer)
      {
         super();
      }
      
      public static function getInstance() : ActionDropsManager
      {
         if(m_objInstance == null)
         {
            m_objInstance = new ActionDropsManager(new SingletonEnforcer());
            ActionDropsManager.initialize();
         }
         return m_objInstance;
      }
      
      public static function initialize() : void
      {
         if(!m_initialized)
         {
            m_initialized = true;
            TransactionManager.getInstance().addEventListener(TransactionEvent.COMPLETED,onTransactionComplete);
         }
      }
      
      private static function onTransactionComplete(event:TransactionEvent) : void
      {
         if(Boolean(event && event.transaction && event.transaction.rawResult) && Boolean(event.transaction.rawResult.hasOwnProperty("metadata")) && Boolean(event.transaction.rawResult.metadata) && Boolean(event.transaction.rawResult.metadata.hasOwnProperty("ActionDrops")) && Boolean(event.transaction.rawResult.metadata.ActionDrops))
         {
            ActionDropsManager.getInstance().dispatchEvent(new DynamicObjectEvent(ActionDropsManager.EVENT_ACTION_DROPS_UPDATED,event.transaction.rawResult.metadata.ActionDrops));
         }
      }
      
      public function getActionDropXML(actionDropName:String) : XML
      {
         var actionDropXML:XML = null;
         var result:XML = null;
         var xml:XML = Global.farmGameSettingsManager.getXML();
         if(Boolean(xml.actionDrops) && Boolean(xml.actionDrops.children()))
         {
            for each(actionDropXML in xml.actionDrops.actionDrop)
            {
               if(actionDropName == actionDropXML.@name)
               {
                  result = actionDropXML;
                  break;
               }
            }
         }
         return result;
      }
   }
}

class SingletonEnforcer
{
   
   public function SingletonEnforcer()
   {
      super();
   }
}
