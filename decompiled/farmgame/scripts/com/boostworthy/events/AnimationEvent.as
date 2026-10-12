package com.boostworthy.events
{
   import flash.events.Event;
   
   public class AnimationEvent extends Event
   {
      
      public static const START:String = "animationStart";
      
      public static const CHANGE:String = "animationChange";
      
      public static const STOP:String = "animationStop";
      
      public static const FINISH:String = "animationFinish";
      
      protected var m_objTarget:Object;
      
      protected var m_strProperty:String;
      
      public function AnimationEvent(param1:String, param2:Object = null, param3:String = "")
      {
         super(param1);
         this.m_objTarget = param2;
         this.m_strProperty = param3;
      }
      
      public function get animTarget() : Object
      {
         return this.m_objTarget;
      }
      
      public function get animProperty() : String
      {
         return this.m_strProperty;
      }
   }
}

