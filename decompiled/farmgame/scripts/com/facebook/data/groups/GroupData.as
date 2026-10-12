package com.facebook.data.groups
{
   import com.facebook.data.FacebookLocation;
   
   [Bindable]
   public class GroupData
   {
      
      public var group_subtype:String;
      
      public var gid:String;
      
      public var update_time:Date;
      
      public var privacy:String;
      
      public var nid:Number;
      
      public var pic:String;
      
      public var name:String;
      
      public var pic_big:String;
      
      public var website:String;
      
      public var office:String;
      
      public var pic_small:String;
      
      public var creator:String;
      
      public var venue:FacebookLocation;
      
      public var recent_news:String;
      
      public var group_type:String;
      
      public var description:String;
      
      public function GroupData()
      {
         super();
      }
   }
}

