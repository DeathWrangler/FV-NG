package com.boostworthy.collections.iterators
{
   public class ForwardArrayIterator implements IIterator
   {
      
      private var m_aData:Array;
      
      private var m_uIndex:uint;
      
      public function ForwardArrayIterator(param1:Array)
      {
         super();
         this.m_aData = param1;
         this.reset();
      }
      
      public function hasNext() : Boolean
      {
         return this.m_uIndex < this.m_aData.length;
      }
      
      public function next() : Object
      {
         return this.m_aData[this.m_uIndex++];
      }
      
      public function reset() : void
      {
         this.m_uIndex = 0;
      }
   }
}

