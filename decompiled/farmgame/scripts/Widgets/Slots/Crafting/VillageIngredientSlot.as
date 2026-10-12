package Widgets.Slots.Crafting
{
   import Classes.Constants.ZLocConstants;
   import Classes.crafting.MarketInventoryItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.Crafting.CraftingManager;
   import Transactions.TransactionWithCallBack;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.UseAllAmountSelectionWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.utils.Dictionary;
   
   public class VillageIngredientSlot extends ZwSlotFrame
   {
      
      private var m_bushel:MarketInventoryItem = null;
      
      private var m_bushelCount:int = 0;
      
      private var m_parentWindow:FarmWindow = null;
      
      public function VillageIngredientSlot(element:DisplayObject, parentWindow:FarmWindow)
      {
         super(element);
         this.m_parentWindow = parentWindow;
         if(m_element.title_tf != null)
         {
            addWidget(new ZwTextField(m_element.title_tf,""));
         }
         if(m_element.itemCount_tf != null)
         {
            addWidget(new ZwTextField(m_element.itemCount_tf,""));
         }
         if(m_element.icon_mc != null)
         {
            addWidget(new FarmIcon(m_element.icon_mc,null));
         }
         if(m_element.remove_bt != null)
         {
            addWidget(new FarmAnimatedTextButton(m_element.remove_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"Remove"),this.removeCallback));
         }
      }
      
      override public function populate(data:Object) : void
      {
         var titleWidget:ZwTextField = null;
         var itemCountWidget:ZwTextField = null;
         var bushelIcon:FarmIcon = null;
         super.populate(data);
         if(data != null && data is MarketInventoryItem)
         {
            this.m_bushel = data as MarketInventoryItem;
            if(this.m_bushel.underlyingItem)
            {
               if(m_element.title_tf != null)
               {
                  titleWidget = getWidget(m_element.title_tf) as ZwTextField;
                  titleWidget.text = this.m_bushel.underlyingItem.friendlyTitle;
                  titleWidget.visible = true;
               }
               this.m_bushelCount = 0;
               if(m_element.itemCount_tf != null)
               {
                  itemCountWidget = getWidget(m_element.itemCount_tf) as ZwTextField;
                  this.m_bushelCount = this.m_bushel.quantity;
                  itemCountWidget.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"Quantity",{"quantity":this.m_bushelCount});
                  itemCountWidget.visible = true;
               }
               if(m_element.icon_mc != null)
               {
                  bushelIcon = getWidget(m_element.icon_mc) as FarmIcon;
                  bushelIcon.loadIcon(this.m_bushel.underlyingItem.icon);
                  bushelIcon.visible = true;
               }
               if(m_element.remove_bt != null && this.m_bushelCount > 0)
               {
                  (getWidget(m_element.remove_bt) as FarmAnimatedTextButton).visible = true;
               }
            }
         }
         else
         {
            this.m_parentWindow.close();
         }
      }
      
      private function removeCallback(event:Event) : void
      {
         var textBundle:Object = new Object();
         textBundle[UseAllAmountSelectionWindow.TEXT_KEY_TITLE] = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"IngredientRemovalTitle");
         textBundle[UseAllAmountSelectionWindow.TEXT_KEY_ACCEPT_BUTTON] = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"Remove");
         textBundle[UseAllAmountSelectionWindow.TEXT_KEY_CANCEL_BUTTON] = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"Cancel");
         var dialogOptions:Object = {};
         dialogOptions[UseAllAmountSelectionWindow.OPTION_KEY_STARTING_QUANTITY] = 1;
         UI.displayPopup(new UseAllAmountSelectionWindow(this.m_bushel.underlyingItem,this.m_bushelCount,1,this.removeCallbackHandler,null,textBundle,dialogOptions),false);
      }
      
      private function removeCallbackHandler(data:Object) : void
      {
         var bushelCode:String = null;
         var villageItem:MarketInventoryItem = null;
         var villageItems:Dictionary = Global.player.craftingState.inventoryState.villageStorageItems;
         if(data != null && data.hasOwnProperty("item") && Boolean(data.item.hasOwnProperty("code")))
         {
            bushelCode = data.item.code;
            for each(villageItem in villageItems)
            {
               if(villageItem.itemCode == bushelCode)
               {
                  CraftingManager.getInstance().deductItemFromCraftingInventory(bushelCode,data.quantitySelected);
                  TransactionManager.addTransaction(new TransactionWithCallBack("CraftingService.removeBushel",null,bushelCode,data.quantitySelected));
                  if(this.m_parentWindow != null)
                  {
                     this.m_parentWindow.refreshWindow();
                  }
                  break;
               }
            }
         }
      }
      
      override public function release() : void
      {
         this.m_parentWindow = null;
         this.m_bushel = null;
         super.release();
      }
   }
}

