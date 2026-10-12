package Engine.Profiler
{
   import Engine.Managers.StatsManager;
   import cipro.Profiler.FrameEntryInfo;
   import cipro.Profiler.GameTagManager;
   import cipro.Profiler.RuntimeModule;
   import cipro.Profiler.RuntimeProfiler;
   import com.adobe.serialization.json.JSON;
   import flash.external.ExternalInterface;
   import flash.utils.Dictionary;
   
   public class ProdAggregator
   {
      
      private static const CIPRO_RUNTIME_STRING1:String = "CIPRO-Module-1";
      
      private static const CIPRO_SAMPLER_STRING1:String = "CIPRO-Sampler-1";
      
      private static const CIPRO_COUNTER_STRING1:String = "CIPRO-Counter-1";
      
      private static var s_updateInterval:int = 5000;
      
      private static var s_statUpdateInterval:int = 30;
      
      private static var s_statFlushInterval:int = 60;
      
      private static var s_uid:int = 0;
      
      private static var s_session_id:String = "SessionId";
      
      public static var s_ProdModeBucketAggregatorSets:Vector.<Vector.<int>> = null;
      
      public static var s_ProdModuleAggregatorSet:int = -1;
      
      private static var s_RuntimeModeModules:Vector.<Dictionary> = new Vector.<Dictionary>();
      
      private static var s_ModeSamplers:Vector.<Vector.<ProdAggrRuntimeModeSampler>> = null;
      
      private static var s_counterModeSamplers:Vector.<ProdAggrCounterModeSampler> = null;
      
      private static var s_samplers:Array = [];
      
      private static var s_countSamplers:Array = [];
      
      private static var s_deferredSamplers:Array = [];
      
      private static var s_statsToSampleConfig:Object = {};
      
      private static var s_enabled:Boolean = false;
      
      private static var s_ztrackEnabled:Boolean = false;
      
      private static var s_lastUpdate:int = 0;
      
      public function ProdAggregator()
      {
         super();
         throw Error("ProdAggregator is a static");
      }
      
      public static function enable(param1:Object) : void
      {
         var config:Object = null;
         var modeStat:Object = null;
         var stat:Object = null;
         var parameters:Object = param1;
         if(!s_enabled && parameters.hasOwnProperty("CiproToProd") && parameters.CiproToProd == "true" && parameters.hasOwnProperty("fb_sig_user"))
         {
            PlaytimeMonitor.enable();
            s_uid = parameters.fb_sig_user;
            s_enabled = true;
            s_ztrackEnabled = false;
            config = null;
            try
            {
               config = ExternalInterface.call("getCiproConfig");
            }
            catch(e:Error)
            {
               config = {};
            }
            if(config.hasOwnProperty("CiproToProdUpdateRate") && config.CiproToProdUpdateRate > 0)
            {
               s_updateInterval = config.CiproToProdUpdateRate;
            }
            if(config.hasOwnProperty("CiproToProdStatUpdateRate") && config.CiproToProdStatUpdateRate > 0)
            {
               s_statUpdateInterval = config.CiproToProdStatUpdateRate;
            }
            if(config.hasOwnProperty("CiproToProdStatFlushRate") && config.CiproToProdStatFlushRate > 0)
            {
               s_statFlushInterval = config.CiproToProdStatFlushRate;
            }
            if(config.hasOwnProperty("CiproStatsToSampleConfig") && config.CiproStatsToSampleConfig != "")
            {
               try
               {
                  s_statsToSampleConfig = com.adobe.serialization.json.JSON.decode(config.CiproStatsToSampleConfig);
               }
               catch(e:Error)
               {
                  s_statsToSampleConfig = {};
               }
            }
            RuntimeProfiler.enable(true);
            s_session_id = Math.random().toString();
            s_ProdModuleAggregatorSet = GameTagManager.registerSamplerSet("ProdModuleAggregator");
            s_ModeSamplers = new Vector.<Vector.<ProdAggrRuntimeModeSampler>>();
            s_ProdModeBucketAggregatorSets = new Vector.<Vector.<int>>();
            s_counterModeSamplers = new Vector.<ProdAggrCounterModeSampler>();
            GameTagManager.registerAddModeCallback(updateGameModes);
            RuntimeProfiler.registerAddModuleCallback(updateRuntimeModules);
            updateGameModes();
            if(Boolean(s_statsToSampleConfig) && s_statsToSampleConfig.hasOwnProperty("ModeSamplers"))
            {
               for each(modeStat in s_statsToSampleConfig.ModeSamplers)
               {
                  if(modeStat.hasOwnProperty("tagName"))
                  {
                     addModeSampler(modeStat.tagName,modeStat.hasOwnProperty("rateName") ? modeStat.rateName : null,modeStat.hasOwnProperty("scale") ? Number(modeStat.scale) : 1);
                  }
               }
            }
            if(Boolean(s_statsToSampleConfig) && s_statsToSampleConfig.hasOwnProperty("CountSamplers"))
            {
               for each(stat in s_statsToSampleConfig.CountSamplers)
               {
                  if(stat.hasOwnProperty("tagName") && stat.hasOwnProperty("gameMode") && stat.hasOwnProperty("calcFunc"))
                  {
                     addCountSampler(stat.calcFunc,stat.hasOwnProperty("kingdom") ? stat.kingdom : "",stat.hasOwnProperty("phylum") ? stat.phylum : "",stat.gameMode,stat.tagName,stat.hasOwnProperty("rateName") ? stat.rateName : null,stat.hasOwnProperty("minimum") ? Number(stat.minimum) : Number.NaN,stat.hasOwnProperty("maximum") ? Number(stat.maximum) : Number.NaN,stat.hasOwnProperty("scale") ? Number(stat.scale) : 1);
                  }
               }
            }
            RuntimeProfiler.addFrameFilter(frameFilter);
         }
      }
      
      public static function enableZtrack(param1:Boolean) : void
      {
         s_ztrackEnabled = param1;
      }
      
      public static function frameFilter(param1:int, param2:int, param3:int, param4:Vector.<FrameEntryInfo>) : void
      {
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:Vector.<int> = null;
         var _loc11_:Vector.<String> = null;
         var _loc12_:Array = null;
         var _loc13_:ProdAggrCounterModeSampler = null;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:ProdAggrRuntimeModeModule = null;
         var _loc18_:ProdAggrRuntimeModeSampler = null;
         var _loc5_:int = param4[param3].time;
         var _loc6_:Vector.<int> = GameTagManager.CurrentGameModes();
         if(param1 > RuntimeModule.BUCKET3_MINIMUM)
         {
            _loc8_ = 2;
         }
         else if(param1 > RuntimeModule.BUCKET2_MINIMUM)
         {
            _loc8_ = 1;
         }
         else
         {
            _loc8_ = 0;
         }
         for each(_loc9_ in _loc6_)
         {
            _loc10_ = s_ProdModeBucketAggregatorSets[_loc9_];
            GameTagManager.refreshSamplerSet(_loc10_[_loc8_]);
            GameTagManager.sampleSamplerSet(_loc10_[_loc8_]);
            GameTagManager.refreshSamplerSet(_loc10_[RuntimeModule.BUCKET_COUNT]);
            GameTagManager.sampleSamplerSet(_loc10_[RuntimeModule.BUCKET_COUNT]);
         }
         if(s_ztrackEnabled && _loc5_ >= s_lastUpdate + s_updateInterval)
         {
            _loc11_ = GameTagManager.getAllGameModes();
            s_lastUpdate = _loc5_;
            GameTagManager.refreshSamplerSet(s_ProdModuleAggregatorSet);
            GameTagManager.sampleSamplerSet(s_ProdModuleAggregatorSet);
            _loc12_ = new Array();
            _loc7_ = 0;
            while(_loc7_ < _loc11_.length)
            {
               _loc14_ = (s_RuntimeModeModules[_loc7_]["Actionscript"] as ProdAggrRuntimeModeModule).bucketTime(0) * 0.01;
               _loc15_ = (s_RuntimeModeModules[_loc7_]["Actionscript"] as ProdAggrRuntimeModeModule).bucketTime(1) * 0.01;
               _loc16_ = (s_RuntimeModeModules[_loc7_]["Actionscript"] as ProdAggrRuntimeModeModule).bucketTime(2) * 0.01;
               if(_loc14_ > 0 || _loc15_ > 0 || _loc16_ > 0)
               {
                  if(_loc14_ == 0)
                  {
                     _loc14_ = Number.MAX_VALUE;
                  }
                  if(_loc15_ == 0)
                  {
                     _loc15_ = Number.MAX_VALUE;
                  }
                  if(_loc16_ == 0)
                  {
                     _loc16_ = Number.MAX_VALUE;
                  }
                  for each(_loc17_ in s_RuntimeModeModules[_loc7_])
                  {
                     if(_loc17_.bucketTime(0) > _loc14_ || _loc17_.bucketTime(1) > _loc15_ || _loc17_.bucketTime(2) > _loc16_)
                     {
                        StatsManager.count_dtl_batch(_loc12_,CIPRO_RUNTIME_STRING1,s_session_id,_loc17_.mode,_loc17_.module,_loc17_.bucketFrameCount(0).toString(),_loc17_.bucketFrameCount(1).toString(),_loc17_.bucketFrameCount(2).toString(),"s8",_loc17_.bucketTime(0),_loc17_.bucketCount(0),_loc17_.bucketTime(1),_loc17_.bucketCount(1),_loc17_.bucketTime(2),_loc17_.bucketCount(2),7,8);
                     }
                  }
                  for each(_loc18_ in s_ModeSamplers[_loc7_])
                  {
                     if(_loc18_.valid())
                     {
                        if(_loc18_.isStringSampler())
                        {
                           StatsManager.count_dtl_batch(_loc12_,CIPRO_SAMPLER_STRING1,s_session_id,_loc18_.mode,_loc18_.tagName,_loc18_.rateName,_loc18_.bucketValue(0),_loc18_.bucketValue(1),_loc18_.bucketValue(2),0,0,0,0,0,0,0,0);
                        }
                        else
                        {
                           StatsManager.count_dtl_batch(_loc12_,CIPRO_SAMPLER_STRING1,s_session_id,_loc18_.mode,_loc18_.tagName,_loc18_.rateName,_loc18_.bucketMax(0).toString(),_loc18_.bucketMax(1).toString(),_loc18_.bucketMax(2).toString(),_loc18_.bucketValue(0),_loc18_.bucketAverage(0),_loc18_.bucketValue(1),_loc18_.bucketAverage(1),_loc18_.bucketValue(2),_loc18_.bucketAverage(2),_loc18_.bucketValue(3),_loc18_.bucketAverage(3));
                        }
                     }
                  }
               }
               _loc7_++;
            }
            for each(_loc13_ in s_counterModeSamplers)
            {
               if(_loc13_.valid())
               {
                  StatsManager.count_batch(_loc12_,CIPRO_COUNTER_STRING1,_loc13_.kingdom,_loc13_.phylum,_loc13_.mode,_loc13_.tagName,_loc13_.rateName ? _loc13_.rateName : "",_loc13_.counterValue());
               }
            }
            StatsManager.deferredTrack(_loc12_,s_session_id,s_statUpdateInterval,s_statFlushInterval,s_uid);
         }
      }
      
      public static function updateGameModes(param1:String = null) : void
      {
         var _loc7_:String = null;
         var _loc8_:Object = null;
         var _loc2_:Vector.<String> = GameTagManager.getAllGameModes();
         var _loc3_:Object = RuntimeProfiler.getAllStandardSections();
         var _loc4_:int = int(_loc2_.length);
         var _loc5_:int = int(s_RuntimeModeModules.length);
         s_RuntimeModeModules.length = _loc4_;
         var _loc6_:int = _loc5_;
         while(_loc6_ < _loc4_)
         {
            s_ProdModeBucketAggregatorSets[_loc6_] = new Vector.<int>(RuntimeModule.BUCKET_COUNT + 1,true);
            s_ProdModeBucketAggregatorSets[_loc6_][0] = GameTagManager.registerSamplerSet("ProdAggregatorBucket1:" + _loc2_[_loc6_]);
            s_ProdModeBucketAggregatorSets[_loc6_][1] = GameTagManager.registerSamplerSet("ProdAggregatorBucket2:" + _loc2_[_loc6_]);
            s_ProdModeBucketAggregatorSets[_loc6_][2] = GameTagManager.registerSamplerSet("ProdAggregatorBucket3:" + _loc2_[_loc6_]);
            s_ProdModeBucketAggregatorSets[_loc6_][3] = GameTagManager.registerSamplerSet("ProdAggregator:" + _loc2_[_loc6_]);
            s_RuntimeModeModules[_loc6_] = new Dictionary();
            s_ModeSamplers[_loc6_] = new Vector.<ProdAggrRuntimeModeSampler>();
            for each(_loc7_ in _loc3_)
            {
               s_RuntimeModeModules[_loc6_][_loc7_] = new ProdAggrRuntimeModeModule(_loc2_[_loc6_],_loc7_);
            }
            for each(_loc8_ in s_samplers)
            {
               s_ModeSamplers[_loc6_].push(new ProdAggrRuntimeModeSampler(_loc2_[_loc6_],s_ProdModeBucketAggregatorSets[_loc6_],_loc8_.tag,_loc8_.rate));
            }
            _loc6_++;
         }
      }
      
      public static function updateRuntimeModules(param1:String = null) : void
      {
         var _loc2_:Vector.<String> = GameTagManager.getAllGameModes();
         var _loc3_:int = int(_loc2_.length);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            s_RuntimeModeModules[_loc4_][param1] = new ProdAggrRuntimeModeModule(_loc2_[_loc4_],param1);
            _loc4_++;
         }
      }
      
      public static function addModeSampler(param1:String, param2:String = null, param3:Number = 1) : void
      {
         var _loc4_:Vector.<String> = GameTagManager.getAllGameModes();
         s_samplers.push({
            "tag":param1,
            "rate":param2,
            "scale":param3
         });
         var _loc5_:int = 0;
         while(_loc5_ < s_ModeSamplers.length)
         {
            s_ModeSamplers[_loc5_].push(new ProdAggrRuntimeModeSampler(_loc4_[_loc5_],s_ProdModeBucketAggregatorSets[_loc5_],param1,param2,param3));
            _loc5_++;
         }
      }
      
      public static function addCountSampler(param1:String, param2:String, param3:String, param4:String, param5:String, param6:String = null, param7:Number = NaN, param8:Number = NaN, param9:Number = 1) : void
      {
         var _loc10_:Vector.<String> = GameTagManager.getAllGameModes();
         s_countSamplers.push({
            "calcFunc":param1,
            "tag":param5,
            "rate":param6,
            "mode":param4,
            "kingdom":param2,
            "phylum":param3,
            "minimum":param7,
            "maximimum":param8,
            "scale":param9
         });
         var _loc11_:int = 0;
         while(_loc11_ < _loc10_.length)
         {
            if(_loc10_[_loc11_] == param4)
            {
               s_counterModeSamplers.push(new ProdAggrCounterModeSampler(param1,param2,param3,param4,s_ProdModeBucketAggregatorSets[_loc11_],param5,param6,param7,param8,param9));
            }
            _loc11_++;
         }
      }
      
      public static function get enabled() : Boolean
      {
         return s_enabled;
      }
   }
}

