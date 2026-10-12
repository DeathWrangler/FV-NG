package com.urbansquall.ginger.events
{
   import flash.events.Event;
   
   public class AnimationEvent extends Event
   {
      
      public static const CHANGE:String = "animation_event_change";
      
      public var begin:Boolean;
      
      public var animationID:String;
      
      public function AnimationEvent(type:String, a_begin:Boolean, a_animationID:String, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super(type,bubbles,cancelable);
         this.begin = a_begin;
         this.animationID = a_animationID;
      }
   }
}

