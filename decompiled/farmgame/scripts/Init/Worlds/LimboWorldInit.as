package Init.Worlds
{
   import Classes.Constants.Experiments;
   import Display.HUD.HUDWidgets.HudBottomGenericButton;
   import Init.PostInitActionHandlers.RightSideHUDIconInitAction;
   import Managers.LimboInnovationManager;
   import Managers.XBOPremarketingManager;
   import flash.events.Event;
   
   public class LimboWorldInit extends HomeWorldInit
   {
      
      public static const ICON_CODE_STARTER_XBO:String = "269";
      
      private static const INNOVATION_HUD:String = "assets/dialogs/limbo/InteractiveDeco2016/FV_InteractiveDeco2016_HUD.swf";
      
      private static const INNOVATION_FEATURE_NAME:String = "limbo_innovation";
      
      public const XBO_PREMARKETING:String = "XBOPremarketing";
      
      private var m_superBuildings:Object;
      
      public function LimboWorldInit()
      {
         super();
      }
      
      override public function onEnterWorld(resultData:Object) : void
      {
         super.onEnterWorld(resultData);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XBO_STARTER) >= 1)
         {
            Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_STARTER_XBO));
         }
         var premarketingManager:XBOPremarketingManager = XBOPremarketingManager.instance(this.XBO_PREMARKETING);
         if(Boolean(premarketingManager) && premarketingManager.isActive)
         {
            premarketingManager.grantEarnedItems();
         }
         this.m_superBuildings = null;
         if(m_expansionData.superBuildings != null)
         {
            this.m_superBuildings = m_expansionData.superBuildings;
         }
         LimboInnovationManager.getInstance().initEventListener();
         var hudButton:HudBottomGenericButton = new HudBottomGenericButton(INNOVATION_HUD,INNOVATION_FEATURE_NAME,this.onAcceptHandler);
         Global.hud.setBottomHudGenericButton(hudButton as HudBottomGenericButton);
      }
      
      override public function onLeaveWorld(destIsVisiting:Boolean) : void
      {
         super.onLeaveWorld(destIsVisiting);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XBO_STARTER) >= 1)
         {
            Global.hud.rightSideIconQueue.removeIconByName(ICON_CODE_STARTER_XBO);
         }
         if(Global.hud)
         {
            Global.hud.removeBottomHudGenericButton();
         }
      }
      
      public function getBuildingConfig() : Object
      {
         return this.m_superBuildings;
      }
      
      private function onAcceptHandler(event:Event) : void
      {
         LimboInnovationManager.getInstance().showFeatureUI();
      }
   }
}

