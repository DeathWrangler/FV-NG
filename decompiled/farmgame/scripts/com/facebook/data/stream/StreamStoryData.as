package com.facebook.data.stream
{
   [Bindable]
   public class StreamStoryData
   {
      
      public var comments:CommentsData;
      
      public var created_time:Date;
      
      public var message:String;
      
      public var target_id:String;
      
      public var sourceXML:XML;
      
      public var privacy:String;
      
      public var updated_time:Date;
      
      public var source_id:String;
      
      public var filter_key:String;
      
      public var post_id:String;
      
      public var action_links:Array;
      
      public var attachment:AttachmentData;
      
      public var actor_id:String;
      
      public var is_hidden:Boolean;
      
      public var viewer_id:String;
      
      public var permalink:String;
      
      public var metadata:Object;
      
      public var app_id:String;
      
      public var type:uint;
      
      public var likes:LikesData;
      
      public var attribution:String;
      
      public function StreamStoryData()
      {
         super();
      }
   }
}

