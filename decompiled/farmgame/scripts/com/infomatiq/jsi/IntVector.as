package com.infomatiq.jsi
{
   public class IntVector
   {
      
      private var m_vector:Vector.<int>;
      
      public function IntVector(param1:int = 10, param2:Boolean = false)
      {
         super();
         this.m_vector = new Vector.<int>(param1,param2);
      }
      
      public static function copyVector(param1:Vector.<int>, param2:Vector.<int>, param3:int = 0, param4:int = 0, param5:int = -1) : void
      {
         if(param5 == -1)
         {
            if(param2.fixed)
            {
               param5 = Math.min(param1.length,param2.length);
            }
            else
            {
               param5 = int(param1.length);
            }
         }
         var _loc6_:int = 0;
         while(_loc6_ < param5)
         {
            param2[param4 + _loc6_] = param1[param3 + _loc6_];
            _loc6_++;
         }
      }
      
      public static function cloneVector(param1:Vector.<int>) : Vector.<int>
      {
         var _loc2_:Vector.<int> = null;
         if(param1 != null)
         {
            _loc2_ = new Vector.<int>(param1.length,true);
            copyVector(param1,_loc2_,0,0,param1.length);
         }
         return _loc2_;
      }
      
      public function add(param1:int) : void
      {
         this.m_vector.push(param1);
      }
      
      public function get(param1:int) : int
      {
         return this.m_vector[param1];
      }
      
      public function set(param1:int, param2:int) : void
      {
         if(param1 < this.m_vector.length)
         {
            this.m_vector[param1] = param2;
         }
         else
         {
            if(param1 != this.m_vector.length)
            {
               throw new ArgumentError("Invalid index [" + param1 + "] is outside the length of the IntVector [" + this.m_vector.length + "]");
            }
            this.m_vector.push(param2);
         }
      }
      
      public function size() : int
      {
         return this.m_vector.length as int;
      }
      
      public function reset() : void
      {
         this.m_vector = new Vector.<int>();
      }
      
      public function toVector() : Vector.<int>
      {
         return cloneVector(this.m_vector);
      }
   }
}

