package Widgets.Windows.Expansion
{
   import Classes.ZItem.ExpansionAccess;
   import Classes.ZItem.FarmItem;
   import Classes.util.MovieClipUtils;
   import Classes.util.ObjectUtil;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.utils.Timer;
   
   public class ExpansionOnboardingWindow extends FarmWindow
   {
      
      private static const NUM_AUTOCENTER_DELAY_MSEC:Number = 10;
      
      protected var m_acceptText:String = null;
      
      protected var m_acceptCallback:Function = null;
      
      protected var m_cancelCallback:Function = null;
      
      protected var m_accessConfig:ExpansionAccess;
      
      private var m_centerTimer:Timer = null;
      
      private var m_currencyType:String = null;
      
      private var m_optionId:String = null;
      
      private var m_hideFirstTimeClose:Boolean = false;
      
      private var m_worldId:String = null;
      
      protected var m_ftueCallback:Function = null;
      
      protected var m_featureName:String = null;
      
      public function ExpansionOnboardingWindow(assetPath:String, acceptText:String = "", acceptCallback:Function = null, cancelCallback:Function = null, accessConfig:ExpansionAccess = null, worldId:String = null, ftueCallback:Function = null, featureName:String = null)
      {
         super(assetPath,true,true);
         this.m_acceptText = acceptText;
         this.m_acceptCallback = acceptCallback;
         this.m_cancelCallback = cancelCallback;
         this.m_accessConfig = accessConfig;
         this.m_worldId = worldId;
         this.m_ftueCallback = ftueCallback;
         this.m_featureName = featureName;
      }
      
      public function getCurrencyType() : String
      {
         return this.m_currencyType;
      }
      
      public function setHideFirstTimeClose(shouldHide:Boolean) : void
      {
         this.m_hideFirstTimeClose = shouldHide;
      }
      
      public function getOptionId() : String
      {
         return this.m_optionId;
      }
      
      override protected function postLoadComplete() : void
      {
         var daysLeft:int = 0;
         super.postLoadComplete();
         if(m_window.play_mc)
         {
            addWidget(new ZwFrame(m_window.play_mc));
            if(ObjectUtil.pathExists(m_window,["play_mc","generic_mc"]))
            {
               addWidget(new ZwFrame(m_window.play_mc.generic_mc));
               if(ObjectUtil.pathExists(m_window,["play_mc","generic_mc","generic_bt"]))
               {
                  addWidget(new FarmAnimatedTextButton(m_window.play_mc.generic_mc.generic_bt,this.m_acceptText,this.acceptPrompt));
               }
            }
            if(m_window.play_mc.close_bt)
            {
               addWidget(new FarmButton(m_window.play_mc.close_bt,this.cancelPrompt));
            }
            if(m_window.play_mc.whatisthis_mc)
            {
               if(this.m_ftueCallback != null)
               {
                  addWidget(new FarmAnimatedButton(m_window.play_mc.whatisthis_mc,this.FTUEPrompt));
               }
               else
               {
                  m_window.play_mc.whatisthis_mc.visible = false;
               }
            }
            if(ObjectUtil.pathExists(m_window,["play_mc","generic_mc","EALearnMore_mc","learnMore_bt"]))
            {
               if(this.m_ftueCallback != null)
               {
                  addWidget(new FarmAnimatedButton(m_window.play_mc.generic_mc.EALearnMore_mc.learnMore_bt,this.FTUEPrompt));
               }
               else
               {
                  m_window.play_mc.generic_mc.EALearnMore_mc.learnMore_bt.visible = false;
               }
            }
            MovieClipUtils.recursivePlay(m_window.play_mc);
            if(this.m_worldId != null && Boolean(m_window.legal_mc))
            {
               addWidget(new FarmAnimatedButton(m_window.legal_mc,this.onLegalClick));
            }
            if(m_window.play_mc.generic_mc.time_mc)
            {
               m_window.play_mc.generic_mc.time_mc.visible = true;
               m_window.play_mc.generic_mc.time_mc.time_tf.visible = true;
               if(this.m_accessConfig)
               {
                  daysLeft = this.m_accessConfig.daysLeft;
                  if(daysLeft > 1)
                  {
                     m_window.play_mc.generic_mc.time_mc.time_tf.text = daysLeft + " days left";
                  }
                  else if(daysLeft == 1)
                  {
                     m_window.play_mc.generic_mc.time_mc.time_tf.text = daysLeft + " day left";
                  }
                  else
                  {
                     m_window.play_mc.generic_mc.time_mc.time_tf.text = "few hours left";
                  }
               }
            }
         }
         this.initAutoCenterTimer();
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         if(this.m_hideFirstTimeClose && !Global.player.getSeenFlag(this.m_windowAssetPath + "FirstTimeWindowSeen"))
         {
            this.setCloseButtonVisible(false);
            Global.player.setSeenFlag(this.m_windowAssetPath + "FirstTimeWindowSeen");
         }
      }
      
      public function onLegalClick(event:Event) : void
      {
         var url:String = null;
         if(this.m_worldId)
         {
            url = ZLocUtils.t("Dialogs",this.m_worldId + "LegalOnboarding");
            navigateToURL(new URLRequest(url),"_blank");
         }
      }
      
      protected function initAutoCenterTimer() : void
      {
         if(this.m_centerTimer == null)
         {
            this.m_centerTimer = new Timer(NUM_AUTOCENTER_DELAY_MSEC);
            this.m_centerTimer.addEventListener(TimerEvent.TIMER,this.onAutoCenterTimer);
            this.m_centerTimer.start();
         }
      }
      
      private function onAutoCenterTimer(event:TimerEvent) : void
      {
         this.centerPopup();
      }
      
      protected function acceptPrompt(event:Event) : void
      {
         if(event.hasOwnProperty("optionId"))
         {
            this.m_optionId = event["optionId"];
            this.m_currencyType = this.m_accessConfig.getOptionCurrency(this.m_optionId);
         }
         else
         {
            this.m_currencyType = FarmItem.MARKET_CONTEXT_CASH;
         }
         if(this.m_acceptCallback != null)
         {
            this.m_acceptCallback();
         }
         this.onClose(event);
      }
      
      protected function cancelPrompt(event:Event) : void
      {
         if(this.m_cancelCallback != null)
         {
            this.m_cancelCallback();
         }
         this.onClose(event);
      }
      
      override protected function onClose(event:Event) : void
      {
         if(this.m_centerTimer != null)
         {
            this.m_centerTimer.stop();
            this.m_centerTimer.removeEventListener(TimerEvent.TIMER,this.onAutoCenterTimer);
            this.m_centerTimer = null;
         }
         this.m_acceptText = null;
         this.m_acceptCallback = null;
         this.m_cancelCallback = null;
         this.m_ftueCallback = null;
         super.onClose(event);
      }
      
      protected function FTUEPrompt(event:Event) : void
      {
         if(this.m_ftueCallback != null)
         {
            this.m_ftueCallback();
         }
      }
   }
}

