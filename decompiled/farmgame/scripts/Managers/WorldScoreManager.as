package Managers
{
   import Classes.Constants.QuestConstants;
   import Classes.MapResource;
   import Classes.Quest.FarmQuestUtility;
   import Classes.Quest.FarmTask;
   import Classes.util.UserRewardUtil;
   import Engine.Events.TransactionEvent;
   import Transactions.TFarmTransaction;
   
   public class WorldScoreManager
   {
      
      public static const KEY_HIGHLIGHT_COLOR:String = "highlightColor";
      
      public function WorldScoreManager()
      {
         super();
      }
      
      public static function onTransactionAdded(event:TransactionEvent) : void
      {
         var transaction:TFarmTransaction = null;
         var task:FarmTask = null;
         var taskTotal:int = 0;
         var progression:int = 0;
         var rewardCount:int = 0;
         var tasks:Vector.<FarmTask> = Global.worldScoreSettingsManager.getTasksForWorldScoreId(WorldScoreSettingsManager.KEY_GLOBAL);
         if(Global.worldScoreSettingsManager.isEnabled(Global.worldManager.currentWorldScoreId))
         {
            tasks = tasks.concat(Global.worldScoreSettingsManager.getTasksForWorldScoreId(Global.worldManager.currentWorldScoreId));
            if(Global.worldScoreSettingsManager.isEnabled(Global.worldManager.currentWorldScore2Id))
            {
               tasks = tasks.concat(Global.worldScoreSettingsManager.getTasksForWorldScoreId(Global.worldManager.currentWorldScore2Id));
            }
         }
         for(var taskIndex:int = 0; taskIndex < tasks.length; taskIndex++)
         {
            transaction = event.transaction as TFarmTransaction;
            task = tasks[taskIndex];
            taskTotal = 1;
            if(task.hasOwnProperty("total"))
            {
               taskTotal = task.total;
            }
            progression = FarmQuestUtility.getInstance().getProgression(task,transaction,null);
            progression = Math.ceil(progression / taskTotal);
            if(progression > 0)
            {
               for(rewardCount = 0; rewardCount < progression; rewardCount++)
               {
                  UserRewardUtil.grantUserRewards(task.rewards);
               }
            }
         }
      }
      
      public static function onWorldLoaded() : void
      {
         var task:FarmTask = null;
         var worldObjects:Array = null;
         var objIdx:int = 0;
         var mapResource:MapResource = null;
         var highlightActions:Array = new Array(QuestConstants.TASK_EXPAND_STORAGE_BUILDING_TO_LEVEL_BY_CODE,QuestConstants.TASK_COMPLETE_NONDETERMINISTIC_CONSTRUCTION_BY_CODE);
         var tasksOfType:Vector.<FarmTask> = Global.worldScoreSettingsManager.getTasksOfAction(Global.worldManager.currentWorldScoreId,highlightActions);
         tasksOfType = tasksOfType.concat(Global.worldScoreSettingsManager.getTasksOfAction(Global.worldManager.currentWorldScore2Id,highlightActions));
         var numTasks:int = int(tasksOfType.length);
         for(var taskIdx:int = 0; taskIdx < numTasks; taskIdx++)
         {
            task = tasksOfType[taskIdx];
            if(task)
            {
               worldObjects = Global.world.getObjectsByCode(task.type);
               for(objIdx = 0; objIdx < worldObjects.length; objIdx++)
               {
                  mapResource = worldObjects[objIdx];
                  if(mapResource)
                  {
                     mapResource.highlightColor = parseInt(task.getAttribute(WorldScoreManager.KEY_HIGHLIGHT_COLOR));
                  }
               }
            }
         }
      }
   }
}

