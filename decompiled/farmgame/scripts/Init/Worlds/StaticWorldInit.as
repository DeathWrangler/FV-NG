package Init.Worlds
{
   import Classes.Idle.IdleTaskQueue;
   import Display.UI;
   
   public class StaticWorldInit extends HomeWorldInit
   {
      
      public function StaticWorldInit()
      {
         super();
      }
      
      public static function setupStaticHud(shouldSetupStaticHud:Boolean) : void
      {
         if(shouldSetupStaticHud)
         {
            Global.hud.hideAllNameDisplays();
            if(Global.ui.leSurfacingToaster)
            {
               Global.ui.leSurfacingToaster.close();
               Global.ui.leSurfacingToaster = null;
            }
            Global.hud.worldScoreMeter = null;
         }
         else
         {
            Global.hud.showTravelNameDisplay();
            if(Global.hud.fishingDerbyTackleBox != null)
            {
               Global.hud.fishingDerbyTackleBox.release();
            }
            if(Global.hud.homeButtonWidget != null)
            {
               Global.hud.homeButtonWidget.release();
            }
            if(Global.hud.zoomWidget != null)
            {
               Global.hud.zoomWidget.release();
            }
         }
         if(Global.hud.m_statsDropDown)
         {
            Global.hud.m_statsDropDown.visible = !shouldSetupStaticHud;
         }
         Global.hud.setIconQueuesVisibility(!shouldSetupStaticHud);
         Global.hud.setRightSideIconQueuesVisibility(!shouldSetupStaticHud);
         Global.hud.setNeighborSearchBarVisibility(!shouldSetupStaticHud);
         Global.hud.setFuelIconVisibility(!shouldSetupStaticHud);
      }
      
      public static function setupStaticUI(shouldSetupStaticUI:Boolean) : void
      {
         Global.ui.bottomUI.visible = !shouldSetupStaticUI;
         UI.stopPopups(shouldSetupStaticUI);
      }
      
      override public function onEnterWorld(resultData:Object) : void
      {
         super.onEnterWorld(resultData);
         IdleTaskQueue.getInstance().blockIdleTasks();
      }
      
      override public function onLeaveWorld(destIsVisiting:Boolean) : void
      {
         super.onLeaveWorld(destIsVisiting);
      }
      
      override public function setupUI() : void
      {
         setupStaticUI(true);
      }
      
      override public function setupHud() : void
      {
         setupStaticHud(true);
      }
   }
}

