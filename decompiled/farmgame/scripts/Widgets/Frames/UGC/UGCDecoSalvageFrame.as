package Widgets.Frames.UGC
{
   import Classes.util.ZLocUtils;
   import Managers.UGCDecoManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.UGC.UGCDecoSalvageSlots;
   import flash.display.DisplayObject;
   
   public class UGCDecoSalvageFrame extends FarmSlotContainerFrame
   {
      
      private const SLOT_PREFIX:String = "giftPanel";
      
      private var m_backButton:ZwBaseWidget;
      
      private var m_buyButton:ZwBaseWidget;
      
      public function UGCDecoSalvageFrame(element:DisplayObject, exitRecycleCallback:Function)
      {
         super(element);
         addWidget(new ZwTextField(m_element.header_tf,ZLocUtils.t("Dialogs","UGCDecoWindow_recycle_header")));
         this.m_backButton = addWidget(new ZwButton(m_element.close_bt,exitRecycleCallback));
         addWidget(new ZwTextField(m_element.generic_tf,ZLocUtils.t("Dialogs","UGCDecoWindow_recycle_description")));
         this.m_buyButton = addWidget(new FarmAnimatedTextButton(m_element.buy_bt,ZLocUtils.t("Dialogs","UGCDecoWindow_recycle_backbtn"),exitRecycleCallback));
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new UGCDecoSalvageSlots(slotElement,true);
      }
      
      override protected function getSlotPrefix() : String
      {
         return this.SLOT_PREFIX;
      }
      
      override protected function getSlotPostfix() : String
      {
         return "";
      }
      
      override protected function setupData() : void
      {
         m_slotData = UGCDecoManager.instance.getRecyclableMaterials();
      }
      
      public function setInputEnabled(enabled:Boolean) : void
      {
         this.m_backButton.enabled = enabled;
         this.m_buyButton.enabled = enabled;
      }
   }
}

