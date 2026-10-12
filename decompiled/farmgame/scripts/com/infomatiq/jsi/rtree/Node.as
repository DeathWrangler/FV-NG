package com.infomatiq.jsi.rtree
{
   public class Node
   {
      
      internal var nodeId:int = 0;
      
      internal var mbrMinX:Number = 1.7976931348623157e+308;
      
      internal var mbrMinY:Number = 1.7976931348623157e+308;
      
      internal var mbrMaxX:Number = -Number.MAX_VALUE;
      
      internal var mbrMaxY:Number = -Number.MAX_VALUE;
      
      internal var entriesMinX:Vector.<Number> = null;
      
      internal var entriesMinY:Vector.<Number> = null;
      
      internal var entriesMaxX:Vector.<Number> = null;
      
      internal var entriesMaxY:Vector.<Number> = null;
      
      internal var ids:Vector.<int> = null;
      
      internal var level:int;
      
      internal var entryCount:int;
      
      public function Node(param1:int, param2:int, param3:int)
      {
         super();
         this.nodeId = param1;
         this.level = param2;
         this.entriesMinX = new Vector.<Number>(param3,true);
         this.entriesMinY = new Vector.<Number>(param3,true);
         this.entriesMaxX = new Vector.<Number>(param3,true);
         this.entriesMaxY = new Vector.<Number>(param3,true);
         this.ids = new Vector.<int>(param3,true);
      }
      
      internal function addEntry(param1:Number, param2:Number, param3:Number, param4:Number, param5:int) : void
      {
         this.ids[this.entryCount] = param5;
         this.entriesMinX[this.entryCount] = param1;
         this.entriesMinY[this.entryCount] = param2;
         this.entriesMaxX[this.entryCount] = param3;
         this.entriesMaxY[this.entryCount] = param4;
         if(param1 < this.mbrMinX)
         {
            this.mbrMinX = param1;
         }
         if(param2 < this.mbrMinY)
         {
            this.mbrMinY = param2;
         }
         if(param3 > this.mbrMaxX)
         {
            this.mbrMaxX = param3;
         }
         if(param4 > this.mbrMaxY)
         {
            this.mbrMaxY = param4;
         }
         ++this.entryCount;
      }
      
      internal function findEntry(param1:Number, param2:Number, param3:Number, param4:Number, param5:int) : int
      {
         var _loc6_:int = 0;
         while(_loc6_ < this.entryCount)
         {
            if(param5 == this.ids[_loc6_] && this.entriesMinX[_loc6_] == param1 && this.entriesMinY[_loc6_] == param2 && this.entriesMaxX[_loc6_] == param3 && this.entriesMaxY[_loc6_] == param4)
            {
               return _loc6_;
            }
            _loc6_++;
         }
         return -1;
      }
      
      internal function deleteEntry(param1:int) : void
      {
         var _loc2_:int = this.entryCount - 1;
         var _loc3_:Number = this.entriesMinX[param1];
         var _loc4_:Number = this.entriesMinY[param1];
         var _loc5_:Number = this.entriesMaxX[param1];
         var _loc6_:Number = this.entriesMaxY[param1];
         if(param1 != _loc2_)
         {
            this.entriesMinX[param1] = this.entriesMinX[_loc2_];
            this.entriesMinY[param1] = this.entriesMinY[_loc2_];
            this.entriesMaxX[param1] = this.entriesMaxX[_loc2_];
            this.entriesMaxY[param1] = this.entriesMaxY[_loc2_];
            this.ids[param1] = this.ids[_loc2_];
         }
         --this.entryCount;
         this.recalculateMBRIfInfluencedBy(_loc3_,_loc4_,_loc5_,_loc6_);
      }
      
      internal function recalculateMBRIfInfluencedBy(param1:Number, param2:Number, param3:Number, param4:Number) : void
      {
         if(this.mbrMinX == param1 || this.mbrMinY == param2 || this.mbrMaxX == param3 || this.mbrMaxY == param4)
         {
            this.recalculateMBR();
         }
      }
      
      internal function recalculateMBR() : void
      {
         this.mbrMinX = this.entriesMinX[0];
         this.mbrMinY = this.entriesMinY[0];
         this.mbrMaxX = this.entriesMaxX[0];
         this.mbrMaxY = this.entriesMaxY[0];
         var _loc1_:int = 1;
         while(_loc1_ < this.entryCount)
         {
            if(this.entriesMinX[_loc1_] < this.mbrMinX)
            {
               this.mbrMinX = this.entriesMinX[_loc1_];
            }
            if(this.entriesMinY[_loc1_] < this.mbrMinY)
            {
               this.mbrMinY = this.entriesMinY[_loc1_];
            }
            if(this.entriesMaxX[_loc1_] > this.mbrMaxX)
            {
               this.mbrMaxX = this.entriesMaxX[_loc1_];
            }
            if(this.entriesMaxY[_loc1_] > this.mbrMaxY)
            {
               this.mbrMaxY = this.entriesMaxY[_loc1_];
            }
            _loc1_++;
         }
      }
      
      internal function reorganize(param1:RTree) : void
      {
         var _loc2_:* = int(param1.maxNodeEntries - 1);
         var _loc3_:int = 0;
         while(_loc3_ < this.entryCount)
         {
            if(this.ids[_loc3_] == -1)
            {
               while(this.ids[_loc2_] == -1 && _loc2_ > _loc3_)
               {
                  _loc2_--;
               }
               this.entriesMinY[_loc3_] = this.entriesMinY[_loc2_];
               this.entriesMinX[_loc3_] = this.entriesMinX[_loc2_];
               this.entriesMaxX[_loc3_] = this.entriesMaxX[_loc2_];
               this.entriesMaxY[_loc3_] = this.entriesMaxY[_loc2_];
               this.ids[_loc3_] = this.ids[_loc2_];
               this.ids[_loc2_] = -1;
            }
            _loc3_++;
         }
      }
      
      public function getId(param1:int) : int
      {
         if(param1 < this.entryCount)
         {
            return this.ids[param1];
         }
         return -1;
      }
      
      internal function isLeaf() : Boolean
      {
         return this.level == 1;
      }
   }
}

