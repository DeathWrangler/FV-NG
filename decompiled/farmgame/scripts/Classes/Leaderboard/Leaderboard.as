package Classes.Leaderboard
{
   import Classes.Constants.Experiments;
   import Classes.Constants.PrerequisiteConstants;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.DynamicIconQueue;
   import Display.QueuedIcons.LeaderboardQueuedDynamicIcon;
   import Display.QueuedIcons.LeaderboardQueuedIcon;
   import Display.QueuedIcons.MultiTaskLeaderboardQueuedIcon;
   
   public class Leaderboard
   {
      
      private static const NUM_DAYS_CONSIDERED_TO_EXPIRING_SOON:int = 3;
      
      private static const HUD_ICON_URL:String = "assets/hud/HUD_leaderboards.png";
      
      private static const DYNAMIC_HUD_ICON_URL:String = "assets/hud/hud_icon_queue/FV_hud_leaderboard_2013.swf";
      
      public static const ASSET_DIALOG_BACKGROUND:String = "dialogBackground";
      
      public static const ASSET_HUD_ICON:String = "hudIcon";
      
      private const NOT_INITIALIZED:Number = -1;
      
      private var m_name:String;
      
      private var m_iconUrl:String;
      
      private var m_prereqs:Array;
      
      private var m_photoContestPrereqs:Array;
      
      private var m_tasks:Array;
      
      private var m_progressRewards:Array;
      
      private var m_rankRewards:Array;
      
      private var m_assets:Object;
      
      private var m_startTime:Number = -1;
      
      private var m_expirationTime:Number = -1;
      
      private var m_everlasting:Boolean = false;
      
      private var m_photoContest:Boolean = false;
      
      public function Leaderboard(xml:XML)
      {
         var taskXml:XML = null;
         var assetsXml:XMLList = null;
         var assetXml:XML = null;
         var assetName:String = null;
         var assetUrl:String = null;
         super();
         this.m_name = String(xml.@name);
         if(xml.@photoContest)
         {
            this.m_photoContest = String(xml.@photoContest) == "true";
         }
         if(xml.hasOwnProperty("prereqs") && xml.prereqs.hasOwnProperty("prereq"))
         {
            this.m_prereqs = PrerequisiteUtility.parseXmlNodePrereqs(xml.prereqs.prereq);
         }
         if(xml.hasOwnProperty("photoContestData") && xml.photoContestData.hasOwnProperty("prereqs") && Boolean(xml.photoContestData.prereqs.hasOwnProperty("prereq")))
         {
            this.m_photoContestPrereqs = PrerequisiteUtility.parseXmlNodePrereqs(xml.photoContestData.prereqs.prereq);
         }
         if(xml.hasOwnProperty("task"))
         {
            this.m_tasks = [new LeaderboardTask(this,FarmGameUtil.xmlNodeToAttributes(xml.task[0] as XML))];
         }
         else if(xml.hasOwnProperty("tasks"))
         {
            this.m_tasks = [];
            for each(taskXml in xml.tasks.task)
            {
               this.m_tasks.push(new LeaderboardTask(this,FarmGameUtil.xmlNodeToAttributes(taskXml)));
            }
         }
         if(xml.hasOwnProperty("progressRewards"))
         {
            this.m_progressRewards = this.processGroupList(xml.progressRewards);
         }
         if(xml.hasOwnProperty("rankRewards"))
         {
            this.m_rankRewards = this.processGroupList(xml.rankRewards);
         }
         if(xml.hasOwnProperty("frontend"))
         {
            this.m_iconUrl = xml.frontend.icon.toString();
         }
         if(xml.hasOwnProperty("frontend"))
         {
            this.m_assets = {};
            assetsXml = xml.frontend;
            for each(assetXml in assetsXml.children())
            {
               assetName = assetXml.name().toString();
               assetUrl = assetXml.valueOf().toString();
               this.m_assets[assetName] = assetUrl;
            }
         }
         if(xml.hasOwnProperty("everlasting"))
         {
            this.m_everlasting = true;
         }
      }
      
      private function processGroupList(groupList:XMLList) : Array
      {
         var node:XML = null;
         var objToAdd:Object = null;
         var result:Array = new Array();
         var list:XMLList = groupList.children();
         if(list.length() == 0)
         {
            list = groupList;
         }
         for each(node in list)
         {
            objToAdd = new Object();
            objToAdd = FarmGameUtil.xmlNodeToAttributes(node);
            result.push(objToAdd);
         }
         return result;
      }
      
      public function get iconUrl() : String
      {
         var result:String = null;
         if(this.m_iconUrl)
         {
            result = this.m_iconUrl;
         }
         else if(Boolean(this.m_tasks) && this.m_tasks.length > 0)
         {
            result = (this.m_tasks[0] as LeaderboardTask).iconUrl;
         }
         return result;
      }
      
      public function get name() : String
      {
         return this.m_name;
      }
      
      public function get photoContest() : Boolean
      {
         return this.m_photoContest;
      }
      
      public function get nameText() : String
      {
         return ZLocUtils.t("Leaderboard",this.m_name + "_Title");
      }
      
      public function get descriptionText() : String
      {
         var result:String = "";
         var descriptionKey:String = this.name + "_Description";
         if(ZLocUtils.hasString("Leaderboard",descriptionKey))
         {
            result = ZLocUtils.t("Leaderboard",descriptionKey);
         }
         else if(!this.isMultitask)
         {
            if(Boolean(this.m_tasks) && this.m_tasks.length > 0)
            {
               result = (this.m_tasks[0] as LeaderboardTask).titleText;
            }
         }
         return result;
      }
      
      public function get prereqs() : Array
      {
         return this.m_prereqs;
      }
      
      public function get photoPrereqs() : Array
      {
         return this.m_photoContestPrereqs;
      }
      
      public function get tasks() : Array
      {
         return this.m_tasks;
      }
      
      public function get isMultitask() : Boolean
      {
         return this.m_tasks ? this.m_tasks.length > 1 : false;
      }
      
      public function get progressRewards() : Array
      {
         return this.m_progressRewards;
      }
      
      public function getProgressReward(index:int) : Object
      {
         return Boolean(this.m_progressRewards) && this.m_progressRewards.length > index ? this.m_progressRewards[index] : null;
      }
      
      public function getIndexForProgressReward(reward:Object) : int
      {
         var i:int = 0;
         var progressReward:Object = null;
         var result:int = -1;
         if(this.m_progressRewards)
         {
            for(i = 0; i < this.m_progressRewards.length; i++)
            {
               progressReward = this.m_progressRewards[i];
               if(progressReward == reward)
               {
                  result = i;
                  break;
               }
            }
         }
         return result;
      }
      
      public function get rankRewards() : Array
      {
         return this.m_rankRewards;
      }
      
      public function get startTime() : Number
      {
         var prereq:Object = null;
         var type:String = null;
         var value:String = null;
         if(this.m_startTime == this.NOT_INITIALIZED)
         {
            this.m_startTime = 0;
            if(this.m_prereqs)
            {
               for each(prereq in this.m_prereqs)
               {
                  type = prereq["type"] as String;
                  if(Boolean(type) && type == PrerequisiteConstants.PREREQUISITE_START_TIME)
                  {
                     value = prereq[PrerequisiteConstants.KEY_VALUE];
                     this.m_startTime = FarmGameUtil.synchronizedDateTimeToNumber(value);
                  }
               }
            }
         }
         return this.m_startTime;
      }
      
      public function get expirationTime() : Number
      {
         var prereq:Object = null;
         var type:String = null;
         var value:String = null;
         if(this.m_expirationTime == this.NOT_INITIALIZED)
         {
            this.m_expirationTime = 0;
            if(this.m_prereqs)
            {
               for each(prereq in this.m_prereqs)
               {
                  type = prereq["type"] as String;
                  if(Boolean(type) && type == PrerequisiteConstants.PREREQUISITE_END_TIME)
                  {
                     value = prereq[PrerequisiteConstants.KEY_VALUE];
                     this.m_expirationTime = FarmGameUtil.synchronizedDateTimeToNumber(value);
                  }
               }
            }
         }
         return this.m_expirationTime;
      }
      
      public function get timeRemaining() : Number
      {
         var result:Number = 0;
         if(this.expirationTime > 0)
         {
            result = (this.expirationTime - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
            if(result < 0)
            {
               result = 0;
            }
         }
         return result;
      }
      
      public function get isActive() : Boolean
      {
         return (!this.m_prereqs || PrerequisiteUtility.arePrerequisitesMet(this.m_prereqs)) && !this.m_everlasting;
      }
      
      public function get isPhotoContestPrereqMet() : Boolean
      {
         return !this.m_photoContestPrereqs || PrerequisiteUtility.arePrerequisitesMet(this.m_photoContestPrereqs);
      }
      
      public function get isEverlasting() : Boolean
      {
         return this.m_everlasting;
      }
      
      public function get isExpired() : Boolean
      {
         var prereq:Object = null;
         var type:String = null;
         var result:Boolean = true;
         if(this.m_prereqs)
         {
            for each(prereq in this.m_prereqs)
            {
               type = prereq["type"] as String;
               if(type)
               {
                  if(type == PrerequisiteConstants.PREREQUISITE_END_TIME)
                  {
                     if(PrerequisiteUtility.isPrerequisiteMet(prereq))
                     {
                        result = false;
                        break;
                     }
                  }
                  else if(!PrerequisiteUtility.isPrerequisiteMet(prereq))
                  {
                     result = false;
                     break;
                  }
               }
            }
         }
         else
         {
            result = false;
         }
         return result;
      }
      
      public function get isExpiringSoon() : Boolean
      {
         var timeLeft:Number = this.timeRemaining;
         return this.expirationTime > 0 && timeLeft <= FarmGameUtil.NUM_SECS_IN_DAY * NUM_DAYS_CONSIDERED_TO_EXPIRING_SOON;
      }
      
      public function get isNew() : Boolean
      {
         var userState:LeaderboardState = Global.player.getLeaderboardState(this.name);
         return userState ? !userState.seen : true;
      }
      
      public function getAssetUrl(assetName:String) : String
      {
         var result:String = null;
         if(Boolean(this.m_assets) && Boolean(this.m_assets[assetName]))
         {
            result = this.m_assets[assetName];
         }
         else
         {
            GlobalEngine.assert(false,"Dialog not found for " + this.m_name + ":" + assetName + ".");
         }
         return result;
      }
      
      public function getQueuedIcon() : LeaderboardQueuedIcon
      {
         return Global.hud.rightSideIconQueue.getIconByName(this.name) as LeaderboardQueuedIcon;
      }
      
      public function addIconToIconQueue() : LeaderboardQueuedIcon
      {
         var icon:LeaderboardQueuedIcon = null;
         var iconURL:String = null;
         var variant:int = 0;
         if(this.isMultitask)
         {
            iconURL = this.getAssetUrl(ASSET_HUD_ICON);
            if(iconURL)
            {
               icon = Global.hud.rightSideIconQueue.addIcon(MultiTaskLeaderboardQueuedIcon.ICON_NAME,DynamicIconQueue.ADD_BY_PRIORITY,iconURL,{"leaderboard":this}) as MultiTaskLeaderboardQueuedIcon;
            }
         }
         else
         {
            variant = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_LEADERBOARDS_SURFACING);
            if(variant >= Experiments.SINGLE_CONTROL_VALID_VARIANT_START)
            {
               icon = Global.hud.rightSideIconQueue.addIcon(LeaderboardQueuedDynamicIcon.DYNAMIC_ICON_NAME,DynamicIconQueue.ADD_BY_PRIORITY,DYNAMIC_HUD_ICON_URL,{"leaderboard":this}) as LeaderboardQueuedDynamicIcon;
            }
            else
            {
               icon = Global.hud.rightSideIconQueue.addIcon(LeaderboardQueuedIcon.DEFAULT_ICON_NAME,DynamicIconQueue.ADD_BY_PRIORITY,HUD_ICON_URL,{"leaderboard":this}) as LeaderboardQueuedIcon;
            }
         }
         if(icon)
         {
            icon.onAdd();
         }
         return icon;
      }
   }
}

