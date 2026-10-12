package Transactions
{
   public class TMarkSeenSocialActions extends TFarmTransaction
   {
      
      private var m_socialActionIds:Array;
      
      public function TMarkSeenSocialActions(actionIds:Array)
      {
         super();
         this.m_socialActionIds = actionIds;
      }
      
      override public function perform() : void
      {
         signedCall("SocialActionsService.markSeenActions",this.m_socialActionIds);
      }
   }
}

