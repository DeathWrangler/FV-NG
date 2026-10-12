package Init.PostInitActionHandlers
{
   import Classes.Constants.QuestConstants;
   import Classes.ZItem.ExpansionAccess;
   import Classes.ZItem.ExpansionData;
   import Classes.util.UserRewardUtil;
   import Managers.WorldSeasonsManager;
   
   public class UnlockWorldsPostInitAction extends AbstractPostInitAction
   {
      
      private static const UNLOCK_WORLDS_RUNTIME_KEY:String = "UNLOCK_WORLDS";
      
      private static const SEEN_FLAG_PREFIX:String = "UNLOCK_WORLDS_";
      
      private var runtimeString:String;
      
      public function UnlockWorldsPostInitAction()
      {
         super();
      }
      
      override public function execute() : void
      {
         var seenFlag:String = null;
         var worlds:Array = null;
         var world:String = null;
         var data:ExpansionData = null;
         var accessInfo:ExpansionAccess = null;
         var rewards:Vector.<Object> = null;
         var worldReward:Object = null;
         this.runtimeString = Global.flashHotParams[UNLOCK_WORLDS_RUNTIME_KEY];
         if(this.runtimeString)
         {
            seenFlag = SEEN_FLAG_PREFIX + this.runtimeString;
            if(!Global.player.getSeenFlag(seenFlag))
            {
               worlds = this.runtimeString.split(",");
               for each(world in worlds)
               {
                  if(!Global.worldManager.hasUnlockedWorld(world) && Global.worldManager.isInExperiment(world))
                  {
                     data = Global.farmGameSettingsManager.getExpansionData(world);
                     if(data)
                     {
                        accessInfo = data.getAccessOfType(ExpansionAccess.TYPE_ALL);
                        if(Boolean(accessInfo) && Boolean(accessInfo.rewards))
                        {
                           rewards = accessInfo.rewards;
                           UserRewardUtil.grantUserRewards(rewards);
                        }
                        else
                        {
                           worldReward = new Object();
                           worldReward.type = QuestConstants.REWARD_UNLOCK_WORLD;
                           worldReward.value = world;
                           UserRewardUtil.grantUserReward(worldReward);
                           if(WorldSeasonsManager.getInstance().getNumSeasonsForWorld(world) > WorldSeasonsManager.SEASON_ONE)
                           {
                              WorldSeasonsManager.getInstance().setSeasonForUser(world,WorldSeasonsManager.SEASON_ONE);
                           }
                        }
                     }
                  }
               }
               Global.player.setSeenFlag(seenFlag);
            }
         }
         m_isFinished = true;
      }
   }
}

