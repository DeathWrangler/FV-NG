package Managers.Clubs.DataObjects
{
   public class MyClubLeaderboardObject extends FarmClubBaseObject implements IFarmClubObject
   {
      
      public function MyClubLeaderboardObject(type:String, ttl:int)
      {
         super(type,ttl);
      }
      
      override protected function parseData(result:Object) : void
      {
         if(result.hasOwnProperty("leaderboard") && Boolean(result.leaderboard))
         {
            m_data = new Object();
            m_data.leaderboard = result.leaderboard as Array;
         }
         if(result.hasOwnProperty("leaderboardTotal") && Boolean(result.leaderboardTotal))
         {
            if(m_data == null)
            {
               m_data = new Object();
            }
            m_data.leaderboardTotal = result.leaderboardTotal;
         }
      }
   }
}

