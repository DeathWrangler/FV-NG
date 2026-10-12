package GameMode
{
   import Classes.BuildingItemUseMediator;
   import Classes.BuildingPart;
   import Classes.CombineChassisConstructionBuilding;
   import Classes.Constants.WorldsConstants;
   import Classes.Equipment;
   import Classes.GarageBuilding;
   import Classes.GarageConstructionBuilding;
   import Classes.StorageBuilding;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.ImpulseBuy;
   import Display.UI;
   import Engine.Classes.WorldObject;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Transactions.TGiftVehiclePart;
   import Widgets.Windows.ConstructionBuilding.ConstructionSelectWindow;
   import Widgets.Windows.Garage.GarageSelectionWindow;
   import flash.utils.Timer;
   
   public class GMVehicleUpgrade extends GMGiftReOpen
   {
      
      protected const SPARKLE_TIME:int = 2500;
      
      protected const BUYTEXT_OFFSET_X:int = 0;
      
      protected const BUYTEXT_OFFSET_Y:int = -40;
      
      protected var m_vehiclePart:BuildingPart;
      
      protected var m_oBuyPartData:Object = new Object();
      
      protected var m_timer:Timer = null;
      
      protected var m_garage:GarageBuilding = null;
      
      private var m_combineChassis:CombineChassisConstructionBuilding = null;
      
      protected var m_isBuildingGarage:Boolean;
      
      private var m_itemName:String;
      
      private var m_hasGarage:Boolean = false;
      
      private var m_hasGarageCanTakeParts:Boolean = false;
      
      private var m_hasGarageUnderConstruction:Boolean = false;
      
      private var m_hasCombineChassis:Boolean = false;
      
      public function GMVehicleUpgrade(itemName:String, isGift:Boolean = false)
      {
         this.m_itemName = itemName;
         this.m_vehiclePart = new BuildingPart(itemName);
         super(isGift);
      }
      
      override public function enableMode() : void
      {
         super.enableMode();
         this.searchWorldForTargetObjects();
         Global.world.popGameMode();
         if(this.m_hasGarageCanTakeParts && this.m_hasCombineChassis)
         {
            this.displayProjectChooseDialog();
         }
         else if(this.m_hasCombineChassis)
         {
            BuildingItemUseMediator.getInstance().mediate(this.m_itemName,m_isGift);
         }
         else if(this.m_hasGarage)
         {
            this.displayVehicleUpgradeChoicePopup();
         }
         else
         {
            this.displayBuyGarageDialog();
         }
      }
      
      private function searchWorldForTargetObjects() : void
      {
         var worldObject:WorldObject = null;
         var allVehicles:Array = null;
         var vehicle:Equipment = null;
         this.m_isBuildingGarage = false;
         var allObjects:Array = Global.world.getObjects();
         for each(worldObject in allObjects)
         {
            if(worldObject is GarageBuilding)
            {
               this.m_garage = worldObject as GarageBuilding;
               this.m_hasGarage = true;
            }
            else if(worldObject is GarageConstructionBuilding)
            {
               this.m_hasGarageUnderConstruction = true;
            }
            else if(worldObject is CombineChassisConstructionBuilding)
            {
               this.m_hasCombineChassis = true;
               this.m_combineChassis = worldObject as CombineChassisConstructionBuilding;
            }
         }
         if(this.m_hasGarage)
         {
            allVehicles = this.m_garage.getEquipmentObjects();
            for each(vehicle in allVehicles)
            {
               if(vehicle.equipmentPartsCount < Equipment.getMaxNumParts(vehicle.getItem().code))
               {
                  this.m_hasGarageCanTakeParts = true;
                  break;
               }
            }
         }
      }
      
      private function displayProjectChooseDialog() : void
      {
         var combineData:Array = null;
         var garageData:Array = null;
         var projectChoices:Array = new Array();
         if(this.m_hasCombineChassis)
         {
            combineData = new Array();
            combineData["building"] = this.m_combineChassis;
            combineData["part"] = this.m_vehiclePart;
            projectChoices.push(combineData);
         }
         if(this.m_hasGarage)
         {
            garageData = new Array();
            garageData["building"] = this.m_garage;
            garageData["part"] = this.m_vehiclePart;
            projectChoices.push(garageData);
         }
         UI.displayPopup(new ConstructionSelectWindow(projectChoices,this.m_vehiclePart.getItem(),this.onProjectChoose));
      }
      
      private function onProjectChoose(building:StorageBuilding, buildingPart:BuildingPart) : void
      {
         if(building is GarageBuilding)
         {
            this.displayVehicleUpgradeChoicePopup();
         }
         else
         {
            BuildingItemUseMediator.getInstance().mediate(this.m_itemName,m_isGift);
         }
      }
      
      private function displayVehicleUpgradeChoicePopup() : void
      {
         if(this.m_garage)
         {
            if(this.m_garage.getContents().length > 0)
            {
               if(this.m_isGift)
               {
                  UI.displayPopup(new GarageSelectionWindow(this.m_garage,this.m_vehiclePart.getItem(),this.addEquipmentPartToEquipment,this.m_isGift));
               }
               else
               {
                  UI.displayPopup(new GarageSelectionWindow(this.m_garage,this.m_vehiclePart.getItem(),this.openAreYouSureDialog,this.m_isGift));
               }
            }
            else if(m_isGift)
            {
               UI.displayPopup(new GenericPopup(ZLocUtils.t("Dialogs","GarageStoreBeforeUpgrade")));
            }
            else if(this.tryBuyPart(this.m_itemName))
            {
               TransactionManager.addTransaction(new TGiftVehiclePart());
               Global.player.addGift(this.m_itemName);
            }
         }
      }
      
      protected function addEquipmentPartToEquipment(equipmentKey:String, messageText:String = "", onAccept:Function = null, partName:String = "vehiclepart") : void
      {
         var nNumPartsBought:Number = NaN;
         var nDollarCost:Number = NaN;
         var floatingMessageText:String = null;
         if(this.tryBuyPart(partName))
         {
            this.m_garage.addPartToVehicle(equipmentKey,m_isGift);
            nNumPartsBought = 1;
            nDollarCost = Global.farmGameSettingsManager.getFarmItemByName(partName).cash;
            if(this.m_isGift)
            {
               floatingMessageText = ZLocUtils.t("Dialogs","GarageUpgradedCursorTextGift",{
                  "quantity":nNumPartsBought,
                  "part_word":ZLocUtils.tk("Dialogs","part_word","",nNumPartsBought)
               });
            }
            else
            {
               floatingMessageText = ZLocUtils.t("Dialogs","GarageUpgradedCursorText",{
                  "quantityA":nDollarCost,
                  "quantityB":nNumPartsBought,
                  "part_word":ZLocUtils.tk("Dialogs","part_word","",nNumPartsBought)
               });
            }
            if(this.m_oBuyPartData.mouseX == null)
            {
               this.m_oBuyPartData.mouseX = GlobalEngine.viewport.mouseX + this.BUYTEXT_OFFSET_X;
            }
            if(this.m_oBuyPartData.mouseY == null)
            {
               this.m_oBuyPartData.mouseY = GlobalEngine.viewport.mouseY + this.BUYTEXT_OFFSET_Y;
            }
            UI.displayStatus(floatingMessageText,this.m_oBuyPartData.mouseX,this.m_oBuyPartData.mouseY);
            if(onAccept != null)
            {
               onAccept();
            }
            else if(this.m_oBuyPartData.onAccept != null)
            {
               this.m_oBuyPartData.onAccept();
            }
         }
         if(m_isGift)
         {
            Global.player.removeGift(null,partName);
         }
      }
      
      protected function openAreYouSureDialog(equipmentKey:String, messageText:String = "", onAccept:Function = null, partName:String = "vehiclepart") : void
      {
         this.m_oBuyPartData.equipmentKey = equipmentKey;
         this.m_oBuyPartData.partName = partName;
         this.m_oBuyPartData.mouseX = GlobalEngine.viewport.mouseX + this.BUYTEXT_OFFSET_X;
         this.m_oBuyPartData.mouseY = GlobalEngine.viewport.mouseY + this.BUYTEXT_OFFSET_Y;
         this.m_oBuyPartData.onAccept = onAccept;
         if(messageText != null && messageText != "")
         {
            UI.displayPopup(new GenericPopup(messageText,GenericPopup.TYPE_ACCEPTCANCEL,this.buyPartConfirmationHandler,GenericPopup.GENERIC_ASSET,"",false,true),false);
         }
      }
      
      private function buyPartConfirmationHandler(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            this.addEquipmentPartToEquipment(this.m_oBuyPartData.equipmentKey,"",null,this.m_oBuyPartData.partName);
         }
         this.m_oBuyPartData.equipmentKey = null;
         this.m_oBuyPartData.partName = null;
         this.m_oBuyPartData.mouseX = -1;
         this.m_oBuyPartData.mouseY = -1;
         this.m_oBuyPartData.parentDialog = null;
      }
      
      protected function openMarket(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            UI.displayMiniMarketDialog([this.getGarageItemPrefix() + "garage"],"equipment","building",null);
         }
      }
      
      protected function getGarageItemPrefix() : String
      {
         var currentWorldType:String = Global.worldManager.currentWorldType;
         var garageItemPrefix:String = null;
         switch(currentWorldType)
         {
            case WorldsConstants.WORLD_ID_ENGLAND:
               garageItemPrefix = WorldsConstants.WORLD_ITEM_PREFIX_ENGLAND;
               break;
            case WorldsConstants.WORLD_ID_HOME:
               garageItemPrefix = WorldsConstants.WORLD_ITEM_PREFIX_HOME;
               break;
            default:
               garageItemPrefix = WorldsConstants.WORLD_ITEM_PREFIX_HOME;
         }
         return garageItemPrefix;
      }
      
      protected function tryBuyPart(partName:String) : Boolean
      {
         var price:int = 0;
         var result:Boolean = false;
         if(!m_isGift)
         {
            price = Global.farmGameSettingsManager.getFarmItemByName(partName).cash;
            if(Boolean(price) && Global.player.cash >= price)
            {
               Global.player.cash -= price;
               result = true;
            }
            else
            {
               UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_CASH,partName,price,Global.farmGameSettingsManager.getFarmItemByName(partName).type);
            }
         }
         else
         {
            result = true;
         }
         return result;
      }
      
      private function displayBuyGarageDialog() : void
      {
         var msg:String = null;
         var currentLevel:int = Global.player.level;
         if(this.m_isBuildingGarage)
         {
            msg = ZLocUtils.t("Dialogs","GarageNeedToFinish");
            UI.displayPopup(new GenericPopup(msg));
         }
         else
         {
            msg = ZLocUtils.t("Dialogs","GarageNeedToBuy");
            UI.displayPopup(new GenericPopup(msg,GenericPopup.TYPE_ACCEPTCANCEL,this.openMarket),false);
         }
      }
   }
}

