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
   import Managers.Dec19InnovationManager;
   import Managers.FeatureMessagingManager;
   import Managers.WinterRacingFeatureManager;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class SantavillageWorldInit extends HomeWorldInit
   {
      
      private static const TILE_BUNDLE_HUD:String = "LandBundleSantavillage";
      
      public static const ICON_CODE_STARTER_XWS:String = "298";
      
      public static const FEATURE_NAME:String = "Dec19Innovation";
      
      public static const GIFTRUSH2019_BONUS_REWARD_FLAG:String = "giftrush2019_bonus_reward_flag";
      
      private static const UITemplatizationBgImages:Array = ["AnimalFrame_big_noBG.png","MOTD.png","AnimalFrame.png","AnimalFrame_big.png","MOTD_noTitle.png","NPC1_225.png","RewardDialog.png","MOTD_ShippingLicense.png","NPC2.png","FV_animal_breeding_aquarium.jpg","FV_animal_breeding_aviary.jpg","FV_animal_breeding_babypen.jpg","FV_animal_breeding_livestockpen.jpg","FV_animal_breeding_paddock.jpg","FV_animal_breeding_pasture.jpg","FV_animal_breeding_petrun.jpg","FV_animal_breeding_wildlifepen.jpg","FV_animal_breeding_zoopen.jpg"];
      
      private static const UITemplatizationSlotImages:Array = ["V100","V80","V55","H100","H60","Button100","treasureDialog","worldScoreIcon","CGTitleBar"];
      
      public function SantavillageWorldInit()
      {
         super();
      }
      
      private static function onUrlLoaded(dispObj:DisplayObject, info:Object = null) : void
      {
      }
      
      private static function isWinterRacing2019Active() : Boolean
      {
         var result:Boolean = false;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("winterracing2019_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            if(Boolean(WinterRacingFeatureManager.getInstance()) && Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_SANTAVILLAGE)
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
         var featureDefBundle:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(TILE_BUNDLE_HUD);
         if(featureDefBundle)
         {
            featureDefBundle.updateIconVisibility();
         }
         if(Boolean(Dec19InnovationManager.getInstance(FEATURE_NAME)) && this.isDec19InnovationActive())
         {
            if(Global.player.postInitFinished)
            {
               Dec19InnovationManager.getInstance(FEATURE_NAME).setupDec19Hud();
            }
            else
            {
               Global.world.addEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferredsetupHud,false,0,true);
            }
            this.triggerDec19InnovationFeature();
            Dec19InnovationManager.getInstance(FEATURE_NAME).initEventListener();
         }
         if(Boolean(WinterRacingFeatureManager.getInstance()) && isWinterRacing2019Active())
         {
            if(Global.player.postInitFinished)
            {
               WinterRacingFeatureManager.getInstance().setUpHudWinterRacing2019();
               WinterRacingFeatureManager.getInstance().startRacingStoneGamebordTimer();
            }
            else
            {
               Global.world.addEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferredsetupWinterwRacing2019Hud,false,0,true);
            }
         }
         else if(Boolean(WinterRacingFeatureManager.getInstance()) && !isWinterRacing2019Active())
         {
            WinterRacingFeatureManager.getInstance().removeHud();
            WinterRacingFeatureManager.getInstance().removeRacingStoneMapTriggers();
         }
         WinterRacingFeatureManager.getInstance().startSkighGamebordTimer();
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XWS_STARTER) >= 1)
         {
            Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_STARTER_XWS));
         }
         var featureDef:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(CommunityGoalsManager.FEATURE_NAME);
         if(featureDef)
         {
            featureDef.updateIconVisibility();
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
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XWS_STARTER) >= 1)
         {
            Global.hud.rightSideIconQueue.removeIconByName(ICON_CODE_STARTER_XWS);
         }
         if(Global.hud)
         {
            Global.hud.removeBottomHudDec19InnovationButton();
            Global.hud.removesetHudWinterRacingFeature();
         }
         var featureDef:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(CommunityGoalsManager.FEATURE_NAME);
         if(featureDef)
         {
            featureDef.updateIconVisibility();
         }
         var featureDefBundle:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(TILE_BUNDLE_HUD);
         if(featureDefBundle)
         {
            featureDefBundle.updateIconVisibility();
         }
      }
      
      private function isDec19InnovationActive() : Boolean
      {
         var dec19InnovationManager:Dec19InnovationManager = null;
         var result:Boolean = false;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("dec19_innovation_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            dec19InnovationManager = Dec19InnovationManager.getInstance();
            if(Boolean(dec19InnovationManager) && Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_SANTAVILLAGE)
            {
               result = true;
            }
         }
         return result;
      }
      
      private function triggerDec19InnovationFeature(e:Event = null) : void
      {
         if(!Global.player.getSeenFlag(Dec19InnovationManager.HUD_INITIALISATION_FLAG))
         {
            Global.player.setSeenFlag(Dec19InnovationManager.HUD_INITIALISATION_FLAG);
            Dec19InnovationManager.getInstance(FEATURE_NAME).showMainUI();
         }
      }
      
      private function deferredsetupHud(e:Event = null) : void
      {
         if(Global.player.postInitFinished)
         {
            Global.world.removeEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferredsetupHud);
            if(Dec19InnovationManager.getInstance(FEATURE_NAME))
            {
               Dec19InnovationManager.getInstance(FEATURE_NAME).setupDec19Hud();
            }
         }
      }
      
      private function deferredsetupWinterwRacing2019Hud(e:Event = null) : void
      {
         if(Global.player.postInitFinished)
         {
            Global.world.removeEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferredsetupWinterwRacing2019Hud);
            if(WinterRacingFeatureManager.getInstance())
            {
               WinterRacingFeatureManager.getInstance().setUpHudWinterRacing2019();
               WinterRacingFeatureManager.getInstance().startRacingStoneGamebordTimer();
            }
         }
      }
   }
}

