package Managers
{
   import Classes.Constants.Experiments;
   import Classes.Constants.QuestConstants;
   import Classes.Friend;
   import Classes.Leaderboard.Leaderboard;
   import Classes.Leaderboard.LeaderboardConfigSettings;
   import Classes.Leaderboard.LeaderboardState;
   import Classes.Leaderboard.LeaderboardTask;
   import Classes.Quest.FarmQuestUtility;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.UserRewardUtil;
   import Classes.util.ZLocUtils;
   import Display.TutorialUI;
   import Display.UI;
   import Engine.Events.TransactionEvent;
   import Engine.Managers.TransactionManager;
   import Transactions.TFarmTransaction;
   import Transactions.TGenericTransaction;
   import Transactions.TGetLeaderboardFriendLists;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Frames.Leaderboard.LeaderboardFrame;
   import Widgets.Windows.Leaderboard.LeaderboardSummaryWindow;
   import Widgets.Windows.Leaderboard.LeaderboardWindow;
   import Widgets.Windows.Leaderboard.MultiTaskLeaderboardNoRankRewardToasterWindow;
   import Widgets.Windows.Leaderboard.MultiTaskLeaderboardRewardWindow;
   import Widgets.Windows.Leaderboard.MultiTaskLeaderboardWindow;
   
   public class LeaderboardManager
   {
      
      private static var m_numPendingInitTransactions:int;
      
      private static var m_nextExpirationTime:Number;
      
      private static var m_nextMultiTaskLeaderboardExpirationTime:Number;
      
      private static var m_leaderboardWindow:LeaderboardWindow;
      
      private static var m_leaderboardSummaryWindow:LeaderboardSummaryWindow;
      
      private static var m_multiTaskLeaderboardWindow:MultiTaskLeaderboardWindow;
      
      public static const PROGRESS_REWARD_TYPE:String = "progress";
      
      public static const RANK_REWARD_TYPE:String = "rank";
      
      public static const STAT_COUNTER:String = "leaderboards";
      
      private static const NEIGHBORS_BUCKET_SIZE:int = 10;
      
      private static const LEADERBOARD_POPUP_FREQUENCY_FLAG:String = "leaderboardPopup";
      
      private static const LEADERBOARD_LAPSED_POPUP_FREQUENCY_FLAG:String = "leaderboardLapsedPopup";
      
      public static const FEED_IMAGE_URL:String = "assets/newsfeed/leaderboard_trophygold_icon.png";
      
      public static const FEED_IMAGE_URL_200:String = "assets/newsfeed/leaderboard_trophygold_icon_200.png";
      
      private static const SUMMARY_SEEN_FLAG_PREFIX:String = "leaderboardsummary_";
      
      private static const PASSED_FRIEND_TOASTER_SEEN_FLAG:String = "passedfriendtoaster";
      
      private static const PASSED_FRIEND_FEATURE_FREQUENCY_KEY:String = "LeaderboardPassedFriend";
      
      private static const PASSED_FRIEND_FEATURE_FREQUENCY:String = "LeaderboardPassedFriendFeatureFrequency";
      
      private static const AUTOPOP_SUMMARY_MAX_DAYS_EXPIRED:Number = 14;
      
      private static var m_isMasterExperimentInitialized:Boolean = false;
      
      private static var m_initialized:Boolean = false;
      
      private static var m_friendLists:Object = {};
      
      private static var m_nextFriends:Object = {};
      
      private static var m_summariesToShow:Array = new Array();
      
      public function LeaderboardManager()
      {
         super();
      }
      
      public static function get initialized() : Boolean
      {
         return m_initialized && m_numPendingInitTransactions <= 0;
      }
      
      public static function initialize() : void
      {
         var activeLeaderboards:Array = null;
         var everlastingLeaderboards:Array = null;
         var hudIconAdded:Boolean = false;
         var multiTaskHUDIconAdded:Boolean = false;
         var leaderboard:Leaderboard = null;
         var leaderboardEverlast:Leaderboard = null;
         if(!m_initialized)
         {
            m_initialized = true;
            TransactionManager.getInstance().addEventListener(TransactionEvent.ADDED,onTransactionManagerAdded);
            activeLeaderboards = Global.leaderboardConfigSettings.getActiveLeaderboards();
            if(activeLeaderboards)
            {
               hudIconAdded = false;
               multiTaskHUDIconAdded = false;
               for each(leaderboard in activeLeaderboards)
               {
                  sendGetFriendListTransaction(leaderboard.name);
                  if(leaderboard.isMultitask)
                  {
                     if(!multiTaskHUDIconAdded)
                     {
                        leaderboard.addIconToIconQueue();
                        multiTaskHUDIconAdded = true;
                     }
                  }
                  else if(!hudIconAdded)
                  {
                     leaderboard.addIconToIconQueue();
                     hudIconAdded = true;
                  }
               }
               calculateNextExpirationTime();
            }
            everlastingLeaderboards = Global.leaderboardConfigSettings.getEverlastingLeaderboards();
            if(everlastingLeaderboards)
            {
               for each(leaderboardEverlast in everlastingLeaderboards)
               {
                  sendGetFriendListTransaction(leaderboardEverlast.name);
               }
            }
            conditionallyPopLeaderboardUI();
            conditionallyShowMultiTaskLeaderboardRewardDialog();
         }
      }
      
      private static function conditionallyPopLeaderboardUI(newLeaderboard:Boolean = false) : void
      {
         var shouldPop:Boolean = false;
         var activeLeaderboards:Array = null;
         var popupCooldown:int = 0;
         var lapsedParticipantsCooldown:int = 0;
         var timeBackToCheck:int = 0;
         var lastPopupSeen:int = 0;
         var currentTime:int = 0;
         var timeSinceLastSeen:int = 0;
         var lastLapsedPopupSeen:int = 0;
         var lapsedParticipantLastSeen:int = 0;
         var startTime:Number = NaN;
         var activeLeaderboard:Leaderboard = null;
         var leaderboards:Array = null;
         var mostRecentTime:Number = NaN;
         var leaderboard:Leaderboard = null;
         var userState:LeaderboardState = null;
         var historicalData:Array = null;
         var totalActiveLeaderboards:int = 0;
         var variant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_LEADERBOARDS_SURFACING);
         if(variant == 1 || variant == 3)
         {
            shouldPop = newLeaderboard == true;
            if(!shouldPop)
            {
               activeLeaderboards = Global.leaderboardConfigSettings.getActiveLeaderboards(LeaderboardConfigSettings.SINGLE_TASK);
               popupCooldown = Global.farmGameSettingsManager.getInt("leaderboardSurfacingCooldown",604800);
               lapsedParticipantsCooldown = Global.farmGameSettingsManager.getInt("leaderboardSurfacingLapsedCooldown",2592000);
               timeBackToCheck = Global.farmGameSettingsManager.getInt("leaderboardSurfacingTimeBack",2419200);
               lastPopupSeen = Global.player.getFeatureLastShown(LEADERBOARD_POPUP_FREQUENCY_FLAG);
               currentTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
               timeSinceLastSeen = currentTime - lastPopupSeen;
               if(Boolean(activeLeaderboards) && Boolean(activeLeaderboards.length > 0) && timeSinceLastSeen > popupCooldown)
               {
                  startTime = currentTime - timeBackToCheck;
                  activeLeaderboard = activeLeaderboards[0] as Leaderboard;
                  leaderboards = Global.leaderboardConfigSettings.getLeaderboardDataByDate(startTime,currentTime);
                  mostRecentTime = getMostRecentTimeHelper(leaderboards);
                  Global.player.setFeatureLastShown(LEADERBOARD_POPUP_FREQUENCY_FLAG,currentTime,true);
                  for each(leaderboard in leaderboards)
                  {
                     userState = Global.player.getLeaderboardState(leaderboard.name);
                     if(mostRecentTime == leaderboard.startTime)
                     {
                        if(Boolean(userState) && (Boolean(userState.progressRewards) || Boolean(userState.rankReward)))
                        {
                           shouldPop = true;
                           FarmStatsManager.featureSample(LeaderboardManager.STAT_COUNTER,"autopop","reward",leaderboard.name);
                           break;
                        }
                     }
                     if(Boolean(userState) && userState.score > 0)
                     {
                        shouldPop = true;
                        if(activeLeaderboard)
                        {
                           FarmStatsManager.featureSample(LeaderboardManager.STAT_COUNTER,"autopop","new_leaderboard","active",activeLeaderboard.name);
                        }
                        break;
                     }
                  }
               }
               lastLapsedPopupSeen = Global.player.getFeatureLastShown(LEADERBOARD_LAPSED_POPUP_FREQUENCY_FLAG);
               lapsedParticipantLastSeen = currentTime - lastLapsedPopupSeen;
               if(!shouldPop && lapsedParticipantLastSeen > lapsedParticipantsCooldown)
               {
                  historicalData = Global.leaderboardConfigSettings.getHistoricalLeaderboards(LeaderboardConfigSettings.SINGLE_TASK);
                  Global.player.setFeatureLastShown(LEADERBOARD_LAPSED_POPUP_FREQUENCY_FLAG,currentTime,true);
                  totalActiveLeaderboards = activeLeaderboards ? int(activeLeaderboards.length) : 0;
                  if(historicalData.length > totalActiveLeaderboards)
                  {
                     shouldPop = true;
                     if(activeLeaderboard)
                     {
                        FarmStatsManager.featureSample(LeaderboardManager.STAT_COUNTER,"autopop","new_leaderboard","lapsed",activeLeaderboard.name);
                     }
                  }
               }
            }
            if(shouldPop)
            {
               displayLeaderboardWindow();
            }
         }
      }
      
      private static function getMostRecentTimeHelper(leaderboards:Array) : Number
      {
         var leaderboard:Leaderboard = null;
         var result:Number = -1;
         if(Boolean(leaderboards) && leaderboards.length > 0)
         {
            for each(leaderboard in leaderboards)
            {
               if(leaderboard.startTime > result)
               {
                  result = leaderboard.startTime;
               }
            }
         }
         return result;
      }
      
      private static function onTransactionManagerAdded(event:TransactionEvent) : void
      {
         var task:LeaderboardTask = null;
         var transaction:TFarmTransaction = null;
         var taskProgression:int = 0;
         var leaderboardState:LeaderboardState = null;
         var incrementalValue:int = 0;
         var tasks:Array = Global.leaderboardConfigSettings.getActiveLeaderboardTasks();
         for each(task in tasks)
         {
            transaction = event.transaction as TFarmTransaction;
            taskProgression = FarmQuestUtility.getInstance().getProgression(task,transaction,null);
            if(taskProgression > 0)
            {
               leaderboardState = getOrCreateLeaderboardState(task.leaderboard.name);
               incrementalValue = taskProgression * task.points;
               incrementScore(leaderboardState,incrementalValue);
            }
         }
      }
      
      public static function updateWorldScoreTasks(unit:String, value:int) : void
      {
         var task:LeaderboardTask = null;
         var leaderboardState:LeaderboardState = null;
         var tasks:Object = Global.leaderboardConfigSettings.getActiveLeaderboardTasks();
         for each(task in tasks)
         {
            if(task.action == QuestConstants.TASK_COUNT_WORLD_SCORE_BY_TYPE && task.type != null && task.type == unit && value > 0)
            {
               leaderboardState = getOrCreateLeaderboardState(task.leaderboard.name);
               incrementScore(leaderboardState,value);
            }
         }
      }
      
      private static function calculateNextExpirationTime() : void
      {
         var nextExpirationTime:Number = NaN;
         var nextMultiTaskExpirationTime:Number = NaN;
         var leaderboard:Leaderboard = null;
         var expirationTime:Number = NaN;
         var activeLeaderboards:Object = Global.leaderboardConfigSettings.getActiveLeaderboards();
         if(activeLeaderboards)
         {
            nextExpirationTime = Number.MAX_VALUE;
            nextMultiTaskExpirationTime = Number.MAX_VALUE;
            for each(leaderboard in activeLeaderboards)
            {
               expirationTime = leaderboard.expirationTime;
               if(expirationTime < nextExpirationTime)
               {
                  if(leaderboard.isMultitask)
                  {
                     nextMultiTaskExpirationTime = expirationTime;
                  }
                  else
                  {
                     nextExpirationTime = expirationTime;
                  }
               }
            }
            if(nextExpirationTime > 0)
            {
               m_nextExpirationTime = nextExpirationTime;
            }
            if(nextMultiTaskExpirationTime > 0)
            {
               m_nextMultiTaskLeaderboardExpirationTime = nextMultiTaskExpirationTime;
            }
         }
      }
      
      public static function update() : void
      {
         var hasLeaderboardExpired:Boolean = false;
         if(m_nextExpirationTime > 0 && m_nextExpirationTime <= GlobalEngine.serverTime)
         {
            hasLeaderboardExpired = true;
            conditionallyPopLeaderboardUI(true);
            if(m_leaderboardWindow)
            {
               m_leaderboardWindow.refresh();
            }
         }
         if(m_nextMultiTaskLeaderboardExpirationTime > 0 && m_nextMultiTaskLeaderboardExpirationTime <= GlobalEngine.serverTime)
         {
            hasLeaderboardExpired = true;
            if(m_multiTaskLeaderboardWindow)
            {
               m_multiTaskLeaderboardWindow.refresh();
            }
         }
         if(hasLeaderboardExpired)
         {
            sendRefreshRanksTransaction();
            calculateNextExpirationTime();
         }
      }
      
      public static function markAsSeen(leaderboardName:String) : void
      {
         var userState:LeaderboardState = getOrCreateLeaderboardState(leaderboardName);
         if(!userState.seen)
         {
            userState.seen = true;
            TransactionManager.addTransaction(new TGenericTransaction("LeaderboardService","markAsSeen",null,[leaderboardName]),true);
         }
      }
      
      public static function markAsRewardSeen(leaderboardName:String) : void
      {
         var userState:LeaderboardState = getOrCreateLeaderboardState(leaderboardName);
         if(!userState.seen)
         {
            userState.seen = true;
            TransactionManager.addTransaction(new TGenericTransaction("LeaderboardService","markAsSeen",null,[leaderboardName]),true);
         }
      }
      
      private static function sendRefreshRanksTransaction() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction("LeaderboardService","refreshRanks",sendRefreshRanksTransactionCallback),true);
         ++m_numPendingInitTransactions;
      }
      
      private static function sendRefreshRanksTransactionCallback(result:Object) : void
      {
         var leaderboardsData:Object = null;
         var leaderboardName:String = null;
         var leaderboardData:Object = null;
         var userState:LeaderboardState = null;
         if(Boolean(result) && Boolean(result["leaderboards"]))
         {
            leaderboardsData = result["leaderboards"] as Object;
            for(leaderboardName in leaderboardsData)
            {
               leaderboardData = leaderboardsData[leaderboardName] as Object;
               if(leaderboardData)
               {
                  userState = Global.player.getLeaderboardState(leaderboardName);
                  if(userState)
                  {
                     userState.rank = leaderboardData.hasOwnProperty("rank") ? int(leaderboardData["rank"]) : 0;
                  }
               }
            }
         }
         --m_numPendingInitTransactions;
         grantRankRewards();
         if(!m_leaderboardWindow && !m_leaderboardSummaryWindow)
         {
            conditionallyShowSummaryWindow();
         }
      }
      
      private static function grantRankRewards() : void
      {
         var leaderboardName:String = null;
         var leaderboardState:LeaderboardState = null;
         var userRank:int = 0;
         var leaderboard:Leaderboard = null;
         var rankRewards:Array = null;
         var rankReward:Object = null;
         var rewards:Vector.<Object> = null;
         var leaderboardStates:Object = Global.player.getLeaderboardStates();
         if(leaderboardStates)
         {
            for(leaderboardName in leaderboardStates)
            {
               leaderboardState = leaderboardStates[leaderboardName] as LeaderboardState;
               if(leaderboardState)
               {
                  userRank = leaderboardState.rank;
                  if(userRank > 0 && !leaderboardState.rankReward)
                  {
                     leaderboard = Global.leaderboardConfigSettings.getLeaderboard(leaderboardName);
                     if(leaderboard)
                     {
                        rankRewards = leaderboard.rankRewards;
                        if(rankRewards)
                        {
                           for each(rankReward in rankRewards)
                           {
                              if(userRank == int(rankReward["rank"]))
                              {
                                 leaderboardState.rankReward = true;
                                 rewards = new Vector.<Object>();
                                 rewards.push(rankReward);
                                 UserRewardUtil.grantUserRewards(rewards);
                                 if(leaderboard.isMultitask)
                                 {
                                    displayMultiTaskLeaderboardRewardWindow(leaderboard,rankReward,RANK_REWARD_TYPE);
                                 }
                                 break;
                              }
                           }
                        }
                     }
                  }
               }
            }
         }
      }
      
      private static function sendGetFriendListTransaction(leaderboardName:String) : void
      {
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_BATCH_LEADERBOARD_FRIENDLIST) == 2)
         {
            TGetLeaderboardFriendLists.getLeaderBoardFriendList(leaderboardName,sendGetFriendListTransactionCallback);
         }
         else
         {
            TransactionManager.addTransaction(new TGenericTransaction("LeaderboardService","getFriendList",sendGetFriendListTransactionCallback,[leaderboardName]),true);
         }
         ++m_numPendingInitTransactions;
      }
      
      private static function sendGetFriendListTransactionCallback(result:Object) : void
      {
         var leaderboardName:String = null;
         var friendList:Array = null;
         var bucket:String = null;
         var numFriends:int = 0;
         var bucketMin:int = 0;
         var bucketMax:int = 0;
         if(Boolean(result) && Boolean(result.hasOwnProperty("leaderboardName")) && result.hasOwnProperty("friendList"))
         {
            leaderboardName = result["leaderboardName"] as String;
            friendList = result["friendList"] as Array;
            m_friendLists[leaderboardName] = friendList;
            calculateNextFriend(leaderboardName);
            numFriends = friendList ? int(friendList.length) : 0;
            if(numFriends > 0)
            {
               bucketMin = Math.floor(numFriends / NEIGHBORS_BUCKET_SIZE) * NEIGHBORS_BUCKET_SIZE;
               bucketMax = Math.ceil(numFriends / NEIGHBORS_BUCKET_SIZE) * NEIGHBORS_BUCKET_SIZE;
               if(bucketMin == bucketMax)
               {
                  bucketMin = bucketMax - NEIGHBORS_BUCKET_SIZE + 1;
               }
               else
               {
                  bucketMin++;
               }
               bucket = bucketMin + "-" + bucketMax;
            }
            else
            {
               bucket = "0";
            }
            FarmStatsManager.featureSample(LeaderboardManager.STAT_COUNTER,"neighbors","on_load",leaderboardName,bucket);
         }
         --m_numPendingInitTransactions;
      }
      
      public static function sendGetRankRewardFeedTransaction(leaderboardName:String) : void
      {
         var userState:LeaderboardState = null;
         if(leaderboardName)
         {
            TransactionManager.addTransaction(new TGenericTransaction("LeaderboardService","getRankRewardFeed",sendGetRankRewardFeedTransactionCallback,[leaderboardName]),true);
            userState = Global.player.getLeaderboardState(leaderboardName);
            if(userState)
            {
               userState.rankFeed = true;
            }
         }
      }
      
      private static function sendGetRankRewardFeedTransactionCallback(result:Object) : void
      {
         var rewardLink:String = null;
         var leaderboardName:String = null;
         var leaderboard:Leaderboard = null;
         var userState:LeaderboardState = null;
         var feedIcon:String = null;
         var bundleData:Object = null;
         if(Boolean(result) && Boolean(result["rewardLink"]))
         {
            rewardLink = result["rewardLink"];
            leaderboardName = result["leaderboardName"];
            if(leaderboardName)
            {
               leaderboard = Global.leaderboardConfigSettings.getLeaderboard(leaderboardName);
               if(leaderboard)
               {
                  userState = Global.player.getLeaderboardState(leaderboardName);
                  if(userState)
                  {
                     feedIcon = LeaderboardManager.FEED_IMAGE_URL;
                     if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FACEBOOK_FEED_ICONS) > 1)
                     {
                        feedIcon = LeaderboardManager.FEED_IMAGE_URL_200;
                     }
                     bundleData = {};
                     bundleData["reward_link"] = rewardLink;
                     bundleData["images"] = [{
                        "href":"{SN_APP_URL}" + rewardLink,
                        "src":Global.getAssetURL(feedIcon)
                     }];
                     bundleData["creative"] = leaderboard.name;
                     bundleData["leaderboardName"] = leaderboard.nameText;
                     bundleData["rank"] = userState.rank;
                     GlobalEngine.socialNetwork.publishFeedStory("LeaderboardRankReward",bundleData,[],false);
                  }
               }
            }
         }
      }
      
      public static function sendGetProgressRewardFeedTransaction(leaderboardName:String, index:int) : void
      {
         var userState:LeaderboardState = null;
         if(leaderboardName)
         {
            TransactionManager.addTransaction(new TGenericTransaction("LeaderboardService","getProgressRewardFeed",sendGetProgressRewardFeedTransactionCallback,[leaderboardName,index]),true);
            userState = Global.player.getLeaderboardState(leaderboardName);
            if(userState)
            {
               userState.setProgressFeed(index);
            }
         }
      }
      
      private static function sendGetProgressRewardFeedTransactionCallback(result:Object) : void
      {
         var rewardLink:String = null;
         var leaderboardName:String = null;
         var index:int = 0;
         var leaderboard:Leaderboard = null;
         var progressReward:Object = null;
         var itemCode:String = null;
         var item:FarmItem = null;
         var feedIcon:String = null;
         var bundleData:Object = null;
         if(Boolean(result) && Boolean(result["rewardLink"]))
         {
            rewardLink = result["rewardLink"];
            leaderboardName = result["leaderboardName"];
            index = int(result["index"]);
            if(Boolean(leaderboardName) && index >= 0)
            {
               leaderboard = Global.leaderboardConfigSettings.getLeaderboard(leaderboardName);
               if(leaderboard)
               {
                  progressReward = leaderboard.getProgressReward(index);
                  if(progressReward)
                  {
                     itemCode = progressReward["value"] as String;
                     item = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
                     if(item)
                     {
                        feedIcon = LeaderboardManager.FEED_IMAGE_URL;
                        if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FACEBOOK_FEED_ICONS) > 1)
                        {
                           feedIcon = LeaderboardManager.FEED_IMAGE_URL_200;
                        }
                        bundleData = {};
                        bundleData["reward_link"] = rewardLink;
                        bundleData["images"] = [{
                           "href":"{SN_APP_URL}" + rewardLink,
                           "src":Global.getAssetURL(feedIcon)
                        }];
                        bundleData["creative"] = leaderboard.name;
                        bundleData["leaderboardName"] = leaderboard.nameText;
                        bundleData["itemName"] = item.friendlyTitle;
                        GlobalEngine.socialNetwork.publishFeedStory("LeaderboardProgressReward",bundleData,[],false);
                     }
                  }
               }
            }
         }
      }
      
      public static function sendGetPassedFriendFeedTransaction(leaderboardName:String, friendUid:String) : void
      {
         if(leaderboardName)
         {
            TransactionManager.addTransaction(new TGenericTransaction("LeaderboardService","getPassedFriendFeed",sendGetPassedFriendFeedTransactionCallback,[leaderboardName,friendUid]),true);
            Global.player.setFeatureLastShown(PASSED_FRIEND_FEATURE_FREQUENCY_KEY,GlobalEngine.serverTime / 1000,false);
         }
      }
      
      private static function sendGetPassedFriendFeedTransactionCallback(result:Object) : void
      {
         var rewardLink:String = null;
         var leaderboardName:String = null;
         var friendUid:String = null;
         var leaderboard:Leaderboard = null;
         var userState:LeaderboardState = null;
         var friend:Friend = null;
         var feedIcon:String = null;
         var bundleData:Object = null;
         if(Boolean(result) && Boolean(result["rewardLink"]))
         {
            rewardLink = result["rewardLink"];
            leaderboardName = result["leaderboardName"];
            friendUid = result["friendUid"];
            if(Boolean(leaderboardName) && friendUid != "0")
            {
               leaderboard = Global.leaderboardConfigSettings.getLeaderboard(leaderboardName);
               if(leaderboard)
               {
                  userState = Global.player.getLeaderboardState(leaderboardName);
                  if(userState)
                  {
                     friend = Global.friendManager.getFriendData(friendUid);
                     if(friend)
                     {
                        feedIcon = LeaderboardManager.FEED_IMAGE_URL;
                        if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FACEBOOK_FEED_ICONS) > 1)
                        {
                           feedIcon = LeaderboardManager.FEED_IMAGE_URL_200;
                        }
                        bundleData = {};
                        bundleData["reward_link"] = rewardLink;
                        bundleData["images"] = [{
                           "href":"{SN_APP_URL}" + rewardLink,
                           "src":Global.getAssetURL(feedIcon)
                        }];
                        bundleData["creative"] = leaderboard.name;
                        bundleData["leaderboardName"] = leaderboard.nameText;
                        bundleData["rank"] = userState.rank;
                        bundleData["friendName"] = friend.firstName;
                        GlobalEngine.socialNetwork.publishFeedStory("LeaderboardPassedFriend",bundleData,[],false);
                     }
                  }
               }
            }
         }
      }
      
      private static function getOrCreateLeaderboardState(leaderboardName:String) : LeaderboardState
      {
         var leaderboardState:LeaderboardState = Global.player.getLeaderboardState(leaderboardName);
         if(leaderboardState == null)
         {
            leaderboardState = new LeaderboardState();
            leaderboardState.name = leaderboardName;
            Global.player.setLeaderboardState(leaderboardName,leaderboardState);
         }
         return leaderboardState;
      }
      
      private static function incrementScore(leaderboardState:LeaderboardState, incrementalValue:int) : void
      {
         leaderboardState.incrementScore(incrementalValue);
         var wasGrantedProgressReward:Boolean = checkProgressRewards(leaderboardState);
         if(!wasGrantedProgressReward)
         {
            conditionallyShowPassedFriendToaster(leaderboardState);
         }
      }
      
      private static function checkProgressRewards(leaderboardState:LeaderboardState) : Boolean
      {
         var progressRewards:Array = null;
         var i:int = 0;
         var progressReward:Object = null;
         var progressThreshold:int = 0;
         var rewards:Vector.<Object> = null;
         var result:Boolean = false;
         var leaderboardName:String = leaderboardState.name;
         var userScore:int = leaderboardState.score;
         var leaderboard:Leaderboard = Global.leaderboardConfigSettings.getLeaderboard(leaderboardName);
         if(leaderboard)
         {
            progressRewards = leaderboard.progressRewards;
            if(progressRewards)
            {
               for(i = 0; i < progressRewards.length; i++)
               {
                  progressReward = progressRewards[i];
                  progressThreshold = int(progressReward["threshold"]);
                  if(progressThreshold > 0 && userScore >= progressThreshold && !leaderboardState.hasProgressReward(i))
                  {
                     result = true;
                     rewards = new Vector.<Object>();
                     rewards.push(progressReward);
                     UserRewardUtil.grantUserRewards(rewards);
                     leaderboardState.setProgressReward(i);
                     if(leaderboard.isMultitask)
                     {
                        displayMultiTaskLeaderboardRewardWindow(leaderboard,progressReward,PROGRESS_REWARD_TYPE);
                     }
                  }
               }
            }
         }
         return result;
      }
      
      private static function getSecondsUntilPassedFriendFeedAvailable() : int
      {
         var featureFrequencyTime:Number = Global.farmGameSettingsManager.getInt(PASSED_FRIEND_FEATURE_FREQUENCY,3600);
         var featureLastShown:Number = Global.player.getFeatureLastShown(PASSED_FRIEND_FEATURE_FREQUENCY_KEY);
         var currentTime:Number = GlobalEngine.serverTime / 1000;
         return int(featureLastShown + featureFrequencyTime - currentTime);
      }
      
      private static function isPassedFriendFeedAvailable() : Boolean
      {
         var secondsUntilAvailable:int = getSecondsUntilPassedFriendFeedAvailable();
         return secondsUntilAvailable <= 0;
      }
      
      private static function conditionallyShowPassedFriendToaster(leaderboardState:LeaderboardState) : Boolean
      {
         var userScore:int = 0;
         var nextFriend:Object = null;
         var result:Boolean = false;
         var leaderboardName:String = leaderboardState.name;
         var leaderboard:Leaderboard = Global.leaderboardConfigSettings.getLeaderboard(leaderboardName);
         if(Boolean(leaderboard) && !leaderboard.isMultitask)
         {
            userScore = leaderboardState.score;
            nextFriend = getNextFriend(leaderboardName);
            if(Boolean(nextFriend) && userScore == int(nextFriend["value"]) + 1)
            {
               calculateNextFriend(leaderboardName);
               FarmStatsManager.featureSample(LeaderboardManager.STAT_COUNTER,"passed_friend",leaderboardName);
            }
         }
         return result;
      }
      
      private static function calculateNextFriend(leaderboardName:String) : Boolean
      {
         var result:Boolean = false;
         var nextFriend:Object = null;
         var userScore:int = 0;
         var leaderboardFriendList:Array = null;
         var leaderboardFriendListLength:int = 0;
         var i:int = 0;
         var leaderboardFriend:Object = null;
         var friendScore:int = 0;
         var nextFriendScore:int = 0;
         var leaderboardState:LeaderboardState = Global.player.getLeaderboardState(leaderboardName);
         if(leaderboardState)
         {
            userScore = leaderboardState.score;
            leaderboardFriendList = LeaderboardManager.getFriendList(leaderboardName);
            if(leaderboardFriendList)
            {
               leaderboardFriendListLength = int(leaderboardFriendList.length);
               for(i = 0; i < leaderboardFriendListLength; i++)
               {
                  leaderboardFriend = leaderboardFriendList[i];
                  friendScore = int(leaderboardFriend["value"]);
                  nextFriendScore = nextFriend ? int(nextFriend["value"]) : int.MAX_VALUE;
                  if(friendScore >= userScore && friendScore < nextFriendScore)
                  {
                     nextFriend = leaderboardFriend;
                  }
               }
            }
         }
         m_nextFriends[leaderboardName] = nextFriend;
         if(nextFriend)
         {
            result = true;
         }
         return result;
      }
      
      private static function getNextFriend(leaderboardName:String) : Object
      {
         return Boolean(m_nextFriends) && m_nextFriends.hasOwnProperty(leaderboardName) ? m_nextFriends[leaderboardName] as Object : null;
      }
      
      public static function getFriendList(leaderboardName:String) : Array
      {
         var result:Array = null;
         if(m_friendLists.hasOwnProperty(leaderboardName))
         {
            result = m_friendLists[leaderboardName];
         }
         else
         {
            result = new Array();
         }
         return result;
      }
      
      public static function getProgressRewardDiscountPercentage(leaderboardName:String) : Number
      {
         var result:Number = NaN;
         var userState:LeaderboardState = null;
         var userScore:int = 0;
         var lowestThreshold:int = 0;
         var numThresholdsPassed:int = 0;
         var progressRewards:Array = null;
         var progressReward:Object = null;
         var threshold:int = 0;
         var leaderboard:Leaderboard = Global.leaderboardConfigSettings.getLeaderboard(leaderboardName);
         if(leaderboard)
         {
            userState = Global.player.getLeaderboardState(leaderboardName);
            if(userState)
            {
               userScore = userState ? userState.score : 0;
               if(userScore > 0)
               {
                  progressRewards = leaderboard.progressRewards;
                  if(progressRewards)
                  {
                     for each(progressReward in progressRewards)
                     {
                        threshold = int(progressReward["threshold"]);
                        if(userScore >= threshold)
                        {
                           numThresholdsPassed++;
                        }
                        else if(threshold < lowestThreshold)
                        {
                           lowestThreshold = threshold;
                        }
                     }
                     if(numThresholdsPassed >= 2)
                     {
                        result = 0.4;
                     }
                     else if(numThresholdsPassed == 1)
                     {
                        result = 0.3;
                     }
                     else if(userScore >= lowestThreshold * 0.5)
                     {
                        result = 0.2;
                     }
                  }
               }
            }
         }
         return result;
      }
      
      public static function getRank(leaderboardName:String) : int
      {
         var userState:LeaderboardState = null;
         var leaderboardFriendList:Array = null;
         var setResult:Boolean = false;
         var userScore:int = 0;
         var leaderboardFriendListLength:int = 0;
         var i:int = 0;
         var leaderboardFriend:Object = null;
         var result:int = 0;
         var leaderboard:Leaderboard = Global.leaderboardConfigSettings.getLeaderboard(leaderboardName);
         if(leaderboard)
         {
            if(leaderboard.isActive)
            {
               leaderboardFriendList = LeaderboardManager.getFriendList(leaderboardName);
               if(Boolean(leaderboardFriendList) && leaderboardFriendList.length > 0)
               {
                  setResult = false;
                  userState = Global.player.getLeaderboardState(leaderboardName);
                  userScore = userState ? userState.score : 0;
                  leaderboardFriendListLength = int(leaderboardFriendList.length);
                  for(i = 0; i < leaderboardFriendListLength; i++)
                  {
                     leaderboardFriend = leaderboardFriendList[i];
                     if(userScore >= int(leaderboardFriend["value"]))
                     {
                        result = i + 1;
                        setResult = true;
                        break;
                     }
                  }
                  if(!setResult)
                  {
                     result = leaderboardFriendListLength + 1;
                  }
               }
               else
               {
                  result = 1;
               }
            }
            else
            {
               userState = Global.player.getLeaderboardState(leaderboardName);
               if(userState)
               {
                  result = userState.rank;
               }
            }
         }
         return result;
      }
      
      public static function displayLeaderboardWindow(tab:String = null) : LeaderboardWindow
      {
         if(!m_leaderboardWindow && Boolean(Global.leaderboardConfigSettings))
         {
            m_leaderboardWindow = new LeaderboardWindow(LeaderboardWindow.DEFAULT_TAB,onLeaderboardWindowClose);
            m_leaderboardWindow.leaderboardToShow = tab;
            UI.displayPopup(m_leaderboardWindow,true,"Leaderboards",true);
            LeaderboardManager.conditionallyShowSummaryWindow();
         }
         return m_leaderboardWindow;
      }
      
      public static function onLeaderboardWindowClose() : void
      {
         m_leaderboardWindow = null;
      }
      
      public static function displayLeaderboardSummaryWindow(leaderboard:Leaderboard) : LeaderboardSummaryWindow
      {
         if(!m_leaderboardSummaryWindow && Boolean(Global.leaderboardConfigSettings))
         {
            m_leaderboardSummaryWindow = new LeaderboardSummaryWindow(leaderboard,onLeaderboardSummaryWindowClose);
            UI.displayPopup(m_leaderboardSummaryWindow,false,"LeaderboardSummary",true);
         }
         return m_leaderboardSummaryWindow;
      }
      
      public static function onLeaderboardSummaryWindowClose() : void
      {
         m_leaderboardSummaryWindow = null;
         if(m_summariesToShow.length > 0)
         {
            showSummaries();
         }
      }
      
      public static function conditionallyShowSummaryWindow() : void
      {
         var leaderboard:Leaderboard = null;
         var expirationTime:Number = NaN;
         var timeDiff:Number = NaN;
         var userState:LeaderboardState = null;
         var progressRewards:Array = null;
         var userScore:int = 0;
         var progressReward:Object = null;
         var leaderboards:Array = Global.leaderboardConfigSettings.getHistoricalLeaderboards(LeaderboardConfigSettings.SINGLE_TASK);
         if(leaderboards)
         {
            for each(leaderboard in leaderboards)
            {
               if(leaderboard.isExpired)
               {
                  expirationTime = leaderboard.expirationTime;
                  timeDiff = (GlobalEngine.serverTime - expirationTime) / FarmGameUtil.NUM_MSECS_IN_DAY;
                  if(timeDiff >= AUTOPOP_SUMMARY_MAX_DAYS_EXPIRED)
                  {
                     break;
                  }
                  userState = Global.player.getLeaderboardState(leaderboard.name);
                  if(Boolean(userState) && userState.score > 0)
                  {
                     progressRewards = leaderboard.progressRewards;
                     if(progressRewards)
                     {
                        userScore = userState.score;
                        for each(progressReward in progressRewards)
                        {
                           if(userScore >= int(progressReward["threshold"]) * 0.1)
                           {
                              m_summariesToShow.push(leaderboard);
                              break;
                           }
                        }
                     }
                  }
               }
            }
         }
         if(m_summariesToShow.length > 0)
         {
            showSummaries();
         }
      }
      
      private static function showSummaries() : void
      {
         var leaderboardToShow:Leaderboard = m_summariesToShow.pop();
         var seenFlag:String = SUMMARY_SEEN_FLAG_PREFIX + leaderboardToShow.name;
         if(!Global.player.getSeenFlag(seenFlag))
         {
            Global.player.setSeenFlag(seenFlag);
            displayLeaderboardSummaryWindow(leaderboardToShow);
         }
      }
      
      public static function getLeaderboardForWidget(widget:ZwWidget) : Leaderboard
      {
         var result:Leaderboard = null;
         var window:LeaderboardSummaryWindow = null;
         var leaderboardFrame:LeaderboardFrame = widget.getAncestorByClassType(LeaderboardFrame) as LeaderboardFrame;
         if(leaderboardFrame)
         {
            result = leaderboardFrame.leaderboard;
         }
         else
         {
            window = widget.getAncestorByClassType(LeaderboardSummaryWindow) as LeaderboardSummaryWindow;
            if(window)
            {
               result = window.leaderboard;
            }
         }
         return result;
      }
      
      public static function getRankOrdinalText(rank:int) : String
      {
         var result:String = null;
         switch(rank)
         {
            case 1:
               result = ZLocUtils.t("Leaderboard","First");
               break;
            case 2:
               result = ZLocUtils.t("Leaderboard","Second");
               break;
            case 3:
               result = ZLocUtils.t("Leaderboard","Third");
               break;
            default:
               result = String(rank);
         }
         return result;
      }
      
      private static function conditionallyShowMultiTaskLeaderboardRewardDialog() : void
      {
         var leaderboard:Leaderboard = null;
         var userState:LeaderboardState = null;
         var showedRewardDialog:Boolean = false;
         var rankRewards:Array = null;
         var userRank:int = 0;
         var rankReward:Object = null;
         var scoreThreshold:int = 0;
         var currentTime:int = 0;
         var activeLeaderboards:Array = null;
         var toaster:MultiTaskLeaderboardNoRankRewardToasterWindow = null;
         var historicalLeaderboards:Array = Global.leaderboardConfigSettings.getHistoricalLeaderboards(LeaderboardConfigSettings.MULTI_TASK);
         if(historicalLeaderboards)
         {
            for each(leaderboard in historicalLeaderboards)
            {
               if(leaderboard.isExpired)
               {
                  userState = Global.player.getLeaderboardState(leaderboard.name);
                  if(!userState.rankRewardSeen)
                  {
                     showedRewardDialog = false;
                     rankRewards = leaderboard.rankRewards;
                     if(rankRewards)
                     {
                        userRank = userState.rank;
                        if(userRank > 0 && userRank <= rankRewards.length)
                        {
                           for each(rankReward in rankRewards)
                           {
                              if(userRank == int(rankReward["rank"]))
                              {
                                 displayMultiTaskLeaderboardRewardWindow(leaderboard,rankReward,RANK_REWARD_TYPE);
                                 showedRewardDialog = true;
                                 break;
                              }
                           }
                        }
                     }
                     if(!showedRewardDialog)
                     {
                        if(userState.seen)
                        {
                           scoreThreshold = Global.farmGameSettingsManager.getInt("multiTaskLeaderboardMinToasterScore",20);
                           if(userState.score >= scoreThreshold)
                           {
                              currentTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
                              if(leaderboard.expirationTime >= currentTime - FarmGameUtil.NUM_SECS_IN_WEEK)
                              {
                                 activeLeaderboards = Global.leaderboardConfigSettings.getActiveLeaderboards(LeaderboardConfigSettings.MULTI_TASK);
                                 if(Boolean(activeLeaderboards) && activeLeaderboards.length > 0)
                                 {
                                    toaster = new MultiTaskLeaderboardNoRankRewardToasterWindow(leaderboard);
                                    ToasterManager.getInstance().addImmediate(toaster);
                                 }
                              }
                           }
                        }
                     }
                     userState.rankRewardSeen = true;
                     TransactionManager.addTransaction(new TGenericTransaction("LeaderboardService","markRankRewardAsSeen",null,[leaderboard.name]),true);
                  }
               }
            }
         }
      }
      
      public static function displayMultiTaskLeaderboardWindow(tab:String = "") : MultiTaskLeaderboardWindow
      {
         if(!m_multiTaskLeaderboardWindow && Boolean(Global.leaderboardConfigSettings))
         {
            m_multiTaskLeaderboardWindow = new MultiTaskLeaderboardWindow(tab,onMultiTaskLeaderboardWindowClose);
            UI.displayPopup(m_multiTaskLeaderboardWindow,true,"MultiTaskLeaderboard",true);
         }
         return m_multiTaskLeaderboardWindow;
      }
      
      public static function onMultiTaskLeaderboardWindowClose() : void
      {
         m_multiTaskLeaderboardWindow = null;
      }
      
      public static function displayMultiTaskLeaderboardTutorial(closeCallback:Function = null) : void
      {
         TutorialUI.displayBundleTutorialWindow("Leaderboard","MultiTaskLeaderboard","assets/dialogs/4d_elements/FarmDerby2013/FarmDerby2013",false,closeCallback);
      }
      
      public static function displayMultiTaskLeaderboardRewardWindow(leaderboard:Leaderboard, reward:Object, rewardType:String) : void
      {
         var dialog:MultiTaskLeaderboardRewardWindow = new MultiTaskLeaderboardRewardWindow(leaderboard,reward,rewardType);
         UI.displayPopup(dialog,false,"MultiTaskLeaderboardReward");
         var userState:LeaderboardState = Global.player.getLeaderboardState(leaderboard.name);
         userState.rankRewardSeen = true;
         TransactionManager.addTransaction(new TGenericTransaction("LeaderboardService","markRankRewardAsSeen",null,[leaderboard.name]),true);
      }
   }
}

