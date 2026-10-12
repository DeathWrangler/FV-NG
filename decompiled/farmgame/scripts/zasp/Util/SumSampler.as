package zasp.Util
{
   public class SumSampler implements Sampler
   {
      
      private var cutoffSum_:Number;
      
      private var runningSum_:Number;
      
      private var samples_:CircularBuffer = new CircularBuffer(0);
      
      public function SumSampler(param1:Number)
      {
         super();
         this.cutoffSum_ = param1;
         this.runningSum_ = 0;
      }
      
      public static function test() : void
      {
         var _loc1_:SumSampler = new SumSampler(50);
         if(0 != _loc1_.length)
         {
            throw new Error("");
         }
         if(Math.abs(_loc1_.value - 0) > 0.01)
         {
            throw new Error("");
         }
         _loc1_.sample(10.1);
         _loc1_.sample(15.2);
         _loc1_.sample(20.3);
         if(3 != _loc1_.length)
         {
            throw new Error("");
         }
         if(Math.abs(_loc1_.value - 45.6) > 0.01)
         {
            throw new Error("");
         }
         _loc1_.sample(5);
         if(4 != _loc1_.length)
         {
            throw new Error("");
         }
         if(Math.abs(_loc1_.value - 50.6) > 0.01)
         {
            throw new Error("");
         }
         _loc1_.sample(0);
         _loc1_.sample(0);
         _loc1_.sample(0);
         if(7 != _loc1_.length)
         {
            throw new Error("");
         }
         if(Math.abs(_loc1_.value - 50.6) > 0.01)
         {
            throw new Error("");
         }
         _loc1_.sample(3.3);
         if(8 != _loc1_.length)
         {
            throw new Error("");
         }
         if(Math.abs(_loc1_.value - 53.9) > 0.01)
         {
            throw new Error("");
         }
         _loc1_.sample(7);
         if(8 != _loc1_.length)
         {
            throw new Error("");
         }
         if(Math.abs(_loc1_.value - 50.8) > 0.01)
         {
            throw new Error("");
         }
         if(15.2 != _loc1_.sampleAt(0))
         {
            throw new Error("");
         }
         if(20.3 != _loc1_.sampleAt(1))
         {
            throw new Error("");
         }
         if(5 != _loc1_.sampleAt(2))
         {
            throw new Error("");
         }
         if(0 != _loc1_.sampleAt(3))
         {
            throw new Error("");
         }
         if(0 != _loc1_.sampleAt(4))
         {
            throw new Error("");
         }
         if(0 != _loc1_.sampleAt(5))
         {
            throw new Error("");
         }
         if(3.3 != _loc1_.sampleAt(6))
         {
            throw new Error("");
         }
         if(7 != _loc1_.sampleAt(7))
         {
            throw new Error("");
         }
         _loc1_.sample(123.4);
         if(1 != _loc1_.length)
         {
            throw new Error("");
         }
         if(Math.abs(_loc1_.value - 123.4) > 0.01)
         {
            throw new Error("");
         }
         _loc1_.sample(49);
         if(2 != _loc1_.length)
         {
            throw new Error("");
         }
         if(Math.abs(_loc1_.value - 172.4) > 0.01)
         {
            throw new Error("");
         }
         _loc1_.sample(1.1);
         if(2 != _loc1_.length)
         {
            throw new Error("");
         }
         if(Math.abs(_loc1_.value - 50.1) > 0.01)
         {
            throw new Error("");
         }
      }
      
      public function sample(param1:Number) : void
      {
         var _loc2_:Number = NaN;
         if(this.samples_.length >= this.samples_.capacity)
         {
            this.samples_.capacity = 1 + 1.3 * this.samples_.capacity;
         }
         this.samples_.push(param1);
         this.runningSum_ += param1;
         while(this.samples_.length > 0)
         {
            _loc2_ = this.samples_.elementAt(0) as Number;
            if(this.runningSum_ - _loc2_ < this.cutoffSum_)
            {
               break;
            }
            this.samples_.pop();
            this.runningSum_ -= _loc2_;
         }
      }
      
      public function get value() : Number
      {
         return this.runningSum_;
      }
      
      public function get length() : int
      {
         return this.samples_.length;
      }
      
      public function sampleAt(param1:int) : Number
      {
         return this.samples_.elementAt(param1) as Number;
      }
   }
}

