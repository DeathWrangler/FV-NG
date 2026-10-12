package zasp.Classes
{
   import flash.external.ExternalInterface;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   import zasp.Util.*;
   
   public class ZaspTrackerGPI
   {
      
      private static var waitHandle:int = 1;
      
      private static var m_logOnce:Boolean = false;
      
      private var m_uiWaitHandle:int = 0;
      
      private var m_userWait:Boolean = false;
      
      private var m_activeWFs:Dictionary;
      
      private var m_activeWaits:Dictionary;
      
      protected var m_numActiveWaits:int = 0;
      
      protected var m_numActiveSTPWaits:int = 0;
      
      protected var m_waitStartTime:int = 0;
      
      protected var m_sTPWaitStartTime:int = 0;
      
      protected var m_totalWaitTime:int = 0;
      
      protected var m_sTPWaitTime:int = 0;
      
      protected var m_playMsecs:int = 0;
      
      protected var m_playInterval:int = 10000;
      
      protected var m_numWFs:int = 0;
      
      protected var m_numWaits:int = 0;
      
      protected var m_numSTPs:int = 0;
      
      protected var m_numLoads:int = 0;
      
      protected var m_numDialogs:int = 0;
      
      protected var m_numUnknownWaits:int = 0;
      
      private var m_queuedMessages:Array;
      
      private var m_playMsecsBandDefinition:Array;
      
      private var m_playMsecsBands:Vector.<int>;
      
      private var m_playDefConMsecs:Vector.<int>;
      
      private var m_lastActivity:int = 0;
      
      private var m_lastDefCon:int = 0;
      
      private var m_sessionStartTime:int = 0;
      
      private var m_sessionid:String;
      
      private var m_failedInit:Boolean = false;
      
      private var m_trackAMFTotalWait:Boolean = true;
      
      protected var m_waitHandleDict:Dictionary;
      
      private var m_numPopups:int = 0;
      
      private var m_numClicks:int = 0;
      
      private var m_loadTime:int = 0;
      
      private var m_ignoreWait:Boolean = false;
      
      protected var m_active:Boolean = false;
      
      private var m_sessionInterval:int = 0;
      
      private var m_lastSession:int = 0;
      
      protected var m_f2f:Number;
      
      protected var m_mem:Number;
      
      protected var m_oef:Number;
      
      protected var m_f2f5s:Number;
      
      protected var m_oef5s:Number;
      
      protected var m_play_f2f_sum:Number = 0;
      
      protected var m_play_oef_sum:Number = 0;
      
      protected var m_play_samples:Number = 0;
      
      protected var m_f2f_sum:Number = 0;
      
      protected var m_total_samples:Number = 0;
      
      private var m_sendSessionMessage:Boolean = true;
      
      private var m_sendWaitMessage:Boolean = true;
      
      private var m_sendWFMessage:Boolean = true;
      
      private var m_componentInitTimes:Object = null;
      
      public function ZaspTrackerGPI(param1:String, param2:int = 5000, param3:Boolean = false)
      {
         super();
         if(ExternalInterface.available)
         {
            ExternalInterface.addCallback("waitStateChange",this.waitStateChange);
            ExternalInterface.addCallback("gameStateChange",this.zaspWorkFlowEvent);
            this.m_sessionStartTime = 0;
            this.m_waitHandleDict = new Dictionary();
            this.m_activeWFs = new Dictionary();
            this.m_activeWaits = new Dictionary();
            this.m_queuedMessages = new Array();
            this.m_playMsecsBandDefinition = new Array(21,18,15,12,9,6,3,2);
            this.m_playMsecsBands = new Vector.<int>(8);
            this.m_playDefConMsecs = new Vector.<int>();
            this.m_sessionInterval = param2;
            this.m_sessionid = param1;
            this.m_trackAMFTotalWait = param3;
         }
         else
         {
            this.m_failedInit = true;
            this.m_active = false;
         }
      }
      
      public function report() : Object
      {
         var _loc1_:Object = null;
         if(this.m_queuedMessages.length > 0)
         {
            _loc1_ = new Object();
            _loc1_.type = "GPI";
            _loc1_.data = this.m_queuedMessages;
            this.m_queuedMessages = new Array();
         }
         return _loc1_;
      }
      
      public function sample() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:Number = NaN;
         var _loc4_:uint = 0;
         if(this.m_lastSession == 0)
         {
            this.m_lastSession = getTimer();
            this.queueSessionReport();
         }
         else
         {
            _loc1_ = getTimer();
            if(_loc1_ - this.m_lastSession > this.m_sessionInterval)
            {
               this.m_f2f_sum += this.m_f2f5s;
               ++this.m_total_samples;
               if(_loc1_ - this.m_playInterval < this.m_lastActivity)
               {
                  ++this.m_play_samples;
                  this.m_play_f2f_sum += this.m_f2f5s;
                  this.m_play_oef_sum += this.m_oef5s;
                  _loc2_ = _loc1_ - this.m_lastSession;
                  this.m_playMsecs += _loc2_;
                  if(this.m_lastDefCon >= 0)
                  {
                     while(this.m_playDefConMsecs.length < this.m_lastDefCon + 1)
                     {
                        this.m_playDefConMsecs[this.m_playDefConMsecs.length] = 0;
                     }
                     this.m_playDefConMsecs[this.m_lastDefCon] += _loc2_;
                  }
                  _loc3_ = 1000 / this.m_f2f5s;
                  while(_loc4_ < this.m_playMsecsBandDefinition.length)
                  {
                     if(_loc3_ >= this.m_playMsecsBandDefinition[_loc4_])
                     {
                        break;
                     }
                     this.m_playMsecsBands[_loc4_] += _loc2_;
                     _loc4_++;
                  }
               }
               this.queueSessionReport();
               this.m_lastSession = _loc1_;
               if(Boolean(this.m_componentInitTimes) && m_logOnce)
               {
                  this.queueMessage(this.m_componentInitTimes);
                  m_logOnce = false;
               }
            }
         }
      }
      
      public function popup() : void
      {
         ++this.m_numPopups;
      }
      
      public function click() : void
      {
         ++this.m_numClicks;
      }
      
      public function trackLoadTimingStart(param1:String) : void
      {
         if(param1)
         {
            if(!this.m_componentInitTimes)
            {
               this.m_componentInitTimes = new Object();
            }
            this.m_componentInitTimes["type"] = "loadstats";
            this.m_componentInitTimes[param1] = getTimer();
         }
      }
      
      public function trackLoadTimingStop(param1:String) : void
      {
         if(param1)
         {
            if(Boolean(this.m_componentInitTimes) && Boolean(this.m_componentInitTimes[param1]))
            {
               this.m_componentInitTimes[param1] = getTimer() - this.m_componentInitTimes[param1];
            }
         }
      }
      
      public function interactive() : void
      {
         this.m_loadTime = getTimer();
         this.m_sessionStartTime = this.m_loadTime;
         m_logOnce = true;
         if(this.m_numActiveSTPWaits)
         {
            this.m_waitStartTime = this.m_loadTime;
         }
         if(this.m_numActiveWaits)
         {
            this.m_sTPWaitStartTime = this.m_loadTime;
         }
      }
      
      public function activate(param1:Boolean, param2:Boolean, param3:Boolean) : void
      {
         if(!this.m_active && !this.m_failedInit)
         {
            this.m_active = true;
            this.m_sendSessionMessage = param1;
            this.m_sendWaitMessage = param2;
            this.m_sendWFMessage = param3;
         }
      }
      
      public function deactivate() : void
      {
         if(this.m_active && !this.m_failedInit)
         {
            this.m_active = false;
         }
      }
      
      private function queueMessage(param1:Object) : void
      {
         this.m_queuedMessages.push(param1);
      }
      
      public function ignoreWaits(param1:Boolean) : void
      {
         this.m_ignoreWait = param1;
      }
      
      public function waitsDisabled() : Boolean
      {
         return this.m_ignoreWait;
      }
      
      private function queueWFMessage(param1:int, param2:String, param3:int, param4:int, param5:String) : void
      {
         var _loc6_:Object = null;
         if(this.m_sendWFMessage)
         {
            _loc6_ = new Object();
            _loc6_.sessionid = this.m_sessionid;
            _loc6_.workFlow = param2;
            _loc6_.timeStamp = param1;
            _loc6_.wfLength = param3;
            _loc6_.waitTime = param4;
            _loc6_.type = "gs";
            _loc6_.waits = param5;
            this.queueMessage(_loc6_);
         }
      }
      
      private function queueWaitMessage(param1:int, param2:String, param3:String, param4:int, param5:String, param6:String) : void
      {
         var _loc7_:Object = null;
         if(this.m_sendWaitMessage)
         {
            _loc7_ = new Object();
            _loc7_.sessionid = this.m_sessionid;
            _loc7_.timeStamp = param1;
            _loc7_.detail = param3;
            _loc7_.MD5 = param6;
            _loc7_.type = "gsWait";
            _loc7_.waitType = param2;
            _loc7_.waitTime = param4;
            _loc7_.wfs = param5;
            this.queueMessage(_loc7_);
         }
      }
      
      public function setFPSData(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:int, param7:int) : void
      {
         this.m_f2f = param1;
         this.m_mem = param3;
         this.m_oef = param2;
         this.m_f2f5s = param4;
         this.m_oef5s = param5;
         this.m_lastActivity = param6;
         this.m_lastDefCon = param7;
      }
      
      private function queueSessionReport() : void
      {
         var _loc1_:Object = null;
         var _loc2_:int = 0;
         var _loc3_:uint = 0;
         if(this.m_sendSessionMessage && this.m_loadTime != 0)
         {
            _loc1_ = new Object();
            _loc2_ = getTimer();
            _loc1_.type = "gsSession";
            _loc1_.sessionid = this.m_sessionid;
            _loc1_.timeStamp = _loc2_;
            _loc1_.sessionTime = _loc2_ - this.m_sessionStartTime;
            if(this.m_numActiveWaits)
            {
               _loc1_.waitTime = this.m_totalWaitTime + (_loc2_ - this.m_waitStartTime);
            }
            else
            {
               _loc1_.waitTime = this.m_totalWaitTime;
            }
            _loc1_.numClicks = this.m_numClicks;
            _loc1_.numDialogs = this.m_numPopups;
            _loc1_.numLoads = this.m_numLoads;
            _loc1_.numSTPs = this.m_numSTPs;
            _loc1_.numUnknownWaits = this.m_numUnknownWaits;
            _loc1_.numWorkFlows = this.m_numWFs;
            if(this.m_numActiveSTPWaits)
            {
               _loc1_.STPWaitTime = this.m_sTPWaitTime + (_loc2_ - this.m_sTPWaitStartTime);
            }
            else
            {
               _loc1_.STPWaitTime = this.m_sTPWaitTime;
            }
            _loc1_.fps = this.m_f2f_sum / this.m_total_samples;
            _loc1_.mem = this.m_mem;
            _loc1_.oef = this.m_oef;
            if(this.m_play_samples > 0)
            {
               _loc1_.play_oef = this.m_play_oef_sum / this.m_play_samples;
               _loc1_.play_f2f = this.m_play_f2f_sum / this.m_play_samples;
               _loc1_.play_msecs = this.m_playMsecs;
               _loc1_.play_msec_bands = "";
               _loc1_.play_msec_bandsB = "";
               _loc3_ = 0;
               while(_loc3_ < this.m_playMsecsBandDefinition.length / 2)
               {
                  _loc1_.play_msec_bands += this.m_playMsecsBandDefinition[_loc3_].toString() + "-" + this.m_playMsecsBands[_loc3_].toString() + "-";
                  _loc3_++;
               }
               _loc3_ = this.m_playMsecsBandDefinition.length / 2;
               while(_loc3_ < this.m_playMsecsBandDefinition.length)
               {
                  _loc1_.play_msec_bandsB += this.m_playMsecsBandDefinition[_loc3_].toString() + "-" + this.m_playMsecsBands[_loc3_].toString() + "-";
                  _loc3_++;
               }
               _loc1_.play_defcon_msecs = "";
               _loc3_ = 0;
               while(_loc3_ < this.m_playDefConMsecs.length)
               {
                  _loc1_.play_defcon_msecs += this.m_playDefConMsecs[_loc3_].toString() + "-";
                  _loc3_++;
               }
            }
            _loc1_.loadTime = this.m_loadTime;
            this.queueMessage(_loc1_);
         }
      }
      
      private function wFStart(param1:String) : void
      {
         var _loc2_:Object = null;
         var _loc4_:* = undefined;
         var _loc5_:Object = null;
         var _loc3_:int = getTimer();
         if(!this.m_activeWFs[param1])
         {
            _loc2_ = new Object();
            ++this.m_numWFs;
            if(this.m_numActiveWaits)
            {
               _loc2_.waitStartTime = _loc3_;
            }
            else
            {
               _loc2_.waitStartTime = 0;
            }
            _loc2_.waitTime = 0;
            _loc2_.startTime = _loc3_;
            _loc2_.name = param1;
            _loc2_.waits = new Array();
            this.m_activeWFs[param1] = _loc2_;
            for(_loc4_ in this.m_activeWaits)
            {
               _loc5_ = this.m_activeWaits[_loc4_];
               _loc5_.wfs.push(_loc2_.name);
               _loc2_.waits.push(_loc5_.MD5);
            }
         }
      }
      
      private function wFEnd(param1:String) : void
      {
         var _loc2_:Object = null;
         var _loc4_:BloomFilter = null;
         var _loc5_:String = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc3_:int = getTimer();
         if(this.m_activeWFs[param1] != null)
         {
            _loc2_ = this.m_activeWFs[param1];
            if(this.m_numActiveWaits)
            {
               if(_loc2_.waitStartTime)
               {
                  _loc2_.waitTime += _loc3_ - _loc2_.waitStartTime;
               }
               else
               {
                  _loc2_.waitTime += _loc3_ - this.m_waitStartTime;
               }
            }
            _loc4_ = new BloomFilter(new Array(BloomFilter.DJB,BloomFilter.PJW,BloomFilter.DEK,BloomFilter.JS,BloomFilter.ELF),20);
            _loc5_ = "";
            if(_loc2_.waits.length != 0)
            {
               _loc4_.BloomAdd(_loc2_.waits[0]);
               _loc7_ = 1;
               while(_loc7_ < _loc2_.waits.length)
               {
                  _loc4_.BloomAdd(_loc2_.waits[_loc7_]);
                  _loc7_++;
               }
               _loc5_ = _loc4_.toString();
            }
            _loc6_ = _loc3_ - _loc2_.startTime;
            this.queueWFMessage(_loc3_,param1,_loc6_,_loc2_.waitTime,_loc5_);
            delete this.m_activeWFs[param1];
         }
      }
      
      private function zaspGetWaitHandle(param1:String, param2:String) : int
      {
         var _loc3_:Object = new Object();
         _loc3_.type = param1;
         _loc3_.detail = param2;
         waitHandle += 1;
         this.m_waitHandleDict[waitHandle] = _loc3_;
         return waitHandle;
      }
      
      private function zaspGetWaitDetails(param1:int) : Object
      {
         var _loc2_:Object = null;
         if(this.m_waitHandleDict[param1])
         {
         }
         return this.m_waitHandleDict[param1];
      }
      
      private function zaspRemoveWait(param1:int) : void
      {
         delete this.m_waitHandleDict[param1];
      }
      
      private function incrementWaitCounters(param1:String) : void
      {
         ++this.m_numWaits;
         switch(param1)
         {
            case "AMF":
            case "AMF-STP":
               ++this.m_numSTPs;
               break;
            case "DIALOG":
               ++this.m_numDialogs;
               break;
            case "ASSET":
            case "HIPRI_ASSET":
               ++this.m_numLoads;
               break;
            default:
               ++this.m_numUnknownWaits;
         }
      }
      
      public function zaspWaitStart(param1:String, param2:String) : int
      {
         var _loc4_:int = 0;
         var _loc5_:Object = null;
         var _loc6_:* = undefined;
         var _loc7_:Object = null;
         var _loc3_:int = 0;
         if(this.m_active && (param1 != "ASSET" || this.m_userWait == true) && !this.waitsDisabled())
         {
            _loc4_ = this.zaspGetWaitHandle(param1,param2);
            _loc5_ = new Object();
            _loc5_.start = getTimer();
            _loc5_.wfs = new Array();
            _loc5_.detail = param2;
            _loc5_.MD5 = MD5.hash(param2);
            this.m_activeWaits[_loc4_] = _loc5_;
            if(this.m_trackAMFTotalWait || param1 != "AMF")
            {
               ++this.m_numActiveWaits;
               if(!this.m_waitStartTime)
               {
                  this.m_waitStartTime = _loc5_.start;
               }
            }
            if(param1 == "AMF" || param1 == "AMF-STP")
            {
               ++this.m_numActiveSTPWaits;
               if(!this.m_sTPWaitStartTime)
               {
                  this.m_sTPWaitStartTime = _loc5_.start;
               }
            }
            for(_loc6_ in this.m_activeWFs)
            {
               _loc7_ = this.m_activeWFs[_loc6_];
               _loc5_.wfs.push(_loc7_.name);
               _loc7_.waits.push(_loc5_.MD5);
            }
            this.incrementWaitCounters(param1);
            _loc3_ = _loc4_;
         }
         else
         {
            _loc3_ = 0;
         }
         return _loc3_;
      }
      
      private function updateWFs(param1:int) : void
      {
         var _loc2_:* = undefined;
         var _loc3_:Object = null;
         var _loc4_:int = 0;
         for(_loc2_ in this.m_activeWFs)
         {
            _loc3_ = this.m_activeWFs[_loc2_];
            if(_loc3_.waitStartTime != 0)
            {
               _loc3_.waitTime += param1 - _loc3_.waitStartTime;
               _loc3_.waitStartTime = 0;
            }
            else
            {
               _loc4_ = param1 - this.m_waitStartTime;
               _loc3_.waitTime += _loc4_;
            }
         }
      }
      
      private function updateWaitState(param1:int) : void
      {
         if(this.m_numActiveWaits == 0)
         {
            this.updateWFs(param1);
            if(this.m_loadTime != 0)
            {
               this.m_totalWaitTime += param1 - this.m_waitStartTime;
            }
            this.m_waitStartTime = 0;
         }
      }
      
      private function updateSTPWaitState(param1:int) : void
      {
         if(this.m_numActiveSTPWaits == 0)
         {
            this.updateWFs(param1);
            if(this.m_loadTime != 0)
            {
               this.m_sTPWaitTime += param1 - this.m_sTPWaitStartTime;
            }
            this.m_sTPWaitStartTime = 0;
         }
      }
      
      public function zaspWaitEnd(param1:int) : void
      {
         var _loc2_:Object = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:Object = null;
         var _loc6_:String = null;
         var _loc7_:int = 0;
         if(this.m_active)
         {
            _loc2_ = this.m_activeWaits[param1];
            if(_loc2_)
            {
               _loc3_ = getTimer();
               _loc4_ = _loc3_ - _loc2_.start;
               _loc5_ = this.zaspGetWaitDetails(param1);
               if(this.m_trackAMFTotalWait || _loc5_.type != "AMF")
               {
                  --this.m_numActiveWaits;
                  this.updateWaitState(_loc3_);
               }
               if(_loc5_.type == "AMF" || _loc5_.type == "AMF-STP")
               {
                  --this.m_numActiveSTPWaits;
                  this.updateSTPWaitState(_loc3_);
               }
               _loc6_ = "";
               if(_loc2_.wfs.length > 0)
               {
                  _loc6_ = _loc2_.wfs[0];
                  _loc7_ = 1;
                  while(_loc7_ < _loc2_.wfs.length)
                  {
                     _loc6_ = _loc6_ + "," + _loc2_.wfs[_loc7_];
                     _loc7_++;
                  }
               }
               delete this.m_activeWaits[param1];
               this.queueWaitMessage(_loc3_,_loc5_.type,_loc5_.detail,_loc4_,_loc6_,_loc2_.MD5);
               this.zaspRemoveWait(param1);
            }
         }
      }
      
      public function zaspUserWaitStart() : void
      {
         this.m_userWait = true;
      }
      
      public function zaspUserWaitEnd() : void
      {
         this.m_userWait = false;
      }
      
      public function zaspWorkFlowEvent(param1:String, param2:String) : void
      {
         if(this.m_active)
         {
            if(param2 == "BEGIN")
            {
               this.wFStart(param1);
            }
            else if(param2 == "END")
            {
               this.wFEnd(param1);
            }
         }
      }
      
      public function waitStateChange(param1:Boolean, param2:String) : void
      {
         if(this.m_active)
         {
            if(param1)
            {
               this.m_uiWaitHandle = this.zaspWaitStart("JS",param2);
            }
            else if(this.m_uiWaitHandle)
            {
               this.zaspWaitEnd(this.m_uiWaitHandle);
            }
         }
      }
   }
}

