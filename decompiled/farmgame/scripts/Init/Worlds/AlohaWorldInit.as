package Init.Worlds
{
   import Classes.Constants.Experiments;
   import Classes.Constants.WorldsConstants;
   import Classes.FeatureMessagingDefinition;
   import Classes.ImageLoader;
   import Classes.Quest.PrerequisiteUtility;
   import Events.FarmGameWorldEvent;
   import Init.PostInitActionHandlers.RightSideHUDIconInitAction;
   import Managers.BoatRushManager;
   import Managers.CommunityGoalsManager;
   import Managers.FeatureMessagingManager;
   import Managers.OrderBoard.TropicalMarketInnovationManager;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class AlohaWorldInit extends HomeWorldInit
   {
      
      public static const ICON_CODE_STARTER_XAH:String = "304";
      
      private static const UITemplatizationBgImages:Array = ["AnimalFrame_big_noBG.png","MOTD.png","AnimalFrame.png","AnimalFrame_big.png","MOTD_noTitle.png","NPC1_225.png","RewardDialog.png","MOTD_ShippingLicense.png","NPC2.png","FV_animal_breeding_aquarium.jpg","FV_animal_breeding_aviary.jpg","FV_animal_breeding_babypen.jpg","FV_animal_breeding_livestockpen.jpg","FV_animal_breeding_paddock.jpg","FV_animal_breeding_pasture.jpg","FV_animal_breeding_petrun.jpg","FV_animal_breeding_wildlifepen.jpg","FV_animal_breeding_zoopen.jpg"];
      
      private static const UITemplatizationSlotImages:Array = ["V100","V80","V55","H100","H60","Button100","treasureDialog","worldScoreIcon","CGTitleBar"];
      
      public function AlohaWorldInit()
      {
         super();
      }
      
      private static function onUrlLoaded(dispObj:DisplayObject, info:Object = null) : void
      {
      }
      
      private static function isBoatRace2020Active() : Boolean
      {
         var result:Boolean = false;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("boatracing2020_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            if(Boolean(BoatRushManager.getInstance()) && Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_ALOHA)
            {
               result = true;
            }
         }
         return result;
      }
      
      private static function isTropicalMarketActive() : Boolean
      {
         var result:Boolean = false;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("tropical_market_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            if(Boolean(TropicalMarketInnovationManager.getInstance()) && Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_ALOHA)
            {
               result = true;
            }
         }
         return result;
      }
      
      override public function onEnterWorld(resultData:Object) : void
      {
         var image:String = null;
         var slotImageTag:String = null;
         var imageUrl:String = null;
         super.onEnterWorld(resultData);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XAH_STARTER) >= 1)
         {
            Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_STARTER_XAH));
         }
         var featureDef:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(CommunityGoalsManager.FEATURE_NAME);
         if(featureDef)
         {
            featureDef.updateIconVisibility();
         }
         if(Boolean(BoatRushManager.getInstance()) && isBoatRace2020Active())
         {
            if(Global.player.postInitFinished)
            {
               BoatRushManager.getInstance().setUpHudBoatRacing2020();
            }
            else
            {
               Global.world.addEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferredsetupWinterwRacing2019Hud,false,0,true);
            }
         }
         else if(Boolean(BoatRushManager.getInstance()) && !isBoatRace2020Active())
         {
            BoatRushManager.getInstance().removeHud();
         }
         BoatRushManager.getInstance().startSkighGamebordTimer();
         if(Boolean(TropicalMarketInnovationManager.getInstance()) && isTropicalMarketActive())
         {
            if(Global.player.postInitFinished)
            {
               TropicalMarketInnovationManager.getInstance().setUpHudTropicalMarket();
            }
            else
            {
               Global.world.addEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferredsetupTropicalMarketInnovationHud,false,0,true);
            }
            this.triggerTropicalMarketFeature();
            TropicalMarketInnovationManager.getInstance().updateEscapeTokensCount();
            TropicalMarketInnovationManager.getInstance().fetchAppEnvironment();
         }
         for each(image in UITemplatizationBgImages)
         {
            imageUrl = "assets/dialogs/" + Global.worldManager.currentWorldType + "/";
            imageUrl = Global.getAssetURL(imageUrl + image);
            ImageLoader.getInstance(imageUrl).getContent(onUrlLoaded);
         }
         for each(slotImageTag in UITemplatizationSlotImages)
         {
            imageUrl = Global.getAssetURL(Global.worldSettingsManager.getSlotBGImagePath(slotImageTag));
            ImageLoader.getInstance(imageUrl).getContent(onUrlLoaded);
         }
      }
      
      override public function onLeaveWorld(destIsVisiting:Boolean) : void
      {
         super.onLeaveWorld(destIsVisiting);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XAH_STARTER) >= 1)
         {
            Global.hud.rightSideIconQueue.removeIconByName(ICON_CODE_STARTER_XAH);
         }
         var featureDef:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(CommunityGoalsManager.FEATURE_NAME);
         if(featureDef)
         {
            featureDef.updateIconVisibility();
         }
         if(Global.hud)
         {
            Global.hud.removeBottomHudTropicalMarketInnovationButton();
            Global.hud.removesetHudBoatRushFeature();
         }
      }
      
      private function deferredsetupWinterwRacing2019Hud(e:Event = null) : void
      {
         if(Global.player.postInitFinished)
         {
            Global.world.removeEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferredsetupWinterwRacing2019Hud);
            if(BoatRushManager.getInstance())
            {
               BoatRushManager.getInstance().setUpHudBoatRacing2020();
            }
         }
      }
      
      private function triggerTropicalMarketFeature(e:Event = null) : void
      {
         if(!Global.player.getSeenFlag(TropicalMarketInnovationManager.HUD_INITIALISATION_FLAG))
         {
            Global.player.setSeenFlag(TropicalMarketInnovationManager.HUD_INITIALISATION_FLAG);
            TropicalMarketInnovationManager.getInstance().showMainWindow();
         }
      }
      
      private function deferredsetupTropicalMarketInnovationHud(e:Event = null) : void
      {
         if(Global.player.postInitFinished)
         {
            Global.world.removeEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferredsetupTropicalMarketInnovationHud);
            if(TropicalMarketInnovationManager.getInstance())
            {
               TropicalMarketInnovationManager.getInstance().setUpHudTropicalMarket();
            }
         }
      }
   }
}

