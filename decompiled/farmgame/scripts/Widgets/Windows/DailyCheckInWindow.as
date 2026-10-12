package Widgets.Windows
{
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.TutorialUI;
   import Engine.Managers.LoadingManager;
   import Managers.DailyCheckInManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Frames.DailyCheckInGoodieFrame;
   import Widgets.Frames.DailyCheckInLastChanceFrame;
   import Widgets.Frames.DailyCheckInRewardFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.LoaderInfo;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class DailyCheckInWindow extends FarmWindow
   {
      
      public static const GOODIE_SMALL:String = "goodie_small";
      
      public static const GOODIE_MEDIUM:String = "goodie_medium";
      
      public static const GOODIE_LARGE:String = "goodie_large";
      
      private static const TUTORIAL_PREFIX_URL:String = "assets/daily_checkin/DailyCheckIn2014";
      
      private var m_goodiesFrame:DailyCheckInGoodieFrame;
      
      private var m_rewardsFrame:DailyCheckInRewardFrame;
      
      private var m_lastChanceFrame:DailyCheckInLastChanceFrame;
      
      private var m_bonusMc:FarmIcon;
      
      private var m_bonusTf:FarmTextField;
      
      private var m_candyCountMc:ZwWidget;
      
      private var m_countMc:MovieClip;
      
      private var m_candyCountTf:FarmTextField;
      
      private var m_titleTf:FarmTextField;
      
      private var m_subTitleTf:FarmTextField;
      
      private var m_timerTf:FarmTextField;
      
      private var m_subTitle2Tf:FarmTextField;
      
      private var m_whatIsThisBt:FarmAnimatedButton;
      
      private var m_lastDayTf:FarmTextField;
      
      private var m_goodieMc:MovieClip;
      
      private var m_goodieUrl:String;
      
      private var m_showLastChance:Boolean;
      
      private var m_timer:Timer;
      
      public function DailyCheckInWindow(dialogUrl:String, goodieUrl:String, showLastChance:Boolean = false)
      {
         super(dialogUrl);
         this.m_goodieUrl = goodieUrl;
         this.m_showLastChance = showLastChance;
      }
      
      override protected function postLoadComplete() : void
      {
         var goodieName:String = null;
         var bonusItem:FarmItem = null;
         var rewards:Array = null;
         var lastChanceGoodieUrl:String = null;
         var subtitleText:String = null;
         super.postLoadComplete();
         if(m_window)
         {
            goodieName = DailyCheckInManager.getInstance().getGoodieName();
            bonusItem = Global.farmGameSettingsManager.getFarmItemByName(DailyCheckInManager.getInstance().bonusItemName);
            if(m_window.hasOwnProperty("bonus_mc"))
            {
               this.m_bonusMc = addWidget(new FarmIcon(m_window["bonus_mc"],bonusItem.getImageByName("feed")),true) as FarmIcon;
            }
            if(m_window.hasOwnProperty("bonus_tf"))
            {
               this.m_bonusTf = addWidget(new FarmTextField(m_window["bonus_tf"],ZLocUtils.t("Dialogs","DailyCheckIn_BonusText")),true) as FarmTextField;
            }
            if(m_window.hasOwnProperty("count_mc"))
            {
               this.m_countMc = m_window["count_mc"] as MovieClip;
               this.m_countMc.visible = true;
               if(m_window["count_mc"].hasOwnProperty("candy_count_mc"))
               {
                  this.m_candyCountMc = addWidget(new ZwWidget(m_window["count_mc"]["candy_count_mc"]),true) as ZwWidget;
               }
               if(m_window["count_mc"].hasOwnProperty("count_tf"))
               {
                  this.m_candyCountTf = addWidget(new FarmTextField(m_window["count_mc"]["count_tf"]),true) as FarmTextField;
               }
            }
            if(m_window.hasOwnProperty("collectcandy_mc"))
            {
               this.m_goodiesFrame = addWidget(new DailyCheckInGoodieFrame(m_window["collectcandy_mc"],this.m_goodieUrl,this),true) as DailyCheckInGoodieFrame;
            }
            if(m_window.hasOwnProperty("claimreward_mc"))
            {
               rewards = DailyCheckInManager.getInstance().getRewards();
               this.m_rewardsFrame = addWidget(new DailyCheckInRewardFrame(m_window["claimreward_mc"],this.m_goodieUrl,rewards,this),true) as DailyCheckInRewardFrame;
            }
            if(m_window.hasOwnProperty("lastchance_mc"))
            {
               lastChanceGoodieUrl = DailyCheckInManager.getInstance().getLastChanceGoodieUrl();
               this.m_lastChanceFrame = addWidget(new DailyCheckInLastChanceFrame(m_window["lastchance_mc"],lastChanceGoodieUrl,this),this.m_showLastChance) as DailyCheckInLastChanceFrame;
            }
            if(m_window.hasOwnProperty("title_tf"))
            {
               this.m_titleTf = addWidget(new FarmTextField(m_window["title_tf"],ZLocUtils.t("Dialogs","dailyCheckIn_Title")),true) as FarmTextField;
            }
            if(m_window.hasOwnProperty("subtitle_tf"))
            {
               subtitleText = ZLocUtils.t("Dialogs","DailyCheckIn_SubTitle",{"goodieName":goodieName});
               if(DailyCheckInManager.getInstance().isV10AnniversaryWeek())
               {
                  subtitleText = "Barbra is celebrating Farmville’s 10th Birthday! Collect a Barbra Cupcake everyday, and treat her with them. She\'ll give you something sweet in return!";
               }
               this.m_subTitleTf = addWidget(new FarmTextField(m_window["subtitle_tf"],subtitleText),true) as FarmTextField;
            }
            if(m_window.hasOwnProperty("subtitle2_tf"))
            {
               this.m_subTitle2Tf = addWidget(new FarmTextField(m_window["subtitle2_tf"]),true) as FarmTextField;
               this.m_subTitle2Tf.text = ZLocUtils.t("Dialogs","DailyCheckIn_BonusSubText",{
                  "goodieName":goodieName,
                  "bonusItemName":bonusItem.friendlyTitle
               });
            }
            if(m_window.hasOwnProperty("timeleft_tf"))
            {
               this.m_timerTf = addWidget(new FarmTextField(m_window["timeleft_tf"]),true) as FarmTextField;
            }
            if(m_window.hasOwnProperty("whatisthis_mc"))
            {
               this.m_whatIsThisBt = addWidget(new FarmAnimatedButton(m_window["whatisthis_mc"],this.onWhatIsThisClick),true) as FarmAnimatedButton;
            }
            if(m_window.hasOwnProperty("sevenday_tf"))
            {
               this.m_lastDayTf = addWidget(new FarmTextField(m_window["sevenday_tf"]),false) as FarmTextField;
            }
            LoadingManager.load(Global.getAssetURL(this.m_goodieUrl),this.onGoodieImgLoaded);
            this.initTimer();
            this.refreshUi();
         }
         FarmStatsManager.count("daily_check_in","open","","","",Global.worldManager.currentWorldType);
      }
      
      private function killTimer() : void
      {
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.refreshUi);
            this.m_timer = null;
         }
      }
      
      private function initTimer() : void
      {
         if(!this.m_timer)
         {
            this.m_timer = new Timer(FarmGameUtil.NUM_MSECS_IN_SECOND);
            this.m_timer.addEventListener(TimerEvent.TIMER,this.refreshUi);
            this.m_timer.start();
         }
      }
      
      private function onGoodieImgLoaded(e:Event) : void
      {
         var loader:LoaderInfo = e.currentTarget as LoaderInfo;
         this.m_goodieMc = loader.content as MovieClip;
         if(this.m_goodieMc)
         {
            (this.m_goodieMc[GOODIE_MEDIUM] as DisplayObject).visible = true;
            (this.m_goodieMc[GOODIE_LARGE] as DisplayObject).visible = false;
            (this.m_goodieMc[GOODIE_SMALL] as DisplayObject).visible = false;
            if(Boolean(this.m_candyCountMc) && Boolean(this.m_candyCountMc.element))
            {
               (this.m_candyCountMc.element as DisplayObjectContainer).addChild(this.m_goodieMc);
            }
         }
      }
      
      public function refreshUi(e:TimerEvent = null) : void
      {
         var currentDay:int = 0;
         var timeRemaining:int = 0;
         var timeLeftArr:Array = null;
         if(e)
         {
            this.initTimer();
         }
         if(!this.m_showLastChance && DailyCheckInManager.getInstance().hasWeekChanged())
         {
            close();
            DailyCheckInManager.getInstance().reinitialize();
         }
         else
         {
            this.m_goodiesFrame.refresh();
            this.m_rewardsFrame.refresh();
            this.m_candyCountTf.text = "x" + DailyCheckInManager.getInstance().currentGoodieCount.toString();
            currentDay = DailyCheckInManager.getInstance().getCurrentDayNumber();
            timeRemaining = 604800 - DailyCheckInManager.getInstance().getTimeElapsedSinceThisWeek();
            timeLeftArr = FarmGameUtil.parseTimeLeft(timeRemaining);
            if(timeLeftArr[0])
            {
               this.m_timerTf.text = ZLocUtils.t("Dialogs","DailyCheckIn_TimeLeftDays",{"time":timeLeftArr[0]});
            }
            else if(timeLeftArr[1])
            {
               this.m_timerTf.text = ZLocUtils.t("Dialogs","DailyCheckIn_TimeLeftHours",{"time":timeLeftArr[1]});
               this.m_lastDayTf.text = "Come back in " + timeLeftArr[1] + " hours for new delights";
            }
            else
            {
               this.m_timerTf.text = timeLeftArr[2] + " minutes";
               this.m_lastDayTf.text = "Come back in " + timeLeftArr[2] + " minutes for new delights";
            }
            this.m_lastDayTf.visible = currentDay == DailyCheckInManager.NUM_DAYS && !DailyCheckInManager.getInstance().canCollectGoodie();
            this.m_subTitleTf.visible = !this.m_lastDayTf.visible;
         }
      }
      
      private function onWhatIsThisClick(ev:Event = null) : void
      {
         var featureOptionsKey:String = DailyCheckInManager.FEATURE_OPTIONS_KEY;
         TutorialUI.displayTutorialWindowForItem(featureOptionsKey,"Dialogs:" + featureOptionsKey + "_Title",TUTORIAL_PREFIX_URL);
      }
      
      override protected function release() : void
      {
         this.m_goodiesFrame = null;
         this.m_rewardsFrame = null;
         this.m_lastChanceFrame = null;
         this.killTimer();
         super.release();
      }
   }
}

