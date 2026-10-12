package Widgets.Frames.TicketParty
{
   import Widgets.Frames.ItemPrizeFrame;
   import flash.display.DisplayObject;
   
   public class TicketPartyPrize extends ItemPrizeFrame
   {
      
      protected var m_redeemItemSeenFlag:String = "";
      
      protected var m_ticketsToUnlock:Number = 0;
      
      protected var m_buyCost:Number = 0;
      
      protected var m_unlockCost:Number = 0;
      
      public function TicketPartyPrize(element:DisplayObject, itemName:String, ticketCost:Number, buyCost:Number, iconURL:String, redeemItemSeenFlag:String, totalTickets:Number, callbacks:Object)
      {
         super(element,itemName,iconURL,callbacks);
         this.m_redeemItemSeenFlag = redeemItemSeenFlag;
         this.m_ticketsToUnlock = ticketCost;
         this.m_buyCost = buyCost;
         this.m_unlockCost = 0;
         this.update(totalTickets);
      }
      
      override protected function getUnlockCost() : Number
      {
         return this.m_unlockCost;
      }
      
      override protected function getBuyCost() : Number
      {
         return this.m_buyCost;
      }
      
      public function update(totalTickets:Number) : void
      {
         if(this.m_ticketsToUnlock > totalTickets)
         {
            m_state = ItemPrizeFrame.STATE_LOCKED;
         }
         this.m_unlockCost = 0;
         if(m_state == ItemPrizeFrame.STATE_LOCKED)
         {
            this.m_unlockCost = this.m_ticketsToUnlock - totalTickets;
         }
         else if(Global.player.getSeenFlag(this.m_redeemItemSeenFlag))
         {
            m_state = ItemPrizeFrame.STATE_BUY;
         }
         refreshUI();
      }
   }
}

