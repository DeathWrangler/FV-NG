package Classes.util
{
   import cipro.Profiler.GameTagManager;
   import cipro.Profiler.GameTagObject;
   
   public class FarmLoadPhaseMonitor
   {
      
      public static var LOADAPP:LoadPhase = new LoadPhase(FarmModeManager.LOAD_APP_PHASE_NAME);
      
      public static var ITEMS_PARSED:LoadPhase = new LoadPhase(FarmModeManager.ITEMS_PARSED);
      
      public static var INTERACTIVE:LoadPhase = new LoadPhase(FarmModeManager.INTERACTIVE_PHASE_NAME);
      
      public static var USERINIT:LoadPhase = new LoadPhase(FarmModeManager.USER_INIT);
      
      public static var LOAD_COMPLETE:LoadPhase = new LoadPhase(FarmModeManager.LOAD_COMPLETE_PHASE_NAME);
      
      private static const LOAD_CYCLE:Array = [LOADAPP,ITEMS_PARSED,INTERACTIVE,USERINIT,LOAD_COMPLETE];
      
      private static var s_cyclePointer:int = 0;
      
      private static var s_loadPhaseTag:GameTagObject = null;
      
      private static var s_loadPhase:LoadPhase = LOADAPP;
      
      public function FarmLoadPhaseMonitor()
      {
         super();
      }
      
      private static function getLoadPhaseName() : String
      {
         return s_loadPhase != null ? s_loadPhase.name : "unknown";
      }
      
      public static function updateLoadPhase(phase:LoadPhase) : void
      {
         if(s_loadPhaseTag == null)
         {
            s_loadPhaseTag = GameTagManager.registerGameTag("LoadPhase",getLoadPhaseName,GameTagManager.TYPE_STRING,GameTagManager.UPDATE_ASSIGN);
         }
         GlobalEngine.info("Perf","Mark load phase: " + phase.name);
         phase.mark();
         while(s_cyclePointer < LOAD_CYCLE.length && (LOAD_CYCLE[s_cyclePointer] as LoadPhase).isMarked())
         {
            phase = LOAD_CYCLE[s_cyclePointer] as LoadPhase;
            GlobalEngine.info("Perf","Set load phase: " + phase.name);
            s_loadPhase = phase;
            s_loadPhaseTag.refresh();
            try
            {
               ExternalUtil.instance.call("onLoadStep",phase.name);
            }
            catch(e:Error)
            {
            }
            ++s_cyclePointer;
         }
      }
   }
}

