package Widgets.Slots
{
   import Engine.Utilities;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class RecentlyPlayedFriendsGiftSlot extends ZwSlotFrame
   {
      
      private static const ICON_SIZE:int = 30;
      
      private var m_clickCallback:Function;
      
      private var m_data:Object;
      
      private var m_selected:Boolean = true;
      
      private var m_activeBackground:ZwWidget;
      
      private var m_checkbox:ZwWidget;
      
      private var m_icon:FarmIcon;
      
      private var m_nameTextField:ZwTextField;
      
      public function RecentlyPlayedFriendsGiftSlot(element:DisplayObject, clickCallback:Function)
      {
         super(element);
         this.m_clickCallback = clickCallback;
         this.m_activeBackground = addWidget(new ZwWidget(m_element.mc_active_bg)) as ZwWidget;
         this.m_checkbox = addWidget(new ZwWidget(m_element.mc_checkmark)) as ZwWidget;
         this.m_icon = addWidget(new FarmIcon(m_element.mc_fbprofile)) as FarmIcon;
         this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
         this.m_nameTextField = addWidget(new ZwTextField(m_element.txt_name," ")) as ZwTextField;
         (m_element as MovieClip).addEventListener(MouseEvent.CLICK,this.onClick,false,0,true);
         (m_element as MovieClip).buttonMode = true;
      }
      
      public function get data() : Object
      {
         return this.m_data;
      }
      
      public function get selected() : Boolean
      {
         return this.m_selected;
      }
      
      public function set selected(_selected:Boolean) : void
      {
         this.m_selected = _selected;
         this.m_activeBackground.visible = this.m_checkbox.visible = this.m_selected;
      }
      
      private function onClick(evt:MouseEvent) : void
      {
         this.m_activeBackground.visible = this.m_checkbox.visible = this.m_selected = !this.m_selected;
         if(this.m_clickCallback != null)
         {
            this.m_clickCallback();
         }
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_data = data;
         if(this.m_data)
         {
            this.m_activeBackground.visible = this.m_checkbox.visible = this.m_selected = true;
            this.m_icon.loadIcon(data["pic_square"]);
            this.m_icon.visible = true;
            this.m_nameTextField.text = data["name"];
            this.m_nameTextField.visible = true;
            Utilities.toggleInputOnlySelf(m_element.txt_name,false);
            Utilities.toggleInputOnlyChildren(m_element as MovieClip,false);
         }
      }
      
      override public function release() : void
      {
         (m_element as MovieClip).removeEventListener(MouseEvent.CLICK,this.onClick);
         this.m_clickCallback = null;
         this.m_data = null;
         this.m_activeBackground = null;
         this.m_checkbox = null;
         this.m_nameTextField = null;
         super.release();
      }
   }
}

