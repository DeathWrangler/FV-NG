package Widgets.Frames.TicketParty
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import flash.display.DisplayObject;
   
   public class TicketPartyFlyoutSlotFrame extends ZwSlotFrame
   {
      
      protected var m_ticketFlyoutSlots:Array;
      
      public function TicketPartyFlyoutSlotFrame(element:DisplayObject, redeemItems:Array, totalTickets:Number, buttonCallbacks:Object)
      {
         var item:Object = null;
         var flyoutLocked:Boolean = false;
         var unlockCost:Number = NaN;
         var flyoutSlot:TicketPartyFlyoutSlot = null;
         this.m_ticketFlyoutSlots = new Array();
         super(element);
         var slotIndex:Number = 0;
         for each(item in redeemItems)
         {
            flyoutLocked = item.accumulativeCost > totalTickets;
            unlockCost = 0;
            if(flyoutLocked)
            {
               unlockCost = item.accumulativeCost - totalTickets;
            }
            flyoutSlot = addWidget(new TicketPartyFlyoutSlot(m_element["slot_" + slotIndex.toString() + "_mc"],item.name,item.accumulativeCost,item.buyCost,unlockCost,item.icon,item.friendlyName,item.redeemItemSeenFlag,flyoutLocked,buttonCallbacks)) as TicketPartyFlyoutSlot;
            this.m_ticketFlyoutSlots.push(flyoutSlot);
            slotIndex++;
         }
      }
      
      public function updateFlyouts(totalTickets:Number) : void
      {
         var flyoutSlot:TicketPartyFlyoutSlot = null;
         var flyoutLocked:Boolean = false;
         for each(flyoutSlot in this.m_ticketFlyoutSlots)
         {
            flyoutLocked = flyoutSlot.ticketsToUnlock() > totalTickets;
            flyoutSlot.locked = flyoutLocked;
            if(flyoutLocked)
            {
               flyoutSlot.unlockCost = flyoutSlot.ticketsToUnlock() - totalTickets;
            }
            else
            {
               flyoutSlot.unlockCost = 0;
            }
         }
      }
      
      public function isAnyRedeemButtonEnabled() : Boolean
      {
         var flyoutSlot:TicketPartyFlyoutSlot = null;
         var result:Boolean = false;
         for each(flyoutSlot in this.m_ticketFlyoutSlots)
         {
            if(flyoutSlot.isRedeemButtonEnabled())
            {
               result = true;
               break;
            }
         }
         return result;
      }
   }
}

