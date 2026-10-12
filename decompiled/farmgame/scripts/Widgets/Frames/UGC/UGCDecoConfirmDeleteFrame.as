package Widgets.Frames.UGC
{
   import Classes.MapResource;
   import Classes.util.ZLocUtils;
   import Managers.UGCDecoManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.UGC.UGCDecoSalvageSlots;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class UGCDecoConfirmDeleteFrame extends FarmSlotContainerFrame
   {
      
      private const SLOT_PREFIX:String = "giftPanel";
      
      private var m_closeCallback:Function = null;
      
      private var m_recycleObject:MapResource;
      
      public function UGCDecoConfirmDeleteFrame(element:DisplayObject)
      {
         super(element);
         addWidget(new ZwTextField(m_element.title_tf,""));
         addWidget(new FarmAnimatedTextButton(m_element.accept_bt,ZLocUtils.t("Dialogs","UGCDecoWindow_recycle_confirm_accept"),this.onAcceptDelete));
         addWidget(new FarmAnimatedTextButton(m_element.cancel_bt,ZLocUtils.t("Dialogs","UGCDecoWindow_recycle_confirm_cancel"),this.onCancelDelete));
      }
      
      public function reloadData(object:MapResource, materials:Array, func:Function) : void
      {
         this.m_closeCallback = func;
         m_slotData = materials;
         this.m_recycleObject = object;
         m_element.title_tf.text = ZLocUtils.t("Dialogs","UGCDecoWindow_recycle_confirm_title",{"itemname":ZLocUtils.tk_pk_asTitle(object.getItemFriendlyName())});
         refresh();
      }
      
      private function onAcceptDelete(event:Event) : void
      {
         if(this.m_closeCallback != null)
         {
            this.m_closeCallback(true);
         }
      }
      
      private function onCancelDelete(event:Event) : void
      {
         if(this.m_closeCallback != null)
         {
            this.m_closeCallback(false);
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new UGCDecoSalvageSlots(slotElement,false);
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
      
      override public function release() : void
      {
         super.release();
         this.m_closeCallback = null;
         this.m_recycleObject = null;
      }
   }
}

