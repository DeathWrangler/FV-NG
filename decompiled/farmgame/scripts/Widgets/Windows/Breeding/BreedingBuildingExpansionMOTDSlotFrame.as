package Widgets.Windows.Breeding
{
   import Classes.FeatureBuilding;
   import Classes.MapResource;
   import Classes.ZItem.FarmItem;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class BreedingBuildingExpansionMOTDSlotFrame extends FarmSlotContainerFrame
   {
      
      private var m_level2Buildings:Object;
      
      private var m_unexpandedBuildings:Object;
      
      private var m_inProgressBuildings:Object;
      
      private var m_fullyExpandedBuildings:Object;
      
      private var m_buildingTypes:Array;
      
      public function BreedingBuildingExpansionMOTDSlotFrame(element:DisplayObject)
      {
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         var slot:BreedingBuildingExpansionMOTDSlot = new BreedingBuildingExpansionMOTDSlot(slotElement);
         slot.addEventListener(BreedingBuildingExpansionMOTDSlot.BUY_BUILDING_CLICKED_EVENT,this.onSlotBuyBuildingClicked);
         slot.addEventListener(BreedingBuildingExpansionMOTDSlot.BUY_EXPANSION_CLICKED_EVENT,this.onSlotBuyExpansionClicked);
         slot.addEventListener(BreedingBuildingExpansionMOTDSlot.EVENT_ADVANCED_EXPAND,this.onAdvancedExpand);
         slot.addEventListener(BreedingBuildingExpansionMOTDSlot.EVENT_FIRST_EXPAND,this.onFirstExpand);
         slot.addEventListener(BreedingBuildingExpansionMOTDSlot.EVENT_COMPLETE_NOW,this.onCompleteNow);
         return slot;
      }
      
      override public function release() : void
      {
         var slot:ZwSlotFrame = null;
         for(var iSlot:int = 0; iSlot < m_slots.length; iSlot++)
         {
            slot = m_slots[iSlot];
            if(slot != null)
            {
               slot.removeEventListener(BreedingBuildingExpansionMOTDSlot.BUY_BUILDING_CLICKED_EVENT,this.onSlotBuyBuildingClicked);
               slot.removeEventListener(BreedingBuildingExpansionMOTDSlot.BUY_EXPANSION_CLICKED_EVENT,this.onSlotBuyExpansionClicked);
               slot.removeEventListener(BreedingBuildingExpansionMOTDSlot.EVENT_ADVANCED_EXPAND,this.onAdvancedExpand);
               slot.removeEventListener(BreedingBuildingExpansionMOTDSlot.EVENT_FIRST_EXPAND,this.onFirstExpand);
               slot.removeEventListener(BreedingBuildingExpansionMOTDSlot.EVENT_COMPLETE_NOW,this.onCompleteNow);
            }
         }
      }
      
      private function onAdvancedExpand(event:Event) : void
      {
         this.refreshSlot(event.target as BreedingBuildingExpansionMOTDSlot,this.m_level2Buildings,this.m_fullyExpandedBuildings);
      }
      
      private function onFirstExpand(event:Event) : void
      {
         this.refreshSlot(event.target as BreedingBuildingExpansionMOTDSlot,this.m_unexpandedBuildings,this.m_level2Buildings);
      }
      
      private function onCompleteNow(event:Event) : void
      {
         this.refreshSlot(event.target as BreedingBuildingExpansionMOTDSlot,this.m_inProgressBuildings,this.m_unexpandedBuildings);
      }
      
      private function refreshSlot(slot:BreedingBuildingExpansionMOTDSlot, sourceList:Object, pushList:Object = null) : void
      {
         var buildingType:String = slot.buildingType;
         if(pushList)
         {
            pushList[buildingType].push(slot.placedBuilding);
            if(pushList == this.m_unexpandedBuildings || pushList == this.m_level2Buildings)
            {
               (pushList[buildingType] as Array).sort(this.sortBuildings);
            }
         }
         var slotData:Object = this.getSlotData(buildingType,sourceList[buildingType].length == 0);
         slot.populate(slotData);
      }
      
      private function hasBuildings(buildingType:String) : Boolean
      {
         return this.m_level2Buildings[buildingType].length > 0 || this.m_unexpandedBuildings[buildingType].length > 0 || this.m_inProgressBuildings[buildingType].length > 0 || this.m_fullyExpandedBuildings[buildingType].length > 0;
      }
      
      private function getSlotData(buildingType:String, includeNumBuildings:Boolean = false) : Object
      {
         var building:MapResource = null;
         var state:int = 0;
         var numBuildings:int = 0;
         if(!this.hasBuildings(buildingType))
         {
            state = BreedingBuildingExpansionMOTDSlot.STATE_NO_BUILDINGS;
         }
         else if(this.m_inProgressBuildings[buildingType].length > 0)
         {
            state = BreedingBuildingExpansionMOTDSlot.STATE_IN_PROGRESS;
            numBuildings = int(this.m_inProgressBuildings[buildingType].length);
            building = this.m_inProgressBuildings[buildingType].shift();
         }
         else if(this.m_unexpandedBuildings[buildingType].length > 0)
         {
            state = BreedingBuildingExpansionMOTDSlot.STATE_UNEXPANDED;
            numBuildings = int(this.m_unexpandedBuildings[buildingType].length);
            building = this.m_unexpandedBuildings[buildingType].shift();
         }
         else if(this.m_level2Buildings[buildingType].length > 0)
         {
            state = BreedingBuildingExpansionMOTDSlot.STATE_EXPANDED_ONCE;
            numBuildings = int(this.m_level2Buildings[buildingType].length);
            building = this.m_level2Buildings[buildingType].shift();
         }
         else
         {
            state = BreedingBuildingExpansionMOTDSlot.STATE_FULLY_EXPANDED;
         }
         var data:Object = {
            "building":building,
            "state":state,
            "type":buildingType
         };
         if(includeNumBuildings)
         {
            data.numBuildings = numBuildings;
         }
         return data;
      }
      
      override protected function setupData() : void
      {
         var buildingType:String = null;
         this.populateBreedingBuildingList();
         m_slotData = new Array(this.m_buildingTypes.length);
         for(var i:int = 0; i < this.m_buildingTypes.length; i++)
         {
            buildingType = this.m_buildingTypes[i];
            m_slotData[i] = this.getSlotData(buildingType,true);
         }
      }
      
      private function populateBreedingBuildingList() : void
      {
         var farmItem:FarmItem = null;
         var placedBuildings:Array = null;
         var i:int = 0;
         var finishedBuildingName:String = null;
         var constructableBuildingName:String = null;
         var building:FeatureBuilding = null;
         var validConstructableBuildingNames:Array = new Array();
         var validFinishedBuildingNames:Array = new Array();
         var validBuildings:Array = Global.farmGameSettingsManager.getItemsByClassArray("AnimalWildlifePenConstructionBuilding");
         validBuildings = validBuildings.concat(Global.farmGameSettingsManager.getItemsByClassArray("AnimalPetrunConstructionBuilding"));
         validBuildings = validBuildings.concat(Global.farmGameSettingsManager.getItemsByClassArray("AnimalBreedingPenConstructionBuilding"));
         for each(farmItem in validBuildings)
         {
            validConstructableBuildingNames.push(farmItem.name);
            validFinishedBuildingNames.push(farmItem.getFinishedName());
         }
         this.m_buildingTypes = validConstructableBuildingNames;
         this.m_level2Buildings = new Object();
         this.m_unexpandedBuildings = new Object();
         this.m_inProgressBuildings = new Object();
         this.m_fullyExpandedBuildings = new Object();
         for(i = 0; i < validFinishedBuildingNames.length; i++)
         {
            finishedBuildingName = validFinishedBuildingNames[i];
            constructableBuildingName = validConstructableBuildingNames[i];
            placedBuildings = Global.world.getObjectsByNames([finishedBuildingName]);
            this.m_level2Buildings[constructableBuildingName] = new Array();
            this.m_unexpandedBuildings[constructableBuildingName] = new Array();
            this.m_fullyExpandedBuildings[constructableBuildingName] = new Array();
            for each(building in placedBuildings)
            {
               if(building.storageLevel == 2)
               {
                  this.m_level2Buildings[constructableBuildingName].push(building);
               }
               else if(building.storageLevel == 1)
               {
                  this.m_unexpandedBuildings[constructableBuildingName].push(building);
               }
               else
               {
                  this.m_fullyExpandedBuildings[constructableBuildingName].push(building);
               }
            }
            (this.m_unexpandedBuildings[constructableBuildingName] as Array).sort(this.sortBuildings);
            (this.m_level2Buildings[constructableBuildingName] as Array).sort(this.sortBuildings);
            this.m_inProgressBuildings[constructableBuildingName] = Global.world.getObjectsByNames([constructableBuildingName]);
         }
      }
      
      private function sortBuildings(buildingA:FeatureBuilding, buildingB:FeatureBuilding) : int
      {
         var returnValue:int = 0;
         if(buildingA.count > buildingB.count)
         {
            returnValue = -1;
         }
         else if(buildingA.count < buildingB.count)
         {
            returnValue = 1;
         }
         return returnValue;
      }
      
      private function onSlotBuyBuildingClicked(event:Event) : void
      {
         dispatchEvent(event);
      }
      
      private function onSlotBuyExpansionClicked(event:Event) : void
      {
         dispatchEvent(event);
      }
   }
}

