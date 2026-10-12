package Widgets.Frames.Crafting
{
   import Classes.ItemType;
   import Classes.crafting.MarketInventoryItem;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmTabButton;
   import Widgets.Core.Constants.ZwToggleState;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class HomeMarketStallInventoryFrame extends ZwFrame
   {
      
      private var m_allCategoriesButton:FarmTabButton;
      
      private var m_fruitCategoryButton:FarmTabButton;
      
      private var m_vegetableCategoryButton:FarmTabButton;
      
      private var m_grainCategoryButton:FarmTabButton;
      
      private var m_flowerCategoryButton:FarmTabButton;
      
      private var m_miscCategoryButton:FarmTabButton;
      
      private var m_bushelInventoryFrame:CraftingInventorySlotFrame;
      
      private var m_category:String = null;
      
      private var m_capacityFrame:ZwFrame;
      
      private var m_currentCapacity:ZwTextField;
      
      private var m_emptyFrame:ZwFrame;
      
      public function HomeMarketStallInventoryFrame(element:MovieClip, useCallback:Function, shareCallback:Function)
      {
         super(element);
         this.m_capacityFrame = addWidget(new ZwFrame(m_element.capacityMeter_mc),false) as ZwFrame;
         this.m_capacityFrame.addWidget(new ZwTextField(m_element.capacityMeter_mc.capacity_tf,ZLocUtils.t("Crafting","HomeMarketStallDialog_MaxCapacity",{"quantity":Global.player.craftingState.inventoryState.maxCapacity})));
         this.m_currentCapacity = this.m_capacityFrame.addWidget(new ZwTextField(m_element.capacityMeter_mc.current_tf,ZLocUtils.t("Crafting","HomeMarketStallDialog_CurrentCapacity",{"quantity":Global.player.craftingState.inventoryState.currentCapacity}))) as ZwTextField;
         var tabs:ZwFrame = addWidget(new ZwFrame(m_element.tabs_mc)) as ZwFrame;
         this.m_allCategoriesButton = tabs.addWidget(new FarmTabButton(m_element.tabs_mc.tab1_mc,ZLocUtils.t("Crafting","MarketViewDialog_CategoryAll"),this.onAllClicked)) as FarmTabButton;
         this.m_fruitCategoryButton = tabs.addWidget(new FarmTabButton(m_element.tabs_mc.tab2_mc,ZLocUtils.t("Crafting","MarketViewDialog_CategoryFruit"),this.onFruitClicked)) as FarmTabButton;
         this.m_vegetableCategoryButton = tabs.addWidget(new FarmTabButton(m_element.tabs_mc.tab3_mc,ZLocUtils.t("Crafting","MarketViewDialog_CategoryVegetables"),this.onVegetableClicked)) as FarmTabButton;
         this.m_grainCategoryButton = tabs.addWidget(new FarmTabButton(m_element.tabs_mc.tab4_mc,ZLocUtils.t("Crafting","MarketViewDialog_CategoryGrains"),this.onGrainClicked)) as FarmTabButton;
         this.m_flowerCategoryButton = tabs.addWidget(new FarmTabButton(m_element.tabs_mc.tab5_mc,ZLocUtils.t("Crafting","MarketViewDialog_CategoryFlowers"),this.onFlowerClicked)) as FarmTabButton;
         this.m_miscCategoryButton = tabs.addWidget(new FarmTabButton(m_element.tabs_mc.tab6_mc,ZLocUtils.t("Crafting","MarketViewDialog_CategoryMisc"),this.onMiscClicked)) as FarmTabButton;
         this.m_bushelInventoryFrame = addWidget(new CraftingInventorySlotFrame(m_element.bushelInventorySlotFrame_mc,Global.player.craftingState.inventoryState.marketStallItemsArray,null,useCallback,shareCallback,null)) as CraftingInventorySlotFrame;
         this.m_emptyFrame = addWidget(new ZwFrame(m_element.emptyFrame_mc),false) as ZwFrame;
         this.m_emptyFrame.addWidget(new ZwTextField(m_element.emptyFrame_mc.generic_tf,ZLocUtils.t("Crafting","HomeMarketStallDialog_NoBushels")));
      }
      
      public function refresh() : void
      {
         var items:Array = null;
         if(this.m_category)
         {
            items = Global.player.craftingState.inventoryState.getItemsBySubtype(this.m_category);
         }
         else
         {
            items = Global.player.craftingState.inventoryState.marketStallItemsArray;
         }
         items.sort(MarketInventoryItem.compareFriendlyName);
         this.m_bushelInventoryFrame.reload(items);
         this.m_currentCapacity.text = ZLocUtils.t("Crafting","HomeMarketStallDialog_CurrentCapacity",{"quantity":Global.player.craftingState.inventoryState.currentCapacity});
         if(items.length > 0)
         {
            this.m_capacityFrame.visible = true;
            this.m_bushelInventoryFrame.visible = true;
            this.m_emptyFrame.visible = false;
         }
         else
         {
            this.m_capacityFrame.visible = false;
            this.m_bushelInventoryFrame.visible = false;
            this.m_emptyFrame.visible = true;
         }
      }
      
      public function updateSearchString(searchString:String) : void
      {
         this.m_bushelInventoryFrame.updateItems(searchString);
      }
      
      private function onAllClicked(evt:Event) : void
      {
         this.setCategory(null);
      }
      
      private function onFlowerClicked(evt:Event) : void
      {
         this.setCategory(ItemType.SUBTYPE_FLOWERS);
      }
      
      private function onFruitClicked(evt:Event) : void
      {
         this.setCategory(ItemType.SUBTYPE_FRUIT);
      }
      
      private function onGrainClicked(evt:Event) : void
      {
         this.setCategory(ItemType.SUBTYPE_GRAIN);
      }
      
      private function onMiscClicked(evt:Event) : void
      {
         this.setCategory(ItemType.SUBTYPE_MISC);
      }
      
      private function onVegetableClicked(evt:Event) : void
      {
         this.setCategory(ItemType.SUBTYPE_VEGETABLE);
      }
      
      private function setTabActive(category:String) : void
      {
         this.setTabButtonActive(this.m_allCategoriesButton,category == null);
         this.setTabButtonActive(this.m_flowerCategoryButton,category == ItemType.SUBTYPE_FLOWERS);
         this.setTabButtonActive(this.m_fruitCategoryButton,category == ItemType.SUBTYPE_FRUIT);
         this.setTabButtonActive(this.m_grainCategoryButton,category == ItemType.SUBTYPE_GRAIN);
         this.setTabButtonActive(this.m_miscCategoryButton,category == ItemType.SUBTYPE_MISC);
         this.setTabButtonActive(this.m_vegetableCategoryButton,category == ItemType.SUBTYPE_VEGETABLE);
      }
      
      private function setCategory(category:String) : void
      {
         this.setTabActive(category);
         this.m_category = category;
         this.refresh();
      }
      
      private function setTabButtonActive(button:FarmTabButton, active:Boolean) : void
      {
         if(active)
         {
            button.setToggleState(ZwToggleState.SELECTED);
         }
         else
         {
            button.setToggleState(ZwToggleState.DESELECTED);
         }
      }
      
      override public function release() : void
      {
         super.release();
         this.m_allCategoriesButton = null;
         this.m_fruitCategoryButton = null;
         this.m_vegetableCategoryButton = null;
         this.m_grainCategoryButton = null;
         this.m_flowerCategoryButton = null;
         this.m_miscCategoryButton = null;
         this.m_bushelInventoryFrame = null;
      }
   }
}

