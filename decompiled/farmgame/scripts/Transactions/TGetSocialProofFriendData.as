package Transactions
{
   import Classes.Constants.Experiments;
   
   public class TGetSocialProofFriendData extends TFarmTransaction
   {
      
      public static const SOCIAL_PROOF_FRIEND_DATA:String = "socialProofFriendData";
      
      public static const SOCIAL_PROOF_NUM_RECENTLY_PAID_FRIENDS:String = "numRecentlyPaidFriends";
      
      public function TGetSocialProofFriendData()
      {
         super();
      }
      
      override public function perform() : void
      {
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_SOCIAL_PROOF_IMPULSE_BUY) > 1)
         {
            signedCall("SocialProofService.getSocialProofFriendData");
         }
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result != null)
         {
            if(result.hasOwnProperty(SOCIAL_PROOF_FRIEND_DATA) && result[SOCIAL_PROOF_FRIEND_DATA] as Array != null && (result[SOCIAL_PROOF_FRIEND_DATA] as Array).length > 0)
            {
               Global.player.setSocialProofFacepileData(result[SOCIAL_PROOF_FRIEND_DATA]);
            }
            if(result.hasOwnProperty(SOCIAL_PROOF_NUM_RECENTLY_PAID_FRIENDS) && result[SOCIAL_PROOF_NUM_RECENTLY_PAID_FRIENDS] > 0)
            {
               Global.player.numRecentlyPaidFriends = result[SOCIAL_PROOF_NUM_RECENTLY_PAID_FRIENDS];
            }
         }
      }
   }
}

