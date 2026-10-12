package cipro.Profiler
{
   public final class FrameEntryInfo
   {
      
      public static const ENTRY_TYPE_ENTER:int = 0;
      
      public static const ENTRY_TYPE_LEAVE:int = 1;
      
      public static const ENTRY_TYPE_LOG:int = 2;
      
      public var time:int;
      
      public var name:String;
      
      public var extraName:String;
      
      public var flag:int;
      
      public var totaltime:int;
      
      public var module:RuntimeModule;
      
      public var enterCookie:int;
      
      public function FrameEntryInfo()
      {
         super();
      }
   }
}

