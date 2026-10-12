package Classes.feed
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   
   public class FriendSetGoalAchievementFeed extends FarmFeed
   {
      
      private static var m_currentWindow:GenericPopup = null;
      
      private var m_callback:Function;
      
      public function FriendSetGoalAchievementFeed(bundle:String, rewardUrl:String, reward:FarmItem, guestCount:int, callback:Function = null, dialogMessageKey:String = "")
      {
         super();
         m_params.reward_link = rewardUrl;
         m_params.first_name = Global.player.firstName;
         m_params.tierGuestCount = guestCount;
         m_params.images = [{
            "src":reward.icon,
            "href":"{SN_APP_URL}" + m_params.reward_link
         }];
         this.m_callback = callback;
         m_bundleId = bundle;
         if(null == m_currentWindow)
         {
            m_currentWindow = UI.displayMessage(ZLocUtils.t("Dialogs","FriendSetGoalFeedPrompt_" + dialogMessageKey,{"item":ZLocUtils.tk_pk(reward.friendlyName)}),GenericPopup.TYPE_SHARE,this.onPrompt,"FriendSetFeed",true);
         }
      }
      
      public function onPrompt(e:GenericPopupEvent) : void
      {
         m_currentWindow = null;
         if(e.button == GenericPopup.ACCEPT)
         {
            this.publish();
         }
      }
   }
}

