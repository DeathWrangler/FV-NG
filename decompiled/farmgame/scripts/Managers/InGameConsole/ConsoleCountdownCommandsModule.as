package Managers.InGameConsole
{
   import Managers.HolidayCountdownManager;
   
   public class ConsoleCountdownCommandsModule extends InGameConsoleBaseCommandsModule
   {
      
      public function ConsoleCountdownCommandsModule()
      {
         super();
      }
      
      override public function get moduleName() : String
      {
         return "Countdown";
      }
      
      public function checkCountdownHistory() : String
      {
         var length:int = 0;
         var NUM_COUNTDOWN_HISTORY:int = 2;
         var history:Array = HolidayCountdownManager.getCountdownCompletionHistory();
         var lastCountdownCount:int = 0;
         var beforeLastCountdownCount:int = 0;
         if(history)
         {
            length = int(history.length);
            if(length >= NUM_COUNTDOWN_HISTORY)
            {
               lastCountdownCount = int(history[length - 1]);
               beforeLastCountdownCount = int(history[length - NUM_COUNTDOWN_HISTORY]);
            }
            else if(length == 1)
            {
               lastCountdownCount = int(history[0]);
            }
         }
         var lastCountdownCountString:String = "Last Countdown Prize Count: " + lastCountdownCount + "\n";
         var beforeLastCountdownCountString:String = "Countdown Before Last Prize Count: " + beforeLastCountdownCount + "\n";
         return lastCountdownCountString + beforeLastCountdownCountString;
      }
      
      public function addHolidayCountdownProgressByIndex(index:int) : String
      {
         var itemCode:String = HolidayCountdownManager.getItemCodeByIndex(index);
         var itemName:String = Global.farmGameSettingsManager.getFarmItemNameByCode(itemCode);
         sendTransaction("adminCall",{
            "adminController":"CPanelCountdownsController",
            "adminCommand":"addHolidayCountdownProgress",
            "reward":itemCode
         });
         HolidayCountdownManager.addProgressForFirstReward(index);
         HolidayCountdownManager.refreshDialog();
         return "Countdown progress for prize: " + itemName + " is increased";
      }
      
      public function resetFeature() : String
      {
         sendTransaction("adminCall",{
            "adminController":"CPanelCountdownsController",
            "adminCommand":"resetHolidayCountdownUserData"
         });
         return "Holiday Countdown User Data Successfully Reset! Reload the app to see the changes";
      }
      
      public function setUpForCompletionTesting() : String
      {
         sendTransaction("adminCall",{
            "adminController":"CPanelCountdownsController",
            "adminCommand":"onSetupHolidayCountdownUserDataForCompletion"
         });
         return "Holiday Countdown setUpForCompletionTesting! Reload the app to see the changes ";
      }
      
      public function viewRewardItemProgress() : String
      {
         var result:String = "";
         var index:int = 0;
         var itemCode:String = HolidayCountdownManager.getItemCodeByIndex(index);
         while(itemCode != "")
         {
            result = result + Global.farmGameSettingsManager.getFarmItemNameByCode(itemCode) + " Progress to next reward is:" + HolidayCountdownManager.getProgressToNextReward(index) + "\n";
            index++;
            itemCode = HolidayCountdownManager.getItemCodeByIndex(index);
         }
         return result;
      }
   }
}

