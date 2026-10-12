package Widgets.Frames.Voting
{
   import Classes.util.ZLocUtils;
   import Widgets.Frames.ItemPrizeFrame;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class VotingBuyPrize extends ItemPrizeFrame
   {
      
      protected var m_buyCost:Number = 0;
      
      protected var m_voteItemIndex:int = -1;
      
      protected var m_fullCrew:Boolean;
      
      public function VotingBuyPrize(element:DisplayObject, itemName:String, voteItemIndex:int, buyCost:Number, iconURL:String, callbacks:Object, textColor:String = null)
      {
         super(element,itemName,iconURL,callbacks,ItemPrizeFrame.ICON_SIZE,textColor);
         this.m_buyCost = buyCost;
         this.m_voteItemIndex = voteItemIndex;
         this.unlock();
      }
      
      override protected function redeemButtonCallback(event:MouseEvent) : void
      {
         if(m_callbacks != null && m_callbacks.hasOwnProperty("redeemVoteItem"))
         {
            m_callbacks.redeemVoteItem(m_itemName,this.m_voteItemIndex);
         }
      }
      
      override protected function getBuyCost() : Number
      {
         return this.m_buyCost;
      }
      
      override protected function canBeRedeemed() : Boolean
      {
         return false;
      }
      
      override protected function getBuyButtonText() : String
      {
         return ZLocUtils.t("Dialogs","Buy");
      }
      
      public function unlock() : void
      {
         if(this.canBeRedeemed())
         {
            m_state = ItemPrizeFrame.STATE_REDEEM;
         }
         else if(this.m_buyCost > 0)
         {
            m_state = ItemPrizeFrame.STATE_BUY;
         }
         else
         {
            m_state = ItemPrizeFrame.STATE_NO_ACTIONS;
         }
         refreshUI();
      }
      
      public function showCheckMark() : void
      {
         if(m_element.hasOwnProperty("checked_mc") && Boolean(m_element.checked_mc))
         {
            m_element.checked_mc.visible = true;
         }
      }
   }
}

