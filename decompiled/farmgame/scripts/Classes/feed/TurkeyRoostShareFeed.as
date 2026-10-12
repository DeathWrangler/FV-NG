package Classes.feed
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Transactions.TCancelFriendReward;
   
   public class TurkeyRoostShareFeed extends FarmFeed
   {
      
      public function TurkeyRoostShareFeed(item:FarmItem, rewardUrl:String)
      {
         super();
         m_bundleId = "TurkeyRoostShare_" + item.name;
         m_params.reward_link = rewardUrl;
         m_params.first_name = Global.player.firstName;
         m_params.rewardItem = item.name;
         m_params.images = [{
            "src":item.icon,
            "href":"{SN_APP_URL}" + rewardUrl
         }];
      }
      
      public function startFeedFlow() : void
      {
         var message:String = ZLocUtils.t("Dialogs","TurkeyRoostSharePrompt" + m_params.rewardItem);
         UI.displayMessage(message,GenericPopup.TYPE_SHARECANCEL,this.onShare,"",false,false,"share_turkeyroost_" + m_params.rewardItem);
      }
      
      protected function onShare(event:GenericPopupEvent) : void
      {
         if(GenericPopup.ACCEPT == event.button)
         {
            this.publish();
         }
         else
         {
            TransactionManager.addTransaction(new TCancelFriendReward([m_params.reward_link]));
         }
      }
   }
}

