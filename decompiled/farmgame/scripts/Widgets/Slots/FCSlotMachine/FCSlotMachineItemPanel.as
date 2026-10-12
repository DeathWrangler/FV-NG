package Widgets.Slots.FCSlotMachine
{
   import Classes.ZItem.FarmItem;
   import Engine.Managers.ErrorManager;
   import Managers.FarmStatsManager;
   import Widgets.Slots.LESlotMachine.LESlotMachineItemPanel;
   import flash.display.DisplayObject;
   
   public final class FCSlotMachineItemPanel extends LESlotMachineItemPanel
   {
      
      public function FCSlotMachineItemPanel(element:DisplayObject)
      {
         super(element);
      }
      
      override protected function getItemNameFromData(data:Object) : String
      {
         if(data.type == "item_grant")
         {
            return data.value as String;
         }
         return data.type as String;
      }
      
      override protected function displayIcon(data:Object) : void
      {
         var itemName:String = null;
         var item:FarmItem = null;
         var value:String = null;
         var type:String = data.type as String;
         var quantity:int = parseInt(data.quantity);
         var icon:String = "assets/dialogs/FV_Support/FV_FortuneWheel/FW_slotCow.png";
         switch(type)
         {
            case "cash":
               icon = "assets/dialogs/FV_Support/FV_FortuneWheel/FW_slotFC.png";
               break;
            case "turbo_charger":
               icon = "assets/consumables/consume_turboharvest_icon.png";
               break;
            case "coins":
               icon = "assets/consumables/consume_coins_icon.png";
               if(quantity == 1000000)
               {
                  icon = "assets/dialogs/FV_Support/FV_ScratchOff/icon_coins.png";
               }
               if(quantity == 2000000)
               {
                  icon = "assets/dialogs/FV_Support/FV_ScratchOff/icon_coins2.png";
               }
               break;
            case "coconuts":
               icon = "assets/consumables/consume_coconuts_icon.png";
               if(quantity == 100000)
               {
                  icon = "assets/dialogs/FV_Support/FV_SlotMachine/icon_coconuts1.png";
               }
               break;
            case "free_spin":
               icon = "assets/dialogs/FV_Support/FV_FCSlotMachine/FreeSpin_icon.png";
               break;
            case "item_grant":
               itemName = data.value as String;
               item = Global.farmGameSettingsManager.getFarmItemByName(itemName);
               if(m_iconMc != null && item != null)
               {
                  icon = item.iconRelativeUrl;
               }
               break;
            default:
               value = data.value ? data.value as String : "";
               ErrorManager.addError("Invalid slot item: " + type + " " + value);
               FarmStatsManager.count("slots","errors","invalid_reel_item",type,value);
         }
         m_iconMc.loadIcon(icon);
         m_iconMc.visible = true;
      }
      
      override protected function getItemCount(data:Object) : int
      {
         var type:String = data.type as String;
         var quantity:int = parseInt(data.quantity);
         if(type == "coins" && (quantity == 1000000 || quantity == 2000000))
         {
            quantity = 0;
         }
         if(type == "coconuts" && quantity == 100000)
         {
            quantity = 0;
         }
         return quantity;
      }
   }
}

