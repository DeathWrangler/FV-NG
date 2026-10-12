package Init.Worlds
{
   import Classes.Constants.Experiments;
   import Classes.Constants.WorldsConstants;
   import Classes.FeatureMessagingDefinition;
   import Classes.ImageLoader;
   import Classes.Quest.PrerequisiteUtility;
   import Init.PostInitActionHandlers.RightSideHUDIconInitAction;
   import Managers.CommunityGoalsManager;
   import Managers.FeatureMessagingManager;
   import Managers.OrderBoard.HalloweenInnovationManager;
   import Managers.WorldSeasonsManager;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class HalloweenusaWorldInit extends HomeWorldInit
   {
      
      public static const ICON_CODE_STARTER_XHA:String = "280";
      
      private static const UITemplatizationBgImages:Array = ["AnimalFrame_big_noBG.png","MOTD.png","AnimalFrame.png","MOTD_UnwitherRing.png","MOTD_ShippingLicense.png","AnimalFrame_big.png","MOTD_noTitle.png","NPC1_225.png","RewardDialog.png","NPC2.png","FV_animal_breeding_aquarium.jpg","FV_animal_breeding_aviary.jpg","FV_animal_breeding_babypen.jpg","FV_animal_breeding_livestockpen.jpg","FV_animal_breeding_paddock.jpg","FV_animal_breeding_pasture.jpg","FV_animal_breeding_petrun.jpg","FV_animal_breeding_wildlifepen.jpg","FV_animal_breeding_zoopen.jpg","EliteHorsesFrame.png"];
      
      private static const UITemplatizationSlotImages:Array = ["V100","V80","V55","H100","H60","Button100","treasureDialog","worldScoreIcon","CGTitleBar"];
      
      private const HALLOWEENUSAINNOVATION_EA_FLAG:String = "halloweenusainnovation_EA_Tutorial";
      
      public function HalloweenusaWorldInit()
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
         var prereq:Object = null;
         var imageUrl:String = null;
         super.onEnterWorld(resultData);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XHA_STARTER) >= 1)
         {
            Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_STARTER_XHA));
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
         prereq = Global.farmGameSettingsManager.getPrereqByName("halloweenusa_feature_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            HalloweenInnovationManager.getInstance().initEventListener();
            this.triggerConditionalTutorialPage();
         }
      }
      
      override public function onLeaveWorld(destIsVisiting:Boolean) : void
      {
         super.onLeaveWorld(destIsVisiting);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XHA_STARTER) >= 1)
         {
            Global.hud.rightSideIconQueue.removeIconByName(ICON_CODE_STARTER_XHA);
         }
         var featureDef:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(CommunityGoalsManager.FEATURE_NAME);
         if(featureDef)
         {
            featureDef.updateIconVisibility();
         }
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("halloweenusa_feature_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            HalloweenInnovationManager.getInstance().deleteEventListener();
         }
      }
      
      private function triggerConditionalTutorialPage(e:Event = null) : void
      {
         var tutorialSeenFlag:String = null;
         var showTutorialWithEAPage:Boolean = false;
         if(!Global.player.getSeenFlag(this.HALLOWEENUSAINNOVATION_EA_FLAG))
         {
            Global.player.setSeenFlag(this.HALLOWEENUSAINNOVATION_EA_FLAG);
            if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_HALLOWEENUSA))
            {
               tutorialSeenFlag = "HalloweenUSAInnovation_Tutorial";
               showTutorialWithEAPage = false;
               if(Global.player.getSeenFlag(tutorialSeenFlag))
               {
                  showTutorialWithEAPage = true;
               }
               HalloweenInnovationManager.getInstance().showMainUI(showTutorialWithEAPage);
            }
         }
      }
   }
}

