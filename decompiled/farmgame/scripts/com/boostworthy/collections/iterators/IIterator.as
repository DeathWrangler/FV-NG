package com.boostworthy.collections.iterators
{
   public interface IIterator
   {
      
      function hasNext() : Boolean;
      
      function next() : Object;
      
      function reset() : void;
   }
}

