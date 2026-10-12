package Widgets.Frames
{
   import Managers.SubscriberWalletManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.SubscriberWalletMainWindowRewardSlot;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class SubscriberWalletMainWindowRewards extends FarmSlotContainerFrame
   {
      
      private var m_featureName:String = null;
      
      public function SubscriberWalletMainWindowRewards(element:DisplayObject, featureName:String)
      {
         this.m_featureName = featureName;
         super(element);
         m_pagingComponent.maxPageNumber = 1;
         (m_element["bg_mc"] as MovieClip).visible = true;
         (m_element["bg_mc"] as MovieClip).play();
      }
      
      override protected function setupData() : void
      {
         m_slotData = SubscriberWalletManager.getInstance().getMainWindowRewardsArray();
      }
      
      override protected function getSlotPrefix() : String
      {
         return "icon_";
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new SubscriberWalletMainWindowRewardSlot(slotElement,this.m_featureName);
      }
   }
}

