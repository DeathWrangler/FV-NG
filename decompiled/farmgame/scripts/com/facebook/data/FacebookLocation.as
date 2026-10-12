package com.facebook.data
{
   [Bindable]
   public class FacebookLocation extends FacebookData
   {
      
      public var state:String;
      
      public var street:String;
      
      public var country:String;
      
      public var zip:String;
      
      public var city:String;
      
      public function FacebookLocation()
      {
         super();
      }
   }
}

