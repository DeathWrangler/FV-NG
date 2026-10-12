package Widgets.Windows
{
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.Event;
   
   public class PackPurchasedToaster extends AutoCloseToasterWindow
   {
      
      private static const ASSET_PATH:String = "assets/dialogs/FV_startertoaster.swf";
      
      private static const STATS_COUNTER:String = "dialog";
      
      private static const STATS_KINGDOM:String = "starterpack_toaster_thankyou";
      
      private static const STATS_PHYLUM_VIEW:String = "view";
      
      private static const STATS_PHYLUM_CLICK:String = "x-button";
      
      public function PackPurchasedToaster()
      {
         super(ASSET_PATH);
      }
      
      override protected function postLoadComplete() : void
      {
         var toasterFrame:ZwFrame = null;
         super.postLoadComplete();
         if(Boolean(m_window) && Boolean(m_window.purchasedToaster_mc))
         {
            m_window.purchasedToaster_mc.visible = true;
            toasterFrame = new ZwFrame(m_window.purchasedToaster_mc);
            toasterFrame.addWidget(new ZwTextField(m_window.purchasedToaster_mc.generic_4_tf,ZLocUtils.t("Dialogs","StarterPack_Toaster_Heading")));
            toasterFrame.addWidget(new ZwTextField(m_window.purchasedToaster_mc.toastertitle_tf,ZLocUtils.t("Dialogs","StarterPack_Toaster_Description")));
            toasterFrame.addWidget(new ZwButton(m_window.purchasedToaster_mc.toasterclose_bt,this.onClickClose));
         }
      }
      
      override protected function postShow() : void
      {
         FarmStatsManager.count(STATS_COUNTER,STATS_KINGDOM,STATS_PHYLUM_VIEW);
      }
      
      protected function onClickClose(event:Event) : void
      {
         FarmStatsManager.count(STATS_COUNTER,STATS_KINGDOM,STATS_PHYLUM_CLICK);
         super.onClose(event);
      }
   }
}

