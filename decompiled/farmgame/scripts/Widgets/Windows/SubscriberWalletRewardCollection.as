package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Managers.SubscriberWalletManager;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.SubscriberWalletRewardCollectionFrame;
   import Widgets.Frames.SubscriberWalletRewardCollectionNewRewardsFrame;
   import Widgets.Frames.SubscriberWalletRewardCollectionTabMenu;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class SubscriberWalletRewardCollection extends FarmWindow
   {
      
      private var m_allRewards_mc:MovieClip;
      
      private var m_tabMenu:SubscriberWalletRewardCollectionTabMenu;
      
      private var m_collectionFrame:SubscriberWalletRewardCollectionFrame;
      
      private var m_newCollectionFrame:SubscriberWalletRewardCollectionNewRewardsFrame;
      
      private var m_featureName:String = SubscriberWalletManager.FEATURE_NAME;
      
      public function SubscriberWalletRewardCollection(assetPath:String)
      {
         super(assetPath,true,true);
      }
      
      override protected function postLoadComplete() : void
      {
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_mainUI_rewards")));
         this.m_allRewards_mc = m_window["allRewards_mc"] as MovieClip;
         this.m_allRewards_mc.visible = true;
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         addWidget(this.m_collectionFrame = new SubscriberWalletRewardCollectionFrame(this.m_allRewards_mc["reward_mc"],"subscriber_wallet"));
         addWidget(this.m_newCollectionFrame = new SubscriberWalletRewardCollectionNewRewardsFrame(this.m_allRewards_mc["newRewardItems_mc"],"subscriber_wallet"));
         this.m_tabMenu = new SubscriberWalletRewardCollectionTabMenu(this.m_allRewards_mc["tabs_mc"],4,this.updateCollectionFrameCallBack);
         this.m_allRewards_mc["reward_mc"].visible = true;
         var newRewardsTag:MovieClip = this.m_allRewards_mc["newRewardItems_mc"]["newTag_mc"] as MovieClip;
         newRewardsTag.visible = SubscriberWalletManager.getInstance().areRewardsNew();
      }
      
      private function updateCollectionFrameCallBack(rewardType:String) : void
      {
         var rewardsArray:Array = SubscriberWalletManager.getInstance().getRewardsArray(rewardType);
         this.m_collectionFrame.setupSlotData(rewardsArray);
         this.m_collectionFrame.refresh();
      }
      
      override protected function release() : void
      {
         this.m_allRewards_mc = null;
         this.m_tabMenu = null;
         super.release();
      }
      
      override public function close() : void
      {
         super.close();
      }
   }
}

