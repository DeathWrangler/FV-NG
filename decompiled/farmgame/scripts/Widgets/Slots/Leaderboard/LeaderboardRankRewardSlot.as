package Widgets.Slots.Leaderboard
{
   import Classes.Leaderboard.Leaderboard;
   import Classes.Leaderboard.LeaderboardState;
   import Classes.util.UserRewardUtil;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.LeaderboardManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.Leaderboard.LeaderboardWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class LeaderboardRankRewardSlot extends ZwSlotFrame
   {
      
      private static const BIG_ICON_SIZE:int = 50;
      
      private static const SMALL_ICON_SIZE:int = 25;
      
      private var m_data:Object;
      
      private var m_icon:FarmIcon;
      
      private var m_checkWidget:ZwWidget;
      
      private var m_quantityTextField:ZwTextField;
      
      private var m_rankLabelTextField:ZwTextField;
      
      private var m_rankTextField:ZwTextField;
      
      private var m_shareButton:FarmAnimatedTextButton;
      
      private var m_trophyWidget:ZwWidget;
      
      public function LeaderboardRankRewardSlot(element:DisplayObject)
      {
         super(element);
         this.m_icon = addWidget(new FarmIcon(m_element.prizeIcon_mc)) as FarmIcon;
         this.m_icon.setSmoothing(true);
         this.m_rankTextField = addWidget(new ZwTextField(m_element.rankNumber_tf,"")) as ZwTextField;
         this.m_quantityTextField = addWidget(new ZwTextField(m_element.qty_tf,"")) as ZwTextField;
         if(m_element.hasOwnProperty("check_mc"))
         {
            this.m_checkWidget = addWidget(new ZwWidget(m_element.check_mc)) as ZwWidget;
         }
         if(m_element.hasOwnProperty("claim_bt"))
         {
            this.m_shareButton = addWidget(new FarmAnimatedTextButton(m_element.claim_bt,ZLocUtils.t("Leaderboard","ShareButton"),this.onShareButtonClick),false) as FarmAnimatedTextButton;
         }
         if(m_element.hasOwnProperty("place_tf"))
         {
            this.m_rankLabelTextField = addWidget(new ZwTextField(m_element.place_tf,ZLocUtils.t("Leaderboard","Place"))) as ZwTextField;
         }
         if(m_element.hasOwnProperty("trophies_mc"))
         {
            this.m_trophyWidget = addWidget(new ZwWidget(m_element.trophies_mc)) as ZwWidget;
         }
      }
      
      override public function populate(data:Object) : void
      {
         var iconSize:int = 0;
         var rewardRank:int = 0;
         var leaderboard:Leaderboard = null;
         var userState:LeaderboardState = null;
         super.populate(data);
         this.m_data = data;
         if(this.m_data)
         {
            iconSize = getAncestorByClassType(LeaderboardWindow) ? SMALL_ICON_SIZE : BIG_ICON_SIZE;
            this.m_icon.setIconSize(iconSize,iconSize);
            this.m_icon.loadIcon(UserRewardUtil.getImageForReward(this.m_data));
            this.m_icon.visible = true;
            this.m_quantityTextField.text = String(UserRewardUtil.getValueForReward(this.m_data));
            this.m_quantityTextField.visible = true;
            if(this.m_rankLabelTextField)
            {
               this.m_rankLabelTextField.visible = true;
            }
            rewardRank = int(this.m_data["rank"]);
            this.m_rankTextField.text = LeaderboardManager.getRankOrdinalText(rewardRank);
            this.m_rankTextField.visible = true;
            if(this.m_trophyWidget)
            {
               (this.m_trophyWidget.element as MovieClip).gotoAndStop(rewardRank);
               this.m_trophyWidget.visible = true;
            }
            if(this.m_shareButton)
            {
               leaderboard = LeaderboardManager.getLeaderboardForWidget(this);
               if(leaderboard)
               {
                  userState = Global.player.getLeaderboardState(leaderboard.name);
                  if(Boolean(userState) && userState.rank == rewardRank)
                  {
                     if(this.m_checkWidget)
                     {
                        this.m_checkWidget.visible = true;
                     }
                     this.m_shareButton.visible = !userState.rankFeed;
                  }
               }
            }
         }
      }
      
      override public function release() : void
      {
         this.m_checkWidget = null;
         this.m_data = null;
         this.m_icon = null;
         this.m_quantityTextField = null;
         this.m_rankLabelTextField = null;
         this.m_rankTextField = null;
         this.m_shareButton = null;
         this.m_trophyWidget = null;
         super.release();
      }
      
      private function onShareButtonClick(event:MouseEvent) : void
      {
         var leaderboard:Leaderboard = null;
         if(this.m_shareButton.enabled)
         {
            this.m_shareButton.enabled = false;
            leaderboard = LeaderboardManager.getLeaderboardForWidget(this);
            if(leaderboard)
            {
               LeaderboardManager.sendGetRankRewardFeedTransaction(leaderboard.name);
               FarmStatsManager.featureSample(LeaderboardManager.STAT_COUNTER,"clicks","rank_reward_summary",leaderboard.name,String(this.m_data["rank"]));
            }
         }
      }
   }
}

