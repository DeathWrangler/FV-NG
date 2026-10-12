package Widgets.Frames.SocialRaffle
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.SocialRaffle.RaffleTicketSlot;
   import com.greensock.TweenLite;
   import flash.display.DisplayObject;
   import flash.geom.Point;
   
   public final class RaffleTicketSlotFrame extends FarmSlotContainerFrame
   {
      
      protected var m_winningTicketSlot:RaffleTicketSlot = null;
      
      protected var m_items:Array = null;
      
      protected var m_slotPrefix:String;
      
      protected var m_maxSlots:int;
      
      private var m_startingPosition:Point = null;
      
      private var m_dissipated:Boolean = false;
      
      public function RaffleTicketSlotFrame(element:DisplayObject, items:Array, slotPrefix:String, maxSlots:int)
      {
         this.m_items = items;
         this.m_slotPrefix = slotPrefix;
         this.m_maxSlots = maxSlots;
         this.m_startingPosition = new Point(element.x,element.y);
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new RaffleTicketSlot(slotElement);
      }
      
      override protected function setupData() : void
      {
         m_slotData = this.m_items;
      }
      
      override public function release() : void
      {
         super.release();
         this.m_items = null;
         TweenLite.killTweensOf(this);
      }
      
      public function resetPosition() : void
      {
         this.x = this.m_startingPosition.x;
         this.y = this.m_startingPosition.y;
         this.alpha = 1;
         this.visible = true;
         this.m_dissipated = false;
      }
      
      public function get dissipated() : Boolean
      {
         return this.m_dissipated;
      }
      
      public function dissipate() : void
      {
         if(this.m_dissipated == false)
         {
            this.m_dissipated = true;
            TweenLite.to(this,1,{
               "y":this.m_startingPosition.y + 30,
               "alpha":0,
               "onComplete":this.onFinishDissipate
            });
         }
      }
      
      private function onFinishDissipate() : void
      {
         this.visible = false;
      }
      
      public function setData(data:Array, dissipate:Boolean = true) : void
      {
         m_slotData = this.m_items = data;
         for(var iSlot:int = 0; iSlot < m_slots.length; iSlot++)
         {
            m_slots[iSlot].visible = true;
            if(iSlot >= this.m_items.length && (m_slots[iSlot] as RaffleTicketSlot).dissipated == false)
            {
               (m_slots[iSlot] as RaffleTicketSlot).dissipate();
               if(!dissipate)
               {
                  (m_slots[iSlot] as RaffleTicketSlot).visible = false;
               }
            }
         }
         while(this.m_items.length < m_slots.length && dissipate)
         {
            this.m_items.push([]);
         }
         if(this.m_items.length == 1)
         {
            this.m_winningTicketSlot = m_slots[0] as RaffleTicketSlot;
         }
         m_slotData = this.m_items;
         refresh();
      }
      
      public function hideMissingTickets(data:Array) : void
      {
         var slot:Object = null;
         var bFound:Boolean = false;
         var iTicket:int = 0;
         var nSlot:int = int(m_slotData.length);
         if(nSlot > this.m_maxSlots)
         {
            nSlot = this.m_maxSlots;
         }
         for(var iSlot:int = 0; iSlot < nSlot; iSlot++)
         {
            slot = m_slotData[iSlot];
            bFound = false;
            for(iTicket = 0; iTicket < data.length; iTicket++)
            {
               if(data[iTicket].number == slot.number)
               {
                  bFound = true;
                  break;
               }
            }
            if(!bFound)
            {
               m_slots[iSlot].dissipate();
            }
            else
            {
               this.m_winningTicketSlot = m_slots[iSlot];
            }
         }
      }
      
      public function getWinningTicketSlot() : RaffleTicketSlot
      {
         return this.m_winningTicketSlot;
      }
      
      public function resetAllSlots() : void
      {
         for(var iSlot:int = 0; iSlot < m_slots.length; iSlot++)
         {
            (m_slots[iSlot] as RaffleTicketSlot).resetPosition();
         }
      }
      
      override protected function getSlotPrefix() : String
      {
         return this.m_slotPrefix;
      }
   }
}

