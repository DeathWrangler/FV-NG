package Widgets.Windows
{
   import Classes.ImageLoader;
   import Managers.FarmStatsManager;
   import Managers.MadagascarInnovationManager;
   import Managers.TemplateUIUtility;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class MadagascarInnovationBadgeGrantWindow extends FarmWindow
   {
      
      private static const FEATURE_NAME:String = "MadagascarInnovation";
      
      private var QTY_NAME_MAP:Object = {
         50:"Bronze Medal",
         100:"Silver Medal",
         300:"Gold Medal"
      };
      
      protected var m_featureName:String = null;
      
      private var m_iconUrl:String = "";
      
      private var m_feedUrl:String = "";
      
      private var m_callback:Function = null;
      
      protected var title_tf:ZwTextField = null;
      
      protected var m_zoomingScale:int = 3;
      
      private var m_bgLoader:ImageLoader = null;
      
      private var m_bgIcon:DisplayObject = null;
      
      private var m_gift_mc:MovieClip = new MovieClip();
      
      private var m_qty:int;
      
      public function MadagascarInnovationBadgeGrantWindow(dialogAsset:String, featureName:String, iconUrl:String = null, buttonCallback:Function = null, dialogBackground:String = null, qty:int = 0, feedUrl:String = null)
      {
         super(dialogAsset);
         this.m_iconUrl = iconUrl;
         this.m_feedUrl = feedUrl;
         this.m_featureName = featureName;
         this.m_qty = qty;
         this.m_callback = buttonCallback;
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
         super.postLoadComplete();
         if(m_window != null)
         {
            if(m_window.hasOwnProperty("title_tf"))
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
               addWidget(new ZwTextField(m_window["subtext1_tf"],"You completed " + this.m_qty + " orders and have earned the " + this.QTY_NAME_MAP[this.m_qty] + " !"));
               if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
               {
                  TemplateUIUtility.applyExpansionSubTextColor(m_window.subtext1_tf);
               }
            }
            if(m_window.hasOwnProperty("subtext2_tf"))
            {
               addWidget(new ZwTextField(m_window["subtext2_tf"],""));
               if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
               {
                  TemplateUIUtility.applyExpansionGlowFilter(m_window.subtext2_tf);
               }
            }
            if(m_window.hasOwnProperty("giftbox_mc"))
            {
               this.m_gift_mc = m_window.giftbox_mc;
               this.m_gift_mc.visible = false;
            }
            buttonCallback = new Function();
            if(m_window.hasOwnProperty("share_bt"))
            {
               buttonCallback = this.onShare;
               if(this.m_callback != null)
               {
                  buttonCallback = this.m_callback;
               }
               addWidget(new FarmAnimatedTextButton(m_window["share_bt"],"Share!",buttonCallback),true);
            }
            if(m_window.hasOwnProperty("reward_mc"))
            {
               addWidget(new FarmIcon(m_window["reward_mc"],this.m_iconUrl));
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
         FarmStatsManager.count("MadagascarInnovation","BadgeGrant",this.QTY_NAME_MAP[this.m_qty],this.m_qty.toString());
      }
      
      private function onShare(event:Event) : void
      {
         var bundleData:Object = {
            "images":[{
               "href":"{SN_APP_URL}",
               "src":this.m_feedUrl
            }],
            "user":Global.player.firstName,
            "item":this.QTY_NAME_MAP[this.m_qty]
         };
         GlobalEngine.socialNetwork.publishFeedStory("MadagascarInnovation_share_badgeGrant",bundleData,[],false,null);
         this.manager.decrementActivePopupCount();
         if(this.manager.mainWindow)
         {
            if(this.manager.canUntintMainWindow())
            {
               this.manager.mainWindow.enableInput = true;
               this.manager.mainWindow.untintWindow();
            }
         }
         this.close();
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         if(m_closeButton)
         {
            m_closeButton.visible = true;
         }
      }
      
      private function get manager() : MadagascarInnovationManager
      {
         return MadagascarInnovationManager.getInstance(FEATURE_NAME);
      }
      
      override protected function onClose(event:Event) : void
      {
         this.manager.decrementActivePopupCount();
         if(this.manager.mainWindow)
         {
            if(this.manager.canUntintMainWindow())
            {
               this.manager.mainWindow.enableInput = true;
               this.manager.mainWindow.untintWindow();
            }
         }
         super.onClose(event);
      }
   }
}

