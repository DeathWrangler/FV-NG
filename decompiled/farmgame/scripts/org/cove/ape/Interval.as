package org.cove.ape
{
   internal final class Interval
   {
      
      internal var min:Number;
      
      internal var max:Number;
      
      public function Interval(min:Number, max:Number)
      {
         super();
         this.min = min;
         this.max = max;
      }
      
      internal function toString() : String
      {
         return this.min + " : " + this.max;
      }
   }
}

