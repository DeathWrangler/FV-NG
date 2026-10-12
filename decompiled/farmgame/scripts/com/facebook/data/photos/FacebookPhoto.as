package com.facebook.data.photos
{
   import com.facebook.data.FacebookData;
   
   [Bindable]
   public class FacebookPhoto extends FacebookData
   {
      
      public var src:String;
      
      public var src_big:String;
      
      public var pid:String;
      
      public var src_small:String;
      
      public var caption:String;
      
      public var created:Date;
      
      public var owner:Number;
      
      public var tags:Array = [];
      
      public var link:String;
      
      public var aid:String;
      
      public function FacebookPhoto()
      {
         super();
      }
   }
}

