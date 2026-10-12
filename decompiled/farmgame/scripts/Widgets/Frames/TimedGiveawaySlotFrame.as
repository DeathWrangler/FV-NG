package Widgets.Frames
{
   import Managers.TimedSlotGiveawaysManager;
   import Widgets.Slots.TimedGiveawaySlot;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.TimedGiveawayWindow;
   import flash.display.DisplayObject;
   
   public class TimedGiveawaySlotFrame extends GenericTimedSlotFrame
   {
      
      public function TimedGiveawaySlotFrame(element:DisplayObject, parentWindow:FarmWindow)
      {
         var itemsLength:int = 0;
         var items:Array = null;
         if(parentWindow != null && parentWindow is TimedGiveawayWindow)
         {
            items = TimedSlotGiveawaysManager.getItemsForGiveaway((parentWindow as TimedGiveawayWindow).getFeatureName());
         }
         else
         {
            items = new Array();
         }
         super(element,TimedGiveawaySlot,items,parentWindow);
         var index:int = 0;
         if(items != null)
         {
            itemsLength = int(items.length);
            while(index < itemsLength && items[index]["unlocked"] != false)
            {
               index++;
            }
         }
         m_pagingComponent.currentPageNumber = Math.floor((index - 1) / m_slots.length);
         refresh();
      }
   }
}

