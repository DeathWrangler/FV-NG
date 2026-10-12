package Init.Worlds
{
   import Classes.Constants.Experiments;
   import Classes.FeatureMessagingDefinition;
   import Classes.ImageLoader;
   import Events.FarmGameWorldEvent;
   import Init.PostInitActionHandlers.RightSideHUDIconInitAction;
   import Managers.CommunityGoalsManager;
   import Managers.FeatureMessagingManager;
   import Managers.OrderBoard.CarribeanInnovationManager;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class CaribbeanWorldInit extends HomeWorldInit
   {
      
      public static const ICON_CODE_STARTER_XCB:String = "284";
      
      private static const TILE_BUNDLE_HUD:String = "LandBundleCaribbean";
      
      private static const UITemplatizationBgImages:Array = ["AnimalFrame_big_noBG.png","MOTD.png","AnimalFrame.png","AnimalFrame_big.png","MOTD_noTitle.png","NPC1_225.png","RewardDialog.png","NPC2.png","FV_animal_breeding_aquarium.jpg","FV_animal_breeding_aviary.jpg","FV_animal_breeding_babypen.jpg","FV_animal_breeding_livestockpen.jpg","FV_animal_breeding_paddock.jpg","FV_animal_breeding_pasture.jpg","FV_animal_breeding_petrun.jpg","FV_animal_breeding_wildlifepen.jpg","FV_animal_breeding_zoopen.jpg"];
      
      private static const UITemplatizationSlotImages:Array = ["V100","V80","V55","H100","H60","Button100","treasureDialog","worldScoreIcon","CGTitleBar"];
      
      public static const FTUE_SEEN_FLAG:String = "Carribean_Welcome_flag";
      
      private const FEATURE_NAME:String = "CarribeanInnovation";
      
      public function CaribbeanWorldInit()
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
         var featureDef1:FeatureMessagingDefinition = null;
         var imageUrl:String = null;
         super.onEnterWorld(resultData);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XCB_STARTER) >= 1)
         {
            Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_STARTER_XCB));
         }
         var featureDef:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(CommunityGoalsManager.FEATURE_NAME);
         if(featureDef)
         {
            featureDef.updateIconVisibility();
         }
         if(Boolean(CarribeanInnovationManager.getInstance(this.FEATURE_NAME)) && CarribeanInnovationManager.getInstance(this.FEATURE_NAME).isFeatureActive)
         {
            if(Global.player.postInitFinished)
            {
               CarribeanInnovationManager.getInstance(this.FEATURE_NAME).setupCarribeanHud();
               CarribeanInnovationManager.getInstance(this.FEATURE_NAME).updateMapTriggers();
            }
            else
            {
               Global.world.addEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferredsetupHud,false,0,true);
            }
            this.triggerCarribeanInnovationFeature();
            CarribeanInnovationManager.getInstance(this.FEATURE_NAME).initEventListener();
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
         featureDef1 = FeatureMessagingManager.getInstance().getFeatureDefinition(TILE_BUNDLE_HUD);
         if(featureDef1)
         {
            featureDef1.updateIconVisibility();
         }
      }
      
      override public function onLeaveWorld(destIsVisiting:Boolean) : void
      {
         super.onLeaveWorld(destIsVisiting);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XCB_STARTER) >= 1)
         {
            Global.hud.rightSideIconQueue.removeIconByName(ICON_CODE_STARTER_XCB);
         }
         var featureDef:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(CommunityGoalsManager.FEATURE_NAME);
         if(featureDef)
         {
            featureDef.updateIconVisibility();
         }
         var featureDef1:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(TILE_BUNDLE_HUD);
         if(featureDef1)
         {
            featureDef1.updateIconVisibility();
         }
         if(Global.hud)
         {
            Global.hud.removeBottomHudCarribeanInnovationButton();
         }
      }
      
      private function triggerCarribeanInnovationFeature(e:Event = null) : void
      {
         if(!Global.player.getSeenFlag(FTUE_SEEN_FLAG))
         {
            CarribeanInnovationManager.getInstance(this.FEATURE_NAME).showMainUI();
         }
      }
      
      private function deferredsetupHud(e:Event = null) : void
      {
         if(Global.player.postInitFinished)
         {
            Global.world.removeEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferredsetupHud);
            if(CarribeanInnovationManager.getInstance(this.FEATURE_NAME))
            {
               CarribeanInnovationManager.getInstance(this.FEATURE_NAME).setupCarribeanHud();
               CarribeanInnovationManager.getInstance(this.FEATURE_NAME).updateMapTriggers();
            }
         }
      }
   }
}

