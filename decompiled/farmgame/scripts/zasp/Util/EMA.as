package zasp.Util
{
   public class EMA implements Sampler
   {
      
      private var alpha_:Number = 0;
      
      private var value_:Number = 0;
      
      private var hasValue_:Boolean = false;
      
      public function EMA(param1:Number)
      {
         super();
         if(param1 < 0 || param1 > 1)
         {
            throw new Error("alpha " + param1 + " not in [0..1]");
         }
         this.alpha_ = param1;
         this.value_ = 0;
         this.hasValue_ = false;
      }
      
      public function sample(param1:Number) : void
      {
         if(!this.hasValue)
         {
            this.value_ = param1;
            this.hasValue_ = true;
         }
         else
         {
            this.value_ = this.alpha * param1 + (1 - this.alpha) * this.value_;
         }
      }
      
      public function get hasValue() : Boolean
      {
         return this.hasValue_;
      }
      
      public function get value() : Number
      {
         if(!this.hasValue_)
         {
            return 0;
         }
         return this.value_;
      }
      
      public function get alpha() : Number
      {
         return this.alpha_;
      }
   }
}

