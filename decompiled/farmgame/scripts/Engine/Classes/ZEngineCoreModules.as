package Engine.Classes
{
   import cipro.Profiler.GameTagManager;
   import cipro.Profiler.GameTagObject;
   import cipro.Profiler.RuntimeModule;
   import cipro.Profiler.RuntimeProfiler;
   import flash.system.System;
   import flash.utils.getTimer;
   
   public class ZEngineCoreModules
   {
      
      public static var AMFConnectionOnResult:RuntimeModule = null;
      
      public static var BaseGameOnEngineEnterFrame:RuntimeModule = null;
      
      public static var BaseGameOnAddedToStage:RuntimeModule = null;
      
      public static var InitializationManagerDoActions:RuntimeModule = null;
      
      public static var InputManagerMouseMisc:RuntimeModule = null;
      
      public static var InputManagerMouseMove:RuntimeModule = null;
      
      public static var LoadingManagerLoadFromUrl:RuntimeModule = null;
      
      public static var LoadingManagerPumpQueue:RuntimeModule = null;
      
      public static var ResourceLoaderOnComplete:RuntimeModule = null;
      
      public static var SmartListenerOnEvent:RuntimeModule = null;
      
      public static var TransactionManagerAddTransaction:RuntimeModule = null;
      
      public static var TransactionManagerOnAmfBatchSend:RuntimeModule = null;
      
      public static var TransactionManagerOnAmfBatchComplete:RuntimeModule = null;
      
      public static var TimerUtilCallLater:RuntimeModule = null;
      
      public static var URLResourceLoaderOnInternalComplete:RuntimeModule = null;
      
      public static var ViewportOnEnterFrame:RuntimeModule = null;
      
      public static var totalMemoryTag:GameTagObject = null;
      
      public static var totalMemoryBytesTag:GameTagObject = null;
      
      public static var totalSecondsTag:GameTagObject = null;
      
      public static var totalMilliSecondsTag:GameTagObject = null;
      
      public function ZEngineCoreModules()
      {
         super();
      }
      
      public static function initialize() : void
      {
         AMFConnectionOnResult = RuntimeProfiler.registerModule("AMFConnection.onResult");
         BaseGameOnEngineEnterFrame = RuntimeProfiler.registerModule("BaseGame.OnEngineEnterFrame");
         BaseGameOnAddedToStage = RuntimeProfiler.registerModule("BaseGame.onAddedToStage");
         InitializationManagerDoActions = RuntimeProfiler.registerModule("InitializationManager.doActions");
         InputManagerMouseMisc = RuntimeProfiler.registerModule("InputManager.MouseMisc");
         InputManagerMouseMove = RuntimeProfiler.registerModule("InputManager.MouseMove");
         LoadingManagerLoadFromUrl = RuntimeProfiler.registerModule("LoadingManager.loadFromUrl");
         LoadingManagerPumpQueue = RuntimeProfiler.registerModule("LoadingManager.pumpQueue");
         ResourceLoaderOnComplete = RuntimeProfiler.registerModule("ResourceLoader.onComplete");
         SmartListenerOnEvent = RuntimeProfiler.registerModule("SmartListener.onEvent");
         TransactionManagerAddTransaction = RuntimeProfiler.registerModule("TransactionManager.addTransaction");
         TransactionManagerOnAmfBatchSend = RuntimeProfiler.registerModule("TransactionManager.onAmfBatchSend");
         TransactionManagerOnAmfBatchComplete = RuntimeProfiler.registerModule("TransactionManager.onAmfBatchComplete");
         TimerUtilCallLater = RuntimeProfiler.registerModule("TimerUtil.callLater");
         URLResourceLoaderOnInternalComplete = RuntimeProfiler.registerModule("URLResourceLoader.onInternalComplete");
         ViewportOnEnterFrame = RuntimeProfiler.registerModule("Viewport.onEnterFrame");
         totalMemoryTag = GameTagManager.registerGameTag("TotalMemory",getMemory,GameTagManager.TYPE_NUMBER,GameTagManager.UPDATE_POLLING);
         totalMemoryBytesTag = GameTagManager.registerGameTag("TotalMemoryBytes",getMemoryBytes,GameTagManager.TYPE_NUMBER,GameTagManager.UPDATE_POLLING);
         totalSecondsTag = GameTagManager.registerGameTag("Seconds",getSeconds,GameTagManager.TYPE_COUNT_NUMBER,GameTagManager.UPDATE_POLLING);
         totalMilliSecondsTag = GameTagManager.registerGameTag("MilliSeconds",getTimer,GameTagManager.TYPE_COUNT_NUMBER,GameTagManager.UPDATE_POLLING);
      }
      
      private static function getMemoryBytes() : Number
      {
         return System.totalMemory;
      }
      
      private static function getMemory() : Number
      {
         return System.totalMemory / 1048576;
      }
      
      private static function getSeconds() : Number
      {
         return getTimer() / 1000;
      }
   }
}

