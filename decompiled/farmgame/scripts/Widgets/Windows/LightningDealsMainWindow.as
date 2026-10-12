package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Display.HUD.HUD;
   import Managers.FarmStatsManager;
   import Managers.LightningDealManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.LightningDealsBundleFrame;
   import Widgets.Frames.TabMenu;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   
   public class LightningDealsMainWindow extends FarmWindowWithTutorial
   {
      
      public var frame:LightningDealsBundleFrame;
      
      private const RECHECKINTERVAL:Number = 12000;
      
      private var m_featureUpdateOnTimer:Timer;
      
      private var m_featureName:String;
      
      private var m_tm:TabMenu;
      
      private var m_bodyText:ZwTextField;
      
      private var m_expiryTimer:Timer;
      
      public function LightningDealsMainWindow(featureName:String, assetPath:String)
      {
         this.m_featureName = featureName;
         super(this.m_featureName,assetPath,5,true,true);
         LightningDealManager.getInstance().selectedTab = 1;
      }
      
      override protected function postLoadComplete() : void
      {
         if(m_window.hasOwnProperty("whatisthis_mc"))
         {
            addWidget(new FarmAnimatedTextButton(m_window["whatisthis_mc"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"whatisthis_mc"),this.onHowDoesThisWorkClick));
         }
         addWidget(new ZwTextField(m_window["title_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_mainUI_title")));
         addWidget(this.m_bodyText = new ZwTextField(m_window["body_tf"]));
         addWidget(new ZwTextField(m_window["expiration_mc"]["expirationTab_mc"]["timer_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_expiring")));
         addWidget(this.frame = new LightningDealsBundleFrame(m_window["slots_mc"],this.m_featureName));
         var dt:Dictionary = LightningDealManager.getInstance().updateAndGetDisabledDealTypes();
         this.m_tm = new TabMenu(m_window["tabs_mc"],3,LightningDealManager.getInstance().selectedTab,this.updateFrameSlots,"tab_","_mc",dt);
         this.m_featureUpdateOnTimer = new Timer(this.RECHECKINTERVAL);
         this.m_featureUpdateOnTimer.addEventListener(TimerEvent.TIMER,this.recheckFeatureUI);
         this.m_featureUpdateOnTimer.start();
         this.recheckFeatureUI(new TimerEvent(TimerEvent.TIMER));
         super.postLoadComplete();
         this.m_expiryTimer = new Timer(1000);
         this.m_expiryTimer.addEventListener(TimerEvent.TIMER,this.updateBodyText);
         this.m_expiryTimer.start();
      }
      
      private function updateBodyText(event:Event) : void
      {
         var timeLeft:Number = NaN;
         if(LightningDealManager.getInstance().selectedTab == 1 && Boolean(this.m_bodyText))
         {
            timeLeft = LightningDealManager.getInstance().getTimeLeftInPresentDeal();
            this.m_bodyText.text = "Expiring in " + HUD.getformattedTimeLeft(timeLeft);
            this.m_bodyText.visible = true;
         }
         else
         {
            this.m_bodyText.visible = false;
         }
      }
      
      private function onHowDoesThisWorkClick(event:Event) : void
      {
         showTutorial();
      }
      
      public function updateNewTag(showFlag:Boolean) : void
      {
         (m_window["newTag_mc"] as MovieClip).visible = showFlag;
      }
      
      public function updateExpiryTag(showFlag:Boolean) : void
      {
         (m_window["expiration_mc"] as MovieClip).visible = (m_window["expiration_mc"]["expireIcon_mc"] as MovieClip).visible = (m_window["expiration_mc"]["expirationTab_mc"] as MovieClip).visible = showFlag;
      }
      
      public function updateFrameSlots(selectedTab:int) : void
      {
         var dealData:Array = LightningDealManager.getInstance().getDealDataByType(selectedTab);
         LightningDealManager.getInstance().selectedTab = selectedTab;
         this.frame.setupSlotData(dealData);
         this.frame.refresh();
         FarmStatsManager.count("lightning_deals","Tab","click",selectedTab.toString());
      }
      
      public function updateUI(dealData:Array, dt:Dictionary) : void
      {
         this.frame.setupSlotData(dealData);
         this.frame.refresh();
         this.m_tm.updateDisabledStates(dt);
      }
      
      override protected function release() : void
      {
         this.m_featureUpdateOnTimer.stop();
         this.m_featureUpdateOnTimer = null;
         this.m_expiryTimer.stop();
         this.m_expiryTimer = null;
         super.release();
      }
      
      private function recheckFeatureUI(t:TimerEvent) : void
      {
         LightningDealManager.getInstance().updateFeature();
      }
   }
}

