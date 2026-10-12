package Widgets.Slots.UGC
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ObjectUtil;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmItemIcon;
   import flash.display.DisplayObject;
   
   public class UGCItemHudPartSlot extends ZwSlotFrame
   {
      
      private var m_countTf:ZwTextField;
      
      private var m_farmItem:FarmItem;
      
      public function UGCItemHudPartSlot(element:DisplayObject, part:FarmItem)
      {
         var icon:FarmItemIcon = null;
         super(element);
         this.m_farmItem = part;
         if(ObjectUtil.pathExists(m_element,"count_tf"))
         {
            this.m_countTf = new ZwTextField(m_element["count_tf"],"0");
            addWidget(this.m_countTf);
         }
         if(ObjectUtil.pathExists(m_element,"icon"))
         {
            icon = new FarmItemIcon(this,m_element.icon,part);
         }
      }
      
      public function setCost(cost:Object) : void
      {
         this.m_countTf.text = cost.hasOwnProperty(this.m_farmItem.name) ? "" + cost[this.m_farmItem.name] : "0";
      }
   }
}

