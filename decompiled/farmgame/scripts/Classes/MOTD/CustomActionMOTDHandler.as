package Classes.MOTD
{
   import Classes.CIPStartNow;
   import Classes.Constants.Experiments;
   import Classes.Minigames.MinigameManager;
   import Classes.Quest.FarmQuestManager;
   import Classes.SocialPlumbingMysteryGift;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.SeedItem;
   import Classes.util.ZLocUtils;
   import Display.Dialogs.GenericDialog;
   import Display.GenericPopup;
   import Display.MOTD;
   import Display.MysteryBoxBalloonDialog;
   import Display.UI;
   import Engine.Managers.ErrorManager;
   import GameMode.GMSpecialDeliveryApply;
   import Managers.BeatExpansion.BeatAfricaManager;
   import Managers.BeatExpansion.BeatAlaskaExpansionManager;
   import Managers.BeatExpansion.BeatAtlantisManager;
   import Managers.BeatExpansion.BeatAustraliaManager;
   import Managers.BeatExpansion.BeatAvalonManager;
   import Managers.BeatExpansion.BeatBloomExpansionManager;
   import Managers.BeatExpansion.BeatBoraExpansionManager;
   import Managers.BeatExpansion.BeatCandyManager;
   import Managers.BeatExpansion.BeatCoastalExpansionManager;
   import Managers.BeatExpansion.BeatCocolandExpansionManager;
   import Managers.BeatExpansion.BeatEnchantedGlenManager;
   import Managers.BeatExpansion.BeatFantasyForestManager;
   import Managers.BeatExpansion.BeatHauntedHallowManager;
   import Managers.BeatExpansion.BeatHawaiiManager;
   import Managers.BeatExpansion.BeatHolidayLightsManager;
   import Managers.BeatExpansion.BeatHolidayTownManager;
   import Managers.BeatExpansion.BeatIndiaExpansionManager;
   import Managers.BeatExpansion.BeatIrelandExpansionManager;
   import Managers.BeatExpansion.BeatJadeFallsManager;
   import Managers.BeatExpansion.BeatJungleExpansionManager;
   import Managers.BeatExpansion.BeatKingdomManager;
   import Managers.BeatExpansion.BeatMapleExpansionManager;
   import Managers.BeatExpansion.BeatMediterraneanManager;
   import Managers.BeatExpansion.BeatOasisManager;
   import Managers.BeatExpansion.BeatOzManager;
   import Managers.BeatExpansion.BeatRainForestManager;
   import Managers.BeatExpansion.BeatSecretExpansionManager;
   import Managers.BeatExpansion.BeatSleepyhollowManager;
   import Managers.BeatExpansion.BeatSoireeExpansionManager;
   import Managers.BeatExpansion.BeatSpaceManager;
   import Managers.BeatExpansion.BeatSpookOWeenExpansionManager;
   import Managers.BeatExpansion.BeatStorybookManager;
   import Managers.BeatExpansion.BeatToylandManager;
   import Managers.BeatExpansion.BeatTrailsExpansionManager;
   import Managers.BeatExpansion.BeatTransylvaniaManager;
   import Managers.BeatExpansion.BeatTreasureTidesManager;
   import Managers.BeatExpansion.BeatValleyExpansionManager;
   import Managers.BeatExpansion.BeatWildWestManager;
   import Managers.BeatExpansion.BeatWinterExpansionManager;
   import Managers.BeatExpansion.BeatanglofrenchExpansionManager;
   import Managers.BeatExpansion.BeatbrazilExpansionManager;
   import Managers.BeatExpansion.BeatcaribbeanExpansionManager;
   import Managers.BeatExpansion.BeatcasablancaExpansionManager;
   import Managers.BeatExpansion.BeatdragonvalleyExpansionManager;
   import Managers.BeatExpansion.BeatdreamworldExpansionManager;
   import Managers.BeatExpansion.BeathalloweenmadExpansionManager;
   import Managers.BeatExpansion.BeathalloweenusaExpansionManager;
   import Managers.BeatExpansion.BeatisraelExpansionManager;
   import Managers.BeatExpansion.BeatlimboExpansionManager;
   import Managers.BeatExpansion.BeatmidwestExpansionManager;
   import Managers.BeatExpansion.BeatmountExpansionManager;
   import Managers.BeatExpansion.BeatnewfrontierExpansionManager;
   import Managers.BeatExpansion.BeatrussiaExpansionManager;
   import Managers.BeatExpansion.BeatrussiaExpansion_aManager;
   import Managers.BeatExpansion.BeatsouthindiaExpansionManager;
   import Managers.BeatExpansion.BeatturtleislandExpansionManager;
   import Managers.BeatExpansion.BeattuscanyExpansionManager;
   import Managers.BeatExpansion.BeattwentiesExpansionManager;
   import Managers.BeatExpansion.BeatunderwaterExpansionManager;
   import Managers.BeatExpansion.BeatwhitewinterExpansionManager;
   import Managers.BeatExpansion.BeatwinternordExpansionManager;
   import Managers.BeatExpansion.BeatxmasExpansionManager;
   import Managers.BuyFromFeedsManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureCraftingManager;
   import Managers.LESurfacingManager;
   import Managers.TaskListManager;
   import Widgets.Windows.BuildingSurfaceWindow;
   import Widgets.Windows.Carnival.CarnivalBoothWindow;
   import Widgets.Windows.Charity.DonateWindow;
   import Widgets.Windows.Charity.DonateWindowFactory;
   import Widgets.Windows.FCSlotMachineWindow;
   import Widgets.Windows.IrrigationFTUEWindow;
   import Widgets.Windows.ItemFinderWindow;
   import Widgets.Windows.Lottery.LotteryMainWindow;
   import Widgets.Windows.LowCashBuyMoneyWindow;
   import Widgets.Windows.MOTD.BuyFromFeedsOfferWindow;
   import Widgets.Windows.Market.MarketWindow;
   import Widgets.Windows.Pigo.PigoWindow;
   import Widgets.Windows.PrizeMachine.PrizeMachineWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class CustomActionMOTDHandler extends MOTDHandler
   {
      
      private static var CUSTOM_ACTION_TYPE:String = "customActionType";
      
      private static var CUSTOM_ACTION_PARAMS:String = "customActionParams";
      
      public function CustomActionMOTDHandler(currentMOTD:Object)
      {
         super(currentMOTD);
      }
      
      public static function showTOS(callBack:Function = null) : void
      {
         var tosCallBack:Function = function():void
         {
            Global.player.setFeatureLastShown("tos_pp_update",GlobalEngine.currentTime,true);
            if(callBack !== null)
            {
               callBack();
            }
         };
         var tosMessage:String = ZLocUtils.t("Dialogs","UpdatedTOS");
         var tosPopup:GenericPopup = new GenericPopup(tosMessage,GenericPopup.TYPE_OK,tosCallBack,GenericPopup.GENERIC_ASSET,"",true);
         tosPopup.setAcceptTextName("OkButton");
         UI.displayPopup(tosPopup);
      }
      
      override public function execute() : void
      {
         var customActionType:String = null;
         var customActionFunction:Function = null;
         var actionParams:Object = null;
         if(m_currentMOTD.hasOwnProperty(CUSTOM_ACTION_PARAMS))
         {
            actionParams = m_currentMOTD[CUSTOM_ACTION_PARAMS];
         }
         if(Boolean(actionParams) && actionParams.hasOwnProperty(CUSTOM_ACTION_TYPE))
         {
            customActionType = actionParams[CUSTOM_ACTION_TYPE];
            if(customActionType in this)
            {
               customActionFunction = this[customActionType] as Function;
               if(customActionFunction != null)
               {
                  customActionFunction.apply(null,[actionParams]);
                  ztrack("impressions");
                  Global.player.setSeenSessionFlag(MOTD.SEEN_MOTD_SESSION_FLAG);
               }
               else
               {
                  ErrorManager.addError(customActionType + " is not a function");
               }
            }
            else
            {
               ErrorManager.addError("Invalid MOTD customaction type, " + customActionType + " missing");
            }
         }
         else
         {
            ErrorManager.addError("Missing MOTD customaction type, " + CUSTOM_ACTION_TYPE + " in " + CUSTOM_ACTION_PARAMS + " missing");
         }
         m_isFinished = true;
      }
      
      public function USDMultiDonate(actionParams:Object) : void
      {
         var seedData:SeedItem = null;
         var donateWindow:DisplayObject = null;
         if(actionParams.hasOwnProperty("seedName"))
         {
            seedData = Global.farmGameSettingsManager.getFarmItemByName(actionParams["seedName"]) as SeedItem;
            if(seedData)
            {
               donateWindow = DonateWindowFactory.getInstance(seedData,closeMOTD,DonateWindow.SOURCE_MOTD);
               if(donateWindow != null)
               {
                  UI.displayPopup(donateWindow,false);
               }
            }
            else
            {
               ErrorManager.addError("Invalid seed name for MOTD action type: USDMultiDonate missing");
            }
         }
         else
         {
            ErrorManager.addError("Invalid action params for MOTD");
         }
      }
      
      public function FCMultiDonate(actionParams:Object) : void
      {
         var donateWindow:DisplayObject = null;
         if(actionParams.hasOwnProperty("featureName"))
         {
            donateWindow = DonateWindowFactory.getInstance(null,closeMOTD,DonateWindow.SOURCE_MOTD,actionParams["featureName"]);
            if(donateWindow != null)
            {
               UI.displayPopup(donateWindow,false);
            }
         }
         else
         {
            ErrorManager.addError("Invalid action params for MOTD");
         }
      }
      
      public function breedingPenSurface(actionParams:Object) : void
      {
         var breedingPenItem:FarmItem = null;
         if(actionParams.hasOwnProperty("breedingPenItemName"))
         {
            breedingPenItem = Global.farmGameSettingsManager.getFarmItemByName(actionParams["breedingPenItemName"]);
            if(breedingPenItem != null)
            {
               UI.displayPopup(new BuildingSurfaceWindow(breedingPenItem,null,false,acceptMOTD));
            }
            else
            {
               ErrorManager.addError("Invalid breedingPenItemName specified for MOTD");
            }
         }
         else
         {
            ErrorManager.addError("No breedingPenItem actionParam for MOTD");
         }
      }
      
      public function openMysteryGame(actionParams:Object) : void
      {
         var gameTokenName:String = null;
         if(actionParams.hasOwnProperty("gameTokenName"))
         {
            gameTokenName = actionParams.gameTokenName;
         }
         MysteryBoxBalloonDialog.openDefaultMysteryGame(gameTokenName);
         closeMOTD();
      }
      
      public function openPigoGame(actionParams:Object) : void
      {
         PigoWindow.displayActiveGame("motd",false);
         closeMOTD();
      }
      
      public function openPrizeMachineGame(actionParams:Object) : void
      {
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_PRIZE_MACHINE) >= 3)
         {
            UI.displayPopup(new PrizeMachineWindow(),true,"PrizeMachineWindow",true);
            closeMOTD();
         }
      }
      
      public function openGenericMinigame(actionParams:Object) : void
      {
         var minigameName:String = null;
         if(actionParams.hasOwnProperty("minigameName"))
         {
            minigameName = actionParams["minigameName"];
            if(MinigameManager.instance.launchMinigameWindow(minigameName,"auto_pop"))
            {
               closeMOTD();
            }
            else
            {
               ErrorManager.addError("CustomActionMOTDHandler.as :: openGenericMinigame() error: failed launchMinigameWindow(" + minigameName + ").");
            }
         }
         else
         {
            ErrorManager.addError("CustomActionMOTDHandler.as :: openGenericMinigame() error: customActionParams tag of MOTD\'s xml is missing minigameName tag");
         }
      }
      
      public function openFCSlotMachine(actionParams:Object) : void
      {
         var fcSlotMachineWindow:FCSlotMachineWindow = new FCSlotMachineWindow(FCSlotMachineWindow.ENTRY_POINT_MOTD_AUTOPOP);
         UI.displayPopup(fcSlotMachineWindow,true,FCSlotMachineWindow.WINDOW_NAME,true);
         closeMOTD();
      }
      
      public function openTaskList(actionParams:Object) : void
      {
         TaskListManager.getInstance().openTaskListWindow();
         closeMOTD();
      }
      
      public function openBeatJadeFalls(actionParams:Object) : void
      {
         if(BeatJadeFallsManager.instance.isQuestActive())
         {
            BeatJadeFallsManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatbrazilExpansion(actionParams:Object) : void
      {
         if(BeatbrazilExpansionManager.instance.isQuestActive())
         {
            BeatbrazilExpansionManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeathalloweenusaExpansion(actionParams:Object) : void
      {
         if(BeathalloweenusaExpansionManager.instance.isQuestActive())
         {
            BeathalloweenusaExpansionManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatwhitewinterExpansion(actionParams:Object) : void
      {
         if(BeatwhitewinterExpansionManager.instance.isQuestActive())
         {
            BeatwhitewinterExpansionManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeattuscanyExpansion(actionParams:Object) : void
      {
         if(BeattuscanyExpansionManager.instance.isQuestActive())
         {
            BeattuscanyExpansionManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatdragonvalleyExpansion(actionParams:Object) : void
      {
         if(BeatdragonvalleyExpansionManager.instance.isQuestActive())
         {
            BeatdragonvalleyExpansionManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatcaribbeanExpansion(actionParams:Object) : void
      {
         if(BeatcaribbeanExpansionManager.instance.isQuestActive())
         {
            BeatcaribbeanExpansionManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatrussiaExpansion(actionParams:Object) : void
      {
         if(BeatrussiaExpansionManager.instance.isQuestActive())
         {
            BeatrussiaExpansionManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatrussiaExpansion_a(actionParams:Object) : void
      {
         if(BeatrussiaExpansion_aManager.instance.isQuestActive())
         {
            BeatrussiaExpansion_aManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatnewfrontierExpansion(actionParams:Object) : void
      {
         if(BeatnewfrontierExpansionManager.instance.isQuestActive())
         {
            BeatnewfrontierExpansionManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatisraelExpansion(actionParams:Object) : void
      {
         if(BeatisraelExpansionManager.instance.isQuestActive())
         {
            BeatisraelExpansionManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeathalloweenmadExpansion(actionParams:Object) : void
      {
         if(BeathalloweenmadExpansionManager.instance.isQuestActive())
         {
            BeathalloweenmadExpansionManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatwinternordExpansion(actionParams:Object) : void
      {
         if(BeatwinternordExpansionManager.instance.isQuestActive())
         {
            BeatwinternordExpansionManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatcasablancaExpansion(actionParams:Object) : void
      {
         if(BeatcasablancaExpansionManager.instance.isQuestActive())
         {
            BeatcasablancaExpansionManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatsouthindiaExpansion(actionParams:Object) : void
      {
         if(BeatsouthindiaExpansionManager.instance.isQuestActive())
         {
            BeatsouthindiaExpansionManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeattwentiesExpansion(actionParams:Object) : void
      {
         if(BeattwentiesExpansionManager.instance.isQuestActive())
         {
            BeattwentiesExpansionManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatAlaskaExpansion(actionParams:Object) : void
      {
         if(BeatAlaskaExpansionManager.instance.isQuestActive())
         {
            BeatAlaskaExpansionManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatCocolandExpansion(actionParams:Object) : void
      {
         if(BeatCocolandExpansionManager.instance.isQuestActive())
         {
            BeatCocolandExpansionManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatIrelandExpansion(actionParams:Object) : void
      {
         if(BeatIrelandExpansionManager.instance.isQuestActive())
         {
            BeatIrelandExpansionManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatSpookOWeenExpansion(actionParams:Object) : void
      {
         if(BeatSpookOWeenExpansionManager.instance.isQuestActive())
         {
            BeatSpookOWeenExpansionManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatSecretExpansion(actionParams:Object) : void
      {
         if(BeatSecretExpansionManager.instance.isQuestActive())
         {
            BeatSecretExpansionManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatValleyExpansion(actionParams:Object) : void
      {
         if(BeatValleyExpansionManager.instance.isQuestActive())
         {
            BeatValleyExpansionManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatTrailsExpansion(actionParams:Object) : void
      {
         if(BeatTrailsExpansionManager.instance.isQuestActive())
         {
            BeatTrailsExpansionManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatBoraExpansion(actionParams:Object) : void
      {
         if(BeatBoraExpansionManager.instance.isQuestActive())
         {
            BeatBoraExpansionManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatBloomExpansion(actionParams:Object) : void
      {
         if(BeatBloomExpansionManager.instance.isQuestActive())
         {
            BeatBloomExpansionManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatMapleExpansion(actionParams:Object) : void
      {
         if(BeatMapleExpansionManager.instance.isQuestActive())
         {
            BeatMapleExpansionManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatCoastalExpansion(actionParams:Object) : void
      {
         if(BeatCoastalExpansionManager.instance.isQuestActive())
         {
            BeatCoastalExpansionManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatanglofrenchExpansion(actionParams:Object) : void
      {
         if(BeatanglofrenchExpansionManager.instance.isQuestActive())
         {
            BeatanglofrenchExpansionManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatmountExpansion(actionParams:Object) : void
      {
         if(BeatmountExpansionManager.instance.isQuestActive())
         {
            BeatmountExpansionManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatSoireeExpansion(actionParams:Object) : void
      {
         if(BeatSoireeExpansionManager.instance.isQuestActive())
         {
            BeatSoireeExpansionManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatxmasExpansion(actionParams:Object) : void
      {
         if(BeatxmasExpansionManager.instance.isQuestActive())
         {
            BeatxmasExpansionManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatmidwestExpansion(actionParams:Object) : void
      {
         if(BeatmidwestExpansionManager.instance.isQuestActive())
         {
            BeatmidwestExpansionManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatunderwaterExpansion(actionParams:Object) : void
      {
         if(BeatunderwaterExpansionManager.instance.isQuestActive())
         {
            BeatunderwaterExpansionManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatturtleislandExpansion(actionParams:Object) : void
      {
         if(BeatturtleislandExpansionManager.instance.isQuestActive())
         {
            BeatturtleislandExpansionManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatdreamworldExpansion(actionParams:Object) : void
      {
         if(BeatdreamworldExpansionManager.instance.isQuestActive())
         {
            BeatdreamworldExpansionManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatlimboExpansion(actionParams:Object) : void
      {
         if(BeatlimboExpansionManager.instance.isQuestActive())
         {
            BeatlimboExpansionManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatWinterExpansion(actionParams:Object) : void
      {
         if(BeatWinterExpansionManager.instance.isQuestActive())
         {
            BeatWinterExpansionManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatIndiaExpansion(actionParams:Object) : void
      {
         if(BeatIndiaExpansionManager.instance.isQuestActive())
         {
            BeatIndiaExpansionManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatJungleExpansion(actionParams:Object) : void
      {
         if(BeatJungleExpansionManager.instance.isQuestActive())
         {
            BeatJungleExpansionManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatHauntedHallow(actionParams:Object) : void
      {
         if(BeatHauntedHallowManager.instance.isQuestActive())
         {
            BeatHauntedHallowManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatHolidayTown(actionParams:Object) : void
      {
         if(BeatHolidayTownManager.instance.isQuestActive())
         {
            BeatHolidayTownManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBuyFromFeedsOfferWindow(actionParams:Object) : void
      {
         BuyFromFeedsOfferWindow.show();
         BuyFromFeedsManager.addHucIcon();
      }
      
      public function openBeatEnchantedGlen(actionParams:Object) : void
      {
         if(BeatEnchantedGlenManager.instance.isQuestActive())
         {
            BeatEnchantedGlenManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatAtlantis(actionParams:Object) : void
      {
         if(BeatAtlantisManager.instance.isQuestActive())
         {
            BeatAtlantisManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatAustralia(actionParams:Object) : void
      {
         if(BeatAustraliaManager.instance.isQuestActive())
         {
            BeatAustraliaManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatSpace(actionParams:Object) : void
      {
         if(BeatSpaceManager.instance.isQuestActive())
         {
            BeatSpaceManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatCandy(actionParams:Object) : void
      {
         if(BeatCandyManager.instance.isQuestActive())
         {
            BeatCandyManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatFforest(actionParams:Object) : void
      {
         if(BeatFantasyForestManager.instance.isQuestActive())
         {
            BeatFantasyForestManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatHlights(actionParams:Object) : void
      {
         if(BeatHolidayLightsManager.instance.isQuestActive())
         {
            BeatHolidayLightsManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatRainForest(actionParams:Object) : void
      {
         if(BeatRainForestManager.instance.isQuestActive())
         {
            BeatRainForestManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatOz(actionParams:Object) : void
      {
         if(BeatOzManager.instance.isQuestActive())
         {
            BeatOzManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatMediterranean(actionParams:Object) : void
      {
         if(BeatMediterraneanManager.instance.isQuestActive())
         {
            BeatMediterraneanManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatOasis(actionParams:Object) : void
      {
         if(BeatOasisManager.instance.isQuestActive())
         {
            BeatOasisManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatStorybook(actionParams:Object) : void
      {
         if(BeatStorybookManager.instance.isQuestActive())
         {
            BeatStorybookManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatSleepyhollow(actionParams:Object) : void
      {
         if(BeatSleepyhollowManager.instance.isQuestActive())
         {
            BeatSleepyhollowManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatToyland(actionParams:Object) : void
      {
         if(BeatToylandManager.instance.isQuestActive())
         {
            BeatToylandManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatAvalon(actionParams:Object) : void
      {
         if(BeatAvalonManager.instance.isQuestActive())
         {
            BeatAvalonManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatWildWest(actionParams:Object) : void
      {
         if(BeatWildWestManager.instance.isQuestActive())
         {
            BeatWildWestManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatAfrica(actionParams:Object) : void
      {
         if(BeatAfricaManager.instance.isQuestActive())
         {
            BeatAfricaManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatKingdom(actionParams:Object) : void
      {
         if(BeatKingdomManager.instance.isQuestActive())
         {
            BeatKingdomManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openFeatureCrafting(actionParams:Object) : void
      {
         if(actionParams.hasOwnProperty("craftingsystem"))
         {
            FeatureCraftingManager.instance.showUI(actionParams["craftingsystem"]);
         }
      }
      
      public function openBeatHawaii(actionParams:Object) : void
      {
         if(BeatHawaiiManager.instance.isQuestActive())
         {
            BeatHawaiiManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openSweepstakes(actionParams:Object) : void
      {
         var lotteryWindow:LotteryMainWindow = new LotteryMainWindow();
         UI.displayPopup(lotteryWindow,false,"lotteryMain",true);
         closeMOTD();
      }
      
      public function openMarketplace(actionParams:Object) : void
      {
         UI.displayMarketDialog("MOTD","special");
         closeMOTD();
      }
      
      public function openCarnivalBooth(actionParams:Object) : void
      {
         var gameTokenName:String = null;
         var expVariant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_MINI_GAMES);
         switch(expVariant)
         {
            case 2:
               gameTokenName = null;
               if(actionParams.hasOwnProperty("gameTokenName"))
               {
                  gameTokenName = actionParams.gameTokenName;
               }
               MysteryBoxBalloonDialog.openDefaultMysteryGame(gameTokenName);
               break;
            case 3:
               PigoWindow.displayActiveGame("motd",false);
               break;
            case 4:
               CarnivalBoothWindow.launchCarnivalBooth();
         }
         closeMOTD();
      }
      
      public function openItemFinder(actionParams:Object) : void
      {
         ItemFinderWindow.launchItemFinder();
         closeMOTD();
      }
      
      public function openShowTOS(actionParams:Object) : void
      {
         if(CIPStartNow.canShowTOS())
         {
            showTOS();
            closeMOTD();
         }
      }
      
      public function openLESurfacing(actionParams:Object) : void
      {
         LESurfacingManager.instance.show();
         closeMOTD();
      }
      
      public function pumpQuestCompletionQueue(actionParams:Object) : void
      {
         FarmQuestManager.getInstance().showInitQuestsImmediately = true;
         closeMOTD();
      }
      
      public function openLowCashBuyMoneyWindow(actionParams:Object) : void
      {
         LowCashBuyMoneyWindow.showStatic();
         closeMOTD();
      }
      
      public function openMarketWindowOnRewardCards(actionParams:Object) : void
      {
         UI.displayMarketDialog("unknown","seed",null,"all",null,null,null,null,-1,null,MarketWindow.REWARDS_CARDS_ITEM);
      }
      
      public function openRtueWindow(actionParams:Object) : void
      {
         var dialog:GenericDialog = null;
         FarmStatsManager.count("retention_RTUE","dialog","returnmsg_view");
         dialog = UI.showMessage(ZLocUtils.t("Dialogs","ret_rtue_body"),UI.BUTTON_LAYOUT_OK,ZLocUtils.t("Dialogs","ret_rtue_title"),"assets/dialogs/4d_elements/MOTD/RTUEprizes_MOTD.png",false,function(event:Event):void
         {
            dialog.destroy();
            dialog = null;
            FarmStatsManager.count("retention_RTUE","dialog","returnmsg_click");
            closeMOTD();
            UI.displayGiftBoxWindow();
         });
      }
      
      public function showSdbCursorMode(actionParams:Object) : void
      {
         var dialog:GenericDialog = null;
         dialog = UI.showMessage(ZLocUtils.t("Dialogs","sdbCursorModeMOTDBody"),UI.BUTTON_LAYOUT_OK,ZLocUtils.t("Dialogs","sdbCursorModeMOTDTitle"),"assets/dialogs/4d_elements/MOTD/RTUEprizes_MOTD.png",false,function(event:Event):void
         {
            dialog.destroy();
            dialog = null;
            closeMOTD();
            Global.world.addGameMode(new GMSpecialDeliveryApply(new SocialPlumbingMysteryGift("socialplumbingmysterygift")));
         });
      }
      
      public function showIrrigationFTUEWindow(actionParams:Object) : void
      {
         if(actionParams.hasOwnProperty("windowSwf") && actionParams.hasOwnProperty("itemToPlaceOnAccept"))
         {
            closeMOTD();
            UI.displayPopup(new IrrigationFTUEWindow(actionParams["windowSwf"],actionParams["itemToPlaceOnAccept"]));
         }
      }
      
      public function openBeatTreasureTides(actionParams:Object) : void
      {
         if(BeatTreasureTidesManager.instance.isQuestActive())
         {
            BeatTreasureTidesManager.instance.displayUI();
            closeMOTD();
         }
      }
      
      public function openBeatTransylvania(actionParams:Object) : void
      {
         if(BeatTransylvaniaManager.instance.isQuestActive())
         {
            BeatTransylvaniaManager.instance.displayUI();
            closeMOTD();
         }
      }
   }
}

