package cipro.Profiler
{
   public class RuntimeModule
   {
      
      public static const BUCKET_COUNT:int = 3;
      
      public static const BUCKET1_MINIMUM:int = 0;
      
      public static const BUCKET2_MINIMUM:int = 66;
      
      public static const BUCKET3_MINIMUM:int = 200;
      
      public var name:String = null;
      
      public var category:String = null;
      
      public var totalCountTag:Vector.<GameTagObject> = new Vector.<GameTagObject>();
      
      public var totalFramesTag:Vector.<GameTagObject> = new Vector.<GameTagObject>();
      
      public var totalTimeTag:Vector.<GameTagObject> = new Vector.<GameTagObject>();
      
      public var frameNum:int = -1;
      
      public var bucketTimes:Vector.<Vector.<int>>;
      
      public var bucketFrames:Vector.<Vector.<int>>;
      
      public var bucketLeaves:Vector.<Vector.<int>>;
      
      public var bucketCountTags:Vector.<Vector.<GameTagObject>>;
      
      public var bucketFramesTags:Vector.<Vector.<GameTagObject>>;
      
      public var bucketTimeTags:Vector.<Vector.<GameTagObject>>;
      
      public function RuntimeModule(param1:String, param2:String)
      {
         super();
         this.name = param1;
         this.category = param2;
         this.resetValues();
         this.bucketCountTags = new Vector.<Vector.<GameTagObject>>(BUCKET_COUNT,true);
         this.bucketTimeTags = new Vector.<Vector.<GameTagObject>>(BUCKET_COUNT,true);
         this.bucketFramesTags = new Vector.<Vector.<GameTagObject>>(BUCKET_COUNT,true);
         var _loc3_:int = 0;
         while(_loc3_ < BUCKET_COUNT)
         {
            this.bucketFramesTags[_loc3_] = new Vector.<GameTagObject>();
            this.bucketCountTags[_loc3_] = new Vector.<GameTagObject>();
            this.bucketTimeTags[_loc3_] = new Vector.<GameTagObject>();
            _loc3_++;
         }
         GameTagManager.registerAddModeCallback(this.updateModes);
         this.updateModes();
      }
      
      public function resetValues() : void
      {
         var _loc3_:int = 0;
         var _loc1_:int = int(GameTagManager.getAllGameModes().length);
         if(!this.bucketTimes)
         {
            this.bucketTimes = new Vector.<Vector.<int>>(BUCKET_COUNT,true);
         }
         if(!this.bucketLeaves)
         {
            this.bucketLeaves = new Vector.<Vector.<int>>(BUCKET_COUNT,true);
         }
         if(!this.bucketFrames)
         {
            this.bucketFrames = new Vector.<Vector.<int>>(BUCKET_COUNT,true);
         }
         var _loc2_:int = 0;
         while(_loc2_ < BUCKET_COUNT)
         {
            if(!this.bucketTimes[_loc2_])
            {
               this.bucketTimes[_loc2_] = new Vector.<int>();
            }
            if(!this.bucketLeaves[_loc2_])
            {
               this.bucketLeaves[_loc2_] = new Vector.<int>();
            }
            if(!this.bucketFrames[_loc2_])
            {
               this.bucketFrames[_loc2_] = new Vector.<int>();
            }
            this.bucketTimes[_loc2_].length = _loc1_;
            this.bucketLeaves[_loc2_].length = _loc1_;
            this.bucketFrames[_loc2_].length = _loc1_;
            _loc3_ = 0;
            while(_loc3_ < _loc1_)
            {
               this.bucketTimes[_loc2_][_loc3_] = 0;
               this.bucketLeaves[_loc2_][_loc3_] = 0;
               this.bucketFrames[_loc2_][_loc3_] = 0;
               _loc3_++;
            }
            _loc2_++;
         }
      }
      
      public function getTotalTimeFunction(param1:int) : Function
      {
         var mode:int = param1;
         return function():int
         {
            var _loc1_:* = 0;
            var _loc2_:* = 0;
            while(_loc2_ < BUCKET_COUNT)
            {
               _loc1_ += bucketTimes[_loc2_][mode];
               _loc2_++;
            }
            return _loc1_;
         };
      }
      
      public function getTotalLeaveFunction(param1:int) : Function
      {
         var mode:int = param1;
         return function():int
         {
            var _loc1_:* = 0;
            var _loc2_:* = 0;
            while(_loc2_ < BUCKET_COUNT)
            {
               _loc1_ += bucketLeaves[_loc2_][mode];
               _loc2_++;
            }
            return _loc1_;
         };
      }
      
      public function getTotalFramesFunction(param1:int) : Function
      {
         var mode:int = param1;
         return function():int
         {
            var _loc1_:* = 0;
            var _loc2_:* = 0;
            while(_loc2_ < BUCKET_COUNT)
            {
               _loc1_ += bucketFrames[_loc2_][mode];
               _loc2_++;
            }
            return _loc1_;
         };
      }
      
      public function getFromVectorFunction(param1:Vector.<int>, param2:int) : Function
      {
         var vector:Vector.<int> = param1;
         var mode:int = param2;
         return function():int
         {
            return vector[mode];
         };
      }
      
      public function getBucketTimeFunction(param1:int, param2:int) : Function
      {
         return this.getFromVectorFunction(this.bucketTimes[param1],param2);
      }
      
      public function getBucketFramesFunction(param1:int, param2:int) : Function
      {
         return this.getFromVectorFunction(this.bucketFrames[param1],param2);
      }
      
      public function getBucketLeaveFunction(param1:int, param2:int) : Function
      {
         return this.getFromVectorFunction(this.bucketLeaves[param1],param2);
      }
      
      public function updateModes(param1:String = null) : void
      {
         var _loc2_:Vector.<String> = GameTagManager.getAllGameModes();
         var _loc3_:int = int(_loc2_.length);
         var _loc4_:int = int(this.totalCountTag.length);
         this.totalCountTag.length = _loc3_;
         this.totalTimeTag.length = _loc3_;
         this.totalFramesTag.length = _loc3_;
         var _loc5_:int = 0;
         while(_loc5_ < BUCKET_COUNT)
         {
            this.bucketTimes[_loc5_].length = _loc3_;
            this.bucketLeaves[_loc5_].length = _loc3_;
            this.bucketFrames[_loc5_].length = _loc3_;
            this.bucketCountTags[_loc5_].length = _loc3_;
            this.bucketTimeTags[_loc5_].length = _loc3_;
            this.bucketFramesTags[_loc5_].length = _loc3_;
            _loc5_++;
         }
         var _loc6_:int = _loc4_;
         while(_loc6_ < _loc3_)
         {
            this.totalCountTag[_loc6_] = GameTagManager.registerGameTag("Mode:" + _loc2_[_loc6_] + ":" + this.name + ".count",this.getTotalLeaveFunction(_loc6_),GameTagManager.TYPE_COUNT_INT,GameTagManager.UPDATE_POLLING);
            this.totalTimeTag[_loc6_] = GameTagManager.registerGameTag("Mode:" + _loc2_[_loc6_] + ":" + this.name + ".time",this.getTotalTimeFunction(_loc6_),GameTagManager.TYPE_COUNT_INT,GameTagManager.UPDATE_POLLING);
            this.totalFramesTag[_loc6_] = GameTagManager.registerGameTag("Mode:" + _loc2_[_loc6_] + ":" + this.name + ".frames",this.getTotalFramesFunction(_loc6_),GameTagManager.TYPE_COUNT_INT,GameTagManager.UPDATE_POLLING);
            _loc5_ = 0;
            while(_loc5_ < BUCKET_COUNT)
            {
               this.bucketCountTags[_loc5_][_loc6_] = GameTagManager.registerGameTag("Mode:" + _loc2_[_loc6_] + ":" + this.name + ".bucket" + (1 + _loc5_).toString() + ".count",this.getBucketLeaveFunction(_loc5_,_loc6_),GameTagManager.TYPE_COUNT_INT,GameTagManager.UPDATE_POLLING);
               this.bucketTimeTags[_loc5_][_loc6_] = GameTagManager.registerGameTag("Mode:" + _loc2_[_loc6_] + ":" + this.name + ".bucket" + (1 + _loc5_).toString() + ".time",this.getBucketTimeFunction(_loc5_,_loc6_),GameTagManager.TYPE_COUNT_INT,GameTagManager.UPDATE_POLLING);
               this.bucketFramesTags[_loc5_][_loc6_] = GameTagManager.registerGameTag("Mode:" + _loc2_[_loc6_] + ":" + this.name + ".bucket" + (1 + _loc5_).toString() + ".frames",this.getBucketFramesFunction(_loc5_,_loc6_),GameTagManager.TYPE_COUNT_INT,GameTagManager.UPDATE_POLLING);
               _loc5_++;
            }
            _loc6_++;
         }
      }
   }
}

