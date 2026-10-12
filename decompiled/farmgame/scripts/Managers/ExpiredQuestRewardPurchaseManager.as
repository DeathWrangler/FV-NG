package Managers
{
   import Classes.Constants.Experiments;
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmQuestSettingsInit;
   import Classes.ZItem.FarmItem;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Widgets.Constants.Market.Currency;
   import Widgets.Windows.ExpiredQuestRewardPurchaseWindow;
   
   public class ExpiredQuestRewardPurchaseManager
   {
      
      public function ExpiredQuestRewardPurchaseManager()
      {
         super();
      }
      
      public static function showDialog(quest:FarmQuest) : void
      {
         var statString:String = quest.chapter.toString() + "," + quest.questNumber.toString();
         StatsManager.count(ExpiredQuestRewardPurchaseWindow.QUEST_RECAPTURE_STATS_COUNTER,quest.chain,"attempting_to_show",statString);
         var numSlots:int = 3;
         var variant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_QUEST_RECAPTURE);
         if(variant == 3)
         {
            numSlots = 8;
         }
         var data:Array = ExpiredQuestRewardPurchaseManager.setupData(quest,numSlots);
         if(data.length > 0)
         {
            UI.displayPopup(new ExpiredQuestRewardPurchaseWindow(quest,data));
         }
      }
      
      private static function setupData(quest:FarmQuest, numSlots:int) : Array
      {
         var rewards:Array = ExpiredQuestRewardPurchaseManager.generateRewardData(quest);
         return ExpiredQuestRewardPurchaseManager.filterRewards(rewards,numSlots);
      }
      
      private static function generateRewardData(quest:FarmQuest) : Array
      {
         var rewards:Vector.<Object> = null;
         var reward:Object = null;
         var children:Vector.<Object> = null;
         var child:Object = null;
         var childQuest:FarmQuest = null;
         var questRewards:Array = new Array();
         if(quest.progress != 1)
         {
            rewards = quest.farmRewards;
            for each(reward in rewards)
            {
               if(reward["type"] == "item_grant")
               {
                  questRewards.push(reward["value"]);
               }
            }
            children = quest.children;
            for each(child in children)
            {
               childQuest = FarmQuestSettingsInit.getInstance().getItemByName(child["value"]) as FarmQuest;
               questRewards = questRewards.concat(ExpiredQuestRewardPurchaseManager.generateRewardData(childQuest));
            }
         }
         return questRewards;
      }
      
      private static function filterRewards(rewards:Array, numSlots:int) : Array
      {
         var filteredRewards:Array = null;
         var reward:String = null;
         var item:FarmItem = null;
         var bucket:int = 0;
         var rewardBuckets:Array = new Array();
         for each(reward in rewards)
         {
            item = Global.farmGameSettingsManager.getFarmItemByCode(reward);
            bucket = ExpiredQuestRewardPurchaseManager.findBucket(item);
            if(bucket >= 0)
            {
               if(!rewardBuckets[bucket])
               {
                  rewardBuckets[bucket] = new Array();
               }
               rewardBuckets[bucket].push(item);
            }
         }
         return ExpiredQuestRewardPurchaseManager.processBuckets(rewardBuckets,numSlots);
      }
      
      private static function findBucket(item:FarmItem) : int
      {
         var result:int = -1;
         if(item.currency == Currency.CASH && item.buyable == true)
         {
            if(item.cash <= 10)
            {
               result = 2;
            }
            else if(item.cash <= 15)
            {
               result = 1;
            }
            else
            {
               result = 0;
            }
         }
         return result;
      }
      
      private static function processBuckets(buckets:Array, numSlots:int) : Array
      {
         var rewardList:Array = new Array();
         var counter:int = 0;
         var iterator:int = 0;
         do
         {
            if(Boolean(buckets[iterator]) && buckets[iterator].length > 0)
            {
               rewardList.push(buckets[iterator].pop());
               counter += 1;
            }
            iterator += 1;
            if(iterator > buckets.length)
            {
               iterator = 0;
            }
         }
         while(counter < numSlots && ExpiredQuestRewardPurchaseManager.bucketSize(buckets) > 0);
         rewardList.sort(ExpiredQuestRewardPurchaseManager.priceSort);
         return rewardList;
      }
      
      private static function bucketSize(buckets:Array) : int
      {
         var bucket:Array = null;
         var total:int = 0;
         for each(bucket in buckets)
         {
            total += bucket.length;
         }
         return total;
      }
      
      private static function priceSort(objA:Object, objB:Object) : int
      {
         var result:int = 0;
         var itemA:FarmItem = objA as FarmItem;
         var itemB:FarmItem = objB as FarmItem;
         if(itemA.cash > itemB.cash)
         {
            result = 1;
         }
         else if(itemA.cash < itemB.cash)
         {
            result = -1;
         }
         return result;
      }
   }
}

