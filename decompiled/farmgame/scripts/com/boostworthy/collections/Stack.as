package com.boostworthy.collections
{
   import com.boostworthy.collections.iterators.ForwardArrayIterator;
   import com.boostworthy.collections.iterators.IIterator;
   import com.boostworthy.collections.iterators.IteratorType;
   import com.boostworthy.collections.iterators.ReverseArrayIterator;
   import com.boostworthy.core.Global;
   import com.boostworthy.core.IDisposable;
   
   public class Stack implements ICollection, IDisposable
   {
      
      protected var m_aData:Array;
      
      public function Stack()
      {
         super();
         this.dispose();
      }
      
      public function addElement(param1:Object) : void
      {
         this.m_aData.unshift(param1);
      }
      
      public function removeElement(param1:Object) : void
      {
         var _loc2_:int = this.getElementIndex(param1);
         if(_loc2_ != com.boostworthy.core.Global.NULL_INDEX)
         {
            this.m_aData.splice(_loc2_,1);
         }
      }
      
      public function get length() : uint
      {
         return this.m_aData.length;
      }
      
      public function getIterator(param1:uint = 2) : IIterator
      {
         if(param1 == IteratorType.ARRAY_FORWARD)
         {
            return new ForwardArrayIterator(this.m_aData.concat());
         }
         if(param1 == IteratorType.ARRAY_REVERSE)
         {
            return new ReverseArrayIterator(this.m_aData.concat());
         }
         return new ForwardArrayIterator(this.m_aData.concat());
      }
      
      public function dispose() : void
      {
         this.m_aData = new Array();
      }
      
      private function getElementIndex(param1:Object) : int
      {
         var _loc2_:int = 0;
         while(_loc2_ < this.m_aData.length)
         {
            if(this.m_aData[_loc2_] === param1)
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return com.boostworthy.core.Global.NULL_INDEX;
      }
   }
}

