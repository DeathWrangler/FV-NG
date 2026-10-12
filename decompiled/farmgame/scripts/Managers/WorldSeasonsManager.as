package Managers
{
   import Classes.Constants.PrerequisiteConstants;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.ZItem.ExpansionAccess;
   import Classes.ZItem.ExpansionData;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Widgets.Windows.SeasonRewardWindow;
   
   public class WorldSeasonsManager
   {
      
      private static var m_instance:WorldSeasonsManager;
      
      public static const SEASON_ONE:int = 1;
      
      public static const SEASON_TWO:int = 2;
      
      public static const SEASON_THREE:int = 3;
      
      public static const SEASON_FOUR:int = 4;
      
      private static var m_seasonLoadingDialog:GenericPopup = null;
      
      private static var m_eligibleWorlds:Object = {
         "avalon":2,
         "japan":4,
         "xmas":2,
         "turtleisland":2,
         "dreamworld":2
      };
      
      private static var m_eligibleTerrains:Object = {
         "avalon":[1,6],
         "japan":[1,2,7],
         "xmas":[1,2,8],
         "turtleisland":[1,2,9],
         "dreamworld":[1,2,10]
      };
      
      private var m_seasonsStartDate:Object = new Object();
      
      private var m_seasonLoading:GenericPopup = null;
      
      private var m_nextSeasonUnlock:Boolean;
      
      public function WorldSeasonsManager()
      {
         super();
      }
      
      public static function getInstance() : WorldSeasonsManager
      {
         if(m_instance == null)
         {
            m_instance = new WorldSeasonsManager();
         }
         return m_instance;
      }
      
      public static function hideNextSeasonLoadingScreen() : void
      {
         if(m_seasonLoadingDialog != null)
         {
            m_seasonLoadingDialog.close();
            m_seasonLoadingDialog = null;
            TransactionManager.sendAllTransactions(true);
         }
      }
      
      public function get nextSeasonUnlock() : Boolean
      {
         return this.m_nextSeasonUnlock;
      }
      
      public function set nextSeasonUnlock(value:Boolean) : void
      {
         this.m_nextSeasonUnlock = value;
      }
      
      public function getTerrainIndex(worldType:String, terrainCode:int) : int
      {
         var eligibleCode:int = 0;
         var result:int = 0;
         var count:int = 0;
         if(Boolean(worldType) && worldType != "")
         {
            if(WorldSeasonsManager.m_eligibleTerrains[worldType])
            {
               for each(eligibleCode in WorldSeasonsManager.m_eligibleTerrains[worldType])
               {
                  if(terrainCode == eligibleCode)
                  {
                     result = count;
                     break;
                  }
                  count++;
               }
            }
         }
         return result;
      }
      
      public function getNumSeasonsForWorld(worldType:String) : int
      {
         var result:int = 0;
         if(Boolean(worldType) && worldType != "")
         {
            if(WorldSeasonsManager.m_eligibleWorlds[worldType])
            {
               result = int(WorldSeasonsManager.m_eligibleWorlds[worldType]);
            }
         }
         return result;
      }
      
      public function hasSeasons(worldType:String) : Boolean
      {
         var result:Boolean = false;
         var expansionData:ExpansionData = Global.farmGameSettingsManager.getExpansionData(worldType);
         if(Boolean(expansionData) && Boolean(expansionData.seasons))
         {
            result = true;
         }
         return result;
      }
      
      public function isUserInSeasonOne(worldType:String) : Boolean
      {
         var result:Boolean = false;
         if(Boolean(worldType) && worldType != "")
         {
            if(this.getNumSeasonsForWorld(worldType) > 1 && this.getCurrentSeason(worldType) == SEASON_ONE)
            {
               result = true;
            }
         }
         return result;
      }
      
      public function getEligibleTerrains(worldType:String) : Array
      {
         var result:Array = new Array();
         if(Boolean(worldType) && worldType != "")
         {
            if(WorldSeasonsManager.m_eligibleTerrains[worldType])
            {
               result = WorldSeasonsManager.m_eligibleTerrains[worldType];
            }
         }
         return result;
      }
      
      public function getCurrentSeason(worldType:String) : int
      {
         var result:int = 0;
         if(FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.WORLD_SEASONS,worldType))
         {
            result = int(FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.WORLD_SEASONS,worldType));
         }
         return result;
      }
      
      private function setSeasonsStartDate(worldType:String) : void
      {
         var expansionData:ExpansionData = null;
         var seasons:Object = null;
         var season:Object = null;
         var prereq:Object = null;
         if(!this.m_seasonsStartDate[worldType])
         {
            if(WorldSeasonsManager.getInstance().hasSeasons(worldType))
            {
               expansionData = Global.farmGameSettingsManager.getExpansionData(worldType);
               seasons = expansionData.seasons;
               this.m_seasonsStartDate[worldType] = {};
               for each(season in seasons)
               {
                  this.m_seasonsStartDate[worldType][season[ExpansionData.KEY_SEASON_ID]] = {};
                  prereq = Global.farmGameSettingsManager.getPrereqByName(season[ExpansionData.KEY_SEASON_EA]);
                  this.m_seasonsStartDate[worldType][season[ExpansionData.KEY_SEASON_ID]][ExpansionData.KEY_SEASON_EA] = this.getStartTimeFromPrereq(prereq);
                  prereq = Global.farmGameSettingsManager.getPrereqByName(season[ExpansionData.KEY_SEASON_GA]);
                  this.m_seasonsStartDate[worldType][season[ExpansionData.KEY_SEASON_ID]][ExpansionData.KEY_SEASON_GA] = this.getStartTimeFromPrereq(prereq);
               }
            }
         }
      }
      
      public function getSeasonUnlockETA(worldType:String, seasonID:int, accessType:String) : Object
      {
         var timeLeftArr:Array = null;
         var result:Object = {};
         this.setSeasonsStartDate(worldType);
         var startDate:String = this.m_seasonsStartDate[worldType][seasonID][accessType];
         var startTimeMS:Number = FarmGameUtil.synchronizedDateToNumber(startDate);
         var timeToUnlockMS:Number = (startTimeMS - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         if(timeToUnlockMS > 0)
         {
            timeLeftArr = FarmGameUtil.parseTimeLeft(timeToUnlockMS);
            result["days"] = timeLeftArr[0];
            result["hours"] = FarmGameUtil.zeroPad(timeLeftArr[1],2);
            result["minutes"] = FarmGameUtil.zeroPad(timeLeftArr[2],2);
            result["seconds"] = FarmGameUtil.zeroPad(timeLeftArr[3],2);
         }
         return result;
      }
      
      private function getStartTimeFromPrereq(prereq:Object) : String
      {
         var child:Object = null;
         var result:String = null;
         for each(child in prereq.children_from_xml)
         {
            if(child.type == "start_time")
            {
               result = child.value;
               break;
            }
         }
         return result;
      }
      
      public function getAccessType(worldType:String) : String
      {
         var result:String = null;
         if(FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.SEASONS_ACCESS_TYPE,worldType))
         {
            result = String(FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.SEASONS_ACCESS_TYPE,worldType));
         }
         if(result != ExpansionData.KEY_SEASON_EA)
         {
            result = ExpansionData.KEY_SEASON_GA;
         }
         return result;
      }
      
      public function isEAUser(worldType:String) : Boolean
      {
         var result:Boolean = false;
         if(this.getAccessType(worldType) != null)
         {
            result = this.getAccessType(worldType) == ExpansionData.KEY_SEASON_EA ? true : false;
         }
         return result;
      }
      
      public function isEarlyAccessExpansionAvailable(worldId:String) : Boolean
      {
         var result:Boolean = false;
         var access:ExpansionAccess = this.getEarlyExpansionAccessData(worldId);
         if(access)
         {
            if(access.checkPrereqs())
            {
               result = true;
            }
         }
         return result;
      }
      
      public function isGeneralAccessExpansionAvailable(worldId:String) : Boolean
      {
         var result:Boolean = false;
         var access:ExpansionAccess = this.getGeneralExpansionAccessData(worldId);
         if(access)
         {
            if(access.checkPrereqs())
            {
               result = true;
            }
         }
         return result;
      }
      
      public function getEarlyExpansionAccessData(worldId:String) : ExpansionAccess
      {
         var access:ExpansionAccess = null;
         var expansionData:ExpansionData = Global.farmGameSettingsManager.getExpansionData(worldId);
         if(expansionData)
         {
            access = expansionData.getAccessOfType(ExpansionAccess.TYPE_EARLY);
         }
         return access;
      }
      
      public function getGeneralExpansionAccessData(worldId:String) : ExpansionAccess
      {
         var access:ExpansionAccess = null;
         var expansionData:ExpansionData = Global.farmGameSettingsManager.getExpansionData(worldId);
         if(expansionData)
         {
            access = expansionData.getAccessOfType(ExpansionAccess.TYPE_GENERAL);
         }
         return access;
      }
      
      private function arePrerequisitesMet(worldType:String, season:int) : Boolean
      {
         return true;
      }
      
      public function setSeasonForUser(worldType:String, season:int) : Boolean
      {
         var result:Boolean = false;
         if(this.arePrerequisitesMet(worldType,season))
         {
            FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.WORLD_SEASONS,worldType,season);
            result = true;
         }
         return result;
      }
      
      public function isSeasonPrereqMet(worldType:String, season:int, accessType:String) : Boolean
      {
         var prereq:String = null;
         var prereqObj:Object = null;
         var result:Boolean = false;
         var expansionData:ExpansionData = Global.farmGameSettingsManager.getExpansionData(worldType);
         if(Boolean(this.hasSeasons(worldType) && season > 1 && expansionData) && Boolean(expansionData.seasons) && expansionData.seasons.hasOwnProperty(String(season)))
         {
            prereq = expansionData.seasons[season][accessType];
            prereqObj = this.getSeasonPrereqFormat(prereq);
            result = PrerequisiteUtility.isPrerequisiteMet(prereqObj);
         }
         return result;
      }
      
      public function canUnlockSeason(worldType:String, accessType:String, seasonNo:int) : Boolean
      {
         var expansionData:ExpansionData = null;
         var seasonData:Object = null;
         var data:Object = null;
         var aceessPrereq:String = null;
         var prereqObj:Object = null;
         var result:Boolean = false;
         if(Boolean(accessType) && this.hasSeasons(worldType))
         {
            expansionData = Global.farmGameSettingsManager.getExpansionData(worldType);
            if(expansionData.seasons)
            {
               seasonData = expansionData.seasons;
               if(seasonData.hasOwnProperty(String(seasonNo)))
               {
                  data = seasonData[String(seasonNo)];
                  if(Boolean(data) && data.hasOwnProperty(accessType))
                  {
                     aceessPrereq = data[accessType];
                     if(Boolean(aceessPrereq) && aceessPrereq != "")
                     {
                        prereqObj = this.getSeasonPrereqFormat(aceessPrereq);
                        result = PrerequisiteUtility.isPrerequisiteMet(prereqObj);
                     }
                  }
               }
            }
         }
         return result;
      }
      
      public function getAvailableSeason(worldType:String, accessType:String) : int
      {
         var seasons:Object = null;
         var season:String = null;
         var result:int = 0;
         var expansionData:ExpansionData = Global.farmGameSettingsManager.getExpansionData(worldType);
         if(expansionData.seasons)
         {
            seasons = expansionData.seasons;
            for(season in seasons)
            {
               if(Boolean(seasons[int(season)].hasOwnProperty(accessType)) && this.isSeasonPrereqMet(worldType,int(season),accessType))
               {
                  result = int(season);
               }
            }
         }
         return result;
      }
      
      public function getSeasonPrereqFormat(prereq:String) : Object
      {
         var result:Object = {};
         result[PrerequisiteConstants.KEY_TYPE] = PrerequisiteConstants.PREREQUISITE_PREREQ_REFERENCE;
         result[PrerequisiteConstants.KEY_VALUE] = prereq;
         return result;
      }
      
      public function canUserUnlockNextSeason(worldType:String) : Boolean
      {
         var nextPlayerSeason:int = this.getNextPlayerSeason(worldType);
         var accessType:String = this.isEAUser(worldType) ? ExpansionData.KEY_SEASON_EA : ExpansionData.KEY_SEASON_GA;
         return this.canUnlockSeason(worldType,accessType,nextPlayerSeason);
      }
      
      public function getNextPlayerSeason(worldType:String) : int
      {
         var playerSeason:int = this.getCurrentSeason(worldType);
         return this.getNextSeasonId(playerSeason);
      }
      
      public function getNextSeasonId(season:int) : int
      {
         return season + 1;
      }
      
      public function showNextSeasonLoadingScreen(worldType:String, nextSeasonID:int) : void
      {
         TransactionManager.sendAllTransactions(true);
         this.showGrantMOTDForSeason(worldType,nextSeasonID,this.loadNextSeason);
      }
      
      private function getSeasonMOTDAssetPath(worldType:String, seasonID:Number, accessType:String) : String
      {
         return Global.farmGameSettingsManager.getDialogUrlBySeason(seasonID,worldType,accessType);
      }
      
      public function showSeasonLoading(worldType:String) : void
      {
         UI.displayPopup(this.m_seasonLoading = new GenericPopup(ZLocUtils.t("Dialogs","next_region_loading_generic"),GenericPopup.TYPE_MODAL),false);
         UI.stopPopups(true);
      }
      
      public function hideSeasonLoading() : void
      {
         if(this.m_seasonLoading)
         {
            this.m_seasonLoading.close();
            this.m_seasonLoading = null;
         }
         UI.stopPopups(false);
      }
      
      private function showSeasonRewardWindowByAccessType(worldType:String, seasonID:Number, accessType:String, clickCallback:Function = null, FTUEPath:String = null) : void
      {
         var assetPath:String = this.getSeasonMOTDAssetPath(worldType,seasonID,accessType);
         var seasonMOTDWindow:SeasonRewardWindow = new SeasonRewardWindow(assetPath,clickCallback,worldType,FTUEPath);
         UI.displayPopup(seasonMOTDWindow,true);
      }
      
      public function showGrantMOTDForSeason(worldType:String, seasonID:Number, clickCallback:Function = null) : void
      {
         var accessType:String = this.getAccessType(worldType);
         var ftuePath:String = Global.farmGameSettingsManager.getFTUEPathByAccessType(worldType,accessType);
         return this.showSeasonRewardWindowByAccessType(worldType,seasonID,accessType,clickCallback,ftuePath);
      }
      
      public function showUnlockMOTDForSeason(worldType:String, seasonID:Number, clickCallback:Function = null) : void
      {
         return this.showSeasonRewardWindowByAccessType(worldType,seasonID,"unlockDialog",clickCallback);
      }
      
      private function loadNextSeason(worldType:String) : void
      {
         Global.worldManager.loadNextSeason(worldType);
      }
      
      public function isEAWeek(worldType:String) : Boolean
      {
         var result:Boolean = false;
         if(this.getEarlyExpansionAccessData(worldType).daysLeft >= 0)
         {
            result = true;
         }
         return result;
      }
      
      public function isGAFirstWeek(worldType:String) : Boolean
      {
         var result:Boolean = false;
         var count:int = this.getGeneralExpansionAccessData(worldType).getDaysLeft();
         if(count >= 0 && count < 7)
         {
            result = true;
         }
         return result;
      }
   }
}

