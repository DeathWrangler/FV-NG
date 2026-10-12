package Widgets.Slots.BushelBaby
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.crafting.RecipeItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.StatsManager;
   import Managers.BushelBabyManager;
   import Managers.Crafting.CraftingManager;
   import Managers.Crafting.MarketViewManager;
   import Widgets.BushelBabiesCraftingFrame;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.utils.Dictionary;
   
   public class BushelBabyCraftingIngredientSlot extends ZwSlotFrame
   {
      
      private var m_icon:FarmIcon;
      
      protected var m_buyButton:FarmAnimatedCashButton;
      
      protected var m_swapButton:FarmAnimatedTextButton;
      
      protected var m_askButton:FarmAnimatedTextButton;
      
      protected var m_ratio:ZwTextField;
      
      private var m_checkWidget:ZwWidget;
      
      private var m_currentData:Object = null;
      
      private var m_selectedData:Object = {};
      
      protected var m_counter:ZwTextField;
      
      protected var m_counterCircle:ZwWidget;
      
      public function BushelBabyCraftingIngredientSlot(element:DisplayObject)
      {
         super(element);
         this.setup();
      }
      
      public function get selectedItems() : Object
      {
         return this.m_selectedData.selectedItemHash || {};
      }
      
      public function resetSelect() : void
      {
         var selectedItemHash:Object = null;
         this.m_selectedData = {};
         var data:Object = this.m_currentData.data;
         if(data[RecipeItem.SWAPPABLE])
         {
            selectedItemHash = {};
            selectedItemHash[data[RecipeItem.ITEM_CODE]] = CraftingManager.getInstance().getBushelQuantityInInventory(data[RecipeItem.ITEM_CODE]);
            this.onSwapSelected(selectedItemHash);
         }
      }
      
      private function setup() : void
      {
         this.m_icon = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
         this.m_icon.clearScale();
         this.m_icon.setSmoothing(true);
         this.m_icon.attachTooltip(new FarmTextTooltip(""));
         addWidget(this.m_buyButton = new FarmAnimatedCashButton(m_element.buy_mc,ZLocUtils.t("FarmGame","Buy"),"",this.onBuy),true);
         addWidget(this.m_swapButton = new FarmAnimatedTextButton(m_element.swap_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"ExchangeSelect"),this.onSwap),true);
         addWidget(this.m_askButton = new FarmAnimatedTextButton(m_element.ask_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"AskNow"),this.onAsk),true);
         addWidget(this.m_ratio = new ZwTextField(m_element.generic_tf,""),true);
         addWidget(this.m_counterCircle = new ZwWidget(m_element.counterCircle_mc),false);
         addWidget(this.m_counter = new ZwTextField(m_element.counter_tf,""),false);
         addWidget(this.m_checkWidget = new ZwWidget(m_element.checkMark_mc),true);
      }
      
      public function onBuy(e:Event) : void
      {
         this.buyBushel();
         BushelBabiesCraftingFrame(parent).orderItem.npcLevel.npc.system.logStats("buy",this.m_currentData.data[RecipeItem.ITEM_CODE]);
      }
      
      public function buyBushel(quantity:int = 1) : Boolean
      {
         var selectedItemHash:Object = null;
         var itemCode:String = this.m_currentData.data[RecipeItem.ITEM_CODE];
         var result:Boolean = false;
         if(CraftingManager.getInstance().onPurchaseBushel(itemCode,this.m_currentData.recipe.id,quantity,false) == true)
         {
            if(this.m_currentData.data[RecipeItem.SWAPPABLE])
            {
               selectedItemHash = this.m_selectedData.selectedItemHash || {};
               selectedItemHash[itemCode] = selectedItemHash[itemCode] || 0;
               selectedItemHash[itemCode] += quantity;
               this.onSwapSelected(selectedItemHash);
            }
            result = true;
            this.populate(this.m_currentData);
            BushelBabiesCraftingFrame(parent).refresh();
         }
         return result;
      }
      
      private function onSwap(e:Event) : void
      {
         BushelBabyManager.instance.showSwapUI(this.m_currentData.data[RecipeItem.QUANTITY_REQUIRED],this.onSwapSelected,this.m_selectedData.selectedItemHash,BushelBabiesCraftingFrame(parent).getRejectoinList());
         StatsManager.count("bushel_babies","swap",this.m_currentData.data[RecipeItem.ITEM_CODE]);
      }
      
      private function onSwapSelected(selectedItemHash:Object) : void
      {
         var count:int = 0;
         var totalCount:int = 0;
         for each(count in selectedItemHash)
         {
            totalCount += count;
         }
         this.m_selectedData.selectedItemHash = selectedItemHash;
         this.m_selectedData.totalSelectedCount = totalCount;
         BushelBabiesCraftingFrame(parent).refresh();
         this.populate(this.m_currentData);
      }
      
      private function onAsk(e:Event) : void
      {
         CraftingManager.getInstance().startGetByFeedIngredientFlow(this.m_currentData.recipe,this.m_currentData.data,this.askFunctionCallBack);
         this.m_askButton.enabled = false;
         StatsManager.count("bushel_babies","Ask_now",this.m_currentData.data[RecipeItem.ITEM_CODE]);
      }
      
      private function askFunctionCallBack(evt:Event = null) : void
      {
         if(CraftingManager.getInstance().canPublishGetByFeedIngredient(this.m_currentData.recipe,this.m_currentData.data))
         {
            this.m_askButton.enabled = true;
         }
         else
         {
            this.m_askButton.enabled = false;
         }
      }
      
      public function requiredItemCount() : int
      {
         var data:Object = this.m_currentData.data;
         var itemCode:String = data[RecipeItem.ITEM_CODE];
         var itemRequired:int = int(data[RecipeItem.QUANTITY_REQUIRED]);
         var itemCount:int = CraftingManager.getInstance().getBushelQuantityInInventory(itemCode);
         return itemRequired - itemCount;
      }
      
      public function requiredItemsCost() : Number
      {
         var item:FarmItem = null;
         var result:Number = 0;
         if(this.m_currentData)
         {
            item = Global.farmGameSettingsManager.getFarmItemByCode(this.m_currentData.data[RecipeItem.ITEM_CODE]);
            result = CraftingManager.getInstance().getBushelPrice(item) * this.requiredItemCount();
         }
         return result;
      }
      
      override public function populate(dataObj:Object) : void
      {
         var friendsWithBushel:Array = null;
         var friend:Dictionary = null;
         var icon:DisplayObject = null;
         super.populate(dataObj);
         if(this.m_currentData == null)
         {
            this.m_currentData = dataObj;
            this.resetSelect();
         }
         this.m_currentData = dataObj;
         var data:Object = dataObj.data;
         var itemCode:String = data[RecipeItem.ITEM_CODE];
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
         var itemRequired:int = int(data[RecipeItem.QUANTITY_REQUIRED]);
         var itemCount:int = CraftingManager.getInstance().getBushelQuantityInInventory(itemCode);
         if(data[RecipeItem.SWAPPABLE])
         {
            itemCount = int(this.m_selectedData.totalSelectedCount);
            (this.m_icon.tooltip as FarmTextTooltip).setText(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"bushelTraderExchangeSelect"));
         }
         else
         {
            (this.m_icon.tooltip as FarmTextTooltip).setText(item.friendlyTitle);
         }
         if(this.m_icon.iconUrl != item.iconUrl)
         {
            icon = this.m_icon.icon;
            if(Boolean(icon) && Boolean(icon.parent))
            {
               icon.parent.removeChild(icon);
            }
            this.m_icon.loadIcon(item.iconUrl);
         }
         this.m_ratio.text = itemCount + "/" + itemRequired;
         this.m_checkWidget.visible = itemCount >= itemRequired;
         this.m_buyButton.enabled = this.m_swapButton.enabled = !this.m_checkWidget.visible;
         this.m_askButton.enabled = !this.m_checkWidget.visible && CraftingManager.getInstance().canPublishGetByFeedIngredient(this.m_currentData.recipe,this.m_currentData.data);
         this.m_buyButton.setAmountText(CraftingManager.getInstance().getBushelPrice(item).toString());
         this.m_swapButton.visible = this.m_askButton.visible = false;
         this.m_swapButton.visible = data[RecipeItem.SWAPPABLE];
         this.m_askButton.visible = data[RecipeItem.GET_BY_FEED];
         this.m_buyButton.visible = this.m_icon.visible = this.m_ratio.visible = true;
         var numFriends:int = 0;
         friendsWithBushel = MarketViewManager.getInstance().getFriendsWithBushel(itemCode);
         for each(friend in friendsWithBushel)
         {
            if(friend["timeToBags"] == 0)
            {
               numFriends++;
            }
         }
         if(numFriends > 0)
         {
            this.m_counter.text = numFriends.toString();
            this.m_counter.visible = true;
            this.m_counterCircle.visible = true;
         }
         else
         {
            this.m_counter.visible = false;
            this.m_counterCircle.visible = false;
         }
      }
      
      override public function release() : void
      {
         this.m_icon = null;
         this.m_buyButton = null;
         this.m_swapButton = null;
         this.m_askButton = null;
         this.m_ratio = null;
         this.m_checkWidget = null;
         this.m_currentData = null;
         this.m_selectedData = null;
         this.m_counterCircle = null;
         this.m_counter = null;
         this.m_swapButton = null;
         this.m_askButton = null;
         super.release();
      }
   }
}

