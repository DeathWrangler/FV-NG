package Classes
{
   import Classes.Constants.Experiments;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Display.GarageStorageWithdrawal;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Classes.SavedObject;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import GameMode.GMHarvester;
   import GameMode.GMIrrigationSprinkler;
   import GameMode.GMPlotRemover;
   import GameMode.GMTractorPlow;
   import Managers.EquipmentSettingsManager;
   import Managers.FarmStatsManager;
   import Transactions.TAddPartToEquipmentInGarage;
   import Widgets.Windows.CombineOnboardingWindow;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.utils.getDefinitionByName;
   
   public class GarageBuilding extends StorageBuilding
   {
      
      public static const VEHICLE_PART_ITEM:String = "vehiclepart";
      
      private var m_equipmentContained:Array = null;
      
      private var m_hasTractor:Boolean = false;
      
      private var m_hasRotTractor:Boolean = false;
      
      private var m_hasSeeder:Boolean = false;
      
      private var m_hasRotSeeder:Boolean = false;
      
      private var m_hasHarvester:Boolean = false;
      
      private var m_hasRotHarvester:Boolean = false;
      
      private var m_hasCombine:Boolean = false;
      
      private var m_hasRotCombine:Boolean = false;
      
      private var m_hasOrchardHarvester:Boolean = false;
      
      private var m_hasRotOrchardHarvester:Boolean = false;
      
      private var m_hasAnimalPenHarvester:Boolean = false;
      
      private var m_hasSprinkler:Boolean = false;
      
      private var m_hasPlotRemover:Boolean = false;
      
      private var m_hasRotPlotRemover:Boolean = false;
      
      public function GarageBuilding(buildingType:String = null)
      {
         super(buildingType);
      }
      
      public function addPartToVehicle(key:String, isGift:Boolean = false, partName:String = "vehiclepart") : void
      {
         var explodedKey:Array = null;
         var code:String = null;
         var numParts:int = 0;
         var item:FarmItem = null;
         var vehiclepart:FarmItem = null;
         var iconFilter:Array = null;
         var iconUrl:String = null;
         var duration:Number = NaN;
         var equipmentClass:Class = null;
         var itemName:String = null;
         var equipment:Equipment = null;
         var allLevels:Array = null;
         var level:Object = null;
         if(m_contents[key])
         {
            explodedKey = key.split(":");
            code = explodedKey[0];
            numParts = int(explodedKey[1]);
            item = Global.farmGameSettingsManager.getFarmItemByCode(code);
            vehiclepart = Global.farmGameSettingsManager.getFarmItemByName(partName);
            iconFilter = [new GlowFilter(16776960,1,8,8,20)];
            iconUrl = Global.farmGameSettingsManager.getFarmItemByName(partName).iconUrl;
            duration = UI.DEFAULT_STATUS_TWEEN_DURATION * 2;
            this.displayStatus("",iconUrl,iconFilter,duration);
            this.centerOn();
            this.removeContents(code,1,numParts);
            equipmentClass = getDefinitionByName("Classes." + item.className) as Class;
            itemName = Global.farmGameSettingsManager.getFarmItemNameByCode(code);
            numParts++;
            equipment = new equipmentClass(itemName,false,numParts);
            StatsManager.milestone("place_item_in_vehicle_first_time");
            allLevels = EquipmentSettingsManager.getInstance().getAllLevelsByItemCode(equipment.getItem().code);
            for each(level in allLevels)
            {
               if(numParts == level.partsNeeded)
               {
                  FarmStatsManager.count("Garage","Upgrade","upgrade_level_" + level.id,equipment.getItem().name);
                  StatsManager.milestone("vehicle_upgrade_first_time");
                  break;
               }
            }
            this.addItem(equipment,0,false,false);
            TransactionManager.addTransaction(new TAddPartToEquipmentInGarage(this.getId(),key,isGift));
         }
      }
      
      override public function getStorageKey(object:Object) : String
      {
         return object.itemCode + ":" + object.numParts;
      }
      
      override public function getStorageKeyFromMapResource(resource:MapResource) : String
      {
         var code:String = Global.farmGameSettingsManager.getFarmItemCodeByName(resource.getItemName());
         return this.getStorageKey({
            "itemCode":code,
            "numParts":(resource as Equipment).equipmentPartsCount
         });
      }
      
      override public function buildContainedItem(key:String) : Object
      {
         var data:Array = key.split(":");
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(data[0]);
         var realName:String = Global.farmGameSettingsManager.getFarmItemNameByCode(data[0]);
         return {
            "item":item,
            "code":data[0],
            "name":realName,
            "num":m_contents[key],
            "numParts":data[1]
         };
      }
      
      override public function displayStorageDialog(defaultAction:String = "") : void
      {
         UI.displayStorageDialog(new GarageStorageWithdrawal(this));
      }
      
      override protected function updateToolTipText() : void
      {
         var toolTip:String = null;
         toolTip = m_item.friendlyTitle;
         if(isHighlighted() && Global.worldManager.isVisiting() == false)
         {
            toolTip += "\n" + ZLocUtils.t("Items",m_item.name + "_mats",{
               "quantity":m_count,
               "maximum":capacity
            });
         }
         setToolTip(toolTip);
         updateToolTipPosition();
      }
      
      override public function showMenu() : void
      {
         super.showMenu();
      }
      
      public function hasGarageSpace() : Boolean
      {
         var _capacity:int = capacity;
         var usage:int = m_count;
         return usage < _capacity;
      }
      
      override public function sortMenu() : void
      {
         this.scanStorageInventory();
         if(this.m_hasTractor)
         {
            m_menuItems.push({
               "label":ZLocUtils.t("FarmGame","Plow"),
               "action":START_PLOW
            });
         }
         if(this.m_hasSeeder)
         {
            m_menuItems.push({
               "label":ZLocUtils.t("FarmGame","PlantSeeds"),
               "action":START_SEEDER
            });
         }
         if(this.m_hasHarvester)
         {
            m_menuItems.push({
               "label":ZLocUtils.t("FarmGame","Harvest"),
               "action":START_HARVESTER
            });
         }
         if(this.m_hasCombine)
         {
            m_menuItems.push({
               "label":ZLocUtils.t("FarmGame","Combine"),
               "action":START_COMBINE
            });
         }
         if(this.m_hasOrchardHarvester)
         {
            m_menuItems.push({
               "label":ZLocUtils.t("FarmGame","OrchardHarvester"),
               "action":START_ORCHARD_HARVESTER
            });
         }
         if(this.m_hasAnimalPenHarvester)
         {
            m_menuItems.push({
               "label":ZLocUtils.t("FarmGame","AnimalPenHarvester"),
               "action":START_ANIMAL_PEN_HARVESTER
            });
         }
         if(this.m_hasSprinkler)
         {
            m_menuItems.push({
               "label":ZLocUtils.t("FarmGame","IrrigationSprinkler"),
               "action":START_IRRIGATION_SPRINKLER
            });
         }
         if(this.m_hasPlotRemover)
         {
            m_menuItems.push({
               "label":ZLocUtils.t("FarmGame","PlotRemover"),
               "action":START_PLOTREMOVE
            });
         }
      }
      
      override public function sell() : void
      {
         var contentsArray:Array = new Array();
         contentsArray = getContents();
         if(contentsArray.length == 0)
         {
            super.sell();
         }
         else
         {
            UI.displayPopup(new GenericPopup(ZLocUtils.t("Dialogs","SellInventoryFail")));
         }
      }
      
      private function scanStorageInventory() : void
      {
         this.m_hasTractor = false;
         this.m_hasSeeder = false;
         this.m_hasHarvester = false;
         this.m_hasCombine = false;
         this.m_hasOrchardHarvester = false;
         this.m_hasAnimalPenHarvester = false;
         this.m_hasSprinkler = false;
         this.m_hasPlotRemover = false;
         this.m_hasRotTractor = false;
         this.m_hasRotSeeder = false;
         this.m_hasRotHarvester = false;
         this.m_hasRotCombine = false;
         this.m_hasRotOrchardHarvester = false;
         this.m_hasRotPlotRemover = false;
         var itemArray:Array = getContents();
         var arrLength:int = int(itemArray.length);
         for(var idx:int = 0; idx < arrLength; idx++)
         {
            if(itemArray[idx].item.className == "Tractor" || itemArray[idx].item.className == "RotatableTractor")
            {
               this.m_hasTractor = true;
            }
            if(itemArray[idx].item.className == "Seeder" || itemArray[idx].item.className == "RotatableSeeder")
            {
               this.m_hasSeeder = true;
            }
            if(itemArray[idx].item.className == "Harvester" || itemArray[idx].item.className == "RotatableHarvester")
            {
               this.m_hasHarvester = true;
            }
            if(itemArray[idx].item.className == "Combine" || itemArray[idx].item.className == "RotatableCombine")
            {
               this.m_hasCombine = true;
            }
            if(itemArray[idx].item.className == "OrchardHarvester" || itemArray[idx].item.className == "RotatableOrchardHarvester")
            {
               this.m_hasOrchardHarvester = true;
            }
            if(itemArray[idx].item.className == "AnimalPenHarvester")
            {
               this.m_hasAnimalPenHarvester = true;
            }
            if(itemArray[idx].item.className == "IrrigationSprinkler")
            {
               this.m_hasSprinkler = true;
            }
            if(itemArray[idx].item.className == "PlotRemover" || itemArray[idx].item.className == "RotatablePlotRemover")
            {
               this.m_hasPlotRemover = true;
            }
         }
      }
      
      public function getEquipment(className:Class = null) : Equipment
      {
         var result:Equipment = null;
         var compareParts:int = 0;
         var maxParts:int = 0;
         var storedEquipment:Array = this.getEquipmentObjects();
         var storedEquipmentLength:int = int(storedEquipment.length);
         for(var equipIdx:int = 0; equipIdx < storedEquipmentLength; equipIdx++)
         {
            if(storedEquipment[equipIdx] != null && (className == null || storedEquipment[equipIdx] is className))
            {
               compareParts = int(storedEquipment[equipIdx].equipmentPartsCount);
               if(compareParts >= maxParts)
               {
                  maxParts = compareParts;
                  result = storedEquipment[equipIdx];
               }
            }
         }
         return result;
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         var equipment:OrchardHarvester = null;
         var animalPenHarvester:AnimalPenHarvester = null;
         var sprinkler:IrrigationSprinkler = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            switch(item.action)
            {
               case START_PLOTREMOVE:
                  Global.world.addGameMode(new GMPlotRemover(this.getEquipment(PlotRemover) as PlotRemover),true);
                  break;
               case START_PLOW:
                  Global.world.addGameMode(new GMTractorPlow(this.getEquipment(Tractor) as Tractor),true);
                  break;
               case START_HARVESTER:
                  Global.world.addGameMode(new GMHarvester(this.getEquipment(Harvester) as Harvester),true);
                  break;
               case START_SEEDER:
                  Global.world.m_chosenSeeder = null;
                  if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_UX_COMBINE_MARKET_SEARCH) == 2)
                  {
                     UI.displaySeedSelectionMiniMarketDialog(this.getEligibleTerrainCodes(Seeder),UI.MARKET_LAUNCH_REFERENCE_SEEDER);
                  }
                  else
                  {
                     UI.displayMarketDialog("actionMenuSeeder","seed",UI.MARKET_LAUNCH_REFERENCE_SEEDER,"seeds",null,null,null,null,-1,this.getEligibleTerrainCodes(Seeder));
                  }
                  break;
               case START_COMBINE:
                  if(Global.player.getSeenFlag(CombineOnboardingWindow.SEEN_FLAG) == false)
                  {
                     UI.displayPopup(new CombineOnboardingWindow(),true);
                  }
                  Global.world.m_chosenSeeder = null;
                  if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_UX_COMBINE_MARKET_SEARCH) == 2)
                  {
                     UI.displaySeedSelectionMiniMarketDialog(this.getEligibleTerrainCodes(Combine),UI.MARKET_LAUNCH_REFERENCE_COMBINE);
                  }
                  else
                  {
                     UI.displayMarketDialog("combine_context_menu","seed",UI.MARKET_LAUNCH_REFERENCE_COMBINE,"seeds",null,null,null,null,-1,this.getEligibleTerrainCodes(Combine));
                  }
                  break;
               case START_ORCHARD_HARVESTER:
                  equipment = this.getEquipment(OrchardHarvester) as OrchardHarvester;
                  equipment.showSelectPatternWindow(Equipment.SOURCE_GARAGE);
                  break;
               case START_ANIMAL_PEN_HARVESTER:
                  animalPenHarvester = this.getEquipment(AnimalPenHarvester) as AnimalPenHarvester;
                  animalPenHarvester.showSelectPatternWindow(Equipment.SOURCE_GARAGE);
                  break;
               case START_IRRIGATION_SPRINKLER:
                  sprinkler = this.getEquipment(IrrigationSprinkler) as IrrigationSprinkler;
                  Global.world.addGameMode(new GMIrrigationSprinkler(sprinkler as IrrigationSprinkler));
                  break;
               default:
                  super.onMenuClick(event);
            }
         }
      }
      
      private function getEligibleTerrainCodes(className:Class) : Array
      {
         var terrainCodes:Array = null;
         var code:int = 0;
         var validTerrainTypes:Array = new Array();
         var storedEquipment:Array = this.getEquipmentObjects();
         var equipmentLen:int = int(storedEquipment.length);
         for(var equipIdx:int = 0; equipIdx < equipmentLen; equipIdx++)
         {
            if(storedEquipment[equipIdx] != null && storedEquipment[equipIdx] is className)
            {
               terrainCodes = storedEquipment[equipIdx].getSupportedTerrainCodes();
               for each(code in terrainCodes)
               {
                  validTerrainTypes.push(code);
               }
            }
         }
         return validTerrainTypes;
      }
      
      public function getEquipmentObject(key:String = "") : Equipment
      {
         var explodedKey:Array = null;
         var equipmentItem:FarmItem = null;
         var object:Object = null;
         var equipment:Equipment = null;
         if(key != "" && Boolean(m_contents[key]))
         {
            explodedKey = key.split(":");
            equipmentItem = Global.farmGameSettingsManager.getFarmItemByCode(explodedKey[0]);
            equipment = SavedObject.getInstance(equipmentItem.className) as Equipment;
            if(equipment)
            {
               object = {
                  "m_equipmentPartsCount":int(explodedKey[1]),
                  "position":{
                     "x":this.m_position.x + this.m_size.x - 1,
                     "y":this.m_position.y + this.m_size.y - 1,
                     "z":this.m_position.z + this.m_size.z - 1
                  },
                  "itemName":equipmentItem.name
               };
               equipment.loadObject(object);
               equipment.setSize(1,1,1);
               equipment.setOuter(Global.world);
               equipment.attachPosition();
            }
         }
         return equipment;
      }
      
      override public function isSellable() : Boolean
      {
         var sellable:Boolean = this.count == 0;
         if(!sellable)
         {
            UI.displayPopup(new GenericPopup(ZLocUtils.t("Dialogs","GarageCantSell")));
         }
         return sellable;
      }
      
      public function getEquipmentObjects() : Array
      {
         var contents:Array = null;
         var key:String = null;
         var equipmentObj:Equipment = null;
         var object:Object = null;
         if(this.m_equipmentContained == null)
         {
            this.m_equipmentContained = new Array();
            contents = this.getContents();
            for(key in contents)
            {
               if(contents[key].num > 0)
               {
                  equipmentObj = SavedObject.getInstance(contents[key].item.className) as Equipment;
                  if(equipmentObj)
                  {
                     object = {
                        "m_equipmentPartsCount":contents[key].numParts,
                        "position":{
                           "x":this.m_position.x + this.m_size.x - 1,
                           "y":this.m_position.y + this.m_size.y - 1,
                           "z":this.m_position.z + this.m_size.z - 1
                        },
                        "itemName":contents[key].item.name
                     };
                     equipmentObj.loadObject(object);
                     equipmentObj.setSize(1,1,1);
                     equipmentObj.setOuter(Global.world);
                     equipmentObj.attachPosition();
                     this.m_equipmentContained.push(equipmentObj);
                  }
               }
            }
         }
         return this.m_equipmentContained;
      }
      
      override public function loadObject(data:Object) : void
      {
         this.m_equipmentContained = null;
         super.loadObject(data);
      }
      
      override public function addItem(resource:MapResource, fromStorage:int = 0, isGift:Boolean = false, sendStoreItem:Boolean = true, force:Boolean = false) : Boolean
      {
         this.m_equipmentContained = null;
         return super.addItem(resource,fromStorage,isGift,sendStoreItem,force);
      }
      
      override public function removeContents(itemCode:String, itemCount:int = 1, itemParts:int = 0) : void
      {
         var item:FarmItem = null;
         var newItemCode:String = null;
         this.m_equipmentContained = null;
         var key:String = this.getStorageKey({
            "itemCode":itemCode,
            "numParts":itemParts
         });
         if(Global.flashHotParams["GARAGEBUILDING_CASH_ITEM_FIX"])
         {
            if(!(key in m_contents))
            {
               item = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
               newItemCode = "";
               if(item.cashCode == itemCode)
               {
                  newItemCode = item.code;
               }
               else
               {
                  newItemCode = item.cashCode;
               }
               key = this.getStorageKey({
                  "itemCode":newItemCode,
                  "numParts":itemParts
               });
            }
         }
         m_contents[key] -= itemCount;
         resetCount();
      }
      
      override public function setAmount(itemCode:String, amount:int) : void
      {
         this.m_equipmentContained = null;
         super.setAmount(itemCode,amount);
      }
      
      override protected function onBuilt() : void
      {
         this.m_equipmentContained = null;
         super.onBuilt();
      }
      
      public function getCurrentPartTotal() : int
      {
         var vehicle:Equipment = null;
         var base:int = 0;
         var total:int = 0;
         var allVehicles:Array = this.getEquipmentObjects();
         for each(vehicle in allVehicles)
         {
            base = Equipment.getNumPartsToPreviousLevel(vehicle.equipmentPartsCount,vehicle.getItem().code);
            total += vehicle.equipmentPartsCount - base;
         }
         return total;
      }
      
      public function getNextPartTotal() : int
      {
         var vehicle:Equipment = null;
         var base:int = 0;
         var next:int = 0;
         var total:int = 0;
         var allVehicles:Array = this.getEquipmentObjects();
         for each(vehicle in allVehicles)
         {
            base = Equipment.getNumPartsToPreviousLevel(vehicle.equipmentPartsCount,vehicle.getItem().code);
            next = Equipment.getNumPartsToNextLevel(vehicle.equipmentPartsCount,vehicle.getItem().code);
            if(next > 0)
            {
               total += next - base;
            }
         }
         return total;
      }
      
      override protected function showStorageContextMenu() : Boolean
      {
         return true;
      }
   }
}

