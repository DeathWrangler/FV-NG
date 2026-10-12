package Managers.InGameConsole
{
   import Classes.FeatureDataObjects.VotingDataObject;
   import Managers.LicenseManager;
   import Managers.VotingDataManager;
   import com.adobe.serialization.json.JSON;
   
   public class ConsoleVotingFeatureCommandsModule extends InGameConsoleBaseCommandsModule
   {
      
      private var m_featureName:String = "";
      
      public function ConsoleVotingFeatureCommandsModule()
      {
         super();
      }
      
      override public function get moduleName() : String
      {
         return "VotingFeature";
      }
      
      public function setVotingFeature(featureName:String) : String
      {
         var message:String = null;
         if(this.isActiveVotingFeature(featureName))
         {
            this.m_featureName = featureName;
            message = featureName + " Is set as the Active Voting Feature. ";
         }
         else
         {
            message = featureName + " Is NOT an Active Voting Feature. ";
         }
         return message;
      }
      
      public function instructionsForUse() : String
      {
         return "Run a command on the currently active voting feature,\n" + "If ther is more than one feature Active Console will prompt you to \n" + "enter one of the active features into the module.";
      }
      
      public function printAllVotingFeatureNames() : String
      {
         var voteFeatures:Array = VotingDataManager.getInstance().getAllVotingFeatures();
         return com.adobe.serialization.json.JSON.encode(voteFeatures);
      }
      
      public function removeAllLicences() : String
      {
         sendTransaction("adminCall",{
            "adminController":"CPanelGeneralController",
            "adminCommand":"resetLicenses"
         });
         LicenseManager.getInstance().resetLicenses();
         return "All Licenses removed when Transaction completes ";
      }
      
      public function resetFeature() : String
      {
         var message:String = null;
         var featureName:String = null;
         if(this.hasUniqueChoice())
         {
            featureName = this.getFeatureName();
            sendTransaction("adminCall",{
               "adminController":"CPanelHolidayBasketsController",
               "adminCommand":"resetVotingFeature",
               "featureName":featureName
            });
            message = "Voting Feature is reset. Refresh Browser when the transaction completes. ";
         }
         else
         {
            message = this.getFeatureNotSetText();
         }
         return message;
      }
      
      public function getAppFriendUIDs() : String
      {
         return com.adobe.serialization.json.JSON.encode(Global.friendManager.appFriendUids);
      }
      
      public function addNaughtyVotesByUID(uid:String) : String
      {
         var message:String = null;
         var featureName:String = null;
         var friendSetCode:String = null;
         if(this.hasUniqueChoice())
         {
            featureName = this.getFeatureName();
            friendSetCode = VotingDataManager.getInstance().getDataObject(featureName).friendSetCode;
            sendTransaction("adminCall",{
               "adminController":"CPanelHolidayBasketsController",
               "adminCommand":"addVotesToFeature",
               "featureName":featureName,
               "vote":"0",
               "uids":uid
            });
            message = " Naughty vote sent for" + featureName + " Refresh to see changes";
         }
         else
         {
            message = this.getFeatureNotSetText();
         }
         return message;
      }
      
      public function addNiceVotesByUID(uid:String) : String
      {
         var message:String = null;
         var featureName:String = null;
         var friendSetCode:String = null;
         if(this.hasUniqueChoice())
         {
            featureName = this.getFeatureName();
            friendSetCode = VotingDataManager.getInstance().getDataObject(featureName).friendSetCode;
            sendTransaction("adminCall",{
               "adminController":"CPanelHolidayBasketsController",
               "adminCommand":"addVotesToFeature",
               "featureName":featureName,
               "vote":"1",
               "uids":uid
            });
            message = " Naughty vote sent for" + featureName + " Refresh to see changes";
         }
         else
         {
            message = this.getFeatureNotSetText();
         }
         return message;
      }
      
      public function viewFeatureData() : String
      {
         var message:String = null;
         var featureName:String = null;
         var voteObj:VotingDataObject = null;
         if(this.hasUniqueChoice())
         {
            featureName = this.getFeatureName();
            voteObj = VotingDataManager.getInstance().getDataObject(featureName);
            message = com.adobe.serialization.json.JSON.encode(voteObj);
         }
         else
         {
            message = this.getFeatureNotSetText();
         }
         return message;
      }
      
      private function hasUniqueChoice() : Boolean
      {
         return this.isActiveVotingFeature(this.m_featureName) || VotingDataManager.getInstance().getAllVotingFeatures().length == 1;
      }
      
      private function getFeatureNotSetText() : String
      {
         return "Enter one of the active feature names into the set Voting Feature box: " + this.printAllVotingFeatureNames();
      }
      
      private function getFeatureName() : String
      {
         var name:String = "";
         if(this.isActiveVotingFeature(this.m_featureName))
         {
            name = this.m_featureName;
         }
         else if(VotingDataManager.getInstance().getAllVotingFeatures().length > 0)
         {
            name = VotingDataManager.getInstance().getAllVotingFeatures()[0];
         }
         return name;
      }
      
      private function isActiveVotingFeature(featureName:String) : Boolean
      {
         var voteFeatures:Array = VotingDataManager.getInstance().getAllVotingFeatures();
         return featureName in voteFeatures;
      }
   }
}

