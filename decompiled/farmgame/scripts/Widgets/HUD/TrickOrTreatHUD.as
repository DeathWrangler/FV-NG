package Widgets.HUD
{
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.FarmStatsManager;
   import Managers.FeatureConfigManager;
   import Managers.TrickOrTreatManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.TrickOrTreatWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class TrickOrTreatHUD extends FarmHUDElement
   {
      
      private static const OFFSET_FROM_TOP:int = 90;
      
      private static const OFFSET_FROM_LEFT:int = -70;
      
      private static const HUD_ICON_SIZE:int = 60;
      
      private static const ATTRACT_DAYS_REMAINING:int = 3;
      
      private static const ASSET_PATH:String = "assets/hud/TrickOrTreat/FV_TrickOrTreatHUD.swf";
      
      public static const WHATS_THIS_PATH:String = "assets/dialogs/FV_GenericMedPopUp.swf";
      
      private static const ATTRACT_ANIMATION_FREQUENCY:int = 30000;
      
      private static const ATTRACT_DAYS:int = 3;
      
      private static const STATE_ACTIVE:int = 0;
      
      private static const STATE_INACTIVE:int = 1;
      
      private static const STATE_ATTRACT:int = 2;
      
      private static const TRICK_COUNT_PREFIX:String = "x";
      
      private var m_state:int = 1;
      
      private var m_activeMC:FarmAnimatedButton;
      
      private var m_inactiveMC:FarmAnimatedButton;
      
      private var m_attractMC:FarmAnimatedButton;
      
      private var m_getTreatsText:ZwTextField;
      
      private var m_animationTimer:Timer;
      
      private var m_visualEmphasis:Boolean = false;
      
      private var m_tooltipText:FarmTextTooltip;
      
      public function TrickOrTreatHUD()
      {
         super(ASSET_PATH);
         this.m_animationTimer = new Timer(ATTRACT_ANIMATION_FREQUENCY);
         this.m_animationTimer.addEventListener(TimerEvent.TIMER,this.playAnimation);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(this.m_activeMC = new FarmAnimatedButton(m_window.active_mc,this.onClick,true));
         addWidget(this.m_inactiveMC = new FarmAnimatedButton(m_window.inactive_mc,this.onClick,true));
         addWidget(this.m_attractMC = new FarmAnimatedButton(m_window.attract_mc,this.onClick,true));
         this.m_tooltipText = new FarmTextTooltip();
         this.m_activeMC.attachTooltip(this.m_tooltipText);
         this.m_inactiveMC.attachTooltip(this.m_tooltipText);
         this.m_activeMC.attachTooltip(this.m_tooltipText);
         show();
      }
      
      override protected function onShow() : void
      {
         super.onShow();
         var timeLeft:Array = FeatureConfigManager.getFeatureConfiguration(TrickOrTreatManager.instance.featureCreditName).getTimeRemaining();
         var offBoardingDays:int = FeatureConfigManager.getFeatureConfiguration(TrickOrTreatManager.instance.featureCreditName).getNumberConstant("offBoardingTime");
         if(timeLeft[0] <= offBoardingDays + ATTRACT_DAYS)
         {
            this.m_visualEmphasis = true;
         }
         this.m_animationTimer.start();
         this.adjustPosition();
         this.setGraphicalState();
      }
      
      public function adjustPosition() : void
      {
         x = Global.stage.stageWidth + OFFSET_FROM_LEFT;
         y = Global.hud.rightSideIconQueue.getVisibleIconsCount() * HUD_ICON_SIZE + OFFSET_FROM_TOP;
      }
      
      private function setGraphicalState() : void
      {
         var tooltipText:String = null;
         if(m_isLoaded)
         {
            switch(this.m_state)
            {
               case STATE_ACTIVE:
                  this.m_activeMC.visible = true;
                  this.m_inactiveMC.visible = false;
                  this.m_attractMC.visible = false;
                  this.m_tooltipText.setText(ZLocUtils.t("Dialogs",TrickOrTreatManager.instance.featureCreditName + "VisitActiveHUD"));
                  break;
               case STATE_INACTIVE:
                  this.m_activeMC.visible = false;
                  this.m_inactiveMC.visible = !this.m_visualEmphasis;
                  this.m_attractMC.visible = this.m_visualEmphasis;
                  tooltipText = Global.worldManager.isVisiting() ? ZLocUtils.t("Dialogs",TrickOrTreatManager.instance.featureCreditName + "VisitInactiveHUD") : ZLocUtils.t("Dialogs",TrickOrTreatManager.instance.featureCreditName + "HomeHUD");
                  this.m_tooltipText.setText(tooltipText);
                  break;
               case STATE_ATTRACT:
                  this.m_activeMC.visible = false;
                  this.m_inactiveMC.visible = false;
                  this.m_attractMC.visible = true;
                  tooltipText = Global.worldManager.isVisiting() ? ZLocUtils.t("Dialogs",TrickOrTreatManager.instance.featureCreditName + "VisitInactiveHUD") : ZLocUtils.t("Dialogs",TrickOrTreatManager.instance.featureCreditName + "HomeHUD");
                  this.m_tooltipText.setText(tooltipText);
            }
         }
      }
      
      private function playAnimation(event:TimerEvent) : void
      {
         if(m_window.attract_mc != null && m_window.attract_mc.animatedBat_mc != null)
         {
            (m_window.attract_mc.animatedBat_mc as MovieClip).play();
         }
         if(m_window.inactive_mc != null && m_window.inactive_mc.animatedBat_mc != null)
         {
            (m_window.inactive_mc.animatedBat_mc as MovieClip).play();
         }
         if(m_window.active_mc != null && m_window.active_mc.animatedBat_mc != null)
         {
            (m_window.active_mc.animatedBat_mc as MovieClip).play();
         }
      }
      
      public function attractAndOpen() : void
      {
         this.m_state = STATE_ATTRACT;
         this.setGraphicalState();
      }
      
      public function set active(isActive:Boolean) : void
      {
         this.m_state = isActive ? STATE_ACTIVE : STATE_INACTIVE;
         this.setGraphicalState();
      }
      
      private function onClick(event:Event) : void
      {
         FarmStatsManager.count(TrickOrTreatManager.instance.featureCreditName,"batHUD","clicks");
         if(!Global.worldManager.isVisiting())
         {
            this.m_animationTimer.stop();
            this.m_animationTimer.removeEventListener(TimerEvent.TIMER,this.playAnimation);
            UI.displayPopup(new TrickOrTreatWindow());
         }
         else if(!TrickOrTreatManager.instance.isOffBoarding())
         {
            switch(this.m_state)
            {
               case STATE_ACTIVE:
                  TrickOrTreatManager.instance.exitGameMode();
                  break;
               case STATE_INACTIVE:
                  TrickOrTreatManager.instance.enterGameMode();
            }
         }
      }
   }
}

