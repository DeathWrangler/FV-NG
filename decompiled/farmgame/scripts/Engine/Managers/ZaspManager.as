package Engine.Managers
{
   import Engine.Transactions.TSendZaspReport;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.getTimer;
   import zasp.Bridge.BridgeAgent;
   import zasp.Classes.ZaspTrackerBase;
   import zasp.Classes.ZaspTrackerGPI;
   
   public class ZaspManager
   {
      
      public static const DEFAULT_SAMPLE_RATE:int = 5000;
      
      public static const SESSION_KEY_FLASHVAR:String = "zaspSessionKey";
      
      public static const DEBUG_FLASHVAR:String = "zaspDebug";
      
      public static const SESSION_FLASHVAR:String = "zaspSession";
      
      public static const FPS_FLASHVAR:String = "zaspFPS";
      
      public static const WAIT_FLASHVAR:String = "zaspWait";
      
      public static const WF_FLASHVAR:String = "zaspWF";
      
      public static const GPI_FLASHVAR:String = "zaspGPI";
      
      public static const DETAIL_FLASHVAR:String = "zaspDetail";
      
      protected var m_reportInterval:Number = 5000;
      
      protected var m_batchSize:int = 4;
      
      protected var m_active:Boolean = false;
      
      protected var m_sendFPSMessage:Boolean = false;
      
      protected var m_batchedReports:Array = [];
      
      protected var m_baseTracker:ZaspTrackerBase;
      
      protected var m_gpiTracker:ZaspTrackerGPI = null;
      
      protected var m_reportStart:Number;
      
      protected var m_previousFrameStart:Number;
      
      protected var m_frameStart:Number = 0;
      
      protected var m_frameEnd:Number = 0;
      
      protected var m_gameStateActive:Boolean = true;
      
      protected var m_lastActivity:int = 0;
      
      protected var m_lastInactivity:int = 0;
      
      protected var m_gameDetailCallback:Function = null;
      
      protected var m_gameNumberCallback:Function = null;
      
      protected var m_bridgeAgent:BridgeAgent = null;
      
      protected var m_zaspSampleRate:int;
      
      protected var m_zaspSessionKey:String;
      
      protected var m_zaspDetail:Boolean;
      
      protected var m_zaspGPI:Boolean;
      
      protected var m_zaspSession:Boolean;
      
      protected var m_zaspWait:Boolean;
      
      protected var m_zaspWF:Boolean;
      
      public function ZaspManager(param1:DisplayObject, param2:int = 5000)
      {
         super();
         this.m_zaspSessionKey = ZaspManager.SESSION_KEY_FLASHVAR;
         if(GlobalEngine.getFlashVar(ZaspManager.SESSION_KEY_FLASHVAR))
         {
            this.m_zaspSessionKey = GlobalEngine.getFlashVar(ZaspManager.SESSION_KEY_FLASHVAR).toString();
         }
         this.m_zaspSampleRate = int(GlobalEngine.getFlashVar("zaspSampleRate"));
         this.m_reportInterval = param2;
         this.m_zaspDetail = Boolean(GlobalEngine.getFlashVar(ZaspManager.DETAIL_FLASHVAR)) && GlobalEngine.getFlashVar(ZaspManager.DETAIL_FLASHVAR) == "true";
         this.m_zaspSession = Boolean(GlobalEngine.getFlashVar(ZaspManager.SESSION_FLASHVAR)) && GlobalEngine.getFlashVar(ZaspManager.SESSION_FLASHVAR) == "true";
         this.m_sendFPSMessage = Boolean(GlobalEngine.getFlashVar(ZaspManager.FPS_FLASHVAR)) && GlobalEngine.getFlashVar(ZaspManager.FPS_FLASHVAR) == "true";
         this.m_zaspGPI = Boolean(GlobalEngine.getFlashVar(ZaspManager.GPI_FLASHVAR)) && GlobalEngine.getFlashVar(ZaspManager.GPI_FLASHVAR) == "true";
         this.m_zaspWait = Boolean(GlobalEngine.getFlashVar(ZaspManager.WAIT_FLASHVAR)) && GlobalEngine.getFlashVar(ZaspManager.WAIT_FLASHVAR) == "true";
         this.m_zaspWF = Boolean(GlobalEngine.getFlashVar(ZaspManager.WF_FLASHVAR)) && GlobalEngine.getFlashVar(ZaspManager.WF_FLASHVAR) == "true";
         if(this.m_zaspSampleRate > 0)
         {
            if(this.m_zaspSampleRate == 1 || Math.random() * this.m_zaspSampleRate <= 1)
            {
               this.activate();
            }
         }
         this.m_gameDetailCallback = this.gameDetail;
         this.m_gameNumberCallback = this.gameNumber;
         this.addStageListeners(param1);
         if(GlobalEngine.getFlashVar("bridgeAgent") == "true")
         {
            this.m_bridgeAgent = new BridgeAgent(param1);
            this.m_bridgeAgent.start();
         }
      }
      
      protected function activate() : void
      {
         this.m_active = true;
         this.m_baseTracker = new ZaspTrackerBase(String(this.m_zaspSessionKey),this.m_reportInterval);
         if(this.m_zaspDetail)
         {
            this.m_baseTracker.activateDetailTracking();
         }
         if(this.m_zaspGPI)
         {
            this.m_gpiTracker = new ZaspTrackerGPI(String(this.m_zaspSessionKey),this.m_reportInterval,false);
            this.m_gpiTracker.activate(this.m_zaspSession,this.m_zaspWait,this.m_zaspWF);
         }
      }
      
      public function zaspWaitStart(param1:String, param2:String) : int
      {
         if(this.m_active && Boolean(this.m_gpiTracker))
         {
            return this.m_gpiTracker.zaspWaitStart(param1,param2);
         }
         return 0;
      }
      
      public function zaspWaitEnd(param1:int) : void
      {
         if(this.m_active && Boolean(this.m_gpiTracker))
         {
            this.m_gpiTracker.zaspWaitEnd(param1);
         }
      }
      
      public function zaspPopup() : void
      {
         if(this.m_active && Boolean(this.m_gpiTracker))
         {
            this.m_gpiTracker.popup();
         }
      }
      
      public function zaspInteractive() : void
      {
         if(this.m_active && Boolean(this.m_gpiTracker))
         {
            this.m_gpiTracker.interactive();
         }
         if(this.m_bridgeAgent)
         {
            this.m_bridgeAgent.saveLoadTime(getTimer());
         }
      }
      
      public function zaspGameStateDeactivate(param1:Event) : void
      {
         this.m_gameStateActive = false;
         this.m_lastInactivity = getTimer();
      }
      
      public function zaspGameStateActivate(param1:Event) : void
      {
         this.zaspActivity();
         this.m_gameStateActive = true;
      }
      
      public function zaspOnMouseClick(param1:Event) : void
      {
         this.zaspClick();
      }
      
      public function zaspOnMouseMove(param1:Event) : void
      {
         this.zaspMove();
      }
      
      public function zaspIsGameActive() : Boolean
      {
         return this.m_gameStateActive;
      }
      
      public function zaspMove() : void
      {
         this.zaspActivity();
      }
      
      public function zaspClick() : void
      {
         this.zaspActivity();
         if(this.m_active && Boolean(this.m_gpiTracker))
         {
            this.m_gpiTracker.click();
         }
      }
      
      public function zaspActivity() : void
      {
         this.m_lastActivity = getTimer();
      }
      
      public function trackTimingStart(param1:String) : void
      {
         if(this.m_active && Boolean(this.m_gpiTracker))
         {
            this.m_gpiTracker.trackLoadTimingStart(param1);
         }
      }
      
      public function trackTimingStop(param1:String) : void
      {
         if(this.m_active && Boolean(this.m_gpiTracker))
         {
            this.m_gpiTracker.trackLoadTimingStop(param1);
         }
      }
      
      public function preUpdate() : void
      {
         if(this.m_active)
         {
            this.m_previousFrameStart = this.m_frameStart;
            this.m_frameStart = getTimer();
         }
      }
      
      public function postUpdate() : void
      {
         if(this.m_active && this.m_previousFrameStart > 0)
         {
            this.m_frameEnd = getTimer();
            if(this.m_baseTracker.isDetailActive())
            {
               this.updateGameState();
            }
            this.m_baseTracker.sample(this.m_frameStart - this.m_previousFrameStart,this.m_frameEnd - this.m_frameStart);
            if(this.m_gpiTracker)
            {
               this.m_gpiTracker.setFPSData(this.m_baseTracker.f2f,this.m_baseTracker.oef,this.m_baseTracker.mem,this.m_baseTracker.f2f5s,this.m_baseTracker.oef5s,this.m_lastActivity,this.gameDefCon());
               this.m_gpiTracker.sample();
            }
            if(!this.m_reportStart)
            {
               this.m_reportStart = this.m_frameEnd;
            }
            else if(this.m_frameEnd - this.m_reportStart > this.m_reportInterval)
            {
               this.cacheReport();
               this.m_reportStart = this.m_frameEnd;
            }
         }
      }
      
      protected function cacheReport() : void
      {
         var _loc1_:Object = null;
         if(this.m_baseTracker)
         {
            if(this.m_sendFPSMessage)
            {
               _loc1_ = this.m_baseTracker.report();
            }
            if(_loc1_)
            {
               this.modifyReport(_loc1_);
               this.m_batchedReports.push(_loc1_);
            }
         }
         _loc1_ = null;
         if(this.m_gpiTracker)
         {
            _loc1_ = this.m_gpiTracker.report();
            if(_loc1_)
            {
               this.modifyReport(_loc1_);
               this.m_batchedReports.push(_loc1_);
            }
         }
         if(this.m_batchedReports.length >= this.m_batchSize)
         {
            this.sendReports();
         }
      }
      
      protected function modifyReport(param1:Object) : void
      {
         if(param1["type"] == "fps")
         {
            param1["constants"] += " V:0";
            param1["string5"] = "";
            param1["string6"] = "";
            param1["string7"] = "";
            param1["string8"] = "";
            param1["number7"] = 0;
            param1["number8"] = 0;
         }
         else if(param1["type"] == "GPI")
         {
         }
      }
      
      protected function gameDetail() : String
      {
         return "";
      }
      
      protected function gameNumber() : Number
      {
         return 0;
      }
      
      protected function gameDefCon() : int
      {
         return -1;
      }
      
      private function updateGameState() : void
      {
         var _loc1_:Number = 0;
         if(this.m_gameNumberCallback != null)
         {
            _loc1_ = this.m_gameNumberCallback();
         }
         var _loc2_:String = "";
         if(this.m_gameDetailCallback != null)
         {
            _loc2_ = this.m_gameDetailCallback();
         }
         this.m_baseTracker.setGameState(_loc2_,_loc1_);
      }
      
      public function sendReports() : void
      {
         if(this.m_active && TransactionManager.canSendTransactions())
         {
            TransactionManager.addTransaction(new TSendZaspReport(this.m_batchedReports));
            this.m_batchedReports = new Array();
         }
      }
      
      public function set batchSize(param1:int) : void
      {
         this.m_batchSize = param1;
      }
      
      public function set reportInterval(param1:Number) : void
      {
         this.m_reportInterval = param1;
      }
      
      public function get zasp() : ZaspTrackerBase
      {
         return this.m_baseTracker;
      }
      
      public function set gameDetailCallback(param1:Function) : void
      {
         this.m_gameDetailCallback = param1;
      }
      
      public function set gameNumberCallback(param1:Function) : void
      {
         this.m_gameNumberCallback = param1;
      }
      
      public function addStageListeners(param1:DisplayObject) : void
      {
         param1.addEventListener(Event.ACTIVATE,this.zaspGameStateActivate);
         param1.addEventListener(Event.DEACTIVATE,this.zaspGameStateDeactivate);
         param1.addEventListener(MouseEvent.CLICK,this.zaspOnMouseClick,false,3);
         param1.addEventListener(MouseEvent.MOUSE_MOVE,this.zaspOnMouseMove,false,3);
      }
      
      public function forceActivateDebugTracking(param1:DisplayObjectContainer = null) : void
      {
         if(this.m_active == false)
         {
            this.activate();
         }
         this.m_baseTracker.activateDebugTracking(param1);
      }
   }
}

