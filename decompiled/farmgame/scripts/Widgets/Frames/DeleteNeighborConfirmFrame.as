package Widgets.Frames
{
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Slots.DeleteNeighborConfirmSlot;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class DeleteNeighborConfirmFrame extends FarmSlotContainerFrame
   {
      
      private var m_acceptCallback:Function;
      
      private var m_closeCallback:Function;
      
      private var m_confirm:FarmAnimatedButton = null;
      
      private var m_cancel:FarmAnimatedButton = null;
      
      public function DeleteNeighborConfirmFrame(element:DisplayObject, acceptCallback:Function, closeCallback:Function)
      {
         super(element);
         this.m_acceptCallback = acceptCallback;
         this.m_closeCallback = closeCallback;
         if(m_element.generic_tf)
         {
            addWidget(new ZwTextField(m_element.generic_tf,ZLocUtils.t("Dialogs","MFSWindow_RemoveNeighbor1"))) as ZwTextField;
         }
         if(m_element.generic2_tf)
         {
            addWidget(new ZwTextField(m_element.generic2_tf,ZLocUtils.t("Dialogs","MFSWindow_RemoveNeighbor2"))) as ZwTextField;
         }
         this.m_confirm = addWidget(new FarmAnimatedTextButton(m_element.confirm_bt,"Accept",this.onAccept)) as FarmAnimatedButton;
         this.m_cancel = addWidget(new FarmAnimatedTextButton(m_element.cancel_bt,"Cancel",this.onCancel)) as FarmAnimatedButton;
      }
      
      public function onAccept(evt:Event) : void
      {
         if(this.m_acceptCallback != null)
         {
            this.m_acceptCallback((m_slots[0] as DeleteNeighborConfirmSlot).data);
         }
      }
      
      private function onCancel(evt:Event) : void
      {
         if(this.m_closeCallback != null)
         {
            this.m_closeCallback();
         }
      }
      
      public function set items(items:Array) : void
      {
         m_slotData = items;
         refresh();
      }
      
      override public function release() : void
      {
         this.m_acceptCallback = null;
         this.m_closeCallback = null;
         this.m_confirm = null;
         this.m_cancel = null;
         super.release();
      }
      
      override protected function setupData() : void
      {
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new DeleteNeighborConfirmSlot(slotElement,this.m_acceptCallback);
      }
   }
}

