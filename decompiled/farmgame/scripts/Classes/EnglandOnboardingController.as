package Classes
{
   import Classes.Constants.WorldsConstants;
   import Classes.Idle.FarmDynamicDialogIdleTask;
   import Classes.Idle.IdleTaskQueue;
   import Classes.Quest.FarmQuestManager;
   import Classes.util.ZLocUtils;
   import Display.Dialogs.CutsceneDialog;
   import Display.Dialogs.NpcImageInfoDialog;
   import Display.Dialogs.NpcSpeechBubble;
   import Display.Dialogs.NpcSpeechOnboarding;
   import Display.FarmDynamicDialog;
   import Display.HUD.TravelNameDisplay;
   import Engine.Managers.TransactionManager;
   import Events.FarmGameWorldEvent;
   import Managers.FarmStatsManager;
   import Managers.ToasterManager;
   import Transactions.TSawPubDialog;
   import Widgets.Windows.EnglandReactivationToasterWindow;
   import com.troyer.widget.controller.ButtonController;
   import com.troyer.widget.controller.ImageController;
   import com.troyer.widget.event.WidgetControllerEvent;
   import com.troyer.widget.view.BaseWidgetView;
   import com.troyer.widget.view.TextFieldView;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class EnglandOnboardingController
   {
      
      public static const RECAPTURE_ICON_ACTION:String = "EnglandRecapture";
      
      private static const ENGLAND_ONBOARDING_DIALOG_NAME:String = "englandOnboardingPrompt";
      
      private static const ENGLAND_ONBOARDING_NPC_IMAGE_URL:String = "assets/dialogs/4d_elements/Questing/NPC_standing_duke_aviator.png";
      
      private static const TRAVEL_NAME_DISPLAY_ASSET_URL:String = "assets/hud/TravelDropdown_Default.swf";
      
      public static const RECAPTURE_ICON_NAME:String = "EnglandRecaptureIcon";
      
      private static const MIN_LEVEL_TO_GO_TO_ENDLANG:Number = Global.farmGameSettingsManager.getInt("minLevelForEngland",20);
      
      public static const ENGLAND_ONBOARDING_STATS_COUNTER:String = "fvec_onboarding";
      
      private static const LOOK_UP_IN_SKY_QUEST_NAME:String = "englandkickoff-01-001";
      
      private static const ENGLAND_PUB_ITEM_NAME:String = "xukcraftingpub";
      
      public static const PUB_DIALOG_ACTION_COUNT:String = "pubPlacementPrompt";
      
      private static const PUB_DIALOG_SEEN_FLAG:String = "seenPubDialog";
      
      private static const POST_FAST_TRACK_SESSION_COUNTER:String = "postEnglandFastTrackSessionCount";
      
      private static const VISITED_ENGLAND_SEEN_FLAG:String = "visitedWorld_england";
      
      private static const WAS_FAST_TRACKED_SEEN_FLAG:String = "fastTracked_englandsmallbubble-02-001";
      
      private static const POST_FAST_TRACK_VIEW_FREQUENCY:int = 3;
      
      private static const POST_FAST_TRACK_VIEW_MAX:int = 3;
      
      private static const TRAVEL_ARROW_X_OFFSET:Number = 95;
      
      private static const TRAVEL_ARROW_Y_OFFSET:Number = 35;
      
      private static const TRAVEL_ARROW_SCALE_X:Number = 0.9;
      
      private static const TRAVEL_ARROW_SCALE_Y:Number = 1;
      
      private static var m_duplicateNameDisplay:TravelNameDisplay = null;
      
      private static var m_instance:EnglandOnboardingController = null;
      
      private var m_promptDialog:FarmDynamicDialog = null;
      
      private var m_travelArrow:DisplayObject = null;
      
      private var m_declinedFirstOnboarding:Boolean = false;
      
      public function EnglandOnboardingController(enforcer:EocSingletonEnforcer)
      {
         super();
         if(enforcer == null)
         {
            throw "Attempt to create new Instance of EnglandOnboardingController, user EnglandOnboardingController instead";
         }
      }
      
      public static function getInstance() : EnglandOnboardingController
      {
         if(m_instance == null)
         {
            m_instance = new EnglandOnboardingController(new EocSingletonEnforcer());
         }
         return m_instance;
      }
      
      public function startOnboarding() : void
      {
         FarmStatsManager.count(EnglandOnboardingController.ENGLAND_ONBOARDING_STATS_COUNTER,"step1_start","view_first");
         this.m_declinedFirstOnboarding = false;
         this.constructDialog("TravelEnglandOnboardingFirstPrompt",this.onDeclineFirstPrompt);
         this.m_promptDialog.addImport(NpcSpeechOnboarding.CANCEL_BUTTON_TEXT_IMPORT,ZLocUtils.t("Dialogs","TravelEnglandOnboardingFirstPromptDecline"));
         this.m_promptDialog.setup();
         this.m_promptDialog.show(true);
         if(Global.hud.iconQueue.getIconByName(RECAPTURE_ICON_NAME) == null)
         {
            Global.hud.iconQueue.addIcon(RECAPTURE_ICON_NAME);
         }
      }
      
      public function isOnDirectToEnglandOnboarding() : Boolean
      {
         var result:Boolean = false;
         var englandReactExpVariant:int = Global.experimentManager.getExperimentVariant("fv_england_react");
         if(englandReactExpVariant == 2 || englandReactExpVariant == 3)
         {
            result = true;
         }
         return result;
      }
      
      public function isOnSpeedierPathToEnglandOnboarding() : Boolean
      {
         var result:Boolean = false;
         var englandReactExpVariant:int = Global.experimentManager.getExperimentVariant("fv_england_react");
         if(englandReactExpVariant == 4)
         {
            result = true;
         }
         return result;
      }
      
      private function onAcceptTravel(event:WidgetControllerEvent) : void
      {
         var statStringDeclinedFirst:String = this.m_declinedFirstOnboarding ? "prompt2_yes" : "prompt1_yes";
         FarmStatsManager.count(EnglandOnboardingController.ENGLAND_ONBOARDING_STATS_COUNTER,"step2_travel",statStringDeclinedFirst);
         Global.worldManager.swapFarm(WorldsConstants.WORLD_ID_ENGLAND,true);
      }
      
      private function setTravelArrowVisible(visible:Boolean) : void
      {
         if(visible)
         {
            if(!this.m_travelArrow)
            {
               this.m_travelArrow = new EmbeddedArt.bouncing_arrow_new_travel() as DisplayObject;
               this.m_travelArrow.x = TRAVEL_ARROW_X_OFFSET;
               this.m_travelArrow.y = TRAVEL_ARROW_Y_OFFSET;
               this.m_travelArrow.scaleX = TRAVEL_ARROW_SCALE_X;
               this.m_travelArrow.scaleY = TRAVEL_ARROW_SCALE_X;
               m_duplicateNameDisplay.addChild(this.m_travelArrow);
            }
         }
         else if(this.m_travelArrow)
         {
            m_duplicateNameDisplay.removeChild(this.m_travelArrow);
            this.m_travelArrow = null;
         }
      }
      
      private function onDeclineFirstPrompt(event:WidgetControllerEvent) : void
      {
         FarmStatsManager.count(EnglandOnboardingController.ENGLAND_ONBOARDING_STATS_COUNTER,"step1_start","view_second");
         this.m_declinedFirstOnboarding = true;
         this.constructDialog("TravelEnglandOnboardingSecondPrompt",this.onDeclineSecondPromt);
         this.m_promptDialog.addImport(NpcSpeechOnboarding.CANCEL_BUTTON_TEXT_IMPORT,ZLocUtils.t("Dialogs","TravelEnglandOnboardingSecondPromptDecline"));
         this.m_promptDialog.addImport(NpcSpeechOnboarding.INFO_ICON_ASSET_IMPORT,"assets/dialogs/FV_Support/FV_Expansions_Features/EarlyExperience/travelButtonCircled.png");
         this.m_promptDialog.setShortcutAttribute("whatsThis",BaseWidgetView.ATTRIBUTE_OBSTRUCT,false);
         this.m_promptDialog.setShortcutAttribute("whatsThis",BaseWidgetView.ATTRIBUTE_VISIBLE,false);
         this.m_promptDialog.setup();
         this.m_promptDialog.show(true);
      }
      
      private function onDeclineSecondPromt(event:WidgetControllerEvent) : void
      {
         FarmStatsManager.count(EnglandOnboardingController.ENGLAND_ONBOARDING_STATS_COUNTER,"step1_start","cancel_second");
      }
      
      private function constructDialog(locResource:String, cancelCallback:Function = null) : void
      {
         this.m_promptDialog = FarmDynamicDialog.createDialog(ENGLAND_ONBOARDING_DIALOG_NAME,NpcSpeechOnboarding);
         this.m_promptDialog.addImport(NpcSpeechBubble.LOC_RESOURCE_NAME_IMPORT,locResource);
         this.m_promptDialog.addImport(NpcSpeechBubble.NPC_IMAGE_URL_IMPORT,ENGLAND_ONBOARDING_NPC_IMAGE_URL);
         this.m_promptDialog.addImport(NpcSpeechBubble.LOC_BUNDLE_NAME_IMPORT,"Dialogs");
         this.m_promptDialog.addImport(NpcSpeechOnboarding.CANCEL_BUTTON_TEXT_IMPORT,ZLocUtils.t("Dialogs","TravelEnglandOnboardingFirstPromptDecline"));
         this.m_promptDialog.getShortcutController("okButton").addEventListener(WidgetControllerEvent.BUTTON_PRESSED,this.onAcceptTravel);
         if(cancelCallback != null)
         {
            this.m_promptDialog.getShortcutController("cancelButton").addEventListener(WidgetControllerEvent.BUTTON_PRESSED,cancelCallback);
         }
      }
      
      private function cleanupDuplicateNameDisplay(event:FarmGameWorldEvent) : void
      {
         FarmStatsManager.count(EnglandOnboardingController.ENGLAND_ONBOARDING_STATS_COUNTER,"step2_travel","click_drop_down");
         m_duplicateNameDisplay.removeEventListener(FarmGameWorldEvent.WORLD_SWAP,this.cleanupDuplicateNameDisplay);
         Global.stage.removeChild(m_duplicateNameDisplay);
         m_duplicateNameDisplay.release();
         m_duplicateNameDisplay = null;
         GlobalEngine.viewport.setZoom(Global.farmGameSettingsManager.getNumber("englandFirstEnterZoom",0.868));
      }
      
      public function displayPreOnboarding() : void
      {
         var preOnboardingDialog:FarmDynamicDialog = null;
         var shouldAddLookUpInSky:Boolean = false;
         var idleTaskDelay:int = 0;
         var preOnboardingIdleTask:FarmDynamicDialogIdleTask = null;
         if(this.canDisplayPreOnboarding() == true)
         {
            FarmStatsManager.count(EnglandOnboardingController.ENGLAND_ONBOARDING_STATS_COUNTER,"step0_cutsceen","add_idletask");
            preOnboardingDialog = FarmDynamicDialog.createDialog("englandOnboardingKickOff",FarmDynamicDialog);
            preOnboardingDialog.setShortcutAttribute("mainText",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","EnglandDukeCrashingText"));
            preOnboardingDialog.setShortcutAttribute("okayButton",ButtonController.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","EnglandDukeCrashingButtonText"));
            shouldAddLookUpInSky = true;
            if(Global.worldManager.hasUnlockedWorld(WorldsConstants.WORLD_ID_ENGLAND) == true)
            {
               preOnboardingDialog.getShortcutController("okayButton").listen(WidgetControllerEvent.BUTTON_PRESSED,this.onViewOnboardingReactivation);
            }
            else
            {
               preOnboardingDialog.getShortcutController("okayButton").listen(WidgetControllerEvent.BUTTON_PRESSED,this.onViewPreOnboarding);
               if(FarmQuestManager.getInstance().isQuestActive(LOOK_UP_IN_SKY_QUEST_NAME) == false)
               {
                  shouldAddLookUpInSky = false;
               }
            }
            if(this.isOnSpeedierPathToEnglandOnboarding() == true)
            {
               this.doShortestOnboarding();
               Global.player.setSeenFlag("eng_kickoff");
            }
            else
            {
               preOnboardingDialog.setup();
               if(shouldAddLookUpInSky == true)
               {
                  idleTaskDelay = Global.farmGameSettingsManager.getInt("englandPreOnboardingDelay",60000);
                  preOnboardingIdleTask = new FarmDynamicDialogIdleTask(preOnboardingDialog,idleTaskDelay,this.onPreOnboardingDialogShown);
                  IdleTaskQueue.getInstance().addTask(preOnboardingIdleTask);
               }
            }
         }
      }
      
      public function canDisplayPreOnboarding() : Boolean
      {
         var result:Boolean = false;
         var isHighEnoughLevel:Boolean = Global.player.level >= MIN_LEVEL_TO_GO_TO_ENDLANG;
         var hasNotBeenOnboarded:Boolean = Global.player.getSeenFlag("eng_kickoff") == false;
         if(isHighEnoughLevel && hasNotBeenOnboarded && Global.worldManager.isInExperiment(WorldsConstants.WORLD_ID_ENGLAND))
         {
            result = true;
         }
         return result;
      }
      
      public function supressPopups() : Boolean
      {
         var supressPopups:Boolean = false;
         var canPreOnboard:Boolean = this.canDisplayPreOnboarding();
         var canSeeOnboardToaster:Boolean = Global.player.getSeenFlag("england_react_show_toaster");
         var isOnDirectEngland:Boolean = EnglandOnboardingController.getInstance().isOnDirectToEnglandOnboarding();
         if(!Global.player.getSeenFlag("eng_onboardSupressPopups") && (canPreOnboard || isOnDirectEngland && canSeeOnboardToaster))
         {
            supressPopups = true;
         }
         Global.player.setSeenFlag("eng_onboardSupressPopups");
         return supressPopups;
      }
      
      private function onViewOnboardingReactivation(event:WidgetControllerEvent) : void
      {
         Global.player.setSeenFlag("eng_kickoff");
         if(Global.hud.iconQueue.getIconByName(RECAPTURE_ICON_NAME) == null)
         {
            Global.hud.iconQueue.addIcon(RECAPTURE_ICON_NAME);
         }
         var dialog:FarmDynamicDialog = null;
         dialog = FarmDynamicDialog.createDialog("cutscene",CutsceneDialog);
         dialog.addImport(CutsceneDialog.CUTSCENE_IMPORT,"assets/dialogs/FV_cutscene_dukeCrash_noHoles.swf");
         dialog.setShortcutAttribute("button",ButtonController.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","Skip"));
         dialog.setup();
         dialog.show(true);
         this.doShortestOnboarding();
      }
      
      private function doShortestOnboarding() : void
      {
         var callback:Function;
         var arriveByGoldenTicketToaster:EnglandReactivationToasterWindow;
         var titleText:String;
         var messageText:String;
         var bgImagePath:String;
         var dialog:FarmDynamicDialog = null;
         dialog = FarmDynamicDialog.createDialog("npcSpeechBubble",NpcSpeechBubble);
         dialog.addImport(NpcSpeechBubble.LOC_BUNDLE_NAME_IMPORT,"Dialogs");
         dialog.addImport(NpcSpeechBubble.LOC_RESOURCE_NAME_IMPORT,"EnglandOnboardingReactivationSpeech");
         dialog.addImport(NpcSpeechBubble.BUTTON_TEXT_LOC_KEY_IMPORT,"EnglandOnboardingReactivationSpeech_button");
         dialog.addImport(NpcSpeechBubble.NPC_IMAGE_URL_IMPORT,"assets/dialogs/4d_elements/Questing/NPC_standing_duke_aviator.png");
         dialog.setup();
         dialog.show(true);
         dialog = FarmDynamicDialog.createDialog("englandSellPostcard",NpcImageInfoDialog);
         dialog.addImport(NpcImageInfoDialog.BUTTON_TEXT_IMPORT,ZLocUtils.t("Dialogs","EnglandOnboardingReactivationSellButtonText"));
         dialog.addImport(NpcImageInfoDialog.IMAGE_ASSET_IMPORT,"assets/dialogs/FV_Support/FV_Expansions_Features/SellScreens/expansions_mainSell.png");
         dialog.addImport(NpcImageInfoDialog.NPC_ASSET_IMPORT,"assets/dialogs/4d_elements/Questing/NPC_circle_duke_aviator.png");
         dialog.addImport(NpcImageInfoDialog.SPEECH_TEXT_IMPORT,ZLocUtils.t("Dialogs","EnglandOnboardingReactivationSellSpeechText"));
         dialog.setShortcutAttribute("titleText",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Quests","england_sell_postcardTitle"));
         callback = function(event:WidgetControllerEvent):void
         {
            startOnboarding();
         };
         dialog.addImport(NpcImageInfoDialog.CALLBACK_IMPORT,callback);
         dialog.setup();
         dialog.show(true);
         arriveByGoldenTicketToaster = null;
         titleText = ZLocUtils.t("Dialogs","EnglandOnboardingReactivationHomeToasterTitle");
         messageText = ZLocUtils.t("Dialogs","EnglandOnboardingReactivationHomeToasterMessage");
         bgImagePath = "assets/xpromoSupport/Eng_ReactivatorToasterBG.jpg";
         arriveByGoldenTicketToaster = new EnglandReactivationToasterWindow(messageText,titleText,bgImagePath);
         ToasterManager.getInstance().add(arriveByGoldenTicketToaster);
      }
      
      private function onViewPreOnboarding(event:WidgetControllerEvent) : void
      {
         FarmStatsManager.count(EnglandOnboardingController.ENGLAND_ONBOARDING_STATS_COUNTER,"step0_cutsceen","accept_cutsceen");
         Global.player.setSeenFlag("eng_kickoff");
      }
      
      private function onPreOnboardingDialogShown() : void
      {
         FarmStatsManager.count(EnglandOnboardingController.ENGLAND_ONBOARDING_STATS_COUNTER,"step0_cutsceen","dialog_shown");
      }
      
      public function showForcePlacementDialog() : void
      {
         var worldType:String = null;
         var giftItemsInWorld:Array = null;
         var onPlacementMode:Function = null;
         var dialog:FarmDynamicDialog = null;
         worldType = Global.worldManager.currentWorldType;
         if(Global.player.getActionCount(PUB_DIALOG_ACTION_COUNT) >= 1 && !Global.player.getSeenFlag(PUB_DIALOG_SEEN_FLAG))
         {
            if(worldType == WorldsConstants.WORLD_ID_ENGLAND)
            {
               giftItemsInWorld = Global.world.getObjectsByNames([ENGLAND_PUB_ITEM_NAME]);
               if(giftItemsInWorld.length == 0)
               {
                  onPlacementMode = function(event:Event):void
                  {
                     dialog.destroy();
                     TransactionManager.addTransaction(new TSawPubDialog(worldType,ENGLAND_PUB_ITEM_NAME),true);
                  };
                  dialog = FarmDynamicDialog.createDialog("FastTrack",FarmDynamicDialog);
                  dialog.setShortcutAttribute("FastTrackTitleText",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","PubPlacementDialogTitle"));
                  dialog.setShortcutAttribute("FastTrackImage",ImageController.ATTRIBUTE_SOURCE,"assets/dialogs/FV_Support/FV_Expansions_Features/EarlyExperience/fastTrack_PubSell.jpg");
                  dialog.setShortcutAttribute("FastTrackBodyText",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","PubPlacementDialogBody"));
                  dialog.setShortcutAttribute("OkButton",ButtonController.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","PubPlacementDialogButton"));
                  dialog.setShortcutListener("OkButton",WidgetControllerEvent.BUTTON_PRESSED,onPlacementMode);
                  dialog.setShortcutAttribute("CancelButton",BaseWidgetView.ATTRIBUTE_VISIBLE,false);
                  dialog.setShortcutAttribute("CancelButton",BaseWidgetView.ATTRIBUTE_OBSTRUCT,false);
                  IdleTaskQueue.getInstance().addTask(new FarmDynamicDialogIdleTask(dialog,Global.farmGameSettingsManager.getInt("englandPubPrompt",120000)));
               }
            }
         }
         else if(!Global.player.getSeenFlag(PUB_DIALOG_SEEN_FLAG) && worldType == WorldsConstants.WORLD_ID_ENGLAND)
         {
            Global.player.incrementActionCount(PUB_DIALOG_ACTION_COUNT,true);
         }
      }
      
      public function shouldShowQuestFastTrackDialog() : Boolean
      {
         var dialogSessionFrequency:int = 0;
         var dialogViewMax:int = 0;
         var playerPostFastTrackSessionCount:int = 0;
         var shouldShowDialog:Boolean = false;
         if(Global.player.getSeenFlag(VISITED_ENGLAND_SEEN_FLAG) == false)
         {
            if(Global.player.getSeenFlag(WAS_FAST_TRACKED_SEEN_FLAG) == true)
            {
               dialogSessionFrequency = POST_FAST_TRACK_VIEW_FREQUENCY;
               dialogViewMax = POST_FAST_TRACK_VIEW_MAX;
               playerPostFastTrackSessionCount = Global.player.getActionCount(POST_FAST_TRACK_SESSION_COUNTER);
               if(playerPostFastTrackSessionCount < dialogSessionFrequency * dialogViewMax)
               {
                  if(playerPostFastTrackSessionCount % dialogSessionFrequency == 0)
                  {
                     shouldShowDialog = true;
                  }
                  Global.player.incrementActionCount(POST_FAST_TRACK_SESSION_COUNTER);
               }
            }
         }
         return shouldShowDialog;
      }
   }
}

class EocSingletonEnforcer
{
   
   public function EocSingletonEnforcer()
   {
      super();
   }
}
