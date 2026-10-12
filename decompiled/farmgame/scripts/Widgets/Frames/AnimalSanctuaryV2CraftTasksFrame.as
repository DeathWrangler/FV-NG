package Widgets.Frames
{
   import Managers.AnimalSanctuaryV2Manager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.AnimalSanctuaryV2CraftTaskSlot;
   import flash.display.DisplayObject;
   
   public class AnimalSanctuaryV2CraftTasksFrame extends FarmSlotContainerFrame
   {
      
      protected static const SLOT_PREFIX:String = "craft_item_";
      
      protected static const SLOT_POSTFIX:String = "_mc";
      
      protected var m_featureName:String;
      
      private var m_craftItems:Array = ["craft_item0","craft_item1","craft_item2","craft_item3","craft_item4"];
      
      public function AnimalSanctuaryV2CraftTasksFrame(featureName:String, element:DisplayObject)
      {
         this.m_featureName = featureName;
         super(element);
         element.visible = true;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new AnimalSanctuaryV2CraftTaskSlot(this.m_featureName,slotElement);
      }
      
      override protected function setupData() : void
      {
         m_slotData = [];
         var itemData:Array = this.manager.getRecipesByWorld(this.manager.getSelectedWorld());
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

