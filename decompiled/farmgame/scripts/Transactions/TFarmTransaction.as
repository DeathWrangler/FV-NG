package Transactions
{
   import Classes.Avatar.AvatarManager;
   import Classes.MapResource;
   import Classes.ZItem.FarmItem;
   import Display.GenericPopup;
   import Display.LockedBoxUncoveredDialog;
   import Display.UI;
   import Engine.Transactions.Transaction;
   import Managers.CollectionsManager;
   import Managers.Crafting.CraftingManager;
   import Managers.TaskListManager;
   import Widgets.Windows.ErrorWindow;
   import flash.events.Event;
   import flash.external.ExternalInterface;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   
   public class TFarmTransaction extends Transaction
   {
      
      public static const CRAFT_MAX_UPDATED:String = "craftingMaxUpdated";
      
      protected const GOAL_TYPE_ACHIEVEMENT:String = "Achievement";
      
      protected const GOAL_TYPE_AVATAR_ACHIEVEMENT:String = "AvatarAchievement";
      
      protected const GOAL_TYPE_MASTERY:String = "Mastery";
      
      protected const GOAL_TYPE_ORGANIC:String = "OrganicCertification";
      
      protected const GOAL_TYPE_RECIPEMASTERY:String = "RecipeMastery";
      
      protected const GOAL_TYPE_FRIENDSET:String = "FriendSetGoal";
      
      protected const GOAL_TYPE_ORGANIC_TOTAL:String = "OrganicCertificationTotal";
      
      protected const PLOT_LOOT_LOCKED_BOX:String = "lockedbox";
      
      private var m_sharePurchaseItem:FarmItem;
      
      private var m_sharePurchaseItemRewardUrl:String;
      
      private var m_transactionLogLoader:URLLoader;
      
      private var m_lastServerErrorLog:String;
      
      public function TFarmTransaction()
      {
         super();
      }
      
      final override protected function onAmfComplete(result:Object) : void
      {
         if(m_preFetch)
         {
            m_rawResult = result;
            postPrefetchActions(result);
         }
         else
         {
            this.onAmfCompleteSteps(result);
         }
      }
      
      public function onAmfCompleteSteps(result:Object) : void
      {
         var message:GenericPopup = null;
         this.fetchLogsForTransaction(result);
         var questComponent:Array = null;
         var actionDrops:Object = null;
         if(rawResult != null && rawResult.metadata != null && rawResult.metadata.QuestComponent != null)
         {
            questComponent = rawResult.metadata.QuestComponent;
         }
         if(rawResult != null && rawResult.metadata != null && rawResult.metadata.ActionDrops != null)
         {
            actionDrops = rawResult.metadata.ActionDrops;
         }
         this.updateWorldTimeFromServer(result);
         super.onAmfComplete(result);
         if(rawResult != null && questComponent != null && rawResult.metadata != null)
         {
            rawResult.metadata.QuestComponent = questComponent;
         }
         if(rawResult != null && actionDrops != null && rawResult.metadata != null)
         {
            rawResult.metadata.ActionDrops = actionDrops;
         }
         if(result)
         {
            if(Boolean(result.goals) || Boolean(result.goalCounters))
            {
               this.handleGoalResponse(result);
            }
            this.updateCraftingState(result);
            this.updateCollectionCounters(result);
            this.updateEvictedGifts(result);
            if(result.plotLootItem)
            {
               if(result.plotLootItem == this.PLOT_LOOT_LOCKED_BOX)
               {
                  message = new LockedBoxUncoveredDialog();
                  message.setAcceptTextName("Okay");
                  UI.displayPopup(message,true,"lockedBoxPopup",true);
                  Global.player.addGift(result.plotLootItem.toString());
               }
            }
            this.updateShareBuyInfo(result);
            this.showRealtimeUserMsg(result);
         }
      }
      
      private function showRealtimeUserMsg(result:Object) : void
      {
         var isCsYellowBoxMsgAutopop:Boolean = Global.flashHotParams["CS_YELLOW_BOX_USER_MSG_AUTOPOP"] as Boolean;
         var isMarketingBlueBoxMsgAutopop:Boolean = Global.flashHotParams["MARKETING_BLUE_BOX_MSG_AUTOPOP"] as Boolean;
         if(isCsYellowBoxMsgAutopop)
         {
            if(result.hasOwnProperty("showIssueBox") && result.showIssueBox == 1)
            {
               ExternalInterface.call("updateCSYellowBox","");
               Global.player.previousCSYellowBoxMsg = "";
               if(result.hasOwnProperty("issueBoxMsg") && Boolean(result.issueBoxMsg))
               {
                  if(Global.player.previousIssueBoxMsg != result.issueBoxMsg)
                  {
                     ExternalInterface.call("updateIssueBox",result.issueBoxMsg);
                     Global.player.previousIssueBoxMsg = result.issueBoxMsg;
                  }
               }
               else
               {
                  ExternalInterface.call("updateIssueBox","");
                  Global.player.previousIssueBoxMsg = "";
               }
            }
            else
            {
               ExternalInterface.call("updateIssueBox","");
               Global.player.previousIssueBoxMsg = "";
               if(result.hasOwnProperty("csYellowBoxMsg") && Boolean(result.csYellowBoxMsg))
               {
                  if(Global.player.previousCSYellowBoxMsg != result.csYellowBoxMsg)
                  {
                     ExternalInterface.call("updateCSYellowBox",result.csYellowBoxMsg);
                     Global.player.previousCSYellowBoxMsg = result.csYellowBoxMsg;
                  }
               }
               else
               {
                  ExternalInterface.call("updateCSYellowBox","");
                  Global.player.previousCSYellowBoxMsg = "";
               }
            }
            if(isMarketingBlueBoxMsgAutopop)
            {
               if(result.hasOwnProperty("marketingBlueBoxMsg") && Boolean(result.marketingBlueBoxMsg))
               {
                  if(Global.player.previousMarketingBlueBoxMsg != result.marketingBlueBoxMsg)
                  {
                     ExternalInterface.call("updateMarketingBlueBox",result.marketingBlueBoxMsg);
                     Global.player.previousMarketingBlueBoxMsg = result.marketingBlueBoxMsg;
                  }
               }
               else
               {
                  ExternalInterface.call("updateMarketingBlueBox","");
                  Global.player.previousMarketingBlueBoxMsg = "";
               }
            }
         }
      }
      
      final override protected function onAmfFault(result:Object, oosCode:int = 25, message:String = "onAmfFault was called") : void
      {
         this.fetchLogsForTransaction(result);
         super.onAmfFault(result,oosCode,message);
      }
      
      protected function updateShareBuyInfo(result:Object) : void
      {
         var item:MapResource = null;
         if(Boolean(result.shareBuyItemName) && Boolean(result.shareBuyUrl))
         {
            item = new MapResource(result.shareBuyItemName);
            item.onPlacementFeedPost(result.shareBuyUrl);
         }
      }
      
      protected function updateCraftingState(result:Object) : void
      {
         var updated:Boolean = false;
         if(result.hasOwnProperty("craftingSiloMaxCapacity") && result.craftingSiloMaxCapacity != null && result.craftingSiloMaxCapacity >= 0)
         {
            Global.player.craftingState.inventoryState.craftingSiloMaxCapacity = result.craftingSiloMaxCapacity;
            updated = true;
         }
         if(result.hasOwnProperty("villageStorageMaxCapacity") && result.villageStorageMaxCapacity != null && result.villageStorageMaxCapacity >= 0)
         {
            Global.player.craftingState.inventoryState.villageStorageMaxCapacity = result.villageStorageMaxCapacity;
            updated = true;
         }
         if(updated)
         {
            Global.stage.dispatchEvent(new Event(CRAFT_MAX_UPDATED));
         }
      }
      
      protected function updateCollectionCounters(result:Object) : void
      {
         var counterIdx:int = 0;
         var collectableCode:String = null;
         var count:int = 0;
         var rewardLink:String = null;
         var collectionCode:String = null;
         var collectionName:String = null;
         if(null != result.collectionCounters)
         {
            for(counterIdx = 0; counterIdx < result.collectionCounters.length; counterIdx++)
            {
               collectableCode = result.collectionCounters[counterIdx]["collectable"];
               count = int(result.collectionCounters[counterIdx]["count"]);
               rewardLink = result.collectionCounters[counterIdx]["link"];
               CollectionsManager.getInstance().queueCollectible(collectableCode,rewardLink);
            }
         }
         if(null != result.storedCollections)
         {
            for(collectionCode in result.storedCollections)
            {
               Global.player.storedCollections[collectionCode] = result.storedCollections[collectionCode];
            }
         }
         if(null != result.collectionLevels)
         {
            for(collectionName in result.collectionLeves)
            {
               Global.player.collectionLevels[collectionName] = result.collectionLevels[collectionName];
            }
         }
      }
      
      protected function updateEvictedGifts(result:Object) : void
      {
         var i:Number = NaN;
         if(null != result.evictedGifts && result.evictedGifts.length > 0)
         {
            for(i = 0; i < result.evictedGifts.length; i++)
            {
               Global.player.removeGiftWithKey(result.evictedGifts[i]);
            }
         }
      }
      
      protected function handleGoalResponse(result:Object) : void
      {
         var recipeMasteryGoals:Array = null;
         var handleFriendSetGoalArray:Array = null;
         var goalX:int = 0;
         var recipe:Object = null;
         var fsg:Object = null;
         var countX:int = 0;
         var code:String = null;
         var newCount:int = 0;
         var masteryCounters:Object = null;
         var oldCount:int = 0;
         var delta:int = 0;
         var organicCounters:Object = null;
         var organicTotal:int = 0;
         var organicCode:String = null;
         var newOrganicCount:int = 0;
         if(result.goals != null)
         {
            recipeMasteryGoals = [];
            handleFriendSetGoalArray = [];
            for(goalX = 0; goalX < result.goals.length; goalX++)
            {
               switch(result.goals[goalX]["type"])
               {
                  case this.GOAL_TYPE_ACHIEVEMENT:
                     Global.player.addAchievement(result.goals[goalX]["code"],result.goals[goalX]["difficulty"],result.goals[goalX]["link"],result.goals[goalX]["updateHud"]);
                     break;
                  case this.GOAL_TYPE_AVATAR_ACHIEVEMENT:
                     Global.player.addAchievement(result.goals[goalX]["code"],result.goals[goalX]["difficulty"],result.goals[goalX]["link"],result.goals[goalX]["updateHud"],"AchievementRewardGiftClothing",AvatarManager.grantAchievementAward);
                     break;
                  case this.GOAL_TYPE_MASTERY:
                     Global.player.addMastery(result.goals[goalX]["code"],result.goals[goalX]["difficulty"],result.goals[goalX]["link"],result.multiAction ? true : false);
                     break;
                  case this.GOAL_TYPE_ORGANIC:
                     Global.player.addOrganic(result.goals[goalX]["code"]);
                     break;
                  case this.GOAL_TYPE_RECIPEMASTERY:
                     recipe = {
                        "code":result.goals[goalX]["code"],
                        "level":result.goals[goalX]["difficulty"],
                        "reward":result.goals[goalX]["link"]
                     };
                     recipeMasteryGoals.push(recipe);
                     break;
                  case this.GOAL_TYPE_FRIENDSET:
                     fsg = {
                        "code":result.goals[goalX]["code"],
                        "difficulty":result.goals[goalX]["difficulty"],
                        "link":result.goals[goalX]["link"]
                     };
                     handleFriendSetGoalArray.push(fsg);
               }
            }
            if(handleFriendSetGoalArray.length > 0)
            {
               Global.player.handleFriendSetGoal(handleFriendSetGoalArray);
            }
            CraftingManager.getInstance().handleMastery(recipeMasteryGoals);
         }
         if(result.goalCounters != null)
         {
            for(countX = 0; countX < result.goalCounters.length; countX++)
            {
               switch(result.goalCounters[countX]["type"])
               {
                  case this.GOAL_TYPE_ACHIEVEMENT:
                  case this.GOAL_TYPE_AVATAR_ACHIEVEMENT:
                     Global.player.achCounters[result.goalCounters[countX]["code"]] = result.goalCounters[countX]["count"];
                     break;
                  case this.GOAL_TYPE_MASTERY:
                     code = result.goalCounters[countX]["code"];
                     newCount = int(result.goalCounters[countX]["count"]);
                     masteryCounters = Global.player.masteryCounters;
                     oldCount = 0;
                     if(masteryCounters.hasOwnProperty(code))
                     {
                        oldCount = int(masteryCounters[code]);
                     }
                     delta = newCount - oldCount;
                     masteryCounters[code] = newCount;
                     break;
                  case this.GOAL_TYPE_ORGANIC:
                     if(result.goalCounters[countX].hasOwnProperty("code"))
                     {
                        organicCode = result.goalCounters[countX]["code"];
                     }
                     if(result.goalCounters[countX].hasOwnProperty("count"))
                     {
                        newOrganicCount = int(result.goalCounters[countX]["count"]);
                     }
                     organicCounters = Global.player.organicCounters;
                     organicCounters[organicCode] = newOrganicCount;
                     break;
                  case this.GOAL_TYPE_ORGANIC_TOTAL:
                     organicTotal = int(result.goalCounters[countX]["count"]);
                     Global.player.organicCertificationTotal = organicTotal;
               }
            }
            TaskListManager.getInstance().checkTasksProgress();
         }
      }
      
      public function getTransactionData() : Object
      {
         return null;
      }
      
      protected function updateWorldTimeFromServer(serverData:Object) : void
      {
         if(serverData)
         {
            if(Boolean(serverData.worldTime) && !Global.worldManager.isVisiting())
            {
               Global.worldManager.syncWorldTime(serverData.worldTime);
            }
            else if(Boolean(serverData.data) && Boolean(serverData.data.hasOwnProperty("neighborWorldTime")))
            {
               Global.worldManager.syncWorldTime(serverData.data.neighborWorldTime);
            }
         }
      }
      
      private function fetchLogsForTransaction(result:Object) : void
      {
         var startTime:String = null;
         var endTime:String = null;
         var phpParams:String = null;
         var appUrl:String = null;
         var urlRequest:URLRequest = null;
         if(Config.DEBUG_MODE && Global.errorPopupEnabled)
         {
            if(null != result)
            {
               startTime = null;
               endTime = null;
               if(result.hasOwnProperty("startTime"))
               {
                  startTime = result.startTime;
               }
               if(result.hasOwnProperty("endTime"))
               {
                  endTime = result.endTime;
               }
               if(null != startTime && null != endTime)
               {
                  phpParams = "?&startTime=" + startTime + "&endTime=" + endTime;
                  appUrl = Config.BASE_PATH;
                  urlRequest = new URLRequest(appUrl + "/fetchLog.php" + phpParams);
                  urlRequest.method = URLRequestMethod.POST;
                  this.m_transactionLogLoader = new URLLoader();
                  this.m_transactionLogLoader.dataFormat = URLLoaderDataFormat.TEXT;
                  this.m_transactionLogLoader.addEventListener(Event.COMPLETE,this.fetchLogDataComplete);
                  this.m_transactionLogLoader.load(urlRequest);
               }
            }
         }
      }
      
      private function fetchLogDataComplete(evt:Event) : void
      {
         var theLogs:String = this.m_transactionLogLoader.data;
         if(null != theLogs && theLogs.length > 0)
         {
            this.m_lastServerErrorLog = theLogs;
            UI.displayPopup(new ErrorWindow(theLogs));
         }
      }
   }
}

