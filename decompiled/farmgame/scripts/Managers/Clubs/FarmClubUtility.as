package Managers.Clubs
{
   import Classes.Constants.FarmClubConstants;
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmQuestUtility;
   import Classes.Quest.FarmTask;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Events.TransactionEvent;
   import Engine.Managers.TransactionManager;
   import Events.DynamicObjectEvent;
   import Events.GenericPopupEvent;
   import Managers.Clubs.DataObjects.*;
   import Managers.FeatureOptionsManager;
   import Transactions.TFarmTransaction;
   import Transactions.TGenericTransaction;
   import Widgets.Frames.Clubs.MyClubFrame;
   import Widgets.Windows.Clubs.FarmClubWindow2;
   import Widgets.Windows.MFSClubInvite;
   import ZQuest.Classes.Quest;
   import ZQuest.Init.QuestSettingsInit;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   
   public class FarmClubUtility
   {
      
      private static var m_rankData:Dictionary;
      
      private static var m_clubLogoHash:Object = null;
      
      private static var m_currentTierNode:XML = null;
      
      private static const TIERS_FEATURE_NAME:String = "farmClub_tiers";
      
      private static const REST_DAY_NUM:int = 0;
      
      private static const CLUB_PREREQ_NAME:String = "clubs_eligible";
      
      public static var dispatcher:EventDispatcher = new EventDispatcher();
      
      public function FarmClubUtility()
      {
         super();
      }
      
      public static function inExperiment() : Boolean
      {
         return PrerequisiteUtility.checkPrereqByName(CLUB_PREREQ_NAME);
      }
      
      public static function showMFS() : void
      {
         var friendSpec:Object = {
            "tabNameSuggested":["CurrentMostGifts"],
            "tabNameFarmVille":["CurrentMostHelpful"],
            "tabNameFacebook":["CurrentFriendsAlpha"]
         };
         var friendTabOrder:Array = ["tabNameSuggested","tabNameFarmVille","tabNameFacebook"];
         UI.displayPopup(new MFSClubInvite(friendSpec,friendTabOrder,"",null),false);
      }
      
      public static function showDialog() : void
      {
         UI.displayPopup(new FarmClubWindow2(),true,"FarmClubs",true);
      }
      
      public static function canJoinClub(clubId:String, confirmCallback:Function) : void
      {
         var popup:GenericPopup = null;
         var currentClubId:String = FarmClubDataManager.getInstance().clubId;
         if(currentClubId == null || currentClubId == "")
         {
            confirmCallback(true);
         }
         else
         {
            popup = new GenericPopup(ZLocUtils.t("FarmClub","JoinClub_AlreayInClub"),GenericPopup.TYPE_ACCEPTCANCEL,function(event:GenericPopupEvent):void
            {
               onConfirmJoin(event,confirmCallback);
            });
            UI.displayPopup(popup,false);
         }
      }
      
      public static function joinClub(clubId:String, callback:Function = null) : void
      {
         TransactionManager.addTransaction(new TGenericTransaction("FarmClubService","joinClub",callback,[clubId]),true);
         var farmClubDataObject:FarmClubDataObject = FarmClubDataManager.getInstance().getFarmClubDataObject(true);
         if(farmClubDataObject != null)
         {
            farmClubDataObject.setDirty();
         }
         var leaderboardDataObj:MyClubLeaderboardObject = FarmClubDataManager.getInstance().getMyClubLeaderboardObject(MyClubFrame.OUR_RANK_FRAME) as MyClubLeaderboardObject;
         if(leaderboardDataObj != null)
         {
            leaderboardDataObj.setDirty();
         }
         var browseClubDataObj:BrowseClubObject = FarmClubDataManager.getInstance().getBrowseClubObject();
         if(browseClubDataObj != null)
         {
            browseClubDataObj.setDirty();
         }
         FeatureOptionsManager.getInstance().setFeatureOption(FarmClubConstants.FARM_CLUB,FarmClubConstants.OPTION_CURRENT_CLUB_ID,clubId);
         FarmClubUtility.dispatcher.dispatchEvent(new DynamicObjectEvent(FarmClubConstants.ON_JOIN_CLUB_EVENT,true));
      }
      
      public static function onConfirmJoin(event:GenericPopupEvent, confirmCallback:Function) : void
      {
         var result:Boolean = event.button == GenericPopup.ACCEPT;
         if(result)
         {
            resign();
         }
         if(confirmCallback != null)
         {
            confirmCallback(result);
         }
      }
      
      public static function createClub(clubName:String, clubLogoId:String, isPrivate:Boolean, callback:Function = null) : void
      {
         if(canCreateClub())
         {
            TransactionManager.addTransaction(new TGenericTransaction("FarmClubService","createClub",callback,[clubName,clubLogoId,isPrivate]),true);
         }
      }
      
      public static function getClubsFarmQuest() : FarmQuest
      {
         var quest:Quest = QuestSettingsInit.getInstance().getItemByName(FarmClubConstants.CREATE_CLUB_QUEST_NAME);
         return quest as FarmQuest;
      }
      
      public static function canCreateClub() : Boolean
      {
         return Global.player.getSeenFlag(FarmClubConstants.CAN_CREATE_FARMCLUB);
      }
      
      public static function updateClubInfo(clubName:String, clubLogoId:String, isPrivate:Boolean, callback:Function = null) : Boolean
      {
         var club:FarmClubDataObject = null;
         var isInClub:Boolean = false;
         var clubId:String = FarmClubDataManager.getInstance().clubId;
         if(clubId != null && clubId != "")
         {
            isInClub = true;
            TransactionManager.addTransaction(new TGenericTransaction("FarmClubService","updateClubInfo",callback,[clubId,clubName,isPrivate,clubLogoId]),true);
            club = FarmClubDataManager.getInstance().getFarmClubDataObject(true);
            if(club != null)
            {
               club.farmClub.clubName = clubName;
               club.farmClub.clubLogoId = parseInt(clubLogoId);
               club.farmClub.isPrivate = isPrivate;
               FarmClubDataManager.getInstance().saveUserFarmClubData(club);
            }
         }
         return isInClub;
      }
      
      public static function resign(callback:Function = null) : Boolean
      {
         var farmClubDataObject:FarmClubDataObject = null;
         var leaderboardDataObj:MyClubLeaderboardObject = null;
         var browseClubDataObj:BrowseClubObject = null;
         var isInClub:Boolean = false;
         var clubId:String = FarmClubDataManager.getInstance().clubId;
         if(clubId != null && clubId != "")
         {
            isInClub = true;
            TransactionManager.addTransaction(new TGenericTransaction("FarmClubService","resignClub",callback),true);
            farmClubDataObject = FarmClubDataManager.getInstance().getFarmClubDataObject(true);
            if(farmClubDataObject != null)
            {
               farmClubDataObject.setDirty();
            }
            leaderboardDataObj = FarmClubDataManager.getInstance().getMyClubLeaderboardObject(MyClubFrame.OUR_RANK_FRAME) as MyClubLeaderboardObject;
            if(leaderboardDataObj != null)
            {
               leaderboardDataObj.setDirty();
            }
            browseClubDataObj = FarmClubDataManager.getInstance().getBrowseClubObject();
            if(browseClubDataObj != null)
            {
               browseClubDataObj.setDirty();
            }
         }
         return isInClub;
      }
      
      private static function initLogoHash() : void
      {
         var xml:XML = null;
         var logo:XML = null;
         if(m_clubLogoHash == null)
         {
            m_clubLogoHash = new Object();
            xml = Global.farmGameSettingsManager.getFeatureXML("farmClub_tiers");
            for each(logo in xml.logos.logo)
            {
               m_clubLogoHash[logo.@id.toString()] = {
                  "path":logo.@path.toString(),
                  "name":logo.@friendlyName.toString(),
                  "backgroundPath":logo.@iconPath.toString()
               };
            }
         }
      }
      
      public static function getLogoPathFromId(id:int, type:String = "path") : String
      {
         var path:String = "";
         initLogoHash();
         if(m_clubLogoHash.hasOwnProperty(id.toString()))
         {
            path = m_clubLogoHash[id.toString()][type];
         }
         return path;
      }
      
      public static function getBackgroundLogoPathFromId(id:int) : String
      {
         return getLogoPathFromId(id,"backgroundPath");
      }
      
      public static function get200LogoPathFromId(id:int) : String
      {
         return getBackgroundLogoPathFromId(id);
      }
      
      public static function getClubLogoHash() : Object
      {
         initLogoHash();
         return m_clubLogoHash;
      }
      
      public static function onTransactionAdded(event:TransactionEvent) : void
      {
         var userClubId:String = null;
         var farmClubDataObject:FarmClubDataObject = null;
         var clubTier:int = 0;
         var clubTierTask:FarmTask = null;
         var newTaskProgression:Number = NaN;
         var date:Date = new Date(GlobalEngine.serverTime);
         if(!isDeadDay() && PrerequisiteUtility.checkPrereqByName(CLUB_PREREQ_NAME))
         {
            userClubId = FarmClubDataManager.getInstance().clubId;
            farmClubDataObject = FarmClubDataManager.getInstance().getFarmClubDataObject();
            if(farmClubDataObject != null)
            {
               clubTier = farmClubDataObject.farmClub.currentTier;
               clubTierTask = FarmClubUtility.getTaskForTier(clubTier);
               if(clubTierTask)
               {
                  newTaskProgression = FarmQuestUtility.getInstance().getProgression(clubTierTask,event.transaction as TFarmTransaction,null);
                  if(newTaskProgression > 0)
                  {
                     farmClubDataObject.updateScore(newTaskProgression);
                  }
               }
            }
         }
      }
      
      public static function promoteMemberToOfficer(uid:String, callback:Function = null) : void
      {
         var clubId:String = FarmClubDataManager.getInstance().clubId;
         TransactionManager.addTransaction(new TGenericTransaction("FarmClubService","promoteMemberToOfficer",callback,[clubId,uid]),true);
      }
      
      public static function demoteOfficerToMember(uid:String, callback:Function = null) : void
      {
         var clubId:String = FarmClubDataManager.getInstance().clubId;
         TransactionManager.addTransaction(new TGenericTransaction("FarmClubService","demoteOfficerToMember",callback,[clubId,uid]),true);
      }
      
      public static function getTaskForTier(clubTier:int) : FarmTask
      {
         var task:FarmTask = null;
         var xmlNode:XML = null;
         var tier:XML = getTierXMLForTier(clubTier);
         if(tier != null)
         {
            xmlNode = tier.task[0] as XML;
            if(xmlNode != null)
            {
               task = new FarmTask(FarmGameUtil.xmlNodeToAttributes(xmlNode));
            }
         }
         return task;
      }
      
      private static function getTierXMLForTier(tierIndex:int) : XML
      {
         var tier:XML = null;
         var result:XML = null;
         var tiers:XMLList = getTiers();
         if(tiers != null)
         {
            for each(tier in tiers)
            {
               if(tier.@index == tierIndex)
               {
                  result = tier;
                  break;
               }
            }
         }
         return result;
      }
      
      private static function getCurrentCachedTier(tierIndex:int) : XML
      {
         if(m_currentTierNode == null)
         {
            m_currentTierNode = getTierXMLForTier(tierIndex);
         }
         return m_currentTierNode;
      }
      
      public static function getTiers() : XMLList
      {
         var tiers:XMLList = null;
         var config:XML = getFeatureConfig();
         if(config != null)
         {
            tiers = config.tiers.tier;
         }
         return tiers;
      }
      
      private static function getFeatureConfig() : XML
      {
         return Global.farmGameSettingsManager.getFeatureXML(TIERS_FEATURE_NAME);
      }
      
      public static function getScoreMultiplierForClubRank(rankIn:String) : int
      {
         var result:int = 1;
         var ranksData:Dictionary = getRanks();
         if(ranksData[rankIn])
         {
            result = int(ranksData[rankIn].multiplier);
         }
         return result;
      }
      
      public static function getBadgePathForClubRank(rankIn:String) : String
      {
         var path:String = "";
         var ranksData:Dictionary = getRanks();
         if(ranksData[rankIn])
         {
            path = ranksData[rankIn].badge;
         }
         return path;
      }
      
      private static function getRanks() : Dictionary
      {
         var config:XML = null;
         var ranks:XMLList = null;
         var name:String = null;
         var badge:String = null;
         var multiplier:int = 0;
         var rank:XML = null;
         var result:Object = null;
         if(m_rankData == null)
         {
            m_rankData = new Dictionary();
            config = getFeatureConfig();
            if(config != null)
            {
               ranks = config.ranks;
               for each(rank in ranks.rank)
               {
                  result = new Object();
                  name = rank.@name;
                  multiplier = parseInt(rank.@multiplier);
                  badge = rank.@badge;
                  result.name = name;
                  result.multiplier = multiplier;
                  result.badge = badge;
                  m_rankData[name] = result;
               }
            }
         }
         return m_rankData;
      }
      
      public static function getNumOfficersForTier(tierIndex:int) : int
      {
         return getNumRankForTier(tierIndex,"officers");
      }
      
      private static function getNumRankForTier(tierIndex:int, rank:String) : int
      {
         var result:int = 0;
         var tier:XML = getCurrentCachedTier(tierIndex);
         if(tier != null && Boolean(tier.attribute(rank)))
         {
            result = parseInt(tier.attribute(rank));
         }
         return result;
      }
      
      public static function getFarmItemFromTier(tier:int) : FarmItem
      {
         var type:String = null;
         var item:FarmItem = null;
         var task:FarmTask = FarmClubUtility.getTaskForTier(tier);
         if(task != null)
         {
            type = task.type;
            item = Global.farmGameSettingsManager.getFarmItemByCode(type);
         }
         return item;
      }
      
      public static function getNumTiers() : int
      {
         return getTiers().length();
      }
      
      public static function sendChatMessage(message:String, callback:Function) : Boolean
      {
         var club:FarmClubDataObject = null;
         var isInClub:Boolean = false;
         var clubId:String = FarmClubDataManager.getInstance().clubId;
         if(clubId != null && clubId != "")
         {
            isInClub = true;
            TransactionManager.addTransaction(new TGenericTransaction("FarmClubService","sendChatMessage",callback,[message]),true);
            club = FarmClubDataManager.getInstance().getFarmClubDataObject(true);
            if(club != null)
            {
               club.farmClub.message = message;
               FarmClubDataManager.getInstance().saveUserFarmClubData(club);
            }
         }
         return isInClub;
      }
      
      public static function formatRank(rank:int) : String
      {
         return rank > 999 ? ZLocUtils.t("FarmClub","Rank_Over_1000") : String(rank);
      }
      
      public static function isDeadDay() : Boolean
      {
         var result:Boolean = false;
         var serverOffset:int = FarmGameUtil.getGlobalServerUTCOffsetHours() * FarmGameUtil.NUM_MSECS_IN_HOUR;
         var date:Date = new Date(GlobalEngine.serverTime - serverOffset);
         if(date.dayUTC == FarmClubConstants.COMPETITION_DEAD_DAY)
         {
            result = true;
         }
         return result;
      }
      
      public static function getTimeTillDeadDay() : Number
      {
         var serverOffset:int = 0;
         var currentDate:Date = null;
         var dayDifference:int = 0;
         var timeElapsed:int = 0;
         var time:Number = 0;
         if(!isDeadDay())
         {
            serverOffset = FarmGameUtil.getGlobalServerUTCOffsetHours() * FarmGameUtil.NUM_MSECS_IN_HOUR;
            currentDate = new Date(GlobalEngine.serverTime - serverOffset);
            dayDifference = (currentDate.dayUTC - FarmClubConstants.COMPETITION_DEAD_DAY + FarmGameUtil.NUM_DAYS_IN_WEEK) % FarmGameUtil.NUM_DAYS_IN_WEEK;
            timeElapsed = dayDifference * FarmGameUtil.NUM_MSECS_IN_DAY + currentDate.hoursUTC * FarmGameUtil.NUM_MSECS_IN_HOUR + currentDate.minutesUTC * FarmGameUtil.NUM_MSECS_IN_MINUTE + currentDate.secondsUTC * FarmGameUtil.NUM_MSECS_IN_SECOND + currentDate.millisecondsUTC;
            time = FarmGameUtil.NUM_DAYS_IN_WEEK * FarmGameUtil.NUM_MSECS_IN_DAY - timeElapsed;
         }
         return time;
      }
      
      public static function getTimeTillCompetition() : Number
      {
         var serverOffset:int = 0;
         var currentDate:Date = null;
         var timeElapsed:int = 0;
         var time:Number = 0;
         if(isDeadDay())
         {
            serverOffset = FarmGameUtil.getGlobalServerUTCOffsetHours() * FarmGameUtil.NUM_MSECS_IN_HOUR;
            currentDate = new Date(GlobalEngine.serverTime - serverOffset);
            timeElapsed = currentDate.hoursUTC * FarmGameUtil.NUM_MSECS_IN_HOUR + currentDate.minutesUTC * FarmGameUtil.NUM_MSECS_IN_MINUTE + currentDate.secondsUTC * FarmGameUtil.NUM_MSECS_IN_SECOND + currentDate.millisecondsUTC;
            time = FarmGameUtil.NUM_MSECS_IN_DAY - timeElapsed;
         }
         return time;
      }
   }
}

