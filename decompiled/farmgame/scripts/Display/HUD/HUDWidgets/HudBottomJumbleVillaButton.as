package Display.HUD.HUDWidgets
{
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.JumbleVillaManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.filters.DropShadowFilter;
   
   public class HudBottomJumbleVillaButton extends HUDWidget
   {
      
      private static const X_OFFSET:int = -778;
      
      private static const Y_OFFSET:int = 130;
      
      private static const HUD_MC:String = "hud_mc";
      
      private static const STATE_IDLE_MC:String = "hud_notif_0_mc";
      
      private static const STATE_SMALL_NOTIF_MC:String = "hud_notif_1_mc";
      
      private var m_featureName:String;
      
      private var m_hudButton:FarmAnimatedButton;
      
      private var m_stateIdleMc:MovieClip;
      
      private var m_stateSmallNotifMc:MovieClip;
      
      private var m_doober_mc:MovieClip;
      
      private var m_dooberIcon_mc:MovieClip;
      
      private var m_dooberCount_tf:ZwTextField;
      
      public function HudBottomJumbleVillaButton(assetPath:String, featureName:String = "JumbleVilla")
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
            addWidget(this.m_hudButton = new FarmAnimatedButton(m_element[HUD_MC],this.openUI),true);
            description = ZLocUtils.t("Dialogs",this.m_featureName + "_hudOnHover");
            this.m_hudButton.attachTooltip(new FarmTextTooltip("JumbleVilla!"));
            if(m_element[HUD_MC].hasOwnProperty(STATE_IDLE_MC))
            {
               this.m_stateIdleMc = m_element[HUD_MC][STATE_IDLE_MC] as MovieClip;
            }
            if(m_element[HUD_MC].hasOwnProperty(STATE_SMALL_NOTIF_MC))
            {
               this.m_stateSmallNotifMc = m_element[HUD_MC][STATE_SMALL_NOTIF_MC] as MovieClip;
               this.m_stateSmallNotifMc.visible = false;
            }
            if(m_element.hasOwnProperty("doober_mc"))
            {
               this.m_doober_mc = m_element["doober_mc"] as MovieClip;
               if(this.m_doober_mc.hasOwnProperty("dooberIcon_mc"))
               {
                  this.m_dooberIcon_mc = this.m_doober_mc["dooberIcon_mc"] as MovieClip;
                  if(this.m_dooberIcon_mc.hasOwnProperty("dooberCount_tf"))
                  {
                     this.m_dooberCount_tf = new ZwTextField(this.m_dooberIcon_mc["dooberCount_tf"]);
                  }
               }
            }
         }
      }
      
      private function openUI(event:Event) : void
      {
         JumbleVillaManager.getInstance().showMainWindow();
         this.refresh(0);
      }
      
      private function refresh(i:int) : void
      {
      }
      
      public function setXY() : void
      {
         if(m_loader)
         {
            m_loader.x = (GlobalEngine.stage.stageWidth - UI.DEFAULT_WIDTH) / 2 - X_OFFSET;
            m_loader.y = Global.stage.stageHeight - Y_OFFSET;
         }
      }
      
      override public function release() : void
      {
         this.m_stateSmallNotifMc = null;
         this.m_hudButton = null;
         super.release();
      }
      
      public function playProgressDoober() : void
      {
         if(this.m_doober_mc)
         {
            this.m_doober_mc.visible = true;
            if(this.m_dooberIcon_mc)
            {
               this.m_dooberIcon_mc.visible = true;
            }
         }
         this.m_doober_mc.gotoAndPlay(1);
         this.m_doober_mc.addEventListener(Event.ENTER_FRAME,this.onProgresssDooberPlayed);
      }
      
      private function onProgresssDooberPlayed(event:Event) : void
      {
         if(this.m_doober_mc)
         {
            if(this.m_doober_mc.currentFrame == 31)
            {
               this.m_doober_mc.gotoAndStop(1);
               this.m_doober_mc.visible = false;
               if(this.m_dooberIcon_mc)
               {
                  this.m_dooberIcon_mc.visible = false;
               }
               this.m_doober_mc.removeEventListener(Event.ENTER_FRAME,this.onProgresssDooberPlayed);
            }
         }
         this.m_stateSmallNotifMc.visible = this.manager.isActivePuzzleCompleted(true);
      }
      
      private function get manager() : JumbleVillaManager
      {
         return JumbleVillaManager.getInstance(this.m_featureName);
      }
   }
}

