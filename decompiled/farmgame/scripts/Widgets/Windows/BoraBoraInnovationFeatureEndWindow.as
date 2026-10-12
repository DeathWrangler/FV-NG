package Widgets.Windows
{
   import Classes.ZItem.FarmItem;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   
   public class BoraBoraInnovationFeatureEndWindow extends FarmWindow
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
      
      private var m_finalRewardMc:MovieClip;
      
      public function BoraBoraInnovationFeatureEndWindow(dialogAsset:String, featureName:String, rewardItem:FarmItem = null, buttonCallback:Function = null, isMilestone:Boolean = false)
      {
         super(dialogAsset,true,true);
         this.m_reward = rewardItem;
         this.m_featureName = featureName;
         this.m_callback = buttonCallback;
         this.m_isMilestone = isMilestone;
      }
      
      override protected function postLoadComplete() : void
      {
         var itemName:String = null;
         super.postLoadComplete();
         if(m_window.hasOwnProperty("final_reward_window_mc"))
         {
            this.m_finalRewardMc = m_window["final_reward_window_mc"] as MovieClip;
            this.m_finalRewardMc.visible = true;
            if(this.m_finalRewardMc.hasOwnProperty("title_tf"))
            {
               addWidget(this.m_title_tf = new ZwTextField(this.m_finalRewardMc["title_tf"],"End of the Season"));
               this.m_title_tf.visible = true;
            }
            if(this.m_finalRewardMc.hasOwnProperty("header_tf"))
            {
               addWidget(this.m_subtitle1_tf = new ZwTextField(this.m_finalRewardMc["header_tf"]));
               if(Boolean(this.m_callback))
               {
                  this.m_subtitle1_tf.text = "Amazing Work! I knew you’ll do great.";
               }
               else
               {
                  this.m_subtitle1_tf.text = "You didn\'t get enough stars to win a bonus reward.";
               }
            }
            if(this.m_finalRewardMc.hasOwnProperty("subtitle_tf"))
            {
               addWidget(this.m_subtitle2_tf = new ZwTextField(this.m_finalRewardMc["subtitle_tf"]));
               if(Boolean(this.m_callback))
               {
                  this.m_subtitle2_tf.text = "Here is your bonus reward as promised, Enjoy! Remember to harvest it each day for 14 days.";
               }
               else
               {
                  this.m_subtitle2_tf.text = "Here is a small reward for all your efforts!";
               }
            }
            if(this.m_finalRewardMc.hasOwnProperty("reward_img_mc"))
            {
               addWidget(this.m_rewardicon = new FarmIcon(this.m_finalRewardMc["reward_img_mc"]));
               itemName = this.m_reward.friendlyTitle;
               if(this.m_reward.name == "xbb_weddingstore")
               {
                  this.m_rewardicon.loadIcon(Global.getAssetURL("assets/buildings/xbb_weddingstore_icon_200.png"));
               }
               else if(this.m_reward.name == "xbb_weddingstudio")
               {
                  this.m_rewardicon.loadIcon(Global.getAssetURL("assets/buildings/xbb_weddingstudio_icon_200.png"));
               }
               else if(this.m_reward.name == "xbb_weddingparlor")
               {
                  this.m_rewardicon.loadIcon(Global.getAssetURL("assets/buildings/xbb_weddingparlor_icon_200.png"));
               }
               else if(this.m_reward.name == "xbb_weddingsalon")
               {
                  this.m_rewardicon.loadIcon(Global.getAssetURL("assets/buildings/xbb_weddingsalon_icon_200.png"));
               }
               else if(this.m_reward.name == "xbb_threebuilding")
               {
                  this.m_rewardicon.loadIcon(Global.getAssetURL("assets/dialogs/april_innovation_2020/fourbuildings.png"));
               }
               else
               {
                  this.m_rewardicon.loadIcon("assets/dialogs/april_innovation_2020/pack2_200.png");
               }
               this.m_rewardicon.attachTooltip(new FarmTextTooltip(itemName));
               if(this.m_reward.name == "xbb_threebuilding")
               {
                  this.m_rewardicon.setIconSize(200,200);
               }
               else
               {
                  this.m_rewardicon.setIconSize(200,200);
               }
            }
            if(this.m_finalRewardMc.hasOwnProperty("share_bt"))
            {
               addWidget(this.m_awesome_bt = new FarmAnimatedTextButton(this.m_finalRewardMc["share_bt"],"Share!",this.m_callback));
            }
         }
      }
      
      override public function close() : void
      {
         super.close();
      }
   }
}

