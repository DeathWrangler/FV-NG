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
   import Managers.MadagascarInnovationManager;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class MadagascarWorldInit extends HomeWorldInit
   {
      
      public static const ICON_CODE_STARTER_XMT:String = "300";
      
      public static const FEATURE_NAME:String = "MadagascarInnovation";
      
      private static const TILE_BUNDLE_HUD:String = "LandBundleMadagascar";
      
      private static const UITemplatizationBgImages:Array = ["AnimalFrame_big_noBG.png","MOTD.png","AnimalFrame.png","AnimalFrame_big.png","MOTD_noTitle.png","NPC1_225.png","RewardDialog.png","MOTD_ShippingLicense.png","NPC2.png","FV_animal_breeding_aquarium.jpg","FV_animal_breeding_aviary.jpg","FV_animal_breeding_babypen.jpg","FV_animal_breeding_livestockpen.jpg","FV_animal_breeding_paddock.jpg","FV_animal_breeding_pasture.jpg","FV_animal_breeding_petrun.jpg","FV_animal_breeding_wildlifepen.jpg","FV_animal_breeding_zoopen.jpg"];
      
      private static const UITemplatizationSlotImages:Array = ["V100","V80","V55","H100","H60","Button100","treasureDialog","worldScoreIcon","CGTitleBar"];
      
      public function MadagascarWorldInit()
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
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XMT_STARTER) >= 1)
         {
            Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_STARTER_XMT));
         }
         if(Boolean(MadagascarInnovationManager.getInstance(FEATURE_NAME)) && this.isMadagascarInnovationActive())
         {
            if(Global.player.postInitFinished)
            {
               MadagascarInnovationManager.getInstance(FEATURE_NAME).setupMadagascarHud();
            }
            else
            {
               Global.world.addEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferredsetupHud,false,0,true);
            }
            this.triggerMadagascarInnovationFeature();
            MadagascarInnovationManager.getInstance(FEATURE_NAME).initEventListener();
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
         featureDefBundle = FeatureMessagingManager.getInstance().getFeatureDefinition(TILE_BUNDLE_HUD);
         if(featureDefBundle)
         {
            featureDefBundle.updateIconVisibility();
         }
      }
      
      private function isMadagascarInnovationActive() : Boolean
      {
         var madagascarInnovationManager:MadagascarInnovationManager = null;
         var result:Boolean = false;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("madagascar_innovation_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            madagascarInnovationManager = MadagascarInnovationManager.getInstance();
            if(Boolean(madagascarInnovationManager) && Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_MADAGASCAR)
            {
               result = true;
            }
         }
         return result;
      }
      
      private function triggerMadagascarInnovationFeature(e:Event = null) : void
      {
         if(!Global.player.getSeenFlag(MadagascarInnovationManager.HUD_INITIALISATION_FLAG))
         {
            Global.player.setSeenFlag(MadagascarInnovationManager.HUD_INITIALISATION_FLAG);
            MadagascarInnovationManager.getInstance(FEATURE_NAME).showMainUI();
         }
      }
      
      private function deferredsetupHud(e:Event = null) : void
      {
         if(Global.player.postInitFinished)
         {
            Global.world.removeEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferredsetupHud);
            if(MadagascarInnovationManager.getInstance(FEATURE_NAME))
            {
               MadagascarInnovationManager.getInstance(FEATURE_NAME).setupMadagascarHud();
            }
         }
      }
      
      override public function onLeaveWorld(destIsVisiting:Boolean) : void
      {
         super.onLeaveWorld(destIsVisiting);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XMT_STARTER) >= 1)
         {
            Global.hud.rightSideIconQueue.removeIconByName(ICON_CODE_STARTER_XMT);
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
         if(Global.hud)
         {
            Global.hud.removeBottomHudMadagascarInnovationButton();
         }
      }
   }
}

