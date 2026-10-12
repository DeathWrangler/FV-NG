package Init.Worlds
{
   import Classes.Constants.Experiments;
   import Classes.Constants.WorldsConstants;
   import Classes.FeatureMessagingDefinition;
   import Classes.ImageLoader;
   import Classes.Quest.PrerequisiteUtility;
   import Events.FarmGameWorldEvent;
   import Init.PostInitActionHandlers.RightSideHUDIconInitAction;
   import Managers.CommunityGoalsManager;
   import Managers.FeatureMessagingManager;
   import Managers.OctoberSidecarFeatureManager;
   import Managers.PumpkinPartyInnovationManager;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class PumpkinWorldInit extends HomeWorldInit
   {
      
      public static const ICON_CODE_STARTER_XPU:String = "305";
      
      public static const FEATURE_NAME:String = "PumpkinPartyInnovation";
      
      private static const TILE_BUNDLE_HUD:String = "LandBundlePumpkin";
      
      private static const UITemplatizationBgImages:Array = ["AnimalFrame_big_noBG.png","MOTD.png","AnimalFrame.png","AnimalFrame_big.png","MOTD_noTitle.png","NPC1_225.png","RewardDialog.png","MOTD_ShippingLicense.png","NPC2.png","FV_animal_breeding_aquarium.jpg","FV_animal_breeding_aviary.jpg","FV_animal_breeding_babypen.jpg","FV_animal_breeding_livestockpen.jpg","FV_animal_breeding_paddock.jpg","FV_animal_breeding_pasture.jpg","FV_animal_breeding_petrun.jpg","FV_animal_breeding_wildlifepen.jpg","FV_animal_breeding_zoopen.jpg"];
      
      private static const UITemplatizationSlotImages:Array = ["V100","V80","V55","H100","H60","Button100","treasureDialog","worldScoreIcon","CGTitleBar"];
      
      public function PumpkinWorldInit()
      {
         super();
      }
      
      private static function onUrlLoaded(dispObj:DisplayObject, info:Object = null) : void
      {
      }
      
      override public function onEnterWorld(resultData:Object) : void
      {
         var image:String = null;
         var slotImageTag:String = null;
         var featureDefBundle:FeatureMessagingDefinition = null;
         var imageUrl:String = null;
         super.onEnterWorld(resultData);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XPU_STARTER) >= 1)
         {
            Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_STARTER_XPU));
         }
         var featureDef:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(CommunityGoalsManager.FEATURE_NAME);
         if(featureDef)
         {
            featureDef.updateIconVisibility();
         }
         if(Boolean(PumpkinPartyInnovationManager.getInstance(FEATURE_NAME)) && this.isPumpkinPartyInnovationActive())
         {
            if(Global.player.postInitFinished)
            {
               PumpkinPartyInnovationManager.getInstance(FEATURE_NAME).setupPumpkinPartyHud();
            }
            else
            {
               Global.world.addEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferredsetupHud,false,0,true);
            }
            this.triggerPumpkinPartyInnovationFeature();
            PumpkinPartyInnovationManager.getInstance(FEATURE_NAME).initEventListener();
            PumpkinPartyInnovationManager.getInstance().updateEscapeTokensCount();
            PumpkinPartyInnovationManager.getInstance().fetchAppEnvironment();
         }
         if(Boolean(OctoberSidecarFeatureManager.getInstance()) && this.isOctoberSidecarHudActive())
         {
            if(Global.player.postInitFinished)
            {
               OctoberSidecarFeatureManager.getInstance().setupHud();
            }
            else
            {
               Global.world.addEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferredsetupHud,false,0,true);
            }
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
         featureDefBundle = FeatureMessagingManager.getInstance().getFeatureDefinition(TILE_BUNDLE_HUD);
         if(featureDefBundle)
         {
            featureDefBundle.updateIconVisibility();
         }
      }
      
      private function isPumpkinPartyInnovationActive() : Boolean
      {
         var pumpkinpartyInnovationManager:PumpkinPartyInnovationManager = null;
         var result:Boolean = false;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("pumpkinparty_innovation_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            pumpkinpartyInnovationManager = PumpkinPartyInnovationManager.getInstance();
            if(Boolean(pumpkinpartyInnovationManager) && Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_PUMPKIN)
            {
               result = true;
            }
         }
         return result;
      }
      
      private function deferredsetupHud(e:Event = null) : void
      {
         if(Global.player.postInitFinished)
         {
            Global.world.removeEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferredsetupHud);
            if(PumpkinPartyInnovationManager.getInstance(FEATURE_NAME))
            {
               PumpkinPartyInnovationManager.getInstance(FEATURE_NAME).setupPumpkinPartyHud();
            }
            if(OctoberSidecarFeatureManager.getInstance())
            {
               OctoberSidecarFeatureManager.getInstance().setupHud();
            }
         }
      }
      
      private function triggerPumpkinPartyInnovationFeature(e:Event = null) : void
      {
         if(!Global.player.getSeenFlag(PumpkinPartyInnovationManager.HUD_INITIALISATION_FLAG))
         {
            Global.player.setSeenFlag(PumpkinPartyInnovationManager.HUD_INITIALISATION_FLAG);
            PumpkinPartyInnovationManager.getInstance(FEATURE_NAME).showMainUI();
         }
      }
      
      override public function onLeaveWorld(destIsVisiting:Boolean) : void
      {
         super.onLeaveWorld(destIsVisiting);
         var featureDefBundle:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(TILE_BUNDLE_HUD);
         if(featureDefBundle)
         {
            featureDefBundle.updateIconVisibility();
         }
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XPU_STARTER) >= 1)
         {
            Global.hud.rightSideIconQueue.removeIconByName(ICON_CODE_STARTER_XPU);
         }
         var featureDef:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(CommunityGoalsManager.FEATURE_NAME);
         if(featureDef)
         {
            featureDef.updateIconVisibility();
         }
         if(Global.hud)
         {
            Global.hud.removeBottomHudPumpkinPartyInnovationButton();
            Global.hud.removeBottomHudOctoberSidecarFeatureButton();
         }
      }
      
      public function isOctoberSidecarHudActive() : Boolean
      {
         var result:Boolean = false;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("october_sidecar_hud_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            result = true;
         }
         return result;
      }
   }
}

