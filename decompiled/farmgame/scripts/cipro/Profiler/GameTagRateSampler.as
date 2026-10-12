package cipro.Profiler
{
   public class GameTagRateSampler implements GameTagSampler
   {
      
      private var firstRawValue:Number;
      
      private var lastRawValue:Number;
      
      private var firstRateSample:Number;
      
      private var lastRateSample:Number;
      
      private var numSamples:int;
      
      private var totalValue:Number;
      
      private var curValue:Number;
      
      private var minRate:Number;
      
      private var tag:GameTagObject;
      
      private var rateTag:GameTagObject;
      
      private var minvalue:Number = NaN;
      
      private var maxvalue:Number = NaN;
      
      private var samplername:String;
      
      private var resetValue:Number;
      
      public function GameTagRateSampler(param1:String, param2:GameTagObject, param3:GameTagObject = null, param4:Number = 0)
      {
         super();
         if(param3 == null)
         {
            throw Error("Must provide a rate tag");
         }
         if(param2.type != GameTagManager.TYPE_COUNT_INT && param2.type != GameTagManager.TYPE_COUNT_NUMBER)
         {
            throw Error("Rates must be based on increasing numbers");
         }
         if(param3.type != GameTagManager.TYPE_COUNT_INT && param3.type != GameTagManager.TYPE_COUNT_NUMBER)
         {
            throw Error("Rates must be based on increasing numbers");
         }
         this.samplername = param1;
         this.tag = param2;
         this.rateTag = param3;
         this.minRate = param4;
         param3.refresh();
         this.firstRateSample = param3.value;
         this.lastRateSample = param3.value;
         param2.refresh();
         this.firstRawValue = param2.value;
         this.lastRawValue = this.firstRawValue;
         this.curValue = 0;
         this.totalValue = 0;
         this.numSamples = 0;
         this.resetValue = 0;
      }
      
      public function average() : Number
      {
         var _loc1_:Number = this.lastRateSample - this.firstRateSample;
         if(_loc1_ != 0)
         {
            return (this.lastRawValue - this.firstRawValue) / _loc1_;
         }
         return 0;
      }
      
      public function min() : Number
      {
         return this.minvalue;
      }
      
      public function max() : Number
      {
         return this.maxvalue;
      }
      
      public function sample() : void
      {
         var _loc1_:Number = this.tag.value;
         var _loc2_:Number = this.rateTag.value;
         var _loc3_:Number = _loc2_ - this.lastRateSample;
         if(_loc3_ != 0)
         {
            this.curValue = (_loc1_ - this.lastRawValue) / _loc3_;
            this.lastRateSample = _loc2_;
            this.lastRawValue = _loc1_;
            ++this.numSamples;
            if(isNaN(this.minvalue))
            {
               this.minvalue = this.curValue;
               this.maxvalue = this.curValue;
            }
            else
            {
               this.minvalue = this.curValue < this.minvalue ? this.curValue : this.minvalue;
               this.maxvalue = this.curValue > this.maxvalue ? this.curValue : this.maxvalue;
            }
         }
      }
      
      public function value() : *
      {
         return this.curValue;
      }
      
      public function name() : String
      {
         return this.samplername;
      }
      
      public function reset() : void
      {
         this.firstRateSample = this.rateTag.value;
         this.lastRateSample = this.firstRateSample;
         this.firstRawValue = this.tag.value;
         this.lastRawValue = this.firstRawValue;
         this.curValue = 0;
         this.numSamples = 0;
         this.minvalue = NaN;
         this.maxvalue = NaN;
      }
   }
}

