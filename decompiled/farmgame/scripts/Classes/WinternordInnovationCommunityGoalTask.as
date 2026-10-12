package Classes
{
   import Classes.util.FarmGameUtil;
   import Managers.WinternordInnovationManager;
   
   public class WinternordInnovationCommunityGoalTask
   {
      
      private var m_manager:WinternordInnovationManager;
      
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
      
      public function WinternordInnovationCommunityGoalTask(taskData:XML)
      {
         var asset:XML = null;
         super();
         this.m_manager = WinternordInnovationManager.getInstance();
         if(Boolean(this.m_manager) && Boolean(taskData))
         {
            this.name = taskData.@name;
            this.world = taskData.@world;
            if(!this.startDate || this.startDate == "null")
            {
               this.startDate = taskData.@start_date;
            }
            if(!this.endDate || this.endDate == "null")
            {
               this.endDate = taskData.@end_date;
            }
            if(!this.playerGoal)
            {
               this.playerGoal = Number(taskData.@player_goal);
            }
            if(!this.communityGoal)
            {
               this.communityGoal = Number(taskData.@community_goal);
            }
            if(!this.rewards)
            {
               this.rewards = taskData.rewards.reward as XMLList;
            }
            if(!this.ignoreProgLimit)
            {
               this.ignoreProgLimit = Boolean(taskData.@ignore_progression_limit);
            }
            if(!this.progVariableA)
            {
               if(taskData.@progress_variable_A)
               {
                  this.progVariableA = Number(taskData.@progress_variable_A);
               }
            }
            if(!this.progVariableB)
            {
               if(taskData.@progress_variable_B)
               {
                  this.progVariableB = Number(taskData.@progress_variable_B);
               }
            }
            this.assets = new Object();
            for each(asset in taskData.assets.asset)
            {
               this.assets[asset.@name] = asset.@path;
            }
         }
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
         return this.getFieldFromRuntime("rewards") as XMLList;
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
   }
}

