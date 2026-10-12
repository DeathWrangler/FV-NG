package Init.Worlds
{
   import Classes.Constants.Experiments;
   import Classes.FeatureMessagingDefinition;
   import Classes.ImageLoader;
   import Init.PostInitActionHandlers.RightSideHUDIconInitAction;
   import Managers.CommunityGoalsManager;
   import Managers.FeatureMessagingManager;
   import Managers.TuscanyInnovationManager;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class TuscanyWorldInit extends HomeWorldInit
   {
      
      public static const ICON_CODE_STARTER_XTY:String = "282";
      
      private static const UITemplatizationBgImages:Array = ["AnimalFrame_big_noBG.png","MOTD.png","AnimalFrame.png","AnimalFrame_big.png","MOTD_noTitle.png","NPC1_225.png","RewardDialog.png","NPC2.png","FV_animal_breeding_aquarium.jpg","FV_animal_breeding_aviary.jpg","FV_animal_breeding_babypen.jpg","FV_animal_breeding_livestockpen.jpg","FV_animal_breeding_paddock.jpg","FV_animal_breeding_pasture.jpg","FV_animal_breeding_petrun.jpg","FV_animal_breeding_wildlifepen.jpg","FV_animal_breeding_zoopen.jpg"];
      
      private static const UITemplatizationSlotImages:Array = ["V100","V80","V55","H100","H60","Button100","treasureDialog","worldScoreIcon","CGTitleBar"];
      
      private const TUSCANY_IINOVATION_EA_FLAG:String = "tuscanyInnovation_EA_Tutorial";
      
      public function TuscanyWorldInit()
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
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XTY_STARTER) >= 1)
         {
            Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_STARTER_XTY));
         }
         var featureDef:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(CommunityGoalsManager.FEATURE_NAME);
         if(featureDef)
         {
            featureDef.updateIconVisibility();
         }
         TuscanyInnovationManager.getInstance().initEventListener();
         var featureDefinition:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(TuscanyInnovationManager.FEATURE_OPTIONS_KEY);
         if(featureDefinition)
         {
            if(!FeatureMessagingManager.getInstance().isFeatureActive(TuscanyInnovationManager.FEATURE_OPTIONS_KEY))
            {
               if(featureDefinition.passesPrereqs() && !Global.player.getSeenSessionFlag(TuscanyInnovationManager.HUD_INITIALISATION_FLAG))
               {
                  if(featureDefinition.customInit)
                  {
                     featureDefinition.customInit.initialize();
                     Global.player.setSeenSessionFlag(TuscanyInnovationManager.HUD_INITIALISATION_FLAG);
                  }
               }
            }
            featureDefinition.updateIconVisibility();
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
         this.triggerTutorialPage();
      }
      
      override public function onLeaveWorld(destIsVisiting:Boolean) : void
      {
         super.onLeaveWorld(destIsVisiting);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XTY_STARTER) >= 1)
         {
            Global.hud.rightSideIconQueue.removeIconByName(ICON_CODE_STARTER_XTY);
         }
         var featureDef:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(CommunityGoalsManager.FEATURE_NAME);
         if(featureDef)
         {
            featureDef.updateIconVisibility();
         }
         var innovationFeatureDef:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(TuscanyInnovationManager.FEATURE_NAME);
         if(innovationFeatureDef)
         {
            innovationFeatureDef.updateIconVisibility();
         }
      }
      
      private function triggerTutorialPage(e:Event = null) : void
      {
         if(!Global.player.getSeenFlag(this.TUSCANY_IINOVATION_EA_FLAG))
         {
            Global.player.setSeenFlag(this.TUSCANY_IINOVATION_EA_FLAG);
            TuscanyInnovationManager.getInstance().showMainUI();
         }
      }
   }
}

