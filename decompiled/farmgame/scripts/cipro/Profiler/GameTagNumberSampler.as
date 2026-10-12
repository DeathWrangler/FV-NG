package cipro.Profiler
{
   public class GameTagNumberSampler implements GameTagSampler
   {
      
      private var numSamples:int;
      
      private var totalValue:Number;
      
      private var curValue:Number;
      
      private var minRate:Number;
      
      private var tag:GameTagObject;
      
      private var minvalue:Number = NaN;
      
      private var maxvalue:Number = NaN;
      
      private var samplername:String;
      
      private var resetValue:Number;
      
      public function GameTagNumberSampler(param1:String, param2:GameTagObject, param3:Number = 0)
      {
         super();
         if(param2.type == GameTagManager.TYPE_STRING)
         {
            throw Error("Sampled Numbers must be some sort of number");
         }
         this.samplername = param1;
         this.tag = param2;
         this.minRate = param3;
         param2.refresh();
         this.curValue = 0;
         this.totalValue = 0;
         this.numSamples = 0;
         this.resetValue = 0;
      }
      
      public function average() : Number
      {
         if(this.numSamples != 0)
         {
            return this.totalValue / this.numSamples;
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
         this.curValue = this.tag.value - this.resetValue;
         this.totalValue += this.curValue;
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
         ++this.numSamples;
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
         this.tag.refresh();
         switch(this.tag.type)
         {
            case GameTagManager.TYPE_COUNT_INT:
            case GameTagManager.TYPE_COUNT_NUMBER:
               this.resetValue = this.tag.value;
               break;
            case GameTagManager.TYPE_INTEGER:
            case GameTagManager.TYPE_NUMBER:
               this.resetValue = 0;
         }
         this.curValue = 0;
         this.totalValue = 0;
         this.numSamples = 0;
         this.minvalue = NaN;
         this.maxvalue = NaN;
      }
   }
}

