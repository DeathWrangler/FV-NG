package Managers.InGameConsole
{
   public final class ConsoleEXAMPLECommandsModule extends InGameConsoleBaseCommandsModule
   {
      
      protected var m_stateHolder:int = 45;
      
      public function ConsoleEXAMPLECommandsModule()
      {
         super();
      }
      
      override public function get moduleName() : String
      {
         return "EXAMPLE";
      }
      
      public function exampleConsoleFunction() : String
      {
         this.exampleHelperFunction();
         return "Example function returned successfully. Nice";
      }
      
      private function exampleHelperFunction() : void
      {
         Global.player.gold = 1337;
         Global.player.cash = 9001;
      }
      
      public function changeState(newState:int) : String
      {
         this.m_stateHolder = newState;
         return "State changed to " + newState.toString();
      }
      
      public function checkState() : String
      {
         return "The value of this module\'s state is now: " + this.m_stateHolder.toString();
      }
   }
}

