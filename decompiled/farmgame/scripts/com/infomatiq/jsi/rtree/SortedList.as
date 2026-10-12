package com.infomatiq.jsi.rtree
{
   public class SortedList
   {
      
      private static const DEFAULT_PREFERRED_MAXIMUM_SIZE:int = 10;
      
      private var preferredMaximumSize:int = 1;
      
      private var ids:Vector.<int> = null;
      
      private var priorities:Vector.<Number> = null;
      
      public function SortedList()
      {
         super();
         this.initVectors(DEFAULT_PREFERRED_MAXIMUM_SIZE);
      }
      
      public function init(param1:int) : void
      {
         this.preferredMaximumSize = param1;
         this.initVectors(param1);
      }
      
      private function initVectors(param1:int) : void
      {
         this.ids = new Vector.<int>(param1,false);
         this.priorities = new Vector.<Number>(param1,false);
      }
      
      public function reset() : void
      {
         this.initVectors(this.preferredMaximumSize);
      }
      
      public function add(param1:int, param2:Number) : void
      {
         var _loc4_:* = 0;
         var _loc5_:* = 0;
         var _loc3_:Number = Number.NEGATIVE_INFINITY;
         if(this.priorities.length > 0)
         {
            _loc3_ = this.priorities[this.priorities.length - 1];
         }
         if(param2 == _loc3_ || param2 < _loc3_ && this.ids.length < this.preferredMaximumSize)
         {
            this.ids.push(param1);
            this.priorities.push(param2);
         }
         else if(param2 > _loc3_)
         {
            if(this.ids.length >= this.preferredMaximumSize)
            {
               _loc5_ = int(this.ids.length - 1);
               while(_loc5_ - 1 >= 0 && this.priorities[_loc5_ - 1] == _loc3_)
               {
                  _loc5_--;
               }
               if(_loc5_ >= this.preferredMaximumSize - 1)
               {
                  this.ids.splice(_loc5_,this.ids.length - _loc5_);
                  this.priorities.splice(_loc5_,this.priorities.length - _loc5_);
               }
            }
            _loc4_ = int(this.ids.length);
            while(_loc4_ - 1 >= 0 && param2 > this.priorities[_loc4_ - 1])
            {
               _loc4_--;
            }
            this.ids.splice(_loc4_,0,param1);
            this.priorities.splice(_loc4_,0,param2);
         }
      }
      
      public function getLowestPriority() : Number
      {
         var _loc1_:Number = Number.NEGATIVE_INFINITY;
         if(this.priorities.length >= this.preferredMaximumSize)
         {
            _loc1_ = this.priorities[this.priorities.length - 1];
         }
         return _loc1_;
      }
      
      public function forEachId(param1:Function) : void
      {
         var _loc2_:uint = 0;
         var _loc3_:uint = this.ids.length;
         while(_loc2_ < _loc3_)
         {
            if(!param1(this.ids[_loc2_]))
            {
               break;
            }
            _loc2_++;
         }
      }
   }
}

