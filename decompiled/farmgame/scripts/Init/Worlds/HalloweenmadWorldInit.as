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
   import Managers.OrderBoard.HalloweenInnovationGhoulManager;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class HalloweenmadWorldInit extends HomeWorldInit
   {
      
      public static const ICON_CODE_STARTER_XHX:String = "288";
      
      public static const FEATURE_NAME:String = "HalloweenInnovationGhoul";
      
      private static const UITemplatizationBgImages:Array = ["AnimalFrame_big_noBG.png","MOTD.png","AnimalFrame.png","AnimalFrame_big.png","MOTD_noTitle.png","NPC1_225.png","RewardDialog.png","MOTD_ShippingLicense.png","NPC2.png","FV_animal_breeding_aquarium.jpg","FV_animal_breeding_aviary.jpg","FV_animal_breeding_babypen.jpg","FV_animal_breeding_livestockpen.jpg","FV_animal_breeding_paddock.jpg","FV_animal_breeding_pasture.jpg","FV_animal_breeding_petrun.jpg","FV_animal_breeding_wildlifepen.jpg","FV_animal_breeding_zoopen.jpg"];
      
      private static const UITemplatizationSlotImages:Array = ["V100","V80","V55","H100","H60","Button100","treasureDialog","worldScoreIcon","CGTitleBar"];
      
      public function HalloweenmadWorldInit()
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
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XHX_STARTER) >= 1)
         {
            Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_STARTER_XHX));
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
         if(Boolean(HalloweenInnovationGhoulManager.getInstance(FEATURE_NAME)) && this.isHalloweenInnovationGhoulActive())
         {
            if(Global.player.postInitFinished)
            {
               HalloweenInnovationGhoulManager.getInstance(FEATURE_NAME).setupHalloweenInnovationGhoulHud();
            }
            else
            {
               Global.world.addEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferredsetupHud,false,0,true);
            }
            this.triggerHalloweenInnovationGhoulFeature();
            HalloweenInnovationGhoulManager.getInstance(FEATURE_NAME).initEventListener();
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
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XHX_STARTER) >= 1)
         {
            Global.hud.rightSideIconQueue.removeIconByName(ICON_CODE_STARTER_XHX);
         }
         var featureDef:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(CommunityGoalsManager.FEATURE_NAME);
         if(featureDef)
         {
            featureDef.updateIconVisibility();
         }
         if(Global.hud)
         {
            Global.hud.removeBottomHudHalloweenInnovationGhoulButton();
         }
         if(HalloweenInnovationGhoulManager.getInstance(FEATURE_NAME))
         {
            HalloweenInnovationGhoulManager.getInstance(FEATURE_NAME).deleteEventListener();
         }
      }
      
      private function isHalloweenInnovationGhoulActive() : Boolean
      {
         var InnovationManager:HalloweenInnovationGhoulManager = null;
         var result:Boolean = false;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("HalloweenInnovationGhoul_innovation_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            InnovationManager = HalloweenInnovationGhoulManager.getInstance(FEATURE_NAME);
            if(Boolean(InnovationManager) && Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_HALLOWEENMAD)
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
            if(HalloweenInnovationGhoulManager.getInstance(FEATURE_NAME))
            {
               HalloweenInnovationGhoulManager.getInstance(FEATURE_NAME).setupHalloweenInnovationGhoulHud();
            }
         }
      }
      
      private function triggerHalloweenInnovationGhoulFeature(e:Event = null) : void
      {
         if(!Global.player.getSeenFlag(HalloweenInnovationGhoulManager.HUD_INITIALISATION_FLAG))
         {
            Global.player.setSeenFlag(HalloweenInnovationGhoulManager.HUD_INITIALISATION_FLAG);
            HalloweenInnovationGhoulManager.getInstance(FEATURE_NAME).showMainUI();
         }
      }
   }
}

