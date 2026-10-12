package Widgets.Frames.Subscriptions
{
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.Subscriptions.SubscriptionsSlot;
   import Widgets.Windows.Subscriptions.SubscriptionsMainWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class SubscriptionSlotContainer extends FarmSlotContainerFrame
   {
      
      protected static const SLOT_PREFIX:String = "Slot_";
      
      private var m_parentWindow:SubscriptionsMainWindow;
      
      public function SubscriptionSlotContainer(element:DisplayObject, parentWindow:SubscriptionsMainWindow)
      {
         this.m_parentWindow = parentWindow;
         super(element);
         addWidget(new FarmAnimatedTextButton(m_element.manage_bt,ZLocUtils.t("Dialogs","Subscriptions_ManageSubscription"),this.onManageAccount));
      }
      
      private function onManageAccount(event:Event) : void
      {
         FarmStatsManager.count(SubscriptionsMainWindow.STATS_COUNTER,SubscriptionsMainWindow.STATS_KINGDOM,"manage");
      }
      
      override protected function getSlotPrefix() : String
      {
         return SLOT_PREFIX;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new SubscriptionsSlot(slotElement,this.m_parentWindow);
      }
      
      override protected function setupData() : void
      {
      }
      
      override public function release() : void
      {
         super.release();
      }
      
      public function set items(items:Array) : void
      {
         m_slotData = items;
         refresh();
      }
   }
}

