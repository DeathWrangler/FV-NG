package Widgets.Frames.CreditsBuilding
{
   import Classes.RewardCreditsBuilding;
   import Widgets.Core.Frames.ZwAbstractSlotContainerFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import flash.display.DisplayObject;
   
   public class StatesFlyoutSlotFrame extends ZwAbstractSlotContainerFrame
   {
      
      protected var m_stateFlyoutSlots:Array = new Array();
      
      protected var m_building:RewardCreditsBuilding = null;
      
      protected var m_featureName:String;
      
      public function StatesFlyoutSlotFrame(element:DisplayObject, statesData:Array, building:RewardCreditsBuilding, buildingClassName:String)
      {
         this.m_building = building;
         this.m_featureName = buildingClassName;
         var slotIndex:Number = 1;
         super(element);
      }
      
      override public function release() : void
      {
         super.release();
      }
      
      override protected function setupData() : void
      {
         var index:int = 0;
         var slotObj:Object = null;
         var creditData:Array = Global.farmGameSettingsManager.getBuildingLevelItems(this.m_building.getCreditsFeatureName());
         if(creditData != null)
         {
            for(index = 0; index < creditData.length; index++)
            {
               slotObj = new Object();
               slotObj.cost = creditData[index];
               slotObj.level = index + 1;
               slotObj.title = "level " + (index + 1).toString();
               m_slotData.push(slotObj);
            }
         }
      }
      
      override protected function setupSlots() : void
      {
         var slot:ZwSlotFrame = null;
         var index:uint = 1;
         while(m_element[this.getSlotPrefix() + index + this.getSlotPostfix()])
         {
            slot = this.createSlot(m_element[this.getSlotPrefix() + index + this.getSlotPostfix()]);
            addWidget(slot,false);
            m_slots.push(slot);
            index++;
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new StatesFlyoutSlot(slotElement,this.m_building);
      }
      
      override protected function getSlotPrefix() : String
      {
         return "level";
      }
      
      override protected function getSlotPostfix() : String
      {
         return "_mc";
      }
      
      override public function refresh() : void
      {
         var slot:ZwSlotFrame = null;
         var flyoutSlot:StatesFlyoutSlot = null;
         for each(slot in m_slots)
         {
            flyoutSlot = slot as StatesFlyoutSlot;
            if(!flyoutSlot.updateState())
            {
               break;
            }
         }
      }
   }
}

