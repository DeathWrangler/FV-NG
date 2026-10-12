package Widgets.Slots.Crafting
{
   import Classes.Player;
   import Classes.util.ZLocUtils;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   
   public class CraftshopFriendSlot extends ZwSlotFrame
   {
      
      protected var m_name:ZwTextField;
      
      protected var m_icon:FarmIcon;
      
      private var m_rolloverTooltip:FarmTextTooltip = null;
      
      public function CraftshopFriendSlot(element:DisplayObject)
      {
         super(element);
         this.m_name = addWidget(new ZwTextField(this.element.name_tf,"name_tf")) as ZwTextField;
         this.m_icon = addWidget(new FarmIcon(this.element.icon_mc,Player.NO_PROFILE_PIC_URL)) as FarmIcon;
         this.m_rolloverTooltip = new FarmTextTooltip();
         this.m_rolloverTooltip.setText(ZLocUtils.t("Crafting","CraftingMain_FriendSlot_Tooltip"));
         this.attachTooltip(this.m_rolloverTooltip);
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         if(data.hasOwnProperty("name"))
         {
            this.m_name.text = data.name;
            this.m_name.visible = true;
         }
         if(data.hasOwnProperty("icon"))
         {
            this.m_icon.loadIcon(data.icon);
            this.m_icon.setIconSize(50,50);
            this.m_icon.visible = true;
         }
      }
   }
}

