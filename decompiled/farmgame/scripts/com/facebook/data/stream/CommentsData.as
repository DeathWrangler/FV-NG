package com.facebook.data.stream
{
   [Bindable]
   public class CommentsData
   {
      
      public var can_remove:Boolean;
      
      public var can_post:Boolean;
      
      public var posts:Array;
      
      public var count:uint;
      
      public function CommentsData()
      {
         super();
      }
   }
}

