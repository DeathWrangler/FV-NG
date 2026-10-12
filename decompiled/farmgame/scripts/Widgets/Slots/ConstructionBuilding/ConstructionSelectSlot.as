package Widgets.Slots.ConstructionBuilding
{
   import Classes.BuildingPart;
   import Classes.GarageBuilding;
   import Classes.HalloweenCastleDuckulaBuilding;
   import Classes.HalloweenHauntedHouseBuilding;
   import Classes.StorageBuilding;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class ConstructionSelectSlot extends ZwSlotFrame
   {
      
      private const ICON_SIZE:Number = 50;
      
      private var m_storageBuilding:StorageBuilding = null;
      
      private var m_buildingPart:BuildingPart = null;
      
      private var m_addItemCallback:Function;
      
      private var m_mainWindow:FarmWindow;
      
      public function ConstructionSelectSlot(element:DisplayObject, addItemCallback:Function, mainWindow:FarmWindow)
      {
         this.m_addItemCallback = addItemCallback;
         this.m_mainWindow = mainWindow;
         super(element);
         addWidget(new FarmAnimatedButton(m_element.use_bt,this.onChoose));
         if(m_element.hasOwnProperty("useAll_bt"))
         {
            addWidget(new FarmAnimatedButton(m_element.useAll_bt,null),false);
         }
         addWidget(new ZwTextField(m_element.itemTitle_tf));
         addWidget(new ZwTextField(m_element.alive_tf));
         addWidget(new FarmIcon(m_element.icon));
      }
      
      override public function populate(data:Object) : void
      {
         var garage:GarageBuilding = null;
         var hauntedHouse:HalloweenHauntedHouseBuilding = null;
         var castleDuckula:HalloweenCastleDuckulaBuilding = null;
         super.populate(data);
         this.m_storageBuilding = data["building"];
         this.m_buildingPart = data["part"];
         var itemCode:String = this.m_buildingPart.getItem().code;
         var quantity:int = this.m_storageBuilding.getAmount(itemCode);
         var max:int = this.m_storageBuilding.getItemLimit(this.m_buildingPart.getItem());
         if(this.m_storageBuilding is GarageBuilding)
         {
            garage = this.m_storageBuilding as GarageBuilding;
            quantity = garage.getCurrentPartTotal();
            max = garage.getNextPartTotal();
         }
         var buildingField:ZwTextField = getWidget(m_element.itemTitle_tf) as ZwTextField;
         buildingField.text = ZLocUtils.tk_pk_asTitle(this.m_storageBuilding.getItemFriendlyName());
         if(this.m_storageBuilding is HalloweenHauntedHouseBuilding)
         {
            hauntedHouse = this.m_storageBuilding as HalloweenHauntedHouseBuilding;
            buildingField.text = ZLocUtils.tk_pk_asTitle(hauntedHouse.getItemShortName());
            max = hauntedHouse.getExpansionPartLimit(itemCode);
         }
         if(this.m_storageBuilding is HalloweenCastleDuckulaBuilding)
         {
            castleDuckula = this.m_storageBuilding as HalloweenCastleDuckulaBuilding;
            buildingField.text = ZLocUtils.tk_pk_asTitle(castleDuckula.getItemShortName());
            max = castleDuckula.getExpansionPartLimit(itemCode);
         }
         var quantityField:ZwTextField = getWidget(m_element.alive_tf) as ZwTextField;
         if(quantity > 0 || max > 0)
         {
            quantityField.text = ZLocUtils.t("Dialogs","ConstructionBuildingChooseJob_Quantity",{
               "quantity":quantity,
               "maximum":max
            });
         }
         var iconWidget:FarmIcon = getWidget(m_element.icon) as FarmIcon;
         var iconURL:String = this.m_storageBuilding.getBuildingIcon(false);
         iconWidget.loadIcon(iconURL);
         iconWidget.setIconSize(this.ICON_SIZE,this.ICON_SIZE);
      }
      
      override public function clearView() : void
      {
      }
      
      private function onChoose(event:Event) : void
      {
         this.m_addItemCallback(this.m_storageBuilding,this.m_buildingPart);
         this.m_mainWindow.close();
      }
   }
}

