package com.facebook.commands.users
{
   import com.facebook.facebook_internal;
   import com.facebook.net.FacebookCall;
   import com.facebook.utils.FacebookDataUtils;
   
   use namespace facebook_internal;
   
   public class GetInfo extends FacebookCall
   {
      
      public static const METHOD_NAME:String = "users.getInfo";
      
      public static const SCHEMA:Array = ["uids","fields"];
      
      public var fields:Array;
      
      public var uids:Array;
      
      public function GetInfo(param1:Array, param2:Array)
      {
         super(METHOD_NAME);
         this.uids = param1;
         this.fields = param2;
      }
      
      override facebook_internal function initialize() : void
      {
         applySchema(SCHEMA,FacebookDataUtils.toArrayString(this.uids),FacebookDataUtils.toArrayString(this.fields));
         super.facebook_internal::initialize();
      }
   }
}

