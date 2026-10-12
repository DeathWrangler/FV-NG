package Widgets.Windows.Equipment
{
   import Classes.HarvestYieldsGroup;
   import Classes.util.ZLocUtils;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Equipment.ResourceHarvesterRewardSlotContainerFrame;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   
   public class ResourceHarvesterRewardWindow extends FarmWindow
   {
      
      public static const DIALOG_TEXT_ZLOC_KEY_PREFIX:String = "ResourceHarvester_RewardWindow";
      
      private var m_coinYield:int;
      
      private var m_rewards:Object;
      
      private var m_yields:HarvestYieldsGroup;
      
      private var m_slots:ResourceHarvesterRewardSlotContainerFrame;
      
      public function ResourceHarvesterRewardWindow(coinYield:int, rewards:Object, yields:HarvestYieldsGroup, assetPath:String)
      {
         this.m_coinYield = coinYield;
         this.m_rewards = rewards;
         this.m_yields = yields;
         super(assetPath);
      }
      
      override protected function postLoadComplete() : void
      {
         var rewardList:Array = null;
         var summaryText:String = null;
         var slotsElement:DisplayObject = null;
         addWidget(new ZwTextField(m_window.title_tf,"Congrats!"));
         var rewardItems:Array = [];
         var numRewards:int = 0;
         for each(rewardList in this.m_rewards)
         {
            rewardItems.push(rewardList);
            numRewards++;
         }
         summaryText = ZLocUtils.t("Dialogs",numRewards > 0 ? DIALOG_TEXT_ZLOC_KEY_PREFIX + "_Summary" : DIALOG_TEXT_ZLOC_KEY_PREFIX + "_Summary_No_Reward",{
            "coinQuantity":this.m_coinYield,
            "harvestYieldsGroup":this.m_yields.getStatus()
         });
         addWidget(new ZwTextField(m_window.coinText_tf,summaryText));
         slotsElement = rewardItems.length > 1 ? m_window.slotsX2_mc : m_window.slotsX1_mc;
         this.m_slots = addWidget(new ResourceHarvesterRewardSlotContainerFrame(slotsElement)) as ResourceHarvesterRewardSlotContainerFrame;
         this.m_slots.items = rewardItems;
      }
      
      override protected function release() : void
      {
         this.m_rewards = null;
         this.m_yields = null;
         this.m_slots.cancelFriendRewards();
         this.m_slots = null;
         super.release();
      }
      
      public function checkNoMoreRewards() : void
      {
         if(!this.m_slots.hasMoreRewards)
         {
            close();
         }
      }
   }
}