import cipro.Profiler.GameTagManager;
import cipro.Profiler.GameTagSampler;
import cipro.Profiler.GameTagStringSampler;
import cipro.Profiler.RuntimeModule;

class ProdAggrRuntimeModeModule
{
   
   public var mode:String;
   
   public var module:String;
   
   protected var m_bucketTimes:Vector.<GameTagSampler>;
   
   protected var m_bucketCounts:Vector.<GameTagSampler>;
   
   protected var m_bucketFrames:Vector.<GameTagSampler>;
   
   public function ProdAggrRuntimeModeModule(param1:String, param2:String)
   {
      super();
      this.mode = param1;
      this.module = param2;
      if(param2.length > 45)
      {
         throw Error("Module name is too long" + param2);
      }
      this.m_bucketTimes = new Vector.<GameTagSampler>(RuntimeModule.BUCKET_COUNT,true);
      this.m_bucketCounts = new Vector.<GameTagSampler>(RuntimeModule.BUCKET_COUNT,true);
      this.m_bucketFrames = new Vector.<GameTagSampler>(RuntimeModule.BUCKET_COUNT,true);
      var _loc3_:int = 0;
      while(_loc3_ < RuntimeModule.BUCKET_COUNT)
      {
         this.m_bucketTimes[_loc3_] = GameTagManager.registerSampler(ProdAggregator.s_ProdModuleAggregatorSet,"Mode:" + this.mode + ":" + this.module + ".bucket" + (_loc3_ + 1).toString() + ".time");
         this.m_bucketCounts[_loc3_] = GameTagManager.registerSampler(ProdAggregator.s_ProdModuleAggregatorSet,"Mode:" + this.mode + ":" + this.module + ".bucket" + (_loc3_ + 1).toString() + ".count");
         this.m_bucketFrames[_loc3_] = GameTagManager.registerSampler(ProdAggregator.s_ProdModuleAggregatorSet,"Mode:" + this.mode + ":" + this.module + ".bucket" + (_loc3_ + 1).toString() + ".frames");
         _loc3_++;
      }
   }
   
