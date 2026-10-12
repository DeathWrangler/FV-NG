package Init
{
   import Classes.util.FarmGameUtil;
   import Engine.Init.InitializationAction;
   import Engine.Managers.ErrorManager;
   import Managers.FarmStatsManager;
   import Transactions.TInitUser;
   import flash.events.Event;
   import flash.external.ExternalInterface;
   
   public class WorldInit extends InitializationAction
   {
      
      public static const INIT_ID:String = "WorldInit";
      
      public function WorldInit()
      {
         super(INIT_ID);
         addDependency(CraftingSettingsInit.INIT_ID);
         addDependency(UIInit.INIT_ID);
         addDependency(ZapCampaignInit.INIT_ID);
         addDependency(ZLocalizationInit.INIT_ID);
      }
      
      override public function execute() : void
      {
         var base64World:String;
         var currentWorldType:String;
         var serializedWorld:Object = null;
         var worldLoaded:Boolean = false;
         Global.world.addEventListener(Event.COMPLETE,this.onGameWorldInitialized);
         base64World = ExternalInterface.call("getWorld");
         currentWorldType = ExternalInterface.call("getCurrentWorldType");
         if(null != currentWorldType && "" != currentWorldType)
         {
            Global.worldManager.setCurrentWorldType(currentWorldType);
         }
         if(Boolean(!Global.worldManager.isVisiting()) && Boolean(base64World) && base64World.length > 0)
         {
            try
            {
               serializedWorld = FarmGameUtil.uncompressAndDecode(base64World,"WorldInit_execute");
               if(Boolean(serializedWorld != null && serializedWorld != "") && Boolean(serializedWorld.objectsArray) && serializedWorld.objectsArray.length > 0)
               {
                  Global.world.errorOnNullObject = true;
                  Global.world.loadObject(serializedWorld);
                  Global.world.errorOnNullObject = false;
                  TInitUser.worldToLoad(serializedWorld);
                  worldLoaded = true;
               }
               else
               {
                  FarmStatsManager.count("errors","loading","invalid world in flash client");
               }
            }
            catch(err:Error)
            {
               Global.world.errorOnNullObject = false;
               logWorldError(err);
            }
         }
         if(!worldLoaded)
         {
            Global.world.initialize();
            if(!Global.worldManager.isVisiting())
            {
               TInitUser.worldToLoad(null);
            }
         }
      }
      
      private function logWorldError(err:Error) : void
      {
         var message:String = err.message;
         var stackTrace:String = err.getStackTrace();
         var stackTraceComponents:Array = [];
         var lastCall:String = "";
         if(stackTrace != null && stackTrace.length > 1)
         {
            stackTraceComponents = stackTrace.split("at");
            lastCall = stackTraceComponents.length > 1 ? stackTraceComponents[1] : lastCall;
            lastCall = lastCall.length > 45 ? lastCall.substr(0,45) : lastCall;
         }
         FarmStatsManager.count("errors","loading","world threw error in flash client",message,lastCall);
         ErrorManager.addError("Flash world loading error: " + message + "\nLast Call: " + lastCall);
      }
      
      protected function onGameWorldInitialized(e:Event) : void
      {
         Global.world.removeEventListener(Event.COMPLETE,this.onGameWorldInitialized);
         dispatchEvent(new Event(Event.COMPLETE));
      }
   }
}

