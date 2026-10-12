package Widgets.Windows
{
   import Classes.ImageLoader;
   import Classes.ZItem.FarmItem;
   import Managers.AnimalSanctuaryManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class AnimalSanctuarySingleRewardPopup extends FarmWindow
   {
      
      protected var m_featureName:String = null;
      
      private var m_reward:FarmItem = null;
      
      private var m_callback:Function = null;
      
      protected var title_tf:ZwTextField = null;
      
      protected var m_zoomingScale:int = 3;
      
      protected var m_closeBt:FarmButton = null;
      
      protected var subtext1_tf:ZwTextField = null;
      
      protected var subtext2_tf:ZwTextField = null;
      
      private var m_iconPreview:ObjectPreviewFrame;
      
      private var m_dialogBackground:String;
      
      private var m_bgLoader:ImageLoader = null;
      
      private var m_bgIcon:DisplayObject = null;
      
      private var m_share_bt:FarmAnimatedTextButton;
      
      private var m_okay_bt:FarmAnimatedTextButton;
      
      private var m_iconUrl:String;
      
      private var m_icon_mc:FarmIcon;
      
      private var m_stage:int;
      
      private var m_isBonusReward:Boolean;
      
      public function AnimalSanctuarySingleRewardPopup(dialogAsset:String, featureName:String, rewardItem:FarmItem = null, buttonCallback:Function = null, dialogBackground:String = null, imageIcon:String = null, stage:int = 0, isBonusReward:Boolean = false)
      {
         super(dialogAsset,true,true);
         this.m_reward = rewardItem;
         this.m_featureName = featureName;
         this.m_callback = buttonCallback;
         this.m_dialogBackground = dialogBackground;
         this.m_iconUrl = imageIcon;
         this.m_stage = stage;
         this.m_isBonusReward = isBonusReward;
         if(this.m_dialogBackground != null)
         {
            this.m_bgLoader = ImageLoader.getInstance(Global.getAssetURL(this.m_dialogBackground));
            this.m_bgLoader.getContent(this.onBgLoad);
         }
      }
      
      private function onBgLoad(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_bgIcon = dispObj;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         var itemFriendlyTitle:String = "";
         if(this.m_reward != null)
         {
            itemFriendlyTitle = this.m_reward.friendlyTitle;
         }
         var itemName:String = this.m_reward.name;
         if(m_window != null)
         {
            if(m_window.hasOwnProperty("title_tf"))
            {
               this.title_tf = addWidget(new ZwTextField(m_window["title_tf"],"Congratulations!")) as ZwTextField;
            }
            if(m_window.hasOwnProperty("subtext1_tf"))
            {
               this.subtext1_tf = addWidget(new ZwTextField(m_window["subtext1_tf"],"Hurrah! You’ve reached a milestone!")) as ZwTextField;
            }
            if(m_window.hasOwnProperty("subtext2_tf"))
            {
               this.subtext2_tf = addWidget(new ZwTextField(m_window["subtext2_tf"],"You\'ve won a " + itemFriendlyTitle)) as ZwTextField;
               if(this.m_stage >= 4)
               {
                  this.subtext2_tf.text = "You\'ve won a " + itemFriendlyTitle + " and Sanctuary";
               }
               if(this.m_isBonusReward)
               {
                  this.subtext1_tf.text = "You have saved all the animals and received the " + itemFriendlyTitle;
                  this.subtext2_tf.text = "";
               }
            }
            if(m_window.hasOwnProperty("share_bt"))
            {
               if(this.m_stage >= 4)
               {
                  this.m_share_bt = addWidget(new FarmAnimatedTextButton(m_window["share_bt"],"Share",this.shareCallbackLast)) as FarmAnimatedTextButton;
                  this.m_share_bt.visible = true;
               }
               else
               {
                  this.m_share_bt = addWidget(new FarmAnimatedTextButton(m_window["share_bt"],"Share",this.shareCallback)) as FarmAnimatedTextButton;
                  this.m_share_bt.visible = true;
               }
            }
            if(this.m_isBonusReward)
            {
               this.m_share_bt.callback = this.shareCallbackBonusReward;
            }
            else
            {
               this.m_share_bt.callback = this.shareCallback;
            }
            if(m_window.hasOwnProperty("icon_mc"))
            {
               this.m_icon_mc = new FarmIcon(m_window["icon_mc"]);
               this.m_icon_mc.loadIcon(this.m_iconUrl);
               this.m_icon_mc.setIconSize(300,300);
               this.m_icon_mc.visible = true;
               this.m_icon_mc.setSmoothing(true);
            }
         }
      }
      
      private function get manager() : AnimalSanctuaryManager
      {
         return AnimalSanctuaryManager.getInstance();
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         m_closeButton.visible = true;
      }
      
      override protected function onClose(event:Event) : void
      {
         if(this.m_callback != null)
         {
            this.m_callback(event);
         }
         super.onClose(event);
      }
      
      private function shareCallback(e:Event) : void
      {
         var bundleData:Object = {
            "images":[{
               "href":"{SN_APP_URL}",
               "src":this.m_reward.icon
            }],
            "user":Global.player.firstName,
            "item":this.m_reward.friendlyTitle
         };
         GlobalEngine.socialNetwork.publishFeedStory("AnimalSanctuary_share_milestoneReward",bundleData,[],false,null);
         this.onClose(e);
         FarmStatsManager.count("AnimalSanctuary","reward_bragfeed",this.m_reward.friendlyTitle);
      }
      
      private function shareCallbackLast(e:Event) : void
      {
         var bundleData:Object = {
            "images":[{
               "href":"{SN_APP_URL}",
               "src":this.m_reward.icon
            }],
            "user":Global.player.firstName,
            "item":this.m_reward.friendlyTitle
         };
         GlobalEngine.socialNetwork.publishFeedStory("AnimalSanctuary_share_last_milestoneReward",bundleData,[],false,null);
         this.onClose(e);
         FarmStatsManager.count("AnimalSanctuary","sanctuary_bragfeed",this.m_reward.friendlyTitle);
      }
      
      private function shareCallbackBonusReward(e:Event) : void
      {
         var bundleData:Object = {
            "images":[{
               "href":"{SN_APP_URL}",
               "src":this.m_reward.icon
            }],
            "user":Global.player.firstName,
            "item":this.m_reward.friendlyTitle
         };
         GlobalEngine.socialNetwork.publishFeedStory("AnimalSanctuary_share_bonusReward",bundleData,[],false,null);
         this.onClose(e);
         FarmStatsManager.count("AnimalSanctuary","bonus_bragfeed",this.m_reward.friendlyTitle);
      }
   }
}

