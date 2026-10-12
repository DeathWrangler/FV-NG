package Widgets.Windows.CompletionPack
{
   import Classes.util.ZLocUtils;
   import Managers.BuildableCompletionPackagesManager;
   import Managers.FarmStatsManager;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.GenericSlotContainerFrame;
   import Widgets.Slots.CompletionPack.BuildableCompletionPackOptionSlot;
   import Widgets.Windows.FarmWindow;
   
   public class BuildableCompletionPackWindow extends FarmWindow
   {
      
      private static const XAU_COMPLETION_PACK_WINDOW_ASSET:String = "assets/dialogs/xau_completionPack.swf";
      
      private static const COMPLETION_PACK_WINDOW_ASSET:String = "assets/dialogs/Candy/FV_xcw_CompleteExpansionPack.swf";
      
      private var m_optionInfo:Array = new Array();
      
      private var m_slots:GenericSlotContainerFrame = null;
      
      public function BuildableCompletionPackWindow(optionsInfo:Array)
      {
         this.m_optionInfo = optionsInfo;
         FarmStatsManager.count("Dialog","impressions",BuildableCompletionPackagesManager.MAIN_WINDOW_STAT);
         super(COMPLETION_PACK_WINDOW_ASSET);
      }
      
      override protected function postLoadComplete() : void
      {
         if(m_window)
         {
            if(m_window.hasOwnProperty("header_tf"))
            {
               addWidget(new ZwTextField(m_window.header_tf,ZLocUtils.t("Dialogs","completion_pack_window_title")));
            }
            if(m_window.hasOwnProperty("subHeader_mc"))
            {
               addWidget(new ZwTextField(m_window.subHeader_mc,ZLocUtils.t("Dialogs","completion_pack_window_subTitle")));
            }
            if(m_window.hasOwnProperty("slots_mc"))
            {
               this.m_slots = addWidget(new GenericSlotContainerFrame(m_window.slots_mc,BuildableCompletionPackOptionSlot,this.m_optionInfo,this)) as GenericSlotContainerFrame;
            }
         }
         super.postLoadComplete();
      }
   }
}

