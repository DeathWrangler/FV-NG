package Widgets.Windows
{
   import Classes.util.ZLocUtils;
   import Managers.AntiqueMuseumV2Manager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Frames.ConsumableToasterFrame;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class ConsumableToasterWindow extends AutoCloseToasterWindow
   {
      
      protected static const POPUP_NAME:String = "Simple Toaster";
      
      public static const FEATURE_NAME:String = "AntiqueMuseumV2";
      
      protected static const DEFAULT_TIME_TO_LIVE:Number = 20000;
      
      protected static const DEFAULT_ANIMATION_FRAME:int = 2;
      
      protected var m_featureName:String;
      
      protected var m_message:String;
      
      protected var m_title:String;
      
      protected var m_bgPath:String;
      
      protected var m_clickCallback:Function = null;
      
      protected var m_animatedClip:MovieClip = null;
      
      protected var m_animatedClipFrame:int;
      
      private var m_consumablesMC:MovieClip;
      
      public var m_consumablesFrame:ConsumableToasterFrame;
      
      public var m_consumable1_mc:MovieClip;
      
      public var m_consumable2_mc:MovieClip;
      
      public var m_consumable3_mc:MovieClip;
      
      public function ConsumableToasterWindow(featureName:String, message:String, windowAssetPath:String, clickCallback:Function = null, toasterTime:Number = 0, title:String = "", bgPath:String = "", animationFrame:int = 2)
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
         var activePieces:Array = null;
         var bg_mc:FarmIcon = null;
         var featureData:Object = this.manager.getFeatureData();
         if(featureData)
         {
            activePieces = featureData["saved_active_pieces"];
         }
         if(m_window.hasOwnProperty("consumables"))
         {
            this.m_consumablesFrame = new ConsumableToasterFrame(m_window["consumables"],this,FEATURE_NAME);
            this.m_consumablesFrame.setData();
            this.m_consumablesFrame.visible = true;
         }
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
      
      private function get manager() : AntiqueMuseumV2Manager
      {
         return AntiqueMuseumV2Manager.getInstance();
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

