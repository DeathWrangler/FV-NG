package com.urbansquall.ginger.events
{
   import flash.events.Event;
   
   public class FrameEvent extends Event
   {
      
      public static const CHANGE:String = "frame_event_change";
      
      public var begin:Boolean;
      
      public var frameID:String;
      
      public var animationID:String;
      
      public function FrameEvent(type:String, a_begin:Boolean, a_frameID:String, a_animationID:String, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super(type,bubbles,cancelable);
         this.begin = a_begin;
         this.frameID = a_frameID;
         this.animationID = a_animationID;
      }
   }
}

