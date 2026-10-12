package Display.HUD.HUDWidgets
{
   import Classes.Quest.PrerequisiteUtility;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.FVFlashHelper2018FeatureWindow;
   import Widgets.Windows.SpecialLEBundleWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.filters.DropShadowFilter;
   
   public class HudBottomFvPluginButton extends HUDWidget
   {
      
      public static const STATE_IDLE:int = 0;
      
      public static const STATE_HARVEST_NOTIF:int = 1;
      
      private static const HUD_MC:String = "hud_mc";
      
      private static const STATE_IDLE_MC:String = "hud_notif_0_mc";
      
      private static const STATE_SMALL_NOTIF_MC:String = "hud_notif_1_mc";
      
      private static const X_OFFSET:int = -780;
      
      private static const Y_OFFSET:int = 110;
      
      private var m_featureName:String = "chromeplugin2018";
      
      private var m_hudButton:FarmAnimatedButton;
      
      private var m_stateIdleMc:MovieClip;
      
      private var m_stateSmallNotifMc:MovieClip;
      
      private var m_state:int = -1;
      
      private var m_LEBundleWindow:SpecialLEBundleWindow;
      
      private var FIRST_TIME_HUD_CLICK:String = "First_time_hud_click";
      
      public function HudBottomFvPluginButton(assetPath:String)
      {
         super(assetPath,Global.hud);
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         m_element.filters = [new DropShadowFilter()];
         this.setXY();
         var parentFrame:ZwFrame = new ZwFrame(m_element);
         (parentFrame.element as MovieClip).stop();
         if(m_element.hasOwnProperty(HUD_MC))
         {
            addWidget(this.m_hudButton = new FarmAnimatedButton(m_element[HUD_MC],this.openUI),true);
            this.m_hudButton.attachTooltip(new FarmTextTooltip("Farmville Flash Helper "));
            if(m_element[HUD_MC].hasOwnProperty(STATE_IDLE_MC))
            {
               this.m_stateIdleMc = m_element[HUD_MC][STATE_IDLE_MC] as MovieClip;
               this.m_stateIdleMc.visible = false;
            }
            if(m_element[HUD_MC].hasOwnProperty(STATE_SMALL_NOTIF_MC))
            {
               this.m_stateSmallNotifMc = m_element[HUD_MC][STATE_SMALL_NOTIF_MC] as MovieClip;
               this.m_stateSmallNotifMc.visible = false;
            }
         }
         this.refresh();
      }
      
      private function openUI(fevent:Event) : void
      {
         StatsManager.count(this.m_featureName,"","click",this.m_state.toString());
         if(!Global.player.getSeenFlag(this.FIRST_TIME_HUD_CLICK))
         {
            Global.player.setSeenFlag(this.FIRST_TIME_HUD_CLICK);
         }
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("fv_flashHelper");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            UI.displayPopup(new FVFlashHelper2018FeatureWindow("assets/dialogs/ChromePlugin2018/FV_motd_ChromePlugin2018.swf"),false);
            this.refresh();
            FarmStatsManager.count("chrome_extension","HUD","clicks","chrome_extension");
         }
      }
      
      public function setXY() : void
      {
         if(m_loader)
         {
            m_loader.x = (GlobalEngine.stage.stageWidth - UI.DEFAULT_WIDTH) / 2 - X_OFFSET;
            m_loader.y = Global.stage.stageHeight - Y_OFFSET;
         }
      }
      
      public function refresh() : void
      {
         if(!Global.player.getSeenFlag(this.FIRST_TIME_HUD_CLICK))
         {
            this.m_stateIdleMc.visible = true;
            this.m_stateSmallNotifMc.visible = true;
         }
         else
         {
            this.m_stateIdleMc.visible = false;
            this.m_stateSmallNotifMc.visible = false;
         }
      }
      
      override public function release() : void
      {
         this.m_hudButton = null;
         super.release();
      }
   }
}

