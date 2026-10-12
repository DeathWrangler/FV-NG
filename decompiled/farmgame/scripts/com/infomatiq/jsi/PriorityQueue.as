package com.infomatiq.jsi
{
   public class PriorityQueue
   {
      
      public static const SORT_ORDER_ASCENDING:Boolean = true;
      
      public static const SORT_ORDER_DESCENDING:Boolean = false;
      
      private static const INTERNAL_CONSISTENCY_CHECKING:Boolean = true;
      
      private var values:Vector.<int> = null;
      
      private var priorities:Vector.<Number> = null;
      
      private var sortOrder:Boolean = true;
      
      public function PriorityQueue(param1:Boolean, param2:int = 10)
      {
         super();
         this.sortOrder = param1;
         this.values = new Vector.<int>(param2);
         this.priorities = new Vector.<Number>(param2);
      }
      
      private function sortsEarlierThan(param1:Number, param2:Number) : Boolean
      {
         if(this.sortOrder == SORT_ORDER_ASCENDING)
         {
            return param1 < param2;
         }
         return param2 < param1;
      }
      
      public function insert(param1:int, param2:Number) : void
      {
         this.values.push(param1);
         this.priorities.push(param2);
         this.promote(this.values.length - 1,param1,param2);
      }
      
      private function promote(param1:int, param2:int, param3:Number) : void
      {
         var _loc4_:int = 0;
         var _loc5_:Number = NaN;
         while(param1 > 0)
         {
            _loc4_ = (param1 - 1) / 2;
            _loc5_ = this.priorities[_loc4_];
            if(this.sortsEarlierThan(_loc5_,param3))
            {
               break;
            }
            this.values[param1] = this.values[_loc4_];
            this.priorities[param1] = _loc5_;
            param1 = _loc4_;
         }
         this.values[param1] = param2;
         this.priorities[param1] = param3;
         if(INTERNAL_CONSISTENCY_CHECKING)
         {
            this.check();
         }
      }
      
      public function size() : int
      {
         return this.values.length;
      }
      
      public function reset() : void
      {
         var _loc1_:int = this.size();
         this.values = new Vector.<int>(_loc1_);
         this.priorities = new Vector.<Number>(_loc1_);
      }
      
      public function getValue() : int
      {
         return this.values[0];
      }
      
      public function getPriority() : Number
      {
         return this.priorities[0];
      }
      
      private function demote(param1:int, param2:int, param3:Number) : void
      {
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc4_:int = param1 * 2 + 1;
         while(_loc4_ < this.values.length)
         {
            _loc5_ = this.priorities[_loc4_];
            if(_loc4_ + 1 < this.values.length)
            {
               _loc6_ = this.priorities[_loc4_ + 1];
               if(this.sortsEarlierThan(_loc6_,_loc5_))
               {
                  _loc5_ = _loc6_;
                  _loc4_++;
               }
            }
            if(!this.sortsEarlierThan(_loc5_,param3))
            {
               break;
            }
            this.values[param1] = this.values[_loc4_];
            this.priorities[param1] = _loc5_;
            param1 = _loc4_;
            _loc4_ = param1 * 2 + 1;
         }
         this.values[param1] = param2;
         this.priorities[param1] = param3;
      }
      
      public function pop() : int
      {
         var _loc1_:int = this.values[0];
         var _loc2_:int = this.values.length - 1;
         var _loc3_:int = this.values[_loc2_];
         var _loc4_:Number = this.priorities[_loc2_];
         this.values.splice(_loc2_,1);
         this.priorities.splice(_loc2_,1);
         if(_loc2_ > 0)
         {
            this.demote(0,_loc3_,_loc4_);
         }
         if(INTERNAL_CONSISTENCY_CHECKING)
         {
            this.check();
         }
         return _loc1_;
      }
      
      public function setSortOrder(param1:Boolean) : void
      {
         var _loc2_:* = 0;
         if(this.sortOrder != param1)
         {
            this.sortOrder = param1;
            _loc2_ = int(this.values.length / 2 - 1);
            while(_loc2_ >= 0)
            {
               this.demote(_loc2_,this.values[_loc2_],this.priorities[_loc2_]);
               _loc2_--;
            }
         }
         if(INTERNAL_CONSISTENCY_CHECKING)
         {
            this.check();
         }
      }
      
      private function check() : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc1_:int = this.values.length - 1;
         var _loc2_:int = 0;
         while(_loc2_ < this.values.length / 2)
         {
            _loc3_ = this.priorities[_loc2_];
            _loc4_ = _loc2_ * 2 + 1;
            if(_loc4_ <= _loc1_)
            {
               _loc6_ = this.priorities[_loc4_];
               if(this.sortsEarlierThan(_loc6_,_loc3_))
               {
               }
            }
            _loc5_ = _loc2_ * 2 + 2;
            if(_loc5_ <= _loc1_)
            {
               _loc7_ = this.priorities[_loc5_];
               if(this.sortsEarlierThan(_loc7_,_loc3_))
               {
               }
            }
            _loc2_++;
         }
      }
   }
}

