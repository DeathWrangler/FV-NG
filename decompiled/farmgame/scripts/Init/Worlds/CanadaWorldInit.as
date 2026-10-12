package Init.Worlds
{
   import Classes.Constants.Experiments;
   import Classes.Constants.WorldsConstants;
   import Classes.FeatureMessagingDefinition;
   import Classes.ImageLoader;
   import Classes.Quest.PrerequisiteUtility;
   import Events.FarmGameWorldEvent;
   import Init.PostInitActionHandlers.RightSideHUDIconInitAction;
   import Managers.AntiqueMuseumV2Manager;
   import Managers.CommunityGoalsManager;
   import Managers.FeatureMessagingManager;
   import Managers.OrderBoard.CanadaInnovationManager;
   import Managers.PunchCardFeatureManager;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class CanadaWorldInit extends HomeWorldInit
   {
      
      public static const ICON_CODE_STARTER_XCD:String = "303";
      
      private static const UITemplatizationBgImages:Array = ["AnimalFrame_big_noBG.png","MOTD.png","AnimalFrame.png","AnimalFrame_big.png","MOTD_noTitle.png","NPC1_225.png","RewardDialog.png","MOTD_ShippingLicense.png","NPC2.png","FV_animal_breeding_aquarium.jpg","FV_animal_breeding_aviary.jpg","FV_animal_breeding_babypen.jpg","FV_animal_breeding_livestockpen.jpg","FV_animal_breeding_paddock.jpg","FV_animal_breeding_pasture.jpg","FV_animal_breeding_petrun.jpg","FV_animal_breeding_wildlifepen.jpg","FV_animal_breeding_zoopen.jpg"];
      
      private static const UITemplatizationSlotImages:Array = ["V100","V80","V55","H100","H60","Button100","treasureDialog","worldScoreIcon","CGTitleBar"];
      
      private static const FEATURE_NAME:String = "CanadaInnovation";
      
      public function CanadaWorldInit()
      {
         super();
      }
      
      private static function onUrlLoaded(dispObj:DisplayObject, info:Object = null) : void
      {
      }
      
      private static function isAntiqueMuseumV2Active() : Boolean
      {
         var result:Boolean = false;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("antique_museum_v2_feature_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            if(Boolean(AntiqueMuseumV2Manager.getInstance()) && Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_CANADA)
            {
               result = true;
            }
         }
         return result;
      }
      
      private static function isAntiqueMuseumV2HudActive() : Boolean
      {
         var result:Boolean = false;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("antique_museum_v2_hud_feature_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            result = true;
         }
         return result;
      }
      
      override public function onEnterWorld(resultData:Object) : void
      {
         var image:String = null;
         var slotImageTag:String = null;
         var imageUrl:String = null;
         var antiqueMuseumV2featureDef:FeatureMessagingDefinition = null;
         super.onEnterWorld(resultData);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XCD_STARTER) >= 1)
         {
            Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_STARTER_XCD));
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
         if(Boolean(PunchCardFeatureManager.getInstance()) && this.isPunchCardHudActive())
         {
            if(Global.player.postInitFinished)
            {
               PunchCardFeatureManager.getInstance().setupHud();
            }
            else
            {
               Global.world.addEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferredsetupHud,false,0,true);
            }
         }
         if(Boolean(CanadaInnovationManager.getInstance(FEATURE_NAME)) && Boolean(this.isCanadaInnovationActive()) && !Global.player.getSeenFlag(CanadaInnovationManager.HUD_INITIALISATION_FLAG_HARVEST))
         {
            if(Global.player.postInitFinished)
            {
               CanadaInnovationManager.getInstance(FEATURE_NAME).setupCanadaInnovationHud();
            }
            else
            {
               Global.world.addEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferredsetupHud,false,0,true);
            }
            this.triggerCanadaInnovationFeature();
            CanadaInnovationManager.getInstance(FEATURE_NAME).initEventListener();
         }
         if(Boolean(AntiqueMuseumV2Manager.getInstance()) && Boolean(!Global.player.getSeenFlag(AntiqueMuseumV2Manager.AMV2MOTD_SEEN)) && isAntiqueMuseumV2Active())
         {
            Global.player.setSeenFlag(AntiqueMuseumV2Manager.AMV2MOTD_SEEN);
            AntiqueMuseumV2Manager.getInstance().showMainWindow();
         }
         if(Boolean(AntiqueMuseumV2Manager.getInstance()) && isAntiqueMuseumV2HudActive())
         {
            antiqueMuseumV2featureDef = FeatureMessagingManager.getInstance().getFeatureDefinition(AntiqueMuseumV2Manager.FEATURE_NAME);
            if(antiqueMuseumV2featureDef)
            {
               antiqueMuseumV2featureDef.updateIconVisibility();
            }
         }
      }
      
      override public function onLeaveWorld(destIsVisiting:Boolean) : void
      {
         var antiqueMuseumV2featureDef:FeatureMessagingDefinition = null;
         var hudData:FeatureMessagingDefinition = null;
         super.onLeaveWorld(destIsVisiting);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XCD_STARTER) >= 1)
         {
            Global.hud.rightSideIconQueue.removeIconByName(ICON_CODE_STARTER_XCD);
         }
         var featureDef:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(CommunityGoalsManager.FEATURE_NAME);
         if(featureDef)
         {
            featureDef.updateIconVisibility();
         }
         if(Global.hud)
         {
            Global.hud.removeBottomHudCanadaInnovationButton();
         }
         if(CanadaInnovationManager.getInstance(FEATURE_NAME))
         {
            CanadaInnovationManager.getInstance(FEATURE_NAME).deleteEventListener();
         }
         if(Boolean(AntiqueMuseumV2Manager.getInstance()) && isAntiqueMuseumV2HudActive())
         {
            antiqueMuseumV2featureDef = FeatureMessagingManager.getInstance().getFeatureDefinition(AntiqueMuseumV2Manager.FEATURE_NAME);
            if(antiqueMuseumV2featureDef)
            {
               antiqueMuseumV2featureDef.updateIconVisibility();
            }
         }
         if(this.isPunchCardHudActive())
         {
            hudData = FeatureMessagingManager.getInstance().getFeatureDefinition("PunchCard");
            if(hudData)
            {
               hudData.updateIconVisibility();
            }
         }
      }
      
      private function isCanadaInnovationActive() : Boolean
      {
         var InnovationManager:CanadaInnovationManager = null;
         var result:Boolean = false;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("CanadaInnovation_harvest_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            InnovationManager = CanadaInnovationManager.getInstance(FEATURE_NAME);
            if(Boolean(InnovationManager) && Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_CANADA)
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
            if(CanadaInnovationManager.getInstance(FEATURE_NAME))
            {
               CanadaInnovationManager.getInstance(FEATURE_NAME).setupCanadaInnovationHud();
            }
            if(Boolean(AntiqueMuseumV2Manager.getInstance()) && Boolean(!Global.player.getSeenFlag(AntiqueMuseumV2Manager.AMV2MOTD_SEEN)) && isAntiqueMuseumV2Active())
            {
               Global.player.setSeenFlag(AntiqueMuseumV2Manager.AMV2MOTD_SEEN);
               AntiqueMuseumV2Manager.getInstance().showMainWindow();
            }
            if(PunchCardFeatureManager.getInstance())
            {
               PunchCardFeatureManager.getInstance().setupHud();
            }
         }
      }
      
      private function triggerCanadaInnovationFeature(e:Event = null) : void
      {
         if(!Global.player.getSeenFlag(CanadaInnovationManager.HUD_INITIALISATION_FLAG))
         {
            Global.player.setSeenFlag(CanadaInnovationManager.HUD_INITIALISATION_FLAG);
            CanadaInnovationManager.getInstance(FEATURE_NAME).showMainUI();
         }
      }
      
      public function isPunchCardHudActive() : Boolean
      {
         var result:Boolean = false;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("punch_card_hudicon_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            result = true;
         }
         return result;
      }
   }
}

