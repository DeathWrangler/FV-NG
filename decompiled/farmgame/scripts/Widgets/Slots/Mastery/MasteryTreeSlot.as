package Widgets.Slots.Mastery
{
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Windows.Mastery.MasteryWindow;
   import flash.display.DisplayObject;
   
   public class MasteryTreeSlot extends ZwSlotFrame
   {
      
      private var m_topMastery:MasterySlot;
      
      private var m_bottomMastery:MasterySlot;
      
      private var m_pointer:ZwBaseWidget;
      
      public function MasteryTreeSlot(element:DisplayObject, masteryWindow:MasteryWindow)
      {
         super(element);
         this.m_topMastery = new MasterySlot(m_element.itemCell0,masteryWindow);
         addWidget(this.m_topMastery,false);
         this.m_bottomMastery = new MasterySlot(m_element.itemCell1,masteryWindow);
         addWidget(this.m_bottomMastery,false);
         if(m_element.pointer_mc)
         {
            this.m_pointer = new ZwBaseWidget(m_element.pointer_mc);
            addWidget(this.m_pointer,false);
         }
      }
      
      override public function populate(data:Object) : void
      {
         this.m_topMastery.populate(data[0]);
         this.m_topMastery.visible = true;
         if(data[1])
         {
            this.m_bottomMastery.populate(data[1]);
            this.m_bottomMastery.visible = true;
            if(this.m_pointer)
            {
               this.m_pointer.visible = true;
            }
         }
      }
   }
}

