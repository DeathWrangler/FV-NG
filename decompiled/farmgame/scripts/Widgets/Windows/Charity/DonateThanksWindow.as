package Widgets.Windows.Charity
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.FarmWindow;
   import flash.events.MouseEvent;
   import flash.net.*;
   
   public class DonateThanksWindow extends FarmWindow
   {
      
      protected var m_thanksItem:FarmItem = null;
      
      protected var m_localizationKey:String = null;
      
      protected var m_feedImage:String = null;
      
      protected var m_mainFrame:ZwFrame = null;
      
      protected var m_rewardName:String = "";
      
      protected var m_rewardLink:String = "";
      
      public function DonateThanksWindow(thanksItem:FarmItem, rewardName:String = "", rewardLink:String = "", receivedItem:FarmItem = null)
      {
         var receivedItemNewsfeed:String = null;
         this.m_rewardName = rewardName;
         this.m_rewardLink = rewardLink;
         this.m_thanksItem = thanksItem;
         this.m_localizationKey = thanksItem.name;
         this.m_feedImage = thanksItem.newsfeed;
         if(receivedItem != null)
         {
            this.m_localizationKey = receivedItem.name;
            receivedItemNewsfeed = receivedItem.newsfeed;
            if(receivedItemNewsfeed != null)
            {
               this.m_feedImage = receivedItemNewsfeed;
            }
         }
         this.name = "DonateThanksWindow" + thanksItem.name;
         var dialogAsset:String = "assets/dialogs/FV_Campaign_" + thanksItem.name + "_thanks.swf";
         super(dialogAsset);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         this.m_mainFrame = addWidget(new ZwFrame(m_window.mainThanks_mc)) as ZwFrame;
         this.m_mainFrame.addWidget(new FarmAnimatedButton(m_window.mainThanks_mc.share_bt,this.onShareClick));
         if(m_window.mainThanks_mc.hasOwnProperty("skip_bt"))
         {
            this.m_mainFrame.addWidget(new FarmAnimatedButton(m_window.mainThanks_mc.skip_bt,this.onSkipClick));
         }
         this.m_mainFrame.addWidget(new ZwTextField(m_window.mainThanks_mc.congrats_tf,ZLocUtils.t("Dialogs","Campaign_DonateThanksTitle")));
         var bodyTxtIdx:int = 0;
         while(m_window.mainThanks_mc.hasOwnProperty("body" + bodyTxtIdx + "_tf"))
         {
            this.m_mainFrame.addWidget(new ZwTextField(m_window.mainThanks_mc["body" + bodyTxtIdx + "_tf"],ZLocUtils.t("Dialogs","Campaign_DonateThanksBody" + bodyTxtIdx + "_" + this.m_localizationKey)));
            bodyTxtIdx++;
         }
         if(m_window.mainThanks_mc.info_bt)
         {
            addWidget(new FarmAnimatedTextButton(m_window.mainThanks_mc.info_bt,ZLocUtils.t("Dialogs","Campaign_DonateThanks_ClickHereText"),this.onMoreInfoClick));
         }
      }
      
      protected function onMoreInfoClick(event:MouseEvent) : void
      {
         var url:String = ZLocUtils.t("Dialogs","Campaign_DonateThanks_ClickHereUrl");
         navigateToURL(new URLRequest(url),"_blank");
      }
      
      private function onShareClick(event:MouseEvent) : void
      {
         var images:Array = [];
         images.push({
            "src":this.m_feedImage,
            "href":"{SN_APP_URL}{creative:picture}" + this.m_rewardLink
         });
         GlobalEngine.socialNetwork.publishFeedStory("Campaign_Donate_" + this.m_localizationKey,{
            "friend":Global.player.snUser.firstName,
            "images":images,
            "reward_link":this.m_rewardLink
         },[],false);
         FarmStatsManager.count("charity_" + this.m_thanksItem.name,"feed_share","accept");
         FarmStatsManager.count("Shortfeed","Donate",this.m_thanksItem.name,"Share");
         close();
      }
      
      private function onSkipClick(event:MouseEvent) : void
      {
         FarmStatsManager.count("charity_" + this.m_thanksItem.name,"feed_share","cancel");
         FarmStatsManager.count("Shortfeed","Donate",this.m_thanksItem.name,"Skip");
         close();
      }
      
      override protected function release() : void
      {
         super.release();
         this.m_mainFrame = null;
      }
   }
}

