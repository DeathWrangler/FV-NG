package Init.Worlds
{
   import Classes.Constants.Experiments;
   import Classes.Constants.WorldsConstants;
   import Classes.FeatureMessagingDefinition;
   import Classes.ImageLoader;
   import Display.UI;
   import Events.FarmGameWorldEvent;
   import Init.PostInitActionHandlers.RightSideHUDIconInitAction;
   import Managers.CommunityGoalsManager;
   import Managers.FeatureMessagingManager;
   import Managers.OrderBoard.DreamWorldInnovationManager;
   import Managers.WorldSeasonsManager;
   import Widgets.Windows.JapanEATutorial;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class DreamworldWorldInit extends HomeWorldInit
   {
      
      public static const ICON_CODE_STARTER_XDW:String = "276";
      
      public static const ICON_CODE_STARTER_XDW_R2:String = "277";
      
      public static const DREAMWORLD_EA_FLAG:String = "EAmotdDreamworld";
      
      public static const FEATURE_NAME:String = "DreamWorldInnovation";
      
      public static const PM_FEATURE_NAME:String = "DreamFishPremarketing";
      
      public static const FTUE_SEEN_FLAG:String = "DreamWorldInnovation_Tutorial";
      
      private static const UITemplatizationBgImages:Array = ["AnimalFrame_big_noBG.png","MOTD.png","MOTD_noBG.png","AnimalFrame.png","AnimalFrame_big.png","MOTD_noTitle.png","RewardDialog.png"];
      
      private static const UITemplatizationSlotImages:Array = ["V100","V80","V55","H100","H60","Button100","treasureDialog","worldScoreIcon","CGTitleBar"];
      
      public function DreamworldWorldInit()
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
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XDW_STARTER) >= 1)
         {
            Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_STARTER_XDW));
         }
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XDW_R2_STARTER) >= 1)
         {
            Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_STARTER_XDW_R2));
         }
         var featureDef:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(CommunityGoalsManager.FEATURE_NAME);
         if(featureDef)
         {
            featureDef.updateIconVisibility();
         }
         featureDef = FeatureMessagingManager.getInstance().getFeatureDefinition(PM_FEATURE_NAME);
         if(featureDef)
         {
            featureDef.updateIconVisibility();
         }
         this.triggerEAMOTD();
         if(Boolean(DreamWorldInnovationManager.getInstance(FEATURE_NAME)) && DreamWorldInnovationManager.getInstance(FEATURE_NAME).isFeatureActive)
         {
            if(Global.player.postInitFinished)
            {
               DreamWorldInnovationManager.getInstance(FEATURE_NAME).setupHud();
            }
            else
            {
               Global.world.addEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferredsetupHud,false,0,true);
            }
            this.triggerDreamWorldInnovationFeature();
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
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XDW_STARTER) >= 1)
         {
            Global.hud.rightSideIconQueue.removeIconByName(ICON_CODE_STARTER_XDW);
         }
         var featureDef:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(CommunityGoalsManager.FEATURE_NAME);
         if(featureDef)
         {
            featureDef.updateIconVisibility();
         }
         featureDef = FeatureMessagingManager.getInstance().getFeatureDefinition(PM_FEATURE_NAME);
         if(featureDef)
         {
            featureDef.updateIconVisibility();
         }
         if(Global.eosManager.getEosVariant(Experiments.EXPERIMENT_MOTD_XDW_R2_STARTER) >= 1)
         {
            Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_STARTER_XDW));
         }
         if(Global.eosManager.getEosVariant(Experiments.EXPERIMENT_MOTD_XDW_R2_STARTER) >= 1)
         {
            Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_STARTER_XDW_R2));
         }
      }
      
      private function triggerEAMOTD(e:Event = null) : void
      {
         if(!Global.player.getSeenFlag(DREAMWORLD_EA_FLAG))
         {
            Global.player.setSeenFlag(DREAMWORLD_EA_FLAG);
            if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_DREAMWORLD))
            {
               UI.displayPopup(new JapanEATutorial(DREAMWORLD_EA_FLAG,"assets/dialogs/dreamworld/FV_xdw_MOTD_R1_PostEA.swf",0,true,false,true,true),false);
            }
         }
      }
      
      private function triggerDreamWorldInnovationFeature(e:Event = null) : void
      {
         if(!Global.player.getSeenFlag(FTUE_SEEN_FLAG))
         {
            DreamWorldInnovationManager.getInstance(FEATURE_NAME).showMainUI();
         }
      }
      
      private function deferredsetupHud(e:Event = null) : void
      {
         if(Global.player.postInitFinished)
         {
            Global.world.removeEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferredsetupHud);
            DreamWorldInnovationManager.getInstance(FEATURE_NAME).setupHud();
         }
      }
   }
}

