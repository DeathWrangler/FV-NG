package com.facebook.data.batch
{
   import com.facebook.data.FacebookData;
   
   [Bindable]
   public class BatchResult extends FacebookData
   {
      
      public var results:Array;
      
      public function BatchResult()
      {
         super();
      }
   }
}

