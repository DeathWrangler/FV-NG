package Managers
{
   import Classes.util.ExternalUtil;
   
   public class ExternalInterfaceFeatureManager
   {
      
      private static var s_instance:ExternalInterfaceFeatureManager;
      
      public static const ACTION_POP_ZMC:String = "popZMC";
      
      public function ExternalInterfaceFeatureManager(key:SingletonEnforcer)
      {
         super();
         GlobalEngine.assert(key != null,"[ExternamInterfaceFeatureManager] :: Use ExternamInterfaceFeatureManager.getInstance");
      }
      
      public static function getInstance() : ExternalInterfaceFeatureManager
      {
         if(!s_instance)
         {
            s_instance = new ExternalInterfaceFeatureManager(new SingletonEnforcer());
         }
         return s_instance;
      }
      
      public function wrapCall(actionName:String) : Function
      {
         return function():*
         {
            return call(actionName);
         };
      }
      
      public function call(actionName:String) : *
      {
         var result:* = null;
         switch(actionName)
         {
            case ACTION_POP_ZMC:
               ExternalUtil.instance.call(ACTION_POP_ZMC);
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
