package Init.Worlds
{
   import Classes.Constants.Experiments;
   import Classes.FeatureMessagingDefinition;
   import Classes.ImageLoader;
   import Init.PostInitActionHandlers.RightSideHUDIconInitAction;
   import Managers.CommunityGoalsManager;
   import Managers.FeatureMessagingManager;
   import flash.display.DisplayObject;
   
   public class UnderwaterWorldInit extends HomeWorldInit
   {
      
      public static const ICON_CODE_STARTER_XUW:String = "273";
      
      private static const UITemplatizationBgImages:Array = ["AnimalFrame_big_noBG.png","MOTD.png","MOTD_noBG.png","AnimalFrame.png","AnimalFrame_big.png","MOTD_noTitle.png","RewardDialog.png"];
      
      private static const UITemplatizationSlotImages:Array = ["V100","V80","V55","H100","H60","Button100","worldScoreIcon","CGTitleBar"];
      
      private const ugcfeatureName:String = "ugc_dreamfish";
      
      private const premarketing_featureName:String = "DreamFishPremarketing";
      
      public function UnderwaterWorldInit()
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
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XUW_STARTER) >= 1)
         {
            Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_STARTER_XUW));
         }
         var featureDef:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(CommunityGoalsManager.FEATURE_NAME);
         if(featureDef)
         {
            featureDef.updateIconVisibility();
         }
         var premarketingfeatureDefine:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(this.premarketing_featureName);
         if(premarketingfeatureDefine)
         {
            premarketingfeatureDefine.updateIconVisibility();
         }
         var ugcfeatureDefine:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(this.ugcfeatureName);
         if(ugcfeatureDefine)
         {
            ugcfeatureDefine.updateIconVisibility();
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
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XUW_STARTER) >= 1)
         {
            Global.hud.rightSideIconQueue.removeIconByName(ICON_CODE_STARTER_XUW);
         }
         var featureDef:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(CommunityGoalsManager.FEATURE_NAME);
         if(featureDef)
         {
            featureDef.updateIconVisibility();
         }
         var ugcfeatureDefine:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(this.ugcfeatureName);
         if(ugcfeatureDefine)
         {
            ugcfeatureDefine.updateIconVisibility();
         }
         var premarketingfeatureDefine:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(this.premarketing_featureName);
         if(premarketingfeatureDefine)
         {
            premarketingfeatureDefine.updateIconVisibility();
         }
      }
   }
}

