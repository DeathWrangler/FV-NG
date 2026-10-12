package Classes
{
   import Classes.Avatar.FarmAvatar;
   import Classes.Constants.Experiments;
   import Classes.Constants.WorldsConstants;
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmQuestManager;
   import Engine.Classes.SocialNetworkUser;
   
   public class Friend implements IUser
   {
      
      public static const NO_QUEST:int = -1;
      
      protected var m_gold:int = 0;
      
      protected var m_xp:Number = 0;
      
      protected var m_worldScores:Object = null;
      
      protected var m_level:Number = 0;
      
      protected var m_avatarData:Object;
      
      protected var m_profilePic:String = "";
      
      protected var m_name:String = "";
      
      protected var m_uid:String = "0";
      
      protected var m_fake:Boolean;
      
      protected var m_empty:Boolean;
      
      protected var m_snUser:SocialNetworkUser;
      
      protected var m_hasNeighborData:Boolean = false;
      
      protected var m_unlockedWorlds:Array = null;
      
      protected var m_usedPhotoContest:Boolean = false;
      
      protected var m_inactiveExp:int = 0;
      
      protected var m_communityNeighbor:int = 0;
      
      protected var m_questIds:Array;
      
      protected var m_activeQuestsByChain:Object;
      
      protected var m_cardStats:Object;
      
      protected var m_hasEmailPermission:Boolean;
      
      protected var m_worldName:String;
      
      protected var m_isNeighbor:Boolean;
      
      protected var m_breedingStats:Object = new Object();
      
      private var m_featureCredits:Object = new Object();
      
      public function Friend(data:Object = null, newUser:SocialNetworkUser = null, fake:Boolean = false, empty:Boolean = false)
      {
         super();
         this.setMetaData(data);
         this.snUser = newUser;
         this.m_empty = empty;
         this.m_fake = fake;
      }
      
      public function toString() : String
      {
         var result:String = " " + this.name + "(" + this.uid.toString() + ")";
         if(this.m_isNeighbor)
         {
            result = "N" + result;
         }
         if(this.m_communityNeighbor)
         {
            result = "C" + result;
         }
         return result;
      }
      
      public function setMetaData(metaData:Object) : void
      {
         if(metaData)
         {
            this.m_hasNeighborData = true;
            this.m_isNeighbor = metaData.isNeighbor;
            this.m_gold = metaData.gold;
            this.m_xp = metaData.xp;
            this.m_worldScores = metaData.worldScores;
            this.m_level = metaData.level;
            this.m_avatarData = metaData.avatar;
            this.m_profilePic = metaData.profilePic;
            this.m_name = metaData.name;
            this.m_uid = metaData.uid;
            this.m_cardStats = metaData.stats;
            this.m_hasEmailPermission = metaData.hasEmailPermission;
            this.m_featureCredits = metaData.featureCredits;
            this.m_questIds = metaData.questIds;
            this.m_breedingStats = metaData.breedingStats;
            this.m_unlockedWorlds = metaData.hasOwnProperty("unlockedWorldTypes") ? metaData.unlockedWorldTypes : null;
            this.m_usedPhotoContest = metaData.hasOwnProperty("usedPhotoContest") ? Boolean(metaData.usedPhotoContest) : false;
            if(metaData.hasOwnProperty("worldName"))
            {
               this.m_worldName = metaData.worldName;
            }
            else
            {
               this.m_worldName = WorldsConstants.WORLD_ID_HOME;
            }
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_NEIGHBORS_BAR_INACTIVE) > 0)
            {
               this.m_inactiveExp = metaData.inactiveExp;
            }
            this.m_communityNeighbor = metaData.community;
            if(this.m_cardStats != null)
            {
               this.m_cardStats.achievements = metaData.achievementDetails;
               this.m_cardStats.masteries = metaData.mastery;
            }
         }
      }
      
      public function get snUser() : SocialNetworkUser
      {
         return this.m_snUser;
      }
      
      public function set snUser(newUser:SocialNetworkUser) : void
      {
         if(newUser)
         {
            this.m_profilePic = newUser.picture;
            this.m_name = newUser.name;
            this.m_uid = newUser.uid;
            this.m_snUser = newUser;
         }
      }
      
      public function get name() : String
      {
         if(Boolean(this.m_snUser) && (null == this.m_name || "" == this.m_name))
         {
            this.m_name = this.m_snUser.name;
         }
         return this.m_name;
      }
      
      public function get firstName() : String
      {
         var result:String = "";
         if(this.m_snUser)
         {
            result = this.m_snUser.firstName;
         }
         else
         {
            result = this.m_name;
         }
         return result;
      }
      
      public function get isNeighbor() : Boolean
      {
         return this.m_isNeighbor;
      }
      
      public function set isNeighbor(val:Boolean) : void
      {
         this.m_isNeighbor = val;
      }
      
      public function get uid() : String
      {
         return this.m_uid;
      }
      
      public function get xp() : Number
      {
         return this.m_xp;
      }
      
      public function get worldScores() : Object
      {
         return this.m_worldScores;
      }
      
      public function get currentWorldScore() : Number
      {
         var result:Number = 0;
         var worldScoreId:String = Global.worldManager.currentWorldScoreId;
         if(worldScoreId != "")
         {
            if(Boolean(this.m_worldScores) && Boolean(this.m_worldScores[worldScoreId]))
            {
               result = Number(this.m_worldScores[worldScoreId][Player.SCORE]);
            }
         }
         return result;
      }
      
      public function get currentWorldScore2() : Number
      {
         var result:Number = 0;
         var worldScoreId:String = Global.worldManager.currentWorldScore2Id;
         if(worldScoreId != "")
         {
            if(Boolean(this.m_worldScores) && Boolean(this.m_worldScores[worldScoreId]))
            {
               result = Number(this.m_worldScores[worldScoreId][Player.SCORE]);
            }
         }
         return result;
      }
      
      public function get currentWorldLevel() : Number
      {
         var result:Number = 1;
         var worldScoreId:String = Global.worldManager.currentWorldScoreId;
         if(worldScoreId != "")
         {
            if(Boolean(this.m_worldScores) && Boolean(this.m_worldScores[worldScoreId]))
            {
               result = Number(this.m_worldScores[worldScoreId][Player.LEVEL]);
            }
         }
         return result;
      }
      
      public function get currentWorldLevel2() : Number
      {
         var result:Number = 1;
         var worldScoreId:String = Global.worldManager.currentWorldScore2Id;
         if(worldScoreId != "")
         {
            if(Boolean(this.m_worldScores) && Boolean(this.m_worldScores[worldScoreId]))
            {
               result = Number(this.m_worldScores[worldScoreId][Player.LEVEL]);
            }
         }
         return result;
      }
      
      public function get level() : Number
      {
         return this.m_level;
      }
      
      public function get inInactiveExp() : int
      {
         return this.m_inactiveExp;
      }
      
      public function get isCommunityNeighbor() : int
      {
         var result:int = 0;
         if(this.m_communityNeighbor != 0)
         {
            result = 1;
         }
         return result;
      }
      
      public function set isCommunityNeighbor(val:int) : void
      {
         this.m_communityNeighbor = val;
      }
      
      public function get avatarData() : Object
      {
         var result:Object = null;
         if(this.m_avatarData)
         {
            result = this.m_avatarData;
         }
         else if(Boolean(this.snUser) && Boolean(this.snUser.gender))
         {
            result = FarmAvatar.getDefaultAvatarCustomizationData(this.snUser.gender);
         }
         else
         {
            result = FarmAvatar.getDefaultAvatarCustomizationData();
         }
         return result;
      }
      
      public function set avatarData(data:Object) : void
      {
         this.m_avatarData = data;
      }
      
      public function get avatar() : FarmAvatar
      {
         return null;
      }
      
      public function set avatar(newAvatar:FarmAvatar) : void
      {
      }
      
      public function get fake() : Boolean
      {
         return this.m_fake;
      }
      
      public function get empty() : Boolean
      {
         return this.m_empty;
      }
      
      public function get usedPhotoContest() : Boolean
      {
         return this.m_usedPhotoContest;
      }
      
      public function get picture() : String
      {
         return this.m_profilePic;
      }
      
      public function set picture(picture:String) : void
      {
         this.m_profilePic = picture;
      }
      
      public function get cardStats() : Object
      {
         return this.m_cardStats;
      }
      
      public function set cardStats(newStats:Object) : void
      {
         this.m_cardStats = newStats;
      }
      
      public function set hasEmailPermission(hasEmailPermission:Boolean) : void
      {
         this.m_hasEmailPermission = hasEmailPermission;
      }
      
      public function get hasEmailPermission() : Boolean
      {
         return this.m_hasEmailPermission;
      }
      
      public function getFeatureCreditsReceived(featureName:String, globalCount:Boolean = false) : int
      {
         var world:String = null;
         var count:uint = 0;
         for each(world in WorldsConstants.ALL_WORLDS)
         {
            if(this.m_featureCredits != null && null != this.m_featureCredits[world] && Boolean(this.m_featureCredits[world][featureName]))
            {
               count += this.m_featureCredits[world][featureName].received;
            }
         }
         return count;
      }
      
      public function setCreditsInfo(data:Object) : void
      {
         this.m_featureCredits = data;
      }
      
      public function get hasNeighborData() : Boolean
      {
         return this.m_hasNeighborData;
      }
      
      public function get questIds() : Array
      {
         return this.m_questIds;
      }
      
      public function getActiveQuestByChain(questChainName:String) : FarmQuest
      {
         if(null == this.m_activeQuestsByChain)
         {
            this.m_activeQuestsByChain = {};
         }
         if(null == this.m_activeQuestsByChain[questChainName])
         {
            this.m_activeQuestsByChain[questChainName] = FarmQuestManager.getInstance().getActiveQuestByChain(questChainName,this);
         }
         return this.m_activeQuestsByChain[questChainName];
      }
      
      public function getQuestLocationByName(questChainName:String) : int
      {
         var quest:FarmQuest = this.getActiveQuestByChain(questChainName);
         var result:int = NO_QUEST;
         if(quest)
         {
            result = quest.location;
         }
         return result;
      }
      
      public function canHelp(questChainName:String, playerQuest:FarmQuest) : int
      {
         return FarmQuestManager.getInstance().canHelpFriend(this,questChainName,playerQuest);
      }
      
      public function get worldName() : String
      {
         return this.m_worldName;
      }
      
      public function getBreedingStatsByFeatureName(featureName:String) : int
      {
         var count:uint = 0;
         if(this.m_breedingStats != null && Boolean(this.m_breedingStats[featureName]))
         {
            count = uint(this.m_breedingStats[featureName]);
         }
         return count;
      }
      
      public function get unlockedWorldTypes() : Array
      {
         return this.m_unlockedWorlds;
      }
   }
}

