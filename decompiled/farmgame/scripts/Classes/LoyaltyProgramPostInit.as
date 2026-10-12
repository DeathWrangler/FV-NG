package Classes
{
   import Display.UI;
   import Managers.LoyaltyProgramManager;
   import Widgets.Windows.LoyaltyProgramGoldenFarmerWindow;
   
   public class LoyaltyProgramPostInit
   {
      
      public function LoyaltyProgramPostInit()
      {
         super();
      }
      
      public static function notifyGoldenFarmerStatus(initParams:Object) : void
      {
         if(LoyaltyProgramManager.getInstance().shouldNotifyGoldenFarmer())
         {
            UI.displayPopup(new LoyaltyProgramGoldenFarmerWindow());
         }
      }
   }
}

