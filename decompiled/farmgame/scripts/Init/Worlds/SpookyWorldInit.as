package Init.Worlds
{
   import Classes.Constants.Experiments;
   import Classes.Constants.WorldsConstants;
   import Classes.FeatureMessagingDefinition;
   import Classes.ImageLoader;
   import Classes.Quest.PrerequisiteUtility;
   import Events.FarmGameWorldEvent;
   import Init.PostInitActionHandlers.RightSideHUDIconInitAction;
   import Managers.AntiqueMuseumManager;
   import Managers.CommunityGoalsManager;
   import Managers.FeatureMessagingManager;
   import Managers.OrderBoard.Halloween2019InnovationManager;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class SpookyWorldInit extends HomeWorldInit
   {
      
      public static const ICON_CODE_STARTER_XHF:String = "297";
      
      private static const UITemplatizationBgImages:Array = ["AnimalFrame_big_noBG.png","MOTD.png","AnimalFrame.png","AnimalFrame_big.png","MOTD_noTitle.png","NPC1_225.png","RewardDialog.png","MOTD_ShippingLicense.png","NPC2.png","FV_animal_breeding_aquarium.jpg","FV_animal_breeding_aviary.jpg","FV_animal_breeding_babypen.jpg","FV_animal_breeding_livestockpen.jpg","FV_animal_breeding_paddock.jpg","FV_animal_breeding_pasture.jpg","FV_animal_breeding_petrun.jpg","FV_animal_breeding_wildlifepen.jpg","FV_animal_breeding_zoopen.jpg"];
      
      private static const UITemplatizationSlotImages:Array = ["V100","V80","V55","H100","H60","Button100","treasureDialog","worldScoreIcon","CGTitleBar"];
      
      private static const FEATURE_NAME:String = "Halloween2019Innovation";
      
      public function SpookyWorldInit()
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
         var imageUrl:String = null;
         super.onEnterWorld(resultData);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XHF_STARTER) >= 1)
         {
            Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_STARTER_XHF));
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
         if(Boolean(Halloween2019InnovationManager.getInstance(FEATURE_NAME)) && Boolean(this.isHalloweenInnovation2019Active()) && !Global.player.getSeenFlag(Halloween2019InnovationManager.HUD_INITIALISATION_FLAG_HARVEST))
         {
            if(Global.player.postInitFinished)
            {
               Halloween2019InnovationManager.getInstance(FEATURE_NAME).setupHalloweenInnovationHud();
            }
            else
            {
               Global.world.addEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferredsetupHud,false,0,true);
            }
            this.triggerHalloweenInnovationFeature();
            Halloween2019InnovationManager.getInstance(FEATURE_NAME).initEventListener();
         }
      }
      
      override public function onLeaveWorld(destIsVisiting:Boolean) : void
      {
         super.onLeaveWorld(destIsVisiting);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XHF_STARTER) >= 1)
         {
            Global.hud.rightSideIconQueue.removeIconByName(ICON_CODE_STARTER_XHF);
         }
         var featureDef:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(CommunityGoalsManager.FEATURE_NAME);
         if(featureDef)
         {
            featureDef.updateIconVisibility();
         }
         var antiqueFeatureDef:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(AntiqueMuseumManager.FEATURE_NAME);
         if(antiqueFeatureDef)
         {
            antiqueFeatureDef.updateIconVisibility();
         }
         if(Global.hud)
         {
            Global.hud.removeBottomHudHalloweenInnovation2019Button();
         }
         if(Halloween2019InnovationManager.getInstance(FEATURE_NAME))
         {
            Halloween2019InnovationManager.getInstance(FEATURE_NAME).deleteEventListener();
         }
      }
      
      private function isHalloweenInnovation2019Active() : Boolean
      {
         var InnovationManager:Halloween2019InnovationManager = null;
         var result:Boolean = false;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("HalloweenInnovation2019_harvest_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            InnovationManager = Halloween2019InnovationManager.getInstance(FEATURE_NAME);
            if(Boolean(InnovationManager) && Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_SPOOKY)
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
            if(Halloween2019InnovationManager.getInstance(FEATURE_NAME))
            {
               Halloween2019InnovationManager.getInstance(FEATURE_NAME).setupHalloweenInnovationHud();
            }
         }
      }
      
      private function triggerHalloweenInnovationFeature(e:Event = null) : void
      {
         if(!Global.player.getSeenFlag(Halloween2019InnovationManager.HUD_INITIALISATION_FLAG))
         {
            Global.player.setSeenFlag(Halloween2019InnovationManager.HUD_INITIALISATION_FLAG);
            Halloween2019InnovationManager.getInstance(FEATURE_NAME).showMainUI();
         }
      }
   }
}

