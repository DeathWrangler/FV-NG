package Init.Worlds
{
   import Classes.Constants.Experiments;
   import Classes.Constants.WorldsConstants;
   import Classes.FeatureMessagingDefinition;
   import Classes.ImageLoader;
   import Classes.Quest.PrerequisiteUtility;
   import Events.FarmGameWorldEvent;
   import Init.PostInitActionHandlers.RightSideHUDIconInitAction;
   import Managers.AnimalSanctuaryV2Manager;
   import Managers.CommunityGoalsManager;
   import Managers.FeatureMessagingManager;
   import Managers.WinternordInnovationManager;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class WinternordWorldInit extends HomeWorldInit
   {
      
      public static const ICON_CODE_STARTER_XWX:String = "289";
      
      public static const FEATURE_NAME:String = "WinternordInnovation";
      
      private static const TILE_BUNDLE_HUD:String = "LandBundleWinternord";
      
      private static const UITemplatizationBgImages:Array = ["AnimalFrame_big_noBG.png","MOTD.png","AnimalFrame.png","AnimalFrame_big.png","MOTD_noTitle.png","NPC1_225.png","RewardDialog.png","MOTD_ShippingLicense.png","NPC2.png","FV_animal_breeding_aquarium.jpg","FV_animal_breeding_aviary.jpg","FV_animal_breeding_babypen.jpg","FV_animal_breeding_livestockpen.jpg","FV_animal_breeding_paddock.jpg","FV_animal_breeding_pasture.jpg","FV_animal_breeding_petrun.jpg","FV_animal_breeding_wildlifepen.jpg","FV_animal_breeding_zoopen.jpg"];
      
      private static const UITemplatizationSlotImages:Array = ["V100","V80","V55","H100","H60","Button100","treasureDialog","worldScoreIcon","CGTitleBar"];
      
      public function WinternordWorldInit()
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
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XWX_STARTER) >= 1)
         {
            Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_STARTER_XWX));
         }
         var featureDefBundle:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(TILE_BUNDLE_HUD);
         if(featureDefBundle)
         {
            featureDefBundle.updateIconVisibility();
         }
         if(Boolean(WinternordInnovationManager.getInstance(FEATURE_NAME)) && this.isWinternordInnovationActive())
         {
            if(Global.player.postInitFinished)
            {
               WinternordInnovationManager.getInstance(FEATURE_NAME).setupWinternordHud();
            }
            else
            {
               Global.world.addEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferredsetupHud,false,0,true);
            }
            this.triggerWinternordInnovationFeature();
            WinternordInnovationManager.getInstance(FEATURE_NAME).initEventListener();
         }
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
      
      private function isWinternordInnovationActive() : Boolean
      {
         var winternordInnovationManager:WinternordInnovationManager = null;
         var result:Boolean = false;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("winternord_innovation_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            winternordInnovationManager = WinternordInnovationManager.getInstance();
            if(Boolean(winternordInnovationManager) && Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_WINTERNORD)
            {
               result = true;
            }
         }
         return result;
      }
      
      private function triggerWinternordInnovationFeature(e:Event = null) : void
      {
         if(!Global.player.getSeenFlag(WinternordInnovationManager.HUD_INITIALISATION_FLAG))
         {
            Global.player.setSeenFlag(WinternordInnovationManager.HUD_INITIALISATION_FLAG);
            WinternordInnovationManager.getInstance(FEATURE_NAME).showMainUI();
         }
      }
      
      private function deferredsetupHud(e:Event = null) : void
      {
         if(Global.player.postInitFinished)
         {
            Global.world.removeEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferredsetupHud);
            if(WinternordInnovationManager.getInstance(FEATURE_NAME))
            {
               WinternordInnovationManager.getInstance(FEATURE_NAME).setupWinternordHud();
            }
         }
         if(Global.player.postInitFinished)
         {
            Global.world.removeEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferredsetupHud);
            if(AnimalSanctuaryV2Manager.getInstance())
            {
               AnimalSanctuaryV2Manager.getInstance().setupAnimalSanctuaryV2Hud();
            }
         }
      }
      
      override public function onLeaveWorld(destIsVisiting:Boolean) : void
      {
         super.onLeaveWorld(destIsVisiting);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XWX_STARTER) >= 1)
         {
            Global.hud.rightSideIconQueue.removeIconByName(ICON_CODE_STARTER_XWX);
         }
         var featureDefBundle:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(TILE_BUNDLE_HUD);
         if(featureDefBundle)
         {
            featureDefBundle.updateIconVisibility();
         }
         var featureDef:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(CommunityGoalsManager.FEATURE_NAME);
         if(featureDef)
         {
            featureDef.updateIconVisibility();
         }
         if(Global.hud)
         {
            Global.hud.removeBottomHudWinternordInnovationButton();
            Global.hud.removeBottomHudAnimalSanctuaryV2Button();
         }
      }
   }
}

