package Widgets.Windows.LESet
{
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.LESurfacingManager;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.LESet.LESurfacingSlotFrame;
   import Widgets.Windows.ToasterWindow;
   import flash.events.Event;
   
   public class LESurfacingToasterWindow extends ToasterWindow
   {
      
      private var m_leSet:Array;
      
      private var m_frame:LESurfacingSlotFrame;
      
      public function LESurfacingToasterWindow(leSet:Array)
      {
         super("assets/dialogs/FV_LESurfacing_neighbor.swf");
         this.name = "LESurfacingToasterWindow";
         this.m_leSet = leSet;
         this.m_showTweenTime = 0;
         this.m_hideTweenTime = 0;
      }
      
      override protected function postLoadComplete() : void
      {
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","LESurfacingWindowTitle")));
         this.m_frame = new LESurfacingSlotFrame(m_window.slotFrame_mc,this.m_leSet,this);
         addWidget(this.m_frame);
         FarmStatsManager.count("le_display_promo","toaster","le_display_" + this.pageNumber,"view");
      }
      
      public function get pageNumber() : uint
      {
         return this.m_frame.pageNumber;
      }
      
      override protected function onClose(event:Event) : void
      {
         FarmStatsManager.count("le_display_promo","toaster","le_display_" + this.pageNumber,"click_cancel");
         super.onClose(event);
         Global.player.setFeatureLastShown(LESurfacingManager.LE_SURFACING_DISMISS_FLAG,GlobalEngine.serverTime,true);
      }
      
      override protected function setToasterDepth() : void
      {
         Global.ui.swapToasterDepth(this);
      }
      
      override public function close() : void
      {
         super.close();
      }
   }
}

