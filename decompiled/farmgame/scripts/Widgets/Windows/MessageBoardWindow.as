package Widgets.Windows
{
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.MessageBoardManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Frames.MessageBoardFrame;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class MessageBoardWindow extends ToasterWindow
   {
      
      protected static const POPUP_NAME:String = "Simple Toaster";
      
      public static const FEATURE_NAME:String = "AntiqueMuseum";
      
      protected static const DEFAULT_TIME_TO_LIVE:Number = 200000;
      
      protected static const DEFAULT_ANIMATION_FRAME:int = 2;
      
      protected var m_featureName:String;
      
      protected var m_message:String;
      
      protected var m_title:String;
      
      protected var m_bgPath:String;
      
      protected var m_clickCallback:Function = null;
      
      protected var m_animatedClip:MovieClip = null;
      
      protected var m_animatedClipFrame:int;
      
      private var m_consumablesMC:MovieClip;
      
      public var m_msgFrame:MessageBoardFrame;
      
      public var m_consumable1_mc:MovieClip;
      
      public var m_consumable2_mc:MovieClip;
      
      public var m_consumable3_mc:MovieClip;
      
      public function MessageBoardWindow(featureName:String, message:String, windowAssetPath:String, toasterTime:Number = 0, title:String = "", bgPath:String = "", animationFrame:int = 2)
      {
         super(windowAssetPath);
         this.name = POPUP_NAME;
         this.m_featureName = featureName;
         this.m_message = message;
         this.m_title = title;
         this.m_bgPath = bgPath;
         this.m_animatedClipFrame = animationFrame;
      }
      
      override protected function postLoadComplete() : void
      {
         var bg_mc:FarmIcon = null;
         if(m_window.hasOwnProperty("message_board_mc"))
         {
            this.m_msgFrame = new MessageBoardFrame(m_window["message_board_mc"],this,FEATURE_NAME);
            this.m_msgFrame.visible = true;
         }
         if(m_window.hasOwnProperty("close_bt"))
         {
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
         FarmStatsManager.count(this.m_featureName,"toaster","clicks");
         close();
      }
      
      private function get manager() : MessageBoardManager
      {
         return MessageBoardManager.getInstance(this.m_featureName);
      }
      
      override public function get isPauseable() : Boolean
      {
         return false;
      }
      
      override public function show() : void
      {
         super.show();
      }
   }
}

