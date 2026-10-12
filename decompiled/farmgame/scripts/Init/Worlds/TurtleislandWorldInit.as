package Init.Worlds
{
   import Classes.Constants.Experiments;
   import Classes.Constants.WorldsConstants;
   import Classes.FeatureMessagingDefinition;
   import Classes.ImageLoader;
   import Display.UI;
   import Init.PostInitActionHandlers.RightSideHUDIconInitAction;
   import Managers.CommunityGoalsManager;
   import Managers.FeatureMessagingManager;
   import Managers.TurtleInnovationManager;
   import Managers.WorldSeasonsManager;
   import Widgets.Windows.JapanEATutorial;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class TurtleislandWorldInit extends HomeWorldInit
   {
      
      public static const ICON_CODE_STARTER_XTI:String = "274";
      
      public static const ICON_CODE_STARTER_XTI_R2:String = "275";
      
      public static const TURTLE_EA_FLAG:String = "EAmotdTurtle";
      
      private static const UITemplatizationBgImages:Array = ["AnimalFrame_big_noBG.png","MOTD.png","MOTD_noBG.png","AnimalFrame.png","AnimalFrame_big.png","MOTD_noTitle.png","RewardDialog.png"];
      
      private static const UITemplatizationSlotImages:Array = ["V100","V80","V55","H100","H60","Button100","treasureDialog","worldScoreIcon","CGTitleBar"];
      
      private const premarketingFeatureName:String = "DreamFishPremarketing";
      
      public function TurtleislandWorldInit()
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
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XTI_STARTER) >= 1)
         {
            Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_STARTER_XTI));
         }
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XTI_R2_STARTER) >= 1)
         {
            Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_STARTER_XTI_R2));
         }
         this.triggerEAMOTDTURTLE();
         var featureDef:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(CommunityGoalsManager.FEATURE_NAME);
         if(featureDef)
         {
            featureDef.updateIconVisibility();
         }
         var premarketingfeatureDefine:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(this.premarketingFeatureName);
         if(premarketingfeatureDefine)
         {
            premarketingfeatureDefine.updateIconVisibility();
         }
         var featureDef1:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(TurtleInnovationManager.FEATURE_NAME);
         if(featureDef1)
         {
            featureDef1.updateIconVisibility();
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
         TurtleInnovationManager.getInstance().initEventListener();
      }
      
      override public function onLeaveWorld(destIsVisiting:Boolean) : void
      {
         super.onLeaveWorld(destIsVisiting);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XTI_STARTER) >= 1)
         {
            Global.hud.rightSideIconQueue.removeIconByName(ICON_CODE_STARTER_XTI);
         }
         var featureDef:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(CommunityGoalsManager.FEATURE_NAME);
         if(featureDef)
         {
            featureDef.updateIconVisibility();
         }
         var premarketingfeatureDefine:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(this.premarketingFeatureName);
         if(premarketingfeatureDefine)
         {
            premarketingfeatureDefine.updateIconVisibility();
         }
         var featureDef1:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(TurtleInnovationManager.FEATURE_NAME);
         if(featureDef1)
         {
            featureDef1.updateIconVisibility();
         }
      }
      
      private function triggerEAMOTDTURTLE(e:Event = null) : void
      {
         if(!Global.player.getSeenFlag(TURTLE_EA_FLAG))
         {
            Global.player.setSeenFlag(TURTLE_EA_FLAG);
            if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_TURTLEISLAND))
            {
               UI.displayPopup(new JapanEATutorial(TURTLE_EA_FLAG,"assets/dialogs/turtleisland/FV_xti_MOTD_R1_PostEA.swf",0,true,false,true,true),false);
            }
         }
      }
   }
}

