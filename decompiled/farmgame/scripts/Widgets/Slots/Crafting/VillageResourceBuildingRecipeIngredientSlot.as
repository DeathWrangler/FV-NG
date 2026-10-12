package Widgets.Slots.Crafting
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.crafting.CraftingInventoryStateV2;
   import Classes.util.ZLocUtils;
   import Managers.Crafting.CraftingManager;
   import Managers.FarmVillageManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.Crafting.VillageResourceBuildingWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class VillageResourceBuildingRecipeIngredientSlot extends ZwSlotFrame
   {
      
      private var m_parentWindow:VillageResourceBuildingWindow = null;
      
      private var m_buyButton:FarmAnimatedCashButton = null;
      
      private var m_icon:FarmIcon = null;
      
      private var m_requiredIngredientsTextField:ZwTextField = null;
      
      protected var m_data:Object = null;
      
      private var m_ingredientItem:FarmItem = null;
      
      private var m_checkMark:ZwWidget = null;
      
      public function VillageResourceBuildingRecipeIngredientSlot(element:DisplayObject, parentWindow:VillageResourceBuildingWindow)
      {
         this.m_parentWindow = parentWindow;
         super(element);
         if(m_element.hasOwnProperty("buy_bt"))
         {
            this.m_buyButton = addWidget(new FarmAnimatedCashButton(m_element.buy_bt,ZLocUtils.t_pk(ZLocConstants.DIALOG_UTIL_PKG,"Buy"),"0",this.onBuyButtonClick,false,false,true)) as FarmAnimatedCashButton;
         }
         if(m_element.hasOwnProperty("icon_mc"))
         {
            this.m_icon = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
            this.m_icon.setSmoothing(true);
         }
         if(m_element.hasOwnProperty("generic_tf"))
         {
            this.m_requiredIngredientsTextField = addWidget(new ZwTextField(m_element.generic_tf,"")) as ZwTextField;
         }
         if(m_element.hasOwnProperty("checkMark_mc"))
         {
            this.m_checkMark = addWidget(new ZwWidget(m_element.checkMark_mc)) as ZwWidget;
         }
      }
      
      override public function release() : void
      {
         this.m_parentWindow = null;
         this.m_ingredientItem = null;
         this.m_data = null;
         this.m_icon = null;
         this.m_buyButton = null;
         this.m_requiredIngredientsTextField = null;
         super.release();
      }
      
      override public function populate(data:Object) : void
      {
         var cashCost:int = 0;
         super.populate(data);
         this.m_data = data;
         if(Boolean(this.m_data) && Boolean(this.m_data.itemCode) && Boolean(this.m_data.quantityRequired) && Boolean(this.m_data.craftType))
         {
            this.m_ingredientItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_data.itemCode);
            if(this.m_ingredientItem)
            {
               cashCost = this.m_ingredientItem.cash;
               if(this.m_icon != null)
               {
                  this.m_icon.loadIcon(this.m_ingredientItem.icon);
                  this.m_icon.visible = true;
                  if(this.m_icon.tooltip)
                  {
                     this.m_icon.detachTooltip();
                  }
                  this.m_icon.attachTooltip(new FarmTextTooltip(FarmVillageManager.instance.getFindItemInBuildingString(this.m_ingredientItem.name)));
               }
               if(this.m_buyButton != null)
               {
                  this.m_buyButton.setAmountText(cashCost.toString());
                  this.m_buyButton.visible = true;
                  this.m_buyButton.enabled = true;
               }
               this.updateIngredientsInfo();
            }
         }
      }
      
      private function onBuyButtonClick(event:Event) : void
      {
         var inventoryState:CraftingInventoryStateV2 = Global.player.craftingState.inventoryState;
         var maxCapacity:Number = inventoryState.villageStorageMaxCapacity;
         var currentCapacity:Number = inventoryState.villageStorageCurrentCapacity;
         if(this.m_data)
         {
            if(currentCapacity + 1 <= maxCapacity)
            {
               CraftingManager.getInstance().onPurchaseBushel(this.m_data.itemCode);
               this.updateIngredientsInfo();
            }
            else
            {
               if(this.m_parentWindow)
               {
                  this.m_parentWindow.close();
               }
               FarmVillageManager.instance.onExpandStorage();
            }
         }
      }
      
      private function updateIngredientsInfo() : void
      {
         var required:int = 0;
         var have:int = 0;
         if(Boolean(this.m_ingredientItem) && Boolean(this.m_data))
         {
            required = int(this.m_data.quantityRequired);
            have = CraftingManager.getInstance().getInventoryCountHelper(this.m_data.itemCode,required,this.m_data.craftType);
            if(this.m_requiredIngredientsTextField != null)
            {
               this.m_requiredIngredientsTextField.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"IngredientStorageInventory",{
                  "curr":have.toString(),
                  "max":required.toString()
               });
               this.m_requiredIngredientsTextField.visible = true;
            }
            if(Boolean(this.m_checkMark) && have >= required)
            {
               this.m_checkMark.visible = true;
            }
         }
         if(this.m_parentWindow)
         {
            this.m_parentWindow.updateMakeOrGetAllButton();
         }
      }
   }
}

