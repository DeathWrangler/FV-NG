package Widgets.Windows
{
   import Classes.ImageLoader;
   import Managers.OrderBoard.IrelandInnovationManager;
   import Managers.TemplateUIUtility;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class IrelandInnovationBuildingUpgradeWindow extends FarmWindow
   {
      
      private static const FEATURE_NAME:String = "IrelandInnovation";
      
      protected var m_featureName:String = null;
      
      private var m_iconUrl:String = "";
      
      private var m_callback:Function = null;
      
      protected var title_tf:ZwTextField = null;
      
      protected var m_zoomingScale:int = 3;
      
      private var m_bgLoader:ImageLoader = null;
      
      private var m_bgIcon:DisplayObject = null;
      
      private var m_gift_mc:MovieClip = new MovieClip();
      
      private var m_buildingName:String;
      
      private var m_isLastUpgrade:Boolean;
      
      public function IrelandInnovationBuildingUpgradeWindow(dialogAsset:String, featureName:String, buildingData:Object, buttonCallback:Function = null, dialogBackground:String = null)
      {
         super(dialogAsset);
         this.m_iconUrl = buildingData.iconUrl;
         this.m_buildingName = buildingData.name;
         this.m_featureName = featureName;
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
               if(!this.m_buildingName)
               {
                  this.m_buildingName = "Town Building";
               }
               addWidget(new ZwTextField(m_window["subtext1_tf"],"Your " + this.m_buildingName + " is complete!"));
               if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
               {
                  TemplateUIUtility.applyExpansionSubTextColor(m_window.subtext1_tf);
               }
            }
            if(m_window.hasOwnProperty("giftbox_mc"))
            {
               this.m_gift_mc = m_window.giftbox_mc;
               this.m_gift_mc.visible = false;
            }
            buttonCallback = new Function();
            if(m_window.hasOwnProperty("accept_bt"))
            {
               buttonCallback = this.onClose;
               if(this.m_callback != null)
               {
                  buttonCallback = this.m_callback;
               }
               addWidget(new FarmAnimatedTextButton(m_window["accept_bt"],"Awesome!",buttonCallback),true);
            }
            if(m_window.hasOwnProperty("icon_mc"))
            {
               addWidget(new FarmIcon(m_window["icon_mc"],this.m_iconUrl));
            }
            else if(m_window.hasOwnProperty("reward_mc"))
            {
               addWidget(new FarmIcon(m_window["reward_mc"],this.m_iconUrl));
            }
            if(Boolean(m_window.mc_RewardDialog) && Boolean(this.m_bgIcon))
            {
               m_window.addChildAt(this.m_bgIcon,m_window.getChildIndex(m_window.mc_RewardDialog));
            }
         }
         if(this.manager.m_mainWindow)
         {
            this.manager.m_mainWindow.tintWindow();
            this.manager.m_mainWindow.enableInput = false;
         }
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         if(m_closeButton)
         {
            m_closeButton.visible = false;
         }
      }
      
      private function get manager() : IrelandInnovationManager
      {
         return IrelandInnovationManager.getInstance(FEATURE_NAME);
      }
      
      override protected function onClose(event:Event) : void
      {
         if(this.manager.m_mainWindow)
         {
            if(this.manager.canUntintMainWindow())
            {
               this.manager.m_mainWindow.untintWindow();
               this.manager.m_mainWindow.enableInput = true;
            }
         }
         this.manager.panToMapTrigger();
         super.onClose(event);
      }
   }
}

