package Widgets.Windows
{
   import Classes.MysteryCrateBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.events.MouseEvent;
   
   public class MysteryCrateRewardWindow extends FarmWindow
   {
      
      protected static const WINDOW_ASSET:String = "assets/dialogs/FV_mysteryCrate_prize.swf";
      
      private static const ICON_SCALE:Number = 1;
      
      private static const ICON_OFFSET_X:int = 0;
      
      private static const ICON_OFFSET_Y:int = 0;
      
      private var m_rewardFriendlyName:String = null;
      
      private var m_reward:FarmItem = null;
      
      private var m_part:FarmItem = null;
      
      private var m_transactionResults:Object = null;
      
      private var m_partName:String = "";
      
      private var m_shareBt:FarmAnimatedButton = null;
      
      private var m_icon:FarmIcon = null;
      
      private var m_congratulationMessage:ZwTextField = null;
      
      private var m_shareMessage:ZwTextField = null;
      
      public function MysteryCrateRewardWindow(reward:FarmItem, part:FarmItem, partName:String, transactionResults:Object)
      {
         super(WINDOW_ASSET);
         this.m_reward = reward;
         this.m_part = part;
         this.m_partName = partName;
         this.m_rewardFriendlyName = reward.friendlyName;
         this.m_transactionResults = transactionResults;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         m_window.visible = true;
         this.m_shareBt = new FarmAnimatedButton(m_window.accept_bt,this.onShare);
         this.m_congratulationMessage = new ZwTextField(m_window.copy_tf,ZLocUtils.t("Dialogs","mysterycrate_congratulations_text",{"prize":ZLocUtils.tk_pk(this.m_rewardFriendlyName)}));
         this.m_shareMessage = new ZwTextField(m_window.subCopy_tf,ZLocUtils.t("Dialogs","mysterycrate_share_text",{"part":this.m_partName}));
         m_window.title_tf.visible = true;
         m_window.back_mc.visible = true;
         m_window.back_mc.gotoAndPlay(2);
         addWidget(this.m_shareBt);
         addWidget(this.m_congratulationMessage);
         addWidget(this.m_shareMessage);
         this.refreshIcon();
         show();
      }
      
      private function refreshIcon() : void
      {
         this.m_icon = new FarmIcon(m_window.icon_mc,this.m_reward.icon);
         this.m_icon.setIconScale(ICON_SCALE,ICON_SCALE);
         this.m_icon.x += ICON_OFFSET_X;
         this.m_icon.y += ICON_OFFSET_Y;
         addWidget(this.m_icon);
      }
      
      private function onShare(e:MouseEvent) : void
      {
         this.m_shareBt.enabled = false;
         close();
         FarmStatsManager.count(MysteryCrateBuilding.FEED_STAT,MysteryCrateBuilding.FEED_STAT,MysteryCrateBuilding.MYSTERY_CRATE,"prize_share_" + this.m_part.name);
         var bundleData:Object = {
            "user":Global.player.firstName,
            "partName":ZLocUtils.tk_pk_asTitle(this.m_part.friendlyName),
            "reward_link":this.m_transactionResults.friendRewardLink,
            "images":[{
               "href":"{SN_APP_URL}" + this.m_transactionResults.friendRewardLink,
               "src":this.m_part.icon
            }]
         };
         var feedStoryBundleID:String = this.m_transactionResults.bundleId;
         GlobalEngine.socialNetwork.publishFeedStory(feedStoryBundleID,bundleData,[],false);
      }
   }
}

