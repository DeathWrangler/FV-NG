package Display.HUD.HUDWidgets
{
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Events.RegionAchievementEvent;
   import Managers.RegionAchievementManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.filters.DropShadowFilter;
   
   public class HudBottomAchievementButton extends HUDWidget
   {
      
      public static const STATE_IDLE:int = 0;
      
      public static const STATE_HARVEST_NOTIF:int = 1;
      
      private static const HUD_MC:String = "hud_mc";
      
      private static const STATE_IDLE_MC:String = "hud_notif_0_mc";
      
      private static const STATE_SMALL_NOTIF_MC:String = "hud_notif_1_mc";
      
      private static const X_OFFSET:int = 80;
      
      private static const Y_OFFSET:int = 130;
      
      private var m_featureName:String;
      
      private var m_hudButton:FarmAnimatedButton;
      
      private var m_stateIdleMc:MovieClip;
      
      private var m_stateSmallNotifMc:MovieClip;
      
      private var m_state:int = -1;
      
      public function HudBottomAchievementButton(assetPath:String, featureName:String)
      {
         super(assetPath,Global.hud);
         this.m_featureName = featureName;
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         var description:String = null;
         super.onLoadComplete(event);
         m_element.filters = [new DropShadowFilter()];
         this.setXY();
         var parentFrame:ZwFrame = new ZwFrame(m_element);
         (parentFrame.element as MovieClip).stop();
         if(m_element.hasOwnProperty(HUD_MC))
         {
            addWidget(this.m_hudButton = new FarmAnimatedButton(m_element[HUD_MC],this.startAchievement),true);
            description = ZLocUtils.t("Dialogs",this.m_featureName + "_hudOnHover");
            this.m_hudButton.attachTooltip(new FarmTextTooltip(description));
            if(m_element[HUD_MC].hasOwnProperty(STATE_IDLE_MC))
            {
               this.m_stateIdleMc = m_element[HUD_MC][STATE_IDLE_MC] as MovieClip;
            }
            if(m_element[HUD_MC].hasOwnProperty(STATE_SMALL_NOTIF_MC))
            {
               this.m_stateSmallNotifMc = m_element[HUD_MC][STATE_SMALL_NOTIF_MC] as MovieClip;
            }
         }
         RegionAchievementManager.getInstance(this.m_featureName).dispatchRegionAchievementEvent(new RegionAchievementEvent(RegionAchievementEvent.UPDATE_HUD));
      }
      
      private function startAchievement(event:Event) : void
      {
         RegionAchievementManager.getInstance(this.m_featureName).showUI();
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
                  this.m_stateIdleMc.visible = true;
                  this.m_stateSmallNotifMc.visible = false;
                  break;
               case STATE_HARVEST_NOTIF:
                  this.m_stateIdleMc.visible = false;
                  this.m_stateSmallNotifMc.visible = true;
            }
         }
      }
      
      override public function release() : void
      {
         this.m_stateIdleMc = null;
         this.m_stateSmallNotifMc = null;
         this.m_hudButton = null;
         super.release();
      }
   }
}

