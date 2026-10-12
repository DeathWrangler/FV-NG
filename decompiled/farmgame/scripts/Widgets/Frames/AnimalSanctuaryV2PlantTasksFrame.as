package Widgets.Frames
{
   import Managers.AnimalSanctuaryV2Manager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.AnimalSanctuaryV2PlantTaskSlot;
   import flash.display.DisplayObject;
   
   public class AnimalSanctuaryV2PlantTasksFrame extends FarmSlotContainerFrame
   {
      
      protected static const SLOT_PREFIX:String = "plant_item_";
      
      protected static const SLOT_POSTFIX:String = "_mc";
      
      protected var m_featureName:String;
      
      private var m_plantItems:Array = ["plant_item0","plant_item1","plant_item2","plant_item3","plant_item4"];
      
      public function AnimalSanctuaryV2PlantTasksFrame(featureName:String, element:DisplayObject)
      {
         this.m_featureName = featureName;
         super(element);
         element.visible = true;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new AnimalSanctuaryV2PlantTaskSlot(this.m_featureName,slotElement);
      }
      
      override protected function setupData() : void
      {
         m_slotData = [];
         var itemData:Array = this.manager.getCropsByWorld(this.manager.getSelectedWorld());
         for(var i:int = 0; i < itemData.length; i++)
         {
            m_slotData.push({
               "id":i,
               "itemCode":itemData[i]
            });
         }
      }
      
      override protected function getSlotPrefix() : String
      {
         return SLOT_PREFIX;
      }
      
      override protected function getSlotPostfix() : String
      {
         return SLOT_POSTFIX;
      }
      
      private function get manager() : AnimalSanctuaryV2Manager
      {
         return AnimalSanctuaryV2Manager.getInstance(this.m_featureName);
      }
   }
}

