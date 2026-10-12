package Widgets.Slots
{
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class FarmVillageOrderBoardSlot extends ZwSlotFrame
   {
      
      private var m_complete:ZwWidget;
      
      private var m_icon:FarmIcon;
      
      private var m_ready:ZwWidget;
      
      private var m_toolTipSlot:FarmVillageToolTipSlot;
      
      private var m_order:Object;
      
      public function FarmVillageOrderBoardSlot(element:MovieClip, parentWindow:FarmWindow)
      {
         super(element);
         m_element.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         m_element.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         if(m_element["complete_mc"])
         {
            this.m_complete = new ZwWidget(m_element.complete_mc);
            addWidget(this.m_complete,false);
         }
         if(m_element["ready_mc"])
         {
            this.m_ready = new ZwWidget(m_element.ready_mc);
            addWidget(this.m_ready,false);
         }
         if(m_element["tooltip_mc"])
         {
            this.m_toolTipSlot = new FarmVillageToolTipSlot(m_element.tooltip_mc,parentWindow);
            addWidget(this.m_toolTipSlot,false);
         }
         if(m_element["icon_mc"])
         {
            this.m_icon = new FarmIcon(m_element.icon_mc);
            addWidget(this.m_icon);
         }
      }
      
      private function update() : void
      {
         if(this.m_toolTipSlot)
         {
            this.m_toolTipSlot.update();
         }
         if(this.m_ready)
         {
            this.m_ready.visible = this.m_toolTipSlot.areRequirementsFulfilled();
         }
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_order = data;
         this.m_icon.loadIcon(this.m_order["npc"]);
         this.m_icon.visible = true;
         this.m_toolTipSlot.setOrderData(data);
         this.update();
      }
      
      override public function release() : void
      {
         this.m_complete = null;
         this.m_icon = null;
         this.m_ready = null;
         this.m_toolTipSlot = null;
         this.m_order = null;
         m_element.removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         m_element.removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         super.release();
      }
      
      private function onMouseOver(event:MouseEvent) : void
      {
         this.update();
         if(this.m_toolTipSlot)
         {
            this.m_toolTipSlot.visible = true;
         }
      }
      
      private function onMouseOut(event:MouseEvent) : void
      {
         if(this.m_toolTipSlot)
         {
            this.m_toolTipSlot.visible = false;
         }
      }
   }
}

