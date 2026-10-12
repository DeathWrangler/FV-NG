package Widgets.Windows
{
   import Cache.Classes.ZCacheUtil;
   import Classes.ZItem.FarmItem;
   import Classes.util.FacebookSocialNetwork;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Managers.BingoManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class BingoRewardWindow extends FarmWindow
   {
      
      protected static const WINDOW_ASSET:String = "assets/dialogs/FV_Bingo_prize.swf";
      
      private var m_reward:FarmItem = null;
      
      private var m_isFinalReward:Boolean = false;
      
      private var m_shareBt:FarmAnimatedTextButton = null;
      
      public function BingoRewardWindow(reward:FarmItem, isFinal:Boolean = false)
      {
         super(WINDOW_ASSET);
         this.m_reward = reward;
         this.m_isFinalReward = isFinal;
      }
      
      override protected function postLoadComplete() : void
      {
         var objectPreviewFrame:ObjectPreviewFrame = null;
         super.postLoadComplete();
         if(m_window.share_bt)
         {
            this.m_shareBt = new FarmAnimatedTextButton(m_window.share_bt,ZLocUtils.t("Dialogs","Bingo_reward_button"),this.onShare);
            addWidget(this.m_shareBt);
         }
         if(m_window.copy_tf)
         {
            addWidget(new ZwTextField(m_window.copy_tf,ZLocUtils.t("Dialogs","Bingo_reward_message")));
         }
         if(m_window.prizename_tf)
         {
            addWidget(new ZwTextField(m_window.prizename_tf,ZLocUtils.t("Dialogs","Bingo_Prize_Name",{"prize":this.m_reward.friendlyTitle})));
         }
         if(m_window.npc_mc)
         {
            objectPreviewFrame = new ObjectPreviewFrame(m_window.npc_mc,this.m_reward,null,[2]);
            (objectPreviewFrame.element as MovieClip).filters = [];
            addWidget(objectPreviewFrame,true);
         }
         if(this.m_isFinalReward == true)
         {
            if(m_window.grandPrize_mc)
            {
               m_window.grandPrize_mc.gotoAndPlay(2);
            }
            if(m_window.generic4_tf)
            {
               m_window.generic4_tf.visible = false;
            }
            if(m_window.generic3_tf)
            {
               addWidget(new ZwTextField(m_window.generic3_tf,ZLocUtils.t("Dialogs","Bingo_reward_giftbox_final_text")));
            }
         }
         else
         {
            if(m_window.grandPrize_mc)
            {
               m_window.grandPrize_mc.visible = false;
            }
            if(m_window.generic4_tf)
            {
               addWidget(new ZwTextField(m_window.generic4_tf,ZLocUtils.t("Dialogs","Bingo_reward_giftbox_text")));
            }
            if(m_window.generic3_tf)
            {
               addWidget(new ZwTextField(m_window.generic3_tf,ZLocUtils.t("Dialogs","Bingo_reward_keep_playing_message")));
            }
         }
      }
      
      private function onShare(event:MouseEvent) : void
      {
         this.m_shareBt.enabled = false;
         TransactionManager.addTransaction(new TGenericTransaction(BingoManager.BINGO_SERVICE,"onBragFeed",this.onCompleteTransaction,[this.m_reward.name]));
      }
      
      private function onCompleteTransaction(result:Object) : void
      {
         if(Boolean(result) && result.hasOwnProperty("feedData"))
         {
            (GlobalEngine.socialNetwork as FacebookSocialNetwork).publishResultsFromTransaction(result.feedData,ZCacheUtil.applyPartial(this.handleFeedPostReturn,this,[result]));
         }
         close();
      }
      
      private function handleFeedPostReturn(result:Object, success:Boolean) : void
      {
         if(result == null)
         {
            result = {};
         }
         result.postSuccessful = success;
      }
   }
}

