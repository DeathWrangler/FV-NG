package Classes.FeatureComponents
{
   import Classes.SocialRaffle.SocialRaffleConstants;
   import Classes.SocialRaffle.SocialRaffleDataView;
   import Managers.SocialRaffleManager;
   
   public class SocialRaffleContextMenuDataHelper implements IContextMenuDataHelper
   {
      
      public function SocialRaffleContextMenuDataHelper()
      {
         super();
      }
      
      public function getData(action:String) : Object
      {
         var currentFriendSet:Number = NaN;
         var friendSetCode:String = null;
         var dataView:SocialRaffleDataView = null;
         var obj:Object = {};
         switch(action)
         {
            case ContextMenuFManager.MENU_ACTION_ASK_FOR_CREW:
               currentFriendSet = 0;
               friendSetCode = "";
               dataView = SocialRaffleManager.getInstance().raffleDataView;
               if(dataView != null)
               {
                  obj.currentFriendSet = dataView.currentSet;
                  obj.friendSetCode = dataView.friendSetCode;
                  obj.featureName = SocialRaffleConstants.REQUESTS_FEATURE_NAME;
                  obj.itemName = "socialraffleticket";
               }
         }
         return obj;
      }
   }
}

