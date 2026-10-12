package Widgets.Core.Frames
{
   import Widgets.Core.Interfaces.IZwToggle;
   import Widgets.Core.Managers.ZwToggleManager;
   import Widgets.Core.Toggles.ZwToggle;
   import flash.display.DisplayObject;
   import flash.utils.Dictionary;
   
   public class ZwAbstractToggleSlotContainerFrame extends ZwAbstractPagableSlotFrameContainer
   {
      
      protected var m_toggleManager:ZwToggleManager = new ZwToggleManager();
      
      protected var m_toggleMap:Dictionary = new Dictionary(true);
      
      public function ZwAbstractToggleSlotContainerFrame(element:DisplayObject)
      {
         super(element);
      }
      
      override protected function setupSlots() : void
      {
         var toggle:ZwToggle = null;
         var slot:ZwSlotFrame = null;
         super.setupSlots();
         for each(slot in m_slots)
         {
            if(slot is IZwToggle)
            {
               toggle = new ZwToggle(slot as IZwToggle);
               this.m_toggleManager.addToggle(toggle);
               this.m_toggleMap[slot] = toggle;
            }
         }
      }
   }
}

