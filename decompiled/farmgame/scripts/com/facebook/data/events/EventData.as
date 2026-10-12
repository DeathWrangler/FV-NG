package com.facebook.data.events
{
   import com.facebook.data.FacebookLocation;
   
   [Bindable]
   public class EventData
   {
      
      public var eid:String;
      
      public var update_time:Date;
      
      public var nid:Number;
      
      public var pic:String;
      
      public var name:String;
      
      public var tagline:String;
      
      public var start_time:Date;
      
      public var end_time:Date;
      
      public var event_subtype:String;
      
      public var pic_small:String;
      
      public var pic_big:String;
      
      public var host:String;
      
      public var creator:Number;
      
      public var venue:FacebookLocation;
      
      public var location:String;
      
      public var description:String;
      
      public var event_type:String;
      
      public function EventData()
      {
         super();
      }
   }
}

