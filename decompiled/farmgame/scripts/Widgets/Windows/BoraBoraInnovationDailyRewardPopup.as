package Widgets.Windows
{
   import Classes.ZItem.FarmItem;
   import Managers.OrderBoard.BoraBoraInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   
   public class BoraBoraInnovationDailyRewardPopup extends FarmWindow
   {
      
      private static const OFFSET_OPF_Y:int = -30;
      
      protected var m_featureName:String = null;
      
      private var m_reward:FarmItem = null;
      
      private var m_callback:Function = null;
      
      protected var m_title_tf:ZwTextField = null;
      
      private var m_subtitle1_tf:ZwTextField;
      
      private var m_subtitle2_tf:ZwTextField;
      
      private var m_rewardicon:FarmIcon;
      
      private var m_isMilestone:Boolean;
      
      private var m_awesome_bt:FarmAnimatedTextButton;
      
      private var m_reward_frame:MovieClip;
      
      private var m_rewardNameTf:ZwTextField;
      
      public function BoraBoraInnovationDailyRewardPopup(dialogAsset:String, featureName:String, rewardItem:FarmItem = null, buttonCallback:Function = null, isMilestone:Boolean = false)
      {
         super(dialogAsset,true,true);
         this.m_reward = rewardItem;
         this.m_featureName = featureName;
         this.m_callback = buttonCallback;
         this.m_isMilestone = isMilestone;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty("reward_window_mc"))
         {
            this.m_reward_frame = m_window["reward_window_mc"] as MovieClip;
            this.m_reward_frame.visible = true;
         }
         if(this.m_reward_frame.hasOwnProperty("title_tf"))
         {
            addWidget(this.m_title_tf = new ZwTextField(this.m_reward_frame["title_tf"]));
         }
         if(this.m_reward_frame.hasOwnProperty("header_tf"))
         {
            addWidget(this.m_subtitle1_tf = new ZwTextField(this.m_reward_frame["header_tf"]));
         }
         if(this.m_reward_frame.hasOwnProperty("subtitle_tf"))
         {
            addWidget(this.m_subtitle2_tf = new ZwTextField(this.m_reward_frame["subtitle_tf"]));
         }
         if(this.m_reward_frame.hasOwnProperty("reward_img_mc"))
         {
            addWidget(this.m_rewardicon = new FarmIcon(this.m_reward_frame["reward_img_mc"]));
         }
         if(this.m_reward_frame.hasOwnProperty("okay_bt"))
         {
            if(this.m_callback == null)
            {
               this.m_callback = onClose;
            }
            addWidget(this.m_awesome_bt = new FarmAnimatedTextButton(this.m_reward_frame["okay_bt"],"",this.m_callback));
         }
         if(this.m_reward_frame.hasOwnProperty("reward_name_tf"))
         {
            addWidget(this.m_rewardNameTf = new ZwTextField(this.m_reward_frame["reward_name_tf"]),"");
            this.m_rewardNameTf.visible = true;
         }
         if(m_window.hasOwnProperty("close_bt"))
         {
         }
         if(this.m_reward)
         {
            this.m_rewardicon.loadIcon(this.m_reward.getImageByName("feed",true));
            this.m_rewardicon.visible = true;
            this.m_rewardicon.setIconSize(200,200);
            this.m_title_tf.text = "CONGRATS!";
            this.m_title_tf.visible = true;
            this.m_subtitle1_tf.text = "Congratulations, you won " + this.m_reward.friendlyTitle;
            this.m_rewardNameTf.text = "for completing today’s daily goal!";
            this.m_subtitle1_tf.visible = true;
            this.m_subtitle2_tf.text = "Find it in your giftbox!";
            this.m_subtitle2_tf.visible = true;
            this.m_awesome_bt.text = "Awesome";
            this.m_awesome_bt.visible = true;
         }
      }
      
      private function get manager() : BoraBoraInnovationManager
      {
         return BoraBoraInnovationManager.getInstance("BoraBoraInnovation");
      }
      
      override public function close() : void
      {
         if(this.manager.mainWindow)
         {
            this.manager.mainWindow.untintWindow();
            this.manager.mainWindow.enableInput = true;
         }
         super.close();
      }
   }
}

