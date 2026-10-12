package Widgets.Frames.Crafting
{
   import Classes.crafting.RecipeItem;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.Crafting.CraftingMainProductionSlot;
   import Widgets.Windows.Crafting.CraftingMainWindow;
   import flash.display.DisplayObject;
   
   public class CraftingMainProductionSlotFrame extends FarmSlotContainerFrame
   {
      
      private static const NUM_OVENS:int = 6;
      
      protected var m_items:Array = null;
      
      private var m_craftingMainWindow:CraftingMainWindow = null;
      
      public function CraftingMainProductionSlotFrame(element:DisplayObject, items:Array, craftingMainWindow:CraftingMainWindow)
      {
         this.m_items = items;
         while(this.m_items.length < NUM_OVENS)
         {
            this.m_items.push(new Object());
         }
         this.m_craftingMainWindow = craftingMainWindow;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new CraftingMainProductionSlot(slotElement,this.m_craftingMainWindow);
      }
      
      override protected function setupData() : void
      {
         m_slotData = this.sortSlots(this.m_items);
      }
      
      override public function release() : void
      {
         super.release();
         this.m_items = null;
         this.m_craftingMainWindow = null;
      }
      
      public function setEnabled(enable:Boolean, index:int = -1) : void
      {
         var productionSlot:CraftingMainProductionSlot = null;
         var i:int = 0;
         this.enabled = enable;
         if(index == -1)
         {
            for(i = 0; i < NUM_OVENS; i++)
            {
               productionSlot = m_slots[i];
               productionSlot.enabled = enable;
            }
         }
         else
         {
            productionSlot = m_slots[index];
            productionSlot.enabled = enable;
         }
      }
      
      public function enterFrame(deltaTime:Number) : void
      {
         var productionSlot:CraftingMainProductionSlot = null;
         for(var i:int = 0; i < NUM_OVENS; i++)
         {
            productionSlot = m_slots[i];
            productionSlot.enterFrame(deltaTime);
         }
      }
      
      public function updateSlots(items:Array) : void
      {
         var recipeSlot:CraftingMainProductionSlot = null;
         m_slotData = this.m_items = this.sortSlots(items);
         for(var i:int = 0; i < m_slots.length; i++)
         {
            recipeSlot = m_slots[i];
            recipeSlot.populate(m_slotData[i]);
         }
      }
      
      public function findEmptySlot(arrayIn:Array = null) : int
      {
         var slot:RecipeItem = null;
         var returnVal:int = -1;
         var testArray:Array = arrayIn != null ? arrayIn : m_slotData;
         var maximumSlots:int = this.m_craftingMainWindow.cottage.maximumSlots;
         for(var i:int = 0; i < maximumSlots; i++)
         {
            slot = testArray[i] as RecipeItem;
            if(!slot || slot.id == "")
            {
               returnVal = i;
               break;
            }
         }
         return returnVal;
      }
      
      private function sortSlots(arrayIn:Array) : Array
      {
         var slot:RecipeItem = null;
         var i:int = 0;
         var arrayOut:Array = [];
         var maximumSlots:int = this.m_craftingMainWindow.cottage.maximumSlots;
         for(i = 0; i < NUM_OVENS; i++)
         {
            if(i < maximumSlots)
            {
               arrayOut[i] = new RecipeItem();
            }
            else
            {
               arrayOut[i] = new Object();
            }
         }
         for(i = 0; i < arrayIn.length; i++)
         {
            slot = arrayIn[i] as RecipeItem;
            if(Boolean(slot) && slot.ovenSlot != -1)
            {
               arrayOut[slot.ovenSlot] = slot;
            }
         }
         for(i = 0; i < arrayIn.length; i++)
         {
            slot = arrayIn[i] as RecipeItem;
            if(Boolean(slot) && slot.ovenSlot == -1)
            {
               slot.ovenSlot = this.findEmptySlot(arrayOut);
               arrayOut[slot.ovenSlot] = slot;
            }
         }
         return arrayOut;
      }
   }
}

