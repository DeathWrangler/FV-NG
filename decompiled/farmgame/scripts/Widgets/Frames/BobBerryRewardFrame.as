package Widgets.Frames
{
   import Classes.util.ZLocUtils;
   import Managers.OrderBoard.BobBerryManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Windows.BobBerryFarmWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class BobBerryRewardFrame extends ZwFrame
   {
      
      private static const REDEEM_BUTTON_TEXT:String = "REDEEM";
      
      private static const CONTINUE_BUTTON_TEXT:String = "CONTINUE";
      
      private var m_owner:BobBerryFarmWindow;
      
      private var m_featureName:String;
      
      private var m_redeembutton:FarmAnimatedTextButton;
      
      private var m_continuebutton:FarmAnimatedTextButton;
      
      public function BobBerryRewardFrame(element:DisplayObject, owner:BobBerryFarmWindow, featureName:String)
      {
         super(element);
         this.m_owner = owner;
         this.m_featureName = featureName;
         if(m_element.hasOwnProperty("congratulationtitle_tf") && m_element.hasOwnProperty("rewardtext_tf"))
         {
            m_element.congratulationtitle_tf.visible = true;
            m_element.rewardtext_tf.text = ZLocUtils.t("Dialogs",this.m_featureName + "_rewardSubtitle");
            m_element.rewardtext_tf.visible = true;
         }
         if(m_element.hasOwnProperty("bobAnim_mc"))
         {
            (m_element.bobAnim_mc as MovieClip).play();
         }
         if(m_element.hasOwnProperty("slot_0_mc") && m_element.hasOwnProperty("slot_2_mc"))
         {
            m_element.slot_0_mc.visible = false;
            m_element.slot_2_mc.visible = false;
         }
         if(m_element.hasOwnProperty("slot_1_mc"))
         {
            if(!m_element["slot_1_mc"].hasOwnProperty("reward_1_tf"))
            {
            }
            m_element.slot_1_mc.visible = true;
         }
         if(m_element.hasOwnProperty("count_mc_1") && Boolean(m_element["count_mc_1"].hasOwnProperty("count_tf")))
         {
            m_element.count_mc_1.visible = true;
            m_element.count_mc_1.count_tf.visible = true;
         }
         if(m_element.hasOwnProperty("complete_bt"))
         {
            this.m_redeembutton = addWidget(new FarmAnimatedTextButton(m_element.complete_bt,REDEEM_BUTTON_TEXT,this.onRedeemClick),true) as FarmAnimatedTextButton;
         }
         if(m_element.hasOwnProperty("playmore_bt"))
         {
            this.m_continuebutton = addWidget(new FarmAnimatedTextButton(m_element.playmore_bt,CONTINUE_BUTTON_TEXT,this.onContinueClick),false) as FarmAnimatedTextButton;
         }
      }
      
      public function onRedeemClick(ev:Event = null) : void
      {
         ev.currentTarget.removeEventListener(ev.type,this.onRedeemClick);
         this.m_owner.pause();
         if(!this.m_continuebutton.visible)
         {
            BobBerryManager.getInstance(this.m_featureName).setFirstRewardStatusAsSeen();
         }
         BobBerryManager.getInstance(this.m_featureName).setRewardStatusAsSeen(this.openMarket);
      }
      
      public function onContinueClick(ev:Event = null) : void
      {
         ev.currentTarget.removeEventListener(ev.type,this.onContinueClick);
         this.m_owner.pause();
         BobBerryManager.getInstance(this.m_featureName).setRewardStatusAsSeen(this.goToMainWindow);
      }
      
      public function goToMainWindow() : void
      {
         this.m_owner.unpause();
         this.m_owner.refreshMainUI();
      }
      
      public function openMarket() : void
      {
         this.m_owner.unpause();
         this.m_owner.openBobsMarket();
      }
      
      override public function release() : void
      {
         this.m_owner = null;
         this.m_redeembutton = null;
         this.m_continuebutton = null;
         super.release();
      }
      
      public function refresh() : void
      {
         var rewardsReceived:Vector.<Object> = null;
         rewardsReceived = BobBerryManager.getInstance(this.m_featureName).getRewards();
         if(rewardsReceived)
         {
            m_element.slot_1_mc.reward_1_tf.text = rewardsReceived[0].value;
         }
         else
         {
            m_element.slot_1_mc.reward_1_tf.text = "";
         }
         m_element.count_mc_1.count_tf.text = "x" + BobBerryManager.getInstance(this.m_featureName).getCurrentCurrencyCount();
         this.m_continuebutton.visible = BobBerryManager.getInstance(this.m_featureName).hasSeenFirstRewardDialog();
      }
   }
}

