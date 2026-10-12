package Widgets.Core.Frames
{
   import flash.display.DisplayObject;
   
   public class ZwAbstractSlotContainerFrame extends ZwFrame
   {
      
      protected var m_slotData:Array = new Array();
      
      protected var m_slots:Array = new Array();
      
      protected var m_lastPopulateStartIndex:uint = 0;
      
      private var m_slotPositions:Object = null;
      
      public function ZwAbstractSlotContainerFrame(element:DisplayObject)
      {
         super(element);
         this.setupSlots();
         this.setupData();
         this.populateSlots();
      }
      
      override public function release() : void
      {
         this.m_slotData = null;
         this.m_slots = null;
         super.release();
      }
      
      public function refresh() : void
      {
         this.populateSlots(this.m_lastPopulateStartIndex);
      }
      
      public function centerSlots() : void
      {
         var slot:Object = null;
         var numTotalSlots:int = 0;
         var i:int = 0;
         var lastSlotXPos:int = 0;
         var lastUsedSlotXPos:int = 0;
         var deltaX:int = 0;
         var j:int = 0;
         var numSlotsToUse:int = int(this.m_slotData.length);
         if(!this.m_slotPositions)
         {
            this.m_slotPositions = {};
            for each(slot in this.m_slots)
            {
               this.m_slotPositions[slot.name] = slot.x;
            }
         }
         if(this.m_slots != null && numSlotsToUse > 0)
         {
            numTotalSlots = int(this.m_slots.length);
            if(numSlotsToUse < numTotalSlots)
            {
               for(i = numSlotsToUse; i < numTotalSlots; i++)
               {
                  this.m_slots[i].visible = false;
               }
               lastSlotXPos = int(this.m_slots[numTotalSlots - 1].x);
               lastUsedSlotXPos = int(this.m_slots[numSlotsToUse - 1].x);
               deltaX = (lastSlotXPos - lastUsedSlotXPos) / 2;
               if(deltaX > 0)
               {
                  j = 0;
                  while(j < numSlotsToUse && j < numTotalSlots)
                  {
                     this.m_slots[j].x += deltaX;
                     j++;
                  }
               }
            }
         }
      }
      
      public function resetSlotPositions() : void
      {
         var slot:Object = null;
         if(this.m_slotPositions)
         {
            for each(slot in this.m_slots)
            {
               slot.x = this.m_slotPositions[slot.name];
            }
         }
      }
      
      protected function getSlotPrefix() : String
      {
         throw new Error("Error: Abstract Function: Need to override ZwAbstractSlotFrame:getSlotPrefix.");
      }
      
      protected function getSlotPostfix() : String
      {
         throw new Error("Error: Abstract Function: Need to override ZwAbstractSlotFrame:getSlotPostfix.");
      }
      
      protected function setupData() : void
      {
         throw new Error("Error: Abstract Function: Need to override ZwAbstractSlotFrame:setupData.");
      }
      
      protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         throw new Error("Error: Abstract Function: Need to override ZwAbstractSlotFrame:createSlot.");
      }
      
      protected function setupSlots() : void
      {
         var slot:ZwSlotFrame = null;
         var index:uint = 0;
         var slotPrefix:String = this.getSlotPrefix();
         var slotPostfix:String = this.getSlotPostfix();
         while(m_element[slotPrefix + index.toString() + slotPostfix])
         {
            slot = this.createSlot(m_element[slotPrefix + index.toString() + slotPostfix]);
            addWidget(slot,false);
            this.m_slots.push(slot);
            index++;
         }
      }
      
      protected function populateSlots(dataIndex:uint = 0) : void
      {
         this.clearSlots();
         var slotIdx:uint = 0;
         while(slotIdx < this.m_slots.length && Boolean(this.m_slots[slotIdx]))
         {
            if(!(Boolean(this.m_slotData) && Boolean(dataIndex < this.m_slotData.length) && this.m_slotData[dataIndex] != null))
            {
               break;
            }
            this.populateSlot(this.m_slots[slotIdx] as ZwSlotFrame,this.m_slotData[dataIndex]);
            slotIdx++;
            dataIndex++;
         }
         this.m_lastPopulateStartIndex = dataIndex;
      }
      
      protected function populateSlot(slot:ZwSlotFrame, data:Object) : void
      {
         slot.populate(data);
         slot.visible = true;
      }
      
      public function totalSlots() : Number
      {
         var result:Number = 0;
         if(this.m_slots)
         {
            result = this.m_slots.length;
         }
         return result;
      }
      
      protected function clearSlots() : void
      {
         for(var slotIndex:uint = 0; slotIndex < this.m_slots.length; slotIndex++)
         {
            this.clearSlot(slotIndex);
         }
      }
      
      protected function clearSlot(slotIndex:uint) : void
      {
         var slot:ZwSlotFrame = null;
         if(this.m_slots[slotIndex])
         {
            slot = this.m_slots[slotIndex];
            slot.visible = false;
            slot.clearView();
         }
      }
      
      public function get slots() : Array
      {
         return this.m_slots;
      }
      
      public function get slotData() : Array
      {
         return this.m_slotData;
      }
   }
}

