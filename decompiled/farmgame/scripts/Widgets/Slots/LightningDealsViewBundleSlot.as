package Widgets.Slots
{
   import Classes.ZItem.FarmItem;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   
   public class LightningDealsViewBundleSlot extends ZwSlotFrame
   {
      
      private var m_icon:FarmIcon;
      
      private var m_name:ZwTextField;
      
      private var iconAdded:Boolean = false;
      
      public function LightningDealsViewBundleSlot(element:DisplayObject, featureName:String)
      {
         super(element);
         addWidget(this.m_name = new ZwTextField(m_element["name_tf"],""),true);
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(data.itemName);
         if(item)
         {
            if(this.iconAdded == true)
            {
               removeWidget(this.m_icon);
            }
            addWidget(this.m_icon = new FarmIcon(m_element["icon_mc"],item.icon));
            this.m_name.text = item.friendlyTitle;
            this.m_name.visible = true;
            this.iconAdded = true;
         }
      }
   }
}

