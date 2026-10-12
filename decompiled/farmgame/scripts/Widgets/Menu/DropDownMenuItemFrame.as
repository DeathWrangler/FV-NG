package Widgets.Menu
{
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class DropDownMenuItemFrame extends ZwSlotFrame
   {
      
      private var m_data:MenuItem;
      
      private var m_button:DropDownMenuItemButton;
      
      private var m_topFrame:ZwFrame;
      
      private var m_topCap:ZwWidget;
      
      private var m_topSpacer:ZwWidget;
      
      private var m_bottomFrame:ZwFrame;
      
      private var m_bottomCap:ZwWidget;
      
      private var m_bottomSpacer:ZwWidget;
      
      private var m_selectedCallback:Function;
      
      public function DropDownMenuItemFrame(element:DisplayObject, selectedCallback:Function)
      {
         this.m_selectedCallback = selectedCallback;
         super(element);
         this.m_button = addWidget(new DropDownMenuItemButton(m_element.generic_bt," ",this.onSelected)) as DropDownMenuItemButton;
         this.m_topFrame = addWidget(new ZwFrame(m_element.top_mc)) as ZwFrame;
         this.m_topCap = this.m_topFrame.addWidget(new ZwWidget(m_element.top_mc.endcap_mc),false) as ZwWidget;
         this.m_topSpacer = this.m_topFrame.addWidget(new ZwWidget(m_element.top_mc.spacer_mc),false) as ZwWidget;
         this.m_bottomFrame = addWidget(new ZwFrame(m_element.bottom_mc)) as ZwFrame;
         this.m_bottomCap = this.m_bottomFrame.addWidget(new ZwWidget(m_element.bottom_mc.endcap_mc),false) as ZwWidget;
         this.m_bottomSpacer = this.m_bottomFrame.addWidget(new ZwWidget(m_element.bottom_mc.spacer_mc),false) as ZwWidget;
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_data = data as MenuItem;
         if(this.m_data)
         {
            this.m_button.text = this.m_data.text;
            this.m_button.visible = true;
            if(m_element.burstNew_mc)
            {
               m_element.burstNew_mc.visible = this.m_data.featured;
            }
         }
      }
      
      private function onSelected(evt:MouseEvent) : void
      {
         if(this.m_selectedCallback != null)
         {
            this.m_selectedCallback(this.m_data);
         }
      }
      
      public function set isFirst(newIsFirst:Boolean) : void
      {
         this.m_topFrame.visible = true;
         this.m_topCap.visible = newIsFirst;
         this.m_topSpacer.visible = !newIsFirst;
      }
      
      public function set isLast(newIsLast:Boolean) : void
      {
         this.m_bottomFrame.visible = true;
         this.m_bottomCap.visible = newIsLast;
         this.m_bottomSpacer.visible = !newIsLast;
      }
      
      override public function release() : void
      {
         this.m_data = null;
         this.m_button = null;
         this.m_topFrame = null;
         this.m_topCap = null;
         this.m_topSpacer = null;
         this.m_bottomFrame = null;
         this.m_bottomCap = null;
         this.m_bottomSpacer = null;
         this.m_selectedCallback = null;
         super.release();
      }
   }
}

