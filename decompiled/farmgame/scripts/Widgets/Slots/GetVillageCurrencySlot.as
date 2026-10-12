package Widgets.Slots
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Engine.Managers.StatsManager;
   import Managers.FarmVillageManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.GetVillageCurrencyWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class GetVillageCurrencySlot extends ItemPurchaseSlot
   {
      
      private const CURRENCY_EXCHANGE_RATE:int = 100;
      
      public function GetVillageCurrencySlot(element:DisplayObject, parentWindow:FarmWindow)
      {
         var valueObject:MovieClip = null;
         super(element,parentWindow);
         if(m_element.value_mc != null)
         {
            valueObject = m_element.value_mc;
            addWidget(new ZwWidget(valueObject));
            if(valueObject.value_tf != null)
            {
               addWidget(new ZwTextField(valueObject.value_tf,""));
            }
            if(m_element.amount_tf != null)
            {
               addWidget(new ZwTextField(m_element.amount_tf,""));
            }
         }
      }
      
      override public function populate(data:Object) : void
      {
         var cashButton:FarmAnimatedCashButton = null;
         var amountTextField:ZwTextField = null;
         var currNum:Number = NaN;
         var cashCost:Number = NaN;
         var coinsForCash:Number = NaN;
         var valueTextField:ZwTextField = null;
         var discount:int = 0;
         super.populate(data);
         if(m_buyButton != null)
         {
            cashButton = m_buyButton as FarmAnimatedCashButton;
            if(cashButton)
            {
               cashButton.showPaymentConfirmation = true;
            }
         }
         if(m_itemName != null)
         {
            m_itemName.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"menu_villageCurrency");
         }
         if(m_element.amount_tf != null)
         {
            amountTextField = getWidget(m_element.amount_tf) as ZwTextField;
            amountTextField.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"Quantity",{"quantity":m_farmItem.count});
            amountTextField.visible = true;
         }
         if(m_element.value_mc != null)
         {
            currNum = m_farmItem.count;
            cashCost = m_farmItem.cash;
            coinsForCash = cashCost * this.CURRENCY_EXCHANGE_RATE;
            if(coinsForCash != currNum)
            {
               getWidget(m_element.value_mc).visible = true;
               valueTextField = getWidget(m_element.value_mc.value_tf) as ZwTextField;
               valueTextField.visible = true;
               discount = currNum - coinsForCash;
               valueTextField.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"VillageCoinBonusText",{"bonus":discount});
            }
         }
      }
      
      override protected function onBuyCallback(event:Event) : void
      {
         if(Global.player.canBuyCash(getItemPrice()))
         {
            if(m_farmItem != null)
            {
               m_farmItem.onBuy(m_farmItem.name);
               StatsManager.count(FarmVillageManager.FARM_VILLAGE_STAT,GetVillageCurrencyWindow.VC_DIALOG_STAT,"buy",m_farmItem.name);
            }
            if(m_parentWindow != null)
            {
               m_parentWindow.close();
            }
         }
      }
   }
}

