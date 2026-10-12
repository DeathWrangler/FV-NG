package Init.Worlds
{
   import Classes.Constants.Experiments;
   import Classes.Constants.WorldsConstants;
   import Classes.FeatureMessagingDefinition;
   import Display.UI;
   import Init.PostInitActionHandlers.RightSideHUDIconInitAction;
   import Managers.ActionDrivenManager;
   import Managers.CommunityGoalsManager;
   import Managers.FeatureMessagingManager;
   import Managers.WorldSeasonsManager;
   import Managers.XMASInnovationManager;
   import Widgets.Windows.JapanEATutorial;
   import flash.events.Event;
   
   public class XmasWorldInit extends HomeWorldInit
   {
      
      public static const ICON_CODE_STARTER_XCH:String = "270";
      
      public static const ICON_CODE_STARTER_XCH_R2:String = "271";
      
      public static const XMAS_EA_FLAG:String = "EAmotdXmas";
      
      private const featureName:String = "northpole_toy_works2016";
      
      public function XmasWorldInit()
      {
         super();
      }
      
      override public function onEnterWorld(resultData:Object) : void
      {
         super.onEnterWorld(resultData);
         if(Global.eosManager.getEosVariant(Experiments.EXPERIMENT_MOTD_XCH_STARTER) >= 1)
         {
            Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_STARTER_XCH));
         }
         if(Global.eosManager.getEosVariant(Experiments.EXPERIMENT_MOTD_XCH_R2_STARTER) >= 1)
         {
            Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_STARTER_XCH_R2));
         }
         if(Global.eosManager.getEosVariant(Experiments.EXPERIMENT_MOTD_XCH_R2_STARTER) >= 1)
         {
            Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_STARTER_XCH_R2));
         }
         this.triggerEAMOTDXMAS();
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_XMAS_INNOVATION) == Experiments.VARIANT_XMAS_INNOVATION)
         {
            if(XMASInnovationManager.getInstance().isFeatureEnabled())
            {
               XMASInnovationManager.getInstance().initEventListener();
            }
         }
         var featureDefinition:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(XMASInnovationManager.FEATURE_OPTIONS_KEY);
         if(featureDefinition)
         {
            if(!FeatureMessagingManager.getInstance().isFeatureActive(XMASInnovationManager.FEATURE_OPTIONS_KEY))
            {
               if(featureDefinition.passesPrereqs() && !Global.player.getSeenSessionFlag(XMASInnovationManager.HUD_INITIALISATION_FLAG))
               {
                  if(featureDefinition.customInit)
                  {
                     featureDefinition.customInit.initialize();
                     Global.player.setSeenSessionFlag(XMASInnovationManager.HUD_INITIALISATION_FLAG);
                  }
               }
            }
            featureDefinition.updateIconVisibility();
         }
         var featureDef:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(CommunityGoalsManager.FEATURE_NAME);
         if(featureDef)
         {
            featureDef.updateIconVisibility();
         }
         var featureDefine:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(this.featureName);
         if(featureDefine)
         {
            featureDefine.updateIconVisibility();
         }
         ActionDrivenManager.dispatchEventListener();
      }
      
      override public function onLeaveWorld(destIsVisiting:Boolean) : void
      {
         super.onLeaveWorld(destIsVisiting);
         if(Global.eosManager.getEosVariant(Experiments.EXPERIMENT_MOTD_XCH_STARTER) >= 1)
         {
            Global.hud.rightSideIconQueue.removeIconByName(ICON_CODE_STARTER_XCH);
         }
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_XMAS_INNOVATION) == Experiments.VARIANT_XMAS_INNOVATION)
         {
            if(XMASInnovationManager.getInstance().isFeatureEnabled())
            {
               XMASInnovationManager.getInstance().deleteEventListener();
            }
         }
         var featureDef:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(XMASInnovationManager.FEATURE_OPTIONS_KEY);
         if(featureDef)
         {
            featureDef.updateIconVisibility();
         }
         var featureDef1:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(CommunityGoalsManager.FEATURE_NAME);
         if(featureDef1)
         {
            featureDef1.updateIconVisibility();
         }
         var featureDefine:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(this.featureName);
         if(featureDefine)
         {
            featureDefine.updateIconVisibility();
         }
      }
      
      private function triggerEAMOTDXMAS(e:Event = null) : void
      {
         if(!Global.player.getSeenFlag(XMAS_EA_FLAG))
         {
            Global.player.setSeenFlag(XMAS_EA_FLAG);
            if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_XMAS))
            {
               UI.displayPopup(new JapanEATutorial(XMAS_EA_FLAG,"assets/dialogs/xmas/FV_xch_MOTD_R2_PostEA.swf",1,true,false,true,true),false);
            }
         }
      }
   }
}

