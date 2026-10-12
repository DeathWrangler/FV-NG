package Classes
{
   public class BitFlagsById
   {
      
      private static const MAX_ID:uint = 65535;
      
      private static const SHIFT_ID_BY:uint = 16;
      
      private static const MAX_FLAGS_PER_GROUP:uint = 16;
      
      private static const MASK_ID:uint = 4294901760;
      
      private static const MASK_FLAGS:uint = 65535;
      
      private var m_serialData:Array = null;
      
      private var m_hashData:Array = null;
      
      private var m_dataHasChanged:Boolean = false;
      
      public function BitFlagsById(serialData:Array)
      {
         super();
         this.m_serialData = serialData;
      }
      
      public function release() : void
      {
         this.m_serialData = null;
         this.m_hashData = null;
      }
      
      private function unpack() : void
      {
         var groupCount:uint = 0;
         var groupIndex:uint = 0;
         var groupOfSerialData:Array = null;
         var len:uint = 0;
         var index:uint = 0;
         var raw:uint = 0;
         if(this.m_hashData == null && this.m_serialData != null)
         {
            this.m_hashData = new Array();
            groupCount = this.m_serialData.length;
            for(groupIndex = 0; groupIndex < groupCount; groupIndex++)
            {
               this.m_hashData[groupIndex] = new Array();
               groupOfSerialData = this.m_serialData[groupIndex];
               len = groupOfSerialData.length;
               for(index = 0; index < len; index++)
               {
                  raw = uint(groupOfSerialData[index]);
                  this.m_hashData[groupIndex][uint(raw & MASK_ID) >>> SHIFT_ID_BY] = raw & MASK_FLAGS;
               }
            }
         }
      }
      
      public function serialize() : Array
      {
         var groupCount:uint = 0;
         var groupIndex:uint = 0;
         var idString:String = null;
         var id:uint = 0;
         var flags:uint = 0;
         var groupLen:uint = 0;
         if(this.m_dataHasChanged && this.m_hashData != null)
         {
            this.m_serialData = null;
            this.m_serialData = new Array();
            groupCount = this.m_hashData.length;
            for(groupIndex = 0; groupIndex < groupCount; groupIndex++)
            {
               this.m_serialData[groupIndex] = new Array();
               for(idString in this.m_hashData[groupIndex])
               {
                  id = uint(idString);
                  flags = uint(this.m_hashData[groupIndex][id]);
                  if(flags > 0)
                  {
                     this.m_serialData[groupIndex].push(uint(id << SHIFT_ID_BY | flags));
                  }
               }
            }
            groupCount = this.m_serialData.length;
            for(groupIndex = groupCount - 1; groupIndex >= 0; groupIndex--)
            {
               groupLen = uint(this.m_serialData[groupIndex].length);
               if(groupLen > 0)
               {
                  break;
               }
               this.m_serialData[groupIndex] = null;
               this.m_serialData.pop();
            }
         }
         return this.m_serialData;
      }
      
      public function getFlag(itemId:uint, flagIndex:uint) : Boolean
      {
         this.unpack();
         if(flagIndex <= 0)
         {
            throw Error("BitFlagsById.as::getFlag(): bad input flagIndex:" + flagIndex);
         }
         if(itemId < 0 || itemId > MAX_ID)
         {
            throw Error("BitFlagsById.as::getFlag(): bad input itemId:" + itemId);
         }
         var result:Boolean = false;
         var groupIndex:uint = uint((flagIndex - 1) / MAX_FLAGS_PER_GROUP);
         var flagMask:uint = uint(1 << flagIndex - groupIndex * MAX_FLAGS_PER_GROUP - 1);
         if(this.m_hashData.length > groupIndex)
         {
            if(Boolean(this.m_hashData[groupIndex]) && Boolean(this.m_hashData[groupIndex].hasOwnProperty(itemId)))
            {
               result = (this.m_hashData[groupIndex][itemId] & flagMask) > 0;
            }
         }
         return result;
      }
      
      public function setFlag(itemId:uint, flagIndex:uint, trueOrFalse:Boolean) : void
      {
         var curValue:Boolean = false;
         this.unpack();
         if(flagIndex <= 0)
         {
            throw Error("BitFlagsById.as::setFlag(): bad input flagIndex:" + flagIndex);
         }
         if(itemId < 0 || itemId > MAX_ID)
         {
            throw Error("BitFlagsById.as::setFlag(): bad input itemId:" + itemId);
         }
         var groupIndex:uint = Math.floor((flagIndex - 1) / MAX_FLAGS_PER_GROUP);
         var flagMask:uint = uint(1 << flagIndex - groupIndex * MAX_FLAGS_PER_GROUP - 1);
         if(this.m_hashData == null)
         {
            this.m_hashData = new Array();
         }
         for(var eachGroupIndex:uint = 0; eachGroupIndex <= groupIndex; eachGroupIndex++)
         {
            if(this.m_hashData.length <= eachGroupIndex)
            {
               this.m_hashData[eachGroupIndex] = new Array();
            }
         }
         if(!this.m_hashData[groupIndex][itemId] && trueOrFalse)
         {
            this.m_hashData[groupIndex][itemId] = flagMask;
            this.m_dataHasChanged = true;
         }
         else if(this.m_hashData[groupIndex][itemId])
         {
            curValue = (this.m_hashData[groupIndex][itemId] & flagMask) > 0;
            if(curValue != trueOrFalse)
            {
               if(trueOrFalse)
               {
                  this.m_hashData[groupIndex][itemId] |= flagMask;
               }
               else
               {
                  this.m_hashData[groupIndex][itemId] &= ~flagMask;
               }
               this.m_dataHasChanged = true;
            }
         }
      }
      
      public function removeId(itemId:uint) : void
      {
         var groupCount:uint = 0;
         var eachGroupIndex:uint = 0;
         var indexOfItem:uint = 0;
         this.unpack();
         if(itemId < 0 || itemId > MAX_ID)
         {
            throw Error("BitFlagsById.as::setFlag(): bad input itemId:" + itemId);
         }
         if(this.m_hashData != null)
         {
            groupCount = this.m_hashData.length;
            for(eachGroupIndex = 0; eachGroupIndex < groupCount; eachGroupIndex++)
            {
               if(this.m_hashData[eachGroupIndex][itemId])
               {
                  indexOfItem = uint(this.m_hashData[eachGroupIndex].indexOf(itemId));
                  this.m_hashData[eachGroupIndex].splice(indexOfItem,1);
                  this.m_dataHasChanged = true;
               }
            }
         }
      }
      
      public function relocateId(fromId:uint, toId:uint) : void
      {
         var groupCount:uint = 0;
         var eachGroupIndex:uint = 0;
         var tmpFlags:uint = 0;
         var indexOfItem:uint = 0;
         this.unpack();
         if(fromId < 0 || fromId > MAX_ID)
         {
            throw Error("BitFlagsById.as::setFlag(): bad input fromId:" + fromId);
         }
         if(toId < 0 || toId > MAX_ID)
         {
            throw Error("BitFlagsById.as::setFlag(): bad input toId:" + toId);
         }
         if(this.m_hashData != null)
         {
            groupCount = this.m_hashData.length;
            for(eachGroupIndex = 0; eachGroupIndex < groupCount; eachGroupIndex++)
            {
               tmpFlags = 0;
               if(this.m_hashData[eachGroupIndex][fromId])
               {
                  tmpFlags = uint(this.m_hashData[eachGroupIndex][fromId]);
                  indexOfItem = uint(this.m_hashData[eachGroupIndex].indexOf(fromId));
                  this.m_hashData[eachGroupIndex].splice(indexOfItem,1);
                  this.m_dataHasChanged = true;
               }
               if(tmpFlags != 0)
               {
                  this.m_hashData[eachGroupIndex][toId] = tmpFlags;
               }
            }
         }
      }
   }
}

