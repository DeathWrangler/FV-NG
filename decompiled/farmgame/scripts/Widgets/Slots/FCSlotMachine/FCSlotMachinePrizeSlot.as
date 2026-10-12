package Widgets.Slots.FCSlotMachine
{
   import Classes.ZItem.FarmItem;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FCSlotMachineWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class FCSlotMachinePrizeSlot extends ZwSlotFrame
   {
      
      private var m_parentWindow:FCSlotMachineWindow;
      
      private var m_itemNameText:ZwTextField;
      
      private var m_item:FarmItem;
      
      public function FCSlotMachinePrizeSlot(element:DisplayObject, parentWindow:FCSlotMachineWindow)
      {
         super(element);
         this.m_parentWindow = parentWindow;
      }
      
      override public function populate(data:Object) : void
      {
         this.m_item = Global.farmGameSettingsManager.getFarmItemByName(data.value);
         this.m_itemNameText = addWidget(new ZwTextField(m_element.greenText_tf,this.m_item.friendlyTitle),true) as ZwTextField;
         addWidget(new ZwFrame(m_element.darkBackground_mc),true);
         var m_icon:FarmIcon = addWidget(new FarmIcon(m_element.icon_mc),true) as FarmIcon;
         m_icon.setIconSize(50,50);
         m_icon.loadIcon(this.m_item.icon);
         var mcElement:MovieClip = m_element as MovieClip;
         mcElement.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         mcElement.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
      }
      
      private function onMouseOver(e:Event) : void
      {
         this.m_parentWindow.showPrizeDetails(this.m_item);
      }
      
      private function onMouseOut(e:Event) : void
      {
         this.m_parentWindow.hideItemDetails();
      }
      
      override public function release() : void
      {
         var mcElement:MovieClip = m_element as MovieClip;
         mcElement.removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         mcElement.removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         super.release();
      }
   }
}

