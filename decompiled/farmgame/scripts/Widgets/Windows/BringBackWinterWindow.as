package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Managers.BringBackWinterManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.BringBackWinterFrame;
   import Widgets.Slots.BringBackWinterSFCollectionSlot;
   import Widgets.TextFields.FarmTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class BringBackWinterWindow extends BBWinterReskinnableWindow
   {
      
      private static const NUM_TUTORIAL_FRAMES:int = 3;
      
      private static const NUM_TUTORIAL_SCENES:int = 3;
      
      private static const NPC_SAD:int = 1;
      
      private static const NPC_NEUTRAL:int = 2;
      
      private static const NPC_ECSTATIC:int = 3;
      
      private var sfcounter_mc:MovieClip;
      
      private var sfcounter_frame:ZwFrame;
      
      private var dailylogin_mc:MovieClip;
      
      private var dailylogin_frame:ZwFrame;
      
      private var zing_mc:MovieClip;
      
      private var zang_mc:MovieClip;
      
      private var timeleft_frame:ZwFrame;
      
      private var time_tf:FarmTextField;
      
      private var congrats_tf:FarmTextField;
      
      private var subtitle1_tf:FarmTextField;
      
      private var subtitle2_tf:FarmTextField;
      
      public function BringBackWinterWindow(featureName:String = null)
      {
         super(featureName);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         this.setUpDailyCollectWindow();
         this.setUpNpcs();
         var firstTimeSeenFlag:String = m_featureName + BringBackWinterManager.getInstance(m_featureName).getFeatureOptionsKey() + FTUE_FLAG;
         if(Global.player.getSeenFlag(firstTimeSeenFlag))
         {
            this.setNPCStates();
         }
      }
      
      override protected function setUpMainWindow() : void
      {
         var sfcounter_mc:MovieClip = null;
         var text:String = null;
         var collectionSlot:BringBackWinterSFCollectionSlot = null;
         var i:int = 0;
         var timeleft_mc:MovieClip = null;
         var timeRemaining:Array = null;
         var sTimeRemaining:String = null;
         if(m_window.hasOwnProperty("sfcounter_mc"))
         {
            sfcounter_mc = m_window.sfcounter_mc as MovieClip;
            addWidget(this.sfcounter_frame = new ZwFrame(m_window.sfcounter_mc),true);
            if(sfcounter_mc.slot_mc)
            {
               this.sfcounter_frame.addWidget(m_slotsFrame = new BringBackWinterFrame(m_window.slot_mc,m_featureName,this),true);
            }
            if(sfcounter_mc.hasOwnProperty("timeleft_mc"))
            {
               timeleft_mc = sfcounter_mc["timeleft_mc"] as MovieClip;
               this.sfcounter_frame.addWidget(this.timeleft_frame = new ZwFrame(sfcounter_mc.timeleft_mc),!BringBackWinterManager.getInstance(m_featureName).isFeatureEnd());
            }
            if(timeleft_mc.hasOwnProperty("time_tf"))
            {
               timeRemaining = BringBackWinterManager.getInstance(m_featureName).getTimeRemaining();
               sTimeRemaining = "";
               if(parseInt(timeRemaining[0]) > 0)
               {
                  sTimeRemaining = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"BBWinter_TimeLeftDays",{"time":timeRemaining[0]});
               }
               else if(parseInt(timeRemaining[1]) > 0)
               {
                  sTimeRemaining = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"BBWinter_TimeLeftHours",{"time":timeRemaining[1]});
               }
               else if(parseInt(timeRemaining[2]) > 0)
               {
                  sTimeRemaining = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"BBWinter_TimeLeftMinutes",{"time":timeRemaining[2]});
               }
               else
               {
                  sTimeRemaining = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"BBWinter_TimeLeftDays",{"time":timeRemaining[0]});
               }
               this.timeleft_frame.addWidget(this.time_tf = new FarmTextField(timeleft_mc.time_tf,sTimeRemaining),true);
            }
            if(timeleft_mc.hasOwnProperty("left_tf"))
            {
               this.timeleft_frame.addWidget(new ZwTextField(timeleft_mc.left_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_windowName + "_timeLeftText")),true);
            }
            if(sfcounter_mc.hasOwnProperty("comment_tf") && BringBackWinterManager.getInstance(m_featureName).isFeatureEnd())
            {
               this.sfcounter_frame.addWidget(this.congrats_tf = new FarmTextField(sfcounter_mc.comment_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_windowName + "_sfCounterCongratsTitle")),true);
            }
            text = "";
            if(sfcounter_mc.hasOwnProperty("subtitle1_tf"))
            {
               if(BringBackWinterManager.getInstance(m_featureName).isFeatureEnd())
               {
                  text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_windowName + "_sfCounterSubtitle_1_1");
               }
               else
               {
                  text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_windowName + "_sfCounterSubtitle_1");
               }
               this.sfcounter_frame.addWidget(this.subtitle1_tf = new FarmTextField(sfcounter_mc.subtitle1_tf,text),true);
            }
            if(sfcounter_mc.hasOwnProperty("subtitle2_tf"))
            {
               if(BringBackWinterManager.getInstance(m_featureName).isFeatureEnd())
               {
                  text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_windowName + "_sfCounterSubtitle_2_1");
               }
               else
               {
                  text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_windowName + "_sfCounterSubtitle_2");
               }
               this.sfcounter_frame.addWidget(this.subtitle2_tf = new FarmTextField(sfcounter_mc.subtitle2_tf,text),true);
            }
            for(i = 0; i < BringBackWinterManager.SFTYPES.length; i++)
            {
               if(sfcounter_mc.hasOwnProperty("snowflake_" + BringBackWinterManager.SFTYPES[i] + "_mc"))
               {
                  collectionSlot = new BringBackWinterSFCollectionSlot(sfcounter_mc["snowflake_" + BringBackWinterManager.SFTYPES[i] + "_mc"],m_featureName,BringBackWinterManager.SFTYPES[i]);
                  this.sfcounter_frame.addWidget(collectionSlot,true);
                  m_collectionSlots.push(collectionSlot);
               }
            }
            if(sfcounter_mc.hasOwnProperty("buy_bt"))
            {
               this.sfcounter_frame.addWidget(new FarmAnimatedTextButton(sfcounter_mc["buy_bt"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_windowName + "_Buy"),onBuyClick));
            }
         }
      }
      
      private function setUpDailyCollectWindow() : void
      {
         if(m_window.hasOwnProperty("dailylogin_mc"))
         {
            this.dailylogin_mc = m_window.dailylogin_mc as MovieClip;
            addWidget(this.dailylogin_frame = new ZwFrame(m_window.dailylogin_mc),false);
            if(this.dailylogin_mc.hasOwnProperty("subtitle2_tf"))
            {
               this.dailylogin_frame.addWidget(new FarmTextField(this.dailylogin_mc.subtitle2_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_windowName + "_dailyCollectSubtitle")),true);
            }
            if(this.dailylogin_mc.hasOwnProperty("collect_bt"))
            {
               this.dailylogin_frame.addWidget(new FarmAnimatedTextButton(this.dailylogin_mc["collect_bt"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_windowName + "_Collect"),this.collectDailySnowFlake));
            }
            if(this.dailylogin_mc.hasOwnProperty("loginClose_bt"))
            {
               this.dailylogin_frame.addWidget(new FarmButton(this.dailylogin_mc.loginClose_bt,this.onCloseDailyCollectWindow));
            }
            if(BringBackWinterManager.getInstance(m_featureName).canCollectDailySnowFlake())
            {
               this.dailylogin_frame.visible = true;
            }
         }
      }
      
      override protected function showFTUE() : void
      {
         super.showFTUE();
         if(m_ftue)
         {
            if(!this.zing_mc || !this.zang_mc)
            {
               this.setUpNpcs();
            }
            this.setNPCStates(true);
         }
      }
      
      private function setUpNpcs() : void
      {
         if(m_window.hasOwnProperty("zing_mc"))
         {
            this.zing_mc = m_window.zing_mc as MovieClip;
            this.zing_mc.visible = false;
         }
         if(m_window.hasOwnProperty("zang_mc"))
         {
            this.zang_mc = m_window.zang_mc as MovieClip;
            this.zang_mc.visible = false;
         }
      }
      
      private function setNPCStates(forFtue:Boolean = false) : void
      {
         var totalFeatureDays:int = 0;
         var daysElapsed:int = 0;
         var state:int = 0;
         if(Boolean(this.zing_mc) && Boolean(this.zang_mc))
         {
            if(forFtue)
            {
               state = NPC_NEUTRAL;
            }
            else
            {
               totalFeatureDays = BringBackWinterManager.getInstance(m_featureName).getFeatureDurationDays();
               daysElapsed = BringBackWinterManager.getInstance(m_featureName).getElapsedDays();
               if(daysElapsed < Math.round(totalFeatureDays / 3))
               {
                  state = NPC_SAD;
               }
               else if(daysElapsed < Math.round(totalFeatureDays / 3) * 2)
               {
                  state = NPC_NEUTRAL;
               }
               else
               {
                  state = NPC_ECSTATIC;
               }
            }
            this.zing_mc.gotoAndStop(state);
            this.zang_mc.gotoAndStop(state);
            frame_mc.gotoAndStop(state);
            this.showZang(true);
            this.showZing(true);
         }
      }
      
      private function showZing(visible:Boolean = false) : void
      {
         if(this.zing_mc)
         {
            this.zing_mc.visible = visible;
         }
      }
      
      private function showZang(visible:Boolean = false) : void
      {
         if(this.zang_mc)
         {
            this.zang_mc.visible = visible;
         }
      }
      
      private function collectDailySnowFlake(event:Event) : void
      {
         BringBackWinterManager.getInstance(m_featureName).collectDailySnowFlake();
         this.onCloseDailyCollectWindow(null);
      }
      
      private function onCloseDailyCollectWindow(event:Event) : void
      {
         this.dailylogin_frame.visible = false;
         update();
      }
      
      override protected function updateSfCollection() : void
      {
         var i:int = 0;
         var collectionSlot:BringBackWinterSFCollectionSlot = null;
         if(m_collectionSlots)
         {
            for(i = 0; i < m_collectionSlots.length; i++)
            {
               if(m_collectionSlots[i])
               {
                  collectionSlot = m_collectionSlots[i] as BringBackWinterSFCollectionSlot;
                  collectionSlot.refreshCollectionCount();
               }
            }
         }
      }
      
      override protected function onFTUEOKBtnClick(event:Event) : void
      {
         super.onFTUEOKBtnClick(event);
         if(m_tutorialScene > this.getNumTutorialScenes())
         {
            this.setNPCStates();
         }
      }
      
      override protected function getNumTutorialScenes() : int
      {
         return NUM_TUTORIAL_SCENES;
      }
   }
}

