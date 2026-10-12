package zasp.Classes
{
   import flash.display.DisplayObjectContainer;
   import flash.system.System;
   import flash.utils.getTimer;
   import zasp.Util.EMA;
   import zasp.Util.SumSampler;
   
   public class ZaspTrackerBase
   {
      
      protected static const ALPHA:Number = 0.07;
      
      protected var sma_dt:Number = 5000;
      
      protected var totalDt:int = 0;
      
      protected var totalNum:int = 0;
      
      protected var gameState:String = "";
      
      protected var gameNumber:Number = 0;
      
      protected var objectCount:int = 0;
      
      protected var emaF2F:EMA = new EMA(ALPHA);
      
      protected var emaOEF:EMA = new EMA(ALPHA);
      
      protected var emaMEM:EMA = new EMA(ALPHA);
      
      protected var sum5sF2F:SumSampler = null;
      
      protected var sum5sOEF:SumSampler = null;
      
      protected var detailTracker:ZaspTrackerDetail = null;
      
      protected var debugTracker:ZaspTrackerDebug = null;
      
      private var m_sessionid:String;
      
      public function ZaspTrackerBase(param1:String, param2:int = 5000)
      {
         super();
         this.sma_dt = param2;
         this.m_sessionid = param1;
         this.sum5sF2F = new SumSampler(this.sma_dt);
         this.sum5sOEF = new SumSampler(this.sma_dt);
      }
      
      public function sample(param1:Number, param2:Number) : void
      {
         var _loc3_:int = int(System.totalMemory);
         this.totalDt = getTimer();
         ++this.totalNum;
         this.emaF2F.sample(param1);
         this.emaOEF.sample(param2);
         this.emaMEM.sample(_loc3_);
         this.sum5sF2F.sample(param1);
         this.sum5sOEF.sample(param2);
         if(this.detailTracker)
         {
            this.detailTracker.sample(this.gameState,this.gameNumber,param1,_loc3_);
         }
         if(this.debugTracker)
         {
            this.debugTracker.sample(param1,param2);
         }
      }
      
      public function activateDetailTracking() : void
      {
         this.detailTracker = new ZaspTrackerDetail();
      }
      
      public function isDetailActive() : Boolean
      {
         return this.detailTracker != null;
      }
      
      public function activateDebugTracking(param1:DisplayObjectContainer = null, param2:Boolean = false) : void
      {
         this.debugTracker = new ZaspTrackerDebug(this,param2);
         if(param1)
         {
            param1.addChild(this.debugTracker.sprite);
            this.debugTracker.activateSpinners();
         }
      }
      
      public function report() : Object
      {
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc1_:Object = new Object();
         _loc1_.type = "fps";
         _loc1_.constants = "Alpha:" + ALPHA + " SMA_DT:" + this.sma_dt;
         _loc1_.totalDt = this.totalDt;
         _loc1_.totalNum = this.totalNum;
         _loc1_.ema_mem = this.emaMEM.value;
         _loc1_.game_state = this.gameState;
         _loc1_.game_number = this.gameNumber;
         _loc1_.object_count = this.objectCount;
         _loc1_.sessionid = this.m_sessionid;
         var _loc2_:Number = this.emaF2F.value;
         _loc1_.ema_f2f_dt = _loc2_;
         if(_loc2_ > 0)
         {
            _loc1_.ema_f2f_fps = 1000 / _loc2_;
         }
         var _loc3_:Number = this.emaOEF.value;
         _loc1_.ema_oef_dt = _loc3_;
         if(_loc3_ > 0)
         {
            _loc1_.ema_oef_fps = 1000 / _loc3_;
         }
         if(this.sum5sF2F.length > 0)
         {
            _loc4_ = this.sum5sF2F.value / this.sum5sF2F.length;
            _loc1_.s5s_f2f_dt = _loc4_;
            if(_loc4_ > 0)
            {
               _loc1_.s5s_f2f_fps = 1000 / _loc4_;
            }
         }
         if(this.sum5sOEF.length > 0)
         {
            _loc5_ = this.sum5sOEF.value / this.sum5sOEF.length;
            _loc1_.s5s_oef_dt = _loc5_;
            if(_loc5_ > 0)
            {
               _loc1_.s5s_oef_fps = 1000 / _loc5_;
            }
         }
         if(this.detailTracker)
         {
            _loc1_.detail = this.detailTracker.report();
         }
         return _loc1_;
      }
      
      public function get f2f() : Number
      {
         return this.emaF2F.value;
      }
      
      public function get f2f5s() : Number
      {
         return this.sum5sF2F.value / this.sum5sF2F.length;
      }
      
      public function get oef() : Number
      {
         return this.emaOEF.value;
      }
      
      public function get oef5s() : Number
      {
         return this.sum5sOEF.value / this.sum5sOEF.length;
      }
      
      public function get mem() : Number
      {
         return this.emaMEM.value;
      }
      
      public function setGameState(param1:String = "", param2:Number = 0) : void
      {
         this.gameState = param1;
         this.gameNumber = param2;
      }
      
      public function setObjectCount(param1:int = 0) : void
      {
         this.objectCount = param1;
      }
      
      public function log_report() : void
      {
         var _loc3_:Number = NaN;
         var _loc1_:Number = this.emaF2F.value;
         if(_loc1_ > 0)
         {
         }
         var _loc2_:Number = this.emaOEF.value;
         if(_loc2_ > 0)
         {
         }
         if(this.sum5sF2F.length > 0)
         {
            _loc3_ = this.sum5sF2F.value / this.sum5sF2F.length;
            if(_loc3_ > 0)
            {
            }
         }
         if(this.detailTracker)
         {
            this.detailTracker.log_report();
         }
         if(this.debugTracker)
         {
            this.debugTracker.log_report();
         }
      }
   }
}

