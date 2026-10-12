package Classes.CommunityGoals
{
   import Classes.util.FarmGameUtil;
   import Managers.CommunityGoalsManager;
   
   public class CommunityGoalsTask
   {
      
      private var m_manager:CommunityGoalsManager;
      
      public var name:String;
      
      public var world:String;
      
      public var season:int = 0;
      
      public var questTask:XMLList;
      
      public var startDate:String;
      
      public var endDate:String;
      
      public var playerGoal:Number;
      
      public var communityGoal:Number;
      
      public var rewards:XMLList;
      
      public var ignoreProgLimit:Boolean;
      
      public var progVariableA:Number = 0;
      
      public var progVariableB:Number = 1;
      
      public var description:String;
      
      public var iconUrl:String;
      
      public var assets:Object;
      
      public function CommunityGoalsTask(taskData:XML)
      {
         var asset:XML = null;
         super();
         this.m_manager = CommunityGoalsManager.getInstance();
         if(Boolean(this.m_manager) && Boolean(taskData))
         {
            this.name = taskData.@name;
            this.world = taskData.@world;
            this.questTask = taskData.task;
            this.season = taskData.@season;
            if(this.m_manager.isTestingMode())
            {
               this.startDate = this.getFieldFromRuntime("start_date") as String;
               this.endDate = this.getFieldFromRuntime("end_date") as String;
            }
            if(!this.startDate || this.startDate == "null")
            {
               this.startDate = taskData.@start_date;
            }
            if(!this.endDate || this.endDate == "null")
            {
               this.endDate = taskData.@end_date;
            }
            this.playerGoal = this.getPlayerGoalFromRuntime();
            if(!this.playerGoal)
            {
               this.playerGoal = Number(taskData.@player_goal);
            }
            this.communityGoal = this.getCommunityGoalFromRuntime();
            if(!this.communityGoal)
            {
               this.communityGoal = Number(taskData.@community_goal);
            }
            this.rewards = this.getRewardsFromRuntime();
            if(!this.rewards)
            {
               this.rewards = taskData.rewards.reward as XMLList;
            }
            this.ignoreProgLimit = this.getIgnoreProgLimitFromRuntime();
            if(!this.ignoreProgLimit)
            {
               this.ignoreProgLimit = Boolean(taskData.@ignore_progression_limit);
            }
            this.progVariableA = this.getProgVariableAFromRuntime();
            if(!this.progVariableA)
            {
               if(taskData.@progress_variable_A)
               {
                  this.progVariableA = Number(taskData.@progress_variable_A);
               }
            }
            this.progVariableB = this.getProgVariableBFromRuntime();
            if(!this.progVariableB)
            {
               if(taskData.@progress_variable_B)
               {
                  this.progVariableB = Number(taskData.@progress_variable_B);
               }
            }
            this.description = this.m_manager.getDescriptionForTask(this.name);
            this.iconUrl = taskData.icon[0].toString();
            this.assets = new Object();
            for each(asset in taskData.assets.asset)
            {
               this.assets[asset.@name] = asset.@path;
            }
         }
      }
      
      private function getFieldFromRuntime(fieldName:String) : Object
      {
         var fieldData:Object = null;
         var result:Object = this.m_manager.getRuntimeTaskData(this.name);
         if(Boolean(result) && Boolean(result[fieldName]))
         {
            fieldData = result[fieldName];
         }
         return fieldData;
      }
      
      private function getPlayerGoalFromRuntime() : Number
      {
         return Number(this.getFieldFromRuntime("player_goal"));
      }
      
      private function getCommunityGoalFromRuntime() : Number
      {
         return Number(this.getFieldFromRuntime("community_goal"));
      }
      
      private function getRewardsFromRuntime() : XMLList
      {
         return null;
      }
      
      private function getIgnoreProgLimitFromRuntime() : Boolean
      {
         return Boolean(this.getFieldFromRuntime("ignore_progression_limit"));
      }
      
      private function getProgVariableAFromRuntime() : Number
      {
         return Number(this.getFieldFromRuntime("progress_variable_A"));
      }
      
      private function getProgVariableBFromRuntime() : Number
      {
         return Number(this.getFieldFromRuntime("progress_variable_B"));
      }
      
      public function isActive() : Boolean
      {
         var result:Boolean = false;
         if(Boolean(this.startDate) && Boolean(this.endDate))
         {
            if(FarmGameUtil.checkDateGate(this.startDate,this.endDate))
            {
               result = true;
            }
         }
         return result;
      }
      
      public function getAssetPathFor(key:String) : String
      {
         var assetPath:String = null;
         if(this.assets.hasOwnProperty(key))
         {
            assetPath = this.assets[key];
         }
         return assetPath;
      }
   }
}