   public function bucketTime(param1:int) : Number
   {
      return this.m_bucketTimes[param1].value();
   }
   
   public function bucketCount(param1:int) : Number
   {
      return this.m_bucketCounts[param1].value();
   }
   
   public function bucketFrameCount(param1:int) : Number
   {
      return this.m_bucketFrames[param1].value();
   }
}

class ProdAggrRuntimeModeSampler
{
   
   public var mode:String;
   
   public var tagName:String;
   
   public var rateName:String;
   
   public var bucketSets:Vector.<int>;
   
   public var bucketTags:Vector.<GameTagSampler>;
   
   public var scale:Number;
   
   public function ProdAggrRuntimeModeSampler(param1:String, param2:Vector.<int>, param3:String, param4:String = null, param5:Number = 1)
   {
      super();
      if(param3.length > 45)
      {
         throw Error("tag name is too long" + param3);
      }
      if(Boolean(param4) && param4.length > 45)
      {
         throw Error("Rate name is too long" + param4);
      }
      if(Boolean(param1) && param1.length > 45)
      {
         throw Error("Mode name is too long" + param4);
      }
      if(isNaN(param5) || param5 == 0)
      {
         throw Error("Invalid scale");
      }
      this.mode = param1;
      this.bucketSets = param2;
      this.bucketTags = new Vector.<GameTagSampler>(this.bucketSets.length,true);
      this.tagName = param3;
      this.rateName = param4;
      this.scale = param5;
      if(!this.registerSamplers())
      {
         GameTagManager.registerAddTagCallback(this.registerSamplers);
      }
   }
   
