package Widgets.Slots.Storage
{
   import Engine.Managers.StatsManager;
   import Managers.DecoratorModeManager;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Storage.DecoratorModeTemporaryStorageFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.Storage.StorageWindow;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class DecoratorModeTemporaryStorageSlot extends BaseStorageSlot
   {
      
      private var m_title:ZwTextField;
      
      private var m_icon:FarmIcon;
      
      private var m_amount:ZwTextField;
      
      private var m_itemName:String;
      
      private var m_parentFrame:DecoratorModeTemporaryStorageFrame;
      
      private var m_storageId:int;
      
      public function DecoratorModeTemporaryStorageSlot(element:DisplayObject, parentWindow:StorageWindow, storageId:int, parentFrame:DecoratorModeTemporaryStorageFrame)
      {
         super(element,parentWindow);
         this.m_parentFrame = parentFrame;
         if(m_element.title_tf != null)
         {
            addWidget(this.m_title = new ZwTextField(m_element.title_tf));
         }
         if(m_element.icon_mc != null)
         {
            addWidget(this.m_icon = new FarmIcon(m_element.icon_mc));
            this.m_icon.registerEventListener(MouseEvent.CLICK,this.onUseClick);
         }
         if(m_element.itemCount_tf != null)
         {
            addWidget(this.m_amount = new ZwTextField(m_element.itemCount_tf,""));
         }
         this.m_storageId = storageId;
      }
      
      override protected function onUseClick(event:MouseEvent) : void
      {
         if(this.m_parentFrame.StorageEnabled)
         {
            super.onUseClick(event);
            this.m_parentFrame.removeItem(m_data.itemKey);
            StatsManager.count(DecoratorModeManager.STATS_KINGDOM,"ui_action","remove_tempstore");
         }
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_itemName = data["name"];
         var title:String = data["title"];
         var icon:String = data["icon"];
         var amount:String = data["amount"].toString();
         m_data = data["slotData"];
         if(this.m_icon != null)
         {
            this.m_icon.loadIcon(icon);
            this.m_icon.visible = true;
            this.m_icon.setIconSize(50,50);
         }
         if(this.m_amount != null)
         {
            this.m_amount.text = amount;
            this.m_amount.visible = true;
         }
         if(this.m_title != null)
         {
            this.m_title.text = title;
            this.m_title.visible = true;
         }
      }
      
      override public function release() : void
      {
         super.release();
      }
      
      override protected function shouldCloseOnUse() : Boolean
      {
         return false;
      }
      
      override protected function storageWorldId() : int
      {
         return this.m_storageId;
      }
   }
}

