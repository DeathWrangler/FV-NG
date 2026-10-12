package Managers
{
   import Classes.Constants.ArrowType;
   import Classes.Leaderboard.LeaderboardState;
   import Classes.Quest.FarmQuestUtility;
   import Classes.Quest.FarmTask;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.UserRewardUtil;
   import Classes.util.ZLocUtils;
   import Display.DynamicIconQueue;
   import Display.GenericPopup;
   import Display.QueuedIcons.SpecialQuestIcon;
   import Display.UI;
   import Engine.Events.TransactionEvent;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.OrderBoard.SpecialQuestManager;
   import Transactions.TFarmRunQuestShare;
   import Transactions.TFarmTransaction;
   import Transactions.TGenericTransaction;
   import Widgets.Slots.Leaderboard.LeaderboardSlotPlayerData;
   import Widgets.Windows.FarmRunQuestRewardWindow;
   import Widgets.Windows.FarmRunQuestWindow;
   import flash.utils.Timer;
   
   public class FarmRunQuestManager extends SpecialQuestManager
   {
      
      private static const KEY_SAVED_ACTIVE_TASKS:String = "ActiveTasks";
      
      private static const KEY_CURRENT_STAGE:String = "currentStage";
      
      private static const KEY_CURRENT_WORLD_NUM:String = "currentWorldNum";
      
      private static const KEY_FEATURE_COMPLETE:String = "FarmRunQuestsCompleted";
      
      private static const KEY_FEATURE_REPLAYED:String = "FarmRunQuestsIsReplayed";
      
      private static const KEY_FEATURE_PLAYED:String = "FarmRunQuestsPlayed";
      
      private static const KEY_FEATURE_PLAYED_ONCE:String = "FarmRunQuestsPlayedOnce";
      
      private static const SHOW_REPLAY_OR_MAINFEATURE:String = "ShowReplayOrMainFeature";
      
      private static const SHOW_MAINFEATURE:String = "ShowMainFeature";
      
      private static var m_farmRunRewardWindow:FarmRunQuestRewardWindow = null;
      
      public static const SELF_FRAME:int = 2;
      
      public static const ICON_SIZE:int = 25;
      
      private static var m_friendLists:Object = {};
      
      private var m_tasksById:Object = null;
      
      private var m_rewardsBySlotName:Object = null;
      
      private var m_FriendrewardsBySlotName:Object = null;
      
      private var m_extraRewardsBySlotName:Object = null;
      
      private const VAL_TASK_LENGTH:Number = 3;
      
      private const VAL_LAST_STAGE_IN_WORLD1:Number = 5;
      
      private const VAL_LAST_STAGE_IN_WORLD2:Number = 10;
      
      private const VAL_LAST_STAGE_IN_WORLD3:Number = 15;
      
      private var m_endTimeStamp:Number = 0;
      
      private var m_timer:Timer;
      
      private var m_hud:SpecialQuestIcon;
      
      protected const KEY_ID:String = "id";
      
      protected const KEY_PROGRESS:String = "progress";
      
      protected const KEY_TYPE:String = "type";
      
      protected const KEY_VALUE:String = "value";
      
      private var m_FarmRunWindow:FarmRunQuestWindow = null;
      
      private var m_CurrentStageNum:int = -1;
      
      private var m_CurrentWorldNum:int = -1;
      
      private const SERVICE_NAME:String = "FarmRunQuestService";
      
      private const QUEST_NAME:String = "oldFarmQuest";
      
      private const ASSET_PATH:String = "assets/dialogs/FV_DreamCatcherTrail_Reward_2015.swf";
      
      private const ASSET_PATH_2:String = "assets/dialogs/FV_DreamCatcherTrail_RewardFinal_2015.swf";
      
      private var iconUrl:String = null;
      
      public function FarmRunQuestManager(featureName:String = "FarmRunQuests")
      {
         super(featureName);
         m_featureName = "FarmRunQuests";
         this.initializeFeatureOptions();
         this.parseTaskObjectsFromConfig(this.QUEST_NAME);
         this.parseRewardsDataFromConfig(this.QUEST_NAME);
         this.parseExtraRewardsDataFromConfig(this.QUEST_NAME);
         this.parseFriendsRewardsDataFromConfig(this.QUEST_NAME);
         TransactionManager.getInstance().removeEventListener(TransactionEvent.ADDED,this.onTransactionAdded);
         if(this.isFeatureCompleted() == false)
         {
            TransactionManager.getInstance().addEventListener(TransactionEvent.ADDED,this.onTransactionAdded);
         }
         getOrCreateLeaderboardState("FarmRunQuests");
         sendGetFriendListTransaction("FarmRunQuests");
      }
      
      public static function getInstance(featureName:String = null) : FarmRunQuestManager
      {
         return getInstanceOfClass(featureName,FarmRunQuestManager) as FarmRunQuestManager;
      }
      
      private static function getOrCreateLeaderboardState(leaderboardName:String) : LeaderboardState
      {
         var leaderboardState:LeaderboardState = null;
         leaderboardState = Global.player.getLeaderboardState(leaderboardName);
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
         sendGetFriendListTransaction("FarmRunQuests");
      }
      
      private static function sendGetFriendListTransaction(leaderboardName:String) : void
      {
         TransactionManager.addTransaction(new TGenericTransaction("FarmRunQuestService","getFriendList",sendGetFriendListTransactionCallback,["FarmRunQuests"]),true);
      }
      
      private static function sendGetFriendListTransactionCallback(result:Object) : void
      {
         var leaderboardName:String = null;
         var friendList:Array = null;
         if(Boolean(result) && Boolean(result.hasOwnProperty("leaderboardName")) && result.hasOwnProperty("friendList"))
         {
            leaderboardName = result["leaderboardName"] as String;
            friendList = result["friendList"] as Array;
            m_friendLists[leaderboardName] = friendList;
         }
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
      
      public function getCurrentStage() : int
      {
         if(this.m_CurrentStageNum == -1)
         {
            this.m_CurrentStageNum = this.getFeatureOptionsKey(KEY_CURRENT_STAGE) as int;
         }
         return this.m_CurrentStageNum;
      }
      
      public function getCurrentWorldNum() : int
      {
         if(this.m_CurrentWorldNum == -1)
         {
            this.m_CurrentWorldNum = this.getFeatureOptionsKey(KEY_CURRENT_WORLD_NUM) as int;
         }
         return this.m_CurrentWorldNum;
      }
      
      public function handleHUDClick() : void
      {
         if(this.showReplayOrMainFeature())
         {
            this.openFarmRunQuestUI();
         }
         else
         {
            this.openReplayDialog();
         }
      }
      
      public function openFarmRunQuestUI() : void
      {
         this.m_FarmRunWindow = new FarmRunQuestWindow();
         UI.displayPopup(this.m_FarmRunWindow);
      }
      
      public function closeFarmRunQuestUI() : void
      {
         if(this.m_FarmRunWindow != null)
         {
            this.m_FarmRunWindow.close();
         }
      }
      
      private function setupHud() : void
      {
         var extraData:Object = {};
         extraData["iconTooltip"] = ZLocUtils.t("Dialogs",m_featureName + "_tooltip");
         this.m_hud = Global.hud.rightSideIconQueue.addIcon(m_featureName,DynamicIconQueue.ADD_BY_PRIORITY,null,extraData) as SpecialQuestIcon;
         if(this.m_hud)
         {
            this.m_hud.onAdd();
            this.m_hud.attachArrow(ArrowType.ARROWNEW);
            this.m_hud.playProgressBarAnimation(this.getTasksProgressRatio());
         }
      }
      
      public function skipTask(taskIndex:int) : Boolean
      {
         var savedTasks:Array = null;
         var leaderboardState:LeaderboardState = null;
         var incrementalValue:int = 0;
         var isQuestComplete:Boolean = false;
         var tasksToSave:Array = null;
         var i:int = 0;
         var taskObj:Object = null;
         var result:Boolean = false;
         var tasks:Vector.<FarmTask> = this.getTasks();
         if(Global.player.canBuyCash(tasks[taskIndex].skipCashValue))
         {
            Global.player.cash -= tasks[taskIndex].skipCashValue;
            result = true;
            savedTasks = this.getFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS) as Array;
            if(!savedTasks)
            {
               tasksToSave = [];
               for(i = 0; i < tasks.length; i++)
               {
                  taskObj = {};
                  taskObj[this.KEY_PROGRESS] = 0;
                  tasksToSave.push(taskObj);
               }
               savedTasks = tasksToSave;
            }
            savedTasks[taskIndex][this.KEY_PROGRESS] = tasks[taskIndex].total;
            this.saveFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS,savedTasks);
            leaderboardState = getOrCreateLeaderboardState("FarmRunQuests");
            incrementalValue = 1;
            incrementScore(leaderboardState,incrementalValue);
            isQuestComplete = this.checkQuestCompletion();
            if(isQuestComplete)
            {
               this.doQuestPostCompletionTasks();
            }
            TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_NAME,"skipTask",null,new Array(m_featureName,taskIndex)),true);
         }
         else
         {
            result = false;
         }
         return result;
      }
      
      public function skipAllTasks() : void
      {
         var leaderboardState:LeaderboardState = null;
         var incrementalValue:int = 0;
         var skipAllCash:int = FarmRunQuestManager.getInstance().getSkipAllCashValue();
         if(skipAllCash > 0 && Global.player.canBuyCash(skipAllCash))
         {
            Global.player.cash -= skipAllCash;
            TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_NAME,"skipAllTasks",null,new Array(m_featureName)),true);
            leaderboardState = getOrCreateLeaderboardState("FarmRunQuests");
            incrementalValue = this.getInCompleteTasks();
            incrementScore(leaderboardState,incrementalValue);
            this.doQuestPostCompletionTasks();
         }
      }
      
      public function skipAllTasksWithoutReward() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_NAME,"skipAllTasksWithOutFC",null,new Array(m_featureName)),true);
         this.doQuestPostCompletionTasksWithoutReward();
      }
      
      public function getInCompleteTasks() : int
      {
         var progress:int = 0;
         var value:int = 0;
         var tasks:Vector.<FarmTask> = this.getTasks();
         for(var i:int = 0; i < tasks.length; i++)
         {
            progress = this.getTaskProgress(i);
            if(progress < tasks[i].total)
            {
               value += 1;
            }
         }
         return value;
      }
      
      protected function onTransactionAdded(event:TransactionEvent) : void
      {
         this.checkForTaskUpdates(event);
      }
      
      protected function checkForTaskUpdates(event:TransactionEvent) : void
      {
         var transaction:TFarmTransaction = null;
         var task:FarmTask = null;
         var isComplete:Boolean = false;
         var leaderboardState:LeaderboardState = null;
         var incrementalValue:int = 0;
         var progress:Number = 0;
         var hasUpdatedProgress:Boolean = false;
         var progressArray:Array = [];
         var tasks:Vector.<FarmTask> = this.getTasks();
         for each(task in tasks)
         {
            transaction = event.transaction as TFarmTransaction;
            progress = FarmQuestUtility.getInstance().getProgression(task,transaction,null);
            progressArray.push(progress);
            if(progress > 0)
            {
               hasUpdatedProgress = true;
            }
         }
         if(hasUpdatedProgress)
         {
            this.saveProgressForPlayer(progressArray);
            isComplete = this.checkQuestCompletion();
            leaderboardState = getOrCreateLeaderboardState("FarmRunQuests");
            incrementalValue = 1;
            incrementScore(leaderboardState,incrementalValue);
            if(isComplete)
            {
               this.doQuestPostCompletionTasks();
            }
         }
      }
      
      protected function doQuestPostCompletionTasksWithoutReward() : void
      {
         this.m_FarmRunWindow.close();
         this.generateAndSaveNextTasks();
         if(this.m_CurrentStageNum == this.VAL_LAST_STAGE_IN_WORLD3)
         {
            this.openReplayDialog();
         }
         else
         {
            this.openFarmRunQuestUI();
         }
      }
      
      protected function doQuestPostCompletionTasks() : void
      {
         var reward:Object = null;
         var rewardArray:Array = null;
         var farmItem:FarmItem = null;
         var rewardItem:FarmItem = null;
         var featureOption:String = null;
         var rewards:Vector.<Object> = this.getRewards();
         for each(reward in rewards)
         {
            if(reward.type == "item_grant")
            {
               farmItem = Global.farmGameSettingsManager.getFarmItemByCode(reward.value);
               if(farmItem.type != "seed")
               {
                  UserRewardUtil.grantUserReward(reward);
               }
            }
            else
            {
               UserRewardUtil.grantUserReward(reward);
            }
         }
         rewardArray = this.getRewardsItemsArray();
         if(Boolean(rewardArray) && Boolean(rewardArray[FarmRunQuestManager.getInstance().getCurrentStage()]))
         {
            rewardItem = Global.farmGameSettingsManager.getFarmItemByCode(rewardArray[FarmRunQuestManager.getInstance().getCurrentStage()]);
            if(Boolean(rewardItem) && rewardItem.type == "seed")
            {
               featureOption = rewardItem.name;
               this.saveFeatureOptionsKey(featureOption,1);
               TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_NAME,"setFeatureOption",null,new Array(m_featureName,featureOption,"1")),true);
            }
         }
         this.m_FarmRunWindow.close();
         this.generateAndSaveNextTasks();
         var extraRewards:Vector.<Object> = null;
         if(this.m_CurrentStageNum == this.VAL_LAST_STAGE_IN_WORLD3)
         {
            TransactionManager.getInstance().removeEventListener(TransactionEvent.ADDED,this.onTransactionAdded);
            m_farmRunRewardWindow = new FarmRunQuestRewardWindow(this.openReplayDialog,this.ASSET_PATH_2,true);
            UI.displayPopup(m_farmRunRewardWindow);
            if(this.isFeatureReplayed() == false)
            {
               extraRewards = this.getExtraRewards();
               UserRewardUtil.grantUserRewards(extraRewards);
            }
            this.saveFeatureOptionsKey(KEY_FEATURE_COMPLETE,1);
            TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_NAME,"setFeatureOption",null,new Array(m_featureName,KEY_FEATURE_COMPLETE,"1")),true);
         }
         else
         {
            m_farmRunRewardWindow = new FarmRunQuestRewardWindow(this.openFarmRunQuestUI,this.ASSET_PATH);
            UI.displayPopup(m_farmRunRewardWindow);
         }
      }
      
      private function openReplayDialog() : void
      {
         this.saveFeatureOptionsKey(SHOW_REPLAY_OR_MAINFEATURE,0);
         TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_NAME,"setFeatureOption",null,new Array(m_featureName,SHOW_REPLAY_OR_MAINFEATURE,"0")),true);
         var message:String = "Do you want to replay the DreamCatcher\'s Trail again?";
         var replayPrompt:GenericPopup = new GenericPopup(message,GenericPopup.TYPE_YESNO,this.onCloseReplayQuestPrompt);
         if(replayPrompt)
         {
            TransactionManager.sendAllTransactions(true);
            UI.displayPopup(replayPrompt);
            FarmStatsManager.count("farmrun_replay_dialog","dialog_impressions");
         }
      }
      
      private function onCloseReplayQuestPrompt(event:GenericPopupEvent) : void
      {
         var leaderboardState:LeaderboardState = null;
         var incrementalValue:int = 0;
         if(Boolean(event) && event.button == GenericPopup.ACCEPT)
         {
            FarmStatsManager.count("farmrun_replay_dialog","dialog_clicks","click_replay");
            leaderboardState = Global.player.getLeaderboardState("FarmRunQuests");
            this.saveFeatureOptionsKey(KEY_FEATURE_REPLAYED,1);
            TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_NAME,"setFeatureOption",null,new Array(m_featureName,KEY_FEATURE_REPLAYED,"1")),true);
            this.saveFeatureOptionsKey(KEY_FEATURE_COMPLETE,0);
            TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_NAME,"setFeatureOption",null,new Array(m_featureName,KEY_FEATURE_COMPLETE,"0")),true);
            this.m_CurrentStageNum = -1;
            this.m_CurrentWorldNum = -1;
            this.saveFeatureOptionsKey(KEY_CURRENT_STAGE,0);
            TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_NAME,"setFeatureOption",null,new Array(m_featureName,KEY_CURRENT_STAGE,"0")),true);
            this.saveFeatureOptionsKey(KEY_CURRENT_WORLD_NUM,0);
            TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_NAME,"setFeatureOption",null,new Array(m_featureName,KEY_CURRENT_WORLD_NUM,"1")),true);
            this.resetFeatureOptions();
            leaderboardState = getOrCreateLeaderboardState("FarmRunQuests");
            incrementalValue = 45;
            incrementScore(leaderboardState,incrementalValue);
            TransactionManager.getInstance().removeEventListener(TransactionEvent.ADDED,this.onTransactionAdded);
            if(this.isFeatureCompleted() == false)
            {
               TransactionManager.getInstance().addEventListener(TransactionEvent.ADDED,this.onTransactionAdded);
            }
            FarmRunQuestManager.getInstance().openFarmRunQuestUI();
         }
         else
         {
            FarmStatsManager.count("farmrun_replay_dialog","dialog_clicks","click_close");
            this.saveFeatureOptionsKey(SHOW_REPLAY_OR_MAINFEATURE,0);
            TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_NAME,"setFeatureOption",null,new Array(m_featureName,SHOW_REPLAY_OR_MAINFEATURE,"0")),true);
         }
      }
      
      public function generateAndSaveNextTasks() : void
      {
         var taskObj:Object = null;
         ++this.m_CurrentStageNum;
         if(this.m_CurrentStageNum < this.VAL_LAST_STAGE_IN_WORLD1)
         {
            this.m_CurrentWorldNum = 1;
         }
         else if(this.m_CurrentStageNum < this.VAL_LAST_STAGE_IN_WORLD2)
         {
            this.m_CurrentWorldNum = 2;
         }
         else
         {
            this.m_CurrentWorldNum = 3;
         }
         this.saveFeatureOptionsKey(KEY_CURRENT_STAGE,this.m_CurrentStageNum);
         this.saveFeatureOptionsKey(KEY_CURRENT_WORLD_NUM,this.m_CurrentWorldNum);
         var savedTasks:Array = this.getFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS) as Array;
         var tasksToSave:Array = [];
         for(var i:int = 0; i < this.VAL_TASK_LENGTH; i++)
         {
            taskObj = {};
            taskObj[this.KEY_PROGRESS] = 0;
            tasksToSave.push(taskObj);
         }
         this.saveFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS,tasksToSave as Object);
         FarmStatsManager.count("FarmRunQuets","CurrentStage","","","","",this.m_CurrentStageNum);
         FarmStatsManager.count("FarmRunQuets","CurrentWorld","","","","",this.m_CurrentWorldNum);
      }
      
      protected function saveProgressForPlayer(progressArray:Array) : void
      {
         var taskObj:Object = null;
         var savedTasks:Array = this.getFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS) as Array;
         var tasksToSave:Array = [];
         for(var i:int = 0; i < this.VAL_TASK_LENGTH; i++)
         {
            taskObj = {};
            taskObj[this.KEY_PROGRESS] = savedTasks[i][this.KEY_PROGRESS] + progressArray[i];
            tasksToSave.push(taskObj);
         }
         this.saveFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS,tasksToSave as Object);
      }
      
      protected function checkQuestCompletion() : Boolean
      {
         var isComplete:Boolean = false;
         var tasks:Vector.<FarmTask> = this.getTasks();
         var stepsComplete:int = 0;
         var savedTaskInfo:Array = this.getFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS) as Array;
         for(var i:int = 0; i < tasks.length; i++)
         {
            if(savedTaskInfo[i][this.KEY_PROGRESS] >= tasks[i].total)
            {
               stepsComplete++;
            }
         }
         if(stepsComplete == tasks.length)
         {
            isComplete = true;
         }
         return isComplete;
      }
      
      private function getTasksProgressRatio() : Number
      {
         var i:int = 0;
         var result:Number = 0;
         var tasks:Vector.<FarmTask> = this.getTasks();
         var stepsComplete:int = 0;
         var savedTaskInfo:Array = this.getFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS) as Array;
         if(Boolean(savedTaskInfo) && Boolean(savedTaskInfo.length))
         {
            for(i = 0; i < tasks.length; i++)
            {
               if(savedTaskInfo[i][this.KEY_PROGRESS] >= tasks[i].total)
               {
                  stepsComplete++;
               }
            }
            result = stepsComplete / savedTaskInfo.length;
         }
         return result;
      }
      
      override public function getTasks() : Vector.<FarmTask>
      {
         var tasksXMLList:XMLList = null;
         var taskXML:XML = null;
         var taskObj:Object = null;
         var farmTask:FarmTask = null;
         var taskList:Vector.<FarmTask> = new Vector.<FarmTask>();
         if(this.m_tasksById == null)
         {
            this.parseTaskObjectsFromConfig(this.QUEST_NAME);
         }
         if(this.getCurrentStage() < 15)
         {
            tasksXMLList = this.m_tasksById[this.getCurrentStage() + 1].task;
            for each(taskXML in tasksXMLList)
            {
               taskObj = FarmGameUtil.xmlNodeToAttributes(taskXML);
               taskObj.questName = m_featureName;
               farmTask = new FarmTask(taskObj);
               taskList.push(farmTask);
            }
         }
         return taskList;
      }
      
      override public function getRewards() : Vector.<Object>
      {
         var rewardXML:XML = null;
         var rewardObj:Object = null;
         var rewards:Vector.<Object> = new Vector.<Object>();
         if(this.m_rewardsBySlotName == null)
         {
            this.parseRewardsDataFromConfig(this.QUEST_NAME);
         }
         var stageNum:int = this.getCurrentStage();
         var rewardXMLList:XMLList = this.m_rewardsBySlotName[stageNum + 1].reward;
         for each(rewardXML in rewardXMLList)
         {
            rewardObj = FarmGameUtil.xmlNodeToAttributes(rewardXML);
            if(rewards)
            {
               rewards.push(rewardObj);
            }
         }
         return rewards;
      }
      
      public function getExtraRewards() : Vector.<Object>
      {
         var rewardXML:XML = null;
         var rewardObj:Object = null;
         var rewards:Vector.<Object> = new Vector.<Object>();
         if(this.m_extraRewardsBySlotName == null)
         {
            this.parseExtraRewardsDataFromConfig(this.QUEST_NAME);
         }
         var stageNum:int = this.getCurrentStage();
         var rewardXMLList:XMLList = this.m_extraRewardsBySlotName[stageNum].reward;
         for each(rewardXML in rewardXMLList)
         {
            rewardObj = FarmGameUtil.xmlNodeToAttributes(rewardXML);
            if(rewards)
            {
               rewards.push(rewardObj);
            }
         }
         return rewards;
      }
      
      public function getRewardsItemsArray() : Array
      {
         var rewardXMLList:XMLList = null;
         var rewardXML:XML = null;
         var rewardObj:Object = null;
         var rewards:Array = new Array();
         if(this.m_rewardsBySlotName == null)
         {
            this.parseRewardsDataFromConfig(m_featureName);
         }
         for(var i:int = 0; i < this.VAL_LAST_STAGE_IN_WORLD3; i++)
         {
            rewardXMLList = this.m_rewardsBySlotName[i + 1].reward;
            for each(rewardXML in rewardXMLList)
            {
               rewardObj = FarmGameUtil.xmlNodeToAttributes(rewardXML);
               if(Boolean(rewardObj) && Boolean(rewardObj.hasOwnProperty("type")) && rewardObj.type == "item_grant")
               {
                  rewards.push(rewardObj.value);
               }
            }
         }
         return rewards;
      }
      
      public function getWorldCompleteRewardsItemsArray(stageNum:Number) : String
      {
         var rewardXML:XML = null;
         var rewardObj:Object = null;
         var itemCode:String = null;
         if(this.m_extraRewardsBySlotName == null)
         {
            this.parseExtraRewardsDataFromConfig(this.QUEST_NAME);
         }
         var rewardXMLList:XMLList = this.m_extraRewardsBySlotName[stageNum].reward;
         for each(rewardXML in rewardXMLList)
         {
            rewardObj = FarmGameUtil.xmlNodeToAttributes(rewardXML);
            if(Boolean(rewardObj) && Boolean(rewardObj.hasOwnProperty("type")) && rewardObj.type == "item_grant")
            {
               itemCode = rewardObj.value;
               break;
            }
         }
         return itemCode;
      }
      
      public function getSkipAllCashValue() : int
      {
         var progress:int = 0;
         var value:int = 0;
         var tasks:Vector.<FarmTask> = this.getTasks();
         for(var i:int = 0; i < tasks.length; i++)
         {
            progress = this.getTaskProgress(i);
            if(progress < tasks[i].total)
            {
               value += tasks[i].skipCashValue;
            }
         }
         return value;
      }
      
      public function getFeatureOptionsKey(optionName:String) : Object
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,optionName);
      }
      
      public function saveFeatureOptionsKey(optionName:String, optionsValue:Object) : void
      {
         FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,optionName,optionsValue);
      }
      
      public function removeFeatureOptionsKey(optionName:String) : void
      {
         FeatureOptionsManager.deleteFeatureOption(m_featureName,optionName);
      }
      
      public function initializeFeatureOptions() : void
      {
         var isPlayed:Object = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,KEY_FEATURE_PLAYED);
         if(!isPlayed)
         {
            this.resetFeatureOptions();
            this.saveFeatureOptionsKey(KEY_FEATURE_PLAYED,1);
            TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_NAME,"setFeatureOption",null,new Array(m_featureName,KEY_FEATURE_PLAYED,"1")),true);
         }
         var isPlayedOnce:Object = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,KEY_FEATURE_PLAYED_ONCE);
         if(!isPlayedOnce)
         {
            this.saveFeatureOptionsKey(KEY_FEATURE_COMPLETE,0);
            TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_NAME,"setFeatureOption",null,new Array(m_featureName,KEY_FEATURE_COMPLETE,"0")),true);
            this.saveFeatureOptionsKey(KEY_FEATURE_PLAYED_ONCE,1);
            TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_NAME,"setFeatureOption",null,new Array(m_featureName,KEY_FEATURE_PLAYED_ONCE,"1")),true);
         }
         var isShowMainFeature:Object = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,SHOW_MAINFEATURE);
         if(!isShowMainFeature)
         {
            this.saveFeatureOptionsKey(SHOW_REPLAY_OR_MAINFEATURE,1);
            TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_NAME,"setFeatureOption",null,new Array(m_featureName,SHOW_REPLAY_OR_MAINFEATURE,"1")),true);
            this.saveFeatureOptionsKey(SHOW_MAINFEATURE,1);
            TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_NAME,"setFeatureOption",null,new Array(m_featureName,SHOW_MAINFEATURE,"1")),true);
         }
      }
      
      public function resetFeatureOptions() : void
      {
         var taskObj:Object = null;
         var tasksToSave:Array = [];
         for(var i:int = 0; i < this.VAL_TASK_LENGTH; i++)
         {
            taskObj = {};
            taskObj[this.KEY_PROGRESS] = 0;
            tasksToSave.push(taskObj);
         }
         this.saveFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS,tasksToSave as Object);
         this.saveFeatureOptionsKey(KEY_CURRENT_STAGE,0);
         this.saveFeatureOptionsKey(KEY_CURRENT_WORLD_NUM,1);
         this.saveFeatureOptionsKey(KEY_FEATURE_PLAYED,1);
         this.saveFeatureOptionsKey(SHOW_REPLAY_OR_MAINFEATURE,1);
         TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_NAME,"setFeatureOption",null,new Array(m_featureName,SHOW_REPLAY_OR_MAINFEATURE,"1")),true);
         TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_NAME,"initializeFeatureOptions",null,new Array(m_featureName)),true);
         this.saveFeatureOptionsKey(KEY_FEATURE_COMPLETE,0);
         TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_NAME,"setFeatureOption",null,new Array(m_featureName,KEY_FEATURE_COMPLETE,"0")),true);
      }
      
      protected function parseTaskObjectsFromConfig(questName:String) : void
      {
         var FarmRunQuestXml:XML = null;
         var stagetasksList:XMLList = null;
         var tasksByStage:XML = null;
         var tasksXMLListByStage:XMLList = null;
         this.m_tasksById = {};
         FarmRunQuestXml = Global.farmGameSettingsManager.getXML().FarmRunQuests.FarmRunQuest.(@name == questName)[0];
         if(FarmRunQuestXml)
         {
            stagetasksList = FarmRunQuestXml.FarmRunQuestTasks.stagetasks;
            for each(tasksByStage in stagetasksList)
            {
               tasksXMLListByStage = tasksByStage.tasks;
               this.m_tasksById[tasksByStage.@id] = tasksXMLListByStage;
            }
         }
      }
      
      protected function parseRewardsDataFromConfig(questName:String) : void
      {
         var orderBoardXml:XML = null;
         var rewardsList:XMLList = null;
         var rewardsByStage:XML = null;
         var str:String = null;
         var rewardsXMLListByStage:XMLList = null;
         this.m_rewardsBySlotName = {};
         orderBoardXml = Global.farmGameSettingsManager.getXML().FarmRunQuests.FarmRunQuest.(@name == questName)[0];
         rewardsList = orderBoardXml.FarmRunQuestRewards.stage;
         for each(rewardsByStage in rewardsList)
         {
            str = rewardsByStage.@id;
            rewardsXMLListByStage = rewardsByStage.rewards;
            this.m_rewardsBySlotName[rewardsByStage.@id] = rewardsXMLListByStage;
         }
      }
      
      protected function parseExtraRewardsDataFromConfig(questName:String) : void
      {
         var orderBoardXml:XML = null;
         var rewardsList:XMLList = null;
         var rewardsByStage:XML = null;
         var str:String = null;
         var rewardsXMLListByStage:XMLList = null;
         this.m_extraRewardsBySlotName = {};
         orderBoardXml = Global.farmGameSettingsManager.getXML().FarmRunQuests.FarmRunQuest.(@name == questName)[0];
         rewardsList = orderBoardXml.FarmRunQuestExtraRewards.stage;
         for each(rewardsByStage in rewardsList)
         {
            str = rewardsByStage.@id;
            rewardsXMLListByStage = rewardsByStage.rewards;
            this.m_extraRewardsBySlotName[rewardsByStage.@id] = rewardsXMLListByStage;
         }
      }
      
      protected function parseFriendsRewardsDataFromConfig(questName:String) : void
      {
         var orderBoardXml:XML = null;
         var rewardsList:XMLList = null;
         var rewardsByStage:XML = null;
         var str:String = null;
         var rewardsXMLListByStage:XMLList = null;
         this.m_FriendrewardsBySlotName = {};
         orderBoardXml = Global.farmGameSettingsManager.getXML().FarmRunQuests.FarmRunQuest.(@name == questName)[0];
         rewardsList = orderBoardXml.FarmRunQuestFriendsRewards.stage;
         for each(rewardsByStage in rewardsList)
         {
            str = rewardsByStage.@id;
            rewardsXMLListByStage = rewardsByStage.rewards;
            this.m_FriendrewardsBySlotName[rewardsByStage.@id] = rewardsXMLListByStage;
         }
      }
      
      public function getFriendsRewardsItemsArray() : Array
      {
         var rewardXMLList:XMLList = null;
         var rewardXML:XML = null;
         var rewardObj:Object = null;
         var rewards:Array = new Array();
         if(this.m_FriendrewardsBySlotName == null)
         {
            this.parseFriendsRewardsDataFromConfig(m_featureName);
         }
         for(var i:int = 0; i < this.VAL_LAST_STAGE_IN_WORLD3; i++)
         {
            rewardXMLList = this.m_FriendrewardsBySlotName[i + 1].reward;
            for each(rewardXML in rewardXMLList)
            {
               rewardObj = FarmGameUtil.xmlNodeToAttributes(rewardXML);
               if(rewardObj)
               {
                  rewards.push(rewardObj.value);
               }
            }
         }
         return rewards;
      }
      
      public function getTaskProgress(taskIndex:int) : int
      {
         var progress:int = 0;
         var savedTasksProgress:Array = this.getFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS) as Array;
         if(Boolean(savedTasksProgress) && Boolean(savedTasksProgress[taskIndex][this.KEY_PROGRESS]))
         {
            progress = int(savedTasksProgress[taskIndex][this.KEY_PROGRESS]);
         }
         return progress;
      }
      
      public function getTimeRemaining() : String
      {
         var remainingTime:Number = NaN;
         var result:String = "0 Hours";
         if(!this.isExpired())
         {
            remainingTime = this.m_endTimeStamp - GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            result = FarmGameUtil.toFriendlyTime(remainingTime);
         }
         return result;
      }
      
      public function isExpired() : Boolean
      {
         var result:Boolean = true;
         var config:XML = Global.farmGameSettingsManager.getFeatureXML(m_featureName);
         if(config != null)
         {
            this.m_endTimeStamp = FarmGameUtil.synchronizedDateToNumber(config["listEndDate"]) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         }
         var currentTime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         if(this.m_endTimeStamp > 0 && this.m_endTimeStamp > currentTime)
         {
            result = false;
         }
         return result;
      }
      
      public function getFriendsListByStage(stage:int) : LeaderboardSlotPlayerData
      {
         var leaderboardFriendListLength:int = 0;
         var i:int = 0;
         var friendData:Object = null;
         var result:Object = new Object();
         var leaderboardFriendList:Array = FarmRunQuestManager.getFriendList("FarmRunQuests");
         if(leaderboardFriendList)
         {
            leaderboardFriendListLength = int(leaderboardFriendList.length);
            for(i = 0; i < leaderboardFriendListLength; i++)
            {
               friendData = new LeaderboardSlotPlayerData(Number(leaderboardFriendList[i]["uid"]),int(leaderboardFriendList[i]["value"]));
               result[friendData.score / this.VAL_TASK_LENGTH] = friendData;
            }
         }
         if(result[stage])
         {
            return result[stage];
         }
         return null;
      }
      
      public function postRewardFeed(rewardLink:String) : void
      {
         var creativeBundleName:String = null;
         var rewardItem:FarmItem = null;
         var item:FarmItem = null;
         var iconUrl:String = null;
         var bundleData:Object = null;
         if(rewardLink != null)
         {
            creativeBundleName = "FarmRunQuestsShareReward";
            rewardItem = this.getRewardItemForFinishedStage();
            item = this.getFriendsRewardItemForFinishedStage();
            iconUrl = rewardItem.getImageByName(FarmItem.ICON_FEED);
            if(!iconUrl)
            {
               iconUrl = rewardItem.icon;
            }
            if(creativeBundleName != null && creativeBundleName != "" && item != null)
            {
               bundleData = {
                  "actor":Global.player.firstName,
                  "reward_link":rewardLink,
                  "rewardName":rewardItem.friendlyName,
                  "itemName":item.friendlyName,
                  "images":[{
                     "src":iconUrl,
                     "href":Config.SN_APP_URL + rewardLink
                  }]
               };
               GlobalEngine.socialNetwork.publishFeedStory(creativeBundleName,bundleData,[],false);
            }
         }
      }
      
      public function shareReward() : void
      {
         var itemCode:String = null;
         itemCode = this.getFriendsRewardItemForFinishedStage().code;
         TransactionManager.addTransaction(new TFarmRunQuestShare(m_featureName,itemCode));
      }
      
      public function getRewardItemForFinishedStage() : FarmItem
      {
         var rewardsArray:Array = null;
         var farmItem:FarmItem = null;
         var justFinishedStage:Number = this.getCurrentStage() - 1;
         if(justFinishedStage >= 0)
         {
            rewardsArray = this.getRewardsItemsArray();
            farmItem = Global.farmGameSettingsManager.getFarmItemByCode(rewardsArray[justFinishedStage]);
         }
         return farmItem;
      }
      
      public function getFriendsRewardItemForFinishedStage() : FarmItem
      {
         var rewardsArray:Array = null;
         var farmItem:FarmItem = null;
         var justFinishedStage:Number = this.getCurrentStage() - 1;
         if(justFinishedStage >= 0)
         {
            rewardsArray = this.getFriendsRewardsItemsArray();
            farmItem = Global.farmGameSettingsManager.getFarmItemByCode(rewardsArray[justFinishedStage]);
         }
         return farmItem;
      }
      
      public function isFeatureCompleted() : Boolean
      {
         var result:Boolean = false;
         var isFeatureComplete:Object = this.getFeatureOptionsKey(KEY_FEATURE_COMPLETE);
         if(int(isFeatureComplete) == 1)
         {
            result = true;
         }
         return result;
      }
      
      public function isFeatureReplayed() : Boolean
      {
         var result:Boolean = false;
         var isFeatureComplete:Object = this.getFeatureOptionsKey(KEY_FEATURE_REPLAYED);
         if(int(isFeatureComplete) == 1)
         {
            result = true;
         }
         return result;
      }
      
      public function showReplayOrMainFeature() : Boolean
      {
         var result:Boolean = false;
         var showFeature:Object = this.getFeatureOptionsKey(SHOW_REPLAY_OR_MAINFEATURE);
         if(int(showFeature) == 1)
         {
            result = true;
         }
         return result;
      }
      
      public function getUserScore() : int
      {
         var result:int = 0;
         if(this.isFeatureCompleted() == true || this.isFeatureReplayed() == true)
         {
            result = this.VAL_LAST_STAGE_IN_WORLD3 * this.VAL_TASK_LENGTH;
         }
         else
         {
            result = (this.getCurrentStage() + 1) * this.VAL_TASK_LENGTH - this.getInCompleteTasks();
         }
         return result;
      }
      
      public function getUserLeaderboardRank(leaderboardName:String) : int
      {
         var i:int = 0;
         var leaderboardFriendListLength:int = 0;
         var friendData:Object = null;
         var result:int = 1;
         var userScore:int = FarmRunQuestManager.getInstance().getUserScore();
         var leaderboardFriendList:Array = FarmRunQuestManager.getFriendList(leaderboardName);
         if(leaderboardFriendList)
         {
            result = leaderboardFriendList.length + 1;
            leaderboardFriendListLength = int(leaderboardFriendList.length);
            for(i = 0; i < leaderboardFriendListLength; i++)
            {
               friendData = new LeaderboardSlotPlayerData(Number(leaderboardFriendList[i]["uid"]),int(leaderboardFriendList[i]["value"]));
               if(userScore >= friendData.score)
               {
                  result = i + 1;
                  break;
               }
            }
         }
         return result;
      }
   }
}