   public function isStringSampler() : Boolean
   {
      return Boolean(this.bucketTags[0]) && this.bucketTags[0] is GameTagStringSampler;
   }
   
   protected function registerSamplers(param1:String = null) : Boolean
   {
      var _loc2_:Boolean = true;
      var _loc3_:int = 0;
      while(_loc3_ <= RuntimeModule.BUCKET_COUNT)
      {
         if(!this.bucketTags[_loc3_])
         {
            this.bucketTags[_loc3_] = GameTagManager.registerSampler(this.bucketSets[_loc3_],this.tagName,this.rateName);
            if(!this.bucketTags[_loc3_])
            {
               _loc2_ = false;
            }
         }
         _loc3_++;
      }
      return _loc2_;
   }
   
   public function bucketValue(param1:int) : *
   {
      return this.bucketTags[param1].value();
   }
   
   public function bucketAverage(param1:int) : Number
   {
      return this.bucketTags[param1].average();
   }
   
   public function bucketMax(param1:int) : Number
   {
      var _loc2_:Number = Number(this.bucketTags[param1].max());
      return isNaN(_loc2_) ? NaN : _loc2_ * this.scale;
   }
   
   public function bucketMin(param1:int) : Number
   {
      var _loc2_:Number = Number(this.bucketTags[param1].min());
      return isNaN(_loc2_) ? NaN : _loc2_ * this.scale;
   }
   
