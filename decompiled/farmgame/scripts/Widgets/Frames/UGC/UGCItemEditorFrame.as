package Widgets.Frames.UGC
{
   import Cache.Classes.ZCacheUtil;
   import Classes.UGC.IUGCMapResource;
   import Classes.UGC.UGCConstants;
   import Classes.UGC.UGCItemDefinition;
   import Classes.UGC.UGCItemEditorTabConfig;
   import Classes.UGC.UGCItemLayerDefinition;
   import Classes.UGC.UGCItemLayerState;
   import Classes.UGC.UGCItemState;
   import Classes.UGC.UGCResourceDelegate;
   import Classes.UGC.UGCUtil;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.IUGCItem;
   import Classes.ZItem.UGCDecorationItem;
   import Classes.util.ObjectUtil;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.StatsManager;
   import Engine.MathUtil;
   import Events.DynamicObjectEvent;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Managers.ZwActiveWidgetManager;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Menu.FarmTabMenu;
   import Widgets.Menu.MenuItem;
   import flash.display.DisplayObject;
   
   public class UGCItemEditorFrame extends ZwFrame
   {
      
      private static const COLOR_CHANCE:Number = 0.25;
      
      private static const SUBTAB_PREFIX:String = "subTabs";
      
      private static const SUBTAB_POSTFIX:String = "_mc";
      
      private static const SUBTAB_MIN:int = 2;
      
      private static const SUBTAB_MAX:int = 5;
      
      public static const STATS_PHYLUM_TAB:String = "open_tab";
      
      public static const STATS_PHYLUM_SELECT:String = "select_option";
      
      public static const STATS_PHYLUM_PREVIEW:String = "preview_option";
      
      public static var ztrack:Function = ZCacheUtil.applyPartial(StatsManager.count,null,[UGCConstants.STATS_COUNTER,UGCConstants.STATS_KINGDOM_CREATE]);
      
      private var m_subtabManager:ZwActiveWidgetManager;
      
      protected var m_frameManager:ZwActiveWidgetManager;
      
      protected var m_assetFrame:UGCItemPaintingFrame;
      
      protected var m_colorFrame:UGCColorMatrixFrame;
      
      protected var m_assetDelegate:UGCResourceDelegate;
      
      protected var m_nameHandleHash:Object;
      
      protected var m_instructions:ZwTextField;
      
      protected var m_itemSelector:UGCItemLayerEditorFrame;
      
      protected var m_ugcItemDef:UGCItemDefinition;
      
      protected var m_ugcItemState:UGCItemState;
      
      protected var m_ugcItem:IUGCItem;
      
      protected var m_typeToLayerMap:Object;
      
      private var m_typeToSubtabMenuMap:Object;
      
      private var m_customizeItem:IUGCMapResource = null;
      
      public function UGCItemEditorFrame(element:DisplayObject, assetFrame:UGCItemPaintingFrame, ugcItem:IUGCItem, customizeItem:IUGCMapResource)
      {
         var layer:UGCItemLayerDefinition = null;
         super(element);
         this.m_typeToSubtabMenuMap = {};
         this.m_subtabManager = new ZwActiveWidgetManager();
         this.m_frameManager = new ZwActiveWidgetManager();
         this.m_assetFrame = assetFrame;
         var ugcResource:IUGCMapResource = this.m_assetFrame.mapResource as IUGCMapResource;
         if(ugcResource == null)
         {
            throw new Error("MapResources used in the UGCItemEditor must implement IUGCMapResource. " + typeof this.m_assetFrame.mapResource + " does not.");
         }
         this.m_ugcItem = ugcItem;
         this.m_ugcItemDef = Global.farmGameSettingsManager.getUGCItemDefinition(ugcItem.ugcItemName);
         if(this.m_ugcItemDef == null)
         {
            throw new Error("Unable to find ugcItem definition for item named: " + ugcItem.ugcItemName);
         }
         this.m_assetFrame.ugcItemDefinition = this.m_ugcItemDef;
         this.m_assetFrame.addEventListener(UGCConstants.EVENT_PAINT_RESOURCE,this.onColorPainted);
         this.m_customizeItem = customizeItem;
         if(Boolean(this.m_customizeItem && this.m_customizeItem.ugcDelegate) && Boolean(this.m_customizeItem.ugcDelegate.ugcItemState) && this.m_customizeItem.getItem().name != "ugc_fish_gift")
         {
            this.m_ugcItemState = this.m_customizeItem.ugcDelegate.ugcItemState.clone();
         }
         else
         {
            this.m_ugcItemState = UGCItemState.createFromDefinition(this.m_ugcItemDef);
         }
         this.m_assetDelegate = ugcResource.ugcDelegate;
         this.m_assetDelegate.ugcItemState = this.m_ugcItemState;
         this.m_typeToLayerMap = {};
         for each(layer in this.m_ugcItemDef.layers)
         {
            if(this.m_typeToLayerMap[layer.type])
            {
               (this.m_typeToLayerMap[layer.type] as Array).push(layer);
            }
            else
            {
               this.m_typeToLayerMap[layer.type] = [layer];
            }
         }
         if(ObjectUtil.pathExists(m_element,"instructions_tf"))
         {
            this.m_instructions = new ZwTextField(m_element.instructions_tf,"");
            addWidget(this.m_instructions,false);
         }
         this.m_nameHandleHash = {};
         if(ObjectUtil.pathExists(m_element,"color_mc"))
         {
            this.createColorFrame();
         }
         if(ObjectUtil.pathExists(m_element,"grid_mc"))
         {
            this.createItemLayerEditorFrame();
         }
         this.createSubTabs();
         if(ObjectUtil.pathExists(m_element,"tabs_mc"))
         {
            this.createTabs();
         }
      }
      
      protected function createSubTabs() : void
      {
         var subtabName:String = null;
         var subtabMenu:FarmTabMenu = null;
         for(var subTabIdx:int = SUBTAB_MIN; subTabIdx <= SUBTAB_MAX; subTabIdx++)
         {
            subtabName = this.getSubtabName(subTabIdx);
            if(ObjectUtil.pathExists(m_element,subtabName))
            {
               subtabMenu = new FarmTabMenu(m_element[subtabName],this.onSubtabClick,null,true);
               addWidget(subtabMenu,false);
               this.m_subtabManager.addWidget(subtabMenu);
            }
         }
      }
      
      protected function createTabs() : void
      {
         var tabConfig:UGCItemEditorTabConfig = null;
         var defaultTabConfig:UGCItemEditorTabConfig = null;
         var tabConfigs:Array = this.m_ugcItemDef.editorConfig.tabs;
         var tabItems:Array = [];
         var defaultTabIdx:int = 0;
         var tabIdx:int = 0;
         var tabsLen:int = int(tabConfigs.length);
         while(tabIdx < tabsLen)
         {
            tabConfig = tabConfigs[tabIdx] as UGCItemEditorTabConfig;
            tabItems.push(this.createTabMenuItem(tabConfig,tabConfig.name));
            if(tabConfig.isDefault || tabIdx == 0)
            {
               defaultTabConfig = tabConfig;
               defaultTabIdx = tabIdx;
            }
            tabIdx++;
         }
         var tabs:FarmTabMenu = new FarmTabMenu(m_element.tabs_mc,this.onTabClick,tabItems);
         addWidget(tabs);
         tabs.selectTab(defaultTabIdx);
         this.selectTab(defaultTabConfig);
      }
      
      protected function createTabMenuItem(tabConfig:Object, name:String) : MenuItem
      {
         return new MenuItem(tabConfig,UGCUtil.t(this.m_ugcItem,name));
      }
      
      protected function createItemLayerEditorFrame() : void
      {
         this.m_itemSelector = new UGCItemLayerEditorFrame(m_element.grid_mc,this.m_ugcItemState);
         this.m_itemSelector.addEventListener(UGCConstants.EVENT_SELECT_ITEM,this.onItemClick);
         this.m_nameHandleHash["grid_mc"] = this.m_frameManager.addWidget(addWidget(this.m_itemSelector));
      }
      
      protected function createColorFrame() : void
      {
         this.m_colorFrame = new UGCColorMatrixFrame(m_element.color_mc);
         this.m_colorFrame.addEventListener(UGCConstants.EVENT_SELECT_COLOR,this.onColorClick);
         this.m_nameHandleHash["color_mc"] = this.m_frameManager.addWidget(addWidget(this.m_colorFrame,false));
      }
      
      public function get isCustomizing() : Boolean
      {
         return this.m_customizeItem != null;
      }
      
      public function setCustomizeItem(customizeItem:IUGCMapResource) : void
      {
         this.m_customizeItem = customizeItem as IUGCMapResource;
      }
      
      public function getCustomizeItem() : IUGCMapResource
      {
         return this.m_customizeItem;
      }
      
      public function getGameSettingsFeatureName() : String
      {
         return this.m_ugcItem.farmItem.gameSettingsFeatureName;
      }
      
      public function get totalCash() : int
      {
         var layerState:UGCItemLayerState = null;
         var cash:int = 0;
         if(!this.isCustomizing)
         {
            cash += this.m_ugcItem.farmItem.cash;
         }
         if(this.m_ugcItemState)
         {
            for each(layerState in this.m_ugcItemState.layers)
            {
               if(layerState.isCustomItem)
               {
                  cash += layerState.item.cash;
               }
            }
         }
         return cash;
      }
      
      public function getSelectedItemNameForLayer(layerKey:String) : String
      {
         var itemName:String = "";
         var layerState:UGCItemLayerState = this.m_ugcItemState.layers[layerKey];
         if(Boolean(layerState) && Boolean(layerState.item))
         {
            itemName = layerState.item.name;
         }
         else if(Boolean(layerState) && this.m_ugcItemState.hasItemCode())
         {
            itemName = Global.farmGameSettingsManager.getFarmItemNameByCode(this.m_ugcItemState.itemCode);
         }
         return itemName;
      }
      
      public function getTotalPriceInParts() : Object
      {
         var layerState:UGCItemLayerState = null;
         var price:Object = null;
         var result:Object = new Object();
         if(this.m_ugcItemState)
         {
            for each(layerState in this.m_ugcItemState.layers)
            {
               if(layerState.item)
               {
                  price = layerState.item.getMaterialPrice();
                  if(price)
                  {
                     result = this.mergeObjectsWithAddition(result,price);
                  }
               }
            }
         }
         return this.mergeObjectsWithAddition(result,(this.m_ugcItem as UGCDecorationItem).getMaterialPrice());
      }
      
      private function mergeObjectsWithAddition(obja:Object, objb:Object) : Object
      {
         var prop:String = null;
         var result:Object = new Object();
         for(prop in obja)
         {
            if(result.hasOwnProperty(prop))
            {
               result[prop] += obja[prop];
            }
            else
            {
               result[prop] = obja[prop];
            }
         }
         for(prop in objb)
         {
            if(result.hasOwnProperty(prop))
            {
               result[prop] += objb[prop];
            }
            else
            {
               result[prop] = objb[prop];
            }
         }
         return result;
      }
      
      public function get ugcItemState() : UGCItemState
      {
         return this.m_ugcItemState.clone();
      }
      
      public function set ugcItemState(value:UGCItemState) : void
      {
         if(this.m_ugcItemState != value && this.m_ugcItemDef.validateUGCItemState(value))
         {
            this.m_ugcItemState = value;
            this.m_assetDelegate.ugcItemState = value;
            this.m_itemSelector.ugcItemState = value;
            this.onStateChange();
         }
      }
      
      public function set ugcItem(value:IUGCItem) : void
      {
         this.m_ugcItem = value;
      }
      
      public function set assetFrame(value:UGCItemPaintingFrame) : void
      {
         this.m_assetFrame = value;
         this.m_assetFrame.addEventListener(UGCConstants.EVENT_PAINT_RESOURCE,this.onColorPainted);
      }
      
      override public function release() : void
      {
         if(this.m_colorFrame != null)
         {
            this.m_colorFrame.removeEventListener(UGCConstants.EVENT_SELECT_COLOR,this.onColorClick);
            this.m_colorFrame = null;
         }
         if(this.m_itemSelector != null)
         {
            this.m_itemSelector.removeEventListener(UGCConstants.EVENT_SELECT_ITEM,this.onItemClick);
            this.m_itemSelector = null;
         }
         if(this.m_assetFrame != null)
         {
            this.m_assetFrame.removeEventListener(UGCConstants.EVENT_PAINT_RESOURCE,this.onColorPainted);
         }
         super.release();
         this.m_assetFrame = null;
         this.m_ugcItemDef = null;
         this.m_ugcItem = null;
      }
      
      private function getSubtabName(idx:int) : String
      {
         return SUBTAB_PREFIX + idx + SUBTAB_POSTFIX;
      }
      
      protected function setInstructionsText(type:String) : void
      {
         var instKey:String = null;
         if(this.m_instructions)
         {
            if(type != null)
            {
               instKey = type + "_instructions";
               if(UGCUtil.hasString(this.m_ugcItem,instKey))
               {
                  this.m_instructions.text = UGCUtil.t(this.m_ugcItem,instKey);
                  this.m_instructions.visible = true;
               }
               else
               {
                  this.m_instructions.visible = false;
               }
            }
            else
            {
               this.m_instructions.visible = false;
            }
         }
      }
      
      protected function setItemSelectorLayer(ugcLayer:UGCItemLayerDefinition) : void
      {
         if(this.m_itemSelector != null)
         {
            this.m_itemSelector.ugcLayer = ugcLayer;
         }
         StatsManager.count(UGCConstants.STATS_COUNTER,"create_dialog","sees_tab",ugcLayer.name);
      }
      
      public function reset() : void
      {
         this.m_ugcItemState.reset();
         this.m_itemSelector.refresh();
         this.m_colorFrame.refresh();
         this.m_assetFrame.disablePainting();
         this.onStateChange();
      }
      
      public function disablePaintMode() : void
      {
         this.m_colorFrame.refresh();
         this.m_assetFrame.disablePainting();
      }
      
      public function randomize() : void
      {
         var oldLayerState:UGCItemLayerState = null;
         var itemCode:String = null;
         var color:uint = 0;
         var layerDef:UGCItemLayerDefinition = null;
         var itemName:String = null;
         var oldState:UGCItemState = this.m_ugcItemState.clone();
         this.m_ugcItemState.reset();
         for each(layerDef in this.m_ugcItemDef.layers)
         {
            if(layerDef.isCustomizable())
            {
               itemCode = null;
               color = UGCConstants.COLOR_UNSET;
               oldLayerState = oldState.getLayerStateByDefinition(layerDef,false);
               if(Math.random() < layerDef.randomizeChance)
               {
                  if(layerDef.isItemCustomizable)
                  {
                     if(layerDef.itemNames.length == 1)
                     {
                        if(oldLayerState == null)
                        {
                           itemCode = Global.farmGameSettingsManager.getFarmItemCodeByName(layerDef.itemNames[0]);
                           if(itemCode == "")
                           {
                              ErrorManager.addError("UGCItemEditorFrame#randomize item \'" + layerDef.itemNames[0] + "\' not found");
                              itemCode = null;
                           }
                        }
                     }
                     else
                     {
                        do
                        {
                           itemName = MathUtil.randomElement(layerDef.itemNames);
                           itemCode = Global.farmGameSettingsManager.getFarmItemCodeByName(itemName);
                           if(itemCode == "")
                           {
                              ErrorManager.addError("UGCItemEditorFrame#randomize item \'" + itemName + "\' not found");
                              itemCode = null;
                           }
                        }
                        while(itemCode == null || oldLayerState != null && itemCode == oldLayerState.itemCode);
                     }
                  }
                  if((layerDef.isItemCustomizable && itemCode != null || !layerDef.isItemCustomizable) && layerDef.isColorable && (itemCode == null || Math.random() < COLOR_CHANCE))
                  {
                     do
                     {
                        color = uint(MathUtil.randomElement(UGCConstants.COLOR_DATA).color);
                     }
                     while(oldLayerState != null && color == oldLayerState.color);
                  }
               }
               if(itemCode != null || color < UGCConstants.COLOR_UNSET)
               {
                  this.m_ugcItemState.addLayerState(layerDef,new UGCItemLayerState(itemCode,color));
                  if(Config.DEBUG_MODE)
                  {
                     if(!this.m_ugcItemState.isValid())
                     {
                        throw new Error("UGCItemEditorFrame#randomize caused invalid UGC item state!");
                     }
                  }
               }
            }
         }
         this.onStateChange();
         this.m_itemSelector.refresh();
      }
      
      protected function onStateChange() : void
      {
         this.m_assetDelegate.refresh();
         dispatchEvent(new DynamicObjectEvent(UGCConstants.EVENT_STATE_CHANGE));
      }
      
      private function onTabClick(menuItem:MenuItem) : void
      {
         var tab:UGCItemEditorTabConfig = menuItem.data as UGCItemEditorTabConfig;
         if(tab != null)
         {
            this.selectTab(tab);
            ztrack(STATS_PHYLUM_TAB,tab.name);
         }
         this.m_assetFrame.disablePainting();
      }
      
      protected function selectTab(tab:UGCItemEditorTabConfig) : void
      {
         var subtabMenu:FarmTabMenu = null;
         var subtabMenuItems:Array = null;
         var idx:uint = 0;
         var len:uint = 0;
         StatsManager.count(UGCConstants.STATS_COUNTER,"create_dialog","sees_tab",tab.name);
         this.setInstructionsText(tab.name);
         this.m_frameManager.selectWidget(this.m_nameHandleHash[tab.element]);
         if(tab.name == "body")
         {
            this.m_frameManager.selectWidget(0);
         }
         var layers:Array = this.m_typeToLayerMap[tab.name] as Array;
         if(layers != null && layers.length > 0)
         {
            this.setItemSelectorLayer(layers[0]);
            if(layers.length > 1)
            {
               if(layers.length > SUBTAB_MAX)
               {
                  throw new Error("Failure: configed number of tabs (of " + layers.length + " ) is > UGC SUBTAB_MAX (of " + SUBTAB_MAX + " ).");
               }
               subtabMenu = getWidget(this.getSubtabName(layers.length)) as FarmTabMenu;
               if(subtabMenu != null)
               {
                  subtabMenuItems = this.m_typeToSubtabMenuMap[tab.name] as Array;
                  if(subtabMenuItems == null)
                  {
                     subtabMenuItems = new Array(layers.length);
                     idx = 0;
                     len = layers.length;
                     while(idx < len)
                     {
                        subtabMenuItems[idx] = this.createTabMenuItem(layers[idx],tab.name + "_" + (layers[idx] as UGCItemLayerDefinition).name);
                        idx++;
                     }
                     this.m_typeToSubtabMenuMap[tab.name] = subtabMenuItems;
                  }
                  subtabMenu.items = subtabMenuItems;
                  this.m_subtabManager.selectWidget(layers.length - SUBTAB_MIN);
                  subtabMenu.selectTab(0);
               }
            }
            else
            {
               this.m_subtabManager.deselectAllWidgets();
            }
         }
         else
         {
            this.m_subtabManager.deselectAllWidgets();
         }
      }
      
      private function onSubtabClick(menuItem:MenuItem) : void
      {
         var layer:UGCItemLayerDefinition = menuItem.data as UGCItemLayerDefinition;
         this.setItemSelectorLayer(layer);
         ztrack(STATS_PHYLUM_TAB,layer.type,layer.name);
      }
      
      protected function onItemClick(event:DynamicObjectEvent) : void
      {
         var layerState:UGCItemLayerState = null;
         var layerDef:UGCItemLayerDefinition = event.data.layer as UGCItemLayerDefinition;
         var item:FarmItem = event.data.item as FarmItem;
         if(item.checkPurchasePrereqs())
         {
            ztrack(STATS_PHYLUM_SELECT,layerDef.type,item.name);
            if(item is IUGCItem)
            {
               dispatchEvent(new DynamicObjectEvent(UGCConstants.EVENT_REFRESH,item));
            }
            else if(layerDef.isItemValid(item.name))
            {
               layerState = this.m_ugcItemState.getLayerStateByDefinition(layerDef,false);
               if(layerState != null)
               {
                  if(layerState.itemCode == item.code)
                  {
                     this.m_ugcItemState.removeLayerState(layerDef,layerState);
                  }
                  else
                  {
                     layerState.itemCode = item.code;
                  }
               }
               else
               {
                  layerState = new UGCItemLayerState(item.code);
                  this.m_ugcItemState.addLayerState(layerDef,layerState);
               }
               this.onStateChange();
            }
            else
            {
               ErrorManager.addError("User selected item[name=" + item.name + "] is incompatible with layer[name=" + layerDef.name + "]");
            }
         }
      }
      
      protected function onColorClick(event:DynamicObjectEvent) : void
      {
         this.m_assetFrame.togglePainting(event.data.color);
      }
      
      protected function onColorPainted(event:DynamicObjectEvent) : void
      {
         var layerState:UGCItemLayerState = null;
         var color:uint = uint(event.data.color);
         var layerDef:UGCItemLayerDefinition = event.data.layerDef;
         if(layerDef.isColorable)
         {
            layerState = this.m_ugcItemState.getLayerStateByDefinition(layerDef,false);
            if(layerState != null)
            {
               if(color < UGCConstants.COLOR_UNSET)
               {
                  layerState.color = color;
               }
               else
               {
                  layerState.clearCustomColor();
               }
            }
            else if(color < UGCConstants.COLOR_UNSET)
            {
               layerState = new UGCItemLayerState(null,color);
               this.m_ugcItemState.addLayerState(layerDef,layerState);
            }
            this.onStateChange();
            StatsManager.count(UGCConstants.DREAM_FISH_KEYWORD + "_choice","Color",UGCUtil.getColorName(color),this.getSelectedItemNameForLayer(layerDef.layerKey));
         }
      }
   }
}

