package cipro.Profiler
{
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.IEventDispatcher;
   import flash.system.Capabilities;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   
   public class RuntimeProfiler
   {
      
      private static var s_FrameFilterFunctions:Vector.<Function>;
      
      private static var s_MetaData:Object;
      
      private static var s_Modules:Vector.<RuntimeModule>;
      
      private static var s_frameStartPos:int;
      
      private static var s_Log:Vector.<FrameEntryInfo>;
      
      public static var initialLogSize:int = 256 * 1024;
      
      public static var maxLogEntries:int = 256 * 1024;
      
      public static var maxCapturedFrames:int = 1000;
      
      public static var calibrationIterations:int = 1000;
      
      private static var s_Initialized:Boolean = false;
      
      private static var s_Enabled:Boolean = false;
      
      private static var s_LogEnabled:Boolean = false;
      
      private static var s_stage:Stage = null;
      
      private static var s_Frame:int = 0;
      
      private static var s_CapturedFrames:int = 0;
      
      private static var s_actionscript:RuntimeModule = null;
      
      private static var s_preinit:RuntimeModule = null;
      
      private static var s_TriggerFrameDelay:int = 0;
      
      private static var s_TriggerFunction:Function = null;
      
      private static var s_TriggerName:String = null;
      
      private static var s_TriggerSection:Dictionary = new Dictionary();
      
      private static var s_TriggerStart:int = 0;
      
      private static var s_Overhead:Number = 0;
      
      private static var s_FrameProcessModule:RuntimeModule = null;
      
      private static var s_FrameModule:RuntimeModule = null;
      
      private static var s_addModuleCallbacks:Vector.<Function> = new Vector.<Function>();
      
      private static var s_listeners:Dictionary = new Dictionary(true);
      
      private static var s_LogInitPos:int = 0;
      
      private static var s_LogPos:int = 0;
      
      private static var s_totalFramesTag:GameTagObject = null;
      
      public function RuntimeProfiler()
      {
         super();
      }
      
      public static function registerModule(param1:String, param2:String = "Actionscript") : RuntimeModule
      {
         var _loc4_:Function = null;
         if(!s_Modules)
         {
            s_Modules = new Vector.<RuntimeModule>();
         }
         var _loc3_:RuntimeModule = new RuntimeModule(param1,param2);
         s_Modules.push(_loc3_);
         for each(_loc4_ in s_addModuleCallbacks)
         {
            _loc4_(param1);
         }
         return _loc3_;
      }
      
      public static function registerAddModuleCallback(param1:Function) : void
      {
         s_addModuleCallbacks.push(param1);
      }
      
      public static function enable(param1:Boolean = false) : void
      {
         if(!s_Enabled)
         {
            s_Enabled = true;
            initialize(param1);
            s_totalFramesTag.refresh();
            if(s_stage != null)
            {
               s_stage.addEventListener(Event.ENTER_FRAME,onEnterFrame,false,int.MAX_VALUE);
            }
         }
      }
      
      public static function enableLogging() : void
      {
         s_LogEnabled = true;
      }
      
      public static function enableFrameCapture(param1:Stage) : void
      {
         if(s_stage == null)
         {
            s_stage = param1;
            if(s_Enabled)
            {
               s_stage.addEventListener(Event.ENTER_FRAME,onEnterFrame,false,int.MAX_VALUE);
            }
         }
      }
      
      public static function disable() : void
      {
         s_Enabled = false;
      }
      
      public static function isEnabled() : Boolean
      {
         return s_Enabled;
      }
      
      public static function getTimer() : int
      {
         return getTimer();
      }
      
      public static function log_stats(param1:String, param2:Array) : void
      {
         if(!s_Enabled || !s_LogEnabled)
         {
            return;
         }
         log("Stat:" + param1 + " " + param2);
      }
      
      public static function log(param1:String) : void
      {
         if(!s_Enabled || !s_LogEnabled)
         {
            return;
         }
         if(s_LogPos == s_LogInitPos)
         {
            s_Log[s_LogPos] = new FrameEntryInfo();
            ++s_LogInitPos;
         }
         s_Log[s_LogPos].flag = FrameEntryInfo.ENTRY_TYPE_LOG;
         s_Log[s_LogPos].name = param1;
         s_Log[s_LogPos].extraName = null;
         s_Log[s_LogPos].module = null;
         s_Log[s_LogPos].time = getTimer();
         ++s_LogPos;
      }
      
      public static function FrameEntryFixup(param1:int, param2:int, param3:int, param4:Vector.<FrameEntryInfo>) : void
      {
         var _loc5_:* = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc10_:FrameEntryInfo = null;
         var _loc11_:FrameEntryInfo = null;
         var _loc8_:Vector.<int> = GameTagManager.CurrentGameModes();
         if(param1 > RuntimeModule.BUCKET3_MINIMUM)
         {
            _loc7_ = 2;
         }
         else if(param1 > RuntimeModule.BUCKET2_MINIMUM)
         {
            _loc7_ = 1;
         }
         else
         {
            _loc7_ = 0;
         }
         _loc5_ = param2;
         while(_loc5_ <= param3)
         {
            _loc10_ = param4[_loc5_];
            if(_loc10_.flag == FrameEntryInfo.ENTRY_TYPE_LEAVE)
            {
               _loc11_ = param4[_loc10_.enterCookie];
               _loc11_.totaltime = _loc10_.time - _loc11_.time;
               if(_loc11_.module.frameNum != s_Frame)
               {
                  _loc11_.module.frameNum = s_Frame;
                  for each(_loc6_ in _loc8_)
                  {
                     ++_loc11_.module.bucketLeaves[_loc7_][_loc6_];
                     _loc11_.module.bucketTimes[_loc7_][_loc6_] += _loc11_.totaltime;
                     ++_loc11_.module.bucketFrames[_loc7_][_loc6_];
                  }
               }
               else
               {
                  for each(_loc6_ in _loc8_)
                  {
                     ++_loc11_.module.bucketLeaves[_loc7_][_loc6_];
                     _loc11_.module.bucketTimes[_loc7_][_loc6_] += _loc11_.totaltime;
                  }
               }
            }
            _loc5_++;
         }
         _loc5_ = int(param3 - 1);
         var _loc9_:int = 0;
         while(_loc5_ > param2)
         {
            if(param4[_loc5_].flag == FrameEntryInfo.ENTRY_TYPE_LEAVE)
            {
               _loc5_ = param4[_loc5_].enterCookie;
               _loc9_ += param4[_loc5_].totaltime;
            }
            _loc5_--;
         }
         for each(_loc6_ in _loc8_)
         {
            ++s_actionscript.bucketLeaves[_loc7_][_loc6_];
            s_actionscript.bucketTimes[_loc7_][_loc6_] += _loc9_;
            ++s_actionscript.bucketFrames[_loc7_][_loc6_];
         }
      }
      
      public static function addEventListener(param1:RuntimeModule, param2:IEventDispatcher, param3:String, param4:Function, param5:Boolean = false, param6:int = 0, param7:Boolean = false) : void
      {
         var _loc8_:InstrumentedListener = new InstrumentedListener(param1,param4);
         var _loc9_:Dictionary = s_listeners[param2];
         if(!_loc9_)
         {
            _loc9_ = new Dictionary(false);
            s_listeners[param2] = _loc9_;
         }
         var _loc10_:Dictionary = _loc9_[param3];
         if(!_loc10_)
         {
            _loc10_ = new Dictionary(true);
            _loc9_[param3] = _loc10_;
         }
         if(_loc10_[param4])
         {
            throw new Error("Listener already added");
         }
         _loc10_[param4] = _loc8_;
         param2.addEventListener(param3,_loc8_.onEvent,param5,param6,param7);
      }
      
      public static function removeEventListener(param1:IEventDispatcher, param2:String, param3:Function, param4:Boolean = false) : void
      {
         var _loc6_:Dictionary = null;
         var _loc7_:InstrumentedListener = null;
         var _loc5_:Dictionary = s_listeners[param1];
         if(_loc5_)
         {
            _loc6_ = _loc5_[param2];
            if(_loc6_)
            {
               _loc7_ = _loc6_[param3];
               if(_loc7_ != null)
               {
                  param1.removeEventListener(param2,_loc7_.onEvent,param4);
                  delete _loc6_[param3];
               }
            }
         }
      }
      
      public static function enter(param1:RuntimeModule, param2:String = null) : int
      {
         if(!s_Enabled)
         {
            return -1;
         }
         if(!param1)
         {
            return -1;
         }
         if(s_LogPos == s_LogInitPos)
         {
            s_Log[s_LogPos] = new FrameEntryInfo();
            ++s_LogInitPos;
         }
         s_Log[s_LogPos].flag = FrameEntryInfo.ENTRY_TYPE_ENTER;
         s_Log[s_LogPos].extraName = param2;
         s_Log[s_LogPos].module = param1;
         s_Log[s_LogPos].time = getTimer();
         s_Log[s_LogPos].totaltime = -1;
         ++s_LogPos;
         return s_LogPos - 1;
      }
      
      public static function leave(param1:int) : void
      {
         if(!s_Enabled || param1 == -1)
         {
            return;
         }
         if(s_LogPos == s_LogInitPos)
         {
            s_Log[s_LogPos] = new FrameEntryInfo();
            ++s_LogInitPos;
         }
         s_Log[s_LogPos].enterCookie = param1;
         s_Log[s_LogPos].time = getTimer();
         s_Log[s_LogPos].flag = FrameEntryInfo.ENTRY_TYPE_LEAVE;
         ++s_LogPos;
      }
      
      public static function get frameName() : String
      {
         return "frame#" + s_Frame;
      }
      
      public static function nextFrame() : void
      {
         var _loc4_:int = 0;
         var _loc5_:FrameEntryInfo = null;
         if(!s_Enabled)
         {
            return;
         }
         initialize(false);
         leave(s_frameStartPos);
         ++s_CapturedFrames;
         var _loc1_:int = s_frameStartPos;
         var _loc2_:int = s_LogPos - 1;
         ++s_Frame;
         s_totalFramesTag.refresh();
         s_frameStartPos = enter(s_FrameModule,frameName);
         var _loc3_:int = enter(s_FrameProcessModule);
         checkForFrameFilter(_loc1_,_loc2_);
         checkForProfileTriggers(_loc1_,_loc2_);
         GameTagManager.refreshGameMode();
         leave(_loc3_);
         if(s_LogPos > maxLogEntries || s_CapturedFrames >= maxCapturedFrames)
         {
            _loc4_ = s_frameStartPos;
            while(_loc4_ < s_LogPos)
            {
               _loc5_ = s_Log[_loc4_];
               if(s_Log[_loc4_].flag == FrameEntryInfo.ENTRY_TYPE_LEAVE)
               {
                  s_Log[_loc4_].enterCookie -= s_frameStartPos;
               }
               s_Log[_loc4_] = s_Log[_loc4_ - s_frameStartPos];
               s_Log[_loc4_ - s_frameStartPos] = _loc5_;
               _loc4_++;
            }
            s_LogPos -= s_frameStartPos;
            s_frameStartPos = 0;
            s_TriggerStart = 0;
            s_CapturedFrames = 0;
         }
      }
      
      private static function onEnterFrame(param1:Event) : void
      {
         nextFrame();
      }
      
      public static function triggerProfile(param1:String) : void
      {
         var _loc2_:Object = s_TriggerSection[param1];
         if(s_TriggerFrameDelay == 0)
         {
            s_TriggerFrameDelay = _loc2_.frameDelay + 1;
            s_TriggerFunction = _loc2_.frameCallback;
            s_TriggerName = param1;
            if(_loc2_.deleteOnTrigger)
            {
               delete s_TriggerSection[param1];
            }
         }
      }
      
      public static function setMetaData(param1:Object) : void
      {
         if(!s_Enabled)
         {
            return;
         }
         s_MetaData = param1;
      }
      
      public static function triggerOnSection(param1:String, param2:int, param3:Boolean, param4:Function) : void
      {
         var _loc5_:Object = null;
         if(param2 >= 0)
         {
            _loc5_ = new Object();
            _loc5_.frameDelay = param2;
            _loc5_.frameCallback = param4;
            _loc5_.deleteOnTrigger = param3;
            s_TriggerSection[param1] = _loc5_;
         }
         else
         {
            delete s_TriggerSection[param1];
         }
      }
      
      public static function triggerOnSectionTimeout(param1:String, param2:int, param3:Boolean, param4:Function) : void
      {
         var _loc5_:Object = null;
         if(param2 > 0)
         {
            _loc5_ = new Object();
            _loc5_.frameTimeout = param2;
            _loc5_.frameCallback = param4;
            _loc5_.deleteOnTrigger = param3;
            s_TriggerSection[param1] = _loc5_;
         }
         else
         {
            delete s_TriggerSection[param1];
         }
      }
      
      public static function addFrameFilter(param1:Function) : void
      {
         if(!s_FrameFilterFunctions)
         {
            s_FrameFilterFunctions = new Vector.<Function>();
         }
         s_FrameFilterFunctions.push(param1);
      }
      
      public static function getAllStandardSections() : Object
      {
         var _loc1_:Array = [];
         var _loc2_:int = 0;
         while(_loc2_ < s_Modules.length)
         {
            _loc1_.push(s_Modules[_loc2_].name);
            _loc2_++;
         }
         return _loc1_;
      }
      
      public static function getLog() : Object
      {
         var _loc1_:int = getTimer();
         var _loc2_:Array = [];
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         while(_loc4_ < s_LogPos)
         {
            switch(s_Log[_loc4_].flag)
            {
               case FrameEntryInfo.ENTRY_TYPE_ENTER:
                  _loc2_.push([s_Log[_loc4_].flag,s_Log[_loc4_].time,s_Log[_loc4_].extraName ? s_Log[_loc4_].extraName : s_Log[_loc4_].module.name]);
                  if(s_Log[_loc4_].module == s_FrameModule)
                  {
                     _loc3_ = _loc4_;
                  }
                  break;
               case FrameEntryInfo.ENTRY_TYPE_LEAVE:
                  if(!(s_Log[_loc4_].enterCookie < _loc4_ && s_Log[_loc4_].enterCookie >= _loc3_ && s_Log[s_Log[_loc4_].enterCookie].flag == FrameEntryInfo.ENTRY_TYPE_ENTER && Boolean(s_Log[s_Log[_loc4_].enterCookie].module)))
                  {
                     throw new Error("Invalid Runtime Profiler Leave Frame");
                  }
                  _loc2_.push([s_Log[_loc4_].flag,s_Log[_loc4_].time,s_Log[s_Log[_loc4_].enterCookie].extraName ? s_Log[s_Log[_loc4_].enterCookie].extraName : s_Log[s_Log[_loc4_].enterCookie].module.name]);
                  break;
               case FrameEntryInfo.ENTRY_TYPE_LOG:
                  _loc2_.push([s_Log[_loc4_].flag,s_Log[_loc4_].time,s_Log[_loc4_].extraName ? s_Log[_loc4_].extraName : s_Log[_loc4_].name]);
            }
            _loc4_++;
         }
         _loc2_.push([FrameEntryInfo.ENTRY_TYPE_LEAVE,_loc1_,frameName]);
         var _loc5_:Object = {};
         _loc5_.log = _loc2_;
         _loc5_.resolution = 1000;
         _loc5_.overhead = s_Overhead;
         _loc5_.system = {
            "version":Capabilities.version,
            "debug":Capabilities.isDebugger,
            "arch":Capabilities.cpuArchitecture,
            "os":Capabilities.os,
            "stageX":s_stage.stageWidth,
            "stageY":s_stage.stageHeight,
            "screenX":Capabilities.screenResolutionX,
            "screenY":Capabilities.screenResolutionY
         };
         _loc5_.frame = s_Frame;
         _loc5_.capturedFrames = s_CapturedFrames + 1;
         _loc5_.metaData = s_MetaData;
         return _loc5_;
      }
      
      public static function reset() : void
      {
         s_LogPos = 0;
         s_TriggerStart = 0;
      }
      
      private static function initialize(param1:Boolean) : void
      {
         var profCookie:int = 0;
         var testForHighResTimer:Boolean = param1;
         if(!s_Initialized && s_Enabled)
         {
            s_Log = new Vector.<FrameEntryInfo>(initialLogSize);
            if(!s_Modules)
            {
               s_Modules = new Vector.<RuntimeModule>();
            }
            if(!s_FrameFilterFunctions)
            {
               s_FrameFilterFunctions = new Vector.<Function>();
            }
            s_actionscript = registerModule("Actionscript");
            s_preinit = registerModule("PreInit");
            s_totalFramesTag = GameTagManager.registerGameTag("Frames",function():int
            {
               return s_Frame;
            },GameTagManager.TYPE_COUNT_INT,GameTagManager.UPDATE_ASSIGN);
            s_Initialized = true;
            s_FrameProcessModule = registerModule("RuntimeProfiler.FrameProcess");
            s_FrameModule = registerModule("Frame");
            s_Overhead = calculateOverhead(calibrationIterations);
            s_frameStartPos = enter(s_FrameModule,frameName);
            profCookie = enter(s_preinit);
            s_Log[s_frameStartPos].time = 1;
            s_Log[profCookie].time = 1;
            leave(profCookie);
            nextFrame();
            s_actionscript.resetValues();
         }
      }
      
      private static function calculateOverhead(param1:int) : Number
      {
         var _loc5_:int = 0;
         var _loc2_:int = getTimer();
         var _loc3_:int = 0;
         while(_loc3_ < param1)
         {
            _loc5_ = enter(s_FrameModule,"test");
            leave(_loc5_);
            _loc3_++;
         }
         var _loc4_:int = getTimer() - _loc2_;
         reset();
         return Number(_loc4_) / Number(param1);
      }
      
      private static function checkForFrameFilter(param1:int, param2:int) : void
      {
         var _loc3_:int = s_Log[param2].time - s_Log[param1].time;
         FrameEntryFixup(_loc3_,param1,param2,s_Log);
         var _loc4_:int = 0;
         while(_loc4_ < s_FrameFilterFunctions.length)
         {
            s_FrameFilterFunctions[_loc4_](_loc3_,param1,param2,s_Log);
            _loc4_++;
         }
      }
      
      private static function checkForProfileTriggers(param1:int, param2:int) : void
      {
         var _loc4_:* = undefined;
         var _loc5_:int = 0;
         var _loc3_:Boolean = false;
         for(_loc4_ in s_TriggerSection)
         {
            _loc3_ = true;
         }
         if(_loc3_)
         {
            _loc5_ = s_TriggerStart;
            while(_loc5_ < s_LogPos)
            {
               if(s_Log[_loc5_].flag == FrameEntryInfo.ENTRY_TYPE_ENTER && Boolean(s_TriggerSection[s_Log[_loc5_].module.name]))
               {
                  triggerProfile(s_Log[_loc5_].module.name);
               }
               _loc5_++;
            }
         }
         s_TriggerStart = s_LogPos;
         if(s_TriggerFrameDelay > 0)
         {
            --s_TriggerFrameDelay;
            if(s_TriggerFrameDelay == 0)
            {
               s_TriggerFunction(s_TriggerName);
            }
         }
      }
   }
}

import flash.events.Event;

class InstrumentedListener
{
   
   private var func:Function;
   
   private var module:RuntimeModule;
   
   public function InstrumentedListener(param1:RuntimeModule, param2:Function)
   {
      super();
      this.func = param2;
      this.module = param1;
   }
   
   public function onEvent(param1:Event) : void
   {
      var _loc2_:int = int(RuntimeProfiler.enter(this.module));
      this.func(param1);
      RuntimeProfiler.leave(_loc2_);
   }
}
