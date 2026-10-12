package Widgets.Frames
{
   import Managers.OrderBoard.HalloweenInnovationGhoulManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.HalloweenInnovationGhoulInventionBaseSlot;
   import Widgets.Slots.HalloweenInnovationGhoulInventionSlot;
   import flash.display.DisplayObject;
   
   public class HalloweenInnovationGhoulInventionSlotsFrame extends FarmSlotContainerFrame
   {
      
      private static const KEY_ACTIVE_PART:String = "activePart";
      
      private var m_featureName:String = "";
      
      private var m_manager:HalloweenInnovationGhoulManager = null;
      
      private var m_createBaseSlot:Boolean;
      
      private var m_slotIndex:int;
      
      private var m_activeInvention:int;
      
      private var m_inventionIndex:int = -1;
      
      public function HalloweenInnovationGhoulInventionSlotsFrame(element:DisplayObject, featureName:String, manager:HalloweenInnovationGhoulManager, activeInvention:int, createBaseSlot:Boolean = false, slotIndex:int = -1)
      {
         this.m_featureName = featureName;
         this.m_manager = manager;
         this.m_createBaseSlot = createBaseSlot;
         this.m_slotIndex = slotIndex;
         this.m_activeInvention = activeInvention;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         ++this.m_inventionIndex;
         if(!this.m_createBaseSlot)
         {
            return new HalloweenInnovationGhoulInventionSlot(slotElement,this.m_featureName,this.m_manager,this.m_activeInvention,this.m_inventionIndex);
         }
         return new HalloweenInnovationGhoulInventionBaseSlot(slotElement,this.m_featureName,this.m_manager,this.m_activeInvention,this.m_inventionIndex);
      }
      
      private function insertSlotData(index:int, inventionName:String, activePart:int, activeInvention:int, inventions:Object) : void
      {
         m_slotData.push({
            "Index":index,
            "InventionName":inventionName,
            "ActivePart":activePart,
            "ActiveInvention":activeInvention,
            "Inventions":inventions
         });
      }
      
      override protected function setupData() : void
      {
         var inventionNames:Array = this.m_manager.getInventionNames();
         var inventionSlotsData:Object = this.m_manager.getFeatureOptionsKey(this.m_manager.GAME_INVENTIONS_KEY);
         var activePart:int = 0;
         var inventions:Object = null;
         if(this.m_createBaseSlot)
         {
            inventions = inventionSlotsData.inventions[this.m_slotIndex];
            activePart = this.m_manager.decryptData(inventions[KEY_ACTIVE_PART]);
            this.insertSlotData(this.m_slotIndex,inventionNames[this.m_slotIndex],activePart,this.m_slotIndex,inventionSlotsData.inventions[this.m_slotIndex]);
            return;
         }
         for(var i:int = 0; i < inventionNames.length; i++)
         {
            inventions = inventionSlotsData.inventions[0];
            activePart = this.m_manager.decryptData(inventions[KEY_ACTIVE_PART]);
            this.insertSlotData(i,inventionNames[i],activePart,this.m_manager.decryptData(inventionSlotsData.activeInvention),inventions);
         }
      }
      
      override public function refresh() : void
      {
         m_slotData = [];
         this.setupData();
         super.refresh();
      }
      
      override protected function getSlotPrefix() : String
      {
         return "invention";
      }
   }
}

