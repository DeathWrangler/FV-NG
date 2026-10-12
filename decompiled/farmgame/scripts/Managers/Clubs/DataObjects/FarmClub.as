package Managers.Clubs.DataObjects
{
   public class FarmClub
   {
      
      public static const CLUB_MEMBERSHIP_LEADER:String = "leader";
      
      public static const CLUB_MEMBERSHIP_OFFICER:String = "officer";
      
      public static const CLUB_MEMBERSHIP_CHAMPION:String = "champion";
      
      public static const CLUB_MEMBERSHIP_MEMBER:String = "member";
      
      public var clubId:String;
      
      public var currentTier:int = 1;
      
      public var clubName:String = "DefaultName";
      
      public var clubLogoId:int = 1;
      
      public var isPrivate:Boolean = false;
      
      public var members:Object;
      
      public var lastModifiedTS:Number = 0;
      
      public var message:String = "";
      
      public var numMembers:int = 0;
      
      public function FarmClub()
      {
         super();
      }
      
      public function populate(data:Object) : void
      {
         if(data["clubId"])
         {
            this.clubId = data["clubId"];
         }
         if(data["currentTier"])
         {
            this.currentTier = data.currentTier;
         }
         if(data["clubName"])
         {
            this.clubName = data.clubName;
         }
         if(data["clubLogoId"])
         {
            this.clubLogoId = data.clubLogoId;
         }
         if(data["isPrivate"])
         {
            this.isPrivate = data.isPrivate;
         }
         if(data["members"])
         {
            this.members = data.members;
         }
         if(data["lastModifiedTS"])
         {
            this.lastModifiedTS = data.lastModifiedTS;
         }
         if(data["message"])
         {
            this.message = data.message;
         }
         if(data["numMembers"])
         {
            this.numMembers = data.numMembers;
         }
      }
      
      public function getLeader() : String
      {
         var result:String = null;
         if(Boolean(this.members) && Boolean(this.members[CLUB_MEMBERSHIP_LEADER]) && Boolean(this.members[CLUB_MEMBERSHIP_LEADER][0]))
         {
            result = this.members[CLUB_MEMBERSHIP_LEADER][0];
         }
         return result;
      }
      
      public function getRankOfMember(uid:String) : String
      {
         var result:String = null;
         var uidInList:String = null;
         if(this.members)
         {
            result = CLUB_MEMBERSHIP_MEMBER;
            if(uid == this.getLeader())
            {
               result = CLUB_MEMBERSHIP_LEADER;
            }
            else
            {
               for each(uidInList in this.members[CLUB_MEMBERSHIP_OFFICER])
               {
                  if(uidInList == uid)
                  {
                     result = CLUB_MEMBERSHIP_OFFICER;
                     break;
                  }
               }
               if(result == CLUB_MEMBERSHIP_MEMBER)
               {
                  for each(uidInList in this.members[CLUB_MEMBERSHIP_CHAMPION])
                  {
                     if(uidInList == uid)
                     {
                        result = CLUB_MEMBERSHIP_CHAMPION;
                        break;
                     }
                  }
               }
            }
         }
         return result;
      }
      
      public function promoteMemberToOfficer(uid:String) : void
      {
         var len:int = 0;
         var idx:int = 0;
         if(this.members[CLUB_MEMBERSHIP_OFFICER])
         {
            this.members[CLUB_MEMBERSHIP_OFFICER].push(uid);
         }
         if(this.members[CLUB_MEMBERSHIP_CHAMPION])
         {
            len = int(this.members[CLUB_MEMBERSHIP_CHAMPION]);
            for(idx = 0; idx < len; idx++)
            {
               if(this.members[CLUB_MEMBERSHIP_CHAMPION][idx] == uid)
               {
                  this.members[CLUB_MEMBERSHIP_CHAMPION][idx] = null;
                  break;
               }
            }
         }
      }
      
      public function demoteOfficerToMember(uid:String) : void
      {
         var len:int = 0;
         var idx:int = 0;
         if(this.members[CLUB_MEMBERSHIP_OFFICER])
         {
            len = int(this.members[CLUB_MEMBERSHIP_OFFICER].length);
            for(idx = 0; idx < len; idx++)
            {
               if(this.members[CLUB_MEMBERSHIP_OFFICER][idx] == uid)
               {
                  this.members[CLUB_MEMBERSHIP_OFFICER][idx] = null;
                  break;
               }
            }
         }
      }
   }
}

