package Init.Worlds
{
   import Classes.Constants.Experiments;
   import Classes.FeatureMessagingDefinition;
   import Classes.ImageLoader;
   import Init.PostInitActionHandlers.RightSideHUDIconInitAction;
   import Managers.CommunityGoalsManager;
   import Managers.FeatureMessagingManager;
   import flash.display.DisplayObject;
   
   public class MidwestWorldInit extends HomeWorldInit
   {
      
      public static const ICON_CODE_STARTER_XHH:String = "272";
      
      private static const TILE_BUNDLE_HUD:String = "PayerBundleMidWest";
      
      private static const UITemplatizationBgImages:Array = ["AnimalFrame_big_noBG.png","MOTD.png","MOTD_noBG.png","AnimalFrame.png","AnimalFrame_big.png","MOTD_noTitle.png","RewardDialog.png"];
      
      public function MidwestWorldInit()
      {
         super();
      }
      
      private static function onUrlLoaded(dispObj:DisplayObject, info:Object = null) : void
      {
      }
      
      override public function onEnterWorld(resultData:Object) : void
      {
         var image:String = null;
         var imageUrl:String = null;
         super.onEnterWorld(resultData);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XHH_STARTER) >= 1)
         {
            Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_STARTER_XHH));
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
         for each(image in UITemplatizationBgImages)
         {
            imageUrl = "assets/dialogs/" + Global.worldManager.currentWorldType + "/";
            imageUrl = Global.getAssetURL(imageUrl + image);
            ImageLoader.getInstance(imageUrl).getContent(onUrlLoaded);
         }
      }
      
      override public function onLeaveWorld(destIsVisiting:Boolean) : void
      {
         super.onLeaveWorld(destIsVisiting);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XHH_STARTER) >= 1)
         {
            Global.hud.rightSideIconQueue.removeIconByName(ICON_CODE_STARTER_XHH);
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
      }
   }
}

