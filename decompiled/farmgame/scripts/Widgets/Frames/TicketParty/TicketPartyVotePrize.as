package Widgets.Frames.TicketParty
{
   import Classes.util.ZLocUtils;
   import Managers.VotingDataManager;
   import Widgets.Frames.ItemPrizeFrame;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class TicketPartyVotePrize extends ItemPrizeFrame
   {
      
      protected var m_featureName:String = "";
      
      protected var m_buyCost:Number = 0;
      
      protected var m_voteItemIndex:int = -1;
      
      protected var m_fullCrew:Boolean;
      
      public function TicketPartyVotePrize(element:DisplayObject, itemName:String, voteItemIndex:int, buyCost:Number, iconURL:String, featureName:String, callbacks:Object, fullCrew:Boolean, textColor:String = null)
      {
         super(element,itemName,iconURL,callbacks,ItemPrizeFrame.ICON_SIZE,textColor);
         this.m_buyCost = buyCost;
         this.m_voteItemIndex = voteItemIndex;
         this.m_fullCrew = fullCrew;
         this.m_featureName = featureName;
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
         return this.m_fullCrew && !VotingDataManager.getInstance().isItemCollected(this.m_featureName,m_itemName);
      }
      
      override protected function getBuyButtonText() : String
      {
         return ZLocUtils.t("Dialogs","CompleteNowCamel");
      }
      
      public function unlock() : void
      {
         var stageUnlocked:Boolean = VotingDataManager.getInstance().isCurrentStageUnlocked(this.m_featureName);
         if(stageUnlocked && this.canBeRedeemed())
         {
            m_state = ItemPrizeFrame.STATE_REDEEM;
         }
         else if(stageUnlocked && this.m_buyCost > 0)
         {
            m_state = ItemPrizeFrame.STATE_BUY;
         }
         else
         {
            m_state = ItemPrizeFrame.STATE_NO_ACTIONS;
         }
         refreshUI();
      }
   }
}

