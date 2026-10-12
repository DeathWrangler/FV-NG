package Widgets.Slots.Crafting
{
   import Classes.MarketStallBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.Crafting.CraftingManager;
   import Managers.Crafting.MarketViewManager;
   import Managers.FarmStatsManager;
   import Managers.SubscriptionsManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Crafting.ShoppingListGetBushelSlotFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.MOTD.SubscriptionAllBenefitsMOTDWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class HomeMarketStallShopSlot extends ZwSlotFrame
   {
      
      private static const ICON_SIZE:int = 70;
      
      private static const ICON_OFFSET_X:int = 11;
      
      private static const ICON_OFFSET_Y:int = 11;
      
      private var m_item:Object = null;
      
      private var m_getBushelsSlotFrame:ShoppingListGetBushelSlotFrame = null;
      
      private var m_messageFrame:ZwFrame = null;
      
      private var m_getItemCallback:Function;
      
      private var m_expandButton:FarmAnimatedTextButton = null;
      
      private var m_getFasterButton:FarmAnimatedButton;
      
      private var m_parentWindow:FarmWindow = null;
      
      public function HomeMarketStallShopSlot(element:DisplayObject, getItemCallback:Function, parentWindow:FarmWindow)
      {
         this.m_getItemCallback = getItemCallback;
         this.m_parentWindow = parentWindow;
         super(element);
         addWidget(new ZwTextField(m_element.generic1_tf));
         addWidget(new ZwTextField(m_element.generic2_tf));
         this.m_getBushelsSlotFrame = addWidget(new ShoppingListGetBushelSlotFrame(m_element.get_mc,this.onGetItem)) as ShoppingListGetBushelSlotFrame;
         this.m_messageFrame = addWidget(new ZwFrame(m_element.ask_mc)) as ZwFrame;
         this.m_messageFrame.addWidget(new ZwTextField(m_element.ask_mc.generic_tf,""));
         this.m_expandButton = new FarmAnimatedTextButton(m_element.ask_mc.ask_bt,ZLocUtils.t("Dialogs","Expand"),this.onExpandClicked);
         this.m_messageFrame.addWidget(this.m_expandButton,false);
         this.m_getFasterButton = addWidget(new FarmAnimatedTextButton(m_element.getFaster_bt,ZLocUtils.t("Dialogs","subscription_market_getFaster"),this.onGetFasterClicked),false) as FarmAnimatedButton;
         var icon:FarmIcon = new FarmIcon(m_element.icon_mc);
         addWidget(icon);
         icon.x += ICON_OFFSET_X;
         icon.y += ICON_OFFSET_Y;
         icon.setIconSize(ICON_SIZE,ICON_SIZE);
      }
      
      protected function onGetFasterClicked(event:MouseEvent) : void
      {
         this.closeParentWindow();
         FarmStatsManager.count("subs_ingame_marketing","getbushels","click");
         UI.displayPopup(new SubscriptionAllBenefitsMOTDWindow());
      }
      
      override public function populate(data:Object) : void
      {
         var nameTextField:ZwTextField = null;
         var inventoryQuantity:int = 0;
         var amountTextField:ZwTextField = null;
         var iconFarmIcon:FarmIcon = null;
         var overLimit:Boolean = false;
         var siloFull:Boolean = false;
         var marketStall:MarketStallBuilding = null;
         var friendsWithBushels:Array = null;
         var bushelsRemaining:Boolean = false;
         var friendWithBushel:Object = null;
         super.populate(data);
         this.m_item = data as FarmItem;
         if(this.m_item)
         {
            nameTextField = getWidget(m_element.generic1_tf) as ZwTextField;
            nameTextField.text = ZLocUtils.tk_pk_asTitle("Items:" + this.m_item.name + "_friendlyName");
            nameTextField.visible = true;
            inventoryQuantity = CraftingManager.getInstance().getBushelQuantityInInventory(this.m_item.code);
            amountTextField = getWidget(m_element.generic2_tf) as ZwTextField;
            amountTextField.text = ZLocUtils.t("Crafting","HomeMarketStallDialog_ShopBushelInventory",{"quantity":inventoryQuantity.toString()});
            amountTextField.visible = true;
            iconFarmIcon = getWidget(m_element.icon_mc) as FarmIcon;
            iconFarmIcon.loadIcon(this.m_item.icon);
            iconFarmIcon.visible = true;
            overLimit = Global.player.craftingState.shoppingState.getTotalDailyPurchases() > Global.player.craftingState.shoppingState.maxPurchasesPerDay;
            siloFull = Global.player.craftingState.inventoryState.isFull;
            if(siloFull)
            {
               marketStall = Global.player.craftingState.getMarketStall();
               if(Boolean(marketStall) && marketStall.readyToExpand())
               {
                  this.showMessage(ZLocUtils.t("Crafting","ShoppingListDialog_InventoryFullExpandMessage"),true);
               }
               else
               {
                  this.showMessage(ZLocUtils.t("Crafting","ShoppingListDialog_InventoryFullMessage"),false);
               }
            }
            else if(overLimit)
            {
               if(!SubscriptionsManager.instance.isSubscriber())
               {
                  this.m_getFasterButton.visible = false;
               }
               this.showMessage(ZLocUtils.t("Crafting","ShoppingListDialog_DailyLimitMessage",{"friendlyTime":CraftingManager.getInstance().getFriendlyTimeToMoreBags()}),false);
            }
            else
            {
               friendsWithBushels = MarketViewManager.getInstance().getFriendsWithBushel(this.m_item.code);
               if(Boolean(friendsWithBushels) && friendsWithBushels.length > 0)
               {
                  bushelsRemaining = false;
                  for each(friendWithBushel in friendsWithBushels)
                  {
                     if(Number(friendWithBushel["timeToBags"]) <= 0)
                     {
                        bushelsRemaining = true;
                     }
                  }
                  if(bushelsRemaining)
                  {
                     this.m_getBushelsSlotFrame.updateItems(friendsWithBushels);
                     this.m_getBushelsSlotFrame.visible = true;
                     this.hideMessage();
                  }
                  else
                  {
                     if(!SubscriptionsManager.instance.isSubscriber())
                     {
                        this.m_getFasterButton.visible = false;
                     }
                     this.showMessage(ZLocUtils.t("Crafting","ShoppingListDialog_DailyLimitMessage",{"friendlyTime":CraftingManager.getInstance().getFriendlyTimeToMoreBags()}),false);
                  }
               }
               else
               {
                  this.showMessage(ZLocUtils.t("Crafting","ShoppingListDialog_NoneMessage"),false);
               }
            }
         }
      }
      
      protected function getCanPublishFeed() : Boolean
      {
         return Global.player.craftingState.shoppingState.lastGetBushelsRequestTS < GlobalEngine.serverTime / 1000 - Global.craftConfigSettings.getBushelRequestFeedLimitSeconds();
      }
      
      protected function showMessage(text:String, expandButtonVisible:Boolean) : void
      {
         (this.m_messageFrame.getWidget(m_element.ask_mc.generic_tf) as ZwTextField).text = text;
         this.m_messageFrame.visible = true;
         this.m_getBushelsSlotFrame.visible = false;
         this.m_expandButton.visible = expandButtonVisible;
      }
      
      protected function onExpandClicked(event:Event) : void
      {
         var marketStall:MarketStallBuilding = Global.player.craftingState.getMarketStall();
         if(marketStall)
         {
            FarmStatsManager.count("dialog","marketstall_full_expand","view","home_stall");
            marketStall.beginCompleteExpansionFlow(0,this.expandCallback);
         }
      }
      
      protected function expandCallback() : void
      {
         this.m_parentWindow.close();
      }
      
      protected function hideMessage() : void
      {
         this.m_messageFrame.visible = false;
      }
      
      protected function onGetItem(uid:String) : void
      {
         if(this.m_getItemCallback != null)
         {
            this.m_getItemCallback(uid,this.m_item.code);
         }
      }
      
      override public function release() : void
      {
         super.release();
         this.m_messageFrame = null;
         this.m_getBushelsSlotFrame = null;
         this.m_item = null;
         this.m_getItemCallback = null;
      }
   }
}

