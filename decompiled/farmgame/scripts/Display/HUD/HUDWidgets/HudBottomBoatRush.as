package Display.HUD.HUDWidgets
{
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Managers.BoatRushManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.filters.DropShadowFilter;
   
   public class HudBottomBoatRush extends HUDWidget
   {
      
      public static const STATE_IDLE:int = 0;
      
      public static const STATE_HARVEST_NOTIF:int = 1;
      
      private static const HUD_MC:String = "hud_mc";
      
      private static const STATE_IDLE_MC:String = "hud_notif_0_mc";
      
      private static const STATE_SMALL_NOTIF_MC:String = "hud_notif_1_mc";
      
      private static const X_OFFSET:int = -778;
      
      private static const Y_OFFSET:int = 130;
      
      private var m_featureName:String;
      
      private var m_hudButton:FarmAnimatedButton;
      
      private var m_stateIdleMc:MovieClip;
      
      private var m_stateSmallNotifMc:MovieClip;
      
      private var m_state:int = -1;
      
      public function HudBottomBoatRush(assetPath:String, featureName:String)
      {
         super(assetPath,Global.hud);
         this.m_featureName = featureName;
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         var parentFrame:ZwFrame = null;
         var description:String = null;
         var n1:Number = (GlobalEngine.serverTime - FarmGameUtil.synchronizedDateToNumber("08/31/2020")) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var n2:Number = (GlobalEngine.serverTime - FarmGameUtil.synchronizedDateToNumber("09/29/2020")) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         if(n1 > 0 && n2 < 0)
         {
            super.onLoadComplete(event);
            m_element.filters = [new DropShadowFilter()];
            this.setXY();
            parentFrame = new ZwFrame(m_element);
            (parentFrame.element as MovieClip).stop();
            if(m_element.hasOwnProperty(HUD_MC))
            {
               addWidget(this.m_hudButton = new FarmAnimatedButton(m_element[HUD_MC],this.openUI),true);
               description = ZLocUtils.t("Dialogs",this.m_featureName + "_hudOnHover");
               this.m_hudButton.attachTooltip(new FarmTextTooltip("Build It Up!"));
               if(m_element[HUD_MC].hasOwnProperty(STATE_IDLE_MC))
               {
                  this.m_stateIdleMc = m_element[HUD_MC][STATE_IDLE_MC] as MovieClip;
               }
               if(m_element[HUD_MC].hasOwnProperty(STATE_SMALL_NOTIF_MC))
               {
                  this.m_stateSmallNotifMc = m_element[HUD_MC][STATE_SMALL_NOTIF_MC] as MovieClip;
                  this.m_stateSmallNotifMc.visible = false;
               }
            }
            this.refresh(0);
         }
      }
      
      private function openUI(event:Event) : void
      {
         StatsManager.count("boatrush","HUD_BOATRUSH_2020","click",this.m_state.toString());
         BoatRushManager.getInstance().showMainWindow();
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
      }
      
      override public function release() : void
      {
         this.m_stateSmallNotifMc = null;
         this.m_hudButton = null;
         super.release();
      }
   }
}

