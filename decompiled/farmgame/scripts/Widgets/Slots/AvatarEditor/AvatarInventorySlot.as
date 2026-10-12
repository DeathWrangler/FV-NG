package Widgets.Slots.AvatarEditor
{
   import Classes.Avatar.AvatarItem;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.AvatarEditor.AvatarInventorySlotFrame;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class AvatarInventorySlot extends ZwSlotFrame
   {
      
      private static const ICON_SIZE:int = 50;
      
      private var m_container:AvatarInventorySlotFrame;
      
      private var m_selected:Boolean = false;
      
      private var m_data:AvatarItem;
      
      private var m_nameTextField:ZwTextField;
      
      private var m_icon:FarmIcon;
      
      private var m_selectedHighlight:ZwWidget;
      
      private var m_useButton:FarmAnimatedTextButton;
      
      private var m_useCallback:Function;
      
      private var m_removeButton:FarmAnimatedTextButton;
      
      private var m_removeCallback:Function;
      
      public function AvatarInventorySlot(element:DisplayObject, container:AvatarInventorySlotFrame, useCallback:Function, removeCallback:Function)
      {
         this.m_container = container;
         this.m_useCallback = useCallback;
         this.m_removeCallback = removeCallback;
         super(element);
         this.m_icon = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
         this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
         this.m_nameTextField = addWidget(new ZwTextField(m_element.generic_tf)) as ZwTextField;
         this.m_selectedHighlight = addWidget(new ZwWidget(m_element.selected_mc)) as ZwWidget;
         this.m_useButton = addWidget(new FarmAnimatedTextButton(m_element.use_bt,ZLocUtils.t("Dialogs","AvatarEditorWindow_UseButton"),this.onUseButtonClick)) as FarmAnimatedTextButton;
         this.m_removeButton = addWidget(new FarmAnimatedTextButton(m_element.takeOff_bt,ZLocUtils.t("Dialogs","AvatarEditorWindow_RemoveButton"),this.onRemoveButtonClick)) as FarmAnimatedTextButton;
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_selected = false;
         this.m_data = data as AvatarItem;
         if(this.m_data)
         {
            this.m_nameTextField.visible = true;
            this.m_nameTextField.text = ZLocUtils.tk_pk_asTitle(this.m_data.friendlyName);
            this.m_icon.loadIcon(this.m_data.iconPath);
            this.m_icon.visible = true;
            this.selected = this.m_container.isItemSelected(this.m_data.itemId);
         }
      }
      
      public function get data() : AvatarItem
      {
         return this.m_data;
      }
      
      public function get selected() : Boolean
      {
         return this.m_selected;
      }
      
      public function set selected(value:Boolean) : void
      {
         this.m_selected = value;
         this.m_selectedHighlight.visible = this.m_selected;
         this.m_useButton.visible = !this.m_selected;
         this.m_removeButton.visible = this.m_selected && this.m_data.isRemovable ? true : false;
      }
      
      private function onUseButtonClick(evt:Event) : void
      {
         if(this.m_useButton.enabled)
         {
            if(this.m_useCallback != null && Boolean(this.m_data))
            {
               this.m_useCallback(this.m_data);
            }
         }
      }
      
      private function onRemoveButtonClick(evt:Event) : void
      {
         if(this.m_removeButton.enabled)
         {
            if(this.m_removeCallback != null && Boolean(this.m_data))
            {
               this.m_removeCallback(this.m_data);
            }
         }
      }
      
      override public function release() : void
      {
         this.m_container = null;
         this.m_data = null;
         this.m_nameTextField = null;
         this.m_icon = null;
         this.m_selectedHighlight = null;
         this.m_useButton = null;
         this.m_useCallback = null;
         this.m_removeCallback = null;
         super.release();
      }
   }
}

