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
   import Managers.OrderBoard.FarmersMarketInnovationManager;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class FarmfestWorldInit extends HomeWorldInit
   {
      
      public static const ICON_CODE_STARTER_XFS:String = "299";
      
      private static const UITemplatizationBgImages:Array = ["AnimalFrame_big_noBG.png","MOTD.png","AnimalFrame.png","AnimalFrame_big.png","MOTD_noTitle.png","NPC1_225.png","RewardDialog.png","MOTD_ShippingLicense.png","NPC2.png","FV_animal_breeding_aquarium.jpg","FV_animal_breeding_aviary.jpg","FV_animal_breeding_babypen.jpg","FV_animal_breeding_livestockpen.jpg","FV_animal_breeding_paddock.jpg","FV_animal_breeding_pasture.jpg","FV_animal_breeding_petrun.jpg","FV_animal_breeding_wildlifepen.jpg","FV_animal_breeding_zoopen.jpg"];
      
      private static const UITemplatizationSlotImages:Array = ["V100","V80","V55","H100","H60","Button100","treasureDialog","worldScoreIcon","CGTitleBar"];
      
      public function FarmfestWorldInit()
      {
         super();
      }
      
      private static function onUrlLoaded(dispObj:DisplayObject, info:Object = null) : void
      {
      }
      
      private static function isFarmersMarketActive() : Boolean
      {
         var result:Boolean = false;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("farmersmarket_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            if(Boolean(FarmersMarketInnovationManager.getInstance()) && Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_FARMFEST)
            {
               result = true;
            }
         }
         return result;
      }
      
      override public function onEnterWorld(resultData:Object) : void
      {
         var image:String = null;
         var slotImageTag:String = null;
         var imageUrl:String = null;
         super.onEnterWorld(resultData);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XFS_STARTER) >= 1)
         {
            Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_STARTER_XFS));
         }
         var featureDef:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(CommunityGoalsManager.FEATURE_NAME);
         if(featureDef)
         {
            featureDef.updateIconVisibility();
         }
         if(Boolean(FarmersMarketInnovationManager.getInstance()) && isFarmersMarketActive())
         {
            if(Global.player.postInitFinished)
            {
               FarmersMarketInnovationManager.getInstance().setUpHudFarmersMarket();
            }
            else
            {
               Global.world.addEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferredsetupHud,false,0,true);
            }
            this.triggeFarmersMarketFeature();
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
      
      override public function onLeaveWorld(destIsVisiting:Boolean) : void
      {
         super.onLeaveWorld(destIsVisiting);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XFS_STARTER) >= 1)
         {
            Global.hud.rightSideIconQueue.removeIconByName(ICON_CODE_STARTER_XFS);
         }
         var featureDef:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(CommunityGoalsManager.FEATURE_NAME);
         if(featureDef)
         {
            featureDef.updateIconVisibility();
         }
         if(Global.hud)
         {
            Global.hud.removeBottomHudFarmersMarketInnovationButton();
         }
      }
      
      private function deferredsetupHud(e:Event = null) : void
      {
         if(Global.player.postInitFinished)
         {
            Global.world.removeEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferredsetupHud);
            if(FarmersMarketInnovationManager.getInstance())
            {
               FarmersMarketInnovationManager.getInstance().setUpHudFarmersMarket();
            }
         }
      }
      
      private function triggeFarmersMarketFeature(e:Event = null) : void
      {
         if(!Global.player.getSeenFlag(FarmersMarketInnovationManager.HUD_INITIALISATION_FLAG))
         {
            Global.player.setSeenFlag(FarmersMarketInnovationManager.HUD_INITIALISATION_FLAG);
            FarmersMarketInnovationManager.getInstance().showMainWindow();
         }
      }
   }
}

