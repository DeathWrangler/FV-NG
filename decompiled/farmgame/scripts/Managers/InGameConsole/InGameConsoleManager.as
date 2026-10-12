package Managers.InGameConsole
{
   import Classes.util.ZLocUtils;
   import Engine.Managers.InputManager;
   import Engine.Managers.TransactionManager;
   import Engine.Utilities;
   import Managers.FarmStatsManager;
   import fl.controls.UIScrollBar;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.display.StageDisplayState;
   import flash.events.KeyboardEvent;
   import flash.external.ExternalInterface;
   import flash.text.TextField;
   import flash.text.TextFieldType;
   import flash.text.TextFormat;
   import flash.ui.Keyboard;
   import flash.utils.describeType;
   import flash.utils.getQualifiedClassName;
   
   public class InGameConsoleManager
   {
      
      private static var m_consoleBitmap:Bitmap;
      
      private static var m_consoleSprite:Sprite;
      
      private static var m_textField:TextField;
      
      private static var m_historyTextField:TextField;
      
      public static const HISTORY_SCROLLBAR_WIDTH_PX:int = 20;
      
      public static var CONSOLE_STATS_COUNTER_FIELD:String = "in_game_console";
      
      private static var m_showDebugOptions:Boolean = false;
      
      private static var m_consoleIsOn:Boolean = false;
      
      private static var m_firstTimeRunningConsole:Boolean = true;
      
      private static var m_historyScrollBar:UIScrollBar = null;
      
      private static var m_savedHistory:String = "";
      
      private static var m_statsFilterWords:Array = ["","","","","",""];
      
      public static var showWorldGrid:Boolean = false;
      
      public static var updateWorldGrid:Boolean = false;
      
      private static var m_allCommands:Array = [];
      
      private static var m_pastCommands:Array = [];
      
      private static var m_pastCommandIndex:int = -1;
      
      private static var m_autoGenerateRan:Boolean = false;
      
      private static const allCommandsModules:Array = [ConsoleEXAMPLECommandsModule,ConsoleStandardCommandsModule,ConsoleCraftingCommandsModule,ConsoleFrontEndCommandsModule,ConsoleWatchToEarnCommandsModule,ConsoleAmexTreeCommandsModule,ConsoleGophersCommandsModule,ConsoleCountdownCommandsModule,ConsoleVotingFeatureCommandsModule,ConsoleUGCDecoCommandsModule,ConsoleAnglerCommandsModule,BuyFromFeedsCommandsModule,ItemMembershipCommandsModule,ConsoleFeatureCraftingCommandsModule,ConsoleUserTTLDataCommandsModule,ConsoleAOECommandsModule];
      
      private static var m_activeModules:Array = [];
      
      public function InGameConsoleManager()
      {
         super();
      }
      
      public static function isConsoleOn() : Boolean
      {
         return m_consoleIsOn;
      }
      
      public static function get activeModules() : Array
      {
         return m_activeModules;
      }
      
      public static function getModuleByName(moduleName:String) : InGameConsoleBaseCommandsModule
      {
         var module:InGameConsoleBaseCommandsModule = null;
         var result:InGameConsoleBaseCommandsModule = null;
         for each(module in InGameConsoleManager.activeModules)
         {
            if(Boolean(module) && module.moduleName == moduleName)
            {
               result = module;
               break;
            }
         }
         return result;
      }
      
      public static function isModuleLoaded(moduleName:String) : Boolean
      {
         var loadedModule:InGameConsoleBaseCommandsModule = null;
         var loaded:Boolean = false;
         for each(loadedModule in m_activeModules)
         {
            if(loadedModule.moduleName == moduleName)
            {
               loaded = true;
               break;
            }
         }
         return loaded;
      }
      
      private static function loadAllModules() : void
      {
         var loadedModule:Class = null;
         var module:InGameConsoleBaseCommandsModule = null;
         for each(loadedModule in allCommandsModules)
         {
            module = new loadedModule();
            if(isModuleLoaded(module.moduleName) == false)
            {
               m_activeModules.push(module);
            }
         }
      }
      
      public static function startConsole() : void
      {
         var stage:Stage = null;
         var bData:BitmapData = null;
         var rect:Shape = null;
         var format:TextFormat = null;
         if(!isConsoleOn())
         {
            stage = Global.stage;
            bData = new BitmapData(stage.stageWidth,stage.stageHeight * 2 / 3,false,0);
            m_allCommands = InGameConsoleTokenizerManager.getAllCommands();
            if(Global.stage.displayState == StageDisplayState.FULL_SCREEN)
            {
               Global.stage.displayState = StageDisplayState.NORMAL;
            }
            TransactionManager.additionalSignedParams.authBypass = "1";
            rect = new Shape();
            rect.graphics.beginFill(0,0.6);
            rect.graphics.drawRect(0,0,stage.stageWidth,stage.stageHeight * 2 / 3);
            rect.graphics.endFill();
            bData.draw(rect);
            createConsoleSprite(bData);
            format = new TextFormat();
            format.font = "_typewriter";
            m_textField = new TextField();
            m_textField.text = "> ";
            m_textField.textColor = 16777215;
            m_textField.background = true;
            m_textField.height = 20;
            m_textField.backgroundColor = 2236962;
            m_textField.type = TextFieldType.INPUT;
            m_textField.border = true;
            m_textField.x = 10;
            m_textField.y = 10;
            m_textField.width = stage.stageWidth;
            m_textField.multiline = false;
            m_textField.addEventListener(KeyboardEvent.KEY_DOWN,InGameConsoleManager.inputFieldBehavior);
            m_textField.setTextFormat(format);
            m_consoleSprite.addChild(m_textField);
            m_historyTextField = new TextField();
            if(m_firstTimeRunningConsole)
            {
               m_firstTimeRunningConsole = false;
               m_savedHistory += ZLocUtils.t("FarmGame","InGameConsoleFunction_std.help");
            }
            m_historyTextField.text = m_savedHistory;
            m_historyTextField.textColor = 14540253;
            m_historyTextField.type = TextFieldType.DYNAMIC;
            m_historyTextField.border = true;
            m_historyTextField.x = 10;
            m_historyTextField.y = 30;
            m_historyTextField.height = stage.stageHeight * 2 / 3 - m_historyTextField.y;
            m_historyTextField.width = stage.stageWidth - HISTORY_SCROLLBAR_WIDTH_PX;
            m_historyTextField.multiline = true;
            m_historyTextField.wordWrap = true;
            m_historyTextField.addEventListener(KeyboardEvent.KEY_DOWN,InGameConsoleManager.historyFieldBehavior);
            m_historyTextField.setTextFormat(format);
            m_consoleSprite.addChild(m_historyTextField);
            stage.addChild(m_consoleSprite);
            Global.stage.focus = m_textField;
            m_consoleIsOn = true;
            FarmStatsManager.count(CONSOLE_STATS_COUNTER_FIELD,"view");
            if(InGameConsoleManager.activeModules.length == 0)
            {
               InGameConsoleManager.loadAllModules();
            }
         }
      }
      
      private static function inputFieldBehavior(event:KeyboardEvent) : void
      {
         var command:String = null;
         var autoCompletedCommands:Array = null;
         var autoCompletedString:String = null;
         if(m_textField.caretIndex <= 2)
         {
            m_textField.setSelection(2,2);
            if(event.keyCode == 8)
            {
               m_textField.text = m_textField.text.substring(0,1) + " " + m_textField.text.substr(1);
            }
            event.stopImmediatePropagation();
         }
         switch(event.keyCode)
         {
            case Keyboard.F6:
               command = m_textField.text.substring(2);
               autoCompletedCommands = InGameConsoleTokenizerManager.getAllCommands(command);
               if(autoCompletedCommands.length >= 1)
               {
                  autoCompletedString = InGameConsoleTokenizerManager.autoCompleteCommand(command);
                  if(autoCompletedString == command && autoCompletedCommands.length > 1)
                  {
                     writeToHistory(autoCompletedCommands.join(" \t "));
                  }
                  else
                  {
                     m_textField.text = "> " + autoCompletedString;
                  }
               }
               m_textField.setSelection(m_textField.length,m_textField.length);
               break;
            case 40:
               if(m_pastCommandIndex < m_pastCommands.length - 1)
               {
                  m_textField.text = "> " + m_pastCommands[++m_pastCommandIndex];
               }
               break;
            case 38:
               if(m_pastCommandIndex > 0)
               {
                  m_textField.text = "> " + m_pastCommands[--m_pastCommandIndex];
               }
               else if(m_pastCommandIndex == 0)
               {
                  --m_pastCommandIndex;
                  m_textField.text = "> ";
               }
               break;
            case 13:
               executeCommand(m_textField.text.substring(2));
               break;
            case Keyboard.F5:
               InGameConsoleManager.closeConsole();
         }
      }
      
      public static function simulateCommand(functionName:String, params:Array, moduleName:String) : void
      {
         var param:* = undefined;
         var command:String = moduleName;
         if(command != "")
         {
            command += ".";
         }
         command += functionName + " ";
         if(params != null && params.length != 0)
         {
            for each(param in params)
            {
               command += param.toString() + " ";
            }
         }
         executeCommand(command);
      }
      
      public static function autoGenerateLiveCommands() : void
      {
         var classInfo:XML = null;
         var commands:Array = null;
         var module:* = undefined;
         var moduleName:String = null;
         var method:XML = null;
         var args:Array = null;
         var parameter:XML = null;
         var methodName:String = null;
         var parameterType:String = null;
         if(m_autoGenerateRan == false)
         {
            if(InGameConsoleManager.activeModules.length == 0)
            {
               InGameConsoleManager.loadAllModules();
            }
            m_autoGenerateRan = true;
            commands = [];
            for each(module in InGameConsoleManager.activeModules)
            {
               moduleName = (module as InGameConsoleBaseCommandsModule).moduleName;
               classInfo = describeType(module);
               for each(method in classInfo..method)
               {
                  if(method.@returnType == "String")
                  {
                     args = [];
                     for each(parameter in method..parameter)
                     {
                        parameterType = parameter.@type;
                        args.push({"type":parameterType});
                     }
                     methodName = method.@name;
                     commands.push({
                        "namespace":moduleName,
                        "functionName":methodName,
                        "args":args
                     });
                  }
               }
               commands.sort();
            }
            ExternalInterface.call("autoGenerateAdminCommands",commands);
         }
      }
      
      private static function executeCommand(command:String) : void
      {
         if(InGameConsoleManager.activeModules.length == 0)
         {
            InGameConsoleManager.loadAllModules();
         }
         var output:String = InGameConsoleTokenizerManager.executeCommand(command);
         if(command != "")
         {
            m_pastCommands.unshift(command);
         }
         m_pastCommandIndex = -1;
         ExternalInterface.call("writeToAdminTextField",output + "\n\n");
         if(m_historyTextField != null && Boolean(m_textField))
         {
            if(output != "")
            {
               m_historyTextField.text = m_textField.text.concat("\n",output,"\n",m_historyTextField.text);
            }
            else
            {
               m_historyTextField.text = m_textField.text.concat("\n",m_historyTextField.text);
            }
            m_textField.text = "> ";
            m_historyTextField.scrollV = 1;
            correctHistoryTextFieldFont();
         }
      }
      
      private static function correctHistoryTextFieldFont() : void
      {
         var format:TextFormat = new TextFormat();
         format.font = "_typewriter";
         m_historyTextField.setTextFormat(format);
         if(m_historyScrollBar)
         {
            m_historyScrollBar.scrollTarget = m_historyTextField;
         }
      }
      
      private static function historyFieldBehavior(event:KeyboardEvent) : void
      {
         if(event.keyCode == 40)
         {
            m_historyTextField.scrollV += 1;
         }
         if(event.keyCode == 38)
         {
            --m_historyTextField.scrollV;
         }
      }
      
      public static function startStatsLogging(counter:String = "", kingdom:String = "", phylum:String = "", zclass:String = "", family:String = "", genus:String = "") : void
      {
         m_statsFilterWords = [counter,kingdom,phylum,zclass,family,genus];
      }
      
      public static function stopStatsLogging() : void
      {
         m_statsFilterWords = null;
      }
      
      public static function writeObjectToConsole(object:Object) : void
      {
         var message:String = InGameConsoleManager.traceObjectData(object);
         InGameConsoleManager.writeToHistory(message);
      }
      
      public static function traceObjectData(variable:Object, indent:String = "") : String
      {
         var className:String = null;
         var index:String = null;
         var objectValue:String = null;
         var message:String = "NULL";
         if(variable != null)
         {
            message = "";
            className = getQualifiedClassName(variable);
            if(className == "Object" || className == "Array")
            {
               message += "\n";
               for(index in variable)
               {
                  objectValue = traceObjectData(variable[index],indent + "  ");
                  message += indent + index + ": " + objectValue + "\n";
               }
            }
            else
            {
               message = variable.toString();
            }
         }
         return message;
      }
      
      public static function consoleStatsDisplay(counter:String, kingdom:String = "", phylum:String = "", zclass:String = "", family:String = "", genus:String = "", value:int = 1) : void
      {
         var statsValuesArr:Array = null;
         var match:Boolean = false;
         var i:int = 0;
         if(Config.DEBUG_MODE && m_statsFilterWords != null)
         {
            statsValuesArr = [counter,kingdom,phylum,zclass,family,genus];
            match = true;
            for(i = 0; i < m_statsFilterWords.length; i++)
            {
               if(m_statsFilterWords[i].length != 0 && (!statsValuesArr[i] || statsValuesArr[i].indexOf(m_statsFilterWords[i]) == -1))
               {
                  match = false;
                  break;
               }
            }
            if(match)
            {
               ExternalInterface.call("writeToFrontStatsTable",counter,kingdom,phylum,zclass,family,genus,value);
            }
         }
      }
      
      public static function writeToHistory(message:String) : void
      {
         var consoleMessagePrefix:String = null;
         var recordedMessage:String = null;
         if(Config.DEBUG_MODE)
         {
            consoleMessagePrefix = "! >> ";
            recordedMessage = message.replace(/\n/g,"\n" + consoleMessagePrefix);
            if(InGameConsoleManager.isConsoleOn())
            {
               m_historyTextField.text = consoleMessagePrefix.concat(recordedMessage,"\n",m_historyTextField.text);
               correctHistoryTextFieldFont();
            }
            else
            {
               m_savedHistory = consoleMessagePrefix.concat(recordedMessage,"\n",m_savedHistory);
            }
            ExternalInterface.call("writeToAdminTextField",message + "\n");
         }
      }
      
      public static function closeConsole() : void
      {
         var stage:Stage = null;
         if(m_consoleSprite)
         {
            m_savedHistory = m_historyTextField.text;
            stage = Global.stage;
            stage.removeChild(m_consoleSprite);
            if(m_consoleBitmap.bitmapData)
            {
               m_consoleBitmap.bitmapData.dispose();
            }
            m_consoleSprite = null;
            m_consoleBitmap = null;
            m_textField.removeEventListener(KeyboardEvent.KEY_DOWN,InGameConsoleManager.inputFieldBehavior);
            m_textField = null;
            m_historyTextField.removeEventListener(KeyboardEvent.KEY_DOWN,InGameConsoleManager.historyFieldBehavior);
            m_historyTextField = null;
            InputManager.enableInput();
            m_consoleIsOn = false;
            Global.stage.focus = null;
         }
      }
      
      protected static function createConsoleSprite(bData:BitmapData, mouseFunc:Function = null) : void
      {
         m_consoleBitmap = new Bitmap(bData);
         m_consoleSprite = new Sprite();
         m_consoleSprite.addChild(m_consoleBitmap);
         if(mouseFunc != null)
         {
            Utilities.toggleInputAndChildren(m_consoleSprite,true);
         }
      }
   }
}

