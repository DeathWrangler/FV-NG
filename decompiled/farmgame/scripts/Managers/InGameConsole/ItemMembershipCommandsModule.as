package Managers.InGameConsole
{
   import Managers.FeatureOptionsManager;
   import Managers.ItemMembershipManager;
   import com.adobe.serialization.json.JSON;
   
   public class ItemMembershipCommandsModule extends InGameConsoleBaseCommandsModule
   {
      
      public function ItemMembershipCommandsModule()
      {
         super();
      }
      
      override public function get moduleName() : String
      {
         return "itemMembership";
      }
      
      public function subscribe(featureName:String, duration:int) : String
      {
         var output:String = "Subscribing to " + featureName + " with duration " + duration;
         sendTransaction("adminCall",{
            "adminController":"CPanelItemMembershipController",
            "adminCommand":"subscribe",
            "featureName":featureName,
            "duration":duration
         });
         return output;
      }
      
      public function unsubscribe(featureName:String) : String
      {
         var output:String = "Unsubscribing from " + featureName;
         sendTransaction("adminCall",{
            "adminController":"CPanelItemMembershipController",
            "adminCommand":"unsubscribe",
            "featureName":featureName
         });
         return output;
      }
      
      public function redeem(featureName:String, itemCode:String) : String
      {
         var output:String = "Redeeming " + itemCode + " from " + featureName;
         sendTransaction("adminCall",{
            "adminController":"CPanelItemMembershipController",
            "adminCommand":"redeem",
            "featureName":featureName,
            "itemCode":itemCode
         });
         Global.player.addGift(Global.farmGameSettingsManager.getFarmItemNameByCode(itemCode));
         return output;
      }
      
      public function addCredits(featureName:String, numCredits:int) : String
      {
         var output:String = "Adding " + numCredits + " credits to " + featureName;
         sendTransaction("adminCall",{
            "adminController":"CPanelItemMembershipController",
            "adminCommand":"addCredits",
            "featureName":featureName,
            "numCredits":numCredits
         });
         var featureOption:Object = ItemMembershipManager.getFeatureOption(featureName);
         featureOption[ItemMembershipManager.NUM_CREDITS] += numCredits;
         ItemMembershipManager.setFeatureOption(featureName,featureOption);
         return output;
      }
      
      public function reset(featureName:String) : String
      {
         var output:String = "Resetting feature: " + featureName;
         sendTransaction("adminCall",{
            "adminController":"CPanelItemMembershipController",
            "adminCommand":"reset",
            "featureName":featureName
         });
         FeatureOptionsManager.resetFeatureOption(featureName);
         return output;
      }
      
      public function viewFeatureData(featureName:String) : String
      {
         sendTransaction("adminCall",{
            "adminController":"CPanelItemMembershipController",
            "adminCommand":"viewFeatureData",
            "featureName":featureName
         });
         return "Frontend: \n\n" + com.adobe.serialization.json.JSON.encode(FeatureOptionsManager.getInstance().getFeatureOption(featureName)) + "\n\n";
      }
      
      public function resetFeatureLastUpdated(featureName:String) : String
      {
         sendTransaction("adminCall",{
            "adminController":"CPanelItemMembershipController",
            "adminCommand":"resetFeatureLastUpdated",
            "featureName":featureName
         });
         return "success";
      }
   }
}

