package Managers.InGameConsole
{
   import Classes.ZItem.FarmItem;
   import Classes.crafting.MarketInventoryItem;
   import Managers.Crafting.CraftingManager;
   import flash.utils.Dictionary;
   
   public final class ConsoleCraftingCommandsModule extends InGameConsoleBaseCommandsModule
   {
      
      public function ConsoleCraftingCommandsModule()
      {
         super();
      }
      
      override public function get moduleName() : String
      {
         return "craft";
      }
      
      public function addBushelToInventory(nameList:String, quantity:int = 1) : String
      {
         var name:String = null;
         var item:FarmItem = null;
         var output:String = "";
         var names:Array = nameList.replace(/\s/g,"").split(/,/g);
         var validNames:Array = [];
         for each(name in names)
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(name);
            if(item != null)
            {
               validNames.push(name);
               CraftingManager.getInstance().addItemToInventory(item.code,quantity);
               output += "Successfully adding " + quantity.toString() + " of the bushel \'" + name + "\' to your inventory\n";
            }
            else
            {
               output += "No bushel exists with the name: " + name;
            }
         }
         if(validNames.length > 0)
         {
            sendTransaction("adminCall",{
               "adminController":"CPanelCraftingController",
               "adminCommand":"addCraftingBushel",
               "bushelIds":validNames.join(","),
               "bushelQuantity":quantity.toString()
            });
         }
         return output;
      }
      
      public function removeAllLabBushels() : String
      {
         var bushel:MarketInventoryItem = null;
         var params:Object = null;
         var output:String = "removing all lab crafting bushels";
         var labBushels:Dictionary = Global.player.craftingState.inventoryState.labItems;
         for each(bushel in labBushels)
         {
            CraftingManager.getInstance().deductItemFromCraftingInventory(bushel.itemCode,bushel.quantity);
         }
         params = {
            "adminController":"CPanelCraftingController",
            "adminCommand":"removeAllLabBushels"
         };
         sendTransaction("adminCall",params);
         return output;
      }
      
      public function addAllLabBushels() : String
      {
         var bushel:FarmItem = null;
         var params:Object = null;
         var output:String = "adding 100 of each lab crafting bushel";
         var labBushels:Array = CraftingManager.getInstance().getAllCraftTypeBushelCodes(CraftingManager.BUSHEL_TYPE_LAB);
         for each(bushel in labBushels)
         {
            CraftingManager.getInstance().addItemToInventory(bushel.code,100);
         }
         params = {
            "adminController":"CPanelCraftingController",
            "adminCommand":"addAllLabBushels"
         };
         sendTransaction("adminCall",params);
         return output;
      }
      
      public function resetLabProgression() : String
      {
         var output:String = "resetting lab progression";
         var params:Object = {
            "adminController":"CPanelCraftingController",
            "adminCommand":"resetLabProgression"
         };
         sendTransaction("adminCall",params);
         return output;
      }
   }
}

