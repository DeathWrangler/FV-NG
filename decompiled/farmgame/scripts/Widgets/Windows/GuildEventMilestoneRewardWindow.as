package Widgets.Windows
{
   import Classes.ZItem.FarmItem;
   import Classes.util.MovieClipUtils;
   import Managers.GuildEventManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class GuildEventMilestoneRewardWindow extends FarmWindow
   {
      
      private static const TITLE_TF:String = "title_tf";
      
      private static const BODY_TF:String = "info1_tf";
      
      private var m_featureName:String;
      
      private var m_rewardItem:FarmItem;
      
      private var m_gift_mc:MovieClip = new MovieClip();
      
      private var m_backgroundMc:MovieClip;
      
      private var m_userLvl:int;
      
      private var m_iconMc:FarmIcon;
      
      private var m_iconUrl:String = "";
      
      private var m_feedUrl:String = this.m_rewardItem.getImageByName(FarmItem.ICON_FEED);
      
      public function GuildEventMilestoneRewardWindow(featureName:String, assetPath:String, rewardItem:FarmItem)
      {
         this.m_featureName = featureName;
         this.m_rewardItem = rewardItem;
         super(assetPath);
      }
      
      override protected function postLoadComplete() : void
      {
         var iconUrl:String = null;
         super.postLoadComplete();
         MovieClipUtils.recursivePlay(m_window);
         var curTier:int = this.eventManager.getCurrentTier();
         this.m_userLvl = this.eventManager.getUserGrantedRewardLevel();
         if(m_window.hasOwnProperty(TITLE_TF))
         {
            m_window[TITLE_TF].visible = true;
            m_window[TITLE_TF].text = "One Step Closer";
         }
         if(m_window.hasOwnProperty(BODY_TF))
         {
            m_window[BODY_TF].visible = true;
            m_window[BODY_TF].text = "Maintain your Grape Stomping streak and win any one of these Bonus Wineries!";
         }
         if(m_window.hasOwnProperty("subtext1_tf"))
         {
            m_window["subtext1_tf"].visible = true;
            m_window["subtext1_tf"].text = "You have won this reward for your valiant effort";
            if(m_window.hasOwnProperty("subtext2_tf"))
            {
               m_window["subtext2_tf"].visible = true;
               m_window["subtext2_tf"].text = "Mysterious lost fortune awaits you in your path ahead!";
            }
            if(m_window.hasOwnProperty("icon_mc"))
            {
               iconUrl = this.m_rewardItem.getImageByName(FarmItem.ICON_200);
               if(iconUrl == null)
               {
                  iconUrl = this.m_rewardItem.getImageByName(FarmItem.ICON_FEED);
                  if(iconUrl == null)
                  {
                     iconUrl = this.m_rewardItem.iconUrl;
                  }
               }
               addWidget(this.m_iconMc = new FarmIcon(m_window["icon_mc"],iconUrl));
               if(this.m_iconMc.tooltip)
               {
                  this.m_iconMc.tooltip.release();
               }
               this.m_iconMc.detachTooltip();
               this.m_iconMc.attachTooltip(new FarmTextTooltip(this.m_rewardItem.friendlyTitle));
            }
            if(m_window.hasOwnProperty("giftbox_mc"))
            {
               this.m_gift_mc = m_window.giftbox_mc;
               this.m_gift_mc.visible = true;
            }
            if(m_window.hasOwnProperty("share_bt"))
            {
               addWidget(new FarmAnimatedTextButton(m_window["share_bt"],"Share",this.buttonCallback));
            }
            if(m_window.hasOwnProperty("background_mc"))
            {
               this.m_backgroundMc = m_window["background_mc"] as MovieClip;
               this.m_backgroundMc.visible = true;
               if(curTier <= 2)
               {
                  this.m_backgroundMc.gotoAndStop(curTier);
               }
               else
               {
                  this.m_backgroundMc.gotoAndStop(3);
               }
            }
         }
      }
      
      public function buttonCallback(e:Event) : void
      {
         var bundleData:Object = {
            "images":[{
               "href":"{SN_APP_URL}",
               "src":this.m_feedUrl
            }],
            "user":Global.player.firstName,
            "item":this.m_rewardItem.friendlyTitle
         };
         GlobalEngine.socialNetwork.publishFeedStory("FVGuildEventV3_share_milestoneRewardGrant",bundleData,[],false,null);
         this.close();
      }
      
      private function get eventManager() : GuildEventManager
      {
         return GuildEventManager.getInstance();
      }
      
      override public function close() : void
      {
         super.close();
         this.eventManager.onGrantAllPendingRewards();
      }
   }
}

