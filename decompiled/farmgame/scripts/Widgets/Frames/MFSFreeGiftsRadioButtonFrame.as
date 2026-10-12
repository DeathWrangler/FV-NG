package Widgets.Frames
{
   import Classes.ZItem.FarmItem;
   import Widgets.Buttons.FarmRadioButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   
   public class MFSFreeGiftsRadioButtonFrame extends ZwFrame
   {
      
      private var m_item:FarmItem = null;
      
      private var m_highlight:ZwWidget = null;
      
      private var m_radioButton:FarmRadioButton = null;
      
      private var m_selectCallback:Function = null;
      
      public function MFSFreeGiftsRadioButtonFrame(element:DisplayObject, item:FarmItem, onSelectCallback:Function = null)
      {
         var icon:FarmIcon = null;
         super(element);
         this.m_item = item;
         this.m_selectCallback = onSelectCallback;
         this.m_radioButton = new FarmRadioButton(this.element.mc_radio_container as DisplayObject,this.onRadioSelect,this.onRadioDeselect);
         addWidget(this.m_radioButton);
         this.m_highlight = new ZwWidget(this.element.mc_highlight) as ZwWidget;
         addWidget(this.m_highlight);
         if(item != null)
         {
            icon = new FarmIcon(this.element.mc_gift,item.icon);
            icon.setIconSize(50,50);
            addWidget(icon);
            addWidget(new ZwTextField(this.element.tf_gift,item.friendlyTitle));
         }
         this.toggleHighlight(true);
      }
      
      override public function release() : void
      {
         this.m_highlight = null;
         this.m_radioButton = null;
         this.m_selectCallback = null;
         super.release();
      }
      
      private function onRadioSelect(radio:FarmRadioButton) : void
      {
         this.toggleHighlight(true);
         if(this.m_selectCallback != null)
         {
            this.m_selectCallback(this.m_item);
         }
      }
      
      private function onRadioDeselect(radio:FarmRadioButton) : void
      {
         this.toggleHighlight(false);
      }
      
      public function toggleHighlight(highlightOn:Boolean) : void
      {
         this.m_highlight.visible = highlightOn;
      }
      
      public function get radioButton() : FarmRadioButton
      {
         return this.m_radioButton;
      }
   }
}

