package Managers.InGameConsole
{
   public final class ConsoleWatchToEarnCommandsModule extends InGameConsoleBaseCommandsModule
   {
      
      public static var traceOutputToConsole:Boolean = false;
      
      public function ConsoleWatchToEarnCommandsModule()
      {
         super();
      }
      
      override public function get moduleName() : String
      {
         return "w2e";
      }
      
      public function toggleLogToOutput() : String
      {
         var status:String = "on";
         traceOutputToConsole = !traceOutputToConsole;
         if(traceOutputToConsole == false)
         {
            status = "off";
         }
         return "Tracing to admin output is " + status;
      }
   }
}

