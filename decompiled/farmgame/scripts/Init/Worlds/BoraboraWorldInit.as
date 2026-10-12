package Init.Worlds
{
   import Classes.Constants.Experiments;
   import Classes.Constants.WorldsConstants;
   import Classes.FeatureMessagingDefinition;
   import Classes.ImageLoader;
   import Classes.Quest.PrerequisiteUtility;
   import Display.HUD.HUDWidgets.HudBottomLandBundleUnlockFeature;
   import Events.FarmGameWorldEvent;
   import Init.PostInitActionHandlers.RightSideHUDIconInitAction;
   import Managers.CommunityGoalsManager;
   import Managers.FeatureMessagingManager;
   import Managers.OrderBoard.BoraBoraInnovationManager;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class BoraboraWorldInit extends HomeWorldInit
   {
      
      public static const ICON_CODE_STARTER_XBB:String = "301";
      
      private static const UITemplatizationBgImages:Array = ["AnimalFrame_big_noBG.png","MOTD.png","AnimalFrame.png","AnimalFrame_big.png","MOTD_noTitle.png","NPC1_225.png","RewardDialog.png","MOTD_ShippingLicense.png","NPC2.png","FV_animal_breeding_aquarium.jpg","FV_animal_breeding_aviary.jpg","FV_animal_breeding_babypen.jpg","FV_animal_breeding_livestockpen.jpg","FV_animal_breeding_paddock.jpg","FV_animal_breeding_pasture.jpg","FV_animal_breeding_petrun.jpg","FV_animal_breeding_wildlifepen.jpg","FV_animal_breeding_zoopen.jpg"];
      
      private static const UITemplatizationSlotImages:Array = ["V100","V80","V55","H100","H60","Button100","treasureDialog","worldScoreIcon","CGTitleBar"];
      
      public static const FEATURE_NAME:String = "BoraBoraInnovation";
      
      public function BoraboraWorldInit()
      {
         super();
      }
      
      private static function onUrlLoaded(dispObj:DisplayObject, info:Object = null) : void
      {
      }
      
      private static function isBoraBoraInnovationActive() : Boolean
      {
         var result:Boolean = false;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("borabora_innovation_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            if(Boolean(BoraBoraInnovationManager.getInstance()) && Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_BORABORA)
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
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XBB_STARTER) >= 1)
         {
            Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_STARTER_XBB));
         }
         var featureDef:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(CommunityGoalsManager.FEATURE_NAME);
         if(featureDef)
         {
            featureDef.updateIconVisibility();
         }
         if(Boolean(BoraBoraInnovationManager.getInstance()) && isBoraBoraInnovationActive())
         {
            if(Global.player.postInitFinished)
            {
               if(!Global.player.getSeenFlag("bb_initialize_timer"))
               {
                  BoraBoraInnovationManager.getInstance().updateTimers();
                  Global.player.setSeenFlag("bb_initialize_timer");
               }
               BoraBoraInnovationManager.getInstance().setUpBoraBoraHud();
            }
            else
            {
               if(!Global.player.getSeenFlag("bb_initialize_timer"))
               {
                  BoraBoraInnovationManager.getInstance().updateTimers();
                  Global.player.setSeenFlag("bb_initialize_timer");
               }
               Global.world.addEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferredsetupHud,false,0,true);
            }
         }
         else if(Boolean(BoraBoraInnovationManager.getInstance()) && !Global.player.getSeenFlag(BoraBoraInnovationManager.BB_INNOVATION_END_DECO_FLAG))
         {
            BoraBoraInnovationManager.getInstance().featureEndDeco();
         }
         if(BoraBoraInnovationManager.getInstance())
         {
            BoraBoraInnovationManager.getInstance().initEventListener();
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
         if(PrerequisiteUtility.isPrerequisiteMet(Global.farmGameSettingsManager.getPrereqByName("land_bundle_unlock_feature_enabled")))
         {
            if(Global.hud)
            {
               Global.hud.setHudLandBundleUnlockFeature(new HudBottomLandBundleUnlockFeature("assets/dialogs/borabora/landbundle/FV_xbb_hud_Innovation.swf","LandBundleUnlockFeature"));
            }
         }
      }
      
      private function deferredsetupHud(e:Event = null) : void
      {
         if(Global.player.postInitFinished)
         {
            Global.world.removeEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferredsetupHud);
            if(BoraBoraInnovationManager.getInstance())
            {
               BoraBoraInnovationManager.getInstance().setUpBoraBoraHud();
            }
         }
      }
      
      override public function onLeaveWorld(destIsVisiting:Boolean) : void
      {
         super.onLeaveWorld(destIsVisiting);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XBB_STARTER) >= 1)
         {
            Global.hud.rightSideIconQueue.removeIconByName(ICON_CODE_STARTER_XBB);
         }
         var featureDef:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(CommunityGoalsManager.FEATURE_NAME);
         if(featureDef)
         {
            featureDef.updateIconVisibility();
         }
         if(Global.hud)
         {
            Global.hud.removeBottomHudBoraBoraInnovationButton();
            Global.hud.removeBottomHudLandBundleUnlockFeatureButton();
         }
         if(BoraBoraInnovationManager.getInstance(FEATURE_NAME).m_mainWindow)
         {
            BoraBoraInnovationManager.getInstance(FEATURE_NAME).m_mainWindow.close();
         }
      }
      
      private function triggerBoraboraInnovationFeature(e:Event = null) : void
      {
         if(!Global.player.getSeenFlag(BoraBoraInnovationManager.HUD_INITIALISATION_FLAG))
         {
            Global.player.setSeenFlag(BoraBoraInnovationManager.HUD_INITIALISATION_FLAG);
            Global.worldManager.addEventListener(FarmGameWorldEvent.WORLD_LOADED,this.onWorldLoaded);
         }
      }
      
      override public function setupUI() : void
      {
         super.setupUI();
         this.triggerBoraboraInnovationFeature();
      }
      
      private function onWorldLoaded(event:FarmGameWorldEvent) : void
      {
         Global.worldManager.removeEventListener(FarmGameWorldEvent.WORLD_LOADED,this.onWorldLoaded);
         BoraBoraInnovationManager.getInstance(FEATURE_NAME).showWorldLoadBBStartWindow();
      }
   }
}

