package Managers.Clubs.DataObjects
{
   public class BrowseClubObject extends FarmClubBaseObject implements IFarmClubObject
   {
      
      public function BrowseClubObject(type:String, ttl:int)
      {
         super(type,ttl);
      }
      
      override protected function parseData(result:Object) : void
      {
         if(result.hasOwnProperty("clubs") && Boolean(result.clubs))
         {
            m_data = result.clubs as Array;
         }
      }
      
      public function removeInvitedClub(clubId:String) : void
      {
         var len:int = 0;
         var found:Boolean = false;
         var idx:int = 0;
         if(m_data != null)
         {
            len = int((m_data as Array).length);
            found = false;
            for(idx = 0; idx < len; idx++)
            {
               if(m_data[idx][clubId] == clubId)
               {
                  found = true;
                  break;
               }
            }
            if(found)
            {
               m_data = (m_data as Array).splice(idx,1) as Array;
            }
         }
      }
   }
}

