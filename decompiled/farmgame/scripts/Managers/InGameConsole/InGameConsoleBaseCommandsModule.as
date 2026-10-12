package Managers.InGameConsole
{
   import Engine.Managers.TransactionManager;
   import Transactions.TConsoleCommand;
   import flash.utils.getQualifiedClassName;
   
   public class InGameConsoleBaseCommandsModule
   {
      
      public function InGameConsoleBaseCommandsModule()
      {
         super();
      }
      
      public function get moduleName() : String
      {
         throw new Error("Must overrwrite m_moduleName in" + getQualifiedClassName(this));
      }
      
      protected function sendTransaction(consoleServiceFunc:String, params:Object, callback:Function = null, performImmediately:Boolean = true) : void
      {
         TransactionManager.addTransaction(new TConsoleCommand(consoleServiceFunc,params,callback),performImmediately);
      }
   }
}

