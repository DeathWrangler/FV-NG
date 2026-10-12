package Transactions
{
   import Classes.Constants.WorldsConstants;
   import Classes.ZItem.ExpansionAccess;
   import Classes.ZItem.ExpansionData;
   import Classes.util.UserRewardUtil;
   import Engine.Managers.ErrorManager;
   import Managers.WorldSeasonsManager;
   import flash.utils.getQualifiedClassName;
   
   public class TExpansionWorldAccess extends TFarmTransaction
   {
      
      private static const SERVICE_CALL_YULETIDE:String = "YuletideService.unlockYuletideWorld";
      
      private static const SERVICE_CALL_PUMPKIN:String = "PumpkinService.unlockPumpkinWorld";
      
      private static const SERVICE_CALL_ALOHA:String = "AlohaService.unlockAlohaWorld";
      
      private static const SERVICE_CALL_AMSTERDAM:String = "AmsterdamService.unlockAmsterdamWorld";
      
      private static const SERVICE_CALL_MADAGASCAR:String = "MadagascarService.unlockMadagascarWorld";
      
      private static const SERVICE_CALL_FARMFEST:String = "FarmfestService.unlockFarmfestWorld";
      
      private static const SERVICE_CALL_SANTAVILLAGE:String = "SantavillageService.unlockSantavillageWorld";
      
      private static const SERVICE_CALL_BORABORA:String = "BoraboraService.unlockBoraboraWorld";
      
      private static const SERVICE_CALL_CANADA:String = "CanadaService.unlockCanadaWorld";
      
      private static const SERVICE_CALL_SPOOKY:String = "SpookyService.unlockSpookyWorld";
      
      private static const SERVICE_CALL_IRELAND:String = "IrelandService.unlockIrelandWorld";
      
      private static const SERVICE_CALL_COCOLAND:String = "CocolandService.unlockCocolandWorld";
      
      private static const SERVICE_CALL_ALASKA:String = "AlaskaService.unlockAlaskaWorld";
      
      private static const SERVICE_CALL_TWENTIES:String = "TwentiesService.unlockTwentiesWorld";
      
      private static const SERVICE_CALL_SOUTHINDIA:String = "SouthindiaService.unlockSouthindiaWorld";
      
      private static const SERVICE_CALL_CASABLANCA:String = "CasablancaService.unlockCasablancaWorld";
      
      private static const SERVICE_CALL_WINTERNORD:String = "WinternordService.unlockWinternordWorld";
      
      private static const SERVICE_CALL_HALLOWEENMAD:String = "HalloweenmadService.unlockHalloweenmadWorld";
      
      private static const SERVICE_CALL_ISRAEL:String = "IsraelService.unlockIsraelWorld";
      
      private static const SERVICE_CALL_NEWFRONTIER:String = "NewfrontierService.unlockNewfrontierWorld";
      
      private static const SERVICE_CALL_RUSSIA:String = "RussiaService.unlockRussiaWorld";
      
      private static const SERVICE_CALL_CARIBBEAN:String = "CaribbeanService.unlockCaribbeanWorld";
      
      private static const SERVICE_CALL_DRAGONVALLEY:String = "DragonvalleyService.unlockDragonvalleyWorld";
      
      private static const SERVICE_CALL_TUSCANY:String = "TuscanyService.unlockTuscanyWorld";
      
      private static const SERVICE_CALL_WHITEWINTER:String = "WhitewinterService.unlockWhitewinterWorld";
      
      private static const SERVICE_CALL_HALLOWEENUSA:String = "HalloweenusaService.unlockHalloweenusaWorld";
      
      private static const SERVICE_CALL_BRAZIL:String = "BrazilService.unlockBrazilWorld";
      
      private static const SERVICE_CALL_ANGLOFRENCH:String = "AnglofrenchService.unlockAnglofrenchWorld";
      
      private static const SERVICE_CALL_DREAMWORLD:String = "DreamworldService.unlockDreamworldWorld";
      
      private static const SERVICE_CALL_TURTLEISLAND:String = "TurtleislandService.unlockTurtleislandWorld";
      
      private static const SERVICE_CALL_UNDERWATER:String = "UnderwaterService.unlockUnderwaterWorld";
      
      private static const SERVICE_CALL_MIDWEST:String = "MidwestService.unlockMidwestWorld";
      
      private static const SERVICE_CALL_XMAS:String = "XmasService.unlockXmasWorld";
      
      private static const SERVICE_CALL_FISHERMAN_COVE:String = "FishermansCoveService.unlockFishermanWorld";
      
      private static const SERVICE_CALL_WINTER_WONDERLAND:String = "WinterWonderlandService.unlockWinterWonderlandWorld";
      
      private static const SERVICE_CALL_HAWAII:String = "HawaiiService.unlockHawaiiWorld";
      
      private static const SERVICE_CALL_ASIA:String = "AsiaService.unlockAsiaWorld";
      
      private static const SERVICE_CALL_HALLOW:String = "HallowService.unlockHallowWorld";
      
      private static const SERVICE_CALL_MEADOWS:String = "MeadowsService.unlockMeadowsWorld";
      
      private static const SERVICE_CALL_ENGLAND:String = "EnglandService.unlockEnglandWorld";
      
      private static const SERVICE_CALL_HTOWN:String = "HtownService.unlockHtownWorld";
      
      private static const SERVICE_CALL_SLEEPYHOLLOW:String = "SleepyhollowService.unlockSleepyhollowWorld";
      
      private static const SERVICE_CALL_TOYLAND:String = "ToylandService.unlockToylandWorld";
      
      private static const SERVICE_CALL_AVALON:String = "AvalonService.unlockAvalonWorld";
      
      private static const SERVICE_CALL_WILDWEST:String = "WildwestService.unlockWildwestWorld";
      
      private static const SERVICE_CALL_TREASURETIDES:String = "TreasuretidesService.unlockTreasuretidesWorld";
      
      private static const SERVICE_CALL_AFRICA:String = "AfricaService.unlockAfricaWorld";
      
      private static const SERVICE_CALL_TRANSYLVANIA:String = "TransylvaniaService.unlockTransylvaniaWorld";
      
      private static const SERVICE_CALL_WINTER:String = "WinterService.unlockWinterWorld";
      
      private static const SERVICE_CALL_JAPAN:String = "JapanService.unlockJapanWorld";
      
      private static const SERVICE_CALL_INDIA:String = "IndiaService.unlockIndiaWorld";
      
      private static const SERVICE_CALL_JUNGLE:String = "JungleService.unlockJungleWorld";
      
      private static const SERVICE_CALL_MOUNT:String = "MountService.unlockMountWorld";
      
      private static const SERVICE_CALL_LIMBO:String = "LimboService.unlockLimboWorld";
      
      public static const EXPANSION_ACCESS_PENDING:String = "EXPANSION_ACCESS_PENDING";
      
      public static const EXPANSION_ACCESS_SENT:String = "EXPANSION_ACCESS_SENT";
      
      private static const SERVICE_CALL_GLEN:String = "GlenService.unlockGlenWorld";
      
      private static const SERVICE_CALL_ATLANTIS:String = "AtlantisService.unlockAtlantisWorld";
      
      private static const SERVICE_CALL_AUSTRALIA:String = "AustraliaService.unlockAustraliaWorld";
      
      private static const SERVICE_CALL_SPACE:String = "SpaceService.unlockSpaceWorld";
      
      private static const SERVICE_CALL_CANDY:String = "CandyService.unlockCandyWorld";
      
      private static const SERVICE_CALL_FFOREST:String = "FforestService.unlockFforestWorld";
      
      private static const SERVICE_CALL_HLIGHTS:String = "HlightsService.unlockHlightsWorld";
      
      private static const SERVICE_CALL_RAINFOREST:String = "RainforestService.unlockRainforestWorld";
      
      private static const SERVICE_CALL_OZ:String = "OzService.unlockOzWorld";
      
      private static const SERVICE_CALL_MEDITERRANEAN:String = "MediterraneanService.unlockMediterraneanWorld";
      
      private static const SERVICE_CALL_OASIS:String = "OasisService.unlockOasisWorld";
      
      private static const SERVICE_CALL_STORYBOOK:String = "StorybookService.unlockStorybookWorld";
      
      private static const SERVICE_CALL_GARDEN:String = "GardenService.unlockGardenWorld";
      
      private static const SERVICE_CALL_VILLAGE:String = "VillageService.unlockVillageWorld";
      
      private var m_worldType:String;
      
      private var m_serviceCallName:String;
      
      private var m_accessType:String;
      
      private var m_optionId:String;
      
      private var m_shouldSwapFarm:Boolean;
      
      private var m_callback:Function;
      
      public function TExpansionWorldAccess(worldType:String, accessType:String, shouldFarmSwap:Boolean = true, optionId:String = null, callback:Function = null)
      {
         super();
         switch(worldType)
         {
            case WorldsConstants.WORLD_ID_FISHERMAN:
               this.m_serviceCallName = SERVICE_CALL_FISHERMAN_COVE;
               break;
            case WorldsConstants.WORLD_ID_WINTER_WONDERLAND:
               this.m_serviceCallName = SERVICE_CALL_WINTER_WONDERLAND;
               break;
            case WorldsConstants.WORLD_ID_HAWAII:
               this.m_serviceCallName = SERVICE_CALL_HAWAII;
               break;
            case WorldsConstants.WORLD_ID_ASIA:
               this.m_serviceCallName = SERVICE_CALL_ASIA;
               break;
            case WorldsConstants.WORLD_ID_HALLOW:
               this.m_serviceCallName = SERVICE_CALL_HALLOW;
               break;
            case WorldsConstants.WORLD_ID_HTOWN:
               this.m_serviceCallName = SERVICE_CALL_HTOWN;
               break;
            case WorldsConstants.WORLD_ID_MEADOWS:
               this.m_serviceCallName = SERVICE_CALL_MEADOWS;
               this.m_optionId = optionId;
               break;
            case WorldsConstants.WORLD_ID_GLEN:
               this.m_serviceCallName = SERVICE_CALL_GLEN;
               break;
            case WorldsConstants.WORLD_ID_ENGLAND:
               this.m_serviceCallName = SERVICE_CALL_ENGLAND;
               break;
            case WorldsConstants.WORLD_ID_ATLANTIS:
               this.m_serviceCallName = SERVICE_CALL_ATLANTIS;
               break;
            case WorldsConstants.WORLD_ID_AUSTRALIA:
               this.m_serviceCallName = SERVICE_CALL_AUSTRALIA;
               break;
            case WorldsConstants.WORLD_ID_SPACE:
               this.m_serviceCallName = SERVICE_CALL_SPACE;
               break;
            case WorldsConstants.WORLD_ID_GARDEN:
               this.m_serviceCallName = SERVICE_CALL_GARDEN;
               break;
            case WorldsConstants.WORLD_ID_CANDY:
               this.m_serviceCallName = SERVICE_CALL_CANDY;
               break;
            case WorldsConstants.WORLD_ID_FFOREST:
               this.m_serviceCallName = SERVICE_CALL_FFOREST;
               break;
            case WorldsConstants.WORLD_ID_HLIGHTS:
               this.m_serviceCallName = SERVICE_CALL_HLIGHTS;
               break;
            case WorldsConstants.WORLD_ID_RAINFOREST:
               this.m_serviceCallName = SERVICE_CALL_RAINFOREST;
               break;
            case WorldsConstants.WORLD_ID_OZ:
               this.m_serviceCallName = SERVICE_CALL_OZ;
               break;
            case WorldsConstants.WORLD_ID_MEDITERRANEAN:
               this.m_serviceCallName = SERVICE_CALL_MEDITERRANEAN;
               break;
            case WorldsConstants.WORLD_ID_OASIS:
               this.m_serviceCallName = SERVICE_CALL_OASIS;
               break;
            case WorldsConstants.WORLD_ID_STORYBOOK:
               this.m_serviceCallName = SERVICE_CALL_STORYBOOK;
               break;
            case WorldsConstants.WORLD_ID_VILLAGE:
               this.m_serviceCallName = SERVICE_CALL_VILLAGE;
               break;
            case WorldsConstants.WORLD_ID_SLEEPYHOLLOW:
               this.m_serviceCallName = SERVICE_CALL_SLEEPYHOLLOW;
               break;
            case WorldsConstants.WORLD_ID_TOYLAND:
               this.m_serviceCallName = SERVICE_CALL_TOYLAND;
               break;
            case WorldsConstants.WORLD_ID_AVALON:
               this.m_serviceCallName = SERVICE_CALL_AVALON;
               break;
            case WorldsConstants.WORLD_ID_WILDWEST:
               this.m_serviceCallName = SERVICE_CALL_WILDWEST;
               break;
            case WorldsConstants.WORLD_ID_TREASURETIDES:
               this.m_serviceCallName = SERVICE_CALL_TREASURETIDES;
               break;
            case WorldsConstants.WORLD_ID_AFRICA:
               this.m_serviceCallName = SERVICE_CALL_AFRICA;
               break;
            case WorldsConstants.WORLD_ID_TRANSYLVANIA:
               this.m_serviceCallName = SERVICE_CALL_TRANSYLVANIA;
               break;
            case WorldsConstants.WORLD_ID_WINTER:
               this.m_serviceCallName = SERVICE_CALL_WINTER;
               break;
            case WorldsConstants.WORLD_ID_JAPAN:
               this.m_serviceCallName = SERVICE_CALL_JAPAN;
               break;
            case WorldsConstants.WORLD_ID_INDIA:
               this.m_serviceCallName = SERVICE_CALL_INDIA;
               break;
            case WorldsConstants.WORLD_ID_JUNGLE:
               this.m_serviceCallName = SERVICE_CALL_JUNGLE;
               break;
            case WorldsConstants.WORLD_ID_MOUNT:
               this.m_serviceCallName = SERVICE_CALL_MOUNT;
               break;
            case WorldsConstants.WORLD_ID_LIMBO:
               this.m_serviceCallName = SERVICE_CALL_LIMBO;
               break;
            case WorldsConstants.WORLD_ID_XMAS:
               this.m_serviceCallName = SERVICE_CALL_XMAS;
               break;
            case WorldsConstants.WORLD_ID_TURTLEISLAND:
               this.m_serviceCallName = SERVICE_CALL_TURTLEISLAND;
               break;
            case WorldsConstants.WORLD_ID_MIDWEST:
               this.m_serviceCallName = SERVICE_CALL_MIDWEST;
               break;
            case WorldsConstants.WORLD_ID_UNDERWATER:
               this.m_serviceCallName = SERVICE_CALL_UNDERWATER;
               break;
            case WorldsConstants.WORLD_ID_DREAMWORLD:
               this.m_serviceCallName = SERVICE_CALL_DREAMWORLD;
               break;
            case WorldsConstants.WORLD_ID_ANGLOFRENCH:
               this.m_serviceCallName = SERVICE_CALL_ANGLOFRENCH;
               break;
            case WorldsConstants.WORLD_ID_HALLOWEENUSA:
               this.m_serviceCallName = SERVICE_CALL_HALLOWEENUSA;
               break;
            case WorldsConstants.WORLD_ID_BRAZIL:
               this.m_serviceCallName = SERVICE_CALL_BRAZIL;
               break;
            case WorldsConstants.WORLD_ID_TUSCANY:
               this.m_serviceCallName = SERVICE_CALL_TUSCANY;
               break;
            case WorldsConstants.WORLD_ID_WHITEWINTER:
               this.m_serviceCallName = SERVICE_CALL_WHITEWINTER;
               break;
            case WorldsConstants.WORLD_ID_CARIBBEAN:
               this.m_serviceCallName = SERVICE_CALL_CARIBBEAN;
               break;
            case WorldsConstants.WORLD_ID_DRAGONVALLEY:
               this.m_serviceCallName = SERVICE_CALL_DRAGONVALLEY;
               break;
            case WorldsConstants.WORLD_ID_RUSSIA:
               this.m_serviceCallName = SERVICE_CALL_RUSSIA;
               break;
            case WorldsConstants.WORLD_ID_ISRAEL:
               this.m_serviceCallName = SERVICE_CALL_ISRAEL;
               break;
            case WorldsConstants.WORLD_ID_NEWFRONTIER:
               this.m_serviceCallName = SERVICE_CALL_NEWFRONTIER;
               break;
            case WorldsConstants.WORLD_ID_HALLOWEENMAD:
               this.m_serviceCallName = SERVICE_CALL_HALLOWEENMAD;
               break;
            case WorldsConstants.WORLD_ID_WINTERNORD:
               this.m_serviceCallName = SERVICE_CALL_WINTERNORD;
               break;
            case WorldsConstants.WORLD_ID_CASABLANCA:
               this.m_serviceCallName = SERVICE_CALL_CASABLANCA;
               break;
            case WorldsConstants.WORLD_ID_TWENTIES:
               this.m_serviceCallName = SERVICE_CALL_TWENTIES;
               break;
            case WorldsConstants.WORLD_ID_SOUTHINDIA:
               this.m_serviceCallName = SERVICE_CALL_SOUTHINDIA;
               break;
            case WorldsConstants.WORLD_ID_ALASKA:
               this.m_serviceCallName = SERVICE_CALL_ALASKA;
               break;
            case WorldsConstants.WORLD_ID_COCOLAND:
               this.m_serviceCallName = SERVICE_CALL_COCOLAND;
               break;
            case WorldsConstants.WORLD_ID_IRELAND:
               this.m_serviceCallName = SERVICE_CALL_IRELAND;
               break;
            case WorldsConstants.WORLD_ID_SANTAVILLAGE:
               this.m_serviceCallName = SERVICE_CALL_SANTAVILLAGE;
               break;
            case WorldsConstants.WORLD_ID_BORABORA:
               this.m_serviceCallName = SERVICE_CALL_BORABORA;
               break;
            case WorldsConstants.WORLD_ID_CANADA:
               this.m_serviceCallName = SERVICE_CALL_CANADA;
               break;
            case WorldsConstants.WORLD_ID_SPOOKY:
               this.m_serviceCallName = SERVICE_CALL_SPOOKY;
               break;
            case WorldsConstants.WORLD_ID_FARMFEST:
               this.m_serviceCallName = SERVICE_CALL_FARMFEST;
               break;
            case WorldsConstants.WORLD_ID_MADAGASCAR:
               this.m_serviceCallName = SERVICE_CALL_MADAGASCAR;
               break;
            case WorldsConstants.WORLD_ID_AMSTERDAM:
               this.m_serviceCallName = SERVICE_CALL_AMSTERDAM;
               break;
            case WorldsConstants.WORLD_ID_PUMPKIN:
               this.m_serviceCallName = SERVICE_CALL_PUMPKIN;
               break;
            case WorldsConstants.WORLD_ID_ALOHA:
               this.m_serviceCallName = SERVICE_CALL_ALOHA;
               break;
            case WorldsConstants.WORLD_ID_YULETIDE:
               this.m_serviceCallName = SERVICE_CALL_YULETIDE;
               break;
            default:
               throw new Error(getQualifiedClassName(this) + " does not support access to worldType: " + worldType);
         }
         this.m_worldType = worldType;
         this.m_accessType = accessType;
         this.m_shouldSwapFarm = shouldFarmSwap;
         this.m_callback = callback;
         Global.player.setSeenSessionFlag(EXPANSION_ACCESS_PENDING);
      }
      
      override public function perform() : void
      {
         if(!Global.player.getSeenFlag(EXPANSION_ACCESS_SENT))
         {
            if(this.m_optionId == null)
            {
               signedCall(this.m_serviceCallName,this.m_accessType);
            }
            else
            {
               signedCall(this.m_serviceCallName,this.m_accessType,this.m_optionId);
            }
            Global.player.setSeenSessionFlag(EXPANSION_ACCESS_SENT);
         }
      }
      
      override protected function onComplete(result:Object) : void
      {
         var data:ExpansionData = null;
         var accessInfo:ExpansionAccess = null;
         var rewards:Vector.<Object> = null;
         if(this.m_callback != null)
         {
            this.m_callback();
         }
         if(result)
         {
            if(Global.flashHotParams["SLEEPYHOLLOW_UNWITHER_CROPS_ONCE"])
            {
               if((result as Array).indexOf("sleepyhollowunwitheradded") != -1)
               {
                  Global.player.setSeenSessionFlag("sleepyhollowunwitheradded");
               }
            }
            data = Global.farmGameSettingsManager.getExpansionData(this.m_worldType);
            if(data)
            {
               accessInfo = data.getAccessOfType(this.m_accessType);
               if(accessInfo)
               {
                  rewards = this.m_optionId != null ? accessInfo.getOptionRewards(this.m_optionId) : accessInfo.rewards;
                  if(WorldSeasonsManager.getInstance().hasSeasons(this.m_worldType))
                  {
                     UserRewardUtil.grantSeasonRewards(rewards,data.seasonNumber);
                  }
                  else
                  {
                     UserRewardUtil.grantUserRewards(rewards);
                  }
               }
            }
            if(this.m_shouldSwapFarm)
            {
               Global.worldManager.swapFarm(this.m_worldType,false);
            }
         }
         else
         {
            ErrorManager.addError("Invalid result from service method");
         }
      }
   }
}

