package Managers
{
   import Classes.AutoConsumable;
   import Classes.CommunityGoals.CommunityGoalsTask;
   import Classes.Constants.PrerequisiteConstants;
   import Classes.Quest.FarmQuestUtility;
   import Classes.Quest.FarmTask;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.ZItem.ConsumableItem;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Events.TransactionEvent;
   import Engine.Managers.TransactionManager;
   import Events.DynamicObjectEvent;
   import Transactions.TCommunityGoalsGetProgress;
   import Transactions.TFarmTransaction;
   import Widgets.Windows.CommunityGoalsRewardWindow;
   import Widgets.Windows.CommunityGoalsWindow;
   
   public class CommunityGoalsManager extends BaseFeatureManager
   {
      
      public static const FEATURE_NAME:String = "communityGoals";
      
      public static const REWARD_PLAYER:String = "player";
      
      public static const REWARD_COMMUNITY:String = "community";
      
      public static const NUM_STAGES:int = 5;
      
      public static const DIALOG_ASSET_KEY:String = "dialog";
      
      public static const DIALOG_BG_KEY:String = "dialogBackground";
      
      public static const MOTD_DIALOG_ASSET_KEY:String = "motdDialog";
      
      public static const MOTD_DIALOG_BG_KEY:String = "motdDialogBackground";
      
      public static const REWARD_DIALOG_ASSET_KEY:String = "congratsDialog";
      
      public static const REWARD_DIALOG_BG_KEY:String = "congratsDialogBackground";
      
      public static const TUT_O_ASSET_KEY:String = "tut_0";
      
      public static const TUT_1_ASSET_KEY:String = "tut_1";
      
      public static const TUT_2_ASSET_KEY:String = "tut_2";
      
      public static const TUT_3_ASSET_KEY:String = "tut_3";
      
      private static const MOTD_NAME:String = "MOTD_COMMUNITY_GOALS";
      
      private static const COMMUNITY_GOALS_TASK_DATA:String = "COMMUNITY_GOALS_TASK_DATA";
      
      private static const COMMUNITY_GOALS_TESTING_FLAG:String = "COMMUNITY_GOALS_TESTING";
      
      public static const NPC_URL:String = "npcUrl";
      
      public static const FEATURE_OPS_PLAYER_COUNT:String = "player_count";
      
      public static const FEATURE_OPS_UPDATE_COUNT:String = "task_update_count";
      
      public static const FEATURE_OPS_REWARDS:String = "rewards";
      
      private var m_taskList:Array;
      
      private var m_featureStartDate:String;
      
      private var m_assetPath:String;
      
      private var m_rewardsEarned:Object;
      
      private var m_cachedTaskData:Object;
      
      private var m_communityGoalsWindow:CommunityGoalsWindow = null;
      
      public function CommunityGoalsManager(featureName:String = "communityGoals")
      {
         super(featureName);
      }
      
      public static function onTransactionAdded(event:TransactionEvent) : void
      {
         getInstance().checkForTaskUpdates(event);
      }
      
      public static function getInstance(featureName:String = "communityGoals") : CommunityGoalsManager
      {
         return BaseFeatureManager.getInstanceOfClass(featureName,CommunityGoalsManager) as CommunityGoalsManager;
      }
      
      public function getFeatureConfig(featureName:String = "communityGoals") : XML
      {
         return m_featureConfig;
      }
      
      public function init(data:Object) : void
      {
         if(this.isEnabled() && !Global.worldManager.isVisiting())
         {
            if(data)
            {
               if(data.hasOwnProperty("rewards"))
               {
                  this.m_rewardsEarned = data.rewards;
               }
            }
            TransactionManager.getInstance().addEventListener(TransactionEvent.ADDED,CommunityGoalsManager.onTransactionAdded);
            ActionDropsManager.getInstance().addEventListener(ActionDropsManager.EVENT_DOOBER_PROGRESS,this.onActionDropsUpdated);
         }
      }
      
      public function registerFeature() : void
      {
         FeatureMessagingManager.getInstance().registerFeatureInitialized(FEATURE_NAME,this.displayDialog);
      }
      
      private function onActionDropsUpdated(event:DynamicObjectEvent) : void
      {
         var actionDropsData:Object = null;
         var task:CommunityGoalsTask = null;
         var farmTask:FarmTask = null;
         var actionDropItem:FarmItem = null;
         if(event.data)
         {
            actionDropsData = event.data;
            if(actionDropsData != null)
            {
               task = this.getActiveTask();
               if(task)
               {
                  farmTask = new FarmTask(FarmGameUtil.xmlNodeToAttributes(task.questTask[0]));
                  if(farmTask)
                  {
                     actionDropItem = actionDropsData.item as FarmItem;
                     if(actionDropItem)
                     {
                        if(farmTask.type == actionDropItem.code)
                        {
                           if(actionDropsData.amount > 0)
                           {
                              this.addTaskCountForPlayer(task.name,actionDropsData.amount);
                           }
                        }
                     }
                  }
               }
            }
         }
      }
      
      private function checkForTaskUpdates(event:TransactionEvent) : void
      {
         var farmTask:FarmTask = null;
         var transaction:TFarmTransaction = null;
         var questTaskXML:XML = null;
         var progress:Number = 0;
         var task:CommunityGoalsTask = this.getActiveTask();
         if(task)
         {
            questTaskXML = task.questTask[0];
            if(questTaskXML)
            {
               transaction = event.transaction as TFarmTransaction;
               farmTask = new FarmTask(FarmGameUtil.xmlNodeToAttributes(questTaskXML));
               progress = FarmQuestUtility.getInstance().getProgression(farmTask,transaction,null);
               if(progress > 0)
               {
                  this.addTaskCountForPlayer(task.name,progress);
               }
            }
         }
      }
      
      private function createDefaultFeatureOps() : Object
      {
         var featureOps:Object = new Object();
         featureOps[FEATURE_OPS_PLAYER_COUNT] = 0;
         featureOps[FEATURE_OPS_UPDATE_COUNT] = 0;
         featureOps[FEATURE_OPS_REWARDS] = new Object();
         for(var i:int = 0; i < NUM_STAGES; i++)
         {
            featureOps[FEATURE_OPS_REWARDS][i] = 0;
         }
         return featureOps;
      }
      
      private function addTaskCountForPlayer(taskName:String, progress:Number) : void
      {
         var featureOps:Object = this.getFeatureOptionsForTask(taskName);
         if(!featureOps)
         {
            featureOps = this.createDefaultFeatureOps();
         }
         featureOps[FEATURE_OPS_PLAYER_COUNT] += progress;
         FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_NAME,taskName,featureOps);
      }
      
      public function setTaskList() : void
      {
         var cgTask:CommunityGoalsTask = null;
         var task:XML = null;
         var result:Array = new Array();
         var featureConfig:XML = this.getFeatureConfig();
         if(featureConfig)
         {
            for each(task in featureConfig.cgTask)
            {
               cgTask = new CommunityGoalsTask(task);
               if(cgTask)
               {
                  result.push(cgTask);
               }
            }
         }
         this.m_taskList = result;
      }
      
      public function getTaskList() : Array
      {
         if(!this.m_taskList)
         {
            this.setTaskList();
         }
         return this.m_taskList;
      }
      
      public function getActiveTask() : CommunityGoalsTask
      {
         var result:CommunityGoalsTask = null;
         var task:CommunityGoalsTask = null;
         var taskList:Array = this.getTaskList();
         if(taskList)
         {
            for each(task in taskList)
            {
               if(task.isActive())
               {
                  result = task;
                  break;
               }
            }
         }
         return result;
      }
      
      public function shouldTaskBeShown() : Boolean
      {
         var currentSeason:int = 0;
         var result:Boolean = false;
         var task:CommunityGoalsTask = this.getActiveTask();
         if(task)
         {
            if(!task.world || task.world == "")
            {
               result = true;
            }
            else if(task.world == Global.worldManager.currentWorldType)
            {
               if(task.season)
               {
                  currentSeason = WorldSeasonsManager.getInstance().getCurrentSeason(Global.worldManager.currentWorldType);
                  if(currentSeason == task.season)
                  {
                     result = true;
                  }
               }
               else
               {
                  result = true;
               }
            }
         }
         return result;
      }
      
      public function isRewardGrantedForStage(taskName:String, stageNumber:Number) : Boolean
      {
         var result:Boolean = false;
         var featureOps:Object = this.getFeatureOptionsForTask(taskName);
         if(Boolean(featureOps) && Boolean(featureOps[FEATURE_OPS_REWARDS]))
         {
            if(featureOps[FEATURE_OPS_REWARDS][stageNumber - 1] == 1)
            {
               result = true;
            }
         }
         return result;
      }
      
      public function getPlayerCountForTask(taskName:String) : Number
      {
         var result:Number = 0;
         var featureOps:Object = this.getFeatureOptionsForTask(taskName);
         if(Boolean(featureOps) && Boolean(featureOps[FEATURE_OPS_PLAYER_COUNT]))
         {
            result = Number(featureOps[FEATURE_OPS_PLAYER_COUNT]);
         }
         return result;
      }
      
      private function getFeatureOptionsForTask(taskName:String) : Object
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_NAME,taskName);
      }
      
      public function displayDialog() : void
      {
         var assetPath:String = null;
         var bgPath:String = null;
         var npcPath:String = null;
         var activeTask:CommunityGoalsTask = this.getActiveTask();
         if(activeTask)
         {
            assetPath = activeTask.getAssetPathFor(CommunityGoalsManager.DIALOG_ASSET_KEY);
            bgPath = activeTask.getAssetPathFor(CommunityGoalsManager.DIALOG_BG_KEY);
            npcPath = activeTask.getAssetPathFor(CommunityGoalsManager.NPC_URL);
            if(assetPath != null)
            {
               this.m_communityGoalsWindow = new CommunityGoalsWindow(activeTask,assetPath,bgPath,npcPath);
            }
            else
            {
               this.m_communityGoalsWindow = new CommunityGoalsWindow(activeTask,null,bgPath,npcPath);
            }
            UI.displayPopup(this.m_communityGoalsWindow);
         }
      }
      
      public function displayRewardDialog() : void
      {
         var rewardXMLs:Array = null;
         var taskList:Array = null;
         var activeTask:CommunityGoalsTask = null;
         var isFinalStageReward:Boolean = false;
         var task:CommunityGoalsTask = null;
         var i:int = 0;
         var rewardDialogAsset:String = null;
         var m_rewardsWindow:CommunityGoalsRewardWindow = null;
         var rewardBgAsset:String = null;
         if(this.m_rewardsEarned)
         {
            rewardXMLs = new Array();
            taskList = this.getTaskList();
            activeTask = this.getActiveTask();
            isFinalStageReward = false;
            if(taskList)
            {
               for each(task in taskList)
               {
                  if(this.m_rewardsEarned[task.name])
                  {
                     for(i = 0; i < CommunityGoalsManager.NUM_STAGES; i++)
                     {
                        if(this.m_rewardsEarned[task.name][i])
                        {
                           rewardXMLs.push(task.rewards[i]);
                           this.grantConsumable(task.rewards[i]);
                           this.setRewardGrantedForStage(task.name,i + 1);
                           if(i + 1 == CommunityGoalsManager.NUM_STAGES)
                           {
                              isFinalStageReward = true;
                           }
                        }
                     }
                  }
               }
            }
            if(rewardXMLs.length > 0)
            {
               rewardDialogAsset = null;
               if(activeTask != null)
               {
                  rewardDialogAsset = activeTask.getAssetPathFor(REWARD_DIALOG_ASSET_KEY);
               }
               rewardBgAsset = activeTask.getAssetPathFor(REWARD_DIALOG_BG_KEY);
               if(rewardDialogAsset != null)
               {
                  m_rewardsWindow = new CommunityGoalsRewardWindow(rewardXMLs,isFinalStageReward,rewardDialogAsset,rewardBgAsset);
               }
               else
               {
                  m_rewardsWindow = new CommunityGoalsRewardWindow(rewardXMLs,isFinalStageReward,null,rewardBgAsset);
               }
               UI.displayPopup(m_rewardsWindow);
            }
         }
      }
      
      public function grantConsumable(reward:XML) : void
      {
         var farmItem:FarmItem = null;
         var packageItems:Object = null;
         var itemName:String = null;
         var i:int = 0;
         var rewardName:String = reward.attribute("name").toString();
         var rewardCount:int = parseInt(reward.attribute("qty").toString());
         if(Boolean(rewardName) && rewardName != "")
         {
            farmItem = Global.farmGameSettingsManager.getFarmItemByName(rewardName);
            packageItems = farmItem.getItemPackageHash();
            if(Boolean(farmItem) && packageItems != null)
            {
               for(itemName in packageItems)
               {
                  for(i = 0; i < packageItems[itemName]; i++)
                  {
                     this.addConsumables(itemName,rewardCount);
                  }
               }
            }
            else
            {
               this.addConsumables(rewardName,rewardCount);
            }
         }
      }
      
      private function addConsumables(itemName:String, count:int) : void
      {
         var i:int = 0;
         var autoConsumable:AutoConsumable = null;
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         if(farmItem is ConsumableItem && (farmItem as ConsumableItem).isAutoConsumable())
         {
            for(i = 0; i < count; i++)
            {
               autoConsumable = AutoConsumable.createAutoConsumable(itemName);
               autoConsumable.consume();
            }
         }
      }
      
      private function setRewardGrantedForStage(taskName:String, stage:Number) : void
      {
         var featureOps:Object = this.getFeatureOptionsForTask(taskName);
         if(Boolean(featureOps) && Boolean(featureOps[FEATURE_OPS_REWARDS]))
         {
            featureOps[FEATURE_OPS_REWARDS][stage - 1] = 1;
         }
         FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_NAME,taskName,featureOps);
      }
      
      public function getCommunityProgressForTask(taskName:String, callback:Function = null) : void
      {
         var activeTask:CommunityGoalsTask = this.getActiveTask();
         if(activeTask.name == taskName)
         {
            TransactionManager.addTransaction(new TCommunityGoalsGetProgress(activeTask,callback),true);
         }
      }
      
      public function isTestingMode() : Boolean
      {
         var result:Boolean = false;
         if(Boolean(Global.flashHotParams[COMMUNITY_GOALS_TESTING_FLAG]) && Global.flashHotParams[COMMUNITY_GOALS_TESTING_FLAG] == true)
         {
            result = true;
         }
         return result;
      }
      
      public function getRuntimeTaskData(taskName:String) : Object
      {
         var dataObj:Object = null;
         var taskData:Object = null;
         if(!this.m_cachedTaskData)
         {
            this.m_cachedTaskData = new Object();
            if(Global.flashHotParams.hasOwnProperty(COMMUNITY_GOALS_TASK_DATA))
            {
               dataObj = FarmGameUtil.JSONDecode(Global.flashHotParams[COMMUNITY_GOALS_TASK_DATA].toString(),"CommunityGoalsManager_getRuntimeTaskData");
               if(dataObj)
               {
                  this.m_cachedTaskData = dataObj;
               }
            }
         }
         if(this.m_cachedTaskData[taskName])
         {
            taskData = this.m_cachedTaskData[taskName];
         }
         return taskData;
      }
      
      public function isEnabled() : Boolean
      {
         return PrerequisiteUtility.checkPrereqByName(PrerequisiteConstants.PREREQUISITE_COMMUNITY_GOALS_ENABLED);
      }
      
      public function getDescriptionForTask(taskName:String) : String
      {
         return ZLocUtils.t("Dialogs","community_goals_" + taskName + "_desc");
      }
   }
}

