package Widgets.Slots
{
   import Classes.Quest.FarmQuest;
   import Display.GenericPopup;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Transactions.TBuyItemPutGiftbox;
   import Transactions.TGenericTransaction;
   import Widgets.Constants.Market.Currency;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Windows.ExpiredQuestRewardPurchaseWindow;
   import Widgets.Windows.ExpiredRewardWindow;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class ExpiredQuestRewardPurchaseSlot extends ItemPurchaseSlot
   {
      
      private var m_popup:ZwBaseWidget;
      
      public function ExpiredQuestRewardPurchaseSlot(element:DisplayObject, parentWindow:FarmWindow)
      {
         super(element,parentWindow);
         this.m_popup = addWidget(new ZwBaseWidget(m_element.giftbox_mc));
      }
      
      override protected function onBuyCallback(event:Event) : void
      {
         this.buyItem();
      }
      
      private function onBuyConfirmationHandler(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            this.buyItem();
         }
      }
      
      public function buyItem() : void
      {
         var price:int = 0;
         var parentWindow:ExpiredRewardWindow = null;
         var quest:FarmQuest = null;
         if(m_farmItem != null)
         {
            price = getItemPrice();
            if(Global.player.canBuyCash(price))
            {
               this.applyParentGrayOut(true);
               if(m_parentWindow as ExpiredQuestRewardPurchaseWindow)
               {
                  quest = (m_parentWindow as ExpiredQuestRewardPurchaseWindow).quest;
                  if(quest != null)
                  {
                     StatsManager.count((m_parentWindow as ExpiredQuestRewardPurchaseWindow).expiredFeatureStat,quest.chain,m_farmItem.name,"frontend",m_slotFrameIndex.toString());
                  }
                  else
                  {
                     StatsManager.count((m_parentWindow as ExpiredQuestRewardPurchaseWindow).expiredFeatureStat,"rewards_recapture_purchase",m_farmItem.name,price.toString());
                  }
               }
               parentWindow = m_parentWindow as ExpiredRewardWindow;
               if(parentWindow != null && parentWindow.hasAltPurchaseOption())
               {
                  TransactionManager.addTransaction(new TGenericTransaction(parentWindow.altPurchaseServiceName,parentWindow.altPurchaseServiceFunctionName,this.buySuccess,[m_farmItem.code]));
               }
               else
               {
                  TransactionManager.addTransaction(new TBuyItemPutGiftbox(m_farmItem,Currency.CASH,1,false,false,this.buySuccess));
               }
            }
         }
      }
      
      private function buySuccess(result:Object) : void
      {
         var parentWindow:ExpiredRewardWindow = null;
         if(result)
         {
            this.applyParentGrayOut(false);
            this.showPopup();
            parentWindow = m_parentWindow as ExpiredRewardWindow;
            if(parentWindow != null && parentWindow.hasAltPurchaseCallbackFunction())
            {
               parentWindow.altPurchaseCallbackFunction(result);
               parentWindow.close();
            }
         }
      }
      
      private function showPopup() : void
      {
         this.m_popup.visible = true;
         this.m_popup.element.gotoAndPlay(2);
      }
      
      private function applyParentGrayOut(value:Boolean) : void
      {
         (m_parentWindow as ExpiredRewardWindow).applyBuyButtonGrayOut(value);
      }
      
      public function applyBuyButtonGrayOut(value:Boolean) : void
      {
         if(m_buyButton)
         {
            m_buyButton.applyGrayOut = value;
         }
      }
      
      public function set slotFrameIndex(index:int) : void
      {
         m_slotFrameIndex = index;
      }
      
      override public function release() : void
      {
         this.m_popup = null;
      }
   }
}

