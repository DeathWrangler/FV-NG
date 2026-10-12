package Managers
{
   import Classes.Constants.Experiments;
   import Classes.Constants.ZLocConstants;
   import Classes.Idle.GenericToasterIdleTask;
   import Classes.Idle.IdleTaskQueue;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Widgets.Windows.SimpleToasterWindow;
   
   public class CommunityMatchmakingUtility
   {
      
      public static const COMMUNITY_MATCHMAKING_V3_ADD_NEIGHBOR_SWF:String = "assets/dialogs/FV_CommunityNeighbors_v1.swf";
      
      public static const DEBUG_MAX_NEIGHBOR_OVERRIDE_RUNTIME_KEY:String = "DEBUG_MAX_NEIGHBOR_OVERRIDE";
      
      private static const MIN_NUM_PLAYED_DAYS_AGO_FOR_INACTIVE_USER_RUNTIME_KEY:String = "MIN_NUM_PLAYED_DAYS_AGO_FOR_INACTIVE_USER";
      
      public static const MAX_NUM_NEIGHBORS:int = 300;
      
      public static const MAX_NEIGHBORS_CONFIG_KEY:String = "maxNeighbors";
      
      public static const DEFAULT_MIN_NUM_PLAYED_DAYS_AGO_FOR_INACTIVE_USER:int = 90;
      
      public static const FEATURE_NAME:String = "community_matchmaking_v3";
      
      public static const FEATURE_OPTION_KEY_OPT_IN:String = "opted_in";
      
      private static const SURFACING_PREREQ_NAME:String = "community_matchmaking_v3_surfacing";
      
      private static var s_communityMatchmakingV3Variant:int = -1;
      
      private static var s_minNumPlayedDaysAgoForInactiveUser:int = -1;
      
      public function CommunityMatchmakingUtility()
      {
         super();
      }
      
      public static function isInCommunityMatchmakingV3Experiment() : Boolean
      {
         if(s_communityMatchmakingV3Variant == -1)
         {
            s_communityMatchmakingV3Variant = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_COMMUNITY_MATCHMAKING_V3);
         }
         return s_communityMatchmakingV3Variant >= Experiments.VARIANT_COMMUNITY_MATCHMAKING_V3_VALID_VARIANT_START;
      }
      
      public static function conditionallyAddNeighborToasterIdleTask() : void
      {
         var message:String = null;
         var assetPath:String = null;
         var ttl:int = 0;
         var title:String = null;
         var toaster:SimpleToasterWindow = null;
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_COMMUNITY_NEIGHBORS_TOASTER) >= 1 && PrerequisiteUtility.checkPrereqByName(SURFACING_PREREQ_NAME) && Global.player.canShowFeatureWithFeatureFrequencyInSeconds(FEATURE_NAME,FarmGameUtil.NUM_SECS_IN_WEEK))
         {
            message = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"simpleToasterBody_community_matchmaking_v3");
            assetPath = "assets/dialogs/FV_CommunityNeighbors_toaster.swf";
            ttl = 5000;
            title = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"simpleToasterTitle_community_matchmaking_v3");
            toaster = new SimpleToasterWindow(FEATURE_NAME,message,assetPath,FarmGameUtil.applyPartialStatic(MFSRequestManager.openAddNeighborTab,[true]),ttl,title);
            IdleTaskQueue.getInstance().addTask(new GenericToasterIdleTask(toaster));
         }
      }
      
      public static function getDebugMaxNeighborLimit(currentMax:int) : Number
      {
         var debugMax:Number = NaN;
         var result:int = currentMax;
         if(Config.DEBUG_MODE && Boolean(Global.flashHotParams[DEBUG_MAX_NEIGHBOR_OVERRIDE_RUNTIME_KEY]))
         {
            debugMax = parseInt(Global.flashHotParams[DEBUG_MAX_NEIGHBOR_OVERRIDE_RUNTIME_KEY]);
            if(!isNaN(debugMax))
            {
               result = debugMax;
            }
         }
         return result;
      }
      
      public static function getMinNumPlayedDaysAgoForInactiveUser() : int
      {
         var minNum:Number = NaN;
         if(s_minNumPlayedDaysAgoForInactiveUser == -1)
         {
            minNum = parseInt(Global.flashHotParams[MIN_NUM_PLAYED_DAYS_AGO_FOR_INACTIVE_USER_RUNTIME_KEY]);
            if(!isNaN(minNum))
            {
               s_minNumPlayedDaysAgoForInactiveUser = minNum;
            }
            else
            {
               s_minNumPlayedDaysAgoForInactiveUser = DEFAULT_MIN_NUM_PLAYED_DAYS_AGO_FOR_INACTIVE_USER;
            }
         }
         return s_minNumPlayedDaysAgoForInactiveUser;
      }
      
      public static function isInactiveUser(datum:Object) : Boolean
      {
         return Boolean(datum) && (!datum.played_days_ago || datum.played_days_ago >= getMinNumPlayedDaysAgoForInactiveUser());
      }
   }
}

