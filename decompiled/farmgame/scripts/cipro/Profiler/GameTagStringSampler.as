package cipro.Profiler
{
   public class GameTagStringSampler implements GameTagSampler
   {
      
      private var curValue:String;
      
      private var tag:GameTagObject;
      
      private var samplername:String;
      
      private var minRate:Number;
      
      public function GameTagStringSampler(param1:String, param2:GameTagObject, param3:Number = 0)
      {
         super();
         if(param2.type != GameTagManager.TYPE_STRING)
         {
            throw Error("Sampled Strings must be strings");
         }
         this.samplername = param1;
         this.tag = param2;
         this.minRate = param3;
         param2.refresh();
         this.curValue = param2.value;
      }
      
      public function average() : Number
      {
         throw Error("We don\'t average strings");
      }
      
      public function min() : Number
      {
         throw Error("We don\'t min strings");
      }
      
      public function max() : Number
      {
         throw Error("We don\'t max strings");
      }
      
      public function sample() : void
      {
         this.curValue = this.tag.value;
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
         throw new Error("String samplers cannot be reset");
      }
   }
}

