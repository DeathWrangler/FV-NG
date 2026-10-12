package Widgets.Windows.Leaderboard
{
   import Classes.Constants.QuestConstants;
   import Classes.Leaderboard.Leaderboard;
   import Classes.Leaderboard.LeaderboardConfigSettings;
   import Classes.ZItem.FarmItem;
   import Classes.util.UserRewardUtil;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.LeaderboardManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   
   public class MultiTaskLeaderboardRewardWindow extends FarmWindow
   {
      
      private static const ASSET_URL:String = "assets/dialogs/FV_FarmDerby2013_Prize.swf";
      
      private static const ICON_SIZE:int = 200;
      
      private var m_leaderboard:Leaderboard;
      
      private var m_reward:Object;
      
      private var m_rewardType:String;
      
      public function MultiTaskLeaderboardRewardWindow(leaderboard:Leaderboard, reward:Object, rewardType:String)
      {
         super(ASSET_URL);
         this.m_leaderboard = leaderboard;
         this.m_reward = reward;
         this.m_rewardType = rewardType;
      }
      
      override protected function postLoadComplete() : void
      {
         var itemIconUrl:String = null;
         var itemText:String = null;
         var item:FarmItem = null;
         var amountText:String = null;
         addWidget(new FarmTextField(m_window.title_tf,ZLocUtils.t("Leaderboard","MultiTaskLeaderboardRewardWindow_Title")));
         switch(this.m_reward.type)
         {
            case QuestConstants.REWARD_GRANT_BUSHEL_ITEM:
            case QuestConstants.REWARD_GRANT_BREEDING_ITEM:
            case QuestConstants.REWARD_GRANT_ITEM:
               item = Global.farmGameSettingsManager.getFarmItemByCode(this.m_reward.value);
               if(item)
               {
                  itemIconUrl = item.getImageByName(FarmItem.ICON_200);
                  if(!itemIconUrl)
                  {
                     itemIconUrl = item.getImageByName(FarmItem.ICON_FEED);
                     if(!itemIconUrl)
                     {
                        itemIconUrl = item.icon;
                     }
                  }
                  amountText = UserRewardUtil.getValueForReward(this.m_reward);
                  amountText = amountText == "x1" ? "" : " " + amountText;
                  itemText = item.friendlyTitle + amountText;
               }
               break;
            default:
               itemIconUrl = UserRewardUtil.getImageForReward(this.m_reward);
               itemText = UserRewardUtil.getValueForReward(this.m_reward);
         }
         addWidget(new FarmTextField(m_window.item_tf,ZLocUtils.t("Leaderboard","MultiTaskLeaderboardRewardWindow_Message_" + this.m_rewardType,{
            "leaderboardName":this.m_leaderboard.nameText,
            "itemName":itemText
         })));
         var icon:FarmIcon = addWidget(new FarmIcon(m_window.icon_mc,itemIconUrl)) as FarmIcon;
         icon.setIconSize(ICON_SIZE,ICON_SIZE);
         icon.setSmoothing(true);
         addWidget(new FarmTextField(m_window.info_tf,ZLocUtils.t("Leaderboard","MultiTaskLeaderboardRewardWindow_Info_" + this.m_rewardType)));
         if(this.m_reward.type == QuestConstants.REWARD_GRANT_ITEM)
         {
            addWidget(new FarmTextField(m_window.info2_tf,ZLocUtils.t("Leaderboard","MultiTaskLeaderboardRewardWindow_GiftBox")));
         }
         addWidget(new FarmAnimatedTextButton(m_window.accept_bt,ZLocUtils.t("Dialogs","Accept"),this.onAccept));
         FarmStatsManager.featureSample(LeaderboardManager.STAT_COUNTER,"impressions","multitask_reward_window",this.m_leaderboard.name,this.m_rewardType);
      }
      
      override protected function release() : void
      {
         this.m_leaderboard = null;
         this.m_reward = null;
         super.release();
      }
      
      private function onAccept(event:Event) : void
      {
         var activeLeaderboard:Leaderboard = null;
         var activeLeaderboards:Array = Global.leaderboardConfigSettings.getActiveLeaderboards(LeaderboardConfigSettings.MULTI_TASK);
         if(Boolean(activeLeaderboards) && activeLeaderboards.length > 0)
         {
            activeLeaderboard = activeLeaderboards[0];
            if(activeLeaderboard)
            {
               if(this.m_rewardType == LeaderboardManager.PROGRESS_REWARD_TYPE || this.m_rewardType == LeaderboardManager.RANK_REWARD_TYPE && activeLeaderboard != this.m_leaderboard)
               {
                  LeaderboardManager.displayMultiTaskLeaderboardWindow();
               }
            }
         }
         FarmStatsManager.featureSample(LeaderboardManager.STAT_COUNTER,"clicks","multitask_reward_window",this.m_leaderboard.name,this.m_rewardType);
         close();
      }
   }
}

