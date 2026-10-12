package Widgets.Slots.LimitedGifting
{
   import Classes.ZItem.FarmItem;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   
   public class LimitedGiftingRecipientItemSlot extends ZwSlotFrame
   {
      
      private const ICON_SIZE:Number = 100;
      
      private var m_icon:FarmIcon;
      
      private var m_itemName:String;
      
      private var m_counter:ZwTextField;
      
      public function LimitedGiftingRecipientItemSlot(element:DisplayObject)
      {
         super(element);
         if(m_element.hasOwnProperty("icon_mc"))
         {
            this.m_icon = new FarmIcon(m_element.icon_mc);
            this.m_icon.setIconSize(this.ICON_SIZE,this.ICON_SIZE);
            addWidget(this.m_icon);
         }
      }
      
      override public function populate(data:Object) : void
      {
         var item:FarmItem = data[0];
         super.populate(item);
         if(this.m_icon)
         {
            this.m_icon.visible = true;
            this.m_icon.loadIcon(item.icon);
         }
         this.m_itemName = item.name;
         this.m_counter = new ZwTextField(m_element.counter_tf,data[1].toString());
         addWidget(this.m_counter);
      }
      
      public function get itemName() : String
      {
         return this.m_itemName;
      }
      
      override public function release() : void
      {
         this.m_counter = null;
         this.m_icon = null;
         super.release();
      }
   }
}

