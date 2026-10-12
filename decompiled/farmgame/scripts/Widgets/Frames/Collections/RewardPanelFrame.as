package Widgets.Frames.Collections
{
   import Classes.Collections.Collection;
   import Classes.Collections.Reward;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.CollectionsManager;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Tooltips.MovieClipTooltip;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class RewardPanelFrame extends FarmSlotContainerFrame
   {
      
      private static const CURRENT_ICON_SIZE:int = 100;
      
      private static const NEXT_ICON_SIZE:int = 50;
      
      private static const TOOLTIP_SHOW_FRAME_NUM:int = 30;
      
      private var m_parentWindow:CollectionsRewardFrame;
      
      private var m_currentReward:MovieClip;
      
      private var m_nextReward:MovieClip;
      
      private var m_collection:Collection;
      
      private var m_coinReward:ZwTextField;
      
      private var m_xpReward:ZwTextField;
      
      private var m_coinNextReward:ZwTextField;
      
      private var m_xpNextReward:ZwTextField;
      
      private var m_nextLevel:ZwTextField;
      
      private var m_rewardTooltip:FarmTextTooltip;
      
      private var m_nextRewardTooltip:FarmTextTooltip;
      
      private var m_rewardIcon:FarmIcon;
      
      private var m_nextRewardIcon:FarmIcon;
      
      public function RewardPanelFrame(element:DisplayObject, parent:CollectionsRewardFrame, collection:Collection)
      {
         this.m_parentWindow = parent;
         this.m_collection = collection;
         super(element);
         var topCard:Object = m_element.topCard_mc;
         if(topCard)
         {
            addWidget(new ZwTextField(topCard.title_tf,ZLocUtils.t("Collections","Reward")));
            this.m_coinReward = addWidget(new ZwTextField(topCard.coins_tf,"+99,999")) as ZwTextField;
            this.m_xpReward = addWidget(new ZwTextField(topCard.xp_tf,"+999")) as ZwTextField;
            this.m_rewardIcon = new FarmIcon(m_element.topCard_mc.icon_mc);
            this.m_rewardTooltip = new FarmTextTooltip();
            this.m_rewardIcon.attachTooltip(this.m_rewardTooltip);
         }
         var bottomCard:Object = m_element.subCard_mc;
         if(bottomCard)
         {
            addWidget(new ZwTextField(bottomCard.nextTitle_tf,ZLocUtils.t("Collections","Next")));
            this.m_nextLevel = addWidget(new ZwTextField(bottomCard.level_tf,ZLocUtils.t("Collections","Level",{"levelNum":this.m_collection.getLevel() + 1}))) as ZwTextField;
            this.m_coinNextReward = addWidget(new ZwTextField(bottomCard.nextCoin_tf,"+99,999")) as ZwTextField;
            this.m_xpNextReward = addWidget(new ZwTextField(bottomCard.nextXP_tf,"+999")) as ZwTextField;
            this.attachTooltip(new MovieClipTooltip(element as MovieClip,TOOLTIP_SHOW_FRAME_NUM));
            this.m_nextRewardIcon = new FarmIcon(m_element.subCard_mc.icon_mc);
            this.m_nextRewardTooltip = new FarmTextTooltip();
            this.m_nextRewardIcon.attachTooltip(this.m_nextRewardTooltip);
         }
         m_slotData = this.m_collection.getCollectibles();
         this.refresh();
      }
      
      override protected function setupData() : void
      {
      }
      
      override public function release() : void
      {
         super.release();
         this.m_parentWindow = null;
      }
      
      public function updateCollection(collection:Collection) : void
      {
         this.m_collection = collection;
         this.refresh();
      }
      
      override public function refresh() : void
      {
         var collectionRewards:Array = this.m_collection.getRewards();
         var reward:Reward = collectionRewards[this.m_collection.getLevel() % collectionRewards.length];
         var rewardItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(reward.gift);
         var nextReward:Reward = collectionRewards[(this.m_collection.getLevel() + 1) % collectionRewards.length];
         var nextRewardItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(nextReward.gift);
         this.m_rewardIcon.loadIcon(rewardItem.icon);
         this.m_rewardIcon.enabled = false;
         this.m_rewardIcon.setIconSize(CURRENT_ICON_SIZE,CURRENT_ICON_SIZE);
         this.m_rewardTooltip.setText(rewardItem.friendlyTitle);
         this.m_nextRewardIcon.loadIcon(nextRewardItem.icon);
         this.m_nextRewardIcon.enabled = false;
         this.m_nextRewardIcon.setIconSize(NEXT_ICON_SIZE,NEXT_ICON_SIZE);
         this.m_nextRewardTooltip.setText(nextRewardItem.friendlyTitle);
         if(m_element.topCard_mc)
         {
            this.m_coinReward.text = "+ " + CollectionsManager.getInstance().getConfigAttribute(CollectionsManager.BASE_COIN_REWARD) * (this.m_collection.getLevel() + 1);
            this.m_xpReward.text = "+ " + CollectionsManager.getInstance().getConfigAttribute(CollectionsManager.BASE_XP_REWARD) * (this.m_collection.getLevel() + 1);
         }
         if(m_element.subCard_mc)
         {
            this.m_coinNextReward.text = "+ " + CollectionsManager.getInstance().getConfigAttribute(CollectionsManager.BASE_COIN_REWARD) * (this.m_collection.getLevel() + 2);
            this.m_xpNextReward.text = "+ " + CollectionsManager.getInstance().getConfigAttribute(CollectionsManager.BASE_XP_REWARD) * (this.m_collection.getLevel() + 2);
            this.m_nextLevel.text = ZLocUtils.t("Collections","Level",{"levelNum":this.m_collection.getLevel() + 2});
         }
         this.visible = true;
      }
   }
}

