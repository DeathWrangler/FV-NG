package Widgets.Windows
{
   import Classes.Constants.Experiments;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class WorldProgressWindow extends FarmWindow
   {
      
      private static const INST_NAME_TITLE:String = "title_tf";
      
      private static const INST_NAME_HEADER_LEFT:String = "subheader1_tf";
      
      private static const INST_NAME_HEADER_RIGHT:String = "subheader2_tf";
      
      private static const INST_NAME_MORE_INFO:String = "moreInfo_bt";
      
      private static const INST_NAME_CHECKBOX:String = "checkbox_mc";
      
      private static const INST_NAME_CHECKMARK:String = "check_mc";
      
      private static const INST_NAME_CHECKBOX_TEXT:String = "checkbox_tf";
      
      private static const INST_NAME_PROGRESS:String = "progress_mc";
      
      private static const INST_NAME_TUTORIAL:String = "tutorial_mc";
      
      private static const FRAME_NUM_TUTORIAL_START:uint = 2;
      
      private static const FRAMES_PER_MILESTONE:uint = 10;
      
      private static const LOC_PKG_DIALOG:String = "Dialogs";
      
      private static const LOC_KEY_TITLE:String = "_WorldProgressDialog_Title";
      
      private static const LOC_KEY_HEADER_LEFT:String = "_WorldProgressDialog_HeaderLeft";
      
      private static const LOC_KEY_AUTOSHOW_CB_TEXT:String = "_WorldProgressDialog_AutoShowCBText";
      
      private static const LOC_KEY_HEADER_RIGHT:String = "_WorldProgressDialog_HeaderRight";
      
      private static const TUTORIAL_SEEN_FLAG:String = "_world_progress_dialog_tutorial";
      
      private static const SEEN_ONCE_SEEN_FLAG:String = "_world_progress_dialog_seen_once";
      
      private static const SEEN_SKIP_FIRST_VIEW_FLAG:String = "_world_progress_dialog_skip_1st_view";
      
      private static const WORLD_PROGRESS_NO_AUTOSHOW_FLAG:String = "world_progress_no_autoshow";
      
      private var m_moreInfoButton:FarmAnimatedButton = null;
      
      private var m_autoShowCheckboxButton:FarmAnimatedButton = null;
      
      private var m_locPrefix:String = "";
      
      private var m_tutorial:MovieClip = null;
      
      private var m_tutorialAccept:FarmAnimatedButton = null;
      
      private var m_progress:MovieClip = null;
      
      private var m_autoShowOrig:Boolean = true;
      
      private var m_autoShowCur:Boolean = true;
      
      private var m_dates:Array;
      
      public function WorldProgressWindow(configXml:XML)
      {
         var dateXml:XML = null;
         this.m_dates = new Array();
         super(configXml.assetUrl[0].toString());
         if(configXml.hasOwnProperty("locPrefix"))
         {
            this.m_locPrefix = configXml.locPrefix[0].toString();
         }
         for each(dateXml in configXml.milestoneDates.date)
         {
            this.m_dates.push(new DateData(dateXml));
         }
      }
      
      public static function userHasAutoShowCheckboxOn() : Boolean
      {
         return !Boolean(Global.player.getItemFlag(WORLD_PROGRESS_NO_AUTOSHOW_FLAG) == "true");
      }
      
      public static function userHasNotSeenThisFeatureYet(worldPrefix:String) : Boolean
      {
         return !Global.player.getSeenFlag(worldPrefix + SEEN_ONCE_SEEN_FLAG);
      }
      
      public static function userHasSkippedViewOnFirstWorldLoad(worldPrefix:String) : Boolean
      {
         return Global.player.getSeenFlag(worldPrefix + SEEN_SKIP_FIRST_VIEW_FLAG);
      }
      
      public static function setUserHasSkippedViewOnFirstWorldLoad(worldPrefix:String) : void
      {
         if(!Global.player.getSeenFlag(worldPrefix + SEEN_SKIP_FIRST_VIEW_FLAG))
         {
            Global.player.setSeenFlag(worldPrefix + SEEN_SKIP_FIRST_VIEW_FLAG);
         }
      }
      
      public static function shouldShowOnWorldLoad(worldPrefix:String) : Boolean
      {
         var userHasAutoShowCheckboxOn:Boolean = WorldProgressWindow.userHasAutoShowCheckboxOn();
         var userHasNotSeenThisFeatureYet:Boolean = WorldProgressWindow.userHasNotSeenThisFeatureYet(worldPrefix);
         return userHasAutoShowCheckboxOn || userHasNotSeenThisFeatureYet;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty(INST_NAME_TITLE) && m_window[INST_NAME_TITLE] != null)
         {
            addWidget(new ZwTextField(m_window[INST_NAME_TITLE],ZLocUtils.t(LOC_PKG_DIALOG,this.m_locPrefix + LOC_KEY_TITLE)));
         }
         if(m_window.hasOwnProperty(INST_NAME_HEADER_LEFT) && m_window[INST_NAME_HEADER_LEFT] != null)
         {
            addWidget(new ZwTextField(m_window[INST_NAME_HEADER_LEFT],ZLocUtils.t(LOC_PKG_DIALOG,this.m_locPrefix + LOC_KEY_HEADER_LEFT)));
         }
         if(m_window.hasOwnProperty(INST_NAME_HEADER_RIGHT) && m_window[INST_NAME_HEADER_RIGHT] != null)
         {
            addWidget(new ZwTextField(m_window[INST_NAME_HEADER_RIGHT],ZLocUtils.t(LOC_PKG_DIALOG,this.m_locPrefix + LOC_KEY_HEADER_RIGHT)));
         }
         if(m_window.hasOwnProperty(INST_NAME_MORE_INFO) && m_window[INST_NAME_MORE_INFO] != null)
         {
            this.m_moreInfoButton = new FarmAnimatedButton(m_window[INST_NAME_MORE_INFO],this.onMoreInfoClick);
            addWidget(this.m_moreInfoButton);
         }
         if(m_window.hasOwnProperty(INST_NAME_TUTORIAL) && m_window[INST_NAME_TUTORIAL] != null)
         {
            this.m_tutorial = m_window[INST_NAME_TUTORIAL] as MovieClip;
            this.m_tutorial.visible = false;
            if(!Global.player.getSeenFlag(this.m_locPrefix + TUTORIAL_SEEN_FLAG))
            {
               this.onMoreInfoClick(null);
            }
         }
         if(m_window.hasOwnProperty(INST_NAME_PROGRESS) && m_window[INST_NAME_PROGRESS] != null)
         {
            this.m_progress = m_window[INST_NAME_PROGRESS] as MovieClip;
            this.updateProgress();
         }
         this.m_autoShowCur = this.m_autoShowOrig = userHasAutoShowCheckboxOn();
         if(m_window.hasOwnProperty(INST_NAME_CHECKBOX) && m_window[INST_NAME_CHECKBOX] != null)
         {
            this.m_autoShowCheckboxButton = new FarmAnimatedButton(m_window[INST_NAME_CHECKBOX],this.onCheckboxClickAutoShow);
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_WORLDPROGRESSWINDOW_HIDE_CHECKBOX) == 1)
            {
               m_window[INST_NAME_CHECKBOX].visible = false;
            }
            else
            {
               addWidget(this.m_autoShowCheckboxButton);
               m_window[INST_NAME_CHECKBOX][INST_NAME_CHECKMARK].visible = this.m_autoShowCur;
               addWidget(new ZwTextField(m_window[INST_NAME_CHECKBOX][INST_NAME_CHECKBOX_TEXT],ZLocUtils.t(LOC_PKG_DIALOG,this.m_locPrefix + LOC_KEY_AUTOSHOW_CB_TEXT)));
            }
         }
         if(!Global.player.getSeenFlag(this.m_locPrefix + SEEN_ONCE_SEEN_FLAG))
         {
            Global.player.setSeenFlag(this.m_locPrefix + SEEN_ONCE_SEEN_FLAG);
         }
         FarmStatsManager.sample(100,"exp_map_dialog",Global.worldManager.currentWorldType,"view");
      }
      
      private function updateProgress() : void
      {
         var date:DateData = null;
         var percent:Number = NaN;
         this.m_progress.visible = true;
         var lastValidDateIndex:int = -1;
         var totalDates:int = int(this.m_dates.length);
         for(var curDate:int = 0; curDate < totalDates; curDate++)
         {
            date = this.m_dates[curDate];
            if(FarmGameUtil.synchronizedDateToNumber(date.m_dateString) > GlobalEngine.serverTime)
            {
               break;
            }
            lastValidDateIndex = curDate;
         }
         if(lastValidDateIndex < 0)
         {
            this.m_progress.gotoAndStop(0);
         }
         else if(lastValidDateIndex >= totalDates - 1)
         {
            this.m_progress.gotoAndStop(totalDates * FRAMES_PER_MILESTONE);
         }
         else
         {
            percent = GlobalEngine.serverTime - FarmGameUtil.synchronizedDateToNumber(this.m_dates[lastValidDateIndex].m_dateString);
            percent /= FarmGameUtil.synchronizedDateToNumber(this.m_dates[lastValidDateIndex + 1].m_dateString) - FarmGameUtil.synchronizedDateToNumber(this.m_dates[lastValidDateIndex].m_dateString);
            this.m_progress.gotoAndStop(lastValidDateIndex * FRAMES_PER_MILESTONE + int(percent * FRAMES_PER_MILESTONE));
         }
      }
      
      private function onCheckboxClickAutoShow(event:MouseEvent) : void
      {
         this.m_autoShowCur = !this.m_autoShowCur;
         m_window[INST_NAME_CHECKBOX][INST_NAME_CHECKMARK].visible = this.m_autoShowCur;
      }
      
      private function onMoreInfoClick(event:MouseEvent) : void
      {
         if(this.m_tutorial)
         {
            this.m_tutorial.visible = true;
            this.m_tutorial.gotoAndPlay(FRAME_NUM_TUTORIAL_START);
            if(this.m_tutorialAccept == null)
            {
               this.m_tutorialAccept = new FarmAnimatedButton(this.m_tutorial.accept_bt,this.onAcceptTutorial) as FarmAnimatedButton;
            }
         }
         if(!Global.player.getSeenFlag(this.m_locPrefix + TUTORIAL_SEEN_FLAG))
         {
            Global.player.setSeenFlag(this.m_locPrefix + TUTORIAL_SEEN_FLAG);
         }
      }
      
      public function onAcceptTutorial(event:MouseEvent) : void
      {
         this.m_tutorial.visible = false;
      }
      
      override protected function onClose(event:Event) : void
      {
         super.onClose(event);
         if(this.m_autoShowCur != this.m_autoShowOrig)
         {
            Global.player.setItemFlag(WORLD_PROGRESS_NO_AUTOSHOW_FLAG,String(!this.m_autoShowCur));
         }
         FarmStatsManager.sample(100,"exp_map_dialog",Global.worldManager.currentWorldType,"close","checkbox_show_" + (this.m_autoShowCur ? "startup" : "no"));
      }
   }
}

class DateData
{
   
   public var m_type:String = "";
   
   public var m_dateString:String = null;
   
   public function DateData(configXml:XML)
   {
      super();
      if(configXml.hasOwnProperty("@type") && configXml["@type"] != "")
      {
         this.m_type = configXml["@type"];
      }
      this.m_dateString = configXml.toString();
   }
}
