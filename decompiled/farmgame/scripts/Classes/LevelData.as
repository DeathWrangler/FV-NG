package Classes
{
   import Classes.util.FarmGameUtil;
   import Classes.util.UserRewardUtil;
   import Managers.FarmGameSettingsManager;
   import Managers.WorldScoreSettingsManager;
   import flash.utils.Dictionary;
   
   public class LevelData
   {
      
      private var m_levelNumber:int = -1;
      
      private var m_requiredScore:int = 0;
      
      private var m_rewardsXml:XML = null;
      
      private var m_rewards:Object = null;
      
      private var m_frontendXml:XML = null;
      
      private var m_frontend:Object = null;
      
      private var m_friendReward:Object = null;
      
      public function LevelData(xml:XML, data:Object)
      {
         super();
         if(xml)
         {
            this.initWithXml(xml);
         }
         else if(data)
         {
            this.initWithObject(data);
         }
      }
      
      public static function getCalculatedLevelData(scoreUnit:String, levelNum:int) : LevelData
      {
         var requiredScore:int = 0;
         var defaultLevelData:Dictionary = Global.worldScoreSettingsManager.getDefaultLevel(scoreUnit);
         var configObj:Object = {};
         configObj.num = levelNum;
         switch(scoreUnit)
         {
            case "spook":
               requiredScore = Math.round(10.006 * Math.pow(levelNum,2) - 48.818 * levelNum + 16.945);
               break;
            default:
               requiredScore = Math.round(19.443 * Math.pow(levelNum,2) - 43.183 * levelNum - 175.87);
         }
         configObj.required = requiredScore;
         configObj.rewards = defaultLevelData[WorldScoreSettingsManager.KEY_REWARDS];
         configObj.frontend = defaultLevelData[WorldScoreSettingsManager.KEY_FRONTEND];
         configObj.friendReward = defaultLevelData[WorldScoreSettingsManager.KEY_FRIENDREWARD];
         var levelData:LevelData = new LevelData(null,null);
         levelData.initLevelDataWithObject(configObj);
         return levelData;
      }
      
      public function initWithObject(data:Object) : void
      {
         this.m_levelNumber = data["num"];
         this.m_requiredScore = data["required"];
         if(data["rewards"])
         {
            this.m_rewards = data["rewards"];
         }
         if(data["frontend"])
         {
            this.m_frontend = data["frontend"];
         }
         if(data["friendReward"])
         {
            this.m_friendReward = data["friendReward"];
         }
      }
      
      public function initWithXml(xml:XML) : void
      {
         this.m_levelNumber = xml.attribute("num");
         this.m_requiredScore = xml.attribute("required");
         if(xml.hasOwnProperty("rewards"))
         {
            this.m_rewardsXml = xml["rewards"][0];
         }
         if(xml.hasOwnProperty("frontend"))
         {
            this.m_frontendXml = xml["frontend"][0];
         }
         if(xml.hasOwnProperty("friendReward"))
         {
            this.m_friendReward = FarmGameUtil.xmlNodeToAttributes(xml["friendReward"][0]);
         }
      }
      
      public function initLevelDataWithObject(configObj:Object) : void
      {
         if(configObj.hasOwnProperty("num"))
         {
            this.m_levelNumber = configObj["num"];
         }
         if(configObj.hasOwnProperty("required"))
         {
            this.m_requiredScore = configObj["required"];
         }
         if(configObj.hasOwnProperty("friendReward"))
         {
            this.m_friendReward = configObj["friendReward"];
         }
         if(FarmGameSettingsManager.isInWorldScoreAMFExperiment())
         {
            if(configObj.hasOwnProperty("rewards"))
            {
               this.m_rewards = configObj["rewards"];
            }
            if(configObj.hasOwnProperty("frontend"))
            {
               this.m_frontend = configObj["frontend"];
            }
         }
         else
         {
            if(configObj.hasOwnProperty("rewards"))
            {
               this.m_rewardsXml = configObj["rewards"];
            }
            if(configObj.hasOwnProperty("frontend"))
            {
               this.m_frontendXml = configObj["frontend"];
            }
         }
      }
      
      public function get levelNumber() : int
      {
         return this.m_levelNumber;
      }
      
      public function get requiredScore() : int
      {
         return this.m_requiredScore;
      }
      
      public function applyRewards() : void
      {
         if(FarmGameSettingsManager.isInWorldScoreAMFExperiment())
         {
            UserRewardUtil.grantUserRewardsFromObject(this.m_rewards);
         }
         else
         {
            UserRewardUtil.grantUserRewardsFromXml(this.m_rewardsXml);
         }
      }
      
      public function getRewards() : Object
      {
         return this.m_rewards;
      }
      
      public function getRewardsXml() : XML
      {
         return this.m_rewardsXml;
      }
      
      public function getFeedIconUrl() : String
      {
         var icon:String = null;
         if(FarmGameSettingsManager.isInWorldScoreAMFExperiment())
         {
            if(Boolean(this.m_frontend) && this.m_frontend.hasOwnProperty("icon"))
            {
               icon = this.m_frontend["icon"];
            }
         }
         else if(Boolean(this.m_frontendXml) && this.m_frontendXml.hasOwnProperty("icon"))
         {
            icon = this.m_frontendXml.icon;
         }
         return icon;
      }
      
      public function getFriendRewardItem() : String
      {
         var item:String = null;
         if(Boolean(this.m_friendReward) && this.m_friendReward.hasOwnProperty("item"))
         {
            item = this.m_friendReward.item;
         }
         return item;
      }
   }
}

