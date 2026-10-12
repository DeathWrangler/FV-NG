package Display.HUD.HUDWidgets
{
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Managers.AnimalSanctuaryManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.filters.DropShadowFilter;
   
   public class HudBottomCasablancaInnovationButton extends HUDWidget
   {
      
      public static const STATE_IDLE:int = 0;
      
      public static const STATE_HARVEST_NOTIF:int = 1;
      
      private static const HUD_MC:String = "hud_mc";
      
      private static const STATE_IDLE_MC:String = "hud_notif_0_mc";
      
      private static const STATE_SMALL_NOTIF_MC:String = "hud_notif_1_mc";
      
      private static const X_OFFSET:int = -780;
      
      private static const Y_OFFSET:int = 130;
      
      private var m_featureName:String;
      
      private var m_hudButton:FarmAnimatedButton;
      
      private var m_stateIdleMc:MovieClip;
      
      private var m_stateSmallNotifMc:MovieClip;
      
      private var m_doober0_mc:MovieClip;
      
      private var m_doober1_mc:MovieClip;
      
      private var m_doober2_mc:MovieClip;
      
      private var m_doober0IconMc:MovieClip;
      
      private var m_doober1IconMc:MovieClip;
      
      private var m_doober2IconMc:MovieClip;
      
      private var m_dooberCountTf1:ZwTextField;
      
      private var m_dooberCountTf2:ZwTextField;
      
      private var m_dooberCountTf3:ZwTextField;
      
      private var m_state:int = -1;
      
      public function HudBottomCasablancaInnovationButton(assetPath:String, featureName:String)
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
            this.m_hudButton.attachTooltip(new FarmTextTooltip("Animal Sanctuary"));
            if(m_element[HUD_MC].hasOwnProperty(STATE_SMALL_NOTIF_MC))
            {
               this.m_stateSmallNotifMc = m_element[HUD_MC][STATE_SMALL_NOTIF_MC] as MovieClip;
            }
            if(m_element.hasOwnProperty("food_mc"))
            {
               this.m_doober0_mc = m_element["food_mc"] as MovieClip;
               if(this.m_doober0_mc.hasOwnProperty("dooberIcon_mc"))
               {
                  this.m_doober0IconMc = this.m_doober0_mc.dooberIcon_mc;
                  if(this.m_doober0IconMc.hasOwnProperty("dooberCount_tf"))
                  {
                     this.m_dooberCountTf1 = new ZwTextField(this.m_doober0IconMc["dooberCount_tf"],"10");
                  }
               }
            }
            if(m_element.hasOwnProperty("habitat_mc"))
            {
               this.m_doober1_mc = m_element["habitat_mc"] as MovieClip;
               if(this.m_doober1_mc.hasOwnProperty("dooberIcon_mc"))
               {
                  this.m_doober1IconMc = this.m_doober1_mc.dooberIcon_mc;
                  if(this.m_doober1IconMc.hasOwnProperty("dooberCount_tf"))
                  {
                     this.m_dooberCountTf2 = new ZwTextField(this.m_doober1IconMc["dooberCount_tf"],"10");
                  }
               }
            }
            if(m_element.hasOwnProperty("health_mc"))
            {
               this.m_doober2_mc = m_element["health_mc"] as MovieClip;
               if(this.m_doober2_mc.hasOwnProperty("dooberIcon_mc"))
               {
                  this.m_doober2IconMc = this.m_doober2_mc.dooberIcon_mc;
                  if(this.m_doober2IconMc.hasOwnProperty("dooberCount_tf"))
                  {
                     this.m_dooberCountTf3 = new ZwTextField(this.m_doober2IconMc["dooberCount_tf"],"10");
                  }
               }
            }
         }
         if(this.manager.getUserState() != -1 && this.manager.isDropLimitReached() && !this.manager.isFeatureCompleted)
         {
            this.refresh(1);
         }
         else
         {
            this.refresh(0);
         }
      }
      
      public function showFoodDooberIcon(count:int) : void
      {
         if(this.m_doober0_mc)
         {
            this.m_doober0_mc.dooberIcon_mc.dooberCount_tf.text = "x" + count;
            this.m_doober0_mc.visible = true;
            this.m_doober0_mc.gotoAndPlay(2);
         }
      }
      
      public function showHabitatDooberIcon(count:int) : void
      {
         if(this.m_doober1_mc)
         {
            this.m_doober1_mc.dooberIcon_mc.dooberCount_tf.text = "x" + count;
            this.m_doober1_mc.visible = true;
            this.m_doober1_mc.gotoAndPlay(2);
         }
      }
      
      public function showHealthDooberIcon(count:*) : void
      {
         if(this.m_doober2_mc)
         {
            this.m_doober2_mc.dooberIcon_mc.dooberCount_tf.text = "x" + count;
            this.m_doober2_mc.visible = true;
            this.m_doober2_mc.gotoAndPlay(2);
         }
      }
      
      private function openUI(event:Event) : void
      {
         StatsManager.count(this.m_featureName,"HudClick","click",this.m_state.toString());
         AnimalSanctuaryManager.getInstance(this.m_featureName).showMainUI();
         if(this.manager.getUserState() != -1 && this.manager.isDropLimitReached() && !this.manager.isFeatureCompleted)
         {
            this.refresh(1);
         }
         else
         {
            this.refresh(0);
         }
      }
      
      private function get manager() : AnimalSanctuaryManager
      {
         return AnimalSanctuaryManager.getInstance();
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
         if(Boolean(this.m_stateSmallNotifMc) && state != this.m_state)
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

