package com.facebook.commands.photos
{
   import com.facebook.facebook_internal;
   import com.facebook.net.FacebookCall;
   
   use namespace facebook_internal;
   
   public class CreateAlbum extends FacebookCall
   {
      
      public static const METHOD_NAME:String = "photos.createAlbum";
      
      public static const SCHEMA:Array = ["name","location","description","visible","uid"];
      
      public var uid:String;
      
      public var visible:String;
      
      public var location:String;
      
      public var name:String;
      
      public var description:String;
      
      public function CreateAlbum(param1:String, param2:String = null, param3:String = null, param4:String = null, param5:String = null)
      {
         super(METHOD_NAME);
         this.name = param1;
         this.location = param2;
         this.description = param3;
         this.visible = param4;
         this.uid = param5;
      }
      
      override facebook_internal function initialize() : void
      {
         applySchema(SCHEMA,this.name,this.location,this.description,this.visible,this.uid);
         super.facebook_internal::initialize();
      }
   }
}

