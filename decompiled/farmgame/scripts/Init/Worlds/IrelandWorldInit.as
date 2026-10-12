package Init.Worlds
{
   import Classes.Constants.Experiments;
   import Classes.Constants.WorldsConstants;
   import Classes.FeatureMessagingDefinition;
   import Classes.ImageLoader;
   import Classes.Quest.PrerequisiteUtility;
   import Display.HUD.HUDWidgets.HudBottomLandBundleUnlockFeature;
   import Events.FarmGameWorldEvent;
   import Init.PostInitActionHandlers.RightSideHUDIconInitAction;
   import Managers.CommunityGoalsManager;
   import Managers.FeatureMessagingManager;
   import Managers.OrderBoard.IrelandInnovationManager;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class IrelandWorldInit extends HomeWorldInit
   {
      
      public static const ICON_CODE_STARTER_XID:String = "296";
      
      public static const FEATURE_NAME:String = "IrelandInnovation";
      
      private static const UITemplatizationBgImages:Array = ["AnimalFrame_big_noBG.png","MOTD.png","AnimalFrame.png","AnimalFrame_big.png","MOTD_noTitle.png","NPC1_225.png","RewardDialog.png","MOTD_ShippingLicense.png","NPC2.png","FV_animal_breeding_aquarium.jpg","FV_animal_breeding_aviary.jpg","FV_animal_breeding_babypen.jpg","FV_animal_breeding_livestockpen.jpg","FV_animal_breeding_paddock.jpg","FV_animal_breeding_pasture.jpg","FV_animal_breeding_petrun.jpg","FV_animal_breeding_wildlifepen.jpg","FV_animal_breeding_zoopen.jpg"];
      
      private static const UITemplatizationSlotImages:Array = ["V100","V80","V55","H100","H60","Button100","treasureDialog","worldScoreIcon","CGTitleBar"];
      
      public function IrelandWorldInit()
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
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XID_STARTER) >= 1)
         {
            Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_STARTER_XID));
         }
         var featureDef:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(CommunityGoalsManager.FEATURE_NAME);
         if(featureDef)
         {
            featureDef.updateIconVisibility();
         }
         if(Boolean(IrelandInnovationManager.getInstance(FEATURE_NAME)) && this.isIrelandInnovationActive())
         {
            if(Global.player.postInitFinished)
            {
               IrelandInnovationManager.getInstance(FEATURE_NAME).setupIrelanddHud();
            }
            else
            {
               Global.world.addEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferredsetupHud,false,0,true);
            }
            this.triggerIrelandInnovationFeature();
            IrelandInnovationManager.getInstance(FEATURE_NAME).initEventListener();
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
         if(PrerequisiteUtility.isPrerequisiteMet(Global.farmGameSettingsManager.getPrereqByName("land_bundle_unlock_feature_enabled")))
         {
            if(Global.hud)
            {
               Global.hud.setHudLandBundleUnlockFeature(new HudBottomLandBundleUnlockFeature("assets/dialogs/ireland/LandBundle/Deploy/FV_xid_hud_Innovation.swf","LandBundleUnlockFeature"));
            }
         }
      }
      
      private function isIrelandInnovationActive() : Boolean
      {
         var irelandManager:IrelandInnovationManager = null;
         var result:Boolean = false;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("ireland_innovation_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            irelandManager = IrelandInnovationManager.getInstance();
            if(Boolean(irelandManager) && Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_IRELAND)
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
            if(IrelandInnovationManager.getInstance(FEATURE_NAME))
            {
               IrelandInnovationManager.getInstance(FEATURE_NAME).setupIrelanddHud();
            }
         }
      }
      
      private function triggerIrelandInnovationFeature(e:Event = null) : void
      {
         if(!Global.player.getSeenFlag(IrelandInnovationManager.HUD_INITIALISATION_FLAG))
         {
            Global.player.setSeenFlag(IrelandInnovationManager.HUD_INITIALISATION_FLAG);
            IrelandInnovationManager.getInstance(FEATURE_NAME).showMainUI();
         }
      }
      
      override public function onLeaveWorld(destIsVisiting:Boolean) : void
      {
         super.onLeaveWorld(destIsVisiting);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XID_STARTER) >= 1)
         {
            Global.hud.rightSideIconQueue.removeIconByName(ICON_CODE_STARTER_XID);
         }
         if(Global.hud)
         {
            Global.hud.removeBottomHudIrelandInnovationButton();
            Global.hud.removeBottomHudLandBundleUnlockFeatureButton();
         }
         var featureDef:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(CommunityGoalsManager.FEATURE_NAME);
         if(featureDef)
         {
            featureDef.updateIconVisibility();
         }
      }
   }
}

