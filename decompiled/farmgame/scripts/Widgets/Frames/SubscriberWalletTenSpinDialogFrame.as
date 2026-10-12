package Widgets.Frames
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.SubscriberWalletTenSpinDialogSlot;
   import Widgets.Windows.SubscriberWalletTenSpinDialog;
   import flash.display.DisplayObject;
   
   public class SubscriberWalletTenSpinDialogFrame extends FarmSlotContainerFrame
   {
      
      private var m_featureName:String = null;
      
      private const MAX_PAGE:int = 1;
      
      private var m_mainWindow:SubscriberWalletTenSpinDialog;
      
      public function SubscriberWalletTenSpinDialogFrame(element:DisplayObject, featureName:String, window:SubscriberWalletTenSpinDialog)
      {
         this.m_featureName = featureName;
         super(element);
         m_pagingComponent.maxPageNumber = this.MAX_PAGE;
         m_element.visible = true;
         this.m_mainWindow = window;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new SubscriberWalletTenSpinDialogSlot(slotElement,this.m_featureName,this.m_mainWindow);
      }
      
      override protected function getSlotPrefix() : String
      {
         return "reward_";
      }
      
      public function setupSlotData(slotData:Array) : void
      {
         m_slotData = slotData;
      }
   }
}