   public function valid() : Boolean
   {
      return true;
   }
}

class ProdAggrCounterModeSampler extends ProdAggrRuntimeModeSampler
{
   
   public static const CALC_BY_AVERAGE:String = "average";
   
   public static const CALC_BY_VALUE:String = "value";
   
   public static const CALC_BY_MAX:String = "max";
   
   public static const CALC_BY_MIN:String = "min";
   
   public var minimum:Number;
   
   public var maximum:Number;
   
   public var kingdom:String;
   
   public var phylum:String;
   
   private var calcFunc:Function;
   
   protected var counterBucket:int = RuntimeModule.BUCKET_COUNT;
   
   public function ProdAggrCounterModeSampler(param1:String, param2:String, param3:String, param4:String, param5:Vector.<int>, param6:String, param7:String = null, param8:Number = NaN, param9:Number = NaN, param10:Number = 1)
   {
      super(param4,param5,param6,param7,param10);
      if(Boolean(param2) && param2.length > 45)
      {
         throw Error("Kingdom name is too long" + param7);
      }
      if(Boolean(param3) && param3.length > 45)
      {
         throw Error("Phylum name is too long" + param7);
      }
      this.minimum = param8;
      this.maximum = param9;
      this.kingdom = param2;
      this.phylum = param3;
      this.calcFunc = bucketAverage;
      switch(param1)
      {
         case CALC_BY_AVERAGE:
            this.calcFunc = bucketAverage;
            break;
         case CALC_BY_VALUE:
            this.calcFunc = bucketValue;
            break;
         case CALC_BY_MAX:
            this.calcFunc = bucketMax;
            break;
         case CALC_BY_MIN:
            this.calcFunc = bucketMin;
      }
   }
   
   override public function valid() : Boolean
   {
      var _loc1_:Number = Number(this.counterValue());
      if(!isNaN(this.minimum) && _loc1_ < this.minimum)
      {
         return false;
      }
      if(!isNaN(this.maximum) && _loc1_ > this.maximum)
      {
         return false;
      }
      return true;
   }
   
   public function counterValue() : Number
   {
      return this.calcFunc(this.counterBucket);
   }
   
   override protected function registerSamplers(param1:String = null) : Boolean
   {
      var _loc2_:Boolean = true;
      if(!bucketTags[this.counterBucket])
      {
         bucketTags[this.counterBucket] = GameTagManager.registerSampler(bucketSets[this.counterBucket],tagName,rateName);
         if(!bucketTags[this.counterBucket])
         {
            _loc2_ = false;
         }
      }
      return _loc2_;
   }
}
