package Display.HUD.HUDWidgets
{
   import Display.UI;
   import Engine.Managers.StatsManager;
   import GameMode.GMDecorationPlace;
   import GameMode.GameMode;
   import Managers.OrderBoard.BoraBoraInnovationManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.filters.DropShadowFilter;
   
   public class HudBoraBoraInnovationButton extends HUDWidget
   {
      
      public static const STATE_IDLE:int = 0;
      
      public static const STATE_HARVEST_NOTIF:int = 1;
      
      private static const HUD_MC:String = "hud_mc";
      
      private static const STATE_IDLE_MC:String = "hud_notif_0_mc";
      
      private static const STATE_SMALL_NOTIF_MC:String = "hud_notif_1_mc";
      
      private static const STATE_NOTIF_MC:String = "notif_mc";
      
      private static const X_OFFSET:int = 103;
      
      private static const Y_OFFSET:int = 130;
      
      private var m_featureName:String;
      
      private var m_hudButton:FarmAnimatedButton;
      
      private var m_stateIdleMc:MovieClip;
      
      private var m_stateSmallNotifMc:MovieClip;
      
      private var m_state:int = -1;
      
      private var m_stateNotifMc:MovieClip;
      
      public function HudBoraBoraInnovationButton(assetPath:String, featureName:String)
      {
         super(assetPath,Global.hud);
         this.m_featureName = featureName;
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
            this.m_hudButton.attachTooltip(new FarmTextTooltip("Tropical Ever After"));
            if(m_element[HUD_MC].hasOwnProperty(STATE_IDLE_MC))
            {
               this.m_stateIdleMc = m_element[HUD_MC][STATE_IDLE_MC] as MovieClip;
            }
            if(m_element[HUD_MC].hasOwnProperty(STATE_SMALL_NOTIF_MC))
            {
               this.m_stateSmallNotifMc = m_element[HUD_MC][STATE_SMALL_NOTIF_MC] as MovieClip;
               this.m_stateSmallNotifMc.visible = false;
            }
            if(m_element[HUD_MC].hasOwnProperty(STATE_NOTIF_MC))
            {
               this.m_stateNotifMc = m_element[HUD_MC][STATE_NOTIF_MC] as MovieClip;
               this.m_stateNotifMc.visible = false;
            }
         }
         this.refresh(0);
      }
      
      private function openUI(event:Event) : void
      {
         var modes:Array = null;
         var mode:GameMode = null;
         var result:GameMode = null;
         StatsManager.count("BoraboraInnovation","HudClick","click",this.m_state.toString());
         if(Global.world.isGameModeActive(GMDecorationPlace))
         {
            modes = Global.world.getActiveGameModes();
            for each(mode in modes)
            {
               if(mode is GMDecorationPlace)
               {
                  result = mode;
                  break;
               }
            }
            Global.world.removeGameMode(result);
            return;
         }
         if(!BoraBoraInnovationManager.getInstance().isBoraboraInnovationMainWindowActive())
         {
            BoraBoraInnovationManager.getInstance(this.m_featureName).showMainWindow();
         }
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
                  this.m_stateSmallNotifMc.visible = false;
                  break;
               case STATE_HARVEST_NOTIF:
                  this.m_stateSmallNotifMc.visible = true;
            }
         }
      }
      
      override public function release() : void
      {
         this.m_stateSmallNotifMc = null;
         this.m_hudButton = null;
         super.release();
      }
   }
}

