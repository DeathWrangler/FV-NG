package Widgets.Windows
{
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class SimpleToasterWindow extends AutoCloseToasterWindow
   {
      
      protected static const POPUP_NAME:String = "Simple Toaster";
      
      protected static const DEFAULT_TIME_TO_LIVE:Number = 20000;
      
      protected static const DEFAULT_ANIMATION_FRAME:int = 2;
      
      protected var m_featureName:String;
      
      protected var m_message:String;
      
      protected var m_title:String;
      
      protected var m_bgPath:String;
      
      protected var m_clickCallback:Function = null;
      
      protected var m_animatedClip:MovieClip = null;
      
      protected var m_animatedClipFrame:int;
      
      public function SimpleToasterWindow(featureName:String, message:String, windowAssetPath:String, clickCallback:Function = null, toasterTime:Number = 0, title:String = "", bgPath:String = "", animationFrame:int = 2)
      {
         super(windowAssetPath);
         this.name = POPUP_NAME;
         this.m_featureName = featureName;
         this.m_message = message;
         this.m_title = title;
         this.m_bgPath = bgPath;
         this.m_clickCallback = clickCallback;
         this.m_animatedClipFrame = animationFrame;
         m_timeToLive = DEFAULT_TIME_TO_LIVE;
         if(toasterTime)
         {
            m_timeToLive = toasterTime;
         }
      }
      
      override protected function postLoadComplete() : void
      {
         var bg_mc:FarmIcon = null;
         if(null != m_window.title_tf && "" != this.m_title)
         {
            addWidget(new ZwTextField(m_window.title_tf,this.m_title));
         }
         addWidget(new ZwTextField(m_window.message_tf,this.m_message));
         if(m_window.hitbox_mc)
         {
            addWidget(new ZwButton(m_window.hitbox_mc,this.onHitBoxClick));
         }
         else if(m_window.accept_bt)
         {
            addWidget(new FarmAnimatedTextButton(m_window.accept_bt,ZLocUtils.t("Dialogs","simpleToasterButton_" + this.m_featureName),this.onHitBoxClick));
         }
         if(null != m_window.background_mc && "" != this.m_bgPath)
         {
            bg_mc = new FarmIcon(m_window.background_mc,this.m_bgPath);
            addWidget(bg_mc);
         }
         if(m_window.animated_mc != null)
         {
            addWidget(new ZwBaseWidget(m_window.animated_mc));
            this.m_animatedClip = m_window.animated_mc;
         }
         FarmStatsManager.count(this.m_featureName,"toaster","impressions");
      }
      
      protected function onHitBoxClick(event:MouseEvent) : void
      {
         if(event)
         {
            event.stopPropagation();
         }
         if(this.m_clickCallback != null)
         {
            this.m_clickCallback();
         }
         FarmStatsManager.count(this.m_featureName,"toaster","clicks");
         close();
      }
      
      override public function show() : void
      {
         super.show();
         if(this.m_animatedClip != null)
         {
            this.m_animatedClip.gotoAndPlay(this.m_animatedClipFrame);
         }
      }
   }
}

