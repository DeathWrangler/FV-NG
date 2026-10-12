package Widgets.Slots.Market
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Market.MarketMiniSlotFrame;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   
   public class MarketMiniSlot extends ZwSlotFrame
   {
      
      private static const ICON_SIZE:int = 50;
      
      private var m_callbacks:Object;
      
      private var m_container:MarketMiniSlotFrame;
      
      private var m_data:FarmItem;
      
      private var m_icon:FarmIcon;
      
      private var m_nameTextField:ZwTextField;
      
      private var m_moreTextField:ZwTextField;
      
      public function MarketMiniSlot(element:DisplayObject, container:MarketMiniSlotFrame, callbacks:Object)
      {
         this.m_container = container;
         this.m_callbacks = callbacks;
         super(element);
         this.m_icon = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
         this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
         this.m_nameTextField = addWidget(new ZwTextField(m_element.title_tf)) as ZwTextField;
         this.m_moreTextField = addWidget(new ZwTextField(m_element.linkTitle_tf,ZLocUtils.t("Dialogs","MoreInfo"))) as ZwTextField;
      }
      
      public function get data() : FarmItem
      {
         return this.m_data;
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_data = data as FarmItem;
         if(this.m_data)
         {
            this.m_icon.loadIcon(this.m_data.iconUrl);
            this.m_icon.visible = true;
            this.m_nameTextField.text = this.m_data.friendlyTitle;
            this.m_nameTextField.visible = true;
            this.m_moreTextField.visible = true;
         }
      }
      
      override public function release() : void
      {
         this.m_callbacks = null;
         this.m_container = null;
         this.m_data = null;
         this.m_icon = null;
         this.m_nameTextField = null;
         this.m_moreTextField = null;
         super.release();
      }
   }
}

