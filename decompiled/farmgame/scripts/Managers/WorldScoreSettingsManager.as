package Managers
{
   import Classes.Constants.QuestConstants;
   import Classes.Constants.XMLKeys;
   import Classes.EmbeddedArt;
   import Classes.LevelData;
   import Classes.Quest.FarmTask;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.ZItem.BuildingItem;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.UserRewardUtil;
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   
   public class WorldScoreSettingsManager
   {
      
      public static const KEY_GLOBAL:String = "global";
      
      public static const KEY_TASKS:String = "tasks";
      
      public static const KEY_LEVELS:String = "levels";
      
      public static const KEY_ICON_URL:String = "iconUrl";
      
      public static const KEY_LEVEL_UP_DIALOG_URL:String = "levelUpDialogUrl";
      
      public static const KEY_PREREQ:String = "prereq";
      
      public static const KEY_DEFAULT_LEVEL:String = "defaultLevel";
      
      public static const KEY_REWARDS:String = "rewards";
      
      public static const KEY_FRONTEND:String = "frontend";
      
      public static const KEY_FRIENDREWARD:String = "friendReward";
      
      private static const WORLDSCORE_TO_DATA_PREFIX:String = "worldScore_";
      
      private static var m_scoreUnitToStar:Object = {
         "worldScore_":EmbeddedArt.hud_nghbr_star,
         "worldScore_zen":EmbeddedArt.hud_nghbr_zp_star,
         "worldScore_spook":EmbeddedArt.hud_nghbr_sp_star,
         "worldScore_cheer":EmbeddedArt.hud_nghbr_cp_star,
         "worldScore_pixie":EmbeddedArt.hud_nghbr_fp_star,
         "worldScore_shell":EmbeddedArt.hud_nghbr_shp_star,
         "worldScore_aussie":EmbeddedArt.hud_nghbr_ap_star,
         "worldScore_cosmic":EmbeddedArt.hud_nghbr_cop_star,
         "worldScore_candyPoints":EmbeddedArt.hud_nghbr_cap_star,
         "worldScore_fforestPoints":EmbeddedArt.hud_nghbr_ffp_star,
         "worldScore_lightPoints":EmbeddedArt.hud_nghbr_lgp_star,
         "worldScore_rainforestPoints":EmbeddedArt.hud_nghbr_rfp_star,
         "worldScore_rainbowPoints":EmbeddedArt.hud_nghbr_ozp_star,
         "worldScore_villagePoints":EmbeddedArt.hud_nghbr_cap_star,
         "worldScore_rivieraPoints":EmbeddedArt.hud_nghbr_mediterraneanp_star,
         "worldScore_oasisPoints":EmbeddedArt.hud_nghbr_oap_star,
         "worldScore_storybookPoints":EmbeddedArt.hud_nghbr_storybookp_star,
         "worldScore_sleepyhollowPoints":EmbeddedArt.hud_nghbr_sleepyhollowp_star,
         "worldScore_toylandPoints":EmbeddedArt.hud_nghbr_toylandp_star,
         "worldScore_avalonPoints":EmbeddedArt.hud_nghbr_avalonp_star,
         "worldScore_avalon2Points":EmbeddedArt.hud_nghbr_avalon2p_star,
         "worldScore_ranchPoints":EmbeddedArt.hud_nghbr_wildwestp_star,
         "worldScore_treasurePoints":EmbeddedArt.hud_nghbr_treasuretidesp_star,
         "worldScore_africaPoints":EmbeddedArt.hud_nghbr_africap_star,
         "worldScore_transylvaniaPoints":EmbeddedArt.hud_nghbr_transylvaniap_star,
         "worldScore_japanPoints":EmbeddedArt.hud_nghbr_japanp_star,
         "worldScore_anglofrenchPoints":EmbeddedArt.hud_nghbr_anglofrenchp_star,
         "worldScore_rioPoints":EmbeddedArt.hud_nghbr_brazilp_star,
         "worldScore_winterPoints":EmbeddedArt.hud_nghbr_winterp_star,
         "worldScore_indiaPoints":EmbeddedArt.hud_nghbr_indiap_star,
         "worldScore_junglePoints":EmbeddedArt.hud_nghbr_junglep_star,
         "worldScore_mountPoints":EmbeddedArt.hud_nghbr_mountp_star,
         "worldScore_limboPoints":EmbeddedArt.hud_nghbr_limbop_star,
         "worldScore_groovyPoints":EmbeddedArt.hud_nghbr_midwestp_star,
         "worldScore_xmasPoints":EmbeddedArt.hud_nghbr_xmasp_star,
         "worldScore_opalPoints":EmbeddedArt.hud_nghbr_underwaterp_star,
         "worldScore_turtleislandPoints":EmbeddedArt.hud_nghbr_turtleislandp_star,
         "worldScore_dreamPoints":EmbeddedArt.hud_nghbr_dreamworldp_star,
         "worldScore_shadowPoints":EmbeddedArt.hud_nghbr_halloweenusap_star,
         "worldScore_whitewinterPoints":EmbeddedArt.hud_nghbr_whitewinterp_star,
         "worldScore_dragonvalleyPoints":EmbeddedArt.hud_nghbr_dragonvalleyp_star,
         "worldScore_tuscanyPoints":EmbeddedArt.hud_nghbr_tuscanyp_star,
         "worldScore_caribbeanPoints":EmbeddedArt.hud_nghbr_caribbeanp_star,
         "worldScore_russiaPoints":EmbeddedArt.hud_nghbr_russiap_star,
         "worldScore_newfrontierPoints":EmbeddedArt.hud_nghbr_newfrontierp_star,
         "worldScore_israelPoints":EmbeddedArt.hud_nghbr_israelp_star,
         "worldScore_halloweenmadPoints":EmbeddedArt.hud_nghbr_halloweenmadp_star,
         "worldScore_winternordPoints":EmbeddedArt.hud_nghbr_winternordp_star,
         "worldScore_casablancaPoints":EmbeddedArt.hud_nghbr_casablancap_star,
         "worldScore_southindiaPoints":EmbeddedArt.hud_nghbr_southindiap_star,
         "worldScore_twentiesPoints":EmbeddedArt.hud_nghbr_twentiesp_star,
         "worldScore_alaskaPoints":EmbeddedArt.hud_nghbr_alaskap_star,
         "worldScore_cocolandPoints":EmbeddedArt.hud_nghbr_cocolandp_star,
         "worldScore_irelandPoints":EmbeddedArt.hud_nghbr_irelandp_star,
         "worldScore_spookyPoints":EmbeddedArt.hud_nghbr_spookyp_star,
         "worldScore_santavillagePoints":EmbeddedArt.hud_nghbr_santavillagep_star,
         "worldScore_farmfestPoints":EmbeddedArt.hud_nghbr_farmfestp_star,
         "worldScore_madagascarPoints":EmbeddedArt.hud_nghbr_madagascarp_star,
         "worldScore_boraboraPoints":EmbeddedArt.hud_nghbr_boraborap_star,
         "worldScore_amsterdamPoints":EmbeddedArt.hud_nghbr_amsterdamp_star,
         "worldScore_canadaPoints":EmbeddedArt.hud_nghbr_canadap_star,
         "worldScore_alohaPoints":EmbeddedArt.hud_nghbr_alohap_star,
         "worldScore_pumpkinPoints":EmbeddedArt.hud_nghbr_pumpkinp_star,
         "worldScore_yuletidePoints":EmbeddedArt.hud_nghbr_yuletidep_star
      };
      
      private static var m_scoreUnitToFontColor:Object = {
         "worldScore_":"0x544120",
         "worldScore_zen":"0x764D1F",
         "worldScore_africaPoints":"0xffffff",
         "worldScore_transylvaniaPoints":"0xffffff",
         "worldScore_indiaPoints":"0xffffff",
         "worldScore_limboPoints":"0xf3fe5d",
         "worldScore_xmasPoints":"0x0017c1",
         "worldScore_groovyPoints":"0xffffff",
         "worldScore_dreamPoints":"0x990099",
         "worldScore_shadowPoints":"0xfffd6b",
         "worldScore_whitewinterPoints":"0xffffff",
         "worldScore_tuscanyPoints":"0xfffd6b",
         "worldScore_dragonvalleyPoints":"0x51ff86",
         "worldScore_caribbeanPoints":"0x0046eb",
         "worldScore_russiaPoints":"0x0046eb",
         "worldScore_newfrontierPoints":"0xffffff",
         "worldScore_israelPoints":"0x17ff79",
         "worldScore_halloweenmadPoints":"0x134187",
         "worldScore_winternordPoints":"0x0f4261",
         "worldScore_casablancaPoints":"0xffffff",
         "worldScore_southindiaPoints":"0xffffff",
         "worldScore_twentiesPoints":"0xffffff",
         "worldScore_alaskaPoints":"0xffffff",
         "worldScore_cocolandPoints":"0xfe5a90",
         "worldScore_irelandPoints":"0xffffff",
         "worldScore_spookyPoints":"0xffffff",
         "worldScore_santavillagePoints":"0xffffff",
         "worldScore_farmfestPoints":"0xffffff",
         "worldScore_madagascarPoints":"0xffffff",
         "worldScore_boraboraPoints":"0xffffff",
         "worldScore_amsterdamPoints":"0xffffff",
         "worldScore_canadaPoints":"0xffffff",
         "worldScore_alohaPoints":"0xffffff",
         "worldScore_pumpkinPoints":"0xffffff",
         "worldScore_yuletidePoints":"0xffffff"
      };
      
      private var m_worldScores:Dictionary = new Dictionary();
      
      public function WorldScoreSettingsManager()
      {
         super();
      }
      
      public function getTasksForWorldScoreId(scoreUnit:String) : Vector.<FarmTask>
      {
         var result:Vector.<FarmTask> = new Vector.<FarmTask>();
         if(this.m_worldScores.hasOwnProperty(scoreUnit) && Boolean(this.m_worldScores[scoreUnit].hasOwnProperty(KEY_TASKS)))
         {
            result = this.m_worldScores[scoreUnit][KEY_TASKS];
         }
         return result;
      }
      
      public function getTasksOfAction(scoreUnit:String, actions:Array) : Vector.<FarmTask>
      {
         var task:FarmTask = null;
         var result:Vector.<FarmTask> = new Vector.<FarmTask>();
         var tasks:Vector.<FarmTask> = this.getTasksForWorldScoreId(scoreUnit);
         var numTasks:int = int(tasks.length);
         for(var taskIdx:int = 0; taskIdx < numTasks; taskIdx++)
         {
            task = tasks[taskIdx];
            if(actions.indexOf(task.action) != -1)
            {
               result.push(task);
            }
         }
         return result;
      }
      
      public function getLevelForScore(scoreUnit:String, scoreAmount:Number, currentLevel:Number = 0) : Number
      {
         var tempLevelData:LevelData = null;
         var tempLevelIndex:Number = NaN;
         var levelFound:Boolean = false;
         var result:Number = 0;
         if(this.m_worldScores.hasOwnProperty(scoreUnit) && Boolean(this.m_worldScores[scoreUnit].hasOwnProperty(KEY_LEVELS)))
         {
            if(currentLevel < 0)
            {
               currentLevel = 0;
            }
            tempLevelData = this.getLevelDataForScoreUnit(scoreUnit,currentLevel);
            if(tempLevelData.requiredScore > scoreAmount)
            {
               currentLevel = 0;
            }
            tempLevelIndex = currentLevel;
            levelFound = false;
            while(!levelFound && tempLevelIndex < 1000)
            {
               tempLevelData = this.getLevelDataForScoreUnit(scoreUnit,tempLevelIndex);
               if(Boolean(tempLevelData) && scoreAmount >= tempLevelData.requiredScore)
               {
                  result = tempLevelData.levelNumber;
               }
               else
               {
                  levelFound = true;
               }
               tempLevelIndex++;
            }
         }
         return result;
      }
      
      public function getRewardsForLevel(scoreUnit:String, levelNum:int) : Vector.<Object>
      {
         var result:Vector.<Object> = null;
         var levelData:LevelData = this.getLevelDataForScoreUnit(scoreUnit,levelNum);
         if(FarmGameSettingsManager.isInWorldScoreAMFExperiment())
         {
            result = UserRewardUtil.getRewardsVectorFromObject(levelData.getRewards());
         }
         else
         {
            result = UserRewardUtil.getRewardsVectorFromXml(levelData.getRewardsXml());
         }
         return result;
      }
      
      public function getFeedIconUrlForLevel(scoreUnit:String, levelNum:int) : String
      {
         var levelData:LevelData = this.getLevelDataForScoreUnit(scoreUnit,levelNum);
         return levelData.getFeedIconUrl();
      }
      
      public function getFriendRewardItemForLevel(scoreUnit:String, levelNum:int) : String
      {
         var levelData:LevelData = this.getLevelDataForScoreUnit(scoreUnit,levelNum);
         return levelData.getFriendRewardItem();
      }
      
      public function getRequiredScoreForLevel(scoreUnit:String, aLevel:Number) : Number
      {
         var result:Number = 0;
         var levelData:LevelData = this.getLevelDataForScoreUnit(scoreUnit,aLevel);
         if(levelData)
         {
            result = levelData.requiredScore;
         }
         return result;
      }
      
      public function getLevelDataForScoreUnit(scoreUnit:String, levelNum:Number) : LevelData
      {
         var result:LevelData = null;
         var levels:Vector.<LevelData> = null;
         var levelsLength:int = 0;
         var levelIndex:int = 0;
         var levelData:LevelData = null;
         if(this.m_worldScores.hasOwnProperty(scoreUnit) && Boolean(this.m_worldScores[scoreUnit].hasOwnProperty(KEY_LEVELS)))
         {
            levels = this.m_worldScores[scoreUnit][KEY_LEVELS];
            if(Boolean(this.m_worldScores[scoreUnit][KEY_LEVELS].hasOwnProperty(levelNum)) && (this.m_worldScores[scoreUnit][KEY_LEVELS][levelNum] as LevelData).levelNumber == levelNum)
            {
               result = this.m_worldScores[scoreUnit][KEY_LEVELS][levelNum];
            }
            else if(levelNum > levels[levels.length - 1].levelNumber)
            {
               result = LevelData.getCalculatedLevelData(scoreUnit,levelNum);
            }
            else
            {
               levelsLength = int(levels.length);
               for(levelIndex = 0; levelIndex < levelsLength; levelIndex++)
               {
                  levelData = levels[levelIndex];
                  if(levelData.levelNumber == levelNum)
                  {
                     result = levelData;
                     break;
                  }
               }
            }
         }
         return result;
      }
      
      public function addWorldScoresConfig(worldScores:Object) : void
      {
         var data:Object = null;
         var score:* = undefined;
         var index:int = 0;
         for each(data in worldScores)
         {
            score = data["scores"]["score"];
            if(getQualifiedClassName(score) == "Array")
            {
               for(index = 0; index < score.length; index++)
               {
                  this.addWorldScoreConfig(score[index]);
               }
            }
            else
            {
               this.addWorldScoreConfig(score);
            }
         }
      }
      
      public function addWorldScoreConfig(score:Object) : void
      {
         var levelData:LevelData = null;
         var farmTask:FarmTask = null;
         var level:Object = null;
         var taskObj:Object = null;
         var defaultLevel:Object = null;
         var rewardIndex:int = 0;
         var farmItem:FarmItem = null;
         var rewards:Vector.<Object> = null;
         var items:Array = null;
         var itemIndex:int = 0;
         var buildingItem:BuildingItem = null;
         var scoreId:String = score["id"].toString();
         this.m_worldScores[scoreId] = new Dictionary();
         var levels:Vector.<LevelData> = new Vector.<LevelData>();
         for each(level in score.level)
         {
            levelData = new LevelData(null,level);
            if(levelData)
            {
               levels.push(levelData);
            }
         }
         levels.sort(this.compareLevels);
         this.m_worldScores[scoreId][KEY_LEVELS] = levels;
         if(score.hasOwnProperty(WorldScoreSettingsManager.KEY_DEFAULT_LEVEL))
         {
            defaultLevel = score[KEY_DEFAULT_LEVEL];
            this.m_worldScores[scoreId][KEY_DEFAULT_LEVEL] = new Dictionary();
            if(defaultLevel.hasOwnProperty(KEY_REWARDS))
            {
               this.m_worldScores[scoreId][KEY_DEFAULT_LEVEL][KEY_REWARDS] = defaultLevel[KEY_REWARDS];
            }
            if(defaultLevel.hasOwnProperty(KEY_FRONTEND))
            {
               this.m_worldScores[scoreId][KEY_DEFAULT_LEVEL][KEY_FRONTEND] = score[KEY_FRONTEND];
            }
            if(defaultLevel.hasOwnProperty(KEY_FRIENDREWARD))
            {
               this.m_worldScores[scoreId][KEY_DEFAULT_LEVEL][KEY_FRIENDREWARD] = defaultLevel[KEY_FRIENDREWARD];
            }
         }
         var tasks:Vector.<FarmTask> = new Vector.<FarmTask>();
         for each(taskObj in score.task)
         {
            taskObj["rewardsData"] = taskObj["rewards"];
            taskObj["rewards"] = UserRewardUtil.getRewardsVectorFromObject(taskObj["rewards"]);
            farmTask = new FarmTask(taskObj);
            if(farmTask)
            {
               if(scoreId != WorldScoreSettingsManager.KEY_GLOBAL || !this.isTaskPrunable(farmTask))
               {
                  if(taskObj.hasOwnProperty("rewardsData"))
                  {
                     rewards = UserRewardUtil.getRewardsVectorFromObject(taskObj["rewardsData"]);
                  }
                  farmTask.rewards = rewards;
                  tasks.push(farmTask);
               }
               rewardIndex = 0;
               farmItem = null;
               if(farmTask.action == QuestConstants.TASK_BUY_ITEM_BY_CATEGORY || farmTask.action == QuestConstants.TASK_BUY_ITEM_BY_CODE || farmTask.action == QuestConstants.TASK_BUY_ITEM_BY_CLASS)
               {
                  for(rewardIndex = 0; rewardIndex < rewards.length; rewardIndex++)
                  {
                     if(rewards[rewardIndex].type == QuestConstants.REWARD_WORLD_SCORE)
                     {
                        items = farmTask.getItemsList();
                        for(itemIndex = 0; itemIndex < items.length; itemIndex++)
                        {
                           farmItem = items[itemIndex];
                           if(farmItem)
                           {
                              farmItem.buyWorldScoreUnit = rewards[rewardIndex].unit;
                              farmItem.buyWorldScore = rewards[rewardIndex].value;
                           }
                        }
                     }
                  }
               }
               else if(farmTask.action == QuestConstants.TASK_EXPAND_STORAGE_BUILDING_TO_LEVEL_BY_CODE)
               {
                  for(rewardIndex = 0; rewardIndex < rewards.length; rewardIndex++)
                  {
                     if(rewards[rewardIndex].type == QuestConstants.REWARD_WORLD_SCORE)
                     {
                        farmItem = Global.farmGameSettingsManager.getFarmItemByCode(farmTask.type);
                        if(farmItem)
                        {
                           farmItem.addUpgradeConfigWorldScoreBonus(farmTask.extraData.level,rewards[rewardIndex].unit,rewards[rewardIndex].value);
                        }
                     }
                  }
               }
               else if(farmTask.action == QuestConstants.TASK_COMPLETE_NONDETERMINISTIC_CONSTRUCTION_BY_CODE)
               {
                  for(rewardIndex = 0; rewardIndex < rewards.length; rewardIndex++)
                  {
                     if(rewards[rewardIndex].type == QuestConstants.REWARD_WORLD_SCORE)
                     {
                        buildingItem = Global.farmGameSettingsManager.getFarmItemByCode(farmTask.type) as BuildingItem;
                        if(buildingItem)
                        {
                           buildingItem.completeWorldScore = rewards[rewardIndex].value;
                           buildingItem.completeWorldScoreUnit = rewards[rewardIndex].unit;
                        }
                     }
                  }
               }
            }
         }
         this.m_worldScores[scoreId][KEY_TASKS] = tasks;
         if(score.hasOwnProperty(KEY_ICON_URL))
         {
            this.m_worldScores[scoreId][KEY_ICON_URL] = score[KEY_ICON_URL].toString();
         }
         if(score.hasOwnProperty(KEY_LEVEL_UP_DIALOG_URL))
         {
            this.m_worldScores[scoreId][KEY_LEVEL_UP_DIALOG_URL] = score[KEY_LEVEL_UP_DIALOG_URL].toString();
         }
         if(score.hasOwnProperty(KEY_PREREQ))
         {
            this.m_worldScores[scoreId][KEY_PREREQ] = score[KEY_PREREQ].toString();
         }
      }
      
      public function addConfigXML(xml:XML) : void
      {
         var levelData:LevelData = null;
         var farmTask:FarmTask = null;
         var scoreXml:XML = null;
         var scoreId:String = null;
         var levels:Vector.<LevelData> = null;
         var levelXml:XML = null;
         var tasks:Vector.<FarmTask> = null;
         var taskXml:XML = null;
         var defaultLevel:XML = null;
         var taskObj:Object = null;
         var rewardIndex:int = 0;
         var farmItem:FarmItem = null;
         var rewards:Vector.<Object> = null;
         var items:Array = null;
         var itemIndex:int = 0;
         var buildingItem:BuildingItem = null;
         for each(scoreXml in xml..score)
         {
            scoreId = scoreXml[XMLKeys.ATTR_ID].toString();
            this.m_worldScores[scoreId] = new Dictionary();
            levels = new Vector.<LevelData>();
            for each(levelXml in scoreXml.level)
            {
               levelData = new LevelData(levelXml,null);
               if(levelData)
               {
                  levels.push(levelData);
               }
            }
            levels.sort(this.compareLevels);
            this.m_worldScores[scoreId][KEY_LEVELS] = levels;
            if(scoreXml.hasOwnProperty(WorldScoreSettingsManager.KEY_DEFAULT_LEVEL))
            {
               defaultLevel = scoreXml[KEY_DEFAULT_LEVEL][0];
               this.m_worldScores[scoreId][KEY_DEFAULT_LEVEL] = new Dictionary();
               if(defaultLevel.hasOwnProperty(KEY_REWARDS))
               {
                  this.m_worldScores[scoreId][KEY_DEFAULT_LEVEL][KEY_REWARDS] = defaultLevel[KEY_REWARDS][0];
               }
               if(defaultLevel.hasOwnProperty(KEY_FRONTEND))
               {
                  this.m_worldScores[scoreId][KEY_DEFAULT_LEVEL][KEY_FRONTEND] = xml[KEY_FRONTEND][0];
               }
               if(defaultLevel.hasOwnProperty(KEY_FRIENDREWARD))
               {
                  this.m_worldScores[scoreId][KEY_DEFAULT_LEVEL][KEY_FRIENDREWARD] = FarmGameUtil.xmlNodeToAttributes(defaultLevel[KEY_FRIENDREWARD][0]);
               }
            }
            tasks = new Vector.<FarmTask>();
            for each(taskXml in scoreXml.task)
            {
               taskObj = FarmGameUtil.xmlNodeToAttributes(taskXml);
               farmTask = new FarmTask(taskObj);
               if(farmTask)
               {
                  if(scoreId != WorldScoreSettingsManager.KEY_GLOBAL || !this.isTaskPrunable(farmTask))
                  {
                     if(taskXml.hasOwnProperty("rewards"))
                     {
                        rewards = UserRewardUtil.getRewardsVectorFromXml(taskXml["rewards"][0]);
                     }
                     farmTask.rewards = rewards;
                     tasks.push(farmTask);
                  }
                  rewardIndex = 0;
                  farmItem = null;
                  if(farmTask.action == QuestConstants.TASK_BUY_ITEM_BY_CATEGORY || farmTask.action == QuestConstants.TASK_BUY_ITEM_BY_CODE || farmTask.action == QuestConstants.TASK_BUY_ITEM_BY_CLASS)
                  {
                     for(rewardIndex = 0; rewardIndex < rewards.length; rewardIndex++)
                     {
                        if(rewards[rewardIndex].type == QuestConstants.REWARD_WORLD_SCORE)
                        {
                           items = farmTask.getItemsList();
                           for(itemIndex = 0; itemIndex < items.length; itemIndex++)
                           {
                              farmItem = items[itemIndex];
                              if(farmItem)
                              {
                                 farmItem.buyWorldScoreUnit = rewards[rewardIndex].unit;
                                 farmItem.buyWorldScore = rewards[rewardIndex].value;
                              }
                           }
                        }
                     }
                  }
                  else if(farmTask.action == QuestConstants.TASK_EXPAND_STORAGE_BUILDING_TO_LEVEL_BY_CODE)
                  {
                     for(rewardIndex = 0; rewardIndex < rewards.length; rewardIndex++)
                     {
                        if(rewards[rewardIndex].type == QuestConstants.REWARD_WORLD_SCORE)
                        {
                           farmItem = Global.farmGameSettingsManager.getFarmItemByCode(farmTask.type);
                           if(farmItem)
                           {
                              farmItem.addUpgradeConfigWorldScoreBonus(farmTask.extraData.level,rewards[rewardIndex].unit,rewards[rewardIndex].value);
                           }
                        }
                     }
                  }
                  else if(farmTask.action == QuestConstants.TASK_COMPLETE_NONDETERMINISTIC_CONSTRUCTION_BY_CODE)
                  {
                     for(rewardIndex = 0; rewardIndex < rewards.length; rewardIndex++)
                     {
                        if(rewards[rewardIndex].type == QuestConstants.REWARD_WORLD_SCORE)
                        {
                           buildingItem = Global.farmGameSettingsManager.getFarmItemByCode(farmTask.type) as BuildingItem;
                           if(buildingItem)
                           {
                              buildingItem.completeWorldScore = rewards[rewardIndex].value;
                              buildingItem.completeWorldScoreUnit = rewards[rewardIndex].unit;
                           }
                        }
                     }
                  }
               }
            }
            this.m_worldScores[scoreId][KEY_TASKS] = tasks;
            this.m_worldScores[scoreId][KEY_ICON_URL] = scoreXml[XMLKeys.ATTR_ICON_URL].toString();
            this.m_worldScores[scoreId][KEY_LEVEL_UP_DIALOG_URL] = scoreXml[XMLKeys.ATTR_LEVEL_UP_DIALOG_URL].toString();
            if(scoreXml.hasOwnProperty(XMLKeys.ATTR_PREREQ))
            {
               this.m_worldScores[scoreId][KEY_PREREQ] = scoreXml[XMLKeys.ATTR_PREREQ].toString();
            }
         }
      }
      
      private function isTaskPrunable(task:FarmTask) : Boolean
      {
         var result:Boolean = false;
         switch(task.action)
         {
            case QuestConstants.TASK_BUY_ITEM_BY_CODE:
               result = this.shouldPruneTaskByItemCode(task.type);
         }
         return result;
      }
      
      private function shouldPruneTaskByItemCode(itemCode:String) : Boolean
      {
         var result:Boolean = false;
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
         if(item)
         {
            result = !item.checkDateGate();
         }
         return result;
      }
      
      public function compareLevels(x:LevelData, y:LevelData) : Number
      {
         var result:Number = 0;
         if(x.levelNumber < y.levelNumber)
         {
            result = -1;
         }
         else if(x.levelNumber > y.levelNumber)
         {
            result = 1;
         }
         return result;
      }
      
      public function getIconForScoreUnit(scoreUnit:String) : String
      {
         return this.m_worldScores[scoreUnit][KEY_ICON_URL];
      }
      
      public function getPrereqName(scoreUnit:String) : String
      {
         var result:String = null;
         if(this.m_worldScores[scoreUnit].hasOwnProperty(KEY_PREREQ))
         {
            result = this.m_worldScores[scoreUnit][KEY_PREREQ];
         }
         return result;
      }
      
      public function isEnabled(scoreUnit:String) : Boolean
      {
         var prereqName:String = null;
         var result:Boolean = false;
         if(this.m_worldScores.hasOwnProperty(scoreUnit) && Boolean(this.m_worldScores[scoreUnit].hasOwnProperty(KEY_TASKS)))
         {
            prereqName = this.getPrereqName(scoreUnit);
            if(prereqName == null)
            {
               result = true;
            }
            else
            {
               result = PrerequisiteUtility.checkPrereqByName(prereqName);
            }
         }
         return result;
      }
      
      public function getLevelUpDialogUrlForScoreUnit(scoreUnit:String) : String
      {
         return this.m_worldScores[scoreUnit][KEY_LEVEL_UP_DIALOG_URL];
      }
      
      public function getStar(scoreUnit:String) : Class
      {
         return m_scoreUnitToStar[WORLDSCORE_TO_DATA_PREFIX + scoreUnit];
      }
      
      public function getLevelFontColor(scoreUnit:String) : String
      {
         return m_scoreUnitToFontColor[WORLDSCORE_TO_DATA_PREFIX + scoreUnit];
      }
      
      public function getDefaultLevel(scoreUnit:String) : Dictionary
      {
         return this.m_worldScores[scoreUnit][KEY_DEFAULT_LEVEL];
      }
   }
}

