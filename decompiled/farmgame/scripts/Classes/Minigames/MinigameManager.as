package Classes.Minigames
{
   import Display.UI;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.StatsManager;
   import flash.utils.getDefinitionByName;
   
   public class MinigameManager
   {
      
      private static var s_instance:MinigameManager = null;
      
      public function MinigameManager(key:SingletonEnforcer)
      {
         super();
         if(!key)
         {
            throw new Error("Invalid MinigameManager Singleton access. Use MinigameManager.instance");
         }
      }
      
      public static function get instance() : MinigameManager
      {
         if(!s_instance)
         {
            s_instance = new MinigameManager(new SingletonEnforcer());
         }
         return s_instance;
      }
      
      public function launchMinigameWindow(gameName:String, statSource:String) : Boolean
      {
         var dialogData:DialogFeatureData = null;
         var className:String = null;
         var windowClass:Class = null;
         var gameWindow:* = undefined;
         var result:Boolean = false;
         var minigameData:MinigameData = Global.farmGameSettingsManager.getMiniGameData(gameName);
         if(minigameData != null)
         {
            if(minigameData.prereqsMet())
            {
               dialogData = minigameData.getFeatureData(MinigameConstants.FEATURE_DATA_KEY_DIALOG) as DialogFeatureData;
               if(dialogData)
               {
                  className = dialogData.dialogClass;
                  if(className)
                  {
                     try
                     {
                        windowClass = getDefinitionByName(className) as Class;
                        gameWindow = new windowClass(minigameData);
                        if(statSource)
                        {
                           StatsManager.count(gameName + "_game","impressions",statSource);
                        }
                        UI.displayPopup(gameWindow,true,className,true);
                        result = true;
                     }
                     catch(e:Error)
                     {
                        ErrorManager.addError("MinigameManager.as :: launchMinigameWindow(" + gameName + ") error: unable to create dynamic dialog class: " + className + ".  Don\'t forget to add your class to DECLARE_KNOWN_TYPES in CarnivalBoothWindow.as  Error Msg is: " + e.message);
                     }
                  }
                  else
                  {
                     ErrorManager.addError("MinigameManager.as :: launchMinigameWindow(" + gameName + ") error: in gameSettings.xml, minigame\'s dialog feature is missing <class> name.");
                  }
               }
               else
               {
                  ErrorManager.addError("MinigameManager.as :: launchMinigameWindow(" + gameName + ") error: in gameSettings.xml, minigame\'s dialog feature doesn\'t exist.");
               }
            }
            else
            {
               ErrorManager.addError("MinigameManager.as :: launchMinigameWindow(" + gameName + ") error: prereqs not met.");
            }
         }
         else
         {
            ErrorManager.addError("MinigameManager.as :: launchMinigameWindow(" + gameName + ") error: in gameSettings.xml, cannot find minigame data for " + gameName);
         }
         return result;
      }
      
      public function minigamePrereqsMet(gameName:String) : Boolean
      {
         var result:Boolean = false;
         var minigameData:MinigameData = Global.farmGameSettingsManager.getMiniGameData(gameName);
         if(minigameData != null)
         {
            result = minigameData.prereqsMet();
         }
         else
         {
            ErrorManager.addError("MinigameManager.as :: launchMinigameWindow(" + gameName + ") error: in gameSettings.xml, cannot find minigame data for " + gameName);
         }
         return result;
      }
   }
}

class SingletonEnforcer
{
   
   public function SingletonEnforcer()
   {
      super();
   }
}
