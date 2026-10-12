package Display.HUD.HUDWidgets
{
   import Classes.Quest.PrerequisiteUtility;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Managers.OctoberSidecarFeatureManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.filters.DropShadowFilter;
   
   public class HudBottomOctoberSidecarFeature extends HUDWidget
   {
      
      public static const STATE_IDLE:int = 0;
      
      public static const STATE_HARVEST_NOTIF:int = 1;
      
      private static const HUD_MC:String = "hud_mc";
      
      private static const STATE_IDLE_MC:String = "hud_notif_0_mc";
      
      private static const STATE_SMALL_NOTIF_MC:String = "hud_notif_1_mc";
      
      private static const X_OFFSET:int = -800;
      
      private static const Y_OFFSET:int = 130;
      
      private var m_featureName:String;
      
      private var m_hudButton:FarmAnimatedButton;
      
      private var m_stateIdleMc:MovieClip;
      
      private var m_stateSmallNotifMc:MovieClip;
      
      private var m_state:int = -1;
      
      private var m_hud_mc:MovieClip;
      
      private var m_hightlight_mc:MovieClip;
      
      public function HudBottomOctoberSidecarFeature(assetPath:String, featureName:String)
      {
         super(assetPath,Global.hud);
         this.m_featureName = featureName;
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         var parentFrame:ZwFrame = null;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("october_sidecar_hud_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            super.onLoadComplete(event);
            m_element.filters = [new DropShadowFilter()];
            this.setXY();
            parentFrame = new ZwFrame(m_element);
            (parentFrame.element as MovieClip).stop();
            if(m_element.hasOwnProperty(HUD_MC))
            {
               this.m_hud_mc = m_element[HUD_MC] as MovieClip;
               addWidget(this.m_hudButton = new FarmAnimatedButton(m_element[HUD_MC],this.openUI),true);
               this.m_hudButton.attachTooltip(new FarmTextTooltip("The Mooresville Mystery"));
               if(this.m_hud_mc.hasOwnProperty("speech_mc"))
               {
                  this.m_hightlight_mc = this.m_hud_mc["speech_mc"] as MovieClip;
                  this.m_hightlight_mc.visible = false;
               }
               if(this.m_hud_mc.hasOwnProperty(STATE_IDLE_MC))
               {
                  this.m_stateIdleMc = this.m_hud_mc[STATE_IDLE_MC] as MovieClip;
               }
               if(this.m_hud_mc.hasOwnProperty(STATE_SMALL_NOTIF_MC))
               {
                  this.m_stateSmallNotifMc = this.m_hud_mc[STATE_SMALL_NOTIF_MC] as MovieClip;
                  this.m_stateSmallNotifMc.visible = false;
               }
            }
         }
      }
      
      private function openUI(event:Event) : void
      {
         StatsManager.count(this.m_featureName,"HUD","click",this.m_state.toString());
         this.manager.showMainWindow();
         this.refresh(0);
      }
      
      public function setXY() : void
      {
         if(m_loader)
         {
            m_loader.x = (GlobalEngine.stage.stageWidth - UI.DEFAULT_WIDTH) / 2 - X_OFFSET;
            m_loader.y = Global.stage.stageHeight - Y_OFFSET;
         }
      }
      
      public function refresh(state:int) : void
      {
         if(state != this.m_state)
         {
            this.m_state = state;
            switch(state)
            {
               default:
               case STATE_IDLE:
                  if(this.m_hightlight_mc)
                  {
                     this.m_hightlight_mc.visible = false;
                  }
                  break;
               case STATE_HARVEST_NOTIF:
                  if(this.m_hightlight_mc)
                  {
                     this.m_hightlight_mc.visible = true;
                  }
            }
         }
      }
      
      private function get manager() : OctoberSidecarFeatureManager
      {
         return OctoberSidecarFeatureManager.getInstance(this.m_featureName);
      }
      
      override public function release() : void
      {
         this.m_stateSmallNotifMc = null;
         this.m_hudButton = null;
         super.release();
      }
   }
}

