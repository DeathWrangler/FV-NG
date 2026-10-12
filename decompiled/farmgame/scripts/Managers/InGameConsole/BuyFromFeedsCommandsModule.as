package Managers.InGameConsole
{
   import Managers.BuyFromFeedsManager;
   import Managers.FeatureOptionsManager;
   
   public class BuyFromFeedsCommandsModule extends InGameConsoleBaseCommandsModule
   {
      
      public function BuyFromFeedsCommandsModule()
      {
         super();
      }
      
      override public function get moduleName() : String
      {
         return "buyFromFeeds";
      }
      
      public function addUIDsToFriendClickedArray(uids:String) : String
      {
         var friendsClickedArray:Array = null;
         var rex:RegExp = null;
         var uidArray:Array = null;
         var uid:String = null;
         var output:String = "Could not add uid to user since the feature hasn\'t yet start for the user...";
         var currentOfferBFFFeatureOption:Object = BuyFromFeedsManager.getCurrentOfferFeatureOption();
         if(currentOfferBFFFeatureOption != null)
         {
            if(currentOfferBFFFeatureOption.friendsClickedArray != null)
            {
               friendsClickedArray = currentOfferBFFFeatureOption.friendsClickedArray;
               if(friendsClickedArray != null)
               {
                  output = "Adding uids " + uids + "to the users friend clicked array...";
                  rex = /[\s\r\n]*/gim;
                  uids = uids.replace(rex,"");
                  uidArray = uids.split(",");
                  for each(uid in uidArray)
                  {
                     friendsClickedArray.push(int(uid));
                  }
                  BuyFromFeedsManager.setCurrentOfferFeatureOption(currentOfferBFFFeatureOption);
               }
            }
         }
         return output;
      }
      
      public function reset() : String
      {
         var output:String = "Resetting feature...";
         sendTransaction("adminCall",{
            "adminController":"CPanelBuyFromFeedsController",
            "adminCommand":"reset"
         });
         FeatureOptionsManager.resetFeatureOption(BuyFromFeedsManager.BUY_FROM_FEEDS_FEATURE_NAME);
         return output;
      }
   }
}

