package Widgets.Slots.Garage
{
   import Classes.BuildingPart;
   import Classes.Equipment;
   import Classes.GarageBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.text.TextFormat;
   
   public class GarageSelectSlot extends ZwSlotFrame
   {
      
      private const ICON_SIZE:Number = 50;
      
      private const ITEMNAME_VEHICLEPART:String = "vehiclepart";
      
      private var m_garageBuilding:GarageBuilding = null;
      
      private var m_equipment:Equipment = null;
      
      private var m_equipmentKey:String = null;
      
      private var m_vehiclePart:BuildingPart = null;
      
      private var m_nPartsNeededToLevelUp:Number = 0;
      
      private var m_upgradeCallback:Function;
      
      private var m_chooseBtn:FarmAnimatedButton;
      
      private var m_chooseAllBtn:FarmAnimatedButton;
      
      private var m_mainWindow:FarmWindow;
      
      private var m_equipLevel:int;
      
      private var m_isGift:Boolean;
      
      public function GarageSelectSlot(element:DisplayObject, upgradeCallback:Function, mainWindow:FarmWindow, isGift:Boolean)
      {
         this.m_upgradeCallback = upgradeCallback;
         this.m_mainWindow = mainWindow;
         this.m_isGift = isGift;
         super(element);
         this.m_chooseBtn = new FarmAnimatedButton(m_element.use_bt,this.onChoose);
         addWidget(this.m_chooseBtn);
         if(m_element.useAll_bt)
         {
            this.m_chooseAllBtn = new FarmAnimatedButton(m_element.useAll_bt,this.onUseAll);
            addWidget(this.m_chooseAllBtn);
            this.m_chooseAllBtn.enabled = Global.player.getGiftCountForItem(this.ITEMNAME_VEHICLEPART) > 0;
         }
         addWidget(new ZwTextField(m_element.itemTitle_tf));
         addWidget(new ZwTextField(m_element.alive_tf));
         addWidget(new FarmIcon(m_element.icon));
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         var itemCode:String = Global.farmGameSettingsManager.getFarmItemCodeByName(data["name"]);
         this.m_equipmentKey = itemCode + ":" + data["numParts"];
         this.updateDisplayText();
         if(this.m_chooseAllBtn != null)
         {
            this.m_chooseAllBtn.visible = this.m_isGift;
         }
      }
      
      private function updateDisplayText() : void
      {
         var textFormat:TextFormat = null;
         var explodedKey:Array = this.m_equipmentKey.split(":");
         var itemCode:String = explodedKey[0] as String;
         var quantity:int = int(explodedKey[1]);
         var requiredLevel:int = Equipment.getRequiredUpgradeLevel(quantity,itemCode);
         var max:int = 0;
         var base:int = 0;
         if(Global.player.level >= requiredLevel)
         {
            max = Equipment.getNumPartsToNextLevel(quantity,itemCode);
            this.m_equipLevel = Equipment.getCurrentLevel(quantity,itemCode);
            base = Equipment.getNumPartsToPreviousLevel(quantity,itemCode);
            quantity -= base;
            max -= base;
         }
         if(quantity >= max)
         {
            this.m_chooseBtn.visible = false;
            if(this.m_chooseAllBtn)
            {
               this.m_chooseAllBtn.visible = false;
            }
         }
         else
         {
            this.m_chooseBtn.visible = true;
            if(this.m_chooseAllBtn)
            {
               this.m_chooseAllBtn.visible = true;
               this.m_chooseAllBtn.enabled = Global.player.getGiftCountForItem(this.ITEMNAME_VEHICLEPART) > 0;
            }
         }
         var equipmentItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
         var buildingField:ZwTextField = getWidget(m_element.itemTitle_tf) as ZwTextField;
         buildingField.text = ZLocUtils.tk_pk_asTitle(equipmentItem.friendlyName);
         var quantityField:ZwTextField = getWidget(m_element.alive_tf) as ZwTextField;
         if(Global.player.level < requiredLevel)
         {
            this.m_chooseBtn.visible = false;
            if(this.m_chooseAllBtn)
            {
               this.m_chooseAllBtn.visible = false;
            }
            textFormat = new TextFormat();
            textFormat.color = 16711680;
            quantityField.text = ZLocUtils.t("Dialogs","GarageVehicleLevelLocked",{"quantity":requiredLevel});
            quantityField.setTextFormat(textFormat);
         }
         else if(this.m_chooseBtn.visible)
         {
            quantityField.text = ZLocUtils.t("Dialogs","GarageBuildingChooseEquipment_Quantity",{
               "quantity":quantity,
               "quantityTotal":max
            });
         }
         else
         {
            quantityField.text = ZLocUtils.t("Dialogs","GarageFullyUpgradedVehicle");
         }
         this.m_nPartsNeededToLevelUp = max - quantity;
         var iconWidget:FarmIcon = getWidget(m_element.icon) as FarmIcon;
         var iconURL:String = equipmentItem.icon;
         iconWidget.loadIcon(iconURL);
         iconWidget.setIconSize(this.ICON_SIZE,this.ICON_SIZE);
      }
      
      override public function clearView() : void
      {
      }
      
      private function addToNumParts(add:Number = 1) : void
      {
         var explodedKey:Array = this.m_equipmentKey.split(":");
         var quantity:int = int(explodedKey[1]) + add;
         this.m_equipmentKey = explodedKey[0] + ":" + quantity;
         this.m_mainWindow.close();
      }
      
      private function onUseAll(event:Event) : void
      {
         var usableParts:int = Math.min(Global.player.getGiftCountForItem(this.ITEMNAME_VEHICLEPART),this.m_nPartsNeededToLevelUp);
         var confirmationDialog:GenericPopup = new GenericPopup("Do you want to use " + usableParts + " parts on this vehicle?",GenericPopup.TYPE_ACCEPTCANCEL,this.onUseAllClose);
         UI.displayPopup(confirmationDialog,false,"UseAllConfirmation",true);
      }
      
      private function onUseAllClose(event:GenericPopupEvent) : void
      {
         var i:int = 0;
         var usableParts:int = Math.min(Global.player.getGiftCountForItem(this.ITEMNAME_VEHICLEPART),this.m_nPartsNeededToLevelUp);
         var explodedKey:Array = this.m_equipmentKey.split(":");
         var equipmentItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(explodedKey[0] as String);
         var nDollarCost:Number = Global.farmGameSettingsManager.getFarmItemByName(this.ITEMNAME_VEHICLEPART).cash;
         if(event.button == GenericPopup.OK)
         {
            for(i = 0; i < usableParts; i++)
            {
               this.m_upgradeCallback(this.m_equipmentKey,"",this.addToNumParts);
            }
         }
      }
      
      private function onChoose(event:Event) : void
      {
         var currLevel:int = 0;
         var explodedKey:Array = this.m_equipmentKey.split(":");
         var equipmentItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(explodedKey[0] as String);
         var nDollarCost:Number = Global.farmGameSettingsManager.getFarmItemByName(this.ITEMNAME_VEHICLEPART).cash;
         var confirmMessageText:String = ZLocUtils.t("Dialogs","GarageConfirmBuyVehicleParts",{
            "quantity":this.m_nPartsNeededToLevelUp,
            "part_word":ZLocUtils.tk("Dialogs","part_word","",this.m_nPartsNeededToLevelUp),
            "item":ZLocUtils.tk_pk(equipmentItem.friendlyName),
            "cashQuantity":nDollarCost
         });
         if(Global.player.getGiftCountForItem(this.ITEMNAME_VEHICLEPART) > 0 || !this.m_isGift)
         {
            currLevel = Global.player.level;
            if(currLevel >= 26)
            {
               this.m_upgradeCallback(this.m_equipmentKey,confirmMessageText,this.addToNumParts);
            }
            else if(currLevel >= 22 && currLevel < 26 && this.m_equipLevel < 2)
            {
               this.m_upgradeCallback(this.m_equipmentKey,confirmMessageText,this.addToNumParts);
            }
            else
            {
               this.m_mainWindow.close();
               UI.displayPopup(new GenericPopup(ZLocUtils.t("Dialogs","GarageNeedToLevelUp")));
            }
         }
      }
   }
}

