package Widgets.Windows.LESet
{
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.GenericSlotContainerFrame;
   import Widgets.Slots.LESet.LERecommendationSurfacingSlot;
   import Widgets.Windows.ToasterWindow;
   import flash.events.Event;
   
   public class LERecommendationToasterWindow extends ToasterWindow
   {
      
      private var m_leSet:Array;
      
      private var m_frame:GenericSlotContainerFrame;
      
      public function LERecommendationToasterWindow()
      {
         super("assets/dialogs/FV_HUDSurfacing_recommend.swf");
         this.name = "LERecommendationToasterWindow";
         this.m_leSet = Global.marketRecommendations.getRecommendedItems();
         this.m_showTweenTime = 0;
         this.m_hideTweenTime = 0;
      }
      
      override protected function postLoadComplete() : void
      {
         this.m_frame = new GenericSlotContainerFrame(m_window.slotFrame_mc,LERecommendationSurfacingSlot,this.m_leSet,this);
         addWidget(this.m_frame);
         addWidget(new ZwTextField(m_window.slotFrame_mc.header_tf,ZLocUtils.t("Dialogs","LERecommendationWindowTitle")));
         FarmStatsManager.count("recs_neighbor_bar","impressions",this.pageNumber.toString());
      }
      
      public function get pageNumber() : uint
      {
         return this.m_frame.pageNumber;
      }
      
      override protected function onClose(event:Event) : void
      {
         FarmStatsManager.count("recs_neighbor_bar","close");
         super.onClose(event);
      }
      
      override protected function setToasterDepth() : void
      {
         Global.ui.swapToasterDepth(this);
      }
      
      override protected function release() : void
      {
         this.m_leSet = null;
         this.m_frame = null;
         super.release();
      }
   }
}

