package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ImageLoader;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.AmsterdamInnovationManager;
   import Managers.TemplateUIUtility;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   
   public class AmsterdamInnovationLeagueRewardWindow extends FarmWindow
   {
      
      private static const OFFSET_OPF_Y:int = -30;
      
      protected var m_featureName:String = null;
      
      private var m_reward:FarmItem = null;
      
      private var m_callback:Function = null;
      
      protected var title_tf:ZwTextField = null;
      
      protected var m_zoomingScale:int = 3;
      
      private var m_bgLoader:ImageLoader = null;
      
      private var m_bgIcon:DisplayObject = null;
      
      private var m_gift_mc:MovieClip = new MovieClip();
      
      private var m_performanceType:String;
      
      public function AmsterdamInnovationLeagueRewardWindow(dialogAsset:String, featureName:String, rewardItem:FarmItem = null, buttonCallback:Function = null, dialogBackground:String = null, performanceType:String = null)
      {
         super(dialogAsset);
         this.m_reward = rewardItem;
         this.m_featureName = featureName;
         this.m_callback = buttonCallback;
         this.m_performanceType = performanceType;
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
         var icon:FarmIcon = null;
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
               this.title_tf = addWidget(new ZwTextField(m_window["title_tf"],this.texts[0])) as ZwTextField;
               if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
               {
                  TemplateUIUtility.applyExpansionTextColor(m_window.title_tf);
                  TemplateUIUtility.applyExpansionBevelFilter(m_window.title_tf);
                  TemplateUIUtility.applyExpansionDropShadowFilter(m_window.title_tf);
               }
            }
            if(m_window.hasOwnProperty("subtext1_tf"))
            {
               addWidget(new ZwTextField(m_window["subtext1_tf"],this.texts[1]));
               if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
               {
                  TemplateUIUtility.applyExpansionSubTextColor(m_window.subtext1_tf);
               }
            }
            if(m_window.hasOwnProperty("subtext2_tf"))
            {
               addWidget(new ZwTextField(m_window["subtext2_tf"],this.texts[2]));
               if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
               {
                  TemplateUIUtility.applyExpansionGlowFilter(m_window.subtext2_tf);
               }
            }
            if(m_window.hasOwnProperty("giftbox_mc"))
            {
               this.m_gift_mc = m_window.giftbox_mc;
               if(this.m_performanceType == AmsterdamInnovationManager.PERFORMANCE_TYPE.DEMOTION)
               {
                  this.m_gift_mc.visible = false;
               }
               else
               {
                  this.m_gift_mc.visible = true;
               }
            }
            buttonCallback = new Function();
            if(m_window.hasOwnProperty("accept_bt"))
            {
               buttonCallback = this.onClose;
               if(this.m_callback != null)
               {
                  buttonCallback = this.m_callback;
               }
               addWidget(new FarmAnimatedTextButton(m_window["accept_bt"],this.texts[3],buttonCallback),true);
            }
            icon = null;
            if(m_window.hasOwnProperty("icon_mc"))
            {
               addWidget(icon = new FarmIcon(m_window["icon_mc"],this.getIconURL()));
            }
            else if(m_window.hasOwnProperty("opf_mc"))
            {
               this.addWidget(new ObjectPreviewFrame(m_window.opf_mc,this.m_reward,null,[this.m_zoomingScale],null,"","",null,new Point(0,OFFSET_OPF_Y)));
            }
            else if(m_window.hasOwnProperty("reward_mc"))
            {
               addWidget(icon = new FarmIcon(m_window["reward_mc"],this.getIconURL()));
            }
            if(icon)
            {
               icon.setIconSize(200,200);
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
      
      private function get manager() : AmsterdamInnovationManager
      {
         return AmsterdamInnovationManager.getInstance();
      }
      
      public function getIconURL() : String
      {
         var iconUrl:String = "";
         if(this.m_reward)
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
         }
         else
         {
            iconUrl = Global.getAssetURL("assets/dialogs/winternord/icon_welcome.png");
         }
         return iconUrl;
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         if(m_closeButton)
         {
            m_closeButton.visible = false;
         }
      }
      
      private function get texts() : Array
      {
         var nextLeague:String = null;
         var league:String = AmsterdamInnovationManager.getInstance().Amsterdam_LEAGUE_MAP[this.manager.getCurrentLeague()];
         var title:String = "CONGRATS!";
         var subtextOne:String = "";
         var subtextTwo:String = "";
         var buttonText:String = "Great!";
         if(this.manager.hasFeatureExpired())
         {
            subtextOne = "The Competition is over now!";
            subtextTwo = "You ended the competition in " + league + " League!";
            buttonText = "Good!";
            return [title,subtextOne,subtextTwo,buttonText];
         }
         switch(this.m_performanceType)
         {
            case AmsterdamInnovationManager.PERFORMANCE_TYPE.PROMOTION:
               subtextOne = "Well done! You have been promoted to the " + league + " League.";
               subtextTwo = "Keep playing to get the best prizes every week!";
               break;
            case AmsterdamInnovationManager.PERFORMANCE_TYPE.RETENTION:
               if(league == "Diamond")
               {
                  subtextOne = "Nice Work! You managed to stay in the " + league + " League.";
                  subtextTwo = "Maintain your pace to stay in this league and get the best rewards!";
               }
               else
               {
                  nextLeague = AmsterdamInnovationManager.getInstance().Amsterdam_LEAGUE_MAP[this.manager.getNextLeague()];
                  subtextOne = "You continue to play in the " + league + " League.";
                  subtextTwo = "Try your best to get promoted to the " + nextLeague + " League next week!";
                  buttonText = "Good!";
               }
         }
         return [title,subtextOne,subtextTwo,buttonText];
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
         else
         {
            this.manager.showMainUI();
         }
         super.onClose(event);
      }
   }
}

