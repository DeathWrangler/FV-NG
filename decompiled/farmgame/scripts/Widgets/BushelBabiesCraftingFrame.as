package Widgets
{
   import Classes.BushelBaby.BushelBabyOrderItem;
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.crafting.RecipeItem;
   import Classes.util.ZLocUtils;
   import Display.CraftingUI;
   import Display.ImpulseBuy;
   import Display.UI;
   import Managers.Crafting.CraftingManager;
   import Managers.ExchangeManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Slots.BushelBaby.BushelBabyCraftingIngredientSlot;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class BushelBabiesCraftingFrame extends FarmSlotContainerFrame
   {
      
      protected var m_currentOrderItem:BushelBabyOrderItem;
      
      protected var m_title:ZwTextField;
      
      private var m_icon:FarmIcon;
      
      protected var m_closeButton:FarmButton;
      
      protected var m_craftButton:FarmAnimatedTextButton;
      
      protected var m_getBushelsButton:FarmAnimatedTextButton;
      
      protected var m_buyIngredientsButton:FarmAnimatedCashButton;
      
      protected var m_recipeSlots:Vector.<BushelBabyCraftingIngredientSlot>;
      
      public function BushelBabiesCraftingFrame(element:DisplayObject)
      {
         var slotName:String = null;
         super(element);
         addWidget(this.m_title = new ZwTextField(m_element.title_mc),true);
         addWidget(this.m_icon = new FarmIcon(m_element.icon_mc),true);
         this.m_icon.clearScale();
         this.m_icon.setSmoothing(true);
         this.m_icon.attachTooltip(new FarmTextTooltip(""));
         addWidget(this.m_closeButton = new FarmButton(m_element.close_bt,this.onClose),true);
         addWidget(this.m_craftButton = new FarmAnimatedTextButton(m_element.make_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"MarketPromo_Title_CraftshopV3"),this.onCraft),true);
         addWidget(this.m_buyIngredientsButton = new FarmAnimatedCashButton(m_element.buyIngredients_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"BuyAllBushels"),"0",this.onBuyAllBushelPress,false,false,true),true);
         addWidget(this.m_getBushelsButton = new FarmAnimatedTextButton(m_element.getBushels_bt,ZLocUtils.t("Crafting","CraftingMain_GetBushels"),this.onGetBushels),true);
         this.m_recipeSlots = new Vector.<BushelBabyCraftingIngredientSlot>();
         var slotCount:int = 1;
         while(m_element.hasOwnProperty(slotName = "recipeSlotFull" + slotCount + "_mc") && slotCount < 10)
         {
            this.m_recipeSlots.push(addWidget(new BushelBabyCraftingIngredientSlot(m_element[slotName]) as BushelBabyCraftingIngredientSlot));
            slotCount++;
         }
      }
      
      public function get orderItem() : BushelBabyOrderItem
      {
         return this.m_currentOrderItem;
      }
      
      override public function release() : void
      {
         this.m_title = null;
         this.m_icon = null;
         this.m_closeButton = null;
         this.m_craftButton = null;
         this.m_getBushelsButton = null;
         this.m_buyIngredientsButton = null;
         this.m_recipeSlots = null;
         super.release();
      }
      
      public function show(item:BushelBabyOrderItem) : BushelBabiesCraftingFrame
      {
         visible = true;
         this.m_currentOrderItem = item;
         this.refresh();
         return this;
      }
      
      protected function setupView() : void
      {
         this.m_icon.visible = this.m_craftButton.visible = this.m_title.visible = true;
         m_element.getBushels_bt.counterCircle_mc.visible = m_element.getBushels_bt.counter_tf.visible = false;
         this.m_buyIngredientsButton.visible = this.m_getBushelsButton.visible = true;
      }
      
      override public function refresh() : void
      {
         var item:FarmItem = null;
         var recipe:RecipeItem = null;
         if(this.m_currentOrderItem)
         {
            this.setupView();
            item = this.m_currentOrderItem.item;
            this.m_icon.loadIcon(item.iconUrl);
            (this.m_icon.tooltip as FarmTextTooltip).setText(item.friendlyTitle);
            this.m_title.text = item.friendlyTitle;
            recipe = Global.craftConfigSettings.getRecipeById(item.name);
            if(Boolean(recipe) && Boolean(recipe.ingredients))
            {
               m_slotData = recipe.ingredients;
            }
            this.m_craftButton.enabled = this.canMake(recipe);
            this.setSlots(recipe);
            if(!this.m_craftButton.enabled)
            {
               this.m_getBushelsButton.enabled = this.m_buyIngredientsButton.enabled = true;
            }
            else
            {
               this.m_getBushelsButton.enabled = this.m_buyIngredientsButton.enabled = false;
               this.m_getBushelsButton.visible = this.m_buyIngredientsButton.visible = false;
            }
            if(this.m_buyIngredientsButton.getAmountText() != this.getBuyAllPrice().toString())
            {
               this.m_buyIngredientsButton.setAmountText(this.getBuyAllPrice().toString());
            }
         }
         super.refresh();
      }
      
      public function getRejectoinList() : Object
      {
         var data:Object = null;
         var items:Object = {};
         for each(data in m_slotData)
         {
            if(!data[RecipeItem.SWAPPABLE])
            {
               items[data[RecipeItem.ITEM_CODE]] = data[RecipeItem.QUANTITY_REQUIRED];
            }
         }
         return items;
      }
      
      private function canMake(recipe:RecipeItem) : Boolean
      {
         var data:Object = null;
         var itemCount:int = 0;
         var totalCount:int = 0;
         var count:int = 0;
         var result:Boolean = true;
         for(var i:int = 0; i < this.m_recipeSlots.length; i++)
         {
            if(i < this.m_recipeSlots.length)
            {
               data = m_slotData[i];
               if(!data)
               {
                  result = false;
                  break;
               }
               itemCount = CraftingManager.getInstance().getBushelQuantityInInventory(data[RecipeItem.ITEM_CODE]);
               totalCount = int(data[RecipeItem.QUANTITY_REQUIRED]);
               if(data[RecipeItem.SWAPPABLE])
               {
                  for each(count in this.m_recipeSlots[i].selectedItems)
                  {
                     totalCount -= count;
                  }
                  if(totalCount > 0)
                  {
                     result = false;
                     break;
                  }
               }
               else if(itemCount < totalCount)
               {
                  result = false;
                  break;
               }
            }
         }
         return result;
      }
      
      private function setSlots(recipe:RecipeItem) : void
      {
         var i:int = 0;
         if(m_slotData.length)
         {
            for(i = 0; i < this.m_recipeSlots.length; i++)
            {
               if(i < m_slotData.length)
               {
                  this.m_recipeSlots[i].visible = true;
                  this.m_recipeSlots[i].populate({
                     "recipe":recipe,
                     "data":m_slotData[i]
                  });
               }
               else
               {
                  this.m_recipeSlots[i].visible = false;
               }
            }
         }
      }
      
      private function onGetBushels(e:Event) : void
      {
         var recipe:RecipeItem = Global.craftConfigSettings.getRecipeById(this.m_currentOrderItem.item.name);
         CraftingUI.displayShoppingListWindow(recipe);
      }
      
      private function getBuyAllPrice() : Number
      {
         var slot:BushelBabyCraftingIngredientSlot = null;
         var cost:Number = 0;
         for each(slot in this.m_recipeSlots)
         {
            cost += slot.requiredItemsCost();
         }
         return cost;
      }
      
      private function onBuyAllBushelPress(e:Event) : void
      {
         var slot:BushelBabyCraftingIngredientSlot = null;
         var required:int = 0;
         var success:Boolean = false;
         var cashNeeded:int = this.getBuyAllPrice();
         if(Global.player.cash < cashNeeded)
         {
            UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_CASH,"impulseBuyPopup",cashNeeded,"BushelBabies_BuyAllIngresients");
         }
         else
         {
            this.m_currentOrderItem.npcLevel.npc.system.logStats("buy_all",this.m_currentOrderItem.item.name);
            for each(slot in this.m_recipeSlots)
            {
               required = slot.requiredItemCount();
               success = true;
               if(Boolean(required) && required > 0)
               {
                  if(slot.buyBushel(required) == false)
                  {
                     success = false;
                  }
               }
            }
            if(success == true)
            {
               this.m_buyIngredientsButton.visible = false;
            }
         }
      }
      
      private function onCraft(e:Event) : void
      {
         var i:int = 0;
         var data:Object = null;
         this.m_currentOrderItem.npcLevel.npc.system.logStats("craft",this.m_currentOrderItem.item.name);
         var exchangeSuccess:Boolean = true;
         var slotDataLength:int = int(m_slotData.length);
         var recipeSlotLength:int = int(this.m_recipeSlots.length);
         for(i = 0; i < slotDataLength; i++)
         {
            if(i < recipeSlotLength)
            {
               data = m_slotData[i];
               if(data[RecipeItem.SWAPPABLE])
               {
                  if(!ExchangeManager.getInstance().instantOneToOneExchange(ExchangeManager.BUSHEL_BABY_SWAP,this.m_recipeSlots[i].selectedItems,data[RecipeItem.ITEM_CODE]))
                  {
                     exchangeSuccess = false;
                     break;
                  }
               }
            }
         }
         if(exchangeSuccess)
         {
            CraftingManager.getInstance().craftInstantItem(this.onCraftingComplete,Global.craftConfigSettings.getRecipeById(this.m_currentOrderItem.item.name),true);
            this.m_craftButton.enabled = false;
            Global.player.craftingState.addBushelBabiesCraftItemToInventory(this.m_currentOrderItem.item.code,1);
            for(i = 0; i < this.m_recipeSlots.length; i++)
            {
               this.m_recipeSlots[i].resetSelect();
            }
            this.m_currentOrderItem.npcLevel.npc.system.refreshCurrentWindow();
            this.onClose();
            dispatchEvent(new Event(Event.COMPLETE));
         }
      }
      
      private function onCraftingComplete(code:String, crafted:Boolean) : void
      {
         if(visible)
         {
            this.refresh();
         }
         this.m_currentOrderItem.npcLevel.npc.system.refreshCurrentWindow();
      }
      
      private function onClose(e:Event = null) : void
      {
         for(var i:int = 0; i < this.m_recipeSlots.length; i++)
         {
            this.m_recipeSlots[i].resetSelect();
         }
         visible = false;
         dispatchEvent(new Event(Event.CLOSE));
      }
   }
}

