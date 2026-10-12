package com.facebook.commands.friends
{
   import com.facebook.facebook_internal;
   import com.facebook.net.FacebookCall;
   
   use namespace facebook_internal;
   
   public class GetFriends extends FacebookCall
   {
      
      public static const METHOD_NAME:String = "friends.get";
      
      public static const SCHEMA:Array = ["flid","uid"];
      
      public var uid:String;
      
      public var flid:String;
      
      public function GetFriends(param1:String = null, param2:String = null)
      {
         super(METHOD_NAME);
         this.flid = param1;
         this.uid = param2;
      }
      
      override facebook_internal function initialize() : void
      {
         applySchema(SCHEMA,this.flid,this.uid);
         super.facebook_internal::initialize();
      }
   }
}

