package Init.Worlds
{
   import Classes.Constants.Experiments;
   import Classes.FeatureMessagingDefinition;
   import Classes.ImageLoader;
   import Classes.MultiRewardTreasurePayerLandBundleConstructionBuilding;
   import Classes.Quest.PrerequisiteUtility;
   import Display.HUD.HUDWidgets.HudLandBundle;
   import Events.FarmGameWorldEvent;
   import Init.PostInitActionHandlers.RightSideHUDIconInitAction;
   import Managers.AnimalSanctuaryManager;
   import Managers.CommunityGoalsManager;
   import Managers.FeatureMessagingManager;
   import Managers.WhitewinterInnovationManager;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class WhitewinterWorldInit extends HomeWorldInit
   {
      
      public static const ICON_CODE_STARTER_XFW:String = "281";
      
      public static const WHITEWINTER_INNOVATION_FLAG:String = "whitewinter_innovation_flag";
      
      private static const UITemplatizationBgImages:Array = ["AnimalFrame_big_noBG.png","MOTD.png","AnimalFrame.png","AnimalFrame_big.png","MOTD_noTitle.png","NPC1_225.png","RewardDialog.png","NPC2.png","FV_animal_breeding_aquarium.jpg","FV_animal_breeding_aviary.jpg","FV_animal_breeding_babypen.jpg","FV_animal_breeding_livestockpen.jpg","FV_animal_breeding_paddock.jpg","FV_animal_breeding_pasture.jpg","FV_animal_breeding_petrun.jpg","FV_animal_breeding_wildlifepen.jpg","FV_animal_breeding_zoopen.jpg"];
      
      private static const UITemplatizationSlotImages:Array = ["V100","V80","V55","H100","H60","Button100","treasureDialog","worldScoreIcon","CGTitleBar"];
      
      private const FEATURE_NAME:String = "WhitewinterInnovation";
      
      public function WhitewinterWorldInit()
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
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XFW_STARTER) >= 1)
         {
            Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_STARTER_XFW));
         }
         var featureDef:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(CommunityGoalsManager.FEATURE_NAME);
         if(featureDef)
         {
            featureDef.updateIconVisibility();
         }
         if(WhitewinterInnovationManager.getInstance(this.FEATURE_NAME))
         {
            if(Global.player.postInitFinished)
            {
               WhitewinterInnovationManager.getInstance(this.FEATURE_NAME).setupHud();
            }
            else
            {
               Global.world.addEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferredsetupHud,false,0,true);
            }
            this.triggerWhitewinterInnovationFeature();
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
         prereq = Global.farmGameSettingsManager.getPrereqByName("Whitewinter_feature_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            WhitewinterInnovationManager.getInstance().initEventListener();
         }
         if(Boolean(Global.hud) && MultiRewardTreasurePayerLandBundleConstructionBuilding.isBundleAvailable())
         {
            Global.hud.setHudLandBundle(new HudLandBundle());
         }
         if(Boolean(AnimalSanctuaryManager.getInstance()) && AnimalSanctuaryManager.getInstance().isFeatureActive)
         {
            if(Global.player.postInitFinished)
            {
               AnimalSanctuaryManager.getInstance().setupCasablancaHud();
            }
            else
            {
               Global.world.addEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferredsetupHudAS,false,0,true);
            }
         }
      }
      
      private function triggerWhitewinterInnovationFeature() : void
      {
         if(!Global.player.getSeenFlag(WHITEWINTER_INNOVATION_FLAG))
         {
            Global.player.setSeenFlag(WHITEWINTER_INNOVATION_FLAG);
            WhitewinterInnovationManager.getInstance(this.FEATURE_NAME).showMainUI();
         }
      }
      
      override public function onLeaveWorld(destIsVisiting:Boolean) : void
      {
         super.onLeaveWorld(destIsVisiting);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XFW_STARTER) >= 1)
         {
            Global.hud.rightSideIconQueue.removeIconByName(ICON_CODE_STARTER_XFW);
         }
         var featureDef2:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(CommunityGoalsManager.FEATURE_NAME);
         if(featureDef2)
         {
            featureDef2.updateIconVisibility();
         }
         var featureDef3:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(WhitewinterInnovationManager.FEATURE_NAME);
         if(featureDef3)
         {
            featureDef3.updateIconVisibility();
         }
         if(Global.hud)
         {
            Global.hud.removeHudLandBundle();
         }
         if(Global.hud)
         {
            Global.hud.removeBottomHudCasablancaInnovationButton();
         }
      }
      
      private function deferredsetupHud(e:Event = null) : void
      {
         if(Global.player.postInitFinished)
         {
            Global.world.removeEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferredsetupHud);
            WhitewinterInnovationManager.getInstance(this.FEATURE_NAME).setupHud();
         }
      }
      
      private function deferredsetupHudAS(e:Event = null) : void
      {
         if(Global.player.postInitFinished)
         {
            Global.world.removeEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferredsetupHud);
            if(AnimalSanctuaryManager.getInstance())
            {
               AnimalSanctuaryManager.getInstance().setupCasablancaHud();
            }
         }
      }
   }
}

