package Widgets.Frames.Breeding
{
   import Classes.FeatureComponents.GiftedContentsStorageFManager;
   import Engine.ArrayUtil;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.Breeding.RandomPlacementContentsSlot;
   import Widgets.Windows.Breeding.AnimalBreedingContentsWindow;
   import flash.display.DisplayObject;
   
   public class RandomPlacementContentsSlotFrame extends StorageContentsSlotFrame
   {
      
      private var m_randomIndicies:Array = null;
      
      private var m_numAnimals:int = 0;
      
      private var m_dataShowQuantities:Array = null;
      
      private var m_friendData:Array = null;
      
      private const FIRST_ROW_SIZE:int = 10;
      
      private const ROW_OVERFLOW_MINIMUM:int = 6;
      
      public function RandomPlacementContentsSlotFrame(element:DisplayObject, animals:Array, mainWindow:AnimalBreedingContentsWindow)
      {
         super(element,animals,mainWindow,null);
      }
      
      private function init() : void
      {
         this.setupTotalAnimals();
         this.setupDataShowQuantities();
      }
      
      public function updateAnimals(animals:Array) : void
      {
         m_contents = animals;
      }
      
      override public function refresh() : void
      {
         setupData();
         this.populateSlots();
      }
      
      private function setupDataShowQuantities() : void
      {
         var maxShow:uint = 0;
         var quantity:int = 0;
         var showAmount:int = 0;
         var totalShowing:int = 0;
         var len:uint = 0;
         var data:Object = null;
         var dataIndex:uint = 0;
         if(this.m_numAnimals > 0)
         {
            maxShow = Math.min(m_slots.length,this.m_numAnimals);
            totalShowing = 0;
            len = m_slotData.length;
            this.m_dataShowQuantities = new Array();
            for(dataIndex = 0; dataIndex < len; dataIndex++)
            {
               data = m_slotData[dataIndex];
               quantity = int(data.quantity);
               if(quantity > 0)
               {
                  showAmount = Math.ceil((quantity * maxShow as Number) / this.m_numAnimals);
                  this.m_dataShowQuantities[dataIndex] = showAmount;
                  totalShowing += showAmount;
               }
               else
               {
                  this.m_dataShowQuantities[dataIndex] = 0;
               }
            }
         }
      }
      
      private function setupTotalAnimals() : void
      {
         var data:Object = null;
         var numAnimals:int = 0;
         var len:uint = m_slotData.length;
         this.m_friendData = new Array();
         var storageManager:GiftedContentsStorageFManager = m_mainWindow.building.storage as GiftedContentsStorageFManager;
         for(var dataIndex:uint = 0; dataIndex < len; dataIndex++)
         {
            data = m_slotData[dataIndex];
            if(data.quantity)
            {
               numAnimals += data.quantity;
               this.m_friendData[dataIndex] = storageManager.getFriendListForItemCode(data.code);
            }
         }
         this.m_numAnimals = numAnimals;
      }
      
      override protected function populateSlots(dataIndex:uint = 0) : void
      {
         var slot:ZwSlotFrame = null;
         var dataObject:Object = null;
         var numShow:int = 0;
         var friend:Object = null;
         clearSlots();
         this.init();
         var slotIndex:uint = 0;
         while(slotIndex < m_slots.length && Boolean(m_slots[slotIndex]))
         {
            slot = m_slots[slotIndex] as ZwSlotFrame;
            slot.visible = false;
            slotIndex++;
         }
         slotIndex = 0;
         var numSlotsFill:int = Math.min(this.m_numAnimals,m_slots.length);
         while(slotIndex < numSlotsFill && Boolean(m_slots[slotIndex]))
         {
            if(!(dataIndex < m_slotData.length && Boolean(m_slotData[dataIndex])))
            {
               break;
            }
            slot = m_slots[slotIndex];
            dataObject = m_slotData[dataIndex];
            numShow = int(this.m_dataShowQuantities[dataIndex]);
            if(numShow > 0)
            {
               friend = (this.m_friendData[dataIndex] as Array).pop();
               dataObject.friend = friend;
               slot.populate(dataObject);
               slot.visible = true;
               --this.m_dataShowQuantities[dataIndex];
               slotIndex++;
            }
            dataIndex++;
            dataIndex %= m_slotData.length;
         }
         m_lastPopulateStartIndex = dataIndex;
      }
      
      override protected function setupSlots() : void
      {
         var randSlotIndex:uint = 0;
         var slot:ZwSlotFrame = null;
         this.setUpRandomIndicies();
         for(var slotIndex:uint = 0; slotIndex < this.m_randomIndicies.length; slotIndex++)
         {
            randSlotIndex = uint(this.m_randomIndicies[slotIndex]);
            slot = this.createIndexedSlot(m_element[getSlotPrefix() + randSlotIndex + getSlotPostfix()],randSlotIndex);
            addWidget(slot,false);
            m_slots.push(slot);
         }
      }
      
      private function getSlotLength() : int
      {
         var slotIndex:int = 0;
         while(m_element[getSlotPrefix() + slotIndex + getSlotPostfix()])
         {
            slotIndex++;
         }
         return slotIndex;
      }
      
      private function setUpRandomIndicies() : void
      {
         var slotLen:int = this.getSlotLength();
         this.m_randomIndicies = new Array();
         var len:uint = m_slots.length;
         for(var index:uint = 0; index < slotLen; index++)
         {
            this.m_randomIndicies.push(index);
         }
         ArrayUtil.randomize(this.m_randomIndicies,0,this.FIRST_ROW_SIZE);
         ArrayUtil.randomize(this.m_randomIndicies,this.ROW_OVERFLOW_MINIMUM,this.m_randomIndicies.length);
      }
      
      private function createIndexedSlot(slotElement:DisplayObject, index:int = 0) : ZwSlotFrame
      {
         return new RandomPlacementContentsSlot(slotElement,m_mainWindow,index,this.FIRST_ROW_SIZE);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return null;
      }
   }
}

