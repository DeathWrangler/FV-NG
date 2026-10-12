package Classes.Leaderboard
{
   import Classes.util.FarmGameUtil;
   
   public class LeaderboardConfigSettings
   {
      
      public static const SINGLE_AND_MULTI_TASK:String = "singleAndMulti";
      
      public static const SINGLE_TASK:String = "single";
      
      public static const MULTI_TASK:String = "multi";
      
      private var m_xml:XML;
      
      private var m_leaderboards:Object;
      
      public function LeaderboardConfigSettings(xml:XML)
      {
         var leaderboardXML:XML = null;
         var leaderboard:Leaderboard = null;
         super();
         this.m_leaderboards = new Object();
         for each(leaderboardXML in xml.leaderboards.leaderboard)
         {
            leaderboard = new Leaderboard(leaderboardXML);
            this.m_leaderboards[leaderboard.name] = leaderboard;
         }
      }
      
      public function getLeaderboards() : Object
      {
         return this.m_leaderboards;
      }
      
      public function getLeaderboard(leaderboardName:String) : Leaderboard
      {
         return this.m_leaderboards[leaderboardName] as Leaderboard;
      }
      
      public function getActiveLeaderboards(type:String = "singleAndMulti") : Array
      {
         var leaderboard:Leaderboard = null;
         var result:Array = new Array();
         for each(leaderboard in this.m_leaderboards)
         {
            if(leaderboard.isActive && !leaderboard.photoContest)
            {
               if(type == SINGLE_AND_MULTI_TASK || type == SINGLE_TASK && !leaderboard.isMultitask || type == MULTI_TASK && leaderboard.isMultitask)
               {
                  result.push(leaderboard);
               }
            }
         }
         result.sortOn(["expirationTime","startTime","name"],[Array.DESCENDING,Array.NUMERIC]);
         return result;
      }
      
      public function getEverlastingLeaderboards() : Array
      {
         var leaderboard:Leaderboard = null;
         var result:Array = new Array();
         for each(leaderboard in this.m_leaderboards)
         {
            if(leaderboard.isEverlasting)
            {
               result.push(leaderboard);
            }
         }
         result.sortOn("name");
         return result;
      }
      
      public function getActivePhotoContest(checkPhotoContestPrereqs:Boolean = true) : Leaderboard
      {
         var leaderboard:Leaderboard = null;
         var result:Leaderboard = null;
         for each(leaderboard in this.m_leaderboards)
         {
            if(leaderboard.isActive && leaderboard.photoContest && (!checkPhotoContestPrereqs || leaderboard.isPhotoContestPrereqMet))
            {
               result = leaderboard;
            }
         }
         return result;
      }
      
      public function getActiveLeaderboardTasks(type:String = "singleAndMulti") : Array
      {
         var leaderboard:Leaderboard = null;
         var result:Array = new Array();
         var activeLeaderboards:Array = this.getActiveLeaderboards(type);
         for each(leaderboard in activeLeaderboards)
         {
            result = result.concat(leaderboard.tasks);
         }
         return result;
      }
      
      public function getHistoricalLeaderboards(type:String = "singleAndMulti") : Array
      {
         var leaderboard:Leaderboard = null;
         var isExpired:Boolean = false;
         var isExpiredAndHasScore:Boolean = false;
         var userState:LeaderboardState = null;
         var result:Array = new Array();
         for each(leaderboard in this.m_leaderboards)
         {
            if(!leaderboard.photoContest)
            {
               if(type == SINGLE_AND_MULTI_TASK || type == SINGLE_TASK && !leaderboard.isMultitask || type == MULTI_TASK && leaderboard.isMultitask)
               {
                  isExpired = leaderboard.isExpired;
                  isExpiredAndHasScore = isExpired;
                  if(isExpired)
                  {
                     if(leaderboard.expirationTime > 0 && GlobalEngine.serverTime - leaderboard.expirationTime > 30 * 24 * 60 * 60 * 1000)
                     {
                        isExpiredAndHasScore = false;
                     }
                     else
                     {
                        userState = Global.player.getLeaderboardState(leaderboard.name);
                        if(!userState || userState.score <= 0)
                        {
                           isExpiredAndHasScore = false;
                        }
                     }
                  }
                  if(leaderboard.isActive || isExpiredAndHasScore)
                  {
                     result.push(leaderboard);
                  }
               }
            }
         }
         result.sortOn(["expirationTime","startTime"],[Array.DESCENDING,Array.NUMERIC]);
         return result;
      }
      
      public function getLeaderboardDataByDate(startTime:Number, endTime:Number) : Array
      {
         var leaderboard:Leaderboard = null;
         var isPhoto:Boolean = false;
         var leaderBoardStartTime:Number = NaN;
         var leaderBoardEndTime:Number = NaN;
         var result:Array = new Array();
         for each(leaderboard in this.m_leaderboards)
         {
            isPhoto = leaderboard.photoContest;
            leaderBoardStartTime = leaderboard.startTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            leaderBoardEndTime = leaderboard.expirationTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            if(!isPhoto && !leaderboard.isEverlasting && !leaderboard.isActive && (startTime <= leaderBoardStartTime && leaderBoardStartTime <= endTime || startTime <= leaderBoardEndTime && leaderBoardEndTime <= endTime))
            {
               result.push(leaderboard);
            }
         }
         result.sortOn(["expirationTime","startTime"],[Array.DESCENDING,Array.NUMERIC]);
         return result;
      }
   }
}

