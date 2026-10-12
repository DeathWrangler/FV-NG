package Widgets.Frames.LESet
{
   import Classes.ItemRequirement;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.FarmItemLock;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Managers.LESetManager;
   import Transactions.TBuyItemPutGiftbox;
   import Widgets.Constants.Market.Currency;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.LESet.LESetSlot;
   import Widgets.Windows.LESetWindow;
   import flash.display.DisplayObject;
   
   public class LESetSlotContainerFrame extends FarmSlotContainerFrame
   {
      
      private static var m_set:Array;
      
      private var m_window:LESetWindow;
      
      public function LESetSlotContainerFrame(element:DisplayObject, window:LESetWindow)
      {
         this.m_window = window;
         super(element);
         m_pageForwardWidget = addWidget(new ZwButton(m_element.arrowRight_bt,m_pagingComponent.onPageForward)) as ZwButton;
         m_pageBackWidget = addWidget(new ZwButton(m_element.arrowLeft_bt,m_pagingComponent.onPageBack)) as ZwButton;
         m_currentPageLabel = addWidget(new ZwTextField(m_element.pagect_tf)) as ZwTextField;
      }
      
      override protected function setupData() : void
      {
         m_slotData = LESetManager.getCurrentCollectionData();
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new LESetSlot(slotElement,this);
      }
      
      public function refreshData() : void
      {
         this.setupData();
      }
      
      public function onSlotBuy(slot:LESetSlot) : Boolean
      {
         var complete:Boolean = false;
         var message:String = null;
         var popup:GenericPopup = null;
         var result:Boolean = false;
         var index:int = int(slot.name.split("_")[1]);
         var purchaseIndex:int = index + m_slots.length * m_pagingComponent.currentPageNumber;
         slot = m_slots[index];
         var itemData:FarmItem = m_slotData[purchaseIndex]["item"];
         var lock:String = this.getLocks(itemData);
         if(LESetManager.checkDateGate())
         {
            if(lock == "")
            {
               if(Global.player.canBuyCash(itemData.cash,true))
               {
                  StatsManager.count("dialog","reward_purch_set_1","buy_item_" + purchaseIndex);
                  TransactionManager.addTransaction(new TBuyItemPutGiftbox(itemData,Currency.CASH,1,false,true));
                  result = true;
                  if(m_slotData[purchaseIndex]["owned"] != true)
                  {
                     this.windowAnimations(slot);
                  }
                  m_slotData[purchaseIndex]["owned"] = true;
                  complete = LESetManager.addItemToCollection(itemData);
                  if(complete == true)
                  {
                     this.m_window.completeCollection();
                  }
               }
            }
            else
            {
               message = ZLocUtils.t("Dialogs","LESetBonus_CantBuy",{"lock":lock});
               popup = new GenericPopup(message,GenericPopup.TYPE_OK);
               UI.displayPopup(popup,false);
            }
         }
         else
         {
            LESetManager.endPopup(this.m_window.closeWindow);
         }
         return result;
      }
      
      private function getLocks(item:FarmItem) : String
      {
         var itemRequirementLock:ItemRequirement = null;
         var locks:Array = item.getLockedStates();
         var lock:* = "";
         var lockMessage:String = "";
         for(var i:Number = 0; i < locks.length; i++)
         {
            lock = locks[i];
            if(lock is ItemRequirement)
            {
               itemRequirementLock = lock as ItemRequirement;
               lockMessage = itemRequirementLock.getReadableMessage();
               break;
            }
            if(lock == FarmItemLock.LIMIT_HIT)
            {
               lockMessage = ZLocUtils.t("Dialogs","LimitHit",{"quantity":item.limit});
               break;
            }
         }
         return lockMessage;
      }
      
      public function windowAnimations(slot:LESetSlot) : void
      {
         this.m_window.animateItemIcon(slot.Icon);
         this.m_window.updateProgress(1);
      }
      
      public function getData() : Object
      {
         return m_slotData;
      }
   }
}

