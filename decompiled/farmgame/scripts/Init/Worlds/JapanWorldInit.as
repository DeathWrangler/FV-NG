package Init.Worlds
{
   import Classes.Constants.Experiments;
   import Classes.Constants.WorldsConstants;
   import Classes.Managers.HUDTutorialManager;
   import Display.HUD.HUDWidgets.HudBottomAchievementButton;
   import Display.UI;
   import Init.PostInitActionHandlers.RightSideHUDIconInitAction;
   import Managers.JournalManager;
   import Managers.RegionAchievementManager;
   import Managers.WorldSeasonsManager;
   import Widgets.Windows.JapanEATutorial;
   import Widgets.Windows.JapanTutorial;
   import flash.events.Event;
   
   public class JapanWorldInit extends HomeWorldInit
   {
      
      public static const ICON_CODE_STARTER_XJP_PP:String = "264";
      
      public static const ICON_CODE_STARTER_XJP_RB:String = "265";
      
      public static const ICON_CODE_STARTER_XJP_ZV:String = "266";
      
      public static const TUTORIAL_FLAG:String = "GlobalftueJapan";
      
      private static const REGION_ACHIEVEMENT_HUD:String = "assets/dialogs/RegionAchievement/FV_xjp_hud_Achievements_2015.swf";
      
      private static const TUTORIAL_HUD:String = "assets/dialogs/RegionAchievement/FV_xjp_hud_Achievements_2015.swf";
      
      private static const REGION_ACHIEVEMENT_FEATURE_NAME:String = "japanRA";
      
      private static const JOURNAL_FEATURE_NAME:String = "quest_journal_japan";
      
      private static const JOURNAL_NOTIFICATION_FLAG:String = "xjp_journal_notification";
      
      private var m_journalManager:JournalManager = null;
      
      public function JapanWorldInit()
      {
         super();
      }
      
      override public function onEnterWorld(resultData:Object) : void
      {
         super.onEnterWorld(resultData);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XJP_PP_STARTER) >= 1)
         {
            Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_STARTER_XJP_PP));
         }
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XJP_RB_STARTER) >= 1)
         {
            Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_STARTER_XJP_RB));
         }
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XJP_ZV_STARTER) >= 1)
         {
            Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_STARTER_XJP_ZV));
         }
         var hudButton:HudBottomAchievementButton = new HudBottomAchievementButton(REGION_ACHIEVEMENT_HUD,REGION_ACHIEVEMENT_FEATURE_NAME);
         Global.hud.setBottomHudAchievementButton(hudButton as HudBottomAchievementButton);
         this.m_journalManager = JournalManager.getInstance(JOURNAL_FEATURE_NAME,JOURNAL_NOTIFICATION_FLAG);
         if(Boolean(this.m_journalManager) && this.m_journalManager.isJournalActive())
         {
            this.m_journalManager.initJournalHUD();
            this.m_journalManager.loadCompletedQuestBubbles();
         }
         HUDTutorialManager.instance.initializeBottomHud(TUTORIAL_FLAG,true);
         this.TriggerGlobalTutorial();
      }
      
      public function TriggerGlobalTutorial(e:Event = null) : void
      {
         if(!Global.player.getSeenFlag(TUTORIAL_FLAG))
         {
            Global.player.setSeenFlag(TUTORIAL_FLAG);
            if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_JAPAN))
            {
               UI.displayPopup(new JapanEATutorial(TUTORIAL_FLAG,"assets/dialogs/Japan/xjp_GlobalFTUE_EA.swf",8,true,false,true,true),false);
               WorldSeasonsManager.getInstance().showGrantMOTDForSeason(m_expansionData.worldId,1);
            }
            else
            {
               UI.displayPopup(new JapanTutorial(TUTORIAL_FLAG,"assets/dialogs/Japan/xjp_GlobalFTUE_GA.swf",7,true,false,true,true),false);
            }
         }
      }
      
      override public function onLeaveWorld(destIsVisiting:Boolean) : void
      {
         super.onLeaveWorld(destIsVisiting);
         if(Global.hud)
         {
            Global.hud.removeBottomHudAchievementButton();
            Global.hud.removeBottomHudJournalButton();
         }
         if(Boolean(this.m_journalManager) && this.m_journalManager.isJournalActive())
         {
            this.m_journalManager.release();
         }
         RegionAchievementManager.getInstance(REGION_ACHIEVEMENT_FEATURE_NAME).release();
         if(HUDTutorialManager.instance)
         {
            HUDTutorialManager.instance.releaseTutorialWidget();
         }
      }
   }
}

