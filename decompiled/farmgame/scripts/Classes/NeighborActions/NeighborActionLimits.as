package Classes.NeighborActions
{
   import Classes.ZItem.BuildingItem;
   import Classes.util.FarmGameUtil;
   import GameMode.GMSetAltGraphic;
   
   public class NeighborActionLimits
   {
      
      private var m_neighborActionLimitData:Object = null;
      
      private var m_queuedFarmActions:int = 0;
      
      private var m_queuedFeedActions:int = 0;
      
      private var m_queuedGiftActions:int = 0;
      
      private var m_queuedAnimalFeedActions:int = 0;
      
      private var m_queuedHarvestCandyActions:int = 0;
      
      private var m_queuedHarvestTicketsActions:int = 0;
      
      private var m_queuedTrickNeighborActions:int = 0;
      
      private var m_farmActionCount:int = 0;
      
      private var m_feedActionCount:int = 0;
      
      private var m_giftActionCount:int = 0;
      
      private var m_animalFeedActionCount:int = 0;
      
      private var m_harvestCandyActionCount:int = 0;
      
      private var m_harvestTicketsActionCount:int = 0;
      
      private var m_trickNeighborActionCount:int = 0;
      
      private var m_farmActionLimit:int = 0;
      
      private var m_feedActionLimit:int = 0;
      
      private var m_giftActionLimit:int = 0;
      
      private var m_animalFeedActionLimit:int = 0;
      
      private var m_harvestCandyActionLimit:int = 0;
      
      private var m_harvestTicketsActionLimit:int = 0;
      
      private var m_trickNeighborActionLimit:int = 0;
      
      private var m_currentHostLimits:Object;
      
      private var m_dynamicActionCounts:Object;
      
      private var m_dynamicActionLimits:Object;
      
      private var m_queuedDynamicActions:Object;
      
      public function NeighborActionLimits(neighborActionLimitData:Object, actionableFeatureBuildings:Array)
      {
         var building:BuildingItem = null;
         var key:String = null;
         var limit:int = 0;
         this.m_dynamicActionCounts = {};
         this.m_dynamicActionLimits = {};
         this.m_queuedDynamicActions = {};
         super();
         this.m_neighborActionLimitData = neighborActionLimitData || {};
         this.m_farmActionLimit = Global.farmGameSettingsManager.getInt("neighborActionLimitFarm",5);
         this.m_feedActionLimit = Global.farmGameSettingsManager.getInt("neighborActionLimitFeed",1);
         this.m_giftActionLimit = Global.farmGameSettingsManager.getInt("neighborActionLimitGift",1);
         this.m_animalFeedActionLimit = Global.farmGameSettingsManager.getInt("neighborActionLimitAnimalFeed",1);
         this.m_harvestCandyActionLimit = Global.farmGameSettingsManager.getInt("neighborActionLimitHarvestCandy",1);
         this.m_harvestTicketsActionLimit = Global.farmGameSettingsManager.getInt("neighborActionLimitHarvestTickets",1);
         this.m_trickNeighborActionLimit = Global.farmGameSettingsManager.getInt("neighborActionLimitTrickneighbor",5);
         if(actionableFeatureBuildings)
         {
            for each(building in actionableFeatureBuildings)
            {
               key = building.neighborActionKey;
               limit = building.neighborActionLimit;
               if(key)
               {
                  this.m_dynamicActionLimits[key] = limit;
               }
            }
         }
      }
      
      public function loadActionLimits(hostUserId:String) : void
      {
         var actionKey:String = null;
         var dateKey:String = null;
         var perUserLimitData:Object = null;
         this.m_queuedFarmActions = 0;
         this.m_queuedFeedActions = 0;
         this.m_queuedGiftActions = 0;
         this.m_queuedAnimalFeedActions = 0;
         this.m_queuedTrickNeighborActions = 0;
         this.m_farmActionCount = 0;
         this.m_feedActionCount = 0;
         this.m_giftActionCount = 0;
         this.m_animalFeedActionCount = 0;
         this.m_harvestCandyActionCount = 0;
         this.m_harvestTicketsActionCount = 0;
         this.m_trickNeighborActionCount = 0;
         for(actionKey in this.m_dynamicActionLimits)
         {
            this.m_dynamicActionCounts[actionKey] = 0;
            this.m_queuedDynamicActions[actionKey] = 0;
         }
         dateKey = FarmGameUtil.getYearMonthDayInUTC();
         this.m_currentHostLimits = null;
         if(Boolean(hostUserId) && Boolean(this.m_neighborActionLimitData))
         {
            if(null != this.m_neighborActionLimitData[dateKey])
            {
               for each(perUserLimitData in this.m_neighborActionLimitData[dateKey])
               {
                  if(perUserLimitData["targetId"] == hostUserId)
                  {
                     this.m_currentHostLimits = perUserLimitData;
                     this.m_farmActionCount = int(perUserLimitData[NeighborActionConstants.LIMIT_TYPE_FARM_ACTION]) || this.m_farmActionCount;
                     this.m_feedActionCount = int(perUserLimitData[NeighborActionConstants.LIMIT_TYPE_FEED_ACTION]) || this.m_feedActionCount;
                     this.m_giftActionCount = int(perUserLimitData[NeighborActionConstants.LIMIT_TYPE_GIFT_ACTION]) || this.m_giftActionCount;
                     this.m_animalFeedActionCount = int(perUserLimitData[NeighborActionConstants.LIMIT_TYPE_SEND_ANIMAL_FEED]) || this.m_animalFeedActionCount;
                     this.m_harvestCandyActionCount = int(perUserLimitData[NeighborActionConstants.LIMIT_TYPE_HARVEST_HALLOWEEN_CANDY]) || this.m_harvestCandyActionCount;
                     this.m_harvestTicketsActionCount = int(perUserLimitData[NeighborActionConstants.LIMIT_TYPE_HARVEST_HALLOWEEN_TICKETS]) || this.m_harvestTicketsActionCount;
                     this.m_trickNeighborActionCount = int(perUserLimitData[NeighborActionConstants.LIMIT_TYPE_TRICK_NEIGHBOR_ACTION]) || this.m_trickNeighborActionCount;
                     for(actionKey in this.m_dynamicActionLimits)
                     {
                        this.m_dynamicActionCounts[actionKey] = perUserLimitData[actionKey] || this.m_dynamicActionCounts[actionKey];
                     }
                  }
               }
            }
            else
            {
               this.m_neighborActionLimitData[dateKey] = {};
            }
            if(null == this.m_currentHostLimits)
            {
               this.m_currentHostLimits = this.m_neighborActionLimitData[dateKey][hostUserId] = {"targetId":hostUserId};
            }
         }
      }
      
      public function queueAction(limitType:String, actionKey:String = null) : void
      {
         switch(limitType)
         {
            case NeighborActionConstants.LIMIT_TYPE_FARM_ACTION:
               this.m_queuedFarmActions += 1;
               break;
            case NeighborActionConstants.LIMIT_TYPE_FEED_ACTION:
               this.m_queuedFeedActions += 1;
               break;
            case NeighborActionConstants.LIMIT_TYPE_GIFT_ACTION:
               this.m_queuedGiftActions += 1;
               break;
            case NeighborActionConstants.LIMIT_TYPE_SEND_ANIMAL_FEED:
               this.m_queuedAnimalFeedActions += 1;
               break;
            case NeighborActionConstants.LIMIT_TYPE_HARVEST_HALLOWEEN_CANDY:
               this.m_queuedHarvestCandyActions += 1;
               break;
            case NeighborActionConstants.LIMIT_TYPE_HARVEST_HALLOWEEN_TICKETS:
               this.m_queuedHarvestTicketsActions += 1;
               break;
            case NeighborActionConstants.LIMIT_TYPE_TRICK_NEIGHBOR_ACTION:
               this.m_queuedTrickNeighborActions += 1;
               break;
            case NeighborActionConstants.LIMIT_TYPE_DYNAMIC:
               this.m_queuedDynamicActions[actionKey] += 1;
         }
      }
      
      public function getAvailableActionCount(limitType:String, actionKey:String = null) : int
      {
         var result:int = 0;
         switch(limitType)
         {
            case NeighborActionConstants.LIMIT_TYPE_FARM_ACTION:
               result = this.m_farmActionLimit - (this.m_farmActionCount + this.m_queuedFarmActions);
               break;
            case NeighborActionConstants.LIMIT_TYPE_FEED_ACTION:
               result = this.m_feedActionLimit - (this.m_feedActionCount + this.m_queuedFeedActions);
               break;
            case NeighborActionConstants.LIMIT_TYPE_GIFT_ACTION:
               result = this.m_giftActionLimit - (this.m_giftActionCount + this.m_queuedGiftActions);
               break;
            case NeighborActionConstants.LIMIT_TYPE_SEND_ANIMAL_FEED:
               result = this.m_animalFeedActionLimit - (this.m_animalFeedActionCount + this.m_queuedAnimalFeedActions);
               break;
            case NeighborActionConstants.LIMIT_TYPE_HARVEST_HALLOWEEN_CANDY:
               result = this.m_harvestCandyActionLimit - (this.m_harvestCandyActionCount + this.m_queuedHarvestCandyActions);
               break;
            case NeighborActionConstants.LIMIT_TYPE_HARVEST_HALLOWEEN_TICKETS:
               result = this.m_harvestTicketsActionLimit - (this.m_harvestTicketsActionCount + this.m_queuedHarvestTicketsActions);
               break;
            case NeighborActionConstants.LIMIT_TYPE_TRICK_NEIGHBOR_ACTION:
               result = this.m_trickNeighborActionLimit - (this.m_trickNeighborActionCount + this.m_queuedTrickNeighborActions);
               break;
            case NeighborActionConstants.LIMIT_TYPE_DYNAMIC:
               result = this.m_dynamicActionLimits[actionKey] - (this.m_dynamicActionCounts[actionKey] + this.m_queuedDynamicActions[actionKey]);
         }
         return result;
      }
      
      public function checkWithinActionLimits(limitType:String, actionKey:String = null) : Boolean
      {
         var result:Boolean = false;
         switch(limitType)
         {
            case NeighborActionConstants.LIMIT_TYPE_FARM_ACTION:
               result = this.m_farmActionCount < this.m_farmActionLimit;
               break;
            case NeighborActionConstants.LIMIT_TYPE_FEED_ACTION:
               result = this.m_feedActionCount < this.m_feedActionLimit;
               break;
            case NeighborActionConstants.LIMIT_TYPE_GIFT_ACTION:
               result = this.m_giftActionCount < this.m_giftActionLimit;
               break;
            case NeighborActionConstants.LIMIT_TYPE_SEND_ANIMAL_FEED:
               result = this.m_animalFeedActionCount < this.m_animalFeedActionLimit;
               break;
            case NeighborActionConstants.LIMIT_TYPE_HARVEST_HALLOWEEN_CANDY:
               result = this.m_harvestCandyActionCount < this.m_harvestCandyActionLimit;
               break;
            case NeighborActionConstants.LIMIT_TYPE_HARVEST_HALLOWEEN_TICKETS:
               result = this.m_harvestTicketsActionCount < this.m_harvestTicketsActionLimit;
               break;
            case NeighborActionConstants.LIMIT_TYPE_TRICK_NEIGHBOR_ACTION:
               result = this.m_trickNeighborActionCount < this.m_trickNeighborActionLimit;
               break;
            case NeighborActionConstants.LIMIT_TYPE_DYNAMIC:
               result = this.m_dynamicActionCounts[actionKey] < this.m_dynamicActionLimits[actionKey];
         }
         return result;
      }
      
      public function checkWithinActionLimitsQueued(limitType:String, actionKey:String = null) : Boolean
      {
         var result:Boolean = false;
         switch(limitType)
         {
            case NeighborActionConstants.LIMIT_TYPE_FARM_ACTION:
               result = this.m_farmActionCount + this.m_queuedFarmActions < this.m_farmActionLimit;
               break;
            case NeighborActionConstants.LIMIT_TYPE_FEED_ACTION:
               result = this.m_feedActionCount + this.m_queuedFeedActions < this.m_feedActionLimit;
               break;
            case NeighborActionConstants.LIMIT_TYPE_GIFT_ACTION:
               result = this.m_giftActionCount + this.m_queuedGiftActions < this.m_giftActionLimit;
               break;
            case NeighborActionConstants.LIMIT_TYPE_SEND_ANIMAL_FEED:
               result = this.m_animalFeedActionCount + this.m_queuedAnimalFeedActions < this.m_animalFeedActionLimit;
               break;
            case NeighborActionConstants.LIMIT_TYPE_HARVEST_HALLOWEEN_CANDY:
               result = this.m_harvestCandyActionCount + this.m_queuedHarvestCandyActions < this.m_harvestCandyActionLimit;
               break;
            case NeighborActionConstants.LIMIT_TYPE_HARVEST_HALLOWEEN_TICKETS:
               result = this.m_harvestTicketsActionCount + this.m_queuedHarvestTicketsActions < this.m_harvestTicketsActionLimit;
               break;
            case NeighborActionConstants.LIMIT_TYPE_TRICK_NEIGHBOR_ACTION:
               result = this.m_trickNeighborActionCount + this.m_queuedTrickNeighborActions < Math.min(this.m_trickNeighborActionLimit,(Global.world.getTopGameMode() as GMSetAltGraphic).numSelectableObjects);
               break;
            case NeighborActionConstants.LIMIT_TYPE_DYNAMIC:
               result = this.m_dynamicActionCounts[actionKey] + this.m_queuedDynamicActions[actionKey] < this.m_dynamicActionLimits[actionKey];
         }
         return result;
      }
      
      public function incrementActionCount(limitType:String, actionKey:String = null) : void
      {
         switch(limitType)
         {
            case NeighborActionConstants.LIMIT_TYPE_FARM_ACTION:
               this.m_farmActionCount += 1;
               --this.m_queuedFarmActions;
               this.m_currentHostLimits[NeighborActionConstants.LIMIT_TYPE_FARM_ACTION] = this.m_farmActionCount;
               break;
            case NeighborActionConstants.LIMIT_TYPE_FEED_ACTION:
               this.m_feedActionCount += 1;
               --this.m_queuedFeedActions;
               this.m_currentHostLimits[NeighborActionConstants.LIMIT_TYPE_FEED_ACTION] = this.m_feedActionCount;
               break;
            case NeighborActionConstants.LIMIT_TYPE_GIFT_ACTION:
               this.m_giftActionCount += 1;
               --this.m_queuedGiftActions;
               this.m_currentHostLimits[NeighborActionConstants.LIMIT_TYPE_GIFT_ACTION] = this.m_giftActionCount;
               break;
            case NeighborActionConstants.LIMIT_TYPE_SEND_ANIMAL_FEED:
               this.m_animalFeedActionCount += 1;
               --this.m_queuedAnimalFeedActions;
               this.m_currentHostLimits[NeighborActionConstants.LIMIT_TYPE_SEND_ANIMAL_FEED] = this.m_animalFeedActionCount;
               break;
            case NeighborActionConstants.LIMIT_TYPE_HARVEST_HALLOWEEN_CANDY:
               this.m_harvestCandyActionCount += 1;
               --this.m_queuedHarvestCandyActions;
               this.m_currentHostLimits[NeighborActionConstants.LIMIT_TYPE_HARVEST_HALLOWEEN_CANDY] = this.m_harvestCandyActionCount;
               break;
            case NeighborActionConstants.LIMIT_TYPE_HARVEST_HALLOWEEN_TICKETS:
               this.m_harvestTicketsActionCount += 1;
               --this.m_queuedHarvestTicketsActions;
               this.m_currentHostLimits[NeighborActionConstants.LIMIT_TYPE_HARVEST_HALLOWEEN_TICKETS] = this.m_harvestTicketsActionCount;
               break;
            case NeighborActionConstants.LIMIT_TYPE_TRICK_NEIGHBOR_ACTION:
               this.m_trickNeighborActionCount += 1;
               --this.m_queuedTrickNeighborActions;
               this.m_currentHostLimits[NeighborActionConstants.LIMIT_TYPE_TRICK_NEIGHBOR_ACTION] = this.m_trickNeighborActionCount;
               break;
            case NeighborActionConstants.LIMIT_TYPE_DYNAMIC:
               this.m_dynamicActionCounts[actionKey] += 1;
               this.m_queuedDynamicActions[actionKey] = this.m_queuedDynamicActions[actionKey] - 1;
               this.m_currentHostLimits[actionKey] = this.m_dynamicActionCounts[actionKey];
         }
      }
   }
}

