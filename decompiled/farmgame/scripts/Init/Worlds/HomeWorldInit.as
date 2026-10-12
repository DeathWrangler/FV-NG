package Init.Worlds
{
   import Classes.Constants.Experiments;
   import Classes.Constants.WorldsConstants;
   import Classes.EnglandOnboardingController;
   import Classes.Idle.IdleTaskQueue;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.VisitorManager;
   import Classes.XmlDrivenAction;
   import Classes.util.WheatherEffectOnWorld;
   import Classes.util.WorldIdUtil;
   import Classes.util.ZLocFailoverEntry;
   import Classes.util.ZLocUtils;
   import Display.ActionMultiButton;
   import Display.HUD.HUD;
   import Display.HUD.HUDSkin;
   import Display.HUD.HUDSkinConfig;
   import Display.HUD.HUDWidgets.HudRoyaltyLoyaltyButton;
   import Engine.Managers.LoadingManager;
   import Events.FarmGameWorldEvent;
   import Managers.AnimalSanctuaryV2Manager;
   import Managers.FeatureOptionsManager;
   import Managers.GuildManager;
   import Managers.MessageManager;
   import Managers.SocialActionsManager;
   import Managers.WorldManager;
   import Managers.WorldStatManager;
   import flash.display.Loader;
   import flash.events.Event;
   
   public class HomeWorldInit extends BaseWorldInit
   {
      
      private static const ROYALTY_LOYALTY_PROGRAM:String = "RoyaltyLoyaltyProgram";
      
      public static const ROYALTY_PROGRAM_HUDSHOW_OPTION:String = "RoyaltyLoyaltyHud";
      
      private static const ROYALTY_LOYALTY_HUD:String = "assets/hud/hud_icon_queue/hud_RoyaltyLoyaltyClub2016.swf";
      
      public static const ZRUNTIME_GUILD_CONTROL_RUNTIME:String = "GUILD_CONTROL_V1_RUNTIME";
      
      public function HomeWorldInit()
      {
         super();
      }
      
      public static function createWorldInitByWorldType(worldType:String) : HomeWorldInit
      {
         var result:HomeWorldInit = null;
         switch(worldType)
         {
            case WorldsConstants.WORLD_ID_ENGLAND:
               result = new EnglandWorldInit();
               break;
            case WorldsConstants.WORLD_ID_HAWAII:
               result = new HawaiiWorldInit();
               break;
            case WorldsConstants.WORLD_ID_ASIA:
               result = new AsiaWorldInit();
               break;
            case WorldsConstants.WORLD_ID_ANGLER:
               result = new StaticWorldInit();
               break;
            case WorldsConstants.WORLD_ID_HALLOW:
               result = new HallowWorldInit();
               break;
            case WorldsConstants.WORLD_ID_HTOWN:
               result = new HtownWorldInit();
               break;
            case WorldsConstants.WORLD_ID_MEADOWS:
               result = new MeadowsWorldInit();
               break;
            case WorldsConstants.WORLD_ID_GLEN:
               result = new GlenWorldInit();
               break;
            case WorldsConstants.WORLD_ID_ATLANTIS:
               result = new AtlantisWorldInit();
               break;
            case WorldsConstants.WORLD_ID_AUSTRALIA:
               result = new AustraliaWorldInit();
               break;
            case WorldsConstants.WORLD_ID_SPACE:
               result = new SpaceWorldInit();
               break;
            case WorldsConstants.WORLD_ID_GARDEN:
               result = new GardenWorldInit();
               break;
            case WorldsConstants.WORLD_ID_CANDY:
               result = new CandyWorldInit();
               break;
            case WorldsConstants.WORLD_ID_FFOREST:
               result = new FforestWorldInit();
               break;
            case WorldsConstants.WORLD_ID_HLIGHTS:
               result = new HlightsWorldInit();
               break;
            case WorldsConstants.WORLD_ID_RAINFOREST:
               result = new RainForestWorldInit();
               break;
            case WorldsConstants.WORLD_ID_OZ:
               result = new OzWorldInit();
               break;
            case WorldsConstants.WORLD_ID_VILLAGE:
               result = new VillageWorldInit();
               break;
            case WorldsConstants.WORLD_ID_MEDITERRANEAN:
               result = new MediterraneanWorldInit();
               break;
            case WorldsConstants.WORLD_ID_OASIS:
               result = new OasisWorldInit();
               break;
            case WorldsConstants.WORLD_ID_STORYBOOK:
               result = new StorybookWorldInit();
               break;
            case WorldsConstants.WORLD_ID_SLEEPYHOLLOW:
               result = new SleepyhollowWorldInit();
               break;
            case WorldsConstants.WORLD_ID_TOYLAND:
               result = new ToylandWorldInit();
               break;
            case WorldsConstants.WORLD_ID_AVALON:
               result = new AvalonWorldInit();
               break;
            case WorldsConstants.WORLD_ID_WILDWEST:
               result = new WildwestWorldInit();
               break;
            case WorldsConstants.WORLD_ID_TREASURETIDES:
               result = new TreasuretidesWorldInit();
               break;
            case WorldsConstants.WORLD_ID_AFRICA:
               result = new AfricaWorldInit();
               break;
            case WorldsConstants.WORLD_ID_TRANSYLVANIA:
               result = new TransylvaniaWorldInit();
               break;
            case WorldsConstants.WORLD_ID_WINTER:
               result = new WinterWorldInit();
               break;
            case WorldsConstants.WORLD_ID_JAPAN:
               result = new JapanWorldInit();
               break;
            case WorldsConstants.WORLD_ID_INDIA:
               result = new IndiaWorldInit();
               break;
            case WorldsConstants.WORLD_ID_JUNGLE:
               result = new JungleWorldInit();
               break;
            case WorldsConstants.WORLD_ID_MOUNT:
               result = new MountWorldInit();
               break;
            case WorldsConstants.WORLD_ID_LIMBO:
               result = new LimboWorldInit();
               break;
            case WorldsConstants.WORLD_ID_XMAS:
               result = new XmasWorldInit();
               break;
            case WorldsConstants.WORLD_ID_TURTLEISLAND:
               result = new TurtleislandWorldInit();
               break;
            case WorldsConstants.WORLD_ID_MIDWEST:
               result = new MidwestWorldInit();
               break;
            case WorldsConstants.WORLD_ID_UNDERWATER:
               result = new UnderwaterWorldInit();
               break;
            case WorldsConstants.WORLD_ID_DREAMWORLD:
               result = new DreamworldWorldInit();
               break;
            case WorldsConstants.WORLD_ID_ANGLOFRENCH:
               result = new AnglofrenchWorldInit();
               break;
            case WorldsConstants.WORLD_ID_HALLOWEENUSA:
               result = new HalloweenusaWorldInit();
               break;
            case WorldsConstants.WORLD_ID_BRAZIL:
               result = new BrazilWorldInit();
               break;
            case WorldsConstants.WORLD_ID_TUSCANY:
               result = new TuscanyWorldInit();
               break;
            case WorldsConstants.WORLD_ID_WHITEWINTER:
               result = new WhitewinterWorldInit();
               break;
            case WorldsConstants.WORLD_ID_CARIBBEAN:
               result = new CaribbeanWorldInit();
               break;
            case WorldsConstants.WORLD_ID_DRAGONVALLEY:
               result = new DragonvalleyWorldInit();
               break;
            case WorldsConstants.WORLD_ID_RUSSIA:
               result = new RussiaWorldInit();
               break;
            case WorldsConstants.WORLD_ID_ISRAEL:
               result = new IsraelWorldInit();
               break;
            case WorldsConstants.WORLD_ID_NEWFRONTIER:
               result = new NewfrontierWorldInit();
               break;
            case WorldsConstants.WORLD_ID_HALLOWEENMAD:
               result = new HalloweenmadWorldInit();
               break;
            case WorldsConstants.WORLD_ID_WINTERNORD:
               result = new WinternordWorldInit();
               break;
            case WorldsConstants.WORLD_ID_CASABLANCA:
               result = new CasablancaWorldInit();
               break;
            case WorldsConstants.WORLD_ID_TWENTIES:
               result = new TwentiesWorldInit();
               break;
            case WorldsConstants.WORLD_ID_SOUTHINDIA:
               result = new SouthindiaWorldInit();
               break;
            case WorldsConstants.WORLD_ID_ALASKA:
               result = new AlaskaWorldInit();
               break;
            case WorldsConstants.WORLD_ID_COCOLAND:
               result = new CocolandWorldInit();
               break;
            case WorldsConstants.WORLD_ID_IRELAND:
               result = new IrelandWorldInit();
               break;
            case WorldsConstants.WORLD_ID_SANTAVILLAGE:
               result = new SantavillageWorldInit();
               break;
            case WorldsConstants.WORLD_ID_BORABORA:
               result = new BoraboraWorldInit();
               break;
            case WorldsConstants.WORLD_ID_CANADA:
               result = new CanadaWorldInit();
               break;
            case WorldsConstants.WORLD_ID_SPOOKY:
               result = new SpookyWorldInit();
               break;
            case WorldsConstants.WORLD_ID_FARMFEST:
               result = new FarmfestWorldInit();
               break;
            case WorldsConstants.WORLD_ID_MADAGASCAR:
               result = new MadagascarWorldInit();
               break;
            case WorldsConstants.WORLD_ID_AMSTERDAM:
               result = new AmsterdamWorldInit();
               break;
            case WorldsConstants.WORLD_ID_PUMPKIN:
               result = new PumpkinWorldInit();
               break;
            case WorldsConstants.WORLD_ID_ALOHA:
               result = new AlohaWorldInit();
               break;
            case WorldsConstants.WORLD_ID_YULETIDE:
               result = new YuletideWorldInit();
               break;
            default:
               result = new HomeWorldInit();
         }
         return result;
      }
      
      override public function resyncToBackendData(resultData:Object) : void
      {
         var visitorManager:VisitorManager = null;
         if(Boolean(resultData.world) && Boolean(resultData.world.messageManager))
         {
            MessageManager.getInstance().loadObject(resultData.world.messageManager);
         }
         if(Boolean(resultData.user) && Boolean(resultData.user.socialActionsManager))
         {
            SocialActionsManager.getInstance().loadObject(resultData.user.socialActionsManager);
         }
         var playerData:Object = null;
         if(Boolean(resultData["user"]) && Boolean(resultData.user["player"]))
         {
            playerData = resultData.user.player;
         }
         else if(Boolean(resultData["userInfo"]) && Boolean(resultData.userInfo["player"]))
         {
            playerData = resultData.userInfo.player;
         }
         if(playerData)
         {
            if(playerData.storageData)
            {
               Global.player.storageData = playerData.storageData;
               Global.player.loadInventoryFromStorageData(playerData.storageData);
               Global.player.clearCraftingState();
               Global.player.craftingState.loadCraftedGoodsFromInitUser(playerData.storageData);
               Global.player.craftingState.loadBushelBabiesCraftItemsFromInitUser(playerData.storageData);
               if(resultData.craftingState)
               {
                  Global.player.craftingState.initCraftingStateFromInitUser(resultData.craftingState);
               }
               if(resultData.breedingState)
               {
                  Global.player.breedingState.initBreedingStateFromInitUser(resultData.breedingState);
               }
            }
            visitorManager = VisitorManager.getInstance();
            if(Boolean(playerData.neighborActionQueue) && Boolean(playerData.neighborActionQueue.m_actionQueue))
            {
               visitorManager.initNeighborActionData(playerData.neighborActionQueue.m_actionQueue);
            }
         }
      }
      
      override public function onEnterWorld(resultData:Object) : void
      {
         var hudButton:HudRoyaltyLoyaltyButton = null;
         super.onEnterWorld(resultData);
         if(FeatureOptionsManager.getInstance().getFeatureOption(ROYALTY_LOYALTY_PROGRAM,ROYALTY_PROGRAM_HUDSHOW_OPTION))
         {
            hudButton = new HudRoyaltyLoyaltyButton(ROYALTY_LOYALTY_HUD,ROYALTY_LOYALTY_PROGRAM);
            Global.hud.setHudRoyaltyLoyaltyButton(hudButton as HudRoyaltyLoyaltyButton);
         }
         if(Boolean(m_expansionData) && Boolean(m_expansionData.plotLimits))
         {
            WorldManager.enablePPHLimiting();
         }
         WorldIdUtil.resetTempIdStart();
         IdleTaskQueue.getInstance().unblockIdleTasks();
         IdleTaskQueue.getInstance().addIdleTasksOnEnterWorld();
         this.trackWorldInit();
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_WHEATHER_EFFECTS) >= 2)
         {
            WheatherEffectOnWorld.getInstance().showEffects();
         }
      }
      
      private function deferredsetupHud(e:Event = null) : void
      {
         if(Global.player.postInitFinished)
         {
            Global.world.removeEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferredsetupHud);
            if(AnimalSanctuaryV2Manager.getInstance())
            {
               AnimalSanctuaryV2Manager.getInstance().setupAnimalSanctuaryV2Hud();
            }
         }
      }
      
      override public function setupHud() : void
      {
         var hudSkin:HUDSkin = null;
         var hud:HUD = null;
         var prereq:Object = null;
         super.setupHud();
         StaticWorldInit.setupStaticHud(false);
         if(m_config.hudSkinConfig != null && m_config.hudSkinConfig is HUDSkinConfig)
         {
            hudSkin = new HUDSkin(Global.worldManager.currentWorldType,m_config.hudSkinConfig);
            hudSkin.apply();
            hud = Global.hud;
            if(hud.m_statsDropDown != null)
            {
               hud.m_statsDropDown.SetVisibility(true);
            }
            prereq = Global.farmGameSettingsManager.getPrereqByName("fvGuild_enabled");
            if(PrerequisiteUtility.isPrerequisiteMet(prereq))
            {
               if(Global.player.postInitFinished)
               {
                  if(Global.flashHotParams.hasOwnProperty(ZRUNTIME_GUILD_CONTROL_RUNTIME) && Boolean(Global.flashHotParams[ZRUNTIME_GUILD_CONTROL_RUNTIME]))
                  {
                     GuildManager.getInstance().setupGuildCreationHud();
                  }
               }
               else if(Global.flashHotParams.hasOwnProperty(ZRUNTIME_GUILD_CONTROL_RUNTIME) && Boolean(Global.flashHotParams[ZRUNTIME_GUILD_CONTROL_RUNTIME]))
               {
                  Global.world.addEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferredsetupGuildCreationHud,false,0,true);
               }
            }
            if(hud.shouldAllowTravel())
            {
               hud.showTravelNameDisplay();
               if(hud.farmNameDisplay)
               {
                  hud.farmNameDisplay.setFarmNameByLocation();
               }
            }
            else
            {
               hud.showBasicNameDisplay();
               if(hud.farmNameDisplay)
               {
                  hud.farmNameDisplay.setFarmNameFromPlayerName(Global.player.firstName);
               }
            }
         }
         if(m_config.hasOwnProperty("marketCardUniqueBackground") && m_config.marketCardUniqueBackground != null && m_config.marketCardUniqueBackground == "xww")
         {
            if(Boolean(AnimalSanctuaryV2Manager.getInstance()) && AnimalSanctuaryV2Manager.getInstance().isFeatureActive)
            {
               if(Global.player.postInitFinished)
               {
                  AnimalSanctuaryV2Manager.getInstance().setupAnimalSanctuaryV2Hud();
               }
               else
               {
                  Global.world.addEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferredsetupHud,false,0,true);
               }
            }
         }
      }
      
      override public function setupUI() : void
      {
         var actionMenuConfig:XML = null;
         var buttons:XMLList = null;
         var button:XML = null;
         var curLocationIndex:Number = NaN;
         var action:XmlDrivenAction = null;
         var iconLoader:Loader = null;
         var btnText:String = null;
         var btnTextKey:String = null;
         var commaIdx:int = 0;
         var topRightActionButton:ActionMultiButton = null;
         var failoverOpts:Array = null;
         var btnTextKeys:Array = null;
         var key:String = null;
         StaticWorldInit.setupStaticUI(false);
         var locations:Array = new Array();
         var actionMenuConfigs:XMLList = m_config.actionMenuConfig as XMLList;
         if(Boolean(actionMenuConfigs) && actionMenuConfigs.length() > 0)
         {
            for each(actionMenuConfig in actionMenuConfigs)
            {
               buttons = actionMenuConfig.button as XMLList;
               if(Boolean(buttons) && buttons.length() > 0)
               {
                  for each(button in buttons)
                  {
                     if(button.hasOwnProperty("prereqs"))
                     {
                        if(!PrerequisiteUtility.evalPrereqsXML(button.prereqs.prereq as XMLList))
                        {
                           continue;
                        }
                     }
                     curLocationIndex = 0;
                     if(button.hasOwnProperty("@location"))
                     {
                        curLocationIndex = Number(button.@location.toString());
                        if(locations.hasOwnProperty(curLocationIndex.toString()))
                        {
                           continue;
                        }
                        locations[curLocationIndex] = true;
                     }
                     action = new XmlDrivenAction(button.action[0]);
                     iconLoader = LoadingManager.load(Global.getAssetURL(button.icon[0].toString()),null,LoadingManager.PRIORITY_HIGH);
                     btnTextKey = button.text[0].toString();
                     commaIdx = btnTextKey.indexOf(",");
                     if(commaIdx > 0)
                     {
                        failoverOpts = new Array();
                        btnTextKeys = btnTextKey.split(",");
                        for each(key in btnTextKeys)
                        {
                           failoverOpts.push(new ZLocFailoverEntry(key));
                        }
                        btnText = ZLocUtils.getFailoverLocString(failoverOpts);
                     }
                     else
                     {
                        btnText = ZLocUtils.t_pk(btnTextKey);
                     }
                     Global.ui.getActionMenu().addTempTopRightItem({
                        "text":btnText,
                        "icon":iconLoader,
                        "onClick":action.act,
                        "location":curLocationIndex
                     });
                     topRightActionButton = Global.ui.getActionMenu().getSocialMissionButton() as ActionMultiButton;
                     if(topRightActionButton)
                     {
                        topRightActionButton.updateItems(true);
                     }
                  }
               }
            }
         }
         Global.ui.m_friendBar.updatePlayerSocialData(GlobalEngine.socialNetwork.getLoggedInUser());
      }
      
      protected function trackWorldInit() : void
      {
         var worldType:String = Global.worldManager.currentWorldType;
         var seenFlagName:String = "firstWorldTravel_" + worldType;
         WorldStatManager.trackWorldArrival(worldType);
         if(worldType != WorldsConstants.WORLD_ID_HOME && Global.player.getSeenFlag(seenFlagName) == false)
         {
            Global.player.setSeenFlag(seenFlagName);
            Global.player.setSeenFlag("eng_kickoff");
         }
      }
      
      override public function onLeaveWorld(destIsVisiting:Boolean) : void
      {
         super.onLeaveWorld(destIsVisiting);
         Global.hud.iconQueue.removeIconByName(EnglandOnboardingController.RECAPTURE_ICON_NAME);
         if(Boolean(m_expansionData) && Boolean(m_expansionData.plotLimits))
         {
            WorldManager.disablePPHLimiting();
         }
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_WHEATHER_EFFECTS) >= 2)
         {
            WheatherEffectOnWorld.getInstance().removeEffects();
         }
         if(Global.hud)
         {
            Global.hud.removeBottomHudAnimalSanctuaryV2Button();
         }
      }
      
      private function deferredsetupGuildCreationHud(e:Event = null) : void
      {
         if(Global.player.postInitFinished)
         {
            Global.world.removeEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferredsetupGuildCreationHud);
            if(GuildManager.getInstance())
            {
               GuildManager.getInstance().setupGuildCreationHud();
            }
         }
      }
   }
}

