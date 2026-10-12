package Widgets.Slots
{
   import Classes.ItemFinderFoundItem;
   import Classes.ZItem.FarmItem;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class ItemFinderSlot extends ZwSlotFrame
   {
      
      private static const ICON_SIZE:int = 50;
      
      private static const SWF_EXPORT_NAME_TITLE:String = "title_tf";
      
      private static const SWF_EXPORT_NAME_BODY:String = "body_tf";
      
      private static const SWF_EXPORT_NAME_ICON:String = "icon_mc";
      
      private static const SWF_EXPORT_NAME_ACTION_BUTTON:String = "action_bt";
      
      private static const SWF_EXPORT_NAME_ACTION_BUTTON_TEXT:String = "generic_tf";
      
      protected var m_farmItem:FarmItem = null;
      
      protected var m_itemNameTextField:ZwTextField = null;
      
      protected var m_locationTextField:ZwTextField = null;
      
      protected var m_icon:FarmIcon = null;
      
      protected var m_actionButtonTextField:ZwTextField = null;
      
      protected var m_actionButton:FarmAnimatedButton = null;
      
      protected var m_actionCallback:Function = null;
      
      public function ItemFinderSlot(element:DisplayObject)
      {
         super(element);
      }
      
      override public function populate(data:Object) : void
      {
         var buttonElement:Object = null;
         removeAllWidgets();
         super.populate(data);
         var itemFinderFoundItem:ItemFinderFoundItem = data as ItemFinderFoundItem;
         this.m_farmItem = itemFinderFoundItem.farmItem;
         this.m_actionCallback = itemFinderFoundItem.callback;
         if(m_element.hasOwnProperty(SWF_EXPORT_NAME_TITLE) && m_element[SWF_EXPORT_NAME_TITLE] != null && itemFinderFoundItem.friendlyName != "")
         {
            this.m_itemNameTextField = new ZwTextField(m_element[SWF_EXPORT_NAME_TITLE],itemFinderFoundItem.friendlyName);
            addWidget(this.m_itemNameTextField);
         }
         if(m_element.hasOwnProperty(SWF_EXPORT_NAME_BODY) && m_element[SWF_EXPORT_NAME_BODY] != null)
         {
            this.m_locationTextField = new ZwTextField(m_element[SWF_EXPORT_NAME_BODY],itemFinderFoundItem.bodyText);
            addWidget(this.m_locationTextField);
         }
         if(m_element.hasOwnProperty(SWF_EXPORT_NAME_ICON) && m_element[SWF_EXPORT_NAME_ICON] != null && itemFinderFoundItem.icon != "")
         {
            this.m_icon = new FarmIcon(m_element[SWF_EXPORT_NAME_ICON],itemFinderFoundItem.icon);
            this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
            this.m_icon.setSmoothing(true);
            addWidget(this.m_icon);
         }
         if(m_element.hasOwnProperty(SWF_EXPORT_NAME_ACTION_BUTTON) && m_element[SWF_EXPORT_NAME_ACTION_BUTTON] != null)
         {
            buttonElement = m_element[SWF_EXPORT_NAME_ACTION_BUTTON];
            if(buttonElement.hasOwnProperty(SWF_EXPORT_NAME_ACTION_BUTTON_TEXT) && buttonElement[SWF_EXPORT_NAME_ACTION_BUTTON_TEXT] != null && Boolean(itemFinderFoundItem.buttonText))
            {
               this.m_actionButtonTextField = new ZwTextField(buttonElement[SWF_EXPORT_NAME_ACTION_BUTTON_TEXT],itemFinderFoundItem.buttonText);
               addWidget(this.m_actionButtonTextField);
            }
            this.m_actionButton = new FarmAnimatedButton(m_element[SWF_EXPORT_NAME_ACTION_BUTTON],this.onActionClick);
            addWidget(this.m_actionButton);
         }
      }
      
      private function onActionClick(event:MouseEvent) : void
      {
         this.m_actionCallback(this.m_farmItem);
      }
      
      override public function clearView() : void
      {
         if(this.m_icon)
         {
            this.m_icon.cancelLoad();
         }
         this.m_icon = null;
         this.m_itemNameTextField = null;
         this.m_locationTextField = null;
         this.m_actionButtonTextField = null;
         this.m_actionButton = null;
         removeAllWidgets();
      }
   }
}

