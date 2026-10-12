package Classes
{
   import Classes.util.FarmGameUtil;
   import Managers.DefconManager;
   import cipro.Profiler.GameTagManager;
   import cipro.Profiler.GameTagObject;
   import cipro.Profiler.RuntimeModule;
   import cipro.Profiler.RuntimeProfiler;
   
   public class FarmGameModules
   {
      
      public static var FarmGameConstructor:RuntimeModule = null;
      
      public static var FarmGameOnInit:RuntimeModule = null;
      
      public static var FarmGameInitComplete:RuntimeModule = null;
      
      public static var FarmGameOnEnterFrame:RuntimeModule = null;
      
      public static var visibleObjectsTag:GameTagObject = null;
      
      public static var animatedObjectsTag:GameTagObject = null;
      
      public static var numObjectsTag:GameTagObject = null;
      
      public static var gridSizeTag:GameTagObject = null;
      
      public static var defconTag:GameTagObject = null;
      
      public static var flashVersionTag:GameTagObject = null;
      
      public static var browserTag:GameTagObject = null;
      
      public function FarmGameModules()
      {
         super();
      }
      
      public static function initialize() : void
      {
         FarmGameConstructor = RuntimeProfiler.registerModule("FarmGame.constructor");
         FarmGameOnInit = RuntimeProfiler.registerModule("FarmGame.onInit");
         FarmGameInitComplete = RuntimeProfiler.registerModule("FarmGame.onAllInitComplete");
         FarmGameOnEnterFrame = RuntimeProfiler.registerModule("FarmGame.onEnterFrame");
         visibleObjectsTag = GameTagManager.registerGameTag("VisibleObjects",function():int
         {
            return Global.world ? Global.world.getNumVisibleObjects() : 0;
         },GameTagManager.TYPE_INTEGER,GameTagManager.UPDATE_POLLING);
         animatedObjectsTag = GameTagManager.registerGameTag("AnimatedObjects",function():int
         {
            return Global.world ? Global.world.numPlayingMapResources : 0;
         },GameTagManager.TYPE_INTEGER,GameTagManager.UPDATE_POLLING);
         numObjectsTag = GameTagManager.registerGameTag("NumObjects",function():int
         {
            return Global.world ? Global.world.getNumObjects() : 0;
         },GameTagManager.TYPE_INTEGER,GameTagManager.UPDATE_POLLING);
         gridSizeTag = GameTagManager.registerGameTag("GridSize",function():int
         {
            return Global.world ? Global.world.getGridHeight() : 0;
         },GameTagManager.TYPE_INTEGER,GameTagManager.UPDATE_POLLING);
         defconTag = GameTagManager.registerGameTag("Defcon",function():int
         {
            return DefconManager ? int(DefconManager.defconLevel + 1) : 0;
         },GameTagManager.TYPE_INTEGER,GameTagManager.UPDATE_POLLING);
         flashVersionTag = GameTagManager.registerGameTag("FlashVersion",function():String
         {
            return Global.farmGame ? Global.farmGame.getFlashVersion() : "none";
         },GameTagManager.TYPE_STRING,GameTagManager.UPDATE_ASSIGN);
         browserTag = GameTagManager.registerGameTag("Browser",function():String
         {
            return FarmGameUtil.getBrowserVersion();
         },GameTagManager.TYPE_STRING,GameTagManager.UPDATE_ASSIGN);
      }
   }
}

