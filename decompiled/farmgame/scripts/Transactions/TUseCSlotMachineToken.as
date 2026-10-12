package Transactions
{
   import Classes.FeatureBuilding;
   
   public class TUseCSlotMachineToken extends TUseTargetedConsumable
   {
      
      public function TUseCSlotMachineToken(itemName:String, targetObjectId:Number, isGift:Boolean = true, userID:String = "", isFree:Boolean = false, showGiftDialog:Boolean = false)
      {
         super(itemName,targetObjectId,isGift,userID,isFree,showGiftDialog);
      }
      
      override protected function onComplete(result:Object) : void
      {
         super.onComplete(result);
         var lastTransactionResult:Object = {};
         var featureBuilding:FeatureBuilding = Global.world.getObjectById(targetObjectId()) as FeatureBuilding;
         if(Boolean(featureBuilding) && Boolean(featureBuilding.slotmachine))
         {
            lastTransactionResult = featureBuilding.slotmachine.lastTransactionResult;
         }
         if(Boolean(result) && Boolean(result.hasOwnProperty("success")) && Boolean(result.success))
         {
            if(result.success.hasOwnProperty("xpGain"))
            {
               lastTransactionResult.xpGain = result.success.xpGain;
               lastTransactionResult.xpAnimationPlayed = false;
            }
            if(result.success.hasOwnProperty("lootItemName"))
            {
               lastTransactionResult.lootItemName = result.success.lootItemName;
               lastTransactionResult.lootItemAnimationPlayed = false;
            }
            if(Boolean(result.success.hasOwnProperty("storageData")) && Boolean(result.success.storageData))
            {
               Global.player.refreshGiftBox(result.success.storageData);
            }
            if(result.success.hasOwnProperty("lootRewardURL"))
            {
               lastTransactionResult.lootRewardURL = result.success.lootRewardURL;
            }
         }
         if(Boolean(featureBuilding) && Boolean(featureBuilding.slotmachine))
         {
            featureBuilding.slotmachine.lastTransactionResult = lastTransactionResult;
         }
      }
      
      override protected function updateCollectionCounters(result:Object) : void
      {
         var counterIdx:int = 0;
         var collectableCode:String = null;
         var collectableCount:int = 0;
         var rewardLink:String = null;
         super.updateCollectionCounters(result);
         var lastCollectableCounters:Array = [];
         if(null != result.collectionCounters)
         {
            for(counterIdx = 0; counterIdx < result.collectionCounters.length; counterIdx++)
            {
               collectableCode = result.collectionCounters[counterIdx]["collectable"];
               collectableCount = int(result.collectionCounters[counterIdx]["count"]);
               rewardLink = result.collectionCounters[counterIdx]["link"];
               Global.player.collectionCounters[collectableCode] = collectableCount;
               lastCollectableCounters[collectableCode] = {
                  "count":collectableCount,
                  "link":rewardLink
               };
            }
         }
         var featureBuilding:FeatureBuilding = Global.world.getObjectById(targetObjectId()) as FeatureBuilding;
         if(Boolean(featureBuilding) && Boolean(featureBuilding.slotmachine))
         {
            featureBuilding.slotmachine.lastCollectionCountersUpdate = lastCollectableCounters;
         }
      }
   }
}

