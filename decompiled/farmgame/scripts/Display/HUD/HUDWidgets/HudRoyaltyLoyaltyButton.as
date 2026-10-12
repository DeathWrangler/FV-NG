package Display.HUD.HUDWidgets
{
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.MOTD.RoyaltyLoyaltyProgramMOTDWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.DropShadowFilter;
   import flash.filters.GlowFilter;
   
   public class HudRoyaltyLoyaltyButton extends HUDWidget
   {
      
      public static const STATE_IDLE:int = 0;
      
      public static const STATE_HARVEST_NOTIF:int = 1;
      
      private static const HUD_MC:String = "hud_mc";
      
      private static const STATE_IDLE_MC:String = "hud_notif_0_mc";
      
      private static const STATE_SMALL_NOTIF_MC:String = "hud_notif_1_mc";
      
      private static const X_OFFSET:int = 320;
      
      private static const Y_OFFSET:int = 16;
      
      private var m_featureName:String;
      
      private var m_hudButton:FarmAnimatedButton;
      
      private var m_stateIdleMc:MovieClip;
      
      private var m_stateSmallNotifMc:MovieClip;
      
      private var m_state:int = -1;
      
      public function HudRoyaltyLoyaltyButton(assetPath:String, featureName:String)
      {
         super(assetPath,Global.hud);
         this.m_featureName = featureName;
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         var description:String = null;
         super.onLoadComplete(event);
         this.setXY();
         if(Boolean(m_element) && m_element.hasOwnProperty(HUD_MC))
         {
            addWidget(this.m_hudButton = new FarmAnimatedButton(m_element[HUD_MC],this.displayRoyaltyLoyaltyMotd),true);
            description = ZLocUtils.t("Dialogs",this.m_featureName + "_hudOnHover");
            this.m_hudButton.attachTooltip(new FarmTextTooltip(description));
            this.m_hudButton.registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
            this.m_hudButton.registerEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
            if(m_element[HUD_MC].hasOwnProperty(STATE_IDLE_MC))
            {
               this.m_stateIdleMc = m_element[HUD_MC][STATE_IDLE_MC] as MovieClip;
            }
            if(m_element[HUD_MC].hasOwnProperty(STATE_SMALL_NOTIF_MC))
            {
               this.m_stateSmallNotifMc = m_element[HUD_MC][STATE_SMALL_NOTIF_MC] as MovieClip;
            }
         }
      }
      
      private function onMouseOver(e:Event) : void
      {
         if(this.m_hudButton)
         {
            m_element.filters = [new GlowFilter(16777113,1,14,14,1.83)];
         }
      }
      
      private function onMouseOut(e:Event) : void
      {
         if(this.m_hudButton)
         {
            m_element.filters = [new DropShadowFilter()];
         }
      }
      
      private function displayRoyaltyLoyaltyMotd(event:Event) : void
      {
         StatsManager.count("royalty","click");
         UI.displayPopup(new RoyaltyLoyaltyProgramMOTDWindow());
      }
      
      public function setXY() : void
      {
         if(m_loader)
         {
            m_loader.x = X_OFFSET;
            m_loader.y = Y_OFFSET;
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

