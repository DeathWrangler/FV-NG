package Managers.Clubs.DataObjects
{
   public class FarmClubDataObject extends FarmClubBaseObject implements IFarmClubObject
   {
      
      private var m_farmClub:FarmClub;
      
      private var m_myRankData:Object;
      
      private var m_clubRankData:Object;
      
      private var m_leaderInfo:Object;
      
      public function FarmClubDataObject(type:String, ttl:int)
      {
         super(type,ttl);
         this.m_farmClub = new FarmClub();
      }
      
      override protected function parseData(result:Object) : void
      {
         if(result.hasOwnProperty("clubData") && Boolean(result.clubData))
         {
            this.m_farmClub.populate(result.clubData);
            m_data = result;
         }
         if(result.hasOwnProperty("myRank") && Boolean(result.myRank))
         {
            this.m_myRankData = result.myRank;
         }
         else
         {
            this.m_myRankData = null;
         }
         if(result.hasOwnProperty("clubRank") && Boolean(result.clubRank))
         {
            this.m_clubRankData = result.clubRank;
         }
         else
         {
            this.m_clubRankData = null;
         }
         if(result.hasOwnProperty("leaderInfo") && Boolean(result.leaderInfo))
         {
            this.m_leaderInfo = result.leaderInfo;
         }
         else
         {
            this.m_leaderInfo = null;
         }
      }
      
      public function get clubRank() : Object
      {
         return this.m_clubRankData;
      }
      
      public function get myRank() : Object
      {
         return this.m_myRankData;
      }
      
      public function get farmClub() : FarmClub
      {
         return this.m_farmClub;
      }
      
      public function get leaderInfo() : Object
      {
         return this.m_leaderInfo;
      }
      
      public function updateScore(incrementalValue:int) : void
      {
         if(Boolean(this.m_myRankData) && Boolean(this.m_myRankData["value"]))
         {
            this.m_myRankData["value"] = parseInt(this.m_myRankData["value"]) + incrementalValue;
         }
      }
   }
}

