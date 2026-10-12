package Widgets.Windows
{
   import Classes.FeatureBuilding;
   import Classes.ZItem.BuildingItem;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Frames.Breeding.StorageContentsSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.BloomContentsSlot;
   
   public class BloomContentsWindow extends StorageContentsWindow
   {
      
      public function BloomContentsWindow(building:FeatureBuilding)
      {
         super(building);
      }
      
      override protected function getFarmSlotContainerFrame() : FarmSlotContainerFrame
      {
         return new StorageContentsSlotFrame(m_window.blooms_mc,m_contents,this,BloomContentsSlot);
      }
      
      override protected function loadContents() : Array
      {
         var storageItem:BuildingItem = null;
         var item:Object = null;
         var fullBloom:Number = NaN;
         var newItem:Object = null;
         var numOwned:Number = NaN;
         var quantityKey:String = null;
         var hasFullBloom:Number = NaN;
         var hasSingleBloom:Number = NaN;
         var part1:Number = NaN;
         m_storageItems = Global.storageSettings.getStorageItems(m_building.getItem().storageClass,false,true);
         var farmItem:FarmItem = null;
         var gather:Array = new Array();
         var result:Array = new Array();
         var nonStoredItems:Array = new Array();
         for(var key:int = 0; key < m_storageItems.length; key++)
         {
            storageItem = m_storageItems[key] as BuildingItem;
            if(storageItem.className != "BuildingPart")
            {
               gather.push({
                  "code":storageItem.code,
                  "quantity":0,
                  "itemName":storageItem.name,
                  "name":storageItem.friendlyTitle,
                  "subType":storageItem.subType,
                  "buildingName":storageItem.buildingName,
                  "market":storageItem.canPurchase
               });
            }
         }
         gather.sortOn(["buildingName"],[Array.CASEINSENSITIVE]);
         var lastBuildingName:String = "";
         var lastItem:Object = {
            "owned":0,
            "quantity":0,
            "singleQuantity":0,
            "fullQuantity":0
         };
         for(var count:int = 0; count < gather.length; count++)
         {
            item = gather[count];
            fullBloom = Number(item["subType"] == "fullbloom");
            if(lastBuildingName != "" && item["buildingName"] != lastBuildingName)
            {
               result.push(lastItem);
               lastItem = {
                  "owned":0,
                  "quantity":0,
                  "singleQuantity":0,
                  "fullQuantity":0
               };
            }
            lastBuildingName = item["buildingName"];
            newItem = lastItem;
            if(!lastItem["name"] || fullBloom == 1)
            {
               newItem["itemName"] = item["itemName"];
               newItem["name"] = item["name"];
            }
            numOwned = Number(m_items[item["code"]]);
            numOwned = isNaN(numOwned) ? 0 : numOwned;
            newItem["quantity"] = lastItem["quantity"] + numOwned;
            quantityKey = fullBloom == 1 ? "fullQuantity" : "singleQuantity";
            newItem[quantityKey] += numOwned;
            newItem["bulb"] = lastItem["bulb"];
            newItem["singlebloom"] = lastItem["singlebloom"];
            newItem["fullbloom"] = lastItem["fullbloom"];
            if(!lastItem[item["subType"]])
            {
               newItem[item["subType"]] = item["code"];
            }
            if(item["subType"] == "singlebloom")
            {
               newItem["singleBlooms"] = numOwned;
            }
            else
            {
               newItem["singleBlooms"] = lastItem["singleBlooms"];
            }
            newItem["market"] = lastItem["market"] || item["market"];
            if(numOwned > 0)
            {
               hasFullBloom = fullBloom << fullBloom;
               hasSingleBloom = fullBloom == 0 ? 1 : 0;
               part1 = lastItem["owned"] | hasFullBloom;
               newItem["owned"] = part1 | hasSingleBloom;
            }
            else
            {
               newItem["owned"] = lastItem["owned"];
            }
            lastItem = newItem;
         }
         result.push(lastItem);
         var sortStyle:uint = uint(Array.NUMERIC | Array.DESCENDING);
         result.sortOn(["owned","quantity","market","name"],[sortStyle,sortStyle,sortStyle,Array.CASEINSENSITIVE]);
         return result;
      }
      
      override protected function initFeatureWidgets() : void
      {
         m_contentTab_bt = new FarmAnimatedTextButton(m_window.bloomsTab_mc,ZLocUtils.t("Dialogs","Bloom"),onShowContents);
         super.initFeatureWidgets();
      }
      
      override protected function openMiniMarket(runtimeVariableName:String, createWindow:Function) : void
      {
         UI.displayMiniMarketDialog([Global.flashHotParams[runtimeVariableName]],"Blooms","bloom",createWindow,true);
      }
   }
}

