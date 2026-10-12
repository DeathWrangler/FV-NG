package Widgets.Frames.TicketParty
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.TicketParty.TicketPartyFriendSlot;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   
   public final class TicketPartyFriendSlotFrame extends FarmSlotContainerFrame
   {
      
      private static const SPACE_BETWEEN_SLOTS:int = 3;
      
      private static const NUM_ROWS:int = 2;
      
      private static const MAX_SLOTS_PER_ROW:int = 3;
      
      protected var m_items:Array = new Array();
      
      protected var m_showNames:Boolean;
      
      private var m_dynamicallyAddedSlotClips:Array;
      
      public function TicketPartyFriendSlotFrame(element:DisplayObject, friends:Array, maxFriends:int, showNames:Boolean = true, slotClipClass:Class = null)
      {
         this.m_showNames = showNames;
         var iItem:int = 0;
         while(iItem < friends.length && iItem < maxFriends)
         {
            this.m_items.push(friends[iItem]);
            iItem++;
         }
         for(var iPad:int = int(this.m_items.length); iPad < maxFriends; iPad++)
         {
            this.m_items.push("-1");
         }
         if(slotClipClass)
         {
            this.initializeSlotMovieClips(maxFriends,element,slotClipClass);
         }
         super(element);
      }
      
      private function initializeSlotMovieClips(numSlots:int, slotContainer:DisplayObject, friendSlotClass:Class) : void
      {
         var slotSize:int = 0;
         var slotsPerRow:int = 0;
         var originX:int = 0;
         var x:int = 0;
         var y:int = 0;
         var slotMovieClip:MovieClip = null;
         var nameTextField:TextField = null;
         var i:int = 0;
         var bounds:Rectangle = null;
         var totalWidth:int = 0;
         var maxWidth:int = 0;
         var originOffsetX:int = 0;
         var slotContainerClip:MovieClip = slotContainer as MovieClip;
         if(Boolean(slotContainerClip) && slotContainerClip.slot_0_mc == null)
         {
            if(friendSlotClass)
            {
               slotSize = 0;
               slotsPerRow = Math.floor(numSlots / NUM_ROWS);
               originX = 0;
               x = 0;
               y = 0;
               this.m_dynamicallyAddedSlotClips = new Array();
               for(i = 0; i < numSlots; i++)
               {
                  slotMovieClip = new friendSlotClass();
                  if(i == 0)
                  {
                     nameTextField = slotMovieClip.name_tf;
                     if(nameTextField)
                     {
                        slotMovieClip.removeChild(nameTextField);
                     }
                     bounds = slotMovieClip.getBounds(slotMovieClip);
                     slotSize = bounds.width;
                     totalWidth = slotSize * slotsPerRow + SPACE_BETWEEN_SLOTS * (slotsPerRow - 1);
                     maxWidth = slotSize * MAX_SLOTS_PER_ROW + SPACE_BETWEEN_SLOTS * (MAX_SLOTS_PER_ROW - 1);
                     originOffsetX = (maxWidth - totalWidth) / 2;
                     originX = x = originOffsetX - bounds.left;
                     y = -bounds.top;
                     if(nameTextField)
                     {
                        slotMovieClip.addChild(nameTextField);
                     }
                  }
                  slotMovieClip.x = x;
                  slotMovieClip.y = y;
                  slotMovieClip.name = "slot_" + i + "_mc";
                  if((i + 1) % slotsPerRow == 0)
                  {
                     x = originX;
                     y += slotSize + SPACE_BETWEEN_SLOTS;
                  }
                  else
                  {
                     x += slotSize + SPACE_BETWEEN_SLOTS;
                  }
                  this.m_dynamicallyAddedSlotClips.push(slotMovieClip);
                  slotContainerClip.addChild(slotMovieClip);
               }
            }
         }
      }
      
      override protected function setupSlots() : void
      {
         var slotClip:MovieClip = null;
         var slot:ZwSlotFrame = null;
         if(this.m_dynamicallyAddedSlotClips)
         {
            for each(slotClip in this.m_dynamicallyAddedSlotClips)
            {
               slot = this.createSlot(slotClip);
               addWidget(slot,false);
               m_slots.push(slot);
            }
         }
         else
         {
            super.setupSlots();
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new TicketPartyFriendSlot(slotElement,this.m_showNames);
      }
      
      override protected function setupData() : void
      {
         m_slotData = this.m_items;
      }
      
      override public function release() : void
      {
         super.release();
         this.m_items = null;
      }
      
      override protected function getSlotPrefix() : String
      {
         return "slot_";
      }
      
      override protected function getSlotPostfix() : String
      {
         return "_mc";
      }
      
      public function setData(data:Array) : void
      {
         m_slotData = this.m_items = data;
         refresh();
      }
   }
}

