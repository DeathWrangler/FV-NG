package Widgets.Windows.MOTD
{
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Managers.SubscriptionsManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.TextFields.FarmTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class SubscriptionStreakRestoredMOTDWindow extends CustomWindowMOTDBase
   {
      
      private static const ASSET_PATH:String = "assets/dialogs/Subscriptions/SubUpgrade2019v2/FV_SubUpgrade2019_ExRestored_MOTD.swf";
      
      public function SubscriptionStreakRestoredMOTDWindow()
      {
         super(ASSET_PATH);
      }
      
      public static function display(source:String) : void
      {
         var popup:SubscriptionStreakRestoredMOTDWindow = new SubscriptionStreakRestoredMOTDWindow();
         UI.displayPopup(popup);
         FarmStatsManager.count("MOTD","impressions","MOTD_subs_strkrest_postsignup");
      }
      
      override protected function postLoadComplete() : void
      {
         var benefts:MovieClip = null;
         super.postLoadComplete();
         var subLevel:int = SubscriptionsManager.instance.getSubscriptionLevel();
         var subLevelString:String = SubscriptionsManager.instance.getSubscriptionLevelText(subLevel);
         if(m_window.hasOwnProperty("mainWindow"))
         {
            addWidget(new ZwBaseWidget(m_window.mainWindow));
            if(m_window.mainWindow["title_tf"])
            {
               addWidget(new FarmTextField(m_window.mainWindow.title_tf,ZLocUtils.t("Dialogs","Subscription2016_restored_title")));
            }
            if(m_window.mainWindow["subtitle_tf"])
            {
               addWidget(new FarmTextField(m_window.mainWindow.subtitle_tf,ZLocUtils.t("Dialogs","Subscription2016_restored_subtitle",{"sublevel":subLevelString})));
            }
            if(m_window.mainWindow["body_tf"])
            {
               addWidget(new FarmTextField(m_window.mainWindow.body_tf,ZLocUtils.t("Dialogs","Subscription2016_restored_body")));
            }
            if(m_window.mainWindow["accept_bt"])
            {
               addWidget(new FarmAnimatedTextButton(m_window.mainWindow.accept_bt,"Awesome!",this.onClickMore));
            }
            if(m_window.mainWindow["close_bt"])
            {
               addWidget(new FarmButton(m_window.mainWindow.close_bt,this.onClose));
            }
            if(m_window.mainWindow["benefits_mc"])
            {
               benefts = m_window.mainWindow.benefits_mc as MovieClip;
               benefts.gotoAndStop(subLevel);
            }
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         this.grantRewardSet();
         super.onClose(event);
      }
      
      private function grantRewardSet() : *
      {
         if(!Global.player.getSeenFlag(SubscriptionsManager.REVAMP_REWARD_GRANT_FLAG))
         {
            Global.player.addGift("subscription_reward_bundle");
            TransactionManager.addTransaction(new TGenericTransaction("SubscriptionsService","grantRevampRewardBundle",null),true);
            Global.player.setSeenFlag(SubscriptionsManager.RESTORED_MOTD_SEEN_FLAG,true);
         }
      }
      
      private function onClickMore(event:Event) : void
      {
         this.grantRewardSet();
         FarmStatsManager.count("MOTD","click","MOTD_subs_strkrest_postsignup");
         super.onClose(event);
      }
   }
}

