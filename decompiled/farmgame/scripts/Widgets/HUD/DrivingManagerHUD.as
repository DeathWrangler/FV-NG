package Widgets.HUD
{
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import GameMode.GMCombine;
   import GameMode.GMCombineAll;
   import GameMode.GMHarvester;
   import GameMode.GMHarvesterAll;
   import GameMode.GMSeeder;
   import GameMode.GMSeederAll;
   import GameMode.GMTractorPlow;
   import GameMode.GMTractorPlowAll;
   import GameMode.GameMode;
   import Managers.InfiniteTurboManager;
   import Managers.TurboPPHManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class DrivingManagerHUD extends FarmHUDElement
   {
      
      private static const HOFFSET_FROM_CENTER:int = -343;
      
      private static const VOFFSET_FROM_BOTTOM:int = 181;
      
      private static const ASSET_PATH:String = "assets/hud/TurboPPH/FV_DrivingManager_v2.swf";
      
      public static const WHATS_THIS_PATH:String = "assets/dialogs/FV_GenericMedPopUp.swf";
      
      public static const STATE_ACTIVE:int = 0;
      
      public static const STATE_INACTIVE:int = 1;
      
      private static const STATE_ATTRACT:int = 2;
      
      private static const TURBO_COUNT_PREFIX:String = "x";
      
      private static const TURBOS_PURCHASED_DISPLAY_TIMER:int = 3000;
      
      private var m_state:int = 1;
      
      private var m_activeMC:FarmAnimatedButton;
      
      private var m_inactiveMC:FarmAnimatedButton;
      
      private var m_attractMC:FarmAnimatedButton;
      
      private var m_turboCountTF:ZwTextField;
      
      private var m_turboInfiniteCountMC:ZwWidget;
      
      private var m_getTurboTF:ZwTextField;
      
      private var m_clickToBuyTF:ZwTextField;
      
      private var m_hideTimer:Timer = null;
      
      private var m_hideAfterShow:Boolean = false;
      
      public function DrivingManagerHUD()
      {
         var windowPath:String = ASSET_PATH;
         super(windowPath);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(new FarmAnimatedButton(m_window.whatisthis_mc,this.onWhatsThisClicked));
         addWidget(this.m_activeMC = new FarmAnimatedButton(m_window.active_mc,this.onClick));
         addWidget(this.m_inactiveMC = new FarmAnimatedButton(m_window.inactive_mc,this.onClick));
         addWidget(this.m_attractMC = new FarmAnimatedButton(m_window.attract_mc,this.onBuyClick,true));
         addWidget(this.m_turboCountTF = new ZwTextField(m_window.turbocount_tf));
         addWidget(this.m_getTurboTF = new ZwTextField(m_window.attract_mc.getturbo_tf));
         addWidget(this.m_clickToBuyTF = new ZwTextField(m_window.attract_mc.clicktobuy_tf));
         addWidget(this.m_turboInfiniteCountMC = new ZwWidget(m_window.symbol_mc));
         this.m_getTurboTF.text = ZLocUtils.t("Dialogs","Turbo_GetTurbo");
         this.m_clickToBuyTF.text = ZLocUtils.t("Dialogs","Turbo_ClickToBuy");
      }
      
      override protected function onShow() : void
      {
         super.onShow();
         this.adjustPosition();
         this.turboCountChanged();
         this.setGraphicalState();
         if(this.m_hideAfterShow)
         {
            this.m_hideAfterShow = false;
            this.hideLater();
         }
         else if(this.m_hideTimer)
         {
            this.m_hideTimer.stop();
            this.m_hideTimer = null;
         }
      }
      
      override protected function onHide() : void
      {
         super.onHide();
      }
      
      override protected function onFullScreen() : void
      {
         super.onFullScreen();
         this.adjustPosition();
      }
      
      public function hideLater() : void
      {
         this.turboCountChanged();
         this.setGraphicalState();
         if(this.m_hideTimer == null)
         {
            this.m_hideTimer = new Timer(TURBOS_PURCHASED_DISPLAY_TIMER,1);
            this.m_hideTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onHideTimerComplete);
            this.m_hideTimer.start();
         }
      }
      
      private function onHideTimerComplete(event:TimerEvent) : void
      {
         hide();
         this.m_hideTimer.stop();
         this.m_hideTimer = null;
      }
      
      private function adjustPosition() : void
      {
         x = Global.stage.stageWidth / 2 + HOFFSET_FROM_CENTER;
         y = Global.stage.stageHeight - VOFFSET_FROM_BOTTOM;
      }
      
      private function setGraphicalState() : void
      {
         if(m_isLoaded)
         {
            switch(this.m_state)
            {
               case STATE_ACTIVE:
                  this.m_activeMC.visible = true;
                  this.m_inactiveMC.visible = false;
                  this.m_attractMC.visible = false;
                  this.showTurboCounts();
                  break;
               case STATE_INACTIVE:
                  this.m_activeMC.visible = false;
                  this.m_inactiveMC.visible = true;
                  this.m_attractMC.visible = false;
                  this.showTurboCounts();
                  break;
               case STATE_ATTRACT:
                  this.m_activeMC.visible = false;
                  this.m_inactiveMC.visible = false;
                  this.m_attractMC.visible = true;
                  this.m_turboCountTF.visible = false;
            }
         }
      }
      
      private function onClick(event:Event) : void
      {
         switch(this.m_state)
         {
            case STATE_ACTIVE:
               if(TurboPPHManager.getInstance().disableTurboMode())
               {
                  this.m_state = STATE_INACTIVE;
                  this.setGraphicalState();
               }
               break;
            case STATE_INACTIVE:
               if(TurboPPHManager.getInstance().enableTurboMode())
               {
                  this.m_state = STATE_ACTIVE;
                  this.setGraphicalState();
               }
         }
      }
      
      public function turboCountChanged() : void
      {
         if(m_isLoaded)
         {
            this.m_turboCountTF.text = TURBO_COUNT_PREFIX + String(Global.player.turboChargers);
         }
         var updatedState:int = this.getState();
         if(updatedState != this.m_state)
         {
            this.m_state = updatedState;
            this.setGraphicalState();
         }
         if(!m_shown)
         {
            this.m_hideAfterShow = true;
            show();
         }
      }
      
      private function getState() : int
      {
         var topMode:GameMode = Global.world.getTopGameMode();
         var state:int = this.m_state;
         if(!Global.player.hasEnoughTurbos(1))
         {
            state = STATE_ATTRACT;
         }
         else if(topMode is GMTractorPlowAll)
         {
            state = STATE_ACTIVE;
         }
         else if(topMode is GMSeederAll)
         {
            state = STATE_ACTIVE;
         }
         else if(topMode is GMHarvesterAll)
         {
            state = STATE_ACTIVE;
         }
         else if(topMode is GMCombineAll)
         {
            state = STATE_ACTIVE;
         }
         else if(topMode is GMTractorPlow)
         {
            state = STATE_INACTIVE;
         }
         else if(topMode is GMSeeder)
         {
            state = STATE_INACTIVE;
         }
         else if(topMode is GMHarvester)
         {
            state = STATE_INACTIVE;
         }
         else if(topMode is GMCombine)
         {
            state = STATE_INACTIVE;
         }
         return state;
      }
      
      private function onBuyClick(event:Event) : void
      {
         UI.displayMarketDialog("turbopph","aide",null,"fuel",null,"turbo");
      }
      
      private function onWhatsThisClicked(event:Event) : void
      {
         var msg:String = ZLocUtils.t("Dialogs","WhatIsTurbo");
         var whatsThisDialog:GenericPopup = new GenericPopup(msg,GenericPopup.TYPE_OK,null,WHATS_THIS_PATH);
         whatsThisDialog.setAcceptTextName("Okay");
         UI.displayPopup(whatsThisDialog,false,"whatIsThisPopup",true);
      }
      
      private function showTurboCounts() : void
      {
         if(InfiniteTurboManager.isEnabledInCurrentWorld())
         {
            this.m_turboCountTF.visible = false;
            this.m_turboInfiniteCountMC.visible = true;
         }
         else
         {
            this.m_turboCountTF.visible = true;
            this.m_turboInfiniteCountMC.visible = false;
         }
      }
      
      public function getTurboState() : int
      {
         return this.m_state;
      }
   }
}

