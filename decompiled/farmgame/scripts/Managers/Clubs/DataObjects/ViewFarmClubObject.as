package Managers.Clubs.DataObjects
{
   public class ViewFarmClubObject extends FarmClubBaseObject implements IFarmClubObject
   {
      
      public function ViewFarmClubObject(type:String, ttl:int)
      {
         super(type,ttl);
      }
      
      override protected function parseData(result:Object) : void
      {
         if(Boolean(result.hasOwnProperty("leaderboard") && result.leaderboards) && Boolean(result.hasOwnProperty("clubInfo")) && Boolean(result.clubInfo))
         {
            m_data = new Object();
            m_data.leaderboards = result.leaderboards as Array;
            m_data.clubInfo = result.clubInfo;
         }
      }
   }
}

