package Widgets.Slots.Leaderboard
{
   import Classes.Constants.QuestConstants;
   import Classes.Leaderboard.Leaderboard;
   import Classes.Leaderboard.LeaderboardState;
   import Classes.ZItem.FarmItem;
   import Classes.util.UserRewardUtil;
   import Classes.util.ZLocUtils;
   import Managers.LeaderboardManager;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.Leaderboard.MultiTaskLeaderboardWindow;
   import flash.display.DisplayObject;
   
   public class MultiTaskLeaderboardRewardSlot extends ZwSlotFrame
   {
      
      private static const ICON_SIZE:int = 100;
      
      private var m_type:String;
      
      private var m_data:Object;
      
      private var m_icon:FarmIcon;
      
      private var m_iconTooltip:FarmTextTooltip;
      
      private var m_amountTextField:FarmTextField;
      
      private var m_descriptionTextField:FarmTextField;
      
      private var m_valueTextField:FarmTextField;
      
      private var m_checkWidget:ZwWidget;
      
      public function MultiTaskLeaderboardRewardSlot(element:DisplayObject, type:String)
      {
         this.m_type = type;
         super(element);
         this.m_amountTextField = addWidget(new FarmTextField(m_element.amount_tf)) as FarmTextField;
         this.m_icon = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
         this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
         this.m_icon.setSmoothing(true);
         this.m_iconTooltip = new FarmTextTooltip("");
         this.m_icon.attachTooltip(this.m_iconTooltip);
         this.m_descriptionTextField = addWidget(new FarmTextField(m_element.generic_tf,"")) as FarmTextField;
         this.m_valueTextField = addWidget(new FarmTextField(m_element.score_tf,"")) as FarmTextField;
         this.m_checkWidget = addWidget(new ZwWidget(m_element.checkMark_mc)) as ZwWidget;
      }
      
      override public function populate(data:Object) : void
      {
         var parentWindow:MultiTaskLeaderboardWindow = null;
         var leaderboard:Leaderboard = null;
         var threshold:int = 0;
         var userState:LeaderboardState = null;
         var userScore:int = 0;
         var rewardRank:int = 0;
         super.populate(data);
         this.m_data = data;
         if(this.m_data)
         {
            this.m_icon.loadIcon(UserRewardUtil.getImageForReward(this.m_data));
            this.m_icon.visible = true;
            this.m_iconTooltip.setText(this.getRewardText());
            this.m_amountTextField.text = UserRewardUtil.getValueForReward(this.m_data);
            this.m_amountTextField.visible = true;
            switch(this.m_type)
            {
               case LeaderboardManager.PROGRESS_REWARD_TYPE:
                  parentWindow = getParentWindow() as MultiTaskLeaderboardWindow;
                  if(parentWindow)
                  {
                     leaderboard = parentWindow.leaderboard;
                     if(leaderboard)
                     {
                        this.m_descriptionTextField.text = ZLocUtils.t("Leaderboard","ScoreNeeded");
                        this.m_descriptionTextField.visible = true;
                        threshold = int(this.m_data["threshold"]);
                        this.m_valueTextField.text = String(threshold);
                        this.m_valueTextField.visible = true;
                        userState = Global.player.getLeaderboardState(leaderboard.name);
                        userScore = userState ? userState.score : 0;
                        this.m_checkWidget.visible = userScore >= threshold;
                     }
                  }
                  break;
               case LeaderboardManager.RANK_REWARD_TYPE:
                  this.m_descriptionTextField.text = ZLocUtils.t("Leaderboard","RankNeeded");
                  this.m_descriptionTextField.visible = true;
                  rewardRank = int(this.m_data["rank"]);
                  this.m_valueTextField.text = LeaderboardManager.getRankOrdinalText(rewardRank);
                  this.m_valueTextField.visible = true;
                  this.m_checkWidget.visible = false;
            }
         }
      }
      
      override public function release() : void
      {
         this.m_data = null;
         this.m_icon = null;
         this.m_iconTooltip = null;
         this.m_amountTextField = null;
         this.m_descriptionTextField = null;
         this.m_valueTextField = null;
         this.m_checkWidget = null;
         super.release();
      }
      
      public function getRewardText() : String
      {
         var item:FarmItem = null;
         var result:String = "";
         if(this.m_data)
         {
            switch(this.m_data.type)
            {
               case QuestConstants.REWARD_GRANT_BUSHEL_ITEM:
               case QuestConstants.REWARD_GRANT_BREEDING_ITEM:
               case QuestConstants.REWARD_GRANT_ITEM:
                  item = Global.farmGameSettingsManager.getFarmItemByCode(this.m_data.value);
                  if(item)
                  {
                     result = item.friendlyTitle;
                  }
                  break;
               default:
                  result = UserRewardUtil.getValueForReward(this.m_data);
            }
         }
         return result;
      }
   }
}

