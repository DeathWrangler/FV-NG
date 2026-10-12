package Managers.InGameConsole
{
   import Managers.FarmStatsManager;
   import Replay.ArrayUtils;
   import com.adobe.utils.StringUtil;
   import flash.utils.describeType;
   
   public class InGameConsoleTokenizerManager
   {
      
      private static const TERMINAL_COMMAND:String = "terminal_command";
      
      private static var m_consoleVariables:Object = {};
      
      private static const SPECIAL_TOKENS:Object = {
         "true":true,
         "false":false
      };
      
      public function InGameConsoleTokenizerManager()
      {
         super();
      }
      
      public static function getAllCommands(prefix:String = "") : Array
      {
         var classInfo:XML = null;
         var methodName:String = null;
         var valid:Boolean = false;
         var module:InGameConsoleBaseCommandsModule = null;
         var method:XML = null;
         var allCommands:Array = new Array();
         for each(module in InGameConsoleManager.activeModules)
         {
            classInfo = describeType(module);
            for each(method in classInfo..method)
            {
               methodName = module.moduleName + "." + method.@name;
               valid = method.@returnType == "String" && (prefix.length == 0 || prefix.length <= methodName.length && methodName.substr(0,prefix.length) == prefix);
               if(valid)
               {
                  allCommands.push(methodName);
               }
            }
         }
         return allCommands;
      }
      
      public static function autoCompleteCommand(prefix:String) : String
      {
         var charToCheck:String = null;
         var command:String = null;
         var possibleCommands:Array = getAllCommands(prefix);
         if(possibleCommands.length == 0)
         {
            return prefix;
         }
         var currentIndex:int = prefix.length;
         var finalString:String = prefix;
         var valid:Boolean = true;
         while(valid)
         {
            charToCheck = (possibleCommands[0] as String).charAt(currentIndex);
            for each(command in possibleCommands)
            {
               if(finalString == command || currentIndex < command.length && command.charAt(currentIndex) != charToCheck)
               {
                  valid = false;
                  break;
               }
            }
            if(valid == true)
            {
               currentIndex++;
               finalString += charToCheck;
            }
         }
         return finalString;
      }
      
      private static function determineCommandType(command:String) : String
      {
         command = StringUtil.trim(command);
         return TERMINAL_COMMAND;
      }
      
      public static function executeCommand(command:String) : String
      {
         var output:String = null;
         var tokens:Array = null;
         var commandType:String = null;
         try
         {
            output = "";
            tokens = [];
            commandType = determineCommandType(command);
            switch(commandType)
            {
               case TERMINAL_COMMAND:
                  tokens = tokenizeTerminalCommand(command);
                  output = callFunction(tokens[1],tokens.slice(2),tokens[0]);
                  FarmStatsManager.count(InGameConsoleManager.CONSOLE_STATS_COUNTER_FIELD,TERMINAL_COMMAND,tokens[0],tokens[1]);
            }
            if(output == null || output == "")
            {
               output = "Function Call Successful";
            }
         }
         catch(error:Error)
         {
            output = "Problem parsing the command:\nError name: " + error.name + "\nError Message: " + error.message;
         }
         return output;
      }
      
      private static function tokenizeAssignment(command:String) : String
      {
         return "";
      }
      
      private static function tokenizeTerminalCommand(command:String) : Array
      {
         var index:String = null;
         var identifiedTokens:Array = null;
         var result:Array = [];
         var module:String = "";
         var functionName:String = "";
         command = StringUtil.trim(command);
         var tokens:Array = command.split(/\s+/g);
         if((tokens[0] as String).indexOf(".") != -1)
         {
            identifiedTokens = (tokens[0] as String).split(".");
            if(identifiedTokens.length != 2)
            {
               throw new Error("Command must be in the form \'[namespace].[functionName]\'");
            }
            module = identifiedTokens[0];
            functionName = identifiedTokens[1];
            result = [module,functionName];
            tokens.shift();
            for(index in tokens)
            {
               if(SPECIAL_TOKENS.hasOwnProperty(tokens[index]))
               {
                  tokens[index] = SPECIAL_TOKENS[tokens[index]];
               }
            }
            return ArrayUtils.combine(result,tokens);
         }
         throw new Error("Must specify a module in the command name \'module.functionname\'");
      }
      
      private static function callFunction(functionName:String, parameters:Array, moduleName:String) : String
      {
         var module:InGameConsoleBaseCommandsModule = null;
         var output:String = "Invalid Function Call - \'" + functionName + "\' does not exist in " + moduleName;
         if(moduleName != "")
         {
            module = InGameConsoleManager.getModuleByName(moduleName);
            if(module != null)
            {
               if(functionName in module)
               {
                  try
                  {
                     output = (module[functionName] as Function).apply(null,parameters) as String;
                  }
                  catch(error:ArgumentError)
                  {
                     output = "Wrong number of arguments: \n" + error.name + ": " + error.message;
                  }
                  catch(error:Error)
                  {
                     output = "An unknown error occurred: \n" + error.name + ": " + error.message;
                  }
               }
            }
         }
         return output;
      }
      
      private static function addNewVariable(name:String, value:*) : void
      {
         InGameConsoleTokenizerManager.m_consoleVariables[name] = value;
      }
      
      private static function removeVariable(name:String) : void
      {
         if(InGameConsoleTokenizerManager.m_consoleVariables.hasOwnProperty(name))
         {
            delete InGameConsoleTokenizerManager.m_consoleVariables.name;
         }
      }
   }
}

