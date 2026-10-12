package com.facebook.data
{
   [Bindable]
   public class FacebookEducationInfo
   {
      
      public var concentrations:Array;
      
      public var name:String;
      
      public var degree:String;
      
      public var year:String;
      
      public function FacebookEducationInfo()
      {
         super();
         this.concentrations = [];
      }
   }
}

