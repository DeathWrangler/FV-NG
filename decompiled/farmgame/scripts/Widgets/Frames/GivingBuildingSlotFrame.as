package Widgets.Frames
{
   import Classes.FeatureBuilding;
   import DataSources.BaseDataSource;
   import Managers.FarmGameSettingsManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.GivingBuildingPrizeSlot;
   import flash.display.DisplayObject;
   
   public class GivingBuildingSlotFrame extends FarmSlotContainerFrame
   {
      
      protected var m_building:FeatureBuilding = null;
      
      protected var m_owner:DisplayObject;
      
      public function GivingBuildingSlotFrame(element:DisplayObject, building:FeatureBuilding, owner:DisplayObject)
      {
         this.m_building = building;
         this.m_owner = owner;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new GivingBuildingPrizeSlot(slotElement,this.m_owner);
      }
      
      override protected function setupData() : void
      {
         var data:Object = null;
         var upgradeDataSource:BaseDataSource = null;
         var partData:BaseDataSource = null;
         var upgradeXML:XML = null;
         var numLevels:int = this.m_building.getItem().getMaxUpgradeLevel();
         for(var level:int = 2; level < numLevels + 1; level++)
         {
            data = new Object();
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               upgradeDataSource = this.m_building.getItem().getUpgradeDataSource(level);
               partData = upgradeDataSource.getArray("part")[0];
               data.partNeeded = partData.getInt("need");
               data.partName = partData.getString("name");
               data.award = upgradeDataSource.getString("award","name");
            }
            else
            {
               upgradeXML = this.m_building.getItem().getUpgradeData(level);
               data.partNeeded = upgradeXML.part.@need;
               data.partName = upgradeXML.part.@name;
               data.award = upgradeXML.award.@name;
            }
            data.level = level;
            data.building = this.m_building;
            m_slotData.push(data);
         }
      }
      
      public function refreshSlots() : void
      {
         populateSlots();
      }
   }
}

