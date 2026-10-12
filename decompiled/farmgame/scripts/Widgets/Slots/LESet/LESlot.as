package Widgets.Slots.LESet
{
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Slots.ItemPurchaseSlot;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class LESlot extends ItemPurchaseSlot
   {
      
      public function LESlot(element:DisplayObject, parentWindow:FarmWindow)
      {
         super(element,parentWindow);
      }
      
      override protected function onBuyCallback(event:Event) : void
      {
         if(Global.player.canBuyCash(getItemPrice()))
         {
            m_farmItem.onBuy(m_farmItem.name);
            m_parentWindow.close();
         }
      }
      
      override protected function setupBuyButton() : void
      {
         if(Boolean(m_element) && Boolean(m_element.buy_bt))
         {
            if(m_buyButton)
            {
               removeWidget(m_buyButton);
               m_buyButton = null;
            }
            m_buyButton = addWidget(new FarmAnimatedCashButton(m_element.buy_bt,ZLocUtils.t("Dialogs","Buy"),"" + m_farmItem.cash,this.onBuyCallback,false,false,true)) as FarmAnimatedCashButton;
            m_buyButton.visible = true;
         }
      }
      
      public function set slotFrameIndex(index:int) : void
      {
         m_slotFrameIndex = index;
      }
      
      public function get slotFrameIndex() : int
      {
         return m_slotFrameIndex;
      }
   }
}

