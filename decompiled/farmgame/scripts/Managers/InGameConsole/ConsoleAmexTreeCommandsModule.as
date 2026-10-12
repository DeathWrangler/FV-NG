package Managers.InGameConsole
{
   import Display.UI;
   import Managers.FeatureOptionsManager;
   import Widgets.Windows.Amex.AmexTreeStatusWindow;
   
   public class ConsoleAmexTreeCommandsModule extends InGameConsoleBaseCommandsModule
   {
      
      public static var altPlacementId:String = "";
      
      public function ConsoleAmexTreeCommandsModule()
      {
         super();
      }
      
      override public function get moduleName() : String
      {
         return "amextree";
      }
      
      public function popDialog() : String
      {
         UI.displayPopup(new AmexTreeStatusWindow());
         return "Popped";
      }
      
      public function setAltPlacementId(newId:String) : String
      {
         altPlacementId = newId;
         if(newId == "")
         {
            return "Placement ID reset to normal";
         }
         return "Placement ID for ad is now: " + altPlacementId + "\nTo reset, please enter empty string";
      }
      
      public function hitPayments(eventType:String, quantity:int = 0) : String
      {
         sendTransaction("adminCall",{
            "adminController":"CPanelMiscellaneousController",
            "adminCommand":"amexTreePaymentsCall",
            "eventType":eventType,
            "quantity":quantity
         });
         return "Transaction sent with eventType: " + eventType + "\nand quantity of cash granted: " + quantity.toString();
      }
      
      public function getPaymentsStatus() : String
      {
         return InGameConsoleManager.traceObjectData(FeatureOptionsManager.getInstance().getFeatureOption("affiliateData","amextree"));
      }
      
      public function getTreeStatus() : String
      {
         return InGameConsoleManager.traceObjectData(FeatureOptionsManager.getInstance().getFeatureOption("amex_tree"));
      }
      
      public function getCurrentAmexTreeLink() : String
      {
         if(UI.getCurrentPopup() is AmexTreeStatusWindow)
         {
            return (UI.getCurrentPopup() as AmexTreeStatusWindow).getAmexTreeLink();
         }
         return "Amex Tree Dialog not popped currently, please pop the dialog";
      }
      
      public function setConvertSeenFlag() : String
      {
         Global.player.setSeenFlag(AmexTreeStatusWindow.AMEX_TREE_CONVERT_SEEN_FLAG);
         return "You\'re now a converted AmexTree user. Reset the \'" + AmexTreeStatusWindow.AMEX_TREE_CONVERT_SEEN_FLAG + "\' seen flag to become a normal signup user again";
      }
      
      public function getTreeSeenFlag() : String
      {
         return Global.player.getSeenFlag("amextree_initialzed") ? "amextree_initialzed is set" : "amextree_initialzed is not set";
      }
      
      public function isConvertUser() : String
      {
         return Global.player.getSeenFlag(AmexTreeStatusWindow.AMEX_TREE_CONVERT_SEEN_FLAG) ? AmexTreeStatusWindow.AMEX_TREE_CONVERT_SEEN_FLAG + " is set" : AmexTreeStatusWindow.AMEX_TREE_CONVERT_SEEN_FLAG + " is not set";
      }
      
      public function setMakeGoodSeenFlag() : String
      {
         Global.player.setSeenFlag(AmexTreeStatusWindow.AMEX_TREE_MAKEGOOD_SEEN_FLAG);
         return "You\'re now an AmexTree user that has received make good payment. Reset the \'" + AmexTreeStatusWindow.AMEX_TREE_MAKEGOOD_SEEN_FLAG + "\' seen flag to become a normal user again";
      }
      
      public function isMakeGoodUser() : String
      {
         return Global.player.getSeenFlag(AmexTreeStatusWindow.AMEX_TREE_MAKEGOOD_SEEN_FLAG) ? AmexTreeStatusWindow.AMEX_TREE_MAKEGOOD_SEEN_FLAG + " is set" : AmexTreeStatusWindow.AMEX_TREE_MAKEGOOD_SEEN_FLAG + " is not set";
      }
      
      public function resetTreeStatus() : String
      {
         sendTransaction("adminCall",{
            "adminController":"CPanelMiscellaneousController",
            "adminCommand":"amexTreeStatusReset"
         });
         return "Resetting Payment status in feature options manager under \'affiliateData\' and \'amex_tree\' and reset seen flag \'amextree_initialzed\'";
      }
   }
}

