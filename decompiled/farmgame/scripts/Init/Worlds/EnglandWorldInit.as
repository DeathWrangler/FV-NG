package Init.Worlds
{
   import Classes.Constants.WorldsConstants;
   import Classes.EnglandOnboardingController;
   import Classes.Idle.ExpansionInviteIdleTask;
   import Classes.Idle.FarmDynamicDialogIdleTask;
   import Classes.Idle.IdleTaskQueue;
   import Classes.util.ZLocUtils;
   import Display.FarmDynamicDialog;
   import Managers.FarmStatsManager;
   import Managers.ToasterManager;
   import Managers.WorldManager;
   import Widgets.Windows.EnglandReactivationToasterWindow;
   import Widgets.Windows.ExpansionInviteWindow;
   import com.troyer.widget.controller.ButtonController;
   import com.troyer.widget.event.WidgetControllerEvent;
   import com.troyer.widget.view.TextFieldView;
   import flash.events.Event;
   
   public class EnglandWorldInit extends HomeWorldInit
   {
      
      public function EnglandWorldInit()
      {
         super();
      }
      
      override public function onEnterWorld(resultData:Object) : void
      {
         super.onEnterWorld(resultData);
         this.addSurveyorPrompt();
         this.attemptGoldenTicketToaster();
         this.addExpansionInvitePrompt();
      }
      
      override protected function trackWorldInit() : void
      {
         var worldType:String = Global.worldManager.currentWorldType;
         var seenFlagName:String = "firstWorldTravel_" + worldType;
         if(worldType != WorldsConstants.WORLD_ID_HOME && Global.player.getSeenFlag(seenFlagName) == false)
         {
            FarmStatsManager.count(EnglandOnboardingController.ENGLAND_ONBOARDING_STATS_COUNTER,"step3_success");
            Global.player.setSeenFlag(seenFlagName);
            Global.player.setSeenFlag("eng_kickoff");
         }
         else
         {
            FarmStatsManager.count(WorldManager.STATS_COUNTER_WORLD_SWITCH,"success",worldType);
         }
      }
      
      private function addSurveyorPrompt() : void
      {
         var seenFlag:String = null;
         var onAskReferences:Function = null;
         var onOptOut:Function = null;
         var dialog:FarmDynamicDialog = null;
         var worldType:String = Global.worldManager.currentWorldType;
         seenFlag = "surveyorPromptSeen_" + worldType;
         if(worldType != WorldsConstants.WORLD_ID_HOME && Global.player.getSeenFlag(seenFlag) == false)
         {
            onAskReferences = function(event:Event):void
            {
               Global.player.setSeenFlag(seenFlag);
               dialog.destroy();
            };
            onOptOut = function(event:Event):void
            {
               Global.player.setSeenFlag(seenFlag);
               dialog.destroy();
            };
            dialog = FarmDynamicDialog.createDialog("SurveyorPrompt",FarmDynamicDialog);
            dialog.setShortcutAttribute("infoText",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","ExpansionFarm_EnterNeighborPrompt",{"world":Global.worldManager.getWorldFriendlyName(worldType)}));
            dialog.setShortcutAttribute("greenButton",ButtonController.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","ExpansionFarm_AskReferences"));
            dialog.setShortcutListener("greenButton",WidgetControllerEvent.BUTTON_PRESSED,onAskReferences);
            dialog.setShortcutAttribute("redButton",ButtonController.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","NotNow"));
            dialog.setShortcutListener("redButton",WidgetControllerEvent.BUTTON_PRESSED,onOptOut);
            IdleTaskQueue.getInstance().addTask(new FarmDynamicDialogIdleTask(dialog,Global.farmGameSettingsManager.getInt("englandReferencePromptDelay",60000)));
         }
      }
      
      private function attemptGoldenTicketToaster() : void
      {
         var gettingHomeInfoSeenFlag:String = null;
         var shouldReallySeeInfoSeenFlag:String = null;
         var arriveByGoldenTicketToaster:EnglandReactivationToasterWindow = null;
         var titleText:String = null;
         var messageText:String = null;
         var bgImagePath:String = null;
         if(Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_ENGLAND)
         {
            if(EnglandOnboardingController.getInstance().isOnDirectToEnglandOnboarding() == true)
            {
               gettingHomeInfoSeenFlag = "england_react_return_home";
               shouldReallySeeInfoSeenFlag = "england_react_show_toaster";
               if(Global.player.getSeenFlag(gettingHomeInfoSeenFlag) == false && Global.player.getSeenFlag(shouldReallySeeInfoSeenFlag) == true)
               {
                  arriveByGoldenTicketToaster = null;
                  titleText = ZLocUtils.t("Dialogs","EnglandOnboardingReactivationArriveToasterTitle");
                  messageText = ZLocUtils.t("Dialogs","EnglandOnboardingReactivationArriveToasterMessage");
                  bgImagePath = "assets/xpromoSupport/Eng_ReactivatorToasterBG.jpg";
                  arriveByGoldenTicketToaster = new EnglandReactivationToasterWindow(messageText,titleText,bgImagePath,true);
                  ToasterManager.getInstance().add(arriveByGoldenTicketToaster);
                  Global.player.setSeenFlag(gettingHomeInfoSeenFlag);
               }
            }
         }
      }
      
      private function addExpansionInvitePrompt() : void
      {
         var worldType:String = Global.worldManager.currentWorldType;
         if(worldType == WorldsConstants.WORLD_ID_ENGLAND && Global.player.getSeenFlag(ExpansionInviteWindow.EXPANSION_INVITE_SEEN_FLAG) == false)
         {
            IdleTaskQueue.getInstance().addTask(new ExpansionInviteIdleTask(worldType));
            FarmStatsManager.count("expansioninvite","idletask","added");
         }
      }
   }
}

