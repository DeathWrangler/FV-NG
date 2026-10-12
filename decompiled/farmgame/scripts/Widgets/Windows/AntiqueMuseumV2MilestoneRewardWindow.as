package Widgets.Windows
{
   import Classes.ImageLoader;
   import Classes.ZItem.FarmItem;
   import Managers.AntiqueMuseumV2Manager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class AntiqueMuseumV2MilestoneRewardWindow extends FarmWindow
   {
      
      private static const OFFSET_OPF_Y:int = -30;
      
      protected var m_featureName:String = null;
      
      private var m_reward:FarmItem = null;
      
      private var m_icon:FarmIcon = null;
      
      private var m_rewardIcon:FarmIcon = null;
      
      private var m_callback:Function = null;
      
      protected var title_tf:ZwTextField = null;
      
      protected var body_tf:ZwTextField;
      
      protected var body1_tf:ZwTextField;
      
      protected var m_bonus_mc:MovieClip;
      
      protected var m_zoomingScale:int = 3;
      
      private var m_bgLoader:ImageLoader = null;
      
      private var m_bgIcon:DisplayObject = null;
      
      private var m_gift_mc:MovieClip = new MovieClip();
      
      private var m_rewardImage:String = null;
      
      private var m_isLBReward:Boolean = false;
      
      private var m_accept_bt:FarmButton;
      
      private var m_pieceName:String = "";
      
      private var m_rewardPackMC:MovieClip;
      
      private var m_isMilestone:Boolean = false;
      
      private var m_isFinalReward:Boolean = false;
      
      public function AntiqueMuseumV2MilestoneRewardWindow(dialogAsset:String, featureName:String, rewardItem:FarmItem = null, buttonCallback:Function = null, dialogBackground:String = null, rewardIcon:String = null, pieceName:String = "", isMilestone:* = false)
      {
         super(dialogAsset);
         this.m_reward = rewardItem;
         this.m_featureName = featureName;
         this.m_callback = buttonCallback;
         this.m_rewardImage = rewardIcon;
         this.m_pieceName = pieceName;
         this.m_isMilestone = isMilestone;
         this.m_isFinalReward = rewardItem.name == "xcd_naturalhistorymuseum";
         if(dialogBackground != null)
         {
            this.m_bgLoader = ImageLoader.getInstance(Global.getAssetURL(dialogBackground));
            this.m_bgLoader.getContent(this.onBgLoad);
         }
      }
      
      private function onBgLoad(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_bgIcon = dispObj;
      }
      
      override protected function postLoadComplete() : void
      {
         var iconUrl:String = null;
         super.postLoadComplete();
         var itemName:String = "";
         if(this.m_reward != null)
         {
            itemName = this.m_reward.friendlyTitle;
         }
         if(m_window != null)
         {
            if(m_window.hasOwnProperty("title_tf"))
            {
               this.title_tf = addWidget(new ZwTextField(m_window["title_tf"],"Fossil Completed!")) as ZwTextField;
               if(this.m_isFinalReward)
               {
                  this.title_tf.text = "CONGRATS!";
               }
               else if(this.m_isMilestone)
               {
                  this.title_tf.text = "Congratulations!";
               }
            }
            if(m_window.hasOwnProperty("item_tf"))
            {
               addWidget(this.body_tf = new ZwTextField(m_window["item_tf"],"You completed " + itemName + "! And it has been added for public display"));
               if(this.m_isFinalReward)
               {
                  this.body_tf.text = "You completed " + itemName + "!";
               }
               else if(this.m_isMilestone)
               {
                  this.body_tf.text = "You\'ve reached a milestone!";
               }
               this.body_tf.visible = true;
            }
            if(m_window.hasOwnProperty("reward_pack"))
            {
               this.m_rewardPackMC = m_window["reward_pack"] as MovieClip;
               this.m_rewardPackMC.visible = !this.m_isMilestone;
            }
            if(m_window.hasOwnProperty("info_tf"))
            {
               addWidget(this.body1_tf = new ZwTextField(m_window["info_tf"],"You can find a " + itemName + " and a Pack of Farm Essentials in your giftbox."));
               if(this.m_isFinalReward)
               {
                  this.body1_tf.text = "You can find " + itemName + " in your gift box and can be harvest for 14 Days";
               }
               else if(this.m_isMilestone)
               {
                  this.body1_tf.text = "You can find a " + itemName + " in your giftbox.";
               }
               this.body1_tf.visible = true;
            }
            if(m_window.hasOwnProperty("accept_bt"))
            {
               if(this.m_callback == null)
               {
                  this.m_callback = onClose;
               }
               addWidget(this.m_accept_bt = new FarmAnimatedTextButton(m_window["accept_bt"],"Awesome",this.m_callback));
               this.m_accept_bt.visible = true;
            }
            if(m_window.hasOwnProperty("icon_mc"))
            {
               iconUrl = this.m_reward.getImageByName(FarmItem.ICON_FEED);
               this.m_rewardIcon = addWidget(new FarmIcon(m_window["icon_mc"],iconUrl)) as FarmIcon;
               this.m_rewardIcon.setIconSize(175,175);
            }
         }
      }
      
      private function get manager() : AntiqueMuseumV2Manager
      {
         return AntiqueMuseumV2Manager.getInstance();
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

