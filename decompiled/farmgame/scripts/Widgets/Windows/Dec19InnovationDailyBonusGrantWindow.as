package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ImageLoader;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.Dec19InnovationManager;
   import Managers.TemplateUIUtility;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   
   public class Dec19InnovationDailyBonusGrantWindow extends FarmWindow
   {
      
      private static const OFFSET_OPF_Y:int = -30;
      
      protected var m_featureName:String = null;
      
      private var m_reward:FarmItem = null;
      
      private var m_callback:Function = null;
      
      protected var title_tf:ZwTextField = null;
      
      protected var m_zoomingScale:int = 3;
      
      private var m_bgLoader:ImageLoader = null;
      
      private var m_bgIcon:DisplayObject = null;
      
      private var m_isChristmasReward_popup:Boolean;
      
      private var m_gift_mc:MovieClip = new MovieClip();
      
      public function Dec19InnovationDailyBonusGrantWindow(dialogAsset:String, featureName:String, rewardItem:FarmItem = null, buttonCallback:Function = null, dialogBackground:String = null, isChrismasRewardPopup:Boolean = false)
      {
         super(dialogAsset);
         this.m_reward = rewardItem;
         this.m_featureName = featureName;
         this.m_callback = buttonCallback;
         this.m_isChristmasReward_popup = isChrismasRewardPopup;
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
               this.title_tf = addWidget(new ZwTextField(m_window["title_tf"],"Congrats!")) as ZwTextField;
               if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
               {
                  TemplateUIUtility.applyExpansionTextColor(m_window.title_tf);
                  TemplateUIUtility.applyExpansionBevelFilter(m_window.title_tf);
                  TemplateUIUtility.applyExpansionDropShadowFilter(m_window.title_tf);
               }
            }
            if(m_window.hasOwnProperty("subtext1_tf"))
            {
               if(this.m_isChristmasReward_popup)
               {
                  addWidget(new ZwTextField(m_window["subtext1_tf"],"Here\'s your christmas reward " + itemName + "!"));
               }
               else
               {
                  addWidget(new ZwTextField(m_window["subtext1_tf"],"You’ve hit your daily target and won a " + itemName + "!"));
               }
               if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
               {
                  TemplateUIUtility.applyExpansionSubTextColor(m_window.subtext1_tf);
               }
            }
            if(m_window.hasOwnProperty("subtext2_tf"))
            {
               if(this.m_isChristmasReward_popup)
               {
                  addWidget(new ZwTextField(m_window["subtext2_tf"],"Come everyday to get cool gifts!"));
               }
               else
               {
                  addWidget(new ZwTextField(m_window["subtext2_tf"],"Keep up the spirits to be a true Champion!"));
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
            if(m_window.hasOwnProperty("accept_bt"))
            {
               buttonCallback = this.onClose;
               if(this.m_callback != null)
               {
                  buttonCallback = this.m_callback;
               }
               addWidget(new FarmAnimatedTextButton(m_window["accept_bt"],"Great!",buttonCallback),true);
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
               addWidget(new FarmIcon(m_window["icon_mc"],iconUrl));
            }
            else if(m_window.hasOwnProperty("opf_mc"))
            {
               this.addWidget(new ObjectPreviewFrame(m_window.opf_mc,this.m_reward,null,[this.m_zoomingScale],null,"","",null,new Point(0,OFFSET_OPF_Y)));
            }
            else if(m_window.hasOwnProperty("reward_mc"))
            {
               iconUrl = this.m_reward.getImageByName(FarmItem.ICON_200);
               if(iconUrl == null)
               {
                  iconUrl = this.m_reward.getImageByName(FarmItem.ICON_FEED);
               }
               addWidget(new FarmIcon(m_window["reward_mc"],iconUrl));
            }
            if(Boolean(m_window.mc_RewardDialog) && Boolean(this.m_bgIcon))
            {
               m_window.addChildAt(this.m_bgIcon,m_window.getChildIndex(m_window.mc_RewardDialog));
            }
         }
         if(this.manager.mainWindow)
         {
            this.manager.incrementActivePopupCount();
            this.manager.mainWindow.tintWindow();
            this.manager.mainWindow.enableInput = false;
         }
      }
      
      private function get manager() : Dec19InnovationManager
      {
         return Dec19InnovationManager.getInstance();
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         if(m_closeButton)
         {
            m_closeButton.visible = false;
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         this.manager.decrementActivePopupCount();
         if(this.manager.mainWindow)
         {
            if(this.manager.canUntintMainWindow())
            {
               this.manager.mainWindow.untintWindow();
               this.manager.mainWindow.enableInput = true;
            }
         }
         super.onClose(event);
      }
   }
}

