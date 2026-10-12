package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Managers.BringBackWinterManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.BringBackWinterFrame;
   import Widgets.Slots.BringBackWinterSFBuySlot;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   
   public class BBWinterReskinnableWindow extends FarmWindow
   {
      
      protected static const FTUE_FLAG:String = "_ftue";
      
      private static const NUM_TUTORIAL_FRAMES:int = 3;
      
      private static const NUM_TUTORIAL_SCENES:int = 3;
      
      protected var m_featureName:String;
      
      protected var m_windowName:String;
      
      protected var m_ftue:MovieClip = null;
      
      protected var m_tutorialButton:FarmAnimatedTextButton;
      
      protected var m_tutorialScene:int;
      
      protected var m_whatIsThis_mc:FarmAnimatedButton;
      
      protected var m_learnMore_mc:FarmAnimatedButton;
      
      protected var frame_mc:MovieClip;
      
      protected var outer_frame:ZwFrame;
      
      protected var buySnowflake_frame:ZwFrame;
      
      protected var m_buySlots:Array = new Array();
      
      protected var m_collectionSlots:Array = new Array();
      
      protected var m_slotsFrame:BringBackWinterFrame;
      
      private var m_ftueOn:Boolean = false;
      
      public function BBWinterReskinnableWindow(featureName:String = null)
      {
         this.m_featureName = featureName;
         this.m_windowName = BringBackWinterManager.getInstance(featureName).getWindowName();
         var dialogPath:String = BringBackWinterManager.getInstance(featureName).getMainDialogURL();
         super(dialogPath);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_windowName + "_title")),true);
         }
         if(m_window.hasOwnProperty("frame_mc"))
         {
            this.frame_mc = m_window.frame_mc;
            addWidget(this.outer_frame = new ZwFrame(m_window.frame_mc),true);
         }
         if(m_window.hasOwnProperty("whatisthis_mc") && !this.manager.isFeatureEnd())
         {
            this.m_whatIsThis_mc = addWidget(new FarmAnimatedTextButton(m_window.whatisthis_mc,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"HowDoesThisWork"),this.howDoesThisWorkClick),true) as FarmAnimatedButton;
         }
         if(m_window.hasOwnProperty("learnMore_mc"))
         {
            this.m_learnMore_mc = addWidget(new FarmAnimatedTextButton(m_window.learnMore_mc,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"LearnMore"),this.openUrl),true) as FarmAnimatedButton;
         }
         this.setUpMainWindow();
         this.setUpSFBuyWindow();
         this.initializeProgressBar();
         var firstTimeSeenFlag:String = this.m_featureName + BringBackWinterManager.getInstance(this.m_featureName).getFeatureOptionsKey() + FTUE_FLAG;
         if(!Global.player.getSeenFlag(firstTimeSeenFlag))
         {
            this.setupFTUE();
            this.showFTUE();
         }
      }
      
      protected function setUpMainWindow() : void
      {
      }
      
      protected function initializeProgressBar() : void
      {
      }
      
      private function get manager() : BringBackWinterManager
      {
         return BringBackWinterManager.getInstance(this.m_featureName);
      }
      
      protected function setUpSFBuyWindow() : void
      {
         var buySnowflake_mc:MovieClip = null;
         var buySlot:BringBackWinterSFBuySlot = null;
         var sfPkg:String = null;
         var i:int = 0;
         if(m_window.hasOwnProperty("buySnowflake_mc"))
         {
            buySnowflake_mc = m_window.buySnowflake_mc as MovieClip;
            addWidget(this.buySnowflake_frame = new ZwFrame(m_window.buySnowflake_mc),false);
            if(m_window["buySnowflake_mc"]["subtitle1_tf"])
            {
               this.buySnowflake_frame.addWidget(new ZwTextField(buySnowflake_mc.subtitle1_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_windowName + "_buysfSubtitle")),true);
            }
            if(m_window["buySnowflake_mc"]["buyClose_bt"])
            {
               this.buySnowflake_frame.addWidget(new FarmButton(buySnowflake_mc.buyClose_bt,this.onCloseBuyWindow));
            }
            sfPkg = null;
            for(i = 0; i < BringBackWinterManager.SFTYPES.length; i++)
            {
               sfPkg = BringBackWinterManager.getSfTypeToPkg(BringBackWinterManager.SFTYPES[i]);
               if(buySnowflake_mc.hasOwnProperty("sfbuy_" + BringBackWinterManager.SFTYPES[i]))
               {
                  this.buySnowflake_frame.addWidget(buySlot = new BringBackWinterSFBuySlot(buySnowflake_mc["sfbuy_" + BringBackWinterManager.SFTYPES[i]],this.m_featureName,sfPkg),true);
                  this.m_buySlots.push(buySlot);
               }
            }
            if(buySnowflake_mc.hasOwnProperty("sfbuy_bundle"))
            {
               this.buySnowflake_frame.addWidget(buySlot = new BringBackWinterSFBuySlot(buySnowflake_mc["sfbuy_bundle"],this.m_featureName,BringBackWinterManager.SF_BUNDLE_PKG),true);
               this.m_buySlots.push(buySlot);
            }
         }
      }
      
      protected function updateSfCollection() : void
      {
      }
      
      protected function updateProgressBar(percentValue:Number) : void
      {
      }
      
      protected function refreshSlots() : void
      {
         if(this.m_slotsFrame)
         {
            this.m_slotsFrame.refreshSlots();
         }
      }
      
      protected function onCloseBuyWindow(event:Event) : void
      {
         if(this.buySnowflake_frame)
         {
            this.buySnowflake_frame.visible = false;
         }
         this.update();
      }
      
      protected function setupFTUE() : void
      {
         if(Boolean(m_window) && Boolean(m_window.tutorial_mc))
         {
            this.m_ftue = m_window.tutorial_mc as MovieClip;
            if(this.m_ftue)
            {
               this.m_ftue.visible = false;
               if(this.m_tutorialButton == null && this.m_ftue.hasOwnProperty("okay_bt"))
               {
                  addWidget(this.m_tutorialButton = new FarmAnimatedTextButton(this.m_ftue.okay_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"Okay"),this.onFTUEOKBtnClick));
               }
            }
         }
      }
      
      protected function onFTUEOKBtnClick(event:Event) : void
      {
         var firstTimeSeenFlag:String = null;
         if(this.m_tutorialScene++ < this.getNumTutorialScenes())
         {
            (this.m_ftue as MovieClip).play();
         }
         else
         {
            firstTimeSeenFlag = this.m_featureName + BringBackWinterManager.getInstance(this.m_featureName).getFeatureOptionsKey() + FTUE_FLAG;
            Global.player.setSeenFlag(firstTimeSeenFlag);
            this.m_ftue.visible = false;
            this.m_ftueOn = false;
            FarmStatsManager.count(this.m_featureName,"FTUE","end");
         }
      }
      
      protected function getNumTutorialScenes() : int
      {
         return NUM_TUTORIAL_SCENES;
      }
      
      protected function showFTUE() : void
      {
         if(!this.m_ftue)
         {
            this.setupFTUE();
         }
         if(this.m_ftue)
         {
            this.m_tutorialScene = 1;
            this.m_ftue.gotoAndStop(this.m_tutorialScene);
            this.m_tutorialButton.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"Okay");
            this.m_ftue.visible = true;
            this.m_ftueOn = true;
            FarmStatsManager.count(this.m_featureName,"FTUE","start");
         }
      }
      
      private function howDoesThisWorkClick(event:Event) : void
      {
         this.setupFTUE();
         this.showFTUE();
      }
      
      private function openUrl(event:Event) : void
      {
         navigateToURL(new URLRequest(ZLocUtils.t("Dialogs","MOTD_MERRY_MARSHALL_linkURL")),"_blank");
      }
      
      override protected function onClose(event:Event) : void
      {
         BringBackWinterManager.getInstance(this.m_featureName).onWindowClose();
         super.onClose(event);
      }
      
      protected function onBuyClick(event:Event) : void
      {
         if(!this.isFTUEOn() && Boolean(this.buySnowflake_frame))
         {
            this.buySnowflake_frame.visible = true;
         }
      }
      
      public function update() : void
      {
         this.updateSfCollection();
         this.refreshSlots();
         this.updateProgressBarAccordingToStageCompleted();
      }
      
      private function updateProgressBarAccordingToStageCompleted() : void
      {
         var stageAtTheMoment:int = BringBackWinterManager.getInstance(this.m_featureName).getNumofStageCompleted();
         this.updateProgressBar(stageAtTheMoment);
      }
      
      public function isFTUEOn() : Boolean
      {
         return this.m_ftueOn;
      }
   }
}

