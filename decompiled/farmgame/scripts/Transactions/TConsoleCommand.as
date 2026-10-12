package Transactions
{
   import Managers.InGameConsole.InGameConsoleManager;
   import com.adobe.serialization.json.JSON;
   
   public class TConsoleCommand extends TFarmTransaction
   {
      
      private var m_commandName:String = "";
      
      private var m_commandParams:Object = null;
      
      private var m_callback:Function = null;
      
      public function TConsoleCommand(commandName:String, commandParams:Object = null, callback:Function = null)
      {
         super();
         this.m_commandName = commandName;
         this.m_commandParams = commandParams;
         this.m_callback = callback;
      }
      
      override public function perform() : void
      {
         if(this.m_commandName.length)
         {
            signedCall("InGameConsoleService." + this.m_commandName,com.adobe.serialization.json.JSON.encode(this.m_commandParams));
         }
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result)
         {
            InGameConsoleManager.writeObjectToConsole(this.m_commandParams);
            if(result.hasOwnProperty("errorMessage"))
            {
               InGameConsoleManager.writeToHistory("Console Transaction Failed for: " + this.m_commandName + "\nError Message: " + result["errorMessage"]);
            }
            else
            {
               InGameConsoleManager.writeToHistory("Console Transaction Successful for: " + this.m_commandName);
               if(this.m_callback != null)
               {
                  this.m_callback(result);
               }
            }
         }
         super.onComplete(result);
      }
   }
}

