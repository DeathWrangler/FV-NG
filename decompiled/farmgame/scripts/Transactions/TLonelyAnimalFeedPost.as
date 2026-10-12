package Transactions
{
   import Classes.Constants.Experiments;
   import Classes.ZItem.FarmItem;
   import Classes.util.FacebookSocialNetwork;
   import Classes.util.ZLocUtils;
   import Widgets.Windows.LonelyAnimal.LonelyAnimalWindow;
   
   public class TLonelyAnimalFeedPost extends TFarmTransaction
   {
      
      private var m_itemName:String;
      
      private var m_friendlyName:String;
      
      private var m_friendSetIndex:int;
      
      public function TLonelyAnimalFeedPost(itemName:String, friendlyName:String, friendSetIndex:int)
      {
         this.m_itemName = itemName;
         this.m_friendlyName = friendlyName;
         this.m_friendSetIndex = friendSetIndex;
         super();
      }
      
      override public function perform() : void
      {
         var animalName:String = ZLocUtils.tk_pk_asTitle(this.m_friendlyName);
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_itemName);
         var imageUrl:String = item.getIconUrlFromActiveData(this.m_itemName);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FACEBOOK_FEED_ICONS) > 1)
         {
            imageUrl = item.getImageByName("feed",true);
         }
         signedCall("LonelyCowService.getRewardAndFeedData",animalName,imageUrl,this.m_friendSetIndex);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(Boolean(result) && result.hasOwnProperty("feedData"))
         {
            (GlobalEngine.socialNetwork as FacebookSocialNetwork).publishResultsFromTransaction(result.feedData,this.generateFeedCallback(result));
         }
         else
         {
            super.onComplete(result);
         }
      }
      
      private function generateFeedCallback(transactionResult:Object) : Function
      {
         return function(feedPostingResult:Boolean):void
         {
            var currentTime:* = undefined;
            if(transactionResult == null)
            {
               transactionResult = {};
            }
            transactionResult.postSuccessful = feedPostingResult;
            if(feedPostingResult)
            {
               currentTime = GlobalEngine.serverTime / 1000;
               Global.player.setFeatureLastShown(LonelyAnimalWindow.FEED_POST_FREQUENCY_FLAG,currentTime,true);
            }
            feedCallbackHelper(transactionResult);
         };
      }
      
      private function feedCallbackHelper(result:Object) : void
      {
         super.onComplete(result);
      }
   }
}

