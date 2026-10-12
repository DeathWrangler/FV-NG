package com.boostworthy.collections
{
   import com.boostworthy.collections.iterators.IIterator;
   
   public interface ICollection
   {
      
      function getIterator(param1:uint = 2) : IIterator;
   }
}

