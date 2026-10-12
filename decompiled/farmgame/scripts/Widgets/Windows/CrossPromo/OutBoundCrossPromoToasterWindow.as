package Widgets.Windows.CrossPromo
{
   import Managers.CrossPromoManager;
   import Managers.FarmStatsManager;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.AutoCloseToasterWindow;
   import flash.events.MouseEvent;
   
   public class OutBoundCrossPromoToasterWindow extends AutoCloseToasterWindow
   {
      
      protected static const POPUP_NAME:String = "OutBoundCrossPromoToasterWindow";
      
      protected static const DEFAULT_TIME_TO_LIVE:Number = 20000;
      
      protected var m_promoId:String;
      
      protected var m_message:String;
      
      protected var m_title:String;
      
      protected var m_bgPath:String;
      
      public function OutBoundCrossPromoToasterWindow(promoId:String, message:String, windowAssetPath:String, title:String = "", bgPath:String = "")
      {
         super(windowAssetPath);
         this.name = POPUP_NAME;
         this.m_promoId = promoId;
         this.m_message = message;
         this.m_title = title;
         this.m_bgPath = bgPath;
         m_timeToLive = DEFAULT_TIME_TO_LIVE;
      }
      
      override protected function postLoadComplete() : void
      {
         var bg_mc:FarmIcon = null;
         if(null != m_window.title_tf && "" != this.m_title)
         {
            addWidget(new ZwTextField(m_window.title_tf,this.m_title));
         }
         addWidget(new ZwTextField(m_window.message_tf,this.m_message));
         addWidget(new ZwButton(m_window.hitbox_mc,this.onHitBoxClick));
         if(null != m_window.background_mc && "" != this.m_bgPath)
         {
            bg_mc = new FarmIcon(m_window.background_mc,this.m_bgPath);
            addWidget(bg_mc);
         }
         FarmStatsManager.count(this.m_promoId,"toaster","impressions");
      }
      
      protected function onHitBoxClick(event:MouseEvent) : void
      {
         if(event)
         {
            event.stopPropagation();
         }
         CrossPromoManager.getInstance().toasterClickCallback(this.m_promoId);
         FarmStatsManager.count(this.m_promoId,"toaster","clicks");
         close();
      }
   }
}

