package Widgets.Windows
{
   import Classes.ImageLoader;
   import Classes.ZItem.FarmItem;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class FarmersMarketBonusRewardWindow extends FarmWindow
   {
      
      private static const OFFSET_OPF_Y:int = -30;
      
      protected var m_featureName:String = null;
      
      private var m_reward:FarmItem = null;
      
      private var m_callback:Function = null;
      
      protected var title_tf:ZwTextField = null;
      
      protected var m_zoomingScale:int = 3;
      
      private var m_flow:int;
      
      private var m_bgLoader:ImageLoader = null;
      
      private var m_bgIcon:DisplayObject = null;
      
      private var m_rewardImage:String = null;
      
      private var m_buildingIconMc:MovieClip;
      
      private var m_rewardIcon:FarmIcon;
      
      private var m_buildingNameTf:ZwTextField;
      
      private var m_bodyTf:ZwTextField;
      
      private var m_subTextTf:ZwTextField;
      
      private var m_acceptBt:FarmAnimatedTextButton;
      
      private var m_titleTf:ZwTextField;
      
      private var m_bonus1:MovieClip;
      
      private var m_bonus2:MovieClip;
      
      private var m_bonus3:MovieClip;
      
      private var m_bonus4:MovieClip;
      
      private var m_bonusRewardMc:MovieClip;
      
      private var m_ide3AniMc:MovieClip;
      
      private var m_levelTf:ZwTextField;
      
      public function FarmersMarketBonusRewardWindow(dialogAsset:String, featureName:String, rewardItem:FarmItem = null, flow:int = 0, buttonCallback:Function = null)
      {
         this.m_reward = rewardItem;
         this.m_featureName = featureName;
         this.m_flow = flow;
         this.m_callback = buttonCallback;
         super(dialogAsset);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty("okay_bt"))
         {
            if(Boolean(this.m_reward) && Boolean(this.m_callback))
            {
               addWidget(new FarmAnimatedTextButton(m_window["okay_bt"],"Share",this.m_callback));
            }
         }
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(this.m_titleTf = new ZwTextField(m_window["title_tf"]));
            if(this.m_flow == 1)
            {
               this.m_titleTf.text = "Hard Work Pays!";
            }
            else if(this.m_flow == 2)
            {
               this.m_titleTf.text = "Market Closed";
            }
            this.m_titleTf.visible = true;
         }
         if(m_window.hasOwnProperty("body_tf"))
         {
            addWidget(this.m_bodyTf = new ZwTextField(m_window["body_tf"]));
            if(this.m_flow == 1)
            {
               this.m_bodyTf.text = "You are truly an amazing Seller! You have won the " + this.m_reward.friendlyTitle + ". Find it in your giftbox.";
            }
            else if(this.m_flow == 2)
            {
               this.m_bodyTf.text = "Your selling season has now come to an end.";
            }
            this.m_bodyTf.visible = true;
         }
         if(Boolean(this.m_reward) && m_window.hasOwnProperty("bonus_reward_mc"))
         {
            this.m_bonusRewardMc = m_window["bonus_reward_mc"] as MovieClip;
            if(this.m_bonusRewardMc.hasOwnProperty("level_mc"))
            {
               addWidget(this.m_levelTf = new ZwTextField(this.m_bonusRewardMc["level_mc"]["level_tf"]));
            }
            if(this.m_bonusRewardMc.hasOwnProperty("Bonus_1"))
            {
               this.m_bonus1 = this.m_bonusRewardMc["Bonus_1"] as MovieClip;
               this.m_bonus1.visible = false;
            }
            if(this.m_bonusRewardMc.hasOwnProperty("Bonus_2"))
            {
               this.m_bonus2 = this.m_bonusRewardMc["Bonus_2"] as MovieClip;
               this.m_bonus2.visible = false;
            }
            if(this.m_bonusRewardMc.hasOwnProperty("Bonus_3"))
            {
               this.m_bonus3 = this.m_bonusRewardMc["Bonus_3"] as MovieClip;
               this.m_bonus3.visible = false;
            }
            if(this.m_bonusRewardMc.hasOwnProperty("Bonus_4"))
            {
               this.m_bonus4 = this.m_bonusRewardMc["Bonus_4"] as MovieClip;
               this.m_bonus4.visible = false;
            }
            if(Boolean(this.m_reward) && this.m_reward.name == "xfs_streetvendorshop")
            {
               this.m_bonus1.visible = true;
            }
            else if(Boolean(this.m_reward) && this.m_reward.name == "xfs_valleymarketshop")
            {
               this.m_bonus2.visible = true;
            }
            else if(Boolean(this.m_reward) && this.m_reward.name == "xfs_valleygroceryshop")
            {
               this.m_bonus3.visible = true;
            }
            else if(Boolean(this.m_reward) && this.m_reward.name == "xfs_farmfreshsupermarket")
            {
               this.m_bonus4.visible = true;
            }
            this.m_levelTf.text = this.m_reward.friendlyTitle;
            this.m_levelTf.visible = true;
            this.m_bonusRewardMc.visible = true;
         }
         if(!this.m_reward && m_window.hasOwnProperty("idle3_ani_mc"))
         {
            this.m_ide3AniMc = m_window["idle3_ani_mc"] as MovieClip;
            this.m_ide3AniMc.visible = true;
         }
         if(m_window.hasOwnProperty("body2_tf"))
         {
            addWidget(this.m_subTextTf = new ZwTextField(m_window["body2_tf"]));
            if(this.m_flow == 1)
            {
               this.m_subTextTf.text = "Harvest " + this.m_reward.friendlyTitle + " every day for next 14 days to get consumables!";
            }
            else if(this.m_flow == 2)
            {
               this.m_subTextTf.text = "That was fun. It was great having you around!";
            }
            this.m_subTextTf.visible = true;
         }
         m_window.visible = true;
      }
   }
}

