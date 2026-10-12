package zasp.Util
{
   public class CircularBuffer
   {
      
      private var arr:Array = null;
      
      private var ins:int = 0;
      
      private var num:int = 0;
      
      public function CircularBuffer(param1:int)
      {
         super();
         this.arr = new Array(param1);
         this.ins = 0;
         this.num = 0;
      }
      
      public static function test() : void
      {
         var _loc1_:Boolean = true;
         var _loc2_:CircularBuffer = null;
         var _loc3_:String = "string1";
         var _loc4_:String = "string2";
         var _loc5_:Object = null;
         var _loc6_:Object = null;
         _loc2_ = new CircularBuffer(0);
         if(0 != _loc2_.capacity)
         {
            throw new Error("a1");
         }
         if(0 != _loc2_.length)
         {
            throw new Error("b1");
         }
         try
         {
            _loc2_.push(10);
            _loc1_ = false;
         }
         catch(expected:Error)
         {
         }
         if(!_loc1_)
         {
            throw new Error("c1");
         }
         try
         {
            _loc2_.pop();
            _loc1_ = false;
         }
         catch(expected:Error)
         {
         }
         if(!_loc1_)
         {
            throw new Error("d1");
         }
         _loc2_ = new CircularBuffer(1);
         if(1 != _loc2_.capacity)
         {
            throw new Error("a2");
         }
         if(0 != _loc2_.length)
         {
            throw new Error("b2");
         }
         _loc2_.push(_loc3_);
         try
         {
            _loc2_.push(10);
            _loc1_ = false;
         }
         catch(expected:Error)
         {
         }
         if(!_loc1_)
         {
            throw new Error("c2");
         }
         _loc5_ = _loc2_.pop();
         if(_loc3_ != _loc5_)
         {
            throw new Error("d2");
         }
         try
         {
            _loc2_.pop();
            _loc1_ = false;
         }
         catch(expected:Error)
         {
         }
         if(!_loc1_)
         {
            throw new Error("e2");
         }
         _loc2_ = new CircularBuffer(2);
         if(2 != _loc2_.capacity)
         {
            throw new Error("a3");
         }
         if(0 != _loc2_.length)
         {
            throw new Error("b3");
         }
         _loc2_.push(_loc3_);
         _loc5_ = _loc2_.pop();
         if(_loc3_ != _loc5_)
         {
            throw new Error("c3");
         }
         _loc2_.push(_loc4_);
         _loc6_ = _loc2_.pop();
         if(_loc4_ != _loc6_)
         {
            throw new Error("d3");
         }
         _loc2_.push(_loc3_);
         _loc2_.push(_loc4_);
         try
         {
            _loc2_.push(3);
            _loc1_ = false;
         }
         catch(expected:Error)
         {
         }
         if(!_loc1_)
         {
            throw new Error("e3");
         }
         _loc5_ = _loc2_.pop();
         _loc6_ = _loc2_.pop();
         if(_loc3_ != _loc5_)
         {
            throw new Error("f3");
         }
         if(_loc4_ != _loc6_)
         {
            throw new Error("g3");
         }
         try
         {
            _loc2_.pop();
            _loc1_ = false;
         }
         catch(expected:Error)
         {
         }
         if(!_loc1_)
         {
            throw new Error("h3");
         }
         _loc2_ = new CircularBuffer(2);
         if(2 != _loc2_.capacity)
         {
            throw new Error("a4");
         }
         if(0 != _loc2_.length)
         {
            throw new Error("b4");
         }
         _loc2_.push(_loc3_);
         _loc5_ = _loc2_.pop();
         if(_loc3_ != _loc5_)
         {
            throw new Error("c4");
         }
         _loc2_.push(_loc4_);
         _loc6_ = _loc2_.pop();
         if(_loc4_ != _loc6_)
         {
            throw new Error("d4");
         }
         _loc2_.push(_loc3_);
         _loc2_.push(_loc4_);
         try
         {
            _loc2_.push(3);
            _loc1_ = false;
         }
         catch(expected:Error)
         {
         }
         if(!_loc1_)
         {
            throw new Error("e4");
         }
         var _loc7_:int = _loc2_.length;
         _loc2_.capacity = 1 + _loc2_.capacity;
         if(_loc2_.length != _loc7_)
         {
            throw new Error("len4.1");
         }
         _loc2_.push(3);
         if(_loc3_ != _loc2_.pop())
         {
            throw new Error("f4.a");
         }
         if(_loc4_ != _loc2_.pop())
         {
            throw new Error("f4.b");
         }
         if(3 != _loc2_.pop())
         {
            throw new Error("f4.c");
         }
         _loc2_.push(1);
         _loc2_.push(2);
         try
         {
            _loc2_.capacity = 1;
            _loc1_ = false;
         }
         catch(expected:Error)
         {
         }
         if(!_loc1_)
         {
            throw new Error("g4");
         }
      }
      
      public function get capacity() : int
      {
         return this.arr.length;
      }
      
      public function set capacity(param1:int) : void
      {
         var _loc2_:CircularBuffer = new CircularBuffer(param1);
         while(this.length > 0)
         {
            _loc2_.push(this.pop());
         }
         this.arr = _loc2_.arr;
         this.ins = _loc2_.ins;
         this.num = _loc2_.num;
      }
      
      public function get length() : int
      {
         return this.num;
      }
      
      public function push(param1:Object) : void
      {
         if(this.num >= this.arr.length)
         {
            throw new Error("overflow");
         }
         this.arr[this.ins] = param1;
         this.num += 1;
         this.ins = (this.ins + 1) % this.arr.length;
      }
      
      public function pop() : Object
      {
         if(this.num <= 0)
         {
            throw new Error("underflow");
         }
         var _loc1_:int = (this.arr.length + this.ins - this.num) % this.arr.length;
         var _loc2_:Object = this.arr[_loc1_];
         this.arr[_loc1_] = 0;
         --this.num;
         return _loc2_;
      }
      
      public function elementAt(param1:int) : Object
      {
         if(param1 < 0 || param1 >= this.num)
         {
            throw new Error("out of range");
         }
         var _loc2_:int = (this.arr.length + this.ins - this.num + param1) % this.arr.length;
         return this.arr[_loc2_];
      }
   }
}

