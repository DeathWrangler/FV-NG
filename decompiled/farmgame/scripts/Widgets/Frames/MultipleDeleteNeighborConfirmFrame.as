package Widgets.Frames
{
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class MultipleDeleteNeighborConfirmFrame extends FarmSlotContainerFrame
   {
      
      private var m_acceptCallback:Function;
      
      private var m_closeCallback:Function;
      
      private var m_confirm:FarmAnimatedButton = null;
      
      private var m_cancel:FarmAnimatedButton = null;
      
      public function MultipleDeleteNeighborConfirmFrame(element:DisplayObject, acceptCallback:Function, closeCallback:Function)
      {
         super(element);
         this.m_acceptCallback = acceptCallback;
         this.m_closeCallback = closeCallback;
         if(m_element.generic_tf)
         {
            addWidget(new ZwTextField(m_element.generic_tf,ZLocUtils.t("Dialogs","MFSWindow_RemoveNeighbor"))) as ZwTextField;
         }
         if(m_element.generic2_tf)
         {
            addWidget(new ZwTextField(m_element.generic2_tf,ZLocUtils.t("Dialogs","MFSWindow_RemoveNeighbor2"))) as ZwTextField;
         }
         this.m_confirm = addWidget(new FarmAnimatedTextButton(m_element.confirm_bt,"Yes",this.onAccept)) as FarmAnimatedButton;
         this.m_cancel = addWidget(new FarmAnimatedTextButton(m_element.cancel_bt,"Cancel",this.onCancel)) as FarmAnimatedButton;
      }
      
      public function onAccept(evt:Event) : void
      {
         if(this.m_acceptCallback != null)
         {
            this.m_acceptCallback();
         }
      }
      
      private function onCancel(evt:Event) : void
      {
         if(this.m_closeCallback != null)
         {
            this.m_closeCallback();
         }
      }
      
      override public function release() : void
      {
         this.m_acceptCallback = null;
         this.m_closeCallback = null;
         this.m_confirm = null;
         this.m_cancel = null;
         super.release();
      }
   }
}

