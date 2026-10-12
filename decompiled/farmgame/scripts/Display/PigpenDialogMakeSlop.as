package Display
{
   import Classes.ItemType;
   import Classes.PigpenBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.crafting.MarketInventoryItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Managers.Crafting.CraftingManager;
   import Managers.FarmStatsManager;
   import Transactions.TMakeSlop;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmTabButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Managers.ZwToggleManager;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Core.Toggles.ZwVisibilityToggle;
   import Widgets.Frames.Crafting.CraftingInventorySlotFrame;
   import Widgets.Slots.Crafting.CraftingInventorySlot;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   
   public class PigpenDialogMakeSlop extends FarmWindow
   {
      
      private var m_pigpen:PigpenBuilding;
      
      protected var m_allCategoriesButton:FarmTabButton;
      
      protected var m_allCategoriesFrame:CraftingInventorySlotFrame;
      
      protected var m_fruitCategoryButton:FarmTabButton;
      
      protected var m_fruitCategoryFrame:CraftingInventorySlotFrame;
      
      protected var m_vegetableCategoryButton:FarmTabButton;
      
      protected var m_vegetableCategoryFrame:CraftingInventorySlotFrame;
      
      protected var m_grainCategoryButton:FarmTabButton;
      
      protected var m_grainCategoryFrame:CraftingInventorySlotFrame;
      
      protected var m_flowerCategoryButton:FarmTabButton;
      
      protected var m_flowerCategoryFrame:CraftingInventorySlotFrame;
      
      protected var m_miscCategoryButton:FarmTabButton;
      
      protected var m_miscCategoryFrame:CraftingInventorySlotFrame;
      
      protected var m_toggleManager:ZwToggleManager;
      
      protected var m_currentCapacity:ZwTextField;
      
      protected var m_emptyControls:ZwFrame;
      
      protected var m_emptyTextField:ZwTextField;
      
      protected var m_emptyButton:FarmAnimatedTextButton;
      
      public function PigpenDialogMakeSlop(pigpen:PigpenBuilding, windowAssetRelUrl:String = "assets/dialogs/FV_Bushels.swf", modal:Boolean = true, bAddClickBlocker:Boolean = true)
      {
         super(windowAssetRelUrl,modal,bAddClickBlocker);
         this.m_pigpen = pigpen;
         if(Global.player.craftingState.inventoryState.currentCapacity <= 0)
         {
            FarmStatsManager.count("pigpen","myPigs","clickMakeslop","noBushelsAvailable");
         }
         else
         {
            FarmStatsManager.count("pigpen","myPigs","clickMakeslop","bushelsAvailable");
         }
      }
      
      private function getOutOfBushelsButtonText() : String
      {
         var pCraftMan:CraftingManager = CraftingManager.getInstance();
         if(pCraftMan.getPlacedMarketStalls() > 0)
         {
            return ZLocUtils.t("Dialogs","PigpenBuilding_MakeSlop_OutOfBushels_HaveStall_Body");
         }
         if(pCraftMan.getMarketStallsInGiftBox() > 0)
         {
            return ZLocUtils.t("Dialogs","PigpenBuilding_MakeSlop_OutOfBushels_HaveGift_Body");
         }
         return ZLocUtils.t("Dialogs","PigpenBuilding_MakeSlop_OutOfBushels_BuyOne_Body");
      }
      
      private function onEmptyInventoryClicked(evt:Event) : void
      {
         if(this.m_pigpen)
         {
            this.m_pigpen.onButtonClickMakeSlopIsOutOfBushels();
         }
         close();
      }
      
      override protected function postLoadComplete() : void
      {
         var hasMissingMarketStall:Boolean = Global.player.getSeenFlag("MissingMarketStall");
         if(!hasMissingMarketStall && CraftingManager.getInstance().getPlacedMarketStalls() == 0)
         {
            Global.player.setSeenFlag("MissingMarketStall");
            UI.displayPopup(new GenericIconPopup(ZLocUtils.t("Crafting","MissingMarketStallDialog_Message"),GenericPopup.TYPE_OK,null,Global.getAssetURL("assets/farmers_market/fmarket_multicolorbellpeppers_full_icon.png")));
         }
         this.m_toggleManager = new ZwToggleManager();
         addWidget(new ZwTextField(m_window.categoryTitle_tf,ZLocUtils.t("Dialogs","PigpenBuilding_MakeSlop_Title")));
         addWidget(new ZwTextField(m_window.capacity_tf,ZLocUtils.t("Crafting","SiloInventoryDialog_MaxCapacity",{"quantity":Global.player.craftingState.inventoryState.maxCapacity})));
         this.m_currentCapacity = addWidget(new ZwTextField(m_window.current_tf,ZLocUtils.t("Crafting","SiloInventoryDialog_CurrentCapacity",{"quantity":Global.player.craftingState.inventoryState.currentCapacity}))) as ZwTextField;
         m_window.tabs_mc.visible = true;
         this.m_allCategoriesButton = addWidget(new FarmTabButton(m_window.tabs_mc.tab1_mc,ZLocUtils.t("Crafting","SiloInventoryDialog_CategoryAll"))) as FarmTabButton;
         this.m_allCategoriesFrame = addWidget(new CraftingInventorySlotFrame(m_window.allCropsFrame_mc,Global.player.craftingState.inventoryState.marketStallItemsArray,null,this.getCallback_onCropUsed(),this.getCallback_onCropShared(),this.getCallback_onCropMake())) as CraftingInventorySlotFrame;
         this.m_allCategoriesFrame.visible = false;
         this.m_toggleManager.addToggle(new ZwVisibilityToggle(this.m_allCategoriesButton,this.m_allCategoriesFrame),true);
         this.m_fruitCategoryButton = addWidget(new FarmTabButton(m_window.tabs_mc.tab2_mc,ZLocUtils.t("Crafting","SiloInventoryDialog_CategoryFruit"))) as FarmTabButton;
         this.m_fruitCategoryFrame = addWidget(new CraftingInventorySlotFrame(m_window.fruitsCropsFrame_mc,Global.player.craftingState.inventoryState.getItemsBySubtype(ItemType.SUBTYPE_FRUIT),ItemType.SUBTYPE_FRUIT,this.getCallback_onCropUsed(),this.getCallback_onCropShared(),this.getCallback_onCropMake())) as CraftingInventorySlotFrame;
         this.m_fruitCategoryFrame.visible = false;
         this.m_toggleManager.addToggle(new ZwVisibilityToggle(this.m_fruitCategoryButton,this.m_fruitCategoryFrame));
         this.m_vegetableCategoryButton = addWidget(new FarmTabButton(m_window.tabs_mc.tab3_mc,ZLocUtils.t("Crafting","SiloInventoryDialog_CategoryVegetables"))) as FarmTabButton;
         this.m_vegetableCategoryFrame = addWidget(new CraftingInventorySlotFrame(m_window.vegetablesCropsFrame_mc,Global.player.craftingState.inventoryState.getItemsBySubtype(ItemType.SUBTYPE_VEGETABLE),ItemType.SUBTYPE_VEGETABLE,this.getCallback_onCropUsed(),this.getCallback_onCropShared(),this.getCallback_onCropMake())) as CraftingInventorySlotFrame;
         this.m_vegetableCategoryFrame.visible = false;
         this.m_toggleManager.addToggle(new ZwVisibilityToggle(this.m_vegetableCategoryButton,this.m_vegetableCategoryFrame));
         this.m_grainCategoryButton = addWidget(new FarmTabButton(m_window.tabs_mc.tab4_mc,ZLocUtils.t("Crafting","SiloInventoryDialog_CategoryGrains"))) as FarmTabButton;
         this.m_grainCategoryFrame = addWidget(new CraftingInventorySlotFrame(m_window.grainsCropsFrame_mc,Global.player.craftingState.inventoryState.getItemsBySubtype(ItemType.SUBTYPE_GRAIN),ItemType.SUBTYPE_GRAIN,this.getCallback_onCropUsed(),this.getCallback_onCropShared(),this.getCallback_onCropMake())) as CraftingInventorySlotFrame;
         this.m_grainCategoryFrame.visible = false;
         this.m_toggleManager.addToggle(new ZwVisibilityToggle(this.m_grainCategoryButton,this.m_grainCategoryFrame));
         this.m_flowerCategoryButton = addWidget(new FarmTabButton(m_window.tabs_mc.tab5_mc,ZLocUtils.t("Crafting","SiloInventoryDialog_CategoryFlowers"))) as FarmTabButton;
         this.m_flowerCategoryFrame = addWidget(new CraftingInventorySlotFrame(m_window.flowersCropsFrame_mc,Global.player.craftingState.inventoryState.getItemsBySubtype(ItemType.SUBTYPE_FLOWERS),ItemType.SUBTYPE_FLOWERS,this.getCallback_onCropUsed(),this.getCallback_onCropShared(),this.getCallback_onCropMake())) as CraftingInventorySlotFrame;
         this.m_flowerCategoryFrame.visible = false;
         this.m_toggleManager.addToggle(new ZwVisibilityToggle(this.m_flowerCategoryButton,this.m_flowerCategoryFrame));
         this.m_miscCategoryButton = addWidget(new FarmTabButton(m_window.tabs_mc.tab6_mc,ZLocUtils.t("Crafting","SiloInventoryDialog_CategoryMisc"))) as FarmTabButton;
         this.m_miscCategoryFrame = addWidget(new CraftingInventorySlotFrame(m_window.miscCropsFrame_mc,Global.player.craftingState.inventoryState.getItemsBySubtype(ItemType.SUBTYPE_MISC),ItemType.SUBTYPE_MISC,this.getCallback_onCropUsed(),this.getCallback_onCropShared(),this.getCallback_onCropMake())) as CraftingInventorySlotFrame;
         this.m_miscCategoryFrame.visible = false;
         this.m_toggleManager.addToggle(new ZwVisibilityToggle(this.m_miscCategoryButton,this.m_miscCategoryFrame));
         this.m_emptyControls = addWidget(new ZwFrame(m_window.getBushels_mc)) as ZwFrame;
         this.m_emptyTextField = this.m_emptyControls.addWidget(new ZwTextField(m_window.getBushels_mc.copy_tf,ZLocUtils.t("Dialogs","PigpenBuilding_MakeSlop_OutOfBushels_Text"))) as ZwTextField;
         this.m_emptyButton = this.m_emptyControls.addWidget(new FarmAnimatedTextButton(m_window.getBushels_mc.getBushels_bt,this.getOutOfBushelsButtonText(),this.onEmptyInventoryClicked)) as FarmAnimatedTextButton;
         this.m_emptyControls.visible = false;
         this.refreshCapacity();
      }
      
      private function getCallback_onCropUsed() : Function
      {
         return null;
      }
      
      private function getCallback_onCropShared() : Function
      {
         return null;
      }
      
      private function getCallback_onCropMake() : Function
      {
         return this.onCropMake;
      }
      
      private function onCropMake(slot:CraftingInventorySlot, item:FarmItem, data:MarketInventoryItem) : void
      {
         if(data.quantity <= 0)
         {
            return;
         }
         if(!this.m_pigpen.canAddSlop())
         {
            this.m_pigpen.openDialogSlopMaxSlop();
            return;
         }
         if(CraftingManager.getInstance().consumeBushelForPigpenSlop(data.itemCode))
         {
            this.m_pigpen.addSlop();
            TransactionManager.addTransaction(new TMakeSlop(this.m_pigpen,item.code));
         }
         this.refreshAll();
      }
      
      protected function refreshAll() : void
      {
         this.refreshCapacity();
         this.m_allCategoriesFrame.reload(Global.player.craftingState.inventoryState.marketStallItemsArray);
         this.m_flowerCategoryFrame.reload(Global.player.craftingState.inventoryState.getItemsBySubtype(ItemType.SUBTYPE_FLOWERS));
         this.m_fruitCategoryFrame.reload(Global.player.craftingState.inventoryState.getItemsBySubtype(ItemType.SUBTYPE_FRUIT));
         this.m_grainCategoryFrame.reload(Global.player.craftingState.inventoryState.getItemsBySubtype(ItemType.SUBTYPE_GRAIN));
         this.m_miscCategoryFrame.reload(Global.player.craftingState.inventoryState.getItemsBySubtype(ItemType.SUBTYPE_MISC));
         this.m_vegetableCategoryFrame.reload(Global.player.craftingState.inventoryState.getItemsBySubtype(ItemType.SUBTYPE_VEGETABLE));
      }
      
      protected function refreshCapacity() : void
      {
         var nCurCapacity:Number = Global.player.craftingState.inventoryState.currentCapacity;
         this.m_currentCapacity.text = ZLocUtils.t("Crafting","SiloInventoryDialog_CurrentCapacity",{"quantity":nCurCapacity});
         if(nCurCapacity <= 0)
         {
            m_window.tabs_mc.visible = false;
            this.m_allCategoriesFrame.visible = false;
            this.m_flowerCategoryFrame.visible = false;
            this.m_fruitCategoryFrame.visible = false;
            this.m_grainCategoryFrame.visible = false;
            this.m_miscCategoryFrame.visible = false;
            this.m_vegetableCategoryFrame.visible = false;
            this.m_emptyControls.visible = true;
         }
         else
         {
            m_window.tabs_mc.visible = true;
            this.m_emptyControls.visible = false;
         }
      }
      
      override protected function release() : void
      {
         this.m_pigpen = null;
         this.m_allCategoriesButton = null;
         this.m_allCategoriesFrame = null;
         this.m_fruitCategoryButton = null;
         this.m_fruitCategoryFrame = null;
         this.m_vegetableCategoryButton = null;
         this.m_vegetableCategoryFrame = null;
         this.m_grainCategoryButton = null;
         this.m_grainCategoryFrame = null;
         this.m_flowerCategoryButton = null;
         this.m_flowerCategoryFrame = null;
         this.m_miscCategoryButton = null;
         this.m_miscCategoryFrame = null;
         this.m_toggleManager = null;
         this.m_currentCapacity = null;
         super.release();
      }
   }
}

