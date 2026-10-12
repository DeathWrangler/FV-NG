package Widgets.Slots.LESet
{
   import Classes.LESaleBundle;
   import Engine.Utilities;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.LESet.LEBundleWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class LEBundleSlot extends LESlot
   {
      
      private var m_bundleDesc:ZwTextField;
      
      public function LEBundleSlot(element:DisplayObject, parentWindow:FarmWindow)
      {
         super(element,parentWindow);
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.setupBundleDesc();
      }
      
      override protected function getItemPrice() : int
      {
         var currentBundle:LESaleBundle = null;
         var returnVal:int = 0;
         var parentBundleWindow:LEBundleWindow = m_parentWindow as LEBundleWindow;
         if(Boolean(m_farmItem) && Boolean(parentBundleWindow))
         {
            currentBundle = parentBundleWindow.saleBundle;
            if(currentBundle)
            {
               returnVal = currentBundle.getSalePrice(m_farmItem);
            }
         }
         return returnVal;
      }
      
      override protected function setupPrice() : void
      {
         var parentBundleWindow:LEBundleWindow = m_parentWindow as LEBundleWindow;
         var viewCheck:Boolean = Boolean(parentBundleWindow) && parentBundleWindow.slotsHaveBuyButtons();
         var elementCheck:Boolean = Boolean(m_element) && Boolean(m_element.buy_bt) && Boolean(m_element.buy_bt.farmCash_tf);
         if(viewCheck && elementCheck)
         {
            if(!m_price)
            {
               addWidget(m_price = new ZwTextField(m_element.buy_bt.farmCash_tf,this.getItemPrice().toString()));
               Utilities.toggleInputOnlySelf(m_element.buy_bt.farmCash_tf,false);
               m_price.visible = true;
            }
            else
            {
               m_price.visible = true;
            }
         }
      }
      
      override protected function setupBuyButton() : void
      {
         super.setupBuyButton();
         m_buyButton.setAmountText(this.getItemPrice().toString());
         var parentBundleWindow:LEBundleWindow = m_parentWindow as LEBundleWindow;
         var nonViewCheck:Boolean = Boolean(parentBundleWindow) && !parentBundleWindow.slotsHaveBuyButtons();
         if(nonViewCheck)
         {
            m_buyButton.visible = false;
         }
      }
      
      protected function setupBundleDesc() : void
      {
         var bundleDesc:String = null;
         var parentBundleWindow:LEBundleWindow = m_parentWindow as LEBundleWindow;
         var viewCheck:Boolean = Boolean(parentBundleWindow) && parentBundleWindow.slotsHaveDescription();
         var elementCheck:Boolean = Boolean(m_element) && Boolean(m_element.popupBox_tf);
         if(viewCheck && elementCheck)
         {
            bundleDesc = parentBundleWindow.getSaleBundleDescription();
            if(this.m_bundleDesc)
            {
               removeWidget(this.m_bundleDesc);
               this.m_bundleDesc = null;
            }
            addWidget(this.m_bundleDesc = new ZwTextField(m_element.popupBox_tf,bundleDesc));
            this.m_bundleDesc.visible = true;
         }
      }
      
      override protected function onBuyCallback(event:Event) : void
      {
         var parentBundleWindow:LEBundleWindow = null;
         var currentBundle:LESaleBundle = null;
         if(Boolean(m_farmItem) && Global.player.canBuyCash(this.getItemPrice()))
         {
            parentBundleWindow = m_parentWindow as LEBundleWindow;
            if(Boolean(m_farmItem) && Boolean(parentBundleWindow))
            {
               currentBundle = parentBundleWindow.saleBundle;
               if(currentBundle)
               {
                  parentBundleWindow.trackLEBundleStat("click_buy_" + slotFrameIndex);
                  currentBundle.attemptBundleItemPurchase(m_farmItem);
                  m_parentWindow.close();
               }
            }
         }
      }
   }
}

