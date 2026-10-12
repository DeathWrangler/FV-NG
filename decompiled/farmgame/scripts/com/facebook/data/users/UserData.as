package com.facebook.data.users
{
   [Bindable]
   public class UserData
   {
      
      public var affiations:AffiliationCollection;
      
      public var name:String;
      
      public var uid:String;
      
      public var timezone:Number;
      
      public var first_name:String;
      
      public var last_name:String;
      
      public function UserData()
      {
         super();
      }
      
      public function toString() : String
      {
         return "[ UserData uid: " + this.uid + " affiation:" + this.affiations + " first_name:" + this.first_name + " last_name:" + this.last_name + " name:" + this.name + " timezone: " + this.timezone + "]";
      }
   }
}

