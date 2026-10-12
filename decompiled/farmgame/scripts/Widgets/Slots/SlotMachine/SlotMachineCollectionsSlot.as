package Widgets.Slots.SlotMachine
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   
   public class SlotMachineCollectionsSlot extends ZwSlotFrame
   {
      
      private static const ICON_SIZE:Number = 50;
      
      private var m_item:FarmItem = null;
      
      private var m_data:Object = null;
      
      private var m_icon:FarmIcon;
      
      private var m_name:ZwTextField;
      
      private var m_check:ZwFrame;
      
      private var m_unfound:ZwFrame;
      
      private var m_found:ZwFrame;
      
      public function SlotMachineCollectionsSlot(element:DisplayObject)
      {
         super(element);
         this.m_icon = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
         this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
         this.m_name = addWidget(new ZwTextField(m_element.generic_tf)) as ZwTextField;
         this.m_check = addWidget(new ZwFrame(m_element.check_mc)) as ZwFrame;
         this.m_unfound = addWidget(new ZwFrame(m_element.unFound_mc)) as ZwFrame;
         this.m_found = addWidget(new ZwFrame(m_element.found_mc)) as ZwFrame;
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.refresh(data);
      }
      
      public function refresh(data:Object) : void
      {
         var collectionCount:Number = NaN;
         this.m_data = data;
         if(Boolean(this.m_data) && this.m_data.item is FarmItem)
         {
            this.m_item = this.m_data.item as FarmItem;
            this.m_icon.loadIcon(this.m_item.icon);
            this.m_icon.visible = true;
            this.m_name.text = ZLocUtils.tk_pk_asTitle(this.m_item.friendlyName);
            this.m_name.visible = true;
            collectionCount = Number(Global.player.collectionCounters[this.m_item.code]);
            this.m_found.visible = this.m_check.visible = collectionCount > 0;
            this.m_unfound.visible = !this.m_found.visible;
         }
      }
      
      override public function release() : void
      {
         super.release();
         this.m_item = null;
         this.m_data = null;
         this.m_icon = null;
         this.m_name = null;
         this.m_check = null;
         this.m_unfound = null;
         this.m_found = null;
      }
   }
}

