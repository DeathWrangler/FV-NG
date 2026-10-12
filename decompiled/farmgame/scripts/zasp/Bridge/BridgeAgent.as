package zasp.Bridge
{
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.TimerEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   import flash.net.URLVariables;
   import flash.system.System;
   import flash.utils.*;
   import zasp.Util.*;
   
   public class BridgeAgent extends EventDispatcher
   {
      
      public static var EVENT_BRIDGE_LOG:String = "BridgeLogEvent";
      
      private const ACTION_POLL:String = "Poll";
      
      private const ACTION_GET_LOAD_TIME:String = "GetLoadTime";
      
      private const ACTION_GET_MEMORY_SINGLE:String = "GetMemorySingle";
      
      private const ACTION_GET_MEMORY_BEGIN:String = "GetMemoryBegin";
      
      private const ACTION_GET_MEMORY_END:String = "GetMemoryEnd";
      
      private const ACTION_GET_FPS_SINGLE:String = "GetFpsSingle";
      
      private const ACTION_GET_FPS_BEGIN:String = "GetFpsBegin";
      
      private const ACTION_GET_FPS_END:String = "GetFpsEnd";
      
      private const SIGNAL_SUCCESS:String = "Command::Success";
      
      private const SIGNAL_FAILURE:String = "Command::Failure";
      
      private const GET_COMMAND_DELAY:Number = 1000;
      
      private var bridgeDomain:String = "http://zunit.corp.zynga.com/WebBridge/";
      
      private var pingUrl:String = this.bridgeDomain + "Ping.ashx";
      
      private var getCommandUrl:String = this.bridgeDomain + "GetCommand.ashx";
      
      private var setResultUrl:String = this.bridgeDomain + "SetResult.ashx";
      
      private var isRunning:Boolean = false;
      
      private var request:URLRequest;
      
      private var requestVars:URLVariables;
      
      private var response:URLLoader;
      
      private var getCommandTimer:Timer;
      
      private var index:Number = 0;
      
      private var displayRoot:DisplayObject;
      
      private var loadTime:Number = 0;
      
      private const ALPHA:Number = 0.15;
      
      private const MS_PER_S:Number = 1000;
      
      private var fpsCommandID:String;
      
      private var fpsSampler:SumSampler;
      
      private var fpsInterval:uint;
      
      private var ema:EMA = null;
      
      private var lastTickMS:int = 0;
      
      private var memoryCommandID:String;
      
      private var memorySampler:SumSampler;
      
      private var memoryInterval:uint;
      
      public function BridgeAgent(param1:DisplayObject)
      {
         super();
         this.log("::BridgeAgent");
         this.displayRoot = param1;
      }
      
      public function start() : void
      {
         try
         {
            this.log("::Start");
            this.isRunning = true;
            this.getCommandTimer = new Timer(this.GET_COMMAND_DELAY,1);
            this.getCommandTimer.addEventListener(TimerEvent.TIMER,this.getCommand);
            this.ema = new EMA(this.ALPHA);
            this.displayRoot.addEventListener(Event.ADDED_TO_STAGE,this.handleAddedToStage);
            this.displayRoot.addEventListener(Event.ENTER_FRAME,this.handleEnterFrame);
            this.ping(null);
         }
         catch(err:Error)
         {
            this.log(err.toString());
            this.stop();
         }
      }
      
      public function stop() : void
      {
         try
         {
            this.log("::Stop");
            this.displayRoot.removeEventListener(Event.ADDED_TO_STAGE,this.handleAddedToStage);
            this.displayRoot.removeEventListener(Event.ENTER_FRAME,this.handleEnterFrame);
            this.ema = null;
         }
         catch(err:Error)
         {
            this.log(err.toString());
         }
         finally
         {
            this.isRunning = false;
         }
      }
      
      private function ping(param1:Event) : void
      {
         if(this.isRunning)
         {
            this.log("::Ping");
            this.request = new URLRequest(this.pingUrl);
            this.requestVars = new URLVariables();
            this.response = new URLLoader();
            this.requestVars.d = this.index++;
            this.request.method = URLRequestMethod.GET;
            this.request.data = this.requestVars;
            this.response.addEventListener(Event.COMPLETE,this.handlePingResponse);
            this.response.addEventListener(IOErrorEvent.IO_ERROR,this.handlePingError);
            this.response.load(this.request);
         }
      }
      
      private function handlePingResponse(param1:Event) : void
      {
         var event:Event = param1;
         this.log("::HandlePingResponse");
         try
         {
            this.cleanLoaders();
            if(event != null && event.target != null && event.target.data != null)
            {
               this.log("BridgeID: " + event.target.data);
               this.getCommand(null);
            }
         }
         catch(error:Error)
         {
            this.log(error.message);
            this.stop();
         }
      }
      
      private function handlePingError(param1:Event) : void
      {
         this.log("::HandlePingError");
         this.log("::HandlePingError:" + param1.type);
         this.cleanLoaders();
         this.stop();
      }
      
      private function getCommand(param1:Event) : void
      {
         if(this.getCommandTimer)
         {
            this.getCommandTimer.stop();
         }
         if(this.isRunning)
         {
            this.log("::GetCommand");
            this.request = new URLRequest(this.getCommandUrl);
            this.requestVars = new URLVariables();
            this.response = new URLLoader();
            this.requestVars.d = this.index++;
            this.request.method = URLRequestMethod.GET;
            this.request.data = this.requestVars;
            this.response.addEventListener(Event.COMPLETE,this.handleGetCommandResponse);
            this.response.addEventListener(IOErrorEvent.IO_ERROR,this.handleGetCommandError);
            this.response.load(this.request);
         }
      }
      
      private function handleGetCommandResponse(param1:Event) : void
      {
         var commandString:String = null;
         var splits:Array = null;
         var commandID:String = null;
         var commandType:String = null;
         var commandData:String = null;
         var event:Event = param1;
         this.log("::HandleGetCommandResponse");
         try
         {
            this.cleanLoaders();
            if(event != null && event.target != null && event.target.data != null)
            {
               commandString = event.target.data;
               splits = commandString.split("&");
               commandID = splits[0].split("=")[1];
               commandType = splits[1].split("=")[1];
               commandData = splits[2].split("=")[1];
               switch(commandType)
               {
                  case this.ACTION_GET_LOAD_TIME:
                     this.handleGetLoadTime(commandID,commandType,commandData);
                     break;
                  case this.ACTION_GET_FPS_SINGLE:
                     this.handleGetFpsSingle(commandID,commandType,commandData);
                     break;
                  case this.ACTION_GET_FPS_BEGIN:
                     this.handleGetFpsBegin(commandID,commandType,commandData);
                     break;
                  case this.ACTION_GET_FPS_END:
                     this.handleGetFpsEnd(commandID,commandType,commandData);
                     break;
                  case this.ACTION_GET_MEMORY_SINGLE:
                     this.handleGetMemorySingle(commandID,commandType,commandData);
                     break;
                  case this.ACTION_GET_MEMORY_BEGIN:
                     this.handleGetMemoryBegin(commandID,commandType,commandData);
                     break;
                  case this.ACTION_GET_MEMORY_END:
                     this.handleGetMemoryEnd(commandID,commandType,commandData);
                     break;
                  default:
                     this.handlePoll();
               }
            }
         }
         catch(error:Error)
         {
            this.log(error.message);
            this.handlePoll();
         }
      }
      
      private function handleGetCommandError(param1:Event) : void
      {
         this.log("::HandleGetCommandError");
         this.cleanLoaders();
         this.getCommandTimer.start();
      }
      
      private function setResult(param1:String, param2:String) : void
      {
         var _loc3_:String = this.setResultUrl + "?commandID=" + param1 + "&completed=true";
         this.log("::SetResult");
         this.request = new URLRequest(_loc3_);
         this.requestVars = new URLVariables();
         this.response = new URLLoader();
         this.requestVars.commandID = param1;
         this.requestVars.completed = "true";
         this.request.method = URLRequestMethod.POST;
         this.request.data = param2;
         this.response.addEventListener(Event.COMPLETE,this.handleSetResultResponse);
         this.response.addEventListener(IOErrorEvent.IO_ERROR,this.handleSetResultError);
         this.response.load(this.request);
      }
      
      private function handleSetResultResponse(param1:Event) : void
      {
         this.log("::HandleSetResultResponse");
         this.cleanLoaders();
         this.getCommandTimer.start();
      }
      
      private function handleSetResultError(param1:Event) : void
      {
         this.log("::HandleSetResultError");
         this.cleanLoaders();
         this.getCommandTimer.start();
      }
      
      private function cleanLoaders() : void
      {
         try
         {
            this.log("::CleanLoaders");
            this.requestVars = null;
            if(this.request != null)
            {
               this.request.data = null;
               this.request.url = null;
               this.request = null;
            }
            if(this.response != null)
            {
               this.response.close();
               this.response.removeEventListener(Event.COMPLETE,this.handlePingResponse);
               this.response.removeEventListener(IOErrorEvent.IO_ERROR,this.handlePingError);
               this.response.removeEventListener(Event.COMPLETE,this.handleGetCommandResponse);
               this.response.removeEventListener(IOErrorEvent.IO_ERROR,this.handleGetCommandError);
               this.response.removeEventListener(Event.COMPLETE,this.handleSetResultResponse);
               this.response.removeEventListener(IOErrorEvent.IO_ERROR,this.handleSetResultError);
               this.response = null;
            }
         }
         catch(error:Error)
         {
            this.log("::CleanLoaders:Error:" + error.message);
         }
      }
      
      private function handlePoll() : void
      {
         this.log("::HandlePoll");
         this.getCommandTimer.start();
      }
      
      private function handleGetLoadTime(param1:String, param2:String, param3:String) : void
      {
         this.setResult(param1,this.loadTime.toString());
      }
      
      public function saveLoadTime(param1:Number) : void
      {
         this.loadTime = param1;
      }
      
      private function handleGetMemorySingle(param1:String, param2:String, param3:String) : void
      {
         System.gc();
         this.setResult(param1,System.totalMemory.toString());
      }
      
      private function handleGetMemoryBegin(param1:String, param2:String, param3:String) : void
      {
         var _loc4_:Number = Number(param3);
         System.gc();
         this.memoryCommandID = param1;
         this.memorySampler = new SumSampler(Number.MAX_VALUE);
         this.memoryInterval = setInterval(this.getMemoryAsync,_loc4_);
         this.setResult(param1,this.SIGNAL_SUCCESS);
      }
      
      private function handleGetMemoryEnd(param1:String, param2:String, param3:String) : void
      {
         var _loc4_:uint = this.memorySampler.value / this.memorySampler.length;
         clearInterval(this.memoryInterval);
         this.memoryCommandID = null;
         this.memorySampler = null;
         this.setResult(param1,_loc4_.toString());
      }
      
      private function getMemoryAsync() : void
      {
         this.memorySampler.sample(System.totalMemory);
      }
      
      private function handleGetFpsSingle(param1:String, param2:String, param3:String) : void
      {
         var _loc4_:uint = this.MS_PER_S / this.ema.value;
         this.setResult(param1,_loc4_.toString());
      }
      
      private function handleGetFpsBegin(param1:String, param2:String, param3:String) : void
      {
         var _loc4_:Number = Number(param3);
         this.fpsCommandID = param1;
         this.fpsSampler = new SumSampler(Number.MAX_VALUE);
         this.fpsInterval = setInterval(this.getFpsAsync,_loc4_);
         this.setResult(param1,this.SIGNAL_SUCCESS);
      }
      
      private function handleGetFpsEnd(param1:String, param2:String, param3:String) : void
      {
         var _loc4_:String = "";
         var _loc5_:int = 0;
         while(_loc5_ < this.fpsSampler.length)
         {
            _loc4_ += this.fpsSampler.sampleAt(_loc5_).toString() + ",";
            _loc5_++;
         }
         clearInterval(this.fpsInterval);
         this.fpsCommandID = null;
         this.fpsSampler = null;
         this.setResult(param1,_loc4_);
      }
      
      public function handleAddedToStage(param1:Event) : void
      {
         this.ema = new EMA(this.ALPHA);
         this.lastTickMS = getTimer();
      }
      
      public function handleEnterFrame(param1:Event) : void
      {
         var _loc2_:int = getTimer();
         var _loc3_:int = _loc2_ - this.lastTickMS;
         this.lastTickMS = _loc2_;
         this.ema.sample(_loc3_);
      }
      
      private function getFpsAsync() : void
      {
         var _loc1_:uint = this.MS_PER_S / this.ema.value;
         this.fpsSampler.sample(_loc1_);
      }
      
      private function log(param1:String) : void
      {
         var _loc2_:BridgeLogEvent = null;
         if(this.hasEventListener(EVENT_BRIDGE_LOG))
         {
            _loc2_ = new BridgeLogEvent(EVENT_BRIDGE_LOG,true,true);
            _loc2_.message = param1;
            this.dispatchEvent(_loc2_);
         }
      }
   }
}

