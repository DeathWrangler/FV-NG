package com.troyer.widget.event
{
   import flash.events.Event;
   
   public class WidgetLoadEvent extends Event
   {
      
      public static const LOAD_COMPLETE:String = "load_complete";
      
      public static const LOAD_FAILED:String = "load_failed";
      
      public static const ALL_LOADS_COMPLETE:String = "all_loads_complete";
      
      private var m_url:String;
      
      public function WidgetLoadEvent(param1:String, param2:String = null)
      {
         super(param1,bubbles,cancelable);
         this.m_url = param2;
      }
      
      public function get url() : String
      {
         return this.m_url;
      }
   }
}

