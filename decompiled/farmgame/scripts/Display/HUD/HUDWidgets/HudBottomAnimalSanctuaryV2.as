package Display.HUD.HUDWidgets
{
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Managers.AnimalSanctuaryV2Manager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.filters.DropShadowFilter;
   
   public class HudBottomAnimalSanctuaryV2 extends HUDWidget
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
      
      private var m_doober_mc:MovieClip;
      
      private var m_dooberIconMc:MovieClip;
      
      private var m_dooberCountTf:ZwTextField;
      
      private var m_tokaenNameTf:ZwTextField;
      
      private var m_tokanIconMc:MovieClip;
      
      public function HudBottomAnimalSanctuaryV2(assetPath:String, featureName:String)
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
            this.m_hudButton.attachTooltip(new FarmTextTooltip("Animal Sanctuary!"));
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
         if(m_element.hasOwnProperty("doober_mc"))
         {
            this.m_doober_mc = m_element["doober_mc"] as MovieClip;
            this.m_doober_mc.visible = true;
            if(this.m_doober_mc.hasOwnProperty("dooberIcon_mc"))
            {
               this.m_dooberIconMc = this.m_doober_mc.dooberIcon_mc as MovieClip;
               this.m_dooberIconMc.visible = false;
               if(this.m_dooberIconMc.hasOwnProperty("dooberCount_tf"))
               {
                  this.m_dooberCountTf = new ZwTextField(this.m_dooberIconMc["dooberCount_tf"],"");
               }
               if(this.m_dooberIconMc.hasOwnProperty("token_name_tf"))
               {
                  this.m_tokaenNameTf = new ZwTextField(this.m_dooberIconMc["token_name_tf"],"");
               }
               if(this.m_dooberIconMc.hasOwnProperty("token_icon_mc"))
               {
                  this.m_tokanIconMc = this.m_dooberIconMc["token_icon_mc"] as MovieClip;
               }
            }
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
      
      public function showDooberOnTaskComplete(couponName:String, couponCount:int, playFrame:int) : void
      {
         this.m_doober_mc.visible = true;
         this.m_dooberIconMc.visible = true;
         this.m_dooberCountTf.text = couponCount.toString();
         this.m_dooberCountTf.visible = true;
         this.m_tokaenNameTf.text = couponName;
         this.m_tokaenNameTf.visible = true;
         this.m_tokanIconMc.visible = true;
         this.m_tokanIconMc.gotoAndStop(playFrame);
         this.m_doober_mc.gotoAndPlay(1);
         this.m_doober_mc.addEventListener(Event.ENTER_FRAME,this.onProgresssDooberPlayed);
      }
      
      private function onProgresssDooberPlayed(event:Event) : void
      {
         if(this.m_doober_mc)
         {
            if(this.m_doober_mc.currentFrame >= 95)
            {
               this.m_doober_mc.gotoAndStop(1);
               this.m_doober_mc.visible = false;
               this.m_dooberIconMc.visible = false;
               if(this.m_tokanIconMc)
               {
                  this.m_tokanIconMc.visible = false;
               }
               this.m_doober_mc.removeEventListener(Event.ENTER_FRAME,this.onProgresssDooberPlayed);
            }
         }
      }
      
      private function openUI(event:Event) : void
      {
         StatsManager.count("AnimalSanctuaryV2","HudClick","click");
         AnimalSanctuaryV2Manager.getInstance(this.m_featureName).showMainUI();
         this.removeDoober();
      }
      
      public function removeDoober() : void
      {
         this.m_doober_mc.visible = false;
         this.m_dooberIconMc.visible = false;
         this.m_dooberCountTf.visible = false;
         this.m_tokaenNameTf.visible = false;
         this.m_tokanIconMc.visible = false;
      }
      
      private function get manager() : AnimalSanctuaryV2Manager
      {
         return AnimalSanctuaryV2Manager.getInstance();
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
         if(Boolean(this.m_stateSmallNotifMc) && Boolean(this.m_stateIdleMc) && state != this.m_state)
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

