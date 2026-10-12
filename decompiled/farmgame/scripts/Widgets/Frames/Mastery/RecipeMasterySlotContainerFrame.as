package Widgets.Frames.Mastery
{
   import Classes.buffs.BMasteryTimed;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.Mastery.MasteryRecipeSlot;
   import Widgets.Windows.Mastery.MasteryWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class RecipeMasterySlotContainerFrame extends MasterySlotContainerFrame
   {
      
      public function RecipeMasterySlotContainerFrame(element:DisplayObject, masteryItems:Array, mainWindow:MasteryWindow)
      {
         masteryType = MasteryWindow.TYPE_RECIPE;
         super(element,masteryItems,mainWindow);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new MasteryRecipeSlot(slotElement,m_mainWindow);
      }
      
      override protected function onUpdateTimeLeft(event:Event) : void
      {
         updateTimeHelper(BMasteryTimed.CRAFTING_ITEM_NAME);
      }
   }
}

