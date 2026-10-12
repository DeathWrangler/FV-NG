package Widgets.Slots.TicketParty
{
   import Widgets.Frames.ItemPrizeFrame;
   import flash.display.DisplayObject;
   
   public class TicketPartyPrizePreviewSlot extends ItemPrizeFrame
   {
      
      protected var m_buyCost:Number = 0;
      
      public function TicketPartyPrizePreviewSlot(element:DisplayObject, itemName:String, buyCost:Number, iconURL:String, buttonCallbacks:Object, locked:Boolean, checked:Boolean)
      {
         super(element,itemName,iconURL,buttonCallbacks);
         this.m_buyCost = buyCost;
         this.updateUI(locked,checked);
      }
      
      override protected function getBuyCost() : Number
      {
         return this.m_buyCost;
      }
      
      public function updateUI(locked:Boolean, checked:Boolean) : void
      {
         if(this.element.hasOwnProperty("checkMark_mc") && this.element.checkMark_mc != null)
         {
            if(checked)
            {
               m_element.checkMark_mc.visible = true;
               m_element.checkMark_mc.gotoAndPlay(0);
            }
            else
            {
               m_element.checkMark_mc.visible = false;
            }
         }
         if(locked)
         {
            if(this.element.hasOwnProperty("locked_mc") && this.element.locked_mc != null)
            {
               m_element.locked_mc.visible = true;
               m_element.locked_mc.gotoAndPlay(0);
            }
         }
         else if(this.element.hasOwnProperty("locked_mc") && this.element.locked_mc != null)
         {
            m_element.locked_mc.visible = false;
         }
         m_state = ItemPrizeFrame.STATE_BUY;
         refreshUI();
      }
   }
}

