package com.facebook.data.notes
{
   [Bindable]
   public class NoteData
   {
      
      public var created_time:Date;
      
      public var note_id:String;
      
      public var updated_time:Date;
      
      public var title:String;
      
      public var content:String;
      
      public var uid:String;
      
      public function NoteData()
      {
         super();
      }
   }
}

