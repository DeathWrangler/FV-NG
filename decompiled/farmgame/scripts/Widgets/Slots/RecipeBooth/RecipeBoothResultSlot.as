package Widgets.Slots.RecipeBooth
{
   import Classes.ZItem.FarmItem;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   
   public final class RecipeBoothResultSlot extends ZwSlotFrame
   {
      
      private static const ICON_SIZE:int = 50;
      
      private var m_data:Object;
      
      private var m_icon:FarmIcon;
      
      private var m_countTextField:ZwTextField;
      
      public function RecipeBoothResultSlot(element:DisplayObject)
      {
         super(element);
         this.m_icon = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
         this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
         this.m_countTextField = addWidget(new ZwTextField(m_element.count_tf," ")) as ZwTextField;
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_data = data;
         this.refresh();
      }
      
      override public function release() : void
      {
         this.m_icon = null;
         this.m_countTextField = null;
         super.release();
      }
      
      public function refresh() : void
      {
         var itemName:String = null;
         var item:FarmItem = null;
         if(this.m_data)
         {
            itemName = this.m_data["itemName"];
            item = Global.farmGameSettingsManager.getFarmItemByName(itemName);
            if(item)
            {
               this.m_icon.loadIcon(item.iconUrl);
               this.m_icon.visible = true;
            }
            this.m_countTextField.text = String(this.m_data["count"]);
            this.m_countTextField.visible = true;
         }
      }
   }
}

