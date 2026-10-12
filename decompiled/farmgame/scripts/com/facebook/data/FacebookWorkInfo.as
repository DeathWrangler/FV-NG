package com.facebook.data
{
   [Bindable]
   public class FacebookWorkInfo
   {
      
      public var position:String;
      
      public var start_date:Date;
      
      public var company_name:String;
      
      public var location:FacebookLocation;
      
      public var end_date:Date;
      
      public var description:String;
      
      public function FacebookWorkInfo()
      {
         super();
      }
   }
}

