package Widgets.Frames.Crafting
{
   import Classes.FeatureBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.FarmItemType;
   import Classes.crafting.MarketInventoryItem;
   import Classes.util.ZLocUtils;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   
   public class CraftingSiloInventoryFrame extends ZwFrame
   {
      
      private var m_building:FeatureBuilding = null;
      
      private var m_capacityFrame:ZwFrame = null;
      
      private var m_maxCapacity:ZwTextField = null;
      
      private var m_searchString:String = "";
      
      private var m_currentCapacity:ZwTextField = null;
      
      private var m_inventoryFrame:CraftingSiloInventorySlotFrame = null;
      
      private var m_locPrefix:String = "";
      
      public function CraftingSiloInventoryFrame(element:MovieClip, craftingSiloBuilding:FeatureBuilding, locPrefix:String, buyCallback:Function = null, shareCallback:Function = null, askCallback:Function = null)
      {
         super(element);
         this.m_building = craftingSiloBuilding;
         this.m_locPrefix = locPrefix;
         this.m_searchString = "";
         this.m_inventoryFrame = addWidget(new CraftingSiloInventorySlotFrame(this.m_building,element.slotsFrame_mc,this.m_locPrefix,this.createInventorySlotList(this.m_searchString),null,buyCallback,shareCallback,askCallback)) as CraftingSiloInventorySlotFrame;
         this.m_capacityFrame = addWidget(new ZwFrame(m_element.capacityMeter_mc),true) as ZwFrame;
         this.m_maxCapacity = this.m_capacityFrame.addWidget(new ZwTextField(m_element.capacityMeter_mc.capacity_tf,ZLocUtils.t("Crafting",this.m_locPrefix + "_MaxCapacity",{"quantity":Global.player.craftingState.inventoryState.craftingSiloMaxCapacity}))) as ZwTextField;
         this.m_currentCapacity = this.m_capacityFrame.addWidget(new ZwTextField(m_element.capacityMeter_mc.current_tf,ZLocUtils.t("Crafting",this.m_locPrefix + "_CurrentCapacity",{"quantity":Global.player.craftingState.inventoryState.craftingSiloCurrentCapacity}))) as ZwTextField;
      }
      
      public function refreshItemCount(itemCode:String) : void
      {
         this.m_maxCapacity.text = ZLocUtils.t("Crafting",this.m_locPrefix + "_MaxCapacity",{"quantity":Global.player.craftingState.inventoryState.craftingSiloMaxCapacity});
         this.m_currentCapacity.text = ZLocUtils.t("Crafting",this.m_locPrefix + "_CurrentCapacity",{"quantity":Global.player.craftingState.inventoryState.craftingSiloCurrentCapacity});
         this.m_inventoryFrame.refreshItemCount(itemCode);
      }
      
      public function refresh() : void
      {
         this.m_inventoryFrame.refresh();
      }
      
      public function refreshBuyButtons() : void
      {
         this.m_inventoryFrame.refreshBuyButtons();
      }
      
      public function updateSearchString(searchString:String) : void
      {
         this.m_inventoryFrame.updateItems(this.createInventorySlotList(searchString));
      }
      
      public function createInventorySlotList(searchString:String) : Array
      {
         var eachItem:FarmItem = null;
         var object:Object = null;
         var eachSiloInventoryItem:MarketInventoryItem = null;
         var inventorySlotList:Array = new Array();
         var siloItems:Array = this.getAllCraftingSiloBushelItems();
         var found:Boolean = false;
         for each(eachItem in siloItems)
         {
            found = false;
            object = new Object();
            for each(eachSiloInventoryItem in Global.player.craftingState.inventoryState.craftingSiloItems)
            {
               if(searchString != "")
               {
                  object.localizedName = eachSiloInventoryItem.friendlyName;
                  if(object.localizedName.search(searchString) != -1)
                  {
                     inventorySlotList.push(eachSiloInventoryItem);
                  }
               }
               else if(eachSiloInventoryItem.itemCode == eachItem.code)
               {
                  found = true;
                  inventorySlotList.push(eachSiloInventoryItem);
                  break;
               }
            }
            if(!found)
            {
               if(searchString != "")
               {
                  object = new Object();
                  object.localizedName = Global.farmGameSettingsManager.getFarmItemByName(eachItem.name).friendlyName;
                  if(object.localizedName.search(searchString) != -1)
                  {
                     inventorySlotList.push(new MarketInventoryItem(eachItem.code,0,0,0,eachItem));
                  }
               }
               else
               {
                  inventorySlotList.push(new MarketInventoryItem(eachItem.code,0,0,0,eachItem));
               }
            }
            inventorySlotList.sort(MarketInventoryItem.compareFriendlyName);
         }
         return inventorySlotList;
      }
      
      public function getAllCraftingSiloBushelItems() : Array
      {
         var eachType:String = null;
         var eachSubType:String = null;
         var farmItems:Array = null;
         var eachItem:FarmItem = null;
         var output:Array = new Array();
         var craftSiloItemTypes:Array = new Array(FarmItemType.BUSHEL);
         var craftSiloItemSubTypes:Array = new Array(FarmItemType.ANIMAL,FarmItemType.TREE);
         for each(eachType in craftSiloItemTypes)
         {
            for each(eachSubType in craftSiloItemSubTypes)
            {
               farmItems = Global.farmGameSettingsManager.getFarmItemsArrayByType(eachType,eachSubType);
               for each(eachItem in farmItems)
               {
                  output[eachItem.code] = eachItem;
               }
            }
         }
         return output;
      }
   }
}

