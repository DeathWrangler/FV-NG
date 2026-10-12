package Managers
{
   import Classes.Growable.GrowableContest;
   import Classes.Growable.GrowableContestTutorial;
   import Classes.Growable.IGrowableResource;
   import Classes.Quest.PrerequisiteUtility;
   
   public class GrowableContestManager
   {
      
      private static var s_instance:GrowableContestManager;
      
      public static var GROWABLE_CONTEST_SETTINGS:String = "growableObjectContests";
      
      public static var GROWABLE_CONTEST_STATE:String = "growableObjectContests";
      
      private var m_contests:Object;
      
      private var m_prereqs:Array;
      
      private var m_placingKeys:Array;
      
      public function GrowableContestManager(key:SingletonEnforcer)
      {
         var contestData:XML = null;
         var contestId:String = null;
         var contest:GrowableContest = null;
         this.m_contests = {};
         this.m_placingKeys = new Array();
         super();
         GlobalEngine.assert(key != null,"[GrowableContestManager] :: Use GrowableContestManager.instance");
         var featureData:XML = Global.farmGameSettingsManager.getFeatureXML("growableObjectContests");
         if(featureData)
         {
            this.m_prereqs = PrerequisiteUtility.parseXmlNodePrereqs(featureData.prereqs.prereq);
            if(this.isFeatureEnabled())
            {
               for each(contestData in featureData.contests.contest)
               {
                  contestId = contestData.@contestId;
                  contest = new GrowableContest(contestId);
                  if(contest.isEnabled())
                  {
                     this.m_contests[contestId] = contest;
                     contest.checkInviteStatus();
                  }
               }
            }
         }
      }
      
      public static function get instance() : GrowableContestManager
      {
         if(!s_instance)
         {
            s_instance = new GrowableContestManager(new SingletonEnforcer());
         }
         return s_instance;
      }
      
      public function isContestEnabled(contestId:String) : Boolean
      {
         return this.isFeatureEnabled() && Boolean(this.m_contests[contestId]) && Boolean(this.m_contests[contestId].isEnabled());
      }
      
      public function isFeatureEnabled() : Boolean
      {
         var result:Boolean = InstanceDataStoreManager.isEnabled;
         if(result && Boolean(this.m_prereqs))
         {
            result = PrerequisiteUtility.arePrerequisitesMet(this.m_prereqs);
         }
         return result;
      }
      
      public function beginPlacing(storageKey:String) : void
      {
         this.m_placingKeys.push(storageKey);
      }
      
      public function donePlacing(storageKey:String) : void
      {
         var idx:int = this.m_placingKeys.indexOf(storageKey);
         if(idx > -1)
         {
            this.m_placingKeys.splice(idx,1);
         }
      }
      
      public function isPlacing(storageKey:String) : Boolean
      {
         return this.m_placingKeys.indexOf(storageKey) > -1;
      }
      
      public function getContest(contestId:String) : GrowableContest
      {
         return this.m_contests[contestId];
      }
      
      public function onStateUpdate() : void
      {
      }
      
      public function getContestIdForInstance(instance:IGrowableResource) : String
      {
         var contestId:String = null;
         var contest:GrowableContest = null;
         var result:String = null;
         for(contestId in this.m_contests)
         {
            contest = this.m_contests[contestId];
            if(contest.getContestEntryForKey(instance.growableMapResource.persistentDataKey,GrowableContest.CONTEST_LIST_PARTICIPATING))
            {
               result = contestId;
               break;
            }
         }
         return result;
      }
      
      public function getContestForInstance(instance:IGrowableResource) : GrowableContest
      {
         var contest:GrowableContest = null;
         var contestId:String = this.getContestIdForInstance(instance);
         if(contestId != null)
         {
            contest = this.getContest(contestId);
         }
         return contest;
      }
      
      public function getContestIdForItemCode(itemCode:String) : String
      {
         var contestId:String = null;
         var contest:GrowableContest = null;
         var result:String = null;
         for(contestId in this.m_contests)
         {
            contest = this.m_contests[contestId];
            if(contest.canTakeParticipantItemCode(itemCode))
            {
               result = contestId;
               break;
            }
         }
         return result;
      }
      
      public function getContestForItemCode(itemCode:String) : GrowableContest
      {
         var contest:GrowableContest = null;
         var contestId:String = this.getContestIdForItemCode(itemCode);
         if(contestId != null)
         {
            contest = this.getContest(contestId);
         }
         return contest;
      }
      
      public function getContestIdForBuildingCode(buildingCode:String) : String
      {
         var contestId:String = null;
         var contest:GrowableContest = null;
         var result:String = null;
         if(this.isFeatureEnabled())
         {
            for(contestId in this.m_contests)
            {
               contest = this.m_contests[contestId];
               if(contest.usesBuildingWithId(buildingCode))
               {
                  result = contestId;
                  break;
               }
            }
         }
         return result;
      }
      
      public function getContestForBuildingItemCode(buildingCode:String) : GrowableContest
      {
         var contest:GrowableContest = null;
         var contestId:String = this.getContestIdForBuildingCode(buildingCode);
         if(contestId != null)
         {
            contest = this.getContest(contestId);
         }
         return contest;
      }
      
      public function doPostInit() : void
      {
         var contestId:String = null;
         var contest:GrowableContest = null;
         var tutorial:GrowableContestTutorial = null;
         for(contestId in this.m_contests)
         {
            contest = this.m_contests[contestId];
            tutorial = contest.getTutorial();
            if(tutorial != null && !tutorial.isCompleted())
            {
               contest.getTutorial().updateState();
               break;
            }
         }
      }
   }
}

class SingletonEnforcer
{
   
   public function SingletonEnforcer()
   {
      super();
   }
}
