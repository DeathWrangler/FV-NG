package Classes.Leaderboard
{
   import Classes.Quest.FarmTask;
   import Classes.util.ZLocUtils;
   
   public class LeaderboardTask extends FarmTask
   {
      
      protected var m_leaderboard:Leaderboard;
      
      protected var m_points:uint = 1;
      
      public function LeaderboardTask(leaderboard:Leaderboard, taskData:Object)
      {
         super(taskData);
         this.m_leaderboard = leaderboard;
         this.m_points = taskData.hasOwnProperty("points") && uint(taskData.points) > 0 ? uint(taskData.points) : 1;
      }
      
      override protected function getSpecificTitleResource() : String
      {
         return this.m_leaderboard.name + "_" + action + "_" + type + "_Description";
      }
      
      override public function get titleText() : String
      {
         var result:String = "";
         var uniqueResource:String = this.getSpecificTitleResource();
         if(ZLocUtils.hasString("Leaderboard",uniqueResource))
         {
            result = ZLocUtils.t("Leaderboard",uniqueResource);
         }
         else
         {
            result = super.titleText;
            result = result.replace(" 0","");
         }
         return result;
      }
      
      public function get leaderboard() : Leaderboard
      {
         return this.m_leaderboard;
      }
      
      public function get points() : int
      {
         return this.m_points;
      }
   }
}

