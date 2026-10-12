package Init.Worlds
{
   import Classes.Constants.Experiments;
   import Classes.Constants.WorldsConstants;
   import Classes.FeatureMessagingDefinition;
   import Classes.ImageLoader;
   import Classes.Quest.PrerequisiteUtility;
   import Events.FarmGameWorldEvent;
   import Init.PostInitActionHandlers.RightSideHUDIconInitAction;
   import Managers.AmsterdamInnovationManager;
   import Managers.CommunityGoalsManager;
   import Managers.FeatureMessagingManager;
   import Managers.JumbleVillaManager;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class AmsterdamWorldInit extends HomeWorldInit
   {
      
      public static const ICON_CODE_STARTER_XDM:String = "302";
      
      private static const TILE_BUNDLE_HUD:String = "LandBundleAmsterdam";
      
      private static const UITemplatizationBgImages:Array = ["AnimalFrame_big_noBG.png","MOTD.png","AnimalFrame.png","AnimalFrame_big.png","MOTD_noTitle.png","NPC1_225.png","RewardDialog.png","MOTD_ShippingLicense.png","NPC2.png","FV_animal_breeding_aquarium.jpg","FV_animal_breeding_aviary.jpg","FV_animal_breeding_babypen.jpg","FV_animal_breeding_livestockpen.jpg","FV_animal_breeding_paddock.jpg","FV_animal_breeding_pasture.jpg","FV_animal_breeding_petrun.jpg","FV_animal_breeding_wildlifepen.jpg","FV_animal_breeding_zoopen.jpg"];
      
      private static const UITemplatizationSlotImages:Array = ["V100","V80","V55","H100","H60","Button100","treasureDialog","worldScoreIcon","CGTitleBar"];
      
      public function AmsterdamWorldInit()
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
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XDM_STARTER) >= 1)
         {
            Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_STARTER_XDM));
         }
         var jumbleVillaManager:JumbleVillaManager = JumbleVillaManager.getInstance("JumbleVilla");
         if(jumbleVillaManager)
         {
            if(jumbleVillaManager.isFeatureinActivePeriod() || jumbleVillaManager.isInStoryMode())
            {
               if(Global.player.postInitFinished)
               {
                  JumbleVillaManager.getInstance("JumbleVilla").setupHud();
               }
               else
               {
                  Global.world.addEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferredsetupHudJumbleVilla,false,0,true);
               }
            }
         }
         var featureDefBundle:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(TILE_BUNDLE_HUD);
         if(featureDefBundle)
         {
            featureDefBundle.updateIconVisibility();
         }
         var amsterdamManager:AmsterdamInnovationManager = AmsterdamInnovationManager.getInstance("AmsterdamInnovation");
         if(amsterdamManager)
         {
            amsterdamManager.initEventListener();
         }
         if(Boolean(amsterdamManager) && this.isAmsterdamInnovationActive())
         {
            if(Global.player.postInitFinished)
            {
               AmsterdamInnovationManager.getInstance().setupAmsterdamHud();
            }
            else
            {
               Global.world.addEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferredsetupHud,false,0,true);
            }
            this.triggeAmsterdamInnovation();
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
      
      private function deferredsetupHudJumbleVilla(event:Event) : void
      {
         var jumbleVillaManager:JumbleVillaManager = null;
         if(Global.player.postInitFinished)
         {
            Global.world.removeEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferredsetupHudJumbleVilla);
            jumbleVillaManager = JumbleVillaManager.getInstance("JumbleVilla");
            if(jumbleVillaManager)
            {
               jumbleVillaManager.setupHud();
            }
         }
      }
      
      override public function onLeaveWorld(destIsVisiting:Boolean) : void
      {
         super.onLeaveWorld(destIsVisiting);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XDM_STARTER) >= 1)
         {
            Global.hud.rightSideIconQueue.removeIconByName(ICON_CODE_STARTER_XDM);
         }
         var featureDef:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(CommunityGoalsManager.FEATURE_NAME);
         if(featureDef)
         {
            featureDef.updateIconVisibility();
         }
         if(Global.hud)
         {
            Global.hud.removeBottomHudJumbleVillaButton();
            Global.hud.removeBottomHudAmsterdamInnovationButton();
         }
         var featureDefBundle:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(TILE_BUNDLE_HUD);
         if(featureDefBundle)
         {
            featureDefBundle.updateIconVisibility();
         }
      }
      
      private function isAmsterdamInnovationActive() : Boolean
      {
         var amsterdamManager:AmsterdamInnovationManager = null;
         var result:Boolean = false;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("amsterdam_innovation_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            amsterdamManager = AmsterdamInnovationManager.getInstance();
            if(Boolean(amsterdamManager) && Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_AMSTERDAM)
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
            if(AmsterdamInnovationManager.getInstance())
            {
               AmsterdamInnovationManager.getInstance().setupAmsterdamHud();
            }
         }
      }
      
      private function triggeAmsterdamInnovation(e:Event = null) : void
      {
         if(!Global.player.getSeenFlag(AmsterdamInnovationManager.HUD_INITIALISATION_FLAG))
         {
            Global.player.setSeenFlag(AmsterdamInnovationManager.HUD_INITIALISATION_FLAG);
            AmsterdamInnovationManager.getInstance().showMainUI();
         }
      }
   }
}

