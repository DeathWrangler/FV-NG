package Classes.Collections
{
   import Classes.GameSettingsObject;
   import Classes.util.FarmGameUtil;
   
   public class Collection extends GameSettingsObject
   {
      
      public static const DEFAULT_COLLECTION_EXPIRING_DAYS:Number = 7;
      
      public static const TYPE_PERMANENT:String = "permanent";
      
      public static const TYPE_LIGHTNING:String = "lightning";
      
      public static const TYPE_SLOTMACHINE:String = "slotmachine";
      
      public static const TYPE_ANIMAL_BREEDING:String = "breeding";
      
      public static const TYPE_FISHING:String = "fishing";
      
      public static const TYPE_LE:String = "LE";
      
      public static const TYPE_BREEDING:String = "breeding";
      
      public static const COLLECTIBLE_OBTAINED:String = "collectible_obtained_";
      
      protected var m_collectibleList:Array = new Array();
      
      protected var m_rewardList:Array = new Array();
      
      protected var m_startTime:String;
      
      protected var m_endTime:String;
      
      protected var m_tradeInRewards:Array;
      
      public function Collection(xml:XML)
      {
         super(xml);
         this.buildCollectibleList();
         this.buildRewardList();
         this.getStartAndEndDates();
      }
      
      public static function isSlotMachineCollection(collection:Collection) : Boolean
      {
         return collection.type == Collection.TYPE_SLOTMACHINE;
      }
      
      private function buildCollectibleList() : void
      {
         var newCollectible:Collectible = null;
         var collectables:XMLList = this.getCollectablesXMLList();
         this.m_collectibleList = new Array();
         for(var collectIndex:int = 0; collectIndex < collectables.length(); collectIndex++)
         {
            newCollectible = new Collectible(collectables[collectIndex]);
            this.m_collectibleList.push(newCollectible);
         }
      }
      
      private function buildRewardList() : void
      {
         var newReward:Reward = null;
         var tradeInRewardIndex:int = 0;
         var newTradeInReward:Reward = null;
         var rewards:XMLList = this.getRewardsXML();
         this.m_rewardList = new Array();
         for(var rewardIndex:int = 0; rewardIndex < rewards.length(); rewardIndex++)
         {
            newReward = new Reward(rewards[rewardIndex]);
            this.m_rewardList.push(newReward);
         }
         var tradeInRewards:XMLList = m_xml.tradeInReward;
         this.m_tradeInRewards = new Array();
         if(tradeInRewards.length() > 0)
         {
            for(tradeInRewardIndex = 0; tradeInRewardIndex < tradeInRewards.length(); tradeInRewardIndex++)
            {
               newTradeInReward = new Reward(tradeInRewards[tradeInRewardIndex]);
               this.m_tradeInRewards.push(newTradeInReward);
            }
         }
      }
      
      private function getStartAndEndDates() : void
      {
         if(m_xml.@startDate)
         {
            this.m_startTime = m_xml.@startDate;
         }
         if(m_xml.@endDate)
         {
            this.m_endTime = m_xml.@endDate;
         }
      }
      
      public function get collectibleCount() : Number
      {
         return this.m_collectibleList.length;
      }
      
      override protected function getFriendlyNameLocFile() : String
      {
         return "Collections";
      }
      
      public function get code() : String
      {
         return m_xml.@code;
      }
      
      public function get type() : String
      {
         return m_xml.@type;
      }
      
      public function get icon() : String
      {
         return m_xml.@icon;
      }
      
      public function getWeight() : Number
      {
         var result:Number = 0;
         var serverTime:Number = Math.round(GlobalEngine.serverTime / 1000);
         if(serverTime - Global.player.getFeatureLastShown(COLLECTIBLE_OBTAINED + this.name) < FarmGameUtil.NUM_SECS_IN_DAY)
         {
            result = Number(m_xml.@altWeight);
         }
         else
         {
            result = Number(m_xml.@weight);
         }
         return result;
      }
      
      public function getLevel() : Number
      {
         if(Global.player.collectionLevels[name] == null)
         {
            Global.player.collectionLevels[name] = 0;
         }
         return Global.player.collectionLevels[name];
      }
      
      public function get expireTimeSecs() : Number
      {
         var result:Number = 0;
         if(m_xml.@endDate)
         {
            result = FarmGameUtil.synchronizedDateToNumber(m_xml.@endDate) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         }
         return result;
      }
      
      public function get world() : String
      {
         var result:String = null;
         var worldNameFromData:String = m_xml.attribute("world").toString();
         if(worldNameFromData != null && worldNameFromData != "")
         {
            result = worldNameFromData;
         }
         else
         {
            result = Global.worldManager.currentWorldType;
         }
         return result;
      }
      
      public function getTotalCollectablesCount() : int
      {
         return this.m_collectibleList.length;
      }
      
      public function getCurrentUniqueCollectablesCount() : int
      {
         var currCollectible:Collectible = null;
         var count:int = 0;
         for(var collectIndex:int = 0; collectIndex < this.m_collectibleList.length; collectIndex++)
         {
            currCollectible = this.m_collectibleList[collectIndex];
            if(currCollectible)
            {
               if(null != Global.player.collectionCounters[currCollectible.code] && Global.player.collectionCounters[currCollectible.code] > 0)
               {
                  count++;
               }
            }
         }
         return count;
      }
      
      public function isCollectionStored() : Boolean
      {
         var result:Boolean = false;
         if(this.xml.@type != TYPE_PERMANENT)
         {
            if(Global.player.storedCollections.hasOwnProperty(this.code))
            {
               result = true;
            }
         }
         return result;
      }
      
      public function isCollectionComplete() : Boolean
      {
         var collectIndex:int = 0;
         var currCollectible:Collectible = null;
         var collectible:Collectible = null;
         var result:Boolean = false;
         if(this.type == TYPE_SLOTMACHINE || this.type == TYPE_LE)
         {
            result = this.getCurrentUniqueCollectablesCount() == this.getTotalCollectablesCount();
         }
         else if(this.type == TYPE_LIGHTNING)
         {
            result = true;
            for(collectIndex = 0; collectIndex < this.m_collectibleList.length; collectIndex++)
            {
               currCollectible = this.m_collectibleList[collectIndex];
               if(currCollectible)
               {
                  if(null == Global.player.collectionCounters[currCollectible.code])
                  {
                     result = false;
                     break;
                  }
                  if(Global.player.collectionCounters[currCollectible.code] < currCollectible.numNeeded)
                  {
                     result = false;
                     break;
                  }
               }
            }
         }
         else
         {
            result = true;
            for each(collectible in this.m_collectibleList)
            {
               if(collectible.numNeeded > collectible.numOwned)
               {
                  result = false;
                  break;
               }
            }
         }
         return result;
      }
      
      public function getCashBuyAllAmount() : int
      {
         var tempSum:int = 0;
         var numNeeded:int = 0;
         var currentCount:int = 0;
         var collectIndex:int = 0;
         var currCollectible:Collectible = null;
         var collectibles:Array = null;
         var collectible:Collectible = null;
         var numOwned:Number = NaN;
         var needed:Number = NaN;
         var cashForCollectible:Number = NaN;
         var result:int = 0;
         if(this.type == TYPE_LIGHTNING)
         {
            tempSum = 0;
            numNeeded = 0;
            currentCount = 0;
            for(collectIndex = 0; collectIndex < this.m_collectibleList.length; collectIndex++)
            {
               currCollectible = this.m_collectibleList[collectIndex];
               if(currCollectible)
               {
                  numNeeded = currCollectible.numNeeded;
                  if(null != Global.player.collectionCounters[currCollectible.code])
                  {
                     currentCount = parseInt(Global.player.collectionCounters[currCollectible.code]);
                  }
                  else
                  {
                     currentCount = 0;
                  }
                  if(currentCount < numNeeded)
                  {
                     tempSum = (numNeeded - currentCount) * currCollectible.cashCost;
                  }
                  result += tempSum;
                  tempSum = 0;
               }
            }
         }
         else
         {
            collectibles = this.getCollectibles();
            for each(collectible in collectibles)
            {
               numOwned = collectible.numOwned;
               needed = collectible.numNeeded;
               cashForCollectible = Math.max(0,(needed - numOwned) * (collectible.rarityNumber + 1));
               result += cashForCollectible;
            }
         }
         return result;
      }
      
      public function getCollectablesXMLList() : XMLList
      {
         return m_xml.collectable;
      }
      
      public function getRewardsXML() : XMLList
      {
         return m_xml.rewards.reward;
      }
      
      public function getTradeInRewardsXML() : XMLList
      {
         return m_xml.tradeInReward;
      }
      
      public function getCollectableByIndex(index:Number) : Collectible
      {
         var result:Collectible = null;
         if(index >= 0 && index <= this.m_collectibleList.length - 1)
         {
            result = this.m_collectibleList[index];
         }
         return result;
      }
      
      public function getCollectibles() : Array
      {
         return this.m_collectibleList;
      }
      
      public function getRewards() : Array
      {
         return this.m_rewardList;
      }
      
      public function getTradeInRewards() : Array
      {
         return this.m_tradeInRewards;
      }
      
      public function getCollectable(code:String) : Collectible
      {
         var currCollectible:Collectible = null;
         var result:Collectible = null;
         for(var collectIndex:int = 0; collectIndex < this.m_collectibleList.length; collectIndex++)
         {
            currCollectible = this.m_collectibleList[collectIndex];
            if(Boolean(currCollectible) && currCollectible.code == code)
            {
               result = currCollectible;
               break;
            }
         }
         return result;
      }
      
      public function tradeIn() : Boolean
      {
         var collectIndex:int = 0;
         var currCollectible:Collectible = null;
         var collectCode:String = null;
         var currentCollection:Collection = null;
         var result:Boolean = false;
         if(this.getTotalCollectablesCount() == this.getCurrentUniqueCollectablesCount())
         {
            for(collectIndex = 0; collectIndex < this.m_collectibleList.length; collectIndex++)
            {
               currCollectible = this.m_collectibleList[collectIndex];
               collectCode = currCollectible.code;
               currentCollection = Global.farmGameSettingsManager.getCollectionByCollectableCode(collectCode);
               if(!Collection.isSlotMachineCollection(currentCollection))
               {
                  if(Boolean(currCollectible) && Boolean(null != Global.player.collectionCounters[collectCode]) && Global.player.collectionCounters[collectCode] > 0)
                  {
                     --Global.player.collectionCounters[collectCode];
                  }
               }
            }
            result = true;
         }
         return result;
      }
      
      public function levelUp() : void
      {
         this.decreaseCollectibles();
         if(Global.player.collectionLevels[name] == null)
         {
            Global.player.collectionLevels[name] = 1;
         }
         else
         {
            ++Global.player.collectionLevels[name];
         }
      }
      
      private function decreaseCollectibles() : void
      {
         var collectible:Collectible = null;
         for each(collectible in this.m_collectibleList)
         {
            Global.player.collectionCounters[collectible.code] -= collectible.numNeeded;
         }
      }
      
      public function storeCollection() : Boolean
      {
         var collectables:XMLList = null;
         var numNeeded:int = 0;
         var collectCode:String = null;
         var collectIndex:int = 0;
         var currCollectible:Collectible = null;
         var result:Boolean = false;
         if(this.isCollectionComplete())
         {
            collectables = this.getCollectablesXMLList();
            numNeeded = 0;
            collectCode = "";
            for(collectIndex = 0; collectIndex < this.m_collectibleList.length; collectIndex++)
            {
               currCollectible = this.m_collectibleList[collectIndex];
               if(currCollectible)
               {
                  numNeeded = currCollectible.numNeeded;
                  collectCode = currCollectible.code;
                  if(null == Global.player.collectionCounters[collectCode])
                  {
                     result = false;
                     break;
                  }
                  if(Global.player.collectionCounters[collectCode] >= numNeeded)
                  {
                     Global.player.collectionCounters[collectCode] -= numNeeded;
                  }
                  result = true;
               }
            }
         }
         return result;
      }
      
      public function completedCollection(code:String) : Boolean
      {
         var currentCollectableCount:int = 0;
         var collectIndex:int = 0;
         var currCollectible:Collectible = null;
         var collectCode:String = null;
         var result:Boolean = true;
         if(this.m_collectibleList.length > 0 && null != Global.player.collectionCounters[code] && Global.player.collectionCounters[code] > 0)
         {
            currentCollectableCount = int(Global.player.collectionCounters[code]);
            for(collectIndex = 0; collectIndex < this.m_collectibleList.length; collectIndex++)
            {
               currCollectible = this.m_collectibleList[collectIndex];
               if(currCollectible)
               {
                  collectCode = currCollectible.code;
                  if(null == Global.player.collectionCounters[collectCode] || Global.player.collectionCounters[collectCode] < currentCollectableCount)
                  {
                     result = false;
                     break;
                  }
               }
            }
         }
         else
         {
            result = false;
         }
         return result;
      }
      
      public function isAvailable() : Boolean
      {
         return true;
      }
      
      public function isDateGated() : Boolean
      {
         var serverTime:Number = NaN;
         var startTime:Number = NaN;
         var endTime:Number = NaN;
         var result:Boolean = true;
         if(GlobalEngine.isServerTimeValid())
         {
            serverTime = GlobalEngine.serverTime;
            startTime = FarmGameUtil.synchronizedDateToNumber(this.m_startTime);
            endTime = FarmGameUtil.synchronizedDateToNumber(this.m_endTime);
            result = serverTime >= startTime && serverTime < endTime;
         }
         return result;
      }
      
      public function isExpiring(startDisplayDays:Number = 7) : Boolean
      {
         var result:Boolean = false;
         var newDate:Date = new Date();
         var timeDiff:Number = (this.expireTimeSecs - GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND) / FarmGameUtil.NUM_SECS_IN_HOUR;
         var dayDiff:Number = Math.round(timeDiff / 24);
         if(dayDiff <= startDisplayDays)
         {
            result = true;
         }
         return result;
      }
   }
}

