package com.facebook.data.groups
{
   import com.facebook.data.FacebookData;
   
   [Bindable]
   public class GetMemberData extends FacebookData
   {
      
      public var admins:Array;
      
      public var notReplied:Array;
      
      public var members:Array;
      
      public var officers:Array;
      
      public function GetMemberData()
      {
         super();
      }
   }
}

