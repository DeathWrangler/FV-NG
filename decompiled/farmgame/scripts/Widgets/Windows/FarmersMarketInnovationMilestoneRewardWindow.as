package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ImageLoader;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.OrderBoard.FarmersMarketInnovationManager;
   import Managers.TemplateUIUtility;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   
   public class FarmersMarketInnovationMilestoneRewardWindow extends FarmWindow
   {
      
      private static const OFFSET_OPF_Y:int = -30;
      
      protected var m_featureName:String = null;
      
      private var m_reward:FarmItem = null;
      
      private var m_icon:FarmIcon = null;
      
      private var m_rewardIcon:FarmIcon = null;
      
      private var m_callback:Function = null;
      
      protected var title_tf:ZwTextField = null;
      
      protected var m_zoomingScale:int = 3;
      
      private var m_bgLoader:ImageLoader = null;
      
      private var m_bgIcon:DisplayObject = null;
      
      private var m_gift_mc:MovieClip = new MovieClip();
      
      private var m_rewardImage:String = null;
      
      private var m_isLBReward:Boolean = false;
      
      private var m_score:int = 0;
      
      private var m_lbRank:int = 0;
      
      private var m_isMilestone:Boolean = false;
      
      private var m_lbWeekNum:int = 0;
      
      private var m_share_bt:FarmAnimatedTextButton;
      
      private var m_okay_bt:FarmAnimatedTextButton;
      
      public function FarmersMarketInnovationMilestoneRewardWindow(dialogAsset:String, featureName:String, rewardItem:FarmItem = null, buttonCallback:Function = null, dialogBackground:String = null, isMilestone:Boolean = false, rewardIcon:String = null, score:int = 0, rank:int = 0, isLB:Boolean = false, weekNumByName:int = 0)
      {
         super(dialogAsset);
         this.m_reward = rewardItem;
         this.m_featureName = featureName;
         this.m_callback = buttonCallback;
         this.m_rewardImage = rewardIcon;
         this.m_isLBReward = isLB;
         this.m_score = score;
         this.m_lbRank = rank;
         this.m_isMilestone = isMilestone;
         this.m_lbWeekNum = weekNumByName;
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
         var buttonCallback:Function = null;
         var iconUrl:String = null;
         super.postLoadComplete();
         var itemName:String = "";
         if(this.m_reward != null)
         {
            itemName = this.m_reward.friendlyTitle;
         }
         if(m_window != null)
         {
            if(m_window.hasOwnProperty("generic_tf"))
            {
               this.title_tf = addWidget(new ZwTextField(m_window["generic_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "GenericText",{"itemName":itemName}))) as ZwTextField;
               if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
               {
                  TemplateUIUtility.applyExpansionTextColor(m_window.generic_tf);
                  TemplateUIUtility.applyExpansionBevelFilter(m_window.generic_tf);
                  TemplateUIUtility.applyExpansionDropShadowFilter(m_window.generic_tf);
               }
            }
            else if(m_window.hasOwnProperty("title_tf"))
            {
               this.title_tf = addWidget(new ZwTextField(m_window["title_tf"],"Congratulations!")) as ZwTextField;
               if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
               {
                  TemplateUIUtility.applyExpansionTextColor(m_window.title_tf);
                  TemplateUIUtility.applyExpansionBevelFilter(m_window.title_tf);
                  TemplateUIUtility.applyExpansionDropShadowFilter(m_window.title_tf);
               }
            }
            if(m_window.hasOwnProperty("subtext1_tf"))
            {
               if(this.manager.hasExpiryDatePassedForFeature())
               {
                  addWidget(new ZwTextField(m_window["subtext1_tf"],"Farmers Market has ended. Thank you for participating!"));
               }
               else if(this.m_isLBReward)
               {
                  addWidget(new ZwTextField(m_window["subtext1_tf"],"You scored " + this.m_score.toString() + " and attained Rank " + this.m_lbRank + " in Week " + this.m_lbWeekNum + "\'s Leaderboard"));
               }
               else
               {
                  addWidget(new ZwTextField(m_window["subtext1_tf"],"You have earned " + this.m_score.toString() + " coins and won a " + itemName));
               }
               if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
               {
                  TemplateUIUtility.applyExpansionSubTextColor(m_window.subtext1_tf);
               }
            }
            if(m_window.hasOwnProperty("subtext2_tf"))
            {
               if(this.manager.hasExpiryDatePassedForFeature())
               {
                  addWidget(new ZwTextField(m_window["subtext2_tf"],"You scored " + this.m_score + " and got Rank " + this.m_lbRank + " in Week " + this.m_lbWeekNum + ",\n and won these amazing rewards!"));
               }
               else if(this.m_isLBReward)
               {
                  addWidget(new ZwTextField(m_window["subtext2_tf"],"You\'ve won these amazing rewards!"));
               }
               else
               {
                  addWidget(new ZwTextField(m_window["subtext2_tf"],"Keep selling to become a Super Farmer!"));
               }
               if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
               {
                  TemplateUIUtility.applyExpansionGlowFilter(m_window.subtext2_tf);
               }
            }
            if(m_window.hasOwnProperty("giftbox_mc"))
            {
               this.m_gift_mc = m_window.giftbox_mc;
               this.m_gift_mc.visible = true;
            }
            buttonCallback = new Function();
            if(this.m_isMilestone)
            {
               if(m_window.hasOwnProperty("share_bt"))
               {
                  buttonCallback = this.onClose;
                  if(this.m_callback != null)
                  {
                     buttonCallback = this.m_callback;
                  }
                  this.m_share_bt = addWidget(new FarmAnimatedTextButton(m_window["share_bt"],"Share",this.shareMilestoneCallback)) as FarmAnimatedTextButton;
                  this.m_share_bt.visible = true;
                  if(m_closeButton)
                  {
                     m_closeButton.visible = true;
                  }
               }
            }
            else if(m_window.hasOwnProperty("accept_bt"))
            {
               buttonCallback = this.onClose;
               if(this.m_callback != null)
               {
                  buttonCallback = this.m_callback;
               }
               this.m_okay_bt = addWidget(new FarmAnimatedTextButton(m_window["accept_bt"],"Awesome!",buttonCallback)) as FarmAnimatedTextButton;
               this.m_okay_bt.visible = true;
               if(m_closeButton)
               {
                  m_closeButton.visible = false;
               }
            }
            if(m_window.hasOwnProperty("icon_mc"))
            {
               iconUrl = this.m_reward.getImageByName(FarmItem.ICON_200);
               if(iconUrl == null)
               {
                  iconUrl = this.m_reward.getImageByName(FarmItem.ICON_FEED);
                  if(iconUrl == null)
                  {
                     iconUrl = this.m_reward.iconUrl;
                  }
               }
               this.m_icon = addWidget(new FarmIcon(m_window["icon_mc"],iconUrl)) as FarmIcon;
               this.m_icon.setIconSize(150,150);
            }
            else if(m_window.hasOwnProperty("opf_mc"))
            {
               this.addWidget(new ObjectPreviewFrame(m_window.opf_mc,this.m_reward,null,[this.m_zoomingScale],null,"","",null,new Point(0,OFFSET_OPF_Y)));
            }
            else if(m_window.hasOwnProperty("reward_mc"))
            {
               if(Boolean(this.m_rewardImage) && this.m_rewardImage != "")
               {
                  iconUrl = this.m_rewardImage;
               }
               else
               {
                  iconUrl = this.m_reward.getImageByName(FarmItem.ICON_200);
                  if(iconUrl == null)
                  {
                     iconUrl = this.m_reward.getImageByName(FarmItem.ICON_FEED);
                  }
               }
               this.m_rewardIcon = addWidget(new FarmIcon(m_window["reward_mc"],iconUrl)) as FarmIcon;
               if(!this.m_isLBReward)
               {
                  this.m_rewardIcon.setIconSize(175,175);
               }
            }
            if(Boolean(m_window.mc_RewardDialog) && Boolean(this.m_bgIcon))
            {
               m_window.addChildAt(this.m_bgIcon,m_window.getChildIndex(m_window.mc_RewardDialog));
            }
         }
         if(this.manager.mainWindow)
         {
            this.manager.mainWindow.tintWindow();
            this.manager.mainWindow.enableInput = false;
         }
      }
      
      private function get manager() : FarmersMarketInnovationManager
      {
         return FarmersMarketInnovationManager.getInstance();
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         if(m_closeButton)
         {
            m_closeButton.visible = false;
         }
         if(this.m_isMilestone)
         {
            if(m_closeButton)
            {
               m_closeButton.visible = true;
            }
            if(this.m_okay_bt)
            {
               this.m_okay_bt.visible = false;
            }
            if(this.m_share_bt)
            {
               this.m_share_bt.visible = true;
            }
         }
         else
         {
            if(this.m_share_bt)
            {
               this.m_share_bt.visible = false;
            }
            if(this.m_okay_bt)
            {
               this.m_okay_bt.visible = true;
            }
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         if(this.manager.mainWindow)
         {
            this.manager.mainWindow.untintWindow();
            this.manager.mainWindow.enableInput = true;
         }
         super.onClose(event);
      }
      
      public function shareMilestoneCallback(e:Event) : void
      {
         var windowName:String = "FarmersMarket2020Innovation";
         var bundleId:String = windowName + "ShareMilestone";
         var imageIcon:String = this.m_reward.iconUrl;
         var bundleData:Object = {
            "images":[{
               "href":"{SN_APP_URL}",
               "src":imageIcon
            }],
            "user":Global.player.name,
            "first_name":Global.player.firstName,
            "item":this.m_reward.friendlyTitle
         };
         if(m_window)
         {
            close();
         }
         GlobalEngine.socialNetwork.publishFeedStory(bundleId,bundleData,[],false,null);
      }
   }
}

