package Widgets.Windows.Promotions
{
   import Classes.NPCConfigData;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.AutoCloseToasterWindow;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class PromoToasterWindow extends AutoCloseToasterWindow
   {
      
      protected static const DEFAULT_TIME_TO_LIVE:Number = 10000;
      
      protected var m_promoData:NPCConfigData;
      
      protected var m_activeCallback:Function = null;
      
      public function PromoToasterWindow(assetPath:String, promoData:NPCConfigData, activateCallback:Function = null)
      {
         super(assetPath);
         this.m_promoData = promoData;
         this.m_activeCallback = activateCallback;
         this.duration = DEFAULT_TIME_TO_LIVE;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty("background_mc") && Boolean(m_window.background_mc))
         {
            addWidget(new ZwFrame(m_window.background_mc));
         }
         if(m_window.hasOwnProperty("title_tf") && Boolean(m_window.title_tf))
         {
            addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","PromoFarmToaster_" + this.m_promoData.name + "_title"),true));
         }
         if(m_window.hasOwnProperty("message_tf") && Boolean(m_window.message_tf))
         {
            addWidget(new ZwTextField(m_window.message_tf,ZLocUtils.t("Dialogs","PromoFarmToaster_" + this.m_promoData.name + "_body"),true));
         }
         if(m_window.hasOwnProperty("message_tf2") && Boolean(m_window.message_tf2))
         {
            addWidget(new ZwTextField(m_window.message2_tf,ZLocUtils.t("Dialogs","PromoFarmToaster_" + this.m_promoData.name + "_footer"),true));
         }
         if(m_window.hasOwnProperty("generic_0_tf") && Boolean(m_window.generic_0_tf))
         {
            addWidget(new ZwTextField(m_window.generic_0_tf,ZLocUtils.t("Dialogs","PromoFarmToaster_" + this.m_promoData.name + "_body"),true));
         }
         if(m_window.hasOwnProperty("generic_1_tf") && Boolean(m_window.generic_1_tf))
         {
            addWidget(new ZwTextField(m_window.generic_1_tf,ZLocUtils.t("Dialogs","PromoFarmToaster_" + this.m_promoData.name + "_footer"),true));
         }
         if(m_window.hasOwnProperty("more_bt") && Boolean(m_window.more_bt))
         {
            addWidget(new FarmAnimatedTextButton(m_window.more_bt,ZLocUtils.t("Dialogs","PromoFarmToaster_" + this.m_promoData.name + "_button"),this.onActivate));
         }
         m_window.addEventListener(MouseEvent.CLICK,this.onActivate);
         if(Boolean(this.m_promoData) && Boolean(this.m_promoData.stat))
         {
            FarmStatsManager.count(this.m_promoData.stat,"welcome_toaster","impression");
         }
      }
      
      protected function onActivate(event:MouseEvent) : void
      {
         m_window.removeEventListener(MouseEvent.CLICK,this.onActivate);
         if(event)
         {
            event.stopPropagation();
         }
         if(this.m_activeCallback != null)
         {
            this.m_activeCallback(this.m_promoData);
         }
         if(Boolean(this.m_promoData) && Boolean(this.m_promoData.stat))
         {
            FarmStatsManager.count(this.m_promoData.stat,"welcome_toaster","click");
         }
         close();
      }
      
      override protected function onClose(event:Event) : void
      {
         super.onClose(event);
         if(Boolean(this.m_promoData) && Boolean(this.m_promoData.stat))
         {
            FarmStatsManager.count(this.m_promoData.stat,"welcome_toaster","clickclose");
         }
      }
   }
}

