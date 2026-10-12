package Widgets.Windows.Quests
{
   import Classes.Constants.QuestConstants;
   import Classes.Quest.FarmQuest;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Icons.FarmIcon;
   import Widgets.Interfaces.IQuestRewardView;
   import Widgets.TextFields.FarmTextField;
   
   public class TieredQuestRewardWindow extends QuestCompleteWindowWithRewardItem implements IQuestRewardView
   {
      
      public function TieredQuestRewardWindow(farmQuest:FarmQuest)
      {
         super(farmQuest);
      }
      
      override protected function getTitle() : String
      {
         return ZLocUtils.t("Quests",m_farmQuest.chain + "_Title");
      }
      
      override protected function getRewardText() : String
      {
         var rewardItem:FarmItem = null;
         var reward:Object = null;
         var rewardText:String = null;
         var hasSecondItem:Boolean = false;
         for each(reward in m_farmQuest.farmRewards)
         {
            if(reward.type == QuestConstants.REWARD_GRANT_TIERED_QUEST_ITEM)
            {
               rewardItem = Global.farmGameSettingsManager.getFarmItemByCode(reward.value);
               hasSecondItem = true;
               break;
            }
            if(reward.type == QuestConstants.REWARD_GRANT_ITEM)
            {
               rewardItem = Global.farmGameSettingsManager.getFarmItemByCode(reward.value);
            }
         }
         rewardText = "";
         if(rewardItem)
         {
            if(hasSecondItem)
            {
               rewardText = ZLocUtils.t("Quests",m_farmQuest.chain + "_finalShareRewardText");
            }
            else
            {
               rewardText = ZLocUtils.t("Quests",m_farmQuest.chain + "_shareRewardText",{"itemName":rewardItem.friendlyTitle});
            }
         }
         return rewardText;
      }
      
      override protected function getRewardShareButtonText() : String
      {
         return super.getRewardButtonText();
      }
      
      override protected function showRewardItem(farmItem:FarmItem) : void
      {
         var icon:FarmIcon = null;
         var reward:Object = null;
         farmItem = null;
         var hasSecondItem:Boolean = false;
         if(m_farmQuest.farmRewards.length > 0)
         {
            for each(reward in m_farmQuest.farmRewards)
            {
               if(reward.type == QuestConstants.REWARD_GRANT_ITEM && Boolean(m_window["icon_1_mc"]))
               {
                  farmItem = Global.farmGameSettingsManager.getFarmItemByCode(reward.value);
                  icon = new FarmIcon(m_window["icon_1_mc"],farmItem.getImageByName(FarmItem.ICON_FEED));
                  icon.setSmoothing(true);
                  addWidget(icon);
               }
               if(reward.type == QuestConstants.REWARD_GRANT_TIERED_QUEST_ITEM && Boolean(m_window["icon_2_mc"]))
               {
                  farmItem = Global.farmGameSettingsManager.getFarmItemByCode(reward.value);
                  icon = new FarmIcon(m_window["icon_2_mc"],farmItem.icon);
                  icon.setSmoothing(true);
                  addWidget(icon);
                  hasSecondItem = true;
               }
            }
            if(hasSecondItem)
            {
               if(m_window["reward_tf"])
               {
                  addWidget(new FarmTextField(m_window["reward_tf"],"CONGRATS!\nYou\'ve also won"),true);
               }
               if(m_window["rewardbg_mc"])
               {
                  addWidget(new ZwWidget(m_window["rewardbg_mc"]),true);
               }
            }
         }
      }
   }
}

