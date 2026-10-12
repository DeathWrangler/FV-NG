package Classes
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Helpers.IntVector2;
   import Events.GenericPopupEvent;
   import Managers.EquipmentSettingsManager;
   import Managers.FarmGameSettingsManager;
   import Widgets.Windows.Equipment.SelectPatternWindow;
   import flash.events.MouseEvent;
   
   public class Equipment extends Decoration
   {
      
      public static const HORN:String = "horn";
      
      public static const VEHICLE_ACTION:String = "use_equipment";
      
      public static const SELECT_PATTERN_ACTION:String = "selectPattern";
      
      public static const SOURCE_ACTION_MENU:String = "action_menu";
      
      public static const SOURCE_CONTEXT_MENU:String = "context_menu";
      
      public static const SOURCE_GARAGE:String = "garage";
      
      private static var m_maxUpgradeParts:int = -1;
      
      protected var m_active:Boolean = false;
      
      protected var m_equipmentLevel:int = 0;
      
      protected var m_equipmentPartsCount:int = 0;
      
      protected var m_actionSize:IntVector2 = new IntVector2(EquipmentSettingsManager.DEFAULT_ACTION_X,EquipmentSettingsManager.DEFAULT_ACTION_Y);
      
      protected var m_resourceSize:IntVector2 = new IntVector2(EquipmentSettingsManager.DEFAULT_RESOURCE_X,EquipmentSettingsManager.DEFAULT_RESOURCE_Y);
      
      protected var m_garageBuildingItem:FarmItem;
      
      protected var m_garageBuilding:GarageBuilding;
      
      private var m_equipmentArray:Array = [IrrigationSprinkler];
      
      public function Equipment(itemName:String = null, active:Boolean = false, upgradeParts:Number = 0)
      {
         this.m_equipmentPartsCount = upgradeParts;
         super(itemName);
         if(itemName)
         {
            this.autoUpgradeHotRodTractor(itemName);
            this.setEquipmentLevel();
            this.setActionSize();
            this.setResourceSize();
         }
         this.m_active = active;
         this.m_garageBuildingItem = Global.farmGameSettingsManager.getFarmItemByName("garage");
         this.setGarageBuilding();
      }
      
      public static function getNumPartsToPreviousLevel(currentParts:int, itemCode:String) : int
      {
         var result:int = 0;
         var level:Object = EquipmentSettingsManager.getInstance().getLevelByPartCount(currentParts,itemCode);
         if(level)
         {
            result = int(level.partsNeeded);
         }
         return result;
      }
      
      public static function getNumPartsToNextLevel(currentParts:int, itemCode:String) : int
      {
         var result:int = 0;
         var level:Object = EquipmentSettingsManager.getInstance().getNextLevelByPartCount(currentParts,itemCode);
         if(level)
         {
            result = int(level.partsNeeded);
         }
         return result;
      }
      
      public static function getMaxNumParts(itemCode:String) : int
      {
         var result:int = 0;
         var level:Object = EquipmentSettingsManager.getInstance().getMaxLevel(itemCode);
         if(level)
         {
            result = int(level.partsNeeded);
         }
         return result;
      }
      
      public static function getCurrentLevel(currentParts:int, itemCode:String) : int
      {
         var result:int = 0;
         var level:Object = EquipmentSettingsManager.getInstance().getLevelByPartCount(currentParts,itemCode);
         if(level)
         {
            result = int(level.id);
         }
         return result;
      }
      
      public static function getRequiredUpgradeLevel(currentParts:int, itemCode:String) : int
      {
         var result:int = 0;
         var level:Object = EquipmentSettingsManager.getInstance().getNextLevelByPartCount(currentParts,itemCode);
         if(Boolean(level) && Boolean(level.minLevel))
         {
            result = int(level.minLevel);
         }
         return result;
      }
      
      public function get equipmentPartsCount() : int
      {
         return this.m_equipmentPartsCount;
      }
      
      public function get actionSizeArea() : int
      {
         return this.m_actionSize.x * this.m_actionSize.y;
      }
      
      override public function isUsingPerPixelPick() : Boolean
      {
         return true;
      }
      
      override public function getCurrentImageName() : String
      {
         var result:String = null;
         if(m_item.isBrandedItem && m_item.brandPromoData.isBrandPromoExpired)
         {
            if(this.m_active)
            {
               result = "expired_plowing";
            }
            else
            {
               switch(state)
               {
                  case "static":
                     result = "expired_static";
                     break;
                  default:
                     result = super.getCurrentImageName();
               }
            }
         }
         return result;
      }
      
      override protected function getCurrentImage() : ItemImage
      {
         var result:ItemImage = super.getCurrentImage();
         var imageName:String = null;
         if(result == null)
         {
            if(this.m_active)
            {
               imageName = "plowing";
            }
            else
            {
               imageName = super.getCurrentImageName();
            }
            result = m_item.getCachedImage(postProcessImageName(imageName));
         }
         return result;
      }
      
      override public function getSaveObject() : Object
      {
         var obj:Object = super.getSaveObject();
         obj.m_equipmentPartsCount = this.m_equipmentPartsCount;
         return obj;
      }
      
      override public function loadObject(data:Object) : void
      {
         super.loadObject(data);
         this.m_equipmentPartsCount = data.m_equipmentPartsCount;
         this.autoUpgradeHotRodTractor();
         this.setEquipmentLevel();
         this.setActionSize();
         this.setResourceSize();
      }
      
      private function autoUpgradeHotRodTractor(itemName:String = null) : void
      {
         var equipment:FarmItem = null;
         var actionSizeX:int = EquipmentSettingsManager.DEFAULT_ACTION_X;
         var actionSizeY:int = EquipmentSettingsManager.DEFAULT_ACTION_Y;
         var itemCode:String = null;
         if(m_item)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               actionSizeX = m_item.getIntFromDataSource("actionSizeX");
               actionSizeY = m_item.getIntFromDataSource("actionSizeY");
            }
            else if(m_item.xml)
            {
               actionSizeX = int(m_item.xml.actionSizeX);
               actionSizeY = int(m_item.xml.actionSizeY);
            }
            itemCode = m_item.code;
         }
         else if(itemName != null)
         {
            equipment = Global.farmGameSettingsManager.getFarmItemByName(itemName);
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               actionSizeX = equipment.getIntFromDataSource("actionSizeX");
               actionSizeY = equipment.getIntFromDataSource("actionSizeY");
            }
            else
            {
               actionSizeX = int(equipment.xml.actionSizeX);
               actionSizeY = int(equipment.xml.actionSizeY);
            }
            itemCode = equipment.code;
         }
         var minimumPartCount:int = EquipmentSettingsManager.getInstance().getPartCountByActionSize(actionSizeX,actionSizeY,itemCode);
         if(this.m_equipmentPartsCount < minimumPartCount)
         {
            this.m_equipmentPartsCount = minimumPartCount;
         }
      }
      
      private function setGarageBuilding() : void
      {
         this.m_garageBuilding = null;
         var objs:Array = Global.world.getObjects();
         for(var idx:int = 0; idx < objs.length; idx++)
         {
            if(objs[idx] is GarageBuilding)
            {
               this.m_garageBuilding = objs[idx];
            }
         }
      }
      
      override protected function getMenuItems() : Array
      {
         var menuArray:Array = new Array();
         var action:String = this.getItem().className;
         menuArray = [{
            "label":ZLocUtils.t("FarmGame","Move"),
            "action":MOVE_OBJECT
         },{
            "label":ZLocUtils.t("FarmGame","Sell"),
            "action":SELL_OBJECT
         },{
            "label":ZLocUtils.t("FarmGame",action),
            "action":VEHICLE_ACTION
         },{
            "label":ZLocUtils.t("FarmGame","Horn"),
            "action":HORN
         }];
         menuArray = this.getStoreOptions(menuArray);
         if(EquipmentSettingsManager.getInstance().hasPatterns(this.m_equipmentPartsCount,getItem().code))
         {
            menuArray.push({
               "label":ZLocUtils.t("FarmGame","ContextMenuSelectPattern"),
               "action":SELECT_PATTERN_ACTION
            });
         }
         return menuArray;
      }
      
      protected function getStoreOptions(menuArray:Array) : Array
      {
         var requiredLevel:int = 0;
         this.setGarageBuilding();
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            requiredLevel = this.m_garageBuildingItem.getIntFromDataSource("requiredLevel");
         }
         else
         {
            requiredLevel = int(this.m_garageBuildingItem.xml.requiredLevel);
         }
         var canSeeStorage:Boolean = requiredLevel <= Global.player.level;
         if(Boolean(canSeeStorage) && Boolean(this.m_garageBuilding) && this.m_garageBuilding.hasGarageSpace())
         {
            menuArray.push({
               "label":ZLocUtils.t("FarmGame","StoreVehicle"),
               "action":STORE_VEHICLE
            });
         }
         var canSeeUpgrade:Boolean = Equipment.getMaxNumParts(this.getItem().code) > this.m_equipmentPartsCount;
         if(Boolean(canSeeUpgrade) && Boolean(this.m_garageBuilding) && !Global.player.isGarageUnderConstruction())
         {
            menuArray.push({
               "label":ZLocUtils.t("FarmGame","UpgradeVehicle"),
               "action":UPGRADE_VEHICLE
            });
         }
         return menuArray;
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            switch(item.action)
            {
               case STORE_VEHICLE:
                  this.onStoreVehicle();
                  break;
               case UPGRADE_VEHICLE:
                  this.onUpgradeVehicle();
                  break;
               case VEHICLE_ACTION:
                  this.performEquipmentAction(Equipment.SOURCE_CONTEXT_MENU);
                  break;
               case SELECT_PATTERN_ACTION:
                  this.showSelectPatternWindow(Equipment.SOURCE_CONTEXT_MENU);
                  break;
               default:
                  super.onMenuClick(event);
            }
         }
      }
      
      public function performEquipmentAction(source:String = null) : void
      {
      }
      
      public function onNoGarageClose(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            UI.displayMiniMarketDialog(["garage"],"equipment","building",null);
         }
      }
      
      private function onUpgradeVehicle() : void
      {
         var placeInStorageMsg:String = null;
         var noGarageMsg:String = null;
         this.setGarageBuilding();
         if(Boolean(this.m_garageBuilding) && this.m_garageBuilding.hasGarageSpace())
         {
            placeInStorageMsg = ZLocUtils.t("Dialogs","GarageStoreBeforeUpgrade");
            UI.displayPopup(new GenericPopup(placeInStorageMsg,0));
         }
         else if(Boolean(this.m_garageBuilding) && this.m_garageBuilding.capacity == 0)
         {
            noGarageMsg = ZLocUtils.t("Dialogs","GarageUpgradeNoGarage");
            UI.displayPopup(new GenericPopup(noGarageMsg,2,this.onNoGarageClose));
         }
      }
      
      private function onStoreVehicle() : void
      {
         var objs:Array = null;
         var garage:GarageBuilding = null;
         var idx:int = 0;
         var garageFull:String = null;
         this.setGarageBuilding();
         if(Boolean(this.m_garageBuilding) && this.m_garageBuilding.hasGarageSpace())
         {
            if(Global.storageSettings.storageCanTake("garage",this))
            {
               objs = Global.world.getObjects();
               for(idx = 0; idx < objs.length; idx++)
               {
                  if(objs[idx] is GarageBuilding)
                  {
                     garage = objs[idx];
                  }
               }
               garage.addItem(this);
            }
         }
         else if(Boolean(this.m_garageBuilding) && this.m_garageBuilding.capacity == 20)
         {
            garageFull = ZLocUtils.t("Dialogs","GarageFull");
            UI.displayPopup(new GenericPopup(garageFull));
         }
      }
      
      private function setEquipmentLevel() : void
      {
         this.m_equipmentLevel = getCurrentLevel(this.m_equipmentPartsCount,this.getItem().code);
      }
      
      public function getActionCompareValue() : int
      {
         var actionSize:IntVector2 = this.getActionSize();
         return actionSize.x + actionSize.y;
      }
      
      protected function setActionSize() : void
      {
         var actionSizeX:int = EquipmentSettingsManager.DEFAULT_ACTION_X;
         var actionSizeY:int = EquipmentSettingsManager.DEFAULT_ACTION_Y;
         if(m_item)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               actionSizeX = m_item.getIntFromDataSource("actionSizeX");
               actionSizeY = m_item.getIntFromDataSource("actionSizeY");
            }
            else if(m_item.xml)
            {
               actionSizeX = int(m_item.xml.actionSizeX);
               actionSizeY = int(m_item.xml.actionSizeY);
            }
         }
         var actionSizeFromSettings:IntVector2 = EquipmentSettingsManager.getInstance().getActionSizeByPartCount(this.m_equipmentPartsCount,this.getItem().code);
         if(actionSizeFromSettings)
         {
            if(actionSizeFromSettings.x > actionSizeX)
            {
               actionSizeX = actionSizeFromSettings.x;
            }
            if(actionSizeFromSettings.y > actionSizeY)
            {
               actionSizeY = actionSizeFromSettings.y;
            }
         }
         this.m_actionSize = new IntVector2(actionSizeX,actionSizeY);
      }
      
      protected function setResourceSize() : void
      {
         this.m_resourceSize = EquipmentSettingsManager.getInstance().getResourceSize(getItem().code);
      }
      
      public function getActionSize() : IntVector2
      {
         return this.m_actionSize;
      }
      
      public function getResourceSize() : IntVector2
      {
         return this.m_resourceSize;
      }
      
      public function getEnergyCost() : Number
      {
         return 1;
      }
      
      override protected function updateToolTipText() : void
      {
         var notes:String = null;
         var toolTip:String = null;
         if(isHighlighted())
         {
            toolTip = ZLocUtils.tk_pk_asTitle(Global.farmGameSettingsManager.getUpgradedFriendlyName(m_item.friendlyName,this.m_equipmentLevel,this.getItem().code));
            notes = m_item.tooltipNotes;
            if(notes != "")
            {
               toolTip += "\n" + notes;
            }
         }
         setToolTip(toolTip);
         updateToolTipPosition();
      }
      
      public function attachPosition() : void
      {
         if(m_attachPosition == null)
         {
            m_attachPosition = m_position.clone();
         }
      }
      
      public function showSelectPatternWindow(source:String = null, assetPath:String = null) : void
      {
         var window:SelectPatternWindow = new SelectPatternWindow(this,source,assetPath);
         UI.displayPopup(window,false,"SelectPatternWindow",true);
      }
   }
}

