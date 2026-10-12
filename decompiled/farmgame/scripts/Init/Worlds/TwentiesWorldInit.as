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
   import Managers.TwentiesInnovationManager;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class TwentiesWorldInit extends HomeWorldInit
   {
      
      public static const ICON_CODE_STARTER_XRT:String = "292";
      
      public static const FEATURE_NAME:String = "TwentiesInnovation";
      
      private static const TILE_BUNDLE_HUD:String = "LandBundleTwenties";
      
      private static const UITemplatizationBgImages:Array = ["AnimalFrame_big_noBG.png","MOTD.png","MOTD_ShippingLicense.png","AnimalFrame.png","AnimalFrame_big.png","MOTD_noTitle.png","NPC1_225.png","RewardDialog.png","NPC2.png","FV_animal_breeding_aquarium.jpg","FV_animal_breeding_aviary.jpg","FV_animal_breeding_babypen.jpg","FV_animal_breeding_livestockpen.jpg","FV_animal_breeding_paddock.jpg","FV_animal_breeding_pasture.jpg","FV_animal_breeding_petrun.jpg","FV_animal_breeding_wildlifepen.jpg","FV_animal_breeding_zoopen.jpg"];
      
      private static const UITemplatizationSlotImages:Array = ["V100","V80","V55","H100","H60","Button100","treasureDialog","worldScoreIcon","CGTitleBar"];
      
      public function TwentiesWorldInit()
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
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XRT_STARTER) >= 1)
         {
            Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_STARTER_XRT));
         }
         var featureDef:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(CommunityGoalsManager.FEATURE_NAME);
         if(featureDef)
         {
            featureDef.updateIconVisibility();
         }
         if(Boolean(TwentiesInnovationManager.getInstance(FEATURE_NAME)) && this.isTwentiesInnovationActive())
         {
            if(Global.player.postInitFinished)
            {
               TwentiesInnovationManager.getInstance(FEATURE_NAME).setupTwentiesHud();
            }
            else
            {
               Global.world.addEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferredsetupHud,false,0,true);
            }
            this.triggerWinternordInnovationFeature();
            TwentiesInnovationManager.getInstance(FEATURE_NAME).initEventListener();
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
      
      private function isTwentiesInnovationActive() : Boolean
      {
         var twentiesInnovationManager:TwentiesInnovationManager = null;
         var result:Boolean = false;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("twenties_innovation_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            twentiesInnovationManager = TwentiesInnovationManager.getInstance();
            if(Boolean(twentiesInnovationManager) && Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_TWENTIES)
            {
               result = true;
            }
         }
         return result;
      }
      
      private function triggerWinternordInnovationFeature(e:Event = null) : void
      {
         if(!Global.player.getSeenFlag(TwentiesInnovationManager.HUD_INITIALISATION_FLAG))
         {
            Global.player.setSeenFlag(TwentiesInnovationManager.HUD_INITIALISATION_FLAG);
            TwentiesInnovationManager.getInstance(FEATURE_NAME).showMainUI();
         }
      }
      
      private function deferredsetupHud(e:Event = null) : void
      {
         if(Global.player.postInitFinished)
         {
            Global.world.removeEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferredsetupHud);
            if(TwentiesInnovationManager.getInstance(FEATURE_NAME))
            {
               TwentiesInnovationManager.getInstance(FEATURE_NAME).setupTwentiesHud();
            }
         }
      }
      
      override public function onLeaveWorld(destIsVisiting:Boolean) : void
      {
         super.onLeaveWorld(destIsVisiting);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XRT_STARTER) >= 1)
         {
            Global.hud.rightSideIconQueue.removeIconByName(ICON_CODE_STARTER_XRT);
         }
         var featureDef:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(CommunityGoalsManager.FEATURE_NAME);
         if(featureDef)
         {
            featureDef.updateIconVisibility();
         }
         if(Global.hud)
         {
            Global.hud.removeBottomHudTwentiesInnovationButton();
         }
      }
   }
}

