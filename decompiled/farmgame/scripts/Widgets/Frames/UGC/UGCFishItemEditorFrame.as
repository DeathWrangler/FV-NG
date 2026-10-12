package Widgets.Frames.UGC
{
   import Classes.UGC.IUGCMapResource;
   import Classes.UGC.UGCConstants;
   import Classes.UGC.UGCItemEditorTabConfig;
   import Classes.UGC.UGCItemLayerDefinition;
   import Classes.UGC.UGCItemLayerState;
   import Classes.UGC.UGCItemState;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.IUGCItem;
   import Classes.util.FarmGameUtil;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.StatsManager;
   import Engine.MathUtil;
   import Events.DynamicObjectEvent;
   import Managers.FeatureOptionsManager;
   import Widgets.Menu.FarmTabMenu;
   import Widgets.Menu.MenuItem;
   import flash.display.DisplayObject;
   
   public class UGCFishItemEditorFrame extends UGCItemEditorFrame
   {
      
      private var m_defaultFish:Boolean = true;
      
      public function UGCFishItemEditorFrame(element:DisplayObject, assetFrame:UGCItemPaintingFrame, ugcItem:IUGCItem, customizeItem:IUGCMapResource)
      {
         super(element,assetFrame,ugcItem,customizeItem);
         this.selectDefaultFish();
      }
      
      private function selectDefaultFish() : void
      {
         var layerDef:UGCItemLayerDefinition = null;
         var itemCode:String = null;
         for each(layerDef in m_ugcItemDef.layers)
         {
            if(layerDef.name != "body" && layerDef.itemNames.length >= 1)
            {
               itemCode = Global.farmGameSettingsManager.getFarmItemCodeByName(layerDef.itemNames[0]);
               m_ugcItemState.addLayerState(layerDef,new UGCItemLayerState(itemCode));
            }
         }
         this.onStateChange();
      }
      
      private function updateTypeToLayerMap() : void
      {
         var layer:UGCItemLayerDefinition = null;
         m_ugcItemDef = Global.farmGameSettingsManager.getUGCItemDefinition(m_ugcItem.ugcItemName);
         m_typeToLayerMap = {};
         for each(layer in m_ugcItemDef.layers)
         {
            if(m_typeToLayerMap[layer.type])
            {
               (m_typeToLayerMap[layer.type] as Array).push(layer);
            }
            else
            {
               m_typeToLayerMap[layer.type] = [layer];
            }
         }
      }
      
      override public function reset() : void
      {
         this.m_defaultFish = true;
         m_ugcItemState.reset();
         m_itemSelector.refresh();
         disablePaintMode();
         this.updateTypeToLayerMap();
         m_assetFrame.ugcItemDefinition = m_ugcItemDef;
         m_assetDelegate = (m_assetFrame.mapResource as IUGCMapResource).ugcDelegate;
         ugcItemState = UGCItemState.createFromDefinition(m_ugcItemDef);
         this.selectDefaultFish();
         StatsManager.count(UGCConstants.DREAM_FISH_KEYWORD + "_reset",m_ugcItem.farmItem.name);
      }
      
      override protected function createColorFrame() : void
      {
         m_colorFrame = new UGCFishColorMatrixFrame(m_element.color_mc,this);
         m_colorFrame.addEventListener(UGCConstants.EVENT_SELECT_COLOR,onColorClick);
         addWidget(m_colorFrame);
      }
      
      override protected function createItemLayerEditorFrame() : void
      {
         m_itemSelector = new UGCFishItemLayerEditorFrame(m_element.grid_mc,m_ugcItemState);
         m_itemSelector.addEventListener(UGCConstants.EVENT_SELECT_ITEM,this.onItemClick);
         addWidget(m_itemSelector);
      }
      
      override protected function createTabs() : void
      {
         var tabConfig:UGCItemEditorTabConfig = null;
         var defaultTabConfig:UGCItemEditorTabConfig = null;
         var tabConfigs:Array = m_ugcItemDef.editorConfig.tabs;
         var tabItems:Array = [];
         var defaultTabIdx:int = 0;
         var tabIdx:int = 0;
         var tabsLen:int = int(tabConfigs.length);
         while(tabIdx < tabsLen)
         {
            tabConfig = tabConfigs[tabIdx] as UGCItemEditorTabConfig;
            tabItems.push(createTabMenuItem(tabConfig,tabConfig.name));
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
      
      override protected function createSubTabs() : void
      {
      }
      
      override protected function selectTab(tab:UGCItemEditorTabConfig) : void
      {
         setInstructionsText(tab.name);
         var layers:Array = m_typeToLayerMap[tab.name] as Array;
         if(layers != null && layers.length > 0)
         {
            setItemSelectorLayer(layers[0]);
         }
      }
      
      override public function randomize() : void
      {
         var oldLayerState:UGCItemLayerState = null;
         var itemCode:String = null;
         var color:int = 0;
         var layerDef:UGCItemLayerDefinition = null;
         var itemName:String = null;
         disablePaintMode();
         var oldState:UGCItemState = m_ugcItemState.clone();
         var randomColor:uint = uint(MathUtil.randomElement(UGCConstants.COLOR_DATA_FISH_RANDOM).color);
         for each(layerDef in m_ugcItemDef.layers)
         {
            if(layerDef.isCustomizable())
            {
               itemCode = null;
               color = int(UGCConstants.COLOR_UNSET);
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
                              ErrorManager.addError("UGCFishItemEditorFrame#randomize item \'" + layerDef.itemNames[0] + "\' not found");
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
                           if(this.itemIsLocked(itemName))
                           {
                              itemCode = null;
                           }
                           if(itemCode == "")
                           {
                              ErrorManager.addError("UGCFishItemEditorFrame#randomize item \'" + itemName + "\' not found");
                              itemCode = null;
                           }
                        }
                        while(itemCode == null || oldLayerState != null && itemCode == oldLayerState.itemCode);
                     }
                  }
               }
               if(layerDef.isColorable)
               {
                  color = int(randomColor);
               }
               if(itemCode != null || color < UGCConstants.COLOR_UNSET)
               {
                  m_ugcItemState.addLayerState(layerDef,new UGCItemLayerState(itemCode,color));
                  if(Config.DEBUG_MODE)
                  {
                     if(!m_ugcItemState.isValid())
                     {
                        throw new Error("UGCFishItemEditorFrame#randomize caused invalid UGC item state!");
                     }
                  }
               }
            }
         }
         this.onStateChange();
         this.m_defaultFish = false;
         m_itemSelector.refresh();
         StatsManager.count(UGCConstants.DREAM_FISH_KEYWORD + "_randomize",m_ugcItem.farmItem.name,getSelectedItemNameForLayer(UGCConstants.LAYER_KEY_PATTERN),getSelectedItemNameForLayer(UGCConstants.LAYER_KEY_TAILS),getSelectedItemNameForLayer(UGCConstants.LAYER_KEY_FINS));
      }
      
      private function itemIsLocked(itemName:String) : Boolean
      {
         var marketPrereq:String = null;
         var isEAUser:Boolean = false;
         var dataFO:Boolean = false;
         var result:Boolean = false;
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         var startDate:String = item.limitedStartDate;
         if(Boolean(startDate) && FarmGameUtil.checkStartDateGate(startDate))
         {
            marketPrereq = item.marketPrereqName;
            isEAUser = item.checkMarketPrereqs();
            if(Boolean(marketPrereq) && isEAUser)
            {
               dataFO = FeatureOptionsManager.getInstance().getFeatureOption(UGCConstants.FO_AOE_LICENSE,item.aoeLicenseKey) as Boolean;
               if(dataFO)
               {
                  result = true;
               }
            }
         }
         return result;
      }
      
      override protected function onStateChange() : void
      {
         m_assetDelegate.refresh();
      }
      
      private function onTabClick(menuItem:MenuItem) : void
      {
         disablePaintMode();
         var tab:UGCItemEditorTabConfig = menuItem.data as UGCItemEditorTabConfig;
         if(tab != null)
         {
            this.selectTab(tab);
            StatsManager.count(UGCConstants.DREAM_FISH_KEYWORD + "_tab",tab.name);
         }
      }
      
      override protected function onItemClick(event:DynamicObjectEvent) : void
      {
         var layerState:UGCItemLayerState = null;
         var oldColor:uint = 0;
         disablePaintMode();
         var showPreview:Boolean = event.data.showPreview as Boolean;
         var layerDef:UGCItemLayerDefinition = event.data.layer as UGCItemLayerDefinition;
         var item:FarmItem = event.data.item as FarmItem;
         if(showPreview)
         {
            StatsManager.count(UGCConstants.DREAM_FISH_KEYWORD + "_preview",m_ugcItem.farmItem.name,item.name);
            dispatchEvent(new DynamicObjectEvent(UGCConstants.EVENT_PREVIEW_ITEM,{
               "layer":layerDef,
               "item":item
            }));
         }
         else if(item.checkPurchasePrereqs())
         {
            if(item is IUGCItem)
            {
               StatsManager.count(UGCConstants.DREAM_FISH_KEYWORD + "_choice","Body",item.name);
               dispatchEvent(new DynamicObjectEvent(UGCConstants.EVENT_REFRESH,item));
            }
            else
            {
               this.m_defaultFish = false;
               if(layerDef.isItemValid(item.name))
               {
                  layerState = m_ugcItemState.getLayerStateByDefinition(layerDef,false);
                  if(layerState != null)
                  {
                     oldColor = layerState.color;
                     layerState.itemCode = item.code;
                     layerState.color = oldColor;
                  }
                  else
                  {
                     layerState = new UGCItemLayerState(item.code);
                     m_ugcItemState.addLayerState(layerDef,layerState);
                  }
                  this.onStateChange();
                  StatsManager.count(UGCConstants.DREAM_FISH_KEYWORD + "_choice","",item.name);
               }
               else
               {
                  ErrorManager.addError("User selected item[name=" + item.name + "] is incompatible with layer[name=" + layerDef.name + "]");
               }
            }
         }
      }
      
      public function refreshItemSelector() : void
      {
         m_itemSelector.refresh();
      }
      
      public function isDefaultFish() : Boolean
      {
         return this.m_defaultFish;
      }
      
      override protected function onColorPainted(event:DynamicObjectEvent) : void
      {
         this.m_defaultFish = false;
         super.onColorPainted(event);
      }
   }
}

