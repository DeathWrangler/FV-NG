package Transactions
{
   import Classes.Friend;
   import Display.UI;
   import Managers.FarmStatsManager;
   import Widgets.Windows.ExpansionInviteWindow;
   
   public class TExpansionInvite extends TFarmTransaction
   {
      
      private static const PERCENTAGE_REQUIRED_GOOD_FRIENDS:Number = 0.8;
      
      private var m_worldType:String;
      
      public function TExpansionInvite(worldType:String)
      {
         this.m_worldType = worldType;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("W2WFeatureService.getAllFeatureFriends",ExpansionInviteWindow.EXPANSION_INVITE_FEATURE_NAME,ExpansionInviteWindow.EXPANSION_INVITE_FEED_NAME);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var validFriendList:Array = null;
         var percentGoodFriends:Number = NaN;
         var fullFriendList:Array = new Array();
         if(result.hasOwnProperty("friends") && result.friends is Array)
         {
            fullFriendList = result.friends;
         }
         if(this.m_worldType == Global.worldManager.currentWorldType)
         {
            if(fullFriendList.length > 0)
            {
               validFriendList = this.validateFriendList(fullFriendList);
               percentGoodFriends = validFriendList.length / fullFriendList.length;
               if(percentGoodFriends > PERCENTAGE_REQUIRED_GOOD_FRIENDS)
               {
                  FarmStatsManager.count("expansioninvite","friend_data","percent_valid_passed",validFriendList.length.toString(),fullFriendList.length.toString());
                  UI.displayPopup(new ExpansionInviteWindow(validFriendList,this.m_worldType));
               }
               else
               {
                  FarmStatsManager.count("expansioninvite","friend_data","percent_valid_failed",validFriendList.length.toString(),fullFriendList.length.toString());
               }
            }
            else
            {
               FarmStatsManager.count("expansioninvite","transaction","complete_nofriends");
               Global.player.setSeenFlag(ExpansionInviteWindow.EXPANSION_INVITE_SEEN_FLAG);
            }
         }
      }
      
      private function validateFriendList(friendUids:Array) : Array
      {
         var uid:String = null;
         var friend:Friend = null;
         var validFriends:Array = new Array();
         if(friendUids.length > 0)
         {
            for each(uid in friendUids)
            {
               friend = Global.friendManager.getAppFriendData(uid);
               if(Boolean(friend && friend.name != null && friend.name != "") && Boolean(friend.firstName != null) && friend.firstName != "")
               {
                  validFriends.push(uid);
               }
            }
         }
         return validFriends;
      }
   }
}

