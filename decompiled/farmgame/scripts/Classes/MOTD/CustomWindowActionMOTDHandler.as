package Classes.MOTD
{
   import Classes.Constants.Experiments;
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmQuestManager;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.StorageBuilding;
   import Classes.TieredQuestChainMapTrigger;
   import Display.*;
   import Engine.Managers.ErrorManager;
   import Managers.AFInnovationManager;
   import Managers.ActionDrivenManager;
   import Managers.AmsterdamInnovationManager;
   import Managers.BingoManager;
   import Managers.BringBackWinterManager;
   import Managers.ChoiceDrivenManager;
   import Managers.Crafting.CraftingManager;
   import Managers.CraftingBasketDifficultyLevelManager;
   import Managers.DailyCheckInManager;
   import Managers.Dec19InnovationManager;
   import Managers.DecoratorModeManager;
   import Managers.DreamFishPremarketingManager;
   import Managers.FeatureCraftingManager;
   import Managers.FeatureMessagingManager;
   import Managers.FishingV2Manager;
   import Managers.FlowerShackManager;
   import Managers.GuildManager;
   import Managers.IsraelInnovationManager;
   import Managers.ItemFinderManager;
   import Managers.ItemMembershipManager;
   import Managers.JumbleVillaManager;
   import Managers.LandBundleUnlockFeatureManager;
   import Managers.LimboInnovationManager;
   import Managers.MFSRequestManager;
   import Managers.MadagascarInnovationManager;
   import Managers.MapTriggerManager;
   import Managers.MoneyTree2017Manager;
   import Managers.OctoberSidecarFeatureManager;
   import Managers.OrderBoard.CanadaInnovationManager;
   import Managers.OrderBoard.CarribeanInnovationManager;
   import Managers.OrderBoard.CasablancaInnovationManager;
   import Managers.OrderBoard.CocowonderlandInnovationManager;
   import Managers.OrderBoard.DreamWorldInnovationManager;
   import Managers.OrderBoard.FarmRun2018Manager;
   import Managers.OrderBoard.FarmRunV5Manager;
   import Managers.OrderBoard.FarmRunV7Manager;
   import Managers.OrderBoard.FrontierInnovationManager;
   import Managers.OrderBoard.Halloween2019InnovationManager;
   import Managers.OrderBoard.HalloweenInnovationGhoulManager;
   import Managers.OrderBoard.HalloweenInnovationManager;
   import Managers.OrderBoard.IrelandInnovationManager;
   import Managers.OrganicFertilizerHelper;
   import Managers.PetAcademyManager;
   import Managers.PumpkinPartyInnovationManager;
   import Managers.PunchCardFeatureManager;
   import Managers.RussiaInnovationManager;
   import Managers.SheepPatternBreedingManager;
   import Managers.SouthindiaInnovationManager;
   import Managers.StencilManager;
   import Managers.SubscriptionsClickTestManager;
   import Managers.SuperPlotManager;
   import Managers.TimedSlotGiveawaysManager;
   import Managers.TurtleInnovationManager;
   import Managers.TuscanyInnovationManager;
   import Managers.TwentiesInnovationManager;
   import Managers.WhitewinterInnovationManager;
   import Managers.WinterRacingFeatureManager;
   import Managers.WinternordInnovationManager;
   import Managers.WreathFestivalInnovationManager;
   import Managers.XBOPremarketingManager;
   import Widgets.Windows.ActionDrivenRewardsWindow;
   import Widgets.Windows.AvatarEditor.AvatarEditorWindow;
   import Widgets.Windows.GenericQuestWithRewardWindow;
   import Widgets.Windows.GivingBuildingWindow;
   import Widgets.Windows.LoyaltyProgramWindow;
   import Widgets.Windows.MOTDActionRewardWindow;
   import Widgets.Windows.Subscriptions.SubscriptionsMainWindow;
   import Widgets.Windows.UGCFishItemEditorWindow;
   import ZQuest.Classes.Quest;
   import flash.external.ExternalInterface;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.utils.getDefinitionByName;
   
   public class CustomWindowActionMOTDHandler extends CustomWindowMOTDHandler
   {
      
      private static var CUSTOM_ACTION_TYPE:String = "customActionType";
      
      private static var CUSTOM_ACTION_PARAMS:String = "customActionParams";
      
      public function CustomWindowActionMOTDHandler(currentMOTD:Object)
      {
         super(currentMOTD);
      }
      
      override protected function acceptMOTD() : void
      {
         var customActionType:String = null;
         var customActionFunction:Function = null;
         super.acceptMOTD();
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
               }
               else
               {
                  ErrorManager.addError(customActionType + " is not a function");
               }
            }
            else
            {
               ErrorManager.addError("Invalid MOTD customwindowaction type, " + customActionType + " missing");
            }
         }
         else
         {
            ErrorManager.addError("Missing MOTD customwindowaction type, " + CUSTOM_ACTION_TYPE + " in " + CUSTOM_ACTION_PARAMS + " missing");
         }
      }
      
      public function openAFInnovationRedeemWindow(actionParams:Object) : void
      {
         AFInnovationManager.getInstance().openRedeemWindow();
      }
      
      public function openPetAcademyFeature(actionParams:Object) : void
      {
         PetAcademyManager.getInstance().handleHUDClick();
      }
      
      public function openTurtleInnovationFeature(actionParams:Object) : void
      {
         TurtleInnovationManager.getInstance().showMainUI();
      }
      
      public function openMayPremarketingFeature(actionParams:Object) : void
      {
         DreamFishPremarketingManager.instance().showMainUI();
      }
      
      public function openDreamWorldInnovationFeature(actionParams:Object) : void
      {
         var worldType:String = m_currentMOTD["worldType"];
         if(Global.worldManager.currentWorldType != worldType)
         {
            Global.hud.travelNameDisplay.showNewTravelWindow();
         }
         else
         {
            DreamWorldInnovationManager.getInstance("AlaskaInnovation").showMainUI();
         }
      }
      
      public function openCarribeanInnovationFeature(actionParams:Object) : void
      {
         var worldType:String = m_currentMOTD["worldType"];
         if(Global.worldManager.currentWorldType != worldType)
         {
            Global.hud.travelNameDisplay.showNewTravelWindow();
         }
         else
         {
            CarribeanInnovationManager.getInstance("CarribeanInnovation").showMainUI();
         }
      }
      
      public function openFishingFeature(actionParams:Object) : void
      {
         var worldType:String = m_currentMOTD["worldType"];
         if(Global.worldManager.currentWorldType != worldType)
         {
            Global.hud.travelNameDisplay.showNewTravelWindow();
         }
         else
         {
            FishingV2Manager.getInstance().showMainUI();
         }
      }
      
      public function openCasablancaInnovationFeature(actionParams:Object) : void
      {
         var worldType:String = m_currentMOTD["worldType"];
         if(Global.worldManager.currentWorldType != worldType)
         {
            Global.hud.travelNameDisplay.showNewTravelWindow();
         }
         else
         {
            CasablancaInnovationManager.getInstance("CasablancaInnovation").showMainUI();
         }
      }
      
      public function highlightWaterTileForFishing(actionParams:Object) : void
      {
         var tileUnlock:Boolean = false;
         var worldType:String = m_currentMOTD["worldType"];
         if(Global.worldManager.currentWorldType != worldType)
         {
            tileUnlock = PrerequisiteUtility.checkPrereqByName("xcl_rubbletreasure_payer12_unlocked");
            if(!tileUnlock)
            {
               ItemFinderManager.getInstance().highlightWorldItems("xcl_rubbletreasure_payer12");
            }
         }
      }
      
      public function openTuscanyInnovationWindow(actionParams:Object) : void
      {
         TuscanyInnovationManager.getInstance().showMainUI();
      }
      
      public function openFarmRunV4Window(actionParams:Object) : void
      {
         FarmRun2018Manager.getInstance().showMainUI();
      }
      
      public function openFarmRunV6Window(actionParams:Object) : void
      {
         FarmRun2018Manager.getInstance().showMainUI();
      }
      
      public function openFarmRunV7Window(actionParams:Object) : void
      {
         FarmRunV7Manager.getInstance().showMainUI();
      }
      
      public function openFarmRunV8Window(actionParams:Object) : void
      {
         FarmRun2018Manager.getInstance().showMainUI();
      }
      
      public function openFarmRunV9Window(actionParams:Object) : void
      {
         FarmRun2018Manager.getInstance().showMainUI();
      }
      
      public function openFarmRunV10Window(actionParams:Object) : void
      {
         FarmRun2018Manager.getInstance().showMainUI();
      }
      
      public function openRussiaInnovationWindow(actionParams:Object) : void
      {
         RussiaInnovationManager.getInstance().showMainUI();
      }
      
      public function openIsraelInnovationWindow(actionParams:Object) : void
      {
         IsraelInnovationManager.getInstance().showMainUI();
      }
      
      public function openSouthindiaInnovationWindow(actionParams:Object) : void
      {
         SouthindiaInnovationManager.getInstance().showMainUI();
      }
      
      public function openDec19InnovationWindow(actionParams:Object) : void
      {
         var worldType:String = m_currentMOTD["worldType"];
         if(Global.worldManager.currentWorldType != worldType)
         {
            Global.hud.travelNameDisplay.showNewTravelWindow();
         }
         else
         {
            Dec19InnovationManager.getInstance().showMainUI();
         }
      }
      
      public function openIrelandInnovationWindow(actionParams:Object) : void
      {
         IrelandInnovationManager.getInstance("IrelandInnovation").showMainUI();
      }
      
      public function openFarmRunV5InnovationWindow(actionParams:Object) : void
      {
         FarmRunV5Manager.getInstance().showMainUI();
      }
      
      public function openWinternordInnovationWindow(actionParams:Object) : void
      {
         WinternordInnovationManager.getInstance().showMainUI();
      }
      
      public function openTwentiesInnovationWindow(actionParams:Object) : void
      {
         TwentiesInnovationManager.getInstance().showMainUI();
      }
      
      public function openPumpkinPartyInnovationWindow(actionParams:Object) : void
      {
         PumpkinPartyInnovationManager.getInstance().showMainUI();
      }
      
      public function openCocowonderlandInnovationWindow(actionParams:Object) : void
      {
         CocowonderlandInnovationManager.getInstance().showMainUI();
      }
      
      public function openLandBundleUnlockFeatureWindow(actionParams:Object) : void
      {
         LandBundleUnlockFeatureManager.getInstance().showMainWindow();
      }
      
      public function openGuildMainWindow(actionParams:Object) : void
      {
         GuildManager.getInstance().showUI();
      }
      
      public function openHalloweenInnovationGhoulWindow(actionParams:Object) : void
      {
         var worldType:String = m_currentMOTD["worldType"];
         if(Global.worldManager.currentWorldType != worldType)
         {
            Global.hud.travelNameDisplay.showNewTravelWindow();
         }
         else
         {
            HalloweenInnovationGhoulManager.getInstance("HalloweenInnovationGhoul").showMainUI();
         }
      }
      
      public function openHalloweenInnovation2019Window(actionParams:Object) : void
      {
         var worldType:String = m_currentMOTD["worldType"];
         if(Global.worldManager.currentWorldType != worldType)
         {
            Global.hud.travelNameDisplay.showNewTravelWindow();
         }
         else
         {
            Halloween2019InnovationManager.getInstance("Halloween2019Innovation").showMainUI();
         }
      }
      
      public function openCanadaInnovationWindow(actionParams:Object) : void
      {
         var worldType:String = m_currentMOTD["worldType"];
         if(Global.worldManager.currentWorldType != worldType)
         {
            Global.hud.travelNameDisplay.showNewTravelWindow();
         }
         else
         {
            CanadaInnovationManager.getInstance("CanadaInnovation").showMainUI();
         }
      }
      
      public function openWinterRacing2019Window(actionParams:Object) : void
      {
         var worldType:String = m_currentMOTD["worldType"];
         if(Global.worldManager.currentWorldType != worldType)
         {
            Global.hud.travelNameDisplay.showNewTravelWindow();
         }
         else
         {
            WinterRacingFeatureManager.getInstance().showMainWindow();
         }
      }
      
      public function openMadagascarInnovationWindow(actionParams:Object) : void
      {
         var worldType:String = m_currentMOTD["worldType"];
         if(Global.worldManager.currentWorldType != worldType)
         {
            Global.hud.travelNameDisplay.showNewTravelWindow();
         }
         else
         {
            MadagascarInnovationManager.getInstance().showMainUI();
         }
      }
      
      public function openAmsterdamInnovationWindow(actionParams:Object) : void
      {
         var worldType:String = m_currentMOTD["worldType"];
         if(Global.worldManager.currentWorldType != worldType)
         {
            Global.hud.travelNameDisplay.showNewTravelWindow();
         }
         else
         {
            AmsterdamInnovationManager.getInstance().showMainUI();
         }
      }
      
      public function openWreathFestivalInnovationWindow(actionParams:Object) : void
      {
         var worldType:String = m_currentMOTD["worldType"];
         if(Global.worldManager.currentWorldType != worldType)
         {
            Global.hud.travelNameDisplay.showNewTravelWindow();
         }
         else
         {
            WreathFestivalInnovationManager.getInstance().showMainUI();
         }
      }
      
      public function openOctoberSidecarFeatureWindow(actionParams:Object) : void
      {
         var worldType:String = m_currentMOTD["worldType"];
         if(Global.worldManager.currentWorldType != worldType)
         {
            Global.hud.travelNameDisplay.showNewTravelWindow();
         }
         else
         {
            OctoberSidecarFeatureManager.getInstance().showMainWindow();
         }
      }
      
      public function openPunchCardWindow(actionParams:Object) : void
      {
         var worldType:String = m_currentMOTD["worldType"];
         if(Global.worldManager.currentWorldType != worldType)
         {
            Global.hud.travelNameDisplay.showNewTravelWindow();
         }
         else
         {
            PunchCardFeatureManager.getInstance().showMainWindow();
         }
      }
      
      public function openFrontierInnovationWindow(actionParams:Object) : void
      {
         var worldType:String = m_currentMOTD["worldType"];
         if(Global.worldManager.currentWorldType != worldType)
         {
            Global.hud.travelNameDisplay.showNewTravelWindow();
         }
         else
         {
            FrontierInnovationManager.getInstance("FrontierInnovation").showMainUI();
         }
      }
      
      public function openJumbleVillaWindow(actionParams:Object) : void
      {
         var worldType:String = m_currentMOTD["worldType"];
         if(Global.worldManager.currentWorldType != worldType)
         {
            Global.hud.travelNameDisplay.showNewTravelWindow();
         }
         else
         {
            JumbleVillaManager.getInstance("JumbleVilla").showMainWindow();
         }
      }
      
      public function openTropicEscapeMOTDTrailer(actionParams:Object) : void
      {
         var url:String = "https://www.youtube.com/watch?v=eYP3xqY8bIY";
         if(Global.flashHotParams.hasOwnProperty("TROPIC_ESCAPE_TRAILER_LINK") && Boolean(Global.flashHotParams["TROPIC_ESCAPE_TRAILER_LINK"]))
         {
            url = Global.flashHotParams["TROPIC_ESCAPE_TRAILER_LINK"];
         }
         navigateToURL(new URLRequest(url),"_blank");
      }
      
      public function openMoneyTree2017Window(actionParams:Object) : void
      {
         MoneyTree2017Manager.getInstance().showMainUI();
      }
      
      public function openWhitewinterInnovationFeature(actionParams:Object) : void
      {
         var worldType:String = m_currentMOTD["worldType"];
         if(Global.worldManager.currentWorldType != worldType)
         {
            Global.hud.travelNameDisplay.showNewTravelWindow();
         }
         else
         {
            WhitewinterInnovationManager.getInstance("WhitewinterInnovation").showMainUI();
         }
      }
      
      public function openNeighborWindow(actionParams:Object) : void
      {
         MFSRequestManager.openAddNeighborTab();
      }
      
      public function openGiveaway(actionParams:Object) : void
      {
         var giveawayName:String = null;
         if(actionParams.hasOwnProperty("giveaway"))
         {
            giveawayName = actionParams["giveaway"];
            TimedSlotGiveawaysManager.showGiveawayWindow(giveawayName);
         }
      }
      
      public function openSubscriptionsPlanDescPopUp(actionParams:Object) : void
      {
         var experimentName:String = null;
         var variant:int = 0;
         var isSubscriber:Boolean = false;
         var secondPopUp:String = null;
         if(actionParams.hasOwnProperty("experiment"))
         {
            experimentName = actionParams["experiment"];
            variant = Global.experimentManager.getExperimentVariant(experimentName);
            if(actionParams.hasOwnProperty("secondPopUp"))
            {
               isSubscriber = SubscriptionsMainWindow.isSubscriber();
               secondPopUp = actionParams["secondPopUp"];
               SubscriptionsClickTestManager.displaySubscriptionPlanDescPopUp(variant,secondPopUp,isSubscriber);
            }
         }
      }
      
      public function openBuyDialogDailyDrip(actionParams:Object) : void
      {
      }
      
      public function openFeatureCrafting(actionParams:Object) : void
      {
         if(actionParams.hasOwnProperty("craftingsystem"))
         {
            FeatureCraftingManager.instance.showUI(actionParams["craftingsystem"]);
         }
      }
      
      public function displayStorageDialogByClass(actionParams:Object) : void
      {
         var storageBuildingClassName:String = null;
         var storageBuildingClass:Class = null;
         var storageBuildingObjects:Array = null;
         var storageBuilding:StorageBuilding = null;
         if(actionParams.hasOwnProperty("storageBuildingClass"))
         {
            storageBuildingClassName = actionParams["storageBuildingClass"];
            storageBuildingClass = getDefinitionByName(storageBuildingClassName) as Class;
            storageBuildingObjects = Global.world.getObjectsByClass(storageBuildingClass);
            if(storageBuildingObjects[0])
            {
               storageBuilding = storageBuildingObjects[0];
               if(storageBuilding)
               {
                  storageBuilding.displayStorageDialog();
               }
            }
         }
      }
      
      public function handleItemMembershipOnboarding(actionParams:Object) : void
      {
         if(actionParams["featureName"])
         {
            ItemMembershipManager.onboard(actionParams.featureName);
         }
      }
      
      public function openActionDrivenWindow(actionParams:Object) : void
      {
         var worldType:String = m_currentMOTD["worldType"];
         if(Global.worldManager.currentWorldType != worldType)
         {
            Global.hud.travelNameDisplay.showNewTravelWindow();
            ActionDrivenManager.initEventListener();
         }
         else if(actionParams.featureName)
         {
            ActionDrivenManager.onAcceptMOTD(actionParams.featureName);
         }
      }
      
      public function openTravelWindowOrUgcFish(actionParams:Object) : void
      {
         var worldType:String = m_currentMOTD["worldType"];
         if(Global.worldManager.currentWorldType != worldType)
         {
            Global.hud.travelNameDisplay.showNewTravelWindow();
         }
         else
         {
            UI.displayPopup(new UGCFishItemEditorWindow());
         }
      }
      
      public function openTurtleInnovationMOTD(actionParams:Object) : void
      {
         var worldType:String = m_currentMOTD["worldType"];
         if(Global.worldManager.currentWorldType != worldType)
         {
            Global.hud.travelNameDisplay.showNewTravelWindow();
         }
         else
         {
            this.openTurtleInnovationFeature(actionParams);
         }
      }
      
      public function openActionDrivenRewardsWindow(actionParams:Object) : void
      {
         if(actionParams.featureName)
         {
            ActionDrivenRewardsWindow.show(actionParams.featureName);
         }
      }
      
      public function openActionDrivenGrant(actionParams:Object) : void
      {
         if(actionParams.featureName)
         {
            ActionDrivenRewardsWindow.grant(actionParams.featureName);
         }
      }
      
      public function openSheepPenBreedingUI(actionParams:Object) : void
      {
         if(Boolean(actionParams.featureName) && Boolean(actionParams.itemName))
         {
            SheepPatternBreedingManager.openSheepPenBreedingUI(actionParams.itemName);
         }
      }
      
      public function surfaceCraftShop(actionParams:Object) : void
      {
         CraftingManager.surfaceNewCraftShop();
      }
      
      public function openMiniMarket(actionParams:Object) : void
      {
         var itemList:Array = null;
         var checkVisible:Boolean = false;
         var isCharityMiniMarket:Boolean = false;
         var hideCloseButton:Boolean = false;
         var itemName:String = null;
         if(actionParams.hasOwnProperty("itemList"))
         {
            itemList = [];
            if(actionParams["itemList"].item is Array)
            {
               for each(itemName in actionParams["itemList"].item)
               {
                  itemList.push(itemName);
               }
            }
            else
            {
               itemList.push(actionParams["itemList"].item.toString());
            }
            checkVisible = true;
            if(actionParams.hasOwnProperty("checkItemVisibility"))
            {
               if(actionParams["checkItemVisibility"] == "false")
               {
                  checkVisible = false;
               }
            }
            isCharityMiniMarket = false;
            if(actionParams.hasOwnProperty("isCharityMiniMarket"))
            {
               if(actionParams["isCharityMiniMarket"] == "true")
               {
                  isCharityMiniMarket = true;
               }
            }
            hideCloseButton = actionParams.hasOwnProperty("itemList") && actionParams["hideCloseButton"] == "true";
            if(isCharityMiniMarket)
            {
               UI.displayMiniMarketDialog(itemList,UI.MINIMARKET_CONTEXT_CHARITY,"",null,true,false,false,false,"",true);
            }
            else
            {
               UI.displayMiniMarketDialog(itemList,"motd","",null,true,false,hideCloseButton,checkVisible);
            }
         }
      }
      
      public function onboardSuperPlots(actionParams:Object) : void
      {
         SuperPlotManager.startOnboardFlow();
      }
      
      public function openDesignMode(actionParams:Object) : void
      {
         DecoratorModeManager.instance.startDecoMode();
      }
      
      public function openOrganicFertilizer(actionParams:Object) : void
      {
         var freeUse:Boolean = actionParams.hasOwnProperty("freeUse");
         OrganicFertilizerHelper.showMainWindow(freeUse);
      }
      
      public function openCraftingBasket(actionParams:Object) : void
      {
         var featureName:String = actionParams.featureName;
         var craftingBasket:CraftingBasketDifficultyLevelManager = new CraftingBasketDifficultyLevelManager(featureName);
         FeatureMessagingManager.getInstance().registerFeatureInitialized(featureName,craftingBasket.showMainWindow);
         craftingBasket.showMainWindow();
      }
      
      public function openCraftingBasketDifficultylevel(actionParams:Object) : void
      {
         var featureName:String = actionParams.featureName;
         var craftingBasket:CraftingBasketDifficultyLevelManager = new CraftingBasketDifficultyLevelManager(featureName);
         FeatureMessagingManager.getInstance().registerFeatureInitialized(featureName,craftingBasket.showMainWindow);
         craftingBasket.showMainWindow();
      }
      
      public function openActiveQuestFromRecurringChain(actionParams:Object) : void
      {
         var activeQuest:FarmQuest = null;
         var questChain:String = actionParams.featureName;
         var activeQuests:Vector.<Quest> = FarmQuestManager.getInstance().getActiveQuests();
         for each(activeQuest in activeQuests)
         {
            if(activeQuest.chain == questChain)
            {
               GenericQuestWithRewardWindow.showWindow(activeQuest.name);
            }
         }
      }
      
      public function openTieredQuestUI(actionParams:Object) : void
      {
         var mapTriggerName:String = actionParams.mapTriggerName;
         var trigger:TieredQuestChainMapTrigger = MapTriggerManager.getInstance().getMapTriggerByName(mapTriggerName) as TieredQuestChainMapTrigger;
         if(trigger)
         {
            trigger.showUI();
         }
      }
      
      public function openHollyBrightTreeUI(actionParams:Object) : void
      {
         GivingBuildingWindow.openBuildingUI(actionParams.featureName);
      }
      
      public function openStencilMainWindow(actionParams:Object) : void
      {
         StencilManager.instance().showMainUI();
      }
      
      public function openInteractiveDecoUI(actionParams:Object) : void
      {
         LimboInnovationManager.getInstance().showFeatureUI();
      }
      
      public function openMOTDActionRewardWindow(actionParams:Object) : void
      {
         var popup:MOTDActionRewardWindow = new MOTDActionRewardWindow(actionParams["rewardWindowSwf"],actionParams["rewardBundleKey"]);
         UI.displayPopup(popup,false);
      }
      
      public function openBingoWindow(actionParams:Object) : void
      {
         BingoManager.getInstance().displayBingo();
      }
      
      public function grantOneTimeHalloweenBonus(actionParams:Object) : void
      {
         HalloweenInnovationManager.getInstance().grantOneTimeBonus();
      }
      
      public function goToStaticWorld(actionParams:Object) : void
      {
         if(actionParams.hasOwnProperty("world"))
         {
            Global.worldManager.visitStaticFarm(actionParams["world"]);
         }
      }
      
      public function showLoyaltyProgramWindow(actionParams:Object) : void
      {
         closeMOTD();
         UI.displayPopup(new LoyaltyProgramWindow());
      }
      
      public function showMFSAddNeighbor(actionParams:Object) : void
      {
         MFSRequestManager.getInstance().displayR2AddNeighborWindow("FVfriends_coming_soon");
      }
      
      public function dismiss(actionParams:Object) : void
      {
         this.closeMOTD();
      }
      
      public function openUnclaimedFeeds(actionParams:Object) : void
      {
         var url:String = null;
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_UNCLAIMED_FEEDS_OVERLAY) == 2)
         {
            ExternalInterface.call("showUnclaimedFeeds");
         }
         else
         {
            url = "unClaimedRewards.php?ref=motd";
            Global.farmSocialNetwork.redirectTop(url);
         }
      }
      
      public function openAvatarMenu(actionParams:Object) : void
      {
         closeMOTD();
         if(Global.player.avatarState != null && Global.player.avatarState.inventoryInitialized && Global.player.avatar != null)
         {
            UI.displayPopup(new AvatarEditorWindow(Global.player.avatar),false);
         }
      }
      
      public function openDailyCheckInWindow(actionParams:Object) : void
      {
         var featureXML:XML = null;
         var dialogUrl:String = null;
         var featureName:String = "dailycheckin";
         if(!DailyCheckInManager.isInitialized())
         {
            featureXML = Global.farmGameSettingsManager.getFeatureXML(featureName);
            if(featureXML)
            {
               dialogUrl = featureXML.UI.dialog.@path.toString();
               if(dialogUrl)
               {
                  DailyCheckInManager.getInstance().init(featureName,dialogUrl);
               }
            }
         }
         if(DailyCheckInManager.isInitialized())
         {
            DailyCheckInManager.getInstance().openDailyCheckInUI();
         }
      }
      
      public function openBringBackWinterWindow(actionParams:Object) : void
      {
         var featureName:String = null;
         if(actionParams.hasOwnProperty("featureName"))
         {
            featureName = actionParams.featureName;
            FeatureMessagingManager.getInstance().registerFeatureInitialized(featureName,BringBackWinterManager.getInstance(featureName).handleHUDClick);
            BringBackWinterManager.getInstance(featureName).handleHUDClick();
         }
      }
      
      public function openFlowerShackWindow(actionParams:Object) : void
      {
         var featureName:String = null;
         if(actionParams.hasOwnProperty("featureName"))
         {
            featureName = actionParams.featureName;
            if(!FeatureMessagingManager.getInstance().isFeatureInitialized(featureName))
            {
               FeatureMessagingManager.getInstance().registerFeatureInitialized(featureName,FlowerShackManager.getInstance(featureName).showFlowerShackAndOpenWindow);
            }
            FlowerShackManager.getInstance(featureName).showFlowerShackAndOpenWindow();
         }
      }
      
      public function openR4Battle(actionParams:Object) : void
      {
         var featureName:String = null;
         if(actionParams.hasOwnProperty("featureName"))
         {
            featureName = actionParams.featureName;
            if(!FeatureMessagingManager.getInstance().isFeatureInitialized(featureName))
            {
               FeatureMessagingManager.getInstance().registerFeatureInitialized(featureName,ChoiceDrivenManager.getInstance(featureName).showUI);
            }
            ChoiceDrivenManager.getInstance(featureName).showUI();
         }
      }
      
      public function openTravelWindow(actionParams:Object) : void
      {
         var worldType:String = m_currentMOTD["worldType"];
         if(Global.worldManager.currentWorldType != worldType)
         {
            Global.hud.travelNameDisplay.showNewTravelWindow();
         }
      }
      
      public function openPremarketingWindow(actionParams:Object) : void
      {
         if(actionParams.hasOwnProperty("featureName"))
         {
            XBOPremarketingManager.instance(actionParams["featureName"]).showMainUI();
         }
      }
      
      public function openDreamFishPremarketingWindow(actionParams:Object) : void
      {
         if(actionParams.hasOwnProperty("featureName") && Boolean(DreamFishPremarketingManager.instance(actionParams["featureName"])))
         {
            DreamFishPremarketingManager.instance(actionParams["featureName"]).showMainUI();
         }
      }
      
      public function openStencilsWindow(actionParams:Object) : void
      {
         if(actionParams.hasOwnProperty("featureName"))
         {
            StencilManager.instance(actionParams["featureName"]).showMainUI();
         }
      }
   }
}

