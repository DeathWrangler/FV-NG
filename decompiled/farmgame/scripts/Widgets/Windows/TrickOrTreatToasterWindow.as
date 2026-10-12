package Widgets.Windows
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Managers.FeatureConfigManager;
   import Managers.TrickOrTreatManager;
   import Transactions.TCancelFriendReward;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmButton;
   import flash.events.Event;
   
   public class TrickOrTreatToasterWindow extends ToasterWindow
   {
      
      private static const ASSET_PATH:String = "assets/dialogs/FV_TrickOrTreat_Toaster.swf";
      
      private var m_rewardUrl:String = "";
      
      private var m_giftItem:FarmItem = null;
      
      private var m_shareFeedId:String = "";
      
      public function TrickOrTreatToasterWindow(shareFeedId:String, giftItem:FarmItem, rewardUrl:String)
      {
         this.m_rewardUrl = rewardUrl;
         this.m_giftItem = giftItem;
         this.m_shareFeedId = shareFeedId;
         super(ASSET_PATH);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window)
         {
            m_window.visible = true;
            addWidget(new FarmAnimatedButton(m_window.trade_bt,this.onShare));
            addWidget(new FarmButton(m_window.closeCompleted_bt,this.onClose));
            ZLocUtils.setText(m_window.trade_bt,"generic_tf","Dialogs","Share");
            ZLocUtils.setText(m_window.body_tf,"","Dialogs","TrickOrTreatToaster_body");
            m_window.trade_bt.generic_tf.visible = true;
            m_window.body_tf.visible = true;
         }
      }
      
      private function onShare(event:Event) : void
      {
         var messageType:String = FeatureConfigManager.getFeatureConfiguration(TrickOrTreatManager.instance.featureCreditName).getStringConstant(this.m_shareFeedId);
         var bundleData:Object = {
            "reward_link":this.m_rewardUrl,
            "rewardItem":ZLocUtils.tk_pk_asTitle(this.m_giftItem.friendlyName),
            "prize":ZLocUtils.tk_pk_asTitle(this.m_giftItem.friendlyName),
            "images":[{
               "href":"{SN_APP_URL}" + this.m_rewardUrl,
               "src":this.m_giftItem.icon
            }]
         };
         GlobalEngine.socialNetwork.publishFeedStory(messageType,bundleData,[],false);
         close();
      }
      
      override protected function onClose(event:Event) : void
      {
         TransactionManager.addTransaction(new TCancelFriendReward([this.m_rewardUrl]));
         super.onClose(event);
      }
   }
}

