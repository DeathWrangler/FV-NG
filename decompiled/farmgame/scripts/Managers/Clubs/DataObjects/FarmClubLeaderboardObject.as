package Managers.Clubs.DataObjects
{
   public class FarmClubLeaderboardObject extends FarmClubBaseObject implements IFarmClubObject
   {
      
      public function FarmClubLeaderboardObject(type:String, ttl:int)
      {
         super(type,ttl);
      }
      
      override protected function parseData(result:Object) : void
      {
         if(result.hasOwnProperty("leaderboards") && Boolean(result.leaderboards))
         {
            m_data = new Object();
            m_data.leaderboard = result.leaderboards as Array;
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

