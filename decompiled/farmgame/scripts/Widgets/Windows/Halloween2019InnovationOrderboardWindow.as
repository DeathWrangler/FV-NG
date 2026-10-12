package Widgets.Windows
{
   import Classes.ZItem.FarmItem;
   import Display.HUD.HUD;
   import Managers.FarmStatsManager;
   import Managers.OrderBoard.Halloween2019InnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import com.greensock.TweenMax;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class Halloween2019InnovationOrderboardWindow extends GenericOrderBoardWindow
   {
      
      private static const TITLE_TF:String = "title_tf";
      
      private static const ALL_METER_MC:String = "all_meter_mc";
      
      private static const METER_MC:String = "meter_mc";
      
      private static const BAR_FILL_MC:String = "bar_fill_mc";
      
      private static const POINTS_MC:String = "points_mc";
      
      private static const WORLD1_REWARD_MC:String = "world1reward_mc";
      
      private static const WORLD2_REWARD_MC:String = "world2reward_mc";
      
      private static const WORLD3_REWARD_MC:String = "world3reward_mc";
      
      private static const TOTAL_COUPONS_MC:String = "total_coupons_mc";
      
      private static const COUPONS_COUNTER_TF:String = "coupons_counter_tf";
      
      private static const TOTAL_ORDERS_MC:String = "total_orders_mc";
      
      private static const ORDERS_COUNTER_TF:String = "orders_counter_tf";
      
      private static const POINTS_TF:String = "points_tf";
      
      private static const DAY_TIMER_TF:String = "day_timer_tf";
      
      private static const HOWDOESTHISWORK_MC:String = "howDoesThisWork_mc";
      
      private static const TEXT_WHATISTHIS:String = "HowDoesThisWork";
      
      private var all_meter_mc:MovieClip;
      
      private var meter_mc:MovieClip;
      
      private var bar_fill_mc:MovieClip;
      
      private var points_mc:MovieClip;
      
      private var world1reward_mc:MovieClip;
      
      private var world2reward_mc:MovieClip;
      
      private var world3reward_mc:MovieClip;
      
      private var total_coupons_mc:MovieClip;
      
      private var total_orders_mc:MovieClip;
      
      private var coupons_count_tf:ZwTextField;
      
      private var orders_count_tf:ZwTextField;
      
      private var m_timer:Timer;
      
      private var points_tf:ZwTextField;
      
      private var m0pointsTf:ZwTextField;
      
      private var m1pointsTf:ZwTextField;
      
      private var m2pointsTf:ZwTextField;
      
      public var m_dayTimerTf:ZwTextField;
      
      private var m_candyNormalOuterMc:Array = [];
      
      private var m_normalCandies:Array = [];
      
      private var m_allCandyNormalMc:MovieClip;
      
      private var m_reward1:FarmIcon;
      
      private var m_reward2:FarmIcon;
      
      private var m_reward3:FarmIcon;
      
      private var m_tutorialMc:MovieClip;
      
      private var m_arrowMc:MovieClip;
      
      private var m_npcCircleMc:MovieClip;
      
      private var m_whatIsThisBt:FarmAnimatedTextButton;
      
      private var m_minitutorial_frame:ZwFrame;
      
      private var m_mini_tutorial_mc:MovieClip;
      
      private const WHAT_IS_THIS_MC:String = "whatisthis_mc";
      
      private var m_checkmarkOneMc:MovieClip;
      
      private var m_checkmarkTwoMc:MovieClip;
      
      private var m_checkmarkThreeMc:MovieClip;
      
      private var m_okay1Bt:FarmAnimatedTextButton;
      
      private var m_okay2Bt:FarmAnimatedTextButton;
      
      private var m_tutorialButtons:Array = [];
      
      private var m_hoverEarnMc:MovieClip;
      
      private var m_hoverEarnTf:ZwTextField;
      
      private var m_hoverLimitMc:MovieClip;
      
      private var m_hoverLimitTf:ZwTextField;
      
      public var m_npcCalloutMc:MovieClip;
      
      public var m_npcTitleTf:ZwTextField;
      
      public var m_npcTextTf:ZwTextField;
      
      public var m_npcClodeBt:FarmAnimatedTextButton;
      
      public var m_hitareaEarnMc:MovieClip;
      
      public var m_hitareaLimitMc:MovieClip;
      
      public var totalScene:int = 2;
      
      private var NUM_TUTORIAL_SCENES:int = 3;
      
      private var TUTORIAL_BUTTON_TEXT_ARRAY:Array = ["Next","Next","Let’s go!"];
      
      private const HALLOWEEN2019_ODERBORDWINDOW_FTUE_FLAG:String = "halloween2019_oderbordwindow_ftue_flag";
      
      public function Halloween2019InnovationOrderboardWindow(windowURL:String)
      {
         super(featureManager.featureName,windowURL,featureManager,this.NUM_TUTORIAL_SCENES);
      }
      
      private static function get featureManager() : Halloween2019InnovationManager
      {
         return Halloween2019InnovationManager.getInstance();
      }
      
      override protected function postLoadComplete() : void
      {
         var reward1:FarmItem = null;
         var reward2:FarmItem = null;
         var reward3:FarmItem = null;
         var basicCandyNameURL:Object = null;
         var basicCandyNames:Array = null;
         var i:int = 0;
         var buttonName:String = null;
         super.postLoadComplete();
         if(m_window.hasOwnProperty(TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[TITLE_TF],"Get candies!"));
         }
         if(m_window.hasOwnProperty("subtext_tf"))
         {
            addWidget(new ZwTextField(m_window["subtext_tf"],"Complete order board tasks to earn candies!"));
         }
         if(m_window.hasOwnProperty("progress_bar_tf"))
         {
            addWidget(new ZwTextField(m_window["progress_bar_tf"],"Earn these rewards by completing daily orders!"));
         }
         if(m_window.hasOwnProperty(HOWDOESTHISWORK_MC))
         {
            addWidget(this.m_whatIsThisBt = new FarmAnimatedTextButton(m_window[HOWDOESTHISWORK_MC],"",this.onHowDoesThisWorkClick));
            this.m_whatIsThisBt.visible = true;
         }
         if(m_window.hasOwnProperty("npc_callout_mc"))
         {
            this.m_npcCalloutMc = m_window["npc_callout_mc"] as MovieClip;
            if(this.m_npcCalloutMc.hasOwnProperty("callout_title_tf"))
            {
               addWidget(this.m_npcTitleTf = new ZwTextField(this.m_npcCalloutMc["callout_title_tf"]));
               this.m_npcTitleTf.visible = true;
            }
            if(this.m_npcCalloutMc.hasOwnProperty("callout_text_tf"))
            {
               addWidget(this.m_npcTextTf = new ZwTextField(this.m_npcCalloutMc["callout_text_tf"]));
               this.m_npcTextTf.visible = true;
            }
            if(this.m_npcCalloutMc.hasOwnProperty("okay_bt"))
            {
               addWidget(this.m_npcClodeBt = new FarmAnimatedTextButton(this.m_npcCalloutMc["okay_bt"],"Ok",this.onNpcClose));
               this.m_npcClodeBt.visible = true;
            }
            this.m_npcCalloutMc.visible = false;
         }
         if(m_window.hasOwnProperty("hover_earn_mc"))
         {
            this.m_hoverEarnMc = m_window["hover_earn_mc"] as MovieClip;
            if(this.m_hoverEarnMc.hasOwnProperty("hover_earn_tf"))
            {
               addWidget(this.m_hoverEarnTf = new ZwTextField(this.m_hoverEarnMc["hover_earn_tf"],"Earn more candies in a day by doing harder tasks"));
               this.m_hoverEarnTf.visible = true;
            }
            this.m_hoverEarnMc.visible = false;
         }
         if(m_window.hasOwnProperty("hitarea_earn_mc"))
         {
            this.m_hitareaEarnMc = m_window["hitarea_earn_mc"] as MovieClip;
            this.m_hitareaEarnMc.visible = true;
            this.m_hitareaEarnMc.addEventListener(MouseEvent.MOUSE_OVER,this.onEarnMouseOver);
            this.m_hitareaEarnMc.addEventListener(MouseEvent.MOUSE_OUT,this.onEarnMouseOut);
         }
         if(m_window.hasOwnProperty("hover_limit_mc"))
         {
            this.m_hoverLimitMc = m_window["hover_limit_mc"] as MovieClip;
            if(this.m_hoverLimitMc.hasOwnProperty("hover_limit_tf"))
            {
               addWidget(this.m_hoverLimitTf = new ZwTextField(this.m_hoverLimitMc["hover_limit_tf"],"Do up to " + featureManager.getMaxDailyOderboardCount() + " task a day"));
               this.m_hoverLimitTf.visible = true;
            }
            this.m_hoverLimitMc.visible = false;
         }
         if(m_window.hasOwnProperty("hitarea_limit_mc"))
         {
            this.m_hitareaLimitMc = m_window["hitarea_limit_mc"] as MovieClip;
            this.m_hitareaLimitMc.visible = true;
            this.m_hitareaLimitMc.addEventListener(MouseEvent.MOUSE_OVER,this.onLimitMouseOver);
            this.m_hitareaLimitMc.addEventListener(MouseEvent.MOUSE_OUT,this.onLimitMouseOut);
         }
         if(m_window.hasOwnProperty(ALL_METER_MC))
         {
            this.all_meter_mc = m_window.all_meter_mc as MovieClip;
            this.all_meter_mc.visible = true;
            if(m_window[ALL_METER_MC][METER_MC])
            {
               this.meter_mc = m_window[ALL_METER_MC].meter_mc as MovieClip;
               this.meter_mc.visible = true;
               if(m_window[ALL_METER_MC][METER_MC][BAR_FILL_MC])
               {
                  this.bar_fill_mc = m_window[ALL_METER_MC][METER_MC].bar_fill_mc as MovieClip;
                  this.bar_fill_mc.visible = true;
               }
               if(m_window[ALL_METER_MC][POINTS_MC])
               {
                  this.points_mc = m_window[ALL_METER_MC].points_mc as MovieClip;
                  this.points_mc.visible = true;
                  if(m_window[ALL_METER_MC][POINTS_MC][POINTS_TF])
                  {
                     addWidget(this.points_tf = new ZwTextField(m_window[ALL_METER_MC][POINTS_MC][POINTS_TF],featureManager.getOrderboardProgress().toString()));
                  }
               }
               if(m_window[ALL_METER_MC][WORLD1_REWARD_MC])
               {
                  this.world1reward_mc = m_window[ALL_METER_MC].world1reward_mc as MovieClip;
                  this.world1reward_mc.visible = true;
                  if(this.world1reward_mc.hasOwnProperty("reward1_mc"))
                  {
                     reward1 = featureManager.getDailyRewardItem(0);
                     if(reward1)
                     {
                        addWidget(this.m_reward1 = new FarmIcon(this.world1reward_mc["reward1_mc"],reward1.iconUrl));
                        this.m_reward1.setIconSize(50,50);
                        this.m_reward1.attachTooltip(new FarmTextTooltip(reward1.friendlyTitle));
                        this.m_reward1.visible = true;
                     }
                     else
                     {
                        this.world1reward_mc.visible = false;
                     }
                  }
                  if(this.world1reward_mc.hasOwnProperty("checkmark_two_mc"))
                  {
                     this.m_checkmarkOneMc = this.world1reward_mc["checkmark_two_mc"] as MovieClip;
                     this.m_checkmarkOneMc.visible = featureManager.getFirstDailyMilestone() <= featureManager.getDailyOderboardTaskCount();
                  }
               }
               if(m_window[ALL_METER_MC][WORLD2_REWARD_MC])
               {
                  this.world2reward_mc = m_window[ALL_METER_MC].world2reward_mc as MovieClip;
                  this.world2reward_mc.visible = true;
                  if(this.world2reward_mc.hasOwnProperty("reward2_mc"))
                  {
                     reward2 = featureManager.getDailyRewardItem(1);
                     if(reward2)
                     {
                        addWidget(this.m_reward2 = new FarmIcon(this.world2reward_mc["reward2_mc"],reward2.iconUrl));
                        this.m_reward2.setIconSize(50,50);
                        this.m_reward2.attachTooltip(new FarmTextTooltip(reward2.friendlyTitle));
                        this.m_reward2.visible = true;
                     }
                  }
                  if(this.world2reward_mc.hasOwnProperty("checkmark_two_mc"))
                  {
                     this.m_checkmarkTwoMc = this.world2reward_mc["checkmark_two_mc"] as MovieClip;
                     this.m_checkmarkTwoMc.visible = featureManager.getSecondDailyMilestone() <= featureManager.getDailyOderboardTaskCount();
                  }
               }
               if(m_window[ALL_METER_MC][WORLD3_REWARD_MC])
               {
                  this.world3reward_mc = m_window[ALL_METER_MC].world3reward_mc as MovieClip;
                  this.world3reward_mc.visible = true;
                  if(this.world3reward_mc.hasOwnProperty("reward3_mc"))
                  {
                     reward3 = featureManager.getDailyRewardItem(2);
                     if(reward3)
                     {
                        addWidget(this.m_reward3 = new FarmIcon(this.world3reward_mc["reward3_mc"],reward3.iconUrl));
                        this.m_reward3.setIconSize(50,50);
                        this.m_reward3.attachTooltip(new FarmTextTooltip(reward3.friendlyTitle));
                        this.m_reward3.visible = true;
                     }
                  }
                  if(this.world3reward_mc.hasOwnProperty("checkmark_two_mc"))
                  {
                     this.m_checkmarkThreeMc = this.world3reward_mc["checkmark_two_mc"] as MovieClip;
                     this.m_checkmarkThreeMc.visible = featureManager.getThirdDailyMilestone() <= featureManager.getDailyOderboardTaskCount();
                  }
               }
               if(m_window[ALL_METER_MC]["m0_points_tf"])
               {
                  addWidget(this.m0pointsTf = new ZwTextField(m_window[ALL_METER_MC]["m0_points_tf"],featureManager.getFirstDailyMilestone().toString()));
                  this.m0pointsTf.visible = true;
               }
               if(m_window[ALL_METER_MC]["m1_points_tf"])
               {
                  addWidget(this.m1pointsTf = new ZwTextField(m_window[ALL_METER_MC]["m1_points_tf"],featureManager.getSecondDailyMilestone().toString()));
                  this.m1pointsTf.visible = true;
               }
               if(m_window[ALL_METER_MC]["m0_points_tf"])
               {
                  addWidget(this.m2pointsTf = new ZwTextField(m_window[ALL_METER_MC]["m2_points_tf"],featureManager.getThirdDailyMilestone().toString()));
                  this.m2pointsTf.visible = true;
               }
            }
         }
         if(m_window.hasOwnProperty(TOTAL_COUPONS_MC))
         {
            this.total_coupons_mc = m_window.total_coupons_mc as MovieClip;
            this.total_coupons_mc.visible = true;
            if(m_window[TOTAL_COUPONS_MC][COUPONS_COUNTER_TF])
            {
               addWidget(this.coupons_count_tf = new ZwTextField(m_window[TOTAL_COUPONS_MC][COUPONS_COUNTER_TF],"x" + featureManager.getOrderboardProgress().toString()));
            }
            if(m_window[TOTAL_COUPONS_MC]["all_candy_normal_mc"])
            {
               this.m_allCandyNormalMc = m_window[TOTAL_COUPONS_MC]["all_candy_normal_mc"] as MovieClip;
               this.m_allCandyNormalMc.visible = true;
               basicCandyNameURL = featureManager.getBasicCandyNameURLS();
               basicCandyNames = featureManager.getBasicCandiesNames();
               for(i = 0; i < 3; i++)
               {
                  this.m_candyNormalOuterMc[i] = m_window[TOTAL_COUPONS_MC]["all_candy_normal_mc"]["candy_normal_" + i + "_mc"] as MovieClip;
                  this.m_candyNormalOuterMc[i].visible = true;
                  addWidget(this.m_normalCandies[i] = new FarmIcon(m_window[TOTAL_COUPONS_MC]["all_candy_normal_mc"]["candy_normal_" + i + "_mc"]["candy_icon_" + i + "_mc"],basicCandyNameURL[basicCandyNames[i]]));
                  this.m_normalCandies[i].setIconSize(50,50);
                  this.m_normalCandies[i].attachTooltip(new FarmTextTooltip(basicCandyNames[i]));
                  this.m_normalCandies[i].visible = true;
               }
            }
         }
         if(m_window.hasOwnProperty("mini_tutorial_mc"))
         {
            this.m_mini_tutorial_mc = m_window["mini_tutorial_mc"] as MovieClip;
            this.m_minitutorial_frame = addWidget(new ZwFrame(this.m_mini_tutorial_mc),false) as ZwFrame;
            if(this.m_mini_tutorial_mc.hasOwnProperty("okay_bt"))
            {
               this.m_minitutorial_frame.addWidget(new FarmAnimatedTextButton(this.m_mini_tutorial_mc["okay_bt"],"Great!",this.howDoesThisWorkFrameSwitch));
               this.m_mini_tutorial_mc["okay_bt"].visible = true;
            }
            this.m_mini_tutorial_mc.visible = false;
         }
         if(m_window.hasOwnProperty(TOTAL_ORDERS_MC))
         {
            this.total_orders_mc = m_window.total_orders_mc as MovieClip;
            this.total_orders_mc.visible = true;
            addWidget(this.orders_count_tf = new ZwTextField(m_window[TOTAL_ORDERS_MC][ORDERS_COUNTER_TF],featureManager.getDailyOderboardTaskCount().toString() + "/" + featureManager.getMaxDailyOderboardCount().toString()));
         }
         if(m_window.hasOwnProperty(DAY_TIMER_TF))
         {
            addWidget(this.m_dayTimerTf = new ZwTextField(m_window[DAY_TIMER_TF]));
            this.m_dayTimerTf.text = HUD.getformattedTimeLeft(featureManager.getActiveDayTimeRemain());
            this.m_dayTimerTf.visible = true;
         }
         if(m_window.hasOwnProperty("tutorial_mc"))
         {
            this.m_tutorialMc = m_window["tutorial_mc"] as MovieClip;
            if(this.m_tutorialMc)
            {
               for(i = 0; i < 3; i++)
               {
                  buttonName = "okay_" + (i + 1).toString() + "_bt";
                  if(this.m_tutorialMc.hasOwnProperty(buttonName))
                  {
                     this.m_tutorialButtons[i] = new FarmAnimatedTextButton(this.m_tutorialMc[buttonName]);
                     this.m_tutorialButtons[i].visible = false;
                  }
               }
            }
         }
         this.updateProgressBar();
         this.updatePointerPosition();
         this.totalScene = 0;
         if(!Global.player.getSeenFlag(this.HALLOWEEN2019_ODERBORDWINDOW_FTUE_FLAG))
         {
            Global.player.setSeenFlag(this.HALLOWEEN2019_ODERBORDWINDOW_FTUE_FLAG);
            this.showTutorial1();
         }
         if(featureManager.activeDay)
         {
            this.m_npcCalloutMc.visible = true;
            this.m_npcTitleTf.text = "Reminder";
            this.m_npcTextTf.text = "Remember to get more points, do tasks that give a lot of candies!";
            featureManager.activeDay = false;
         }
      }
      
      public function refreshTaskAndCandyCounts() : void
      {
         if(Boolean(this.coupons_count_tf) && Boolean(this.orders_count_tf))
         {
            this.coupons_count_tf.text = "x" + featureManager.getOrderboardProgress().toString();
            this.orders_count_tf.text = featureManager.getDailyOderboardTaskCount().toString() + "/" + featureManager.getMaxDailyOderboardCount().toString();
         }
      }
      
      public function refreshDailyTaskCount() : void
      {
         this.orders_count_tf.text = featureManager.getDailyOderboardTaskCount().toString() + "/" + featureManager.getMaxDailyOderboardCount().toString();
      }
      
      private function startTimer() : void
      {
         this.m_timer = new Timer(1000);
         this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer);
         this.m_timer.start();
      }
      
      private function onTimer(event:TimerEvent) : void
      {
         if(featureManager.hasActiveDayExpired())
         {
            this.close();
         }
         else
         {
            this.m_dayTimerTf.text = HUD.getformattedTimeLeft(featureManager.getActiveDayTimeRemain());
         }
      }
      
      override public function close() : void
      {
         this.stopTimer();
         if(featureManager.mainWindow)
         {
            featureManager.mainWindow.untintWindow();
            featureManager.mainWindow.enableInput = true;
            featureManager.refreshBasicCandyFrame();
            featureManager.refreshSpecialCandyFrame();
            featureManager.refreshKidFrame();
            featureManager.mainWindow.visible = true;
            if(featureManager.getDailyOderboardTaskCount() == featureManager.getMaxDailyOderboardCount())
            {
               featureManager.setOderbordNPC();
            }
         }
         super.close();
      }
      
      private function stopTimer() : void
      {
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this.m_timer = null;
         }
      }
      
      public function updateProgressBar() : void
      {
         var orderboardTaskCount:int = 0;
         var maxOrderboardTaskCount:int = 0;
         var barWidth:Number = NaN;
         if(Boolean(this.all_meter_mc) && Boolean(this.meter_mc) && Boolean(this.bar_fill_mc))
         {
            orderboardTaskCount = featureManager.getDailyOderboardTaskCount();
            maxOrderboardTaskCount = featureManager.getMaxDailyOderboardCount();
            if(orderboardTaskCount > maxOrderboardTaskCount)
            {
               orderboardTaskCount = maxOrderboardTaskCount;
            }
            barWidth = orderboardTaskCount * 600 / maxOrderboardTaskCount;
            if(orderboardTaskCount == 0)
            {
               (this.meter_mc.bar_fill_mc as MovieClip).width = barWidth;
            }
            else
            {
               TweenMax.to(this.meter_mc.bar_fill_mc,2,{"width":barWidth});
            }
         }
         if(this.points_tf)
         {
            this.points_tf.text = int(orderboardTaskCount).toString();
         }
      }
      
      public function updatePointerPosition() : void
      {
         var orderboardTaskCount:int = 0;
         var maxOrderboardTaskCount:int = 0;
         var barWidth:Number = NaN;
         if(this.points_mc)
         {
            orderboardTaskCount = featureManager.getDailyOderboardTaskCount();
            this.points_mc.points_tf.text = orderboardTaskCount;
            maxOrderboardTaskCount = featureManager.getMaxDailyOderboardCount();
            barWidth = orderboardTaskCount * 600 / maxOrderboardTaskCount;
            this.points_mc.x = barWidth;
         }
      }
      
      protected function onTutorialOkayButtonClick1(event:MouseEvent) : void
      {
         if(this.totalScene < totalScenes - 1)
         {
            ++this.totalScene;
            this.preSwitchChanges1(this.totalScene);
         }
         else
         {
            this.hideTutorial();
         }
      }
      
      override protected function hideTutorial() : void
      {
         if(this.m_tutorialMc)
         {
            this.m_tutorialMc.visible = false;
            m_tutorial.visible = false;
         }
      }
      
      protected function showTutorial1() : void
      {
         if(this.m_tutorialMc)
         {
            this.m_tutorialMc.visible = true;
            m_tutorial.visible = true;
         }
         this.preSwitchChanges1(0);
      }
      
      private function onHowDoesThisWorkClick(event:Event) : void
      {
         if(this.m_minitutorial_frame)
         {
            (this.m_minitutorial_frame.element as MovieClip).gotoAndStop(1);
            this.m_minitutorial_frame.visible = true;
            FarmStatsManager.count("HalloweenInnovation2019Orderboard","FTUE","START");
         }
      }
      
      public function onOkayButtonClick(e:Event) : void
      {
      }
      
      private function howDoesThisWorkFrameSwitch(event:Event = null) : void
      {
         var totalFrames:int = int(this.m_minitutorial_frame.element.totalFrames);
         var currentFrame:int = int(this.m_minitutorial_frame.element.currentFrame);
         if(currentFrame + 1 <= totalFrames)
         {
            (this.m_minitutorial_frame.element as MovieClip).gotoAndStop(currentFrame + 1);
         }
         else
         {
            this.m_minitutorial_frame.visible = false;
         }
      }
      
      protected function preSwitchChanges1(sceneNumber:int) : void
      {
         var button0:FarmAnimatedTextButton = null;
         var button1:FarmAnimatedTextButton = null;
         var button2:FarmAnimatedTextButton = null;
         switch(sceneNumber)
         {
            case 0:
               button0 = this.m_tutorialButtons[0] as FarmAnimatedTextButton;
               button0.text = "Nice";
               button0.visible = true;
               button0.enabled = true;
               button0.callback = this.onTutorialOkayButtonClick1;
               this.hideOtherTutorialButtonsExpect1(0);
               (m_tutorial.element as MovieClip).gotoAndStop(1);
               break;
            case 1:
               button1 = this.m_tutorialButtons[1] as FarmAnimatedTextButton;
               button1.text = "Ok";
               button1.visible = true;
               button1.callback = this.onTutorialOkayButtonClick1;
               this.hideOtherTutorialButtonsExpect1(1);
               (m_tutorial.element as MovieClip).gotoAndStop(2);
               break;
            case 2:
               button2 = this.m_tutorialButtons[2] as FarmAnimatedTextButton;
               button2.text = "Ok";
               button2.visible = true;
               button2.callback = this.onTutorialOkayButtonClick1;
               this.hideOtherTutorialButtonsExpect1(2);
               (m_tutorial.element as MovieClip).gotoAndStop(3);
         }
      }
      
      private function hideOtherTutorialButtonsExpect1(buttonNo:int) : void
      {
         for(var i:int = 0; i < this.m_tutorialButtons.length; i++)
         {
            if(i != buttonNo)
            {
               this.m_tutorialButtons[i].visible = false;
            }
         }
      }
      
      private function howDoesThisWorkClick(event:Event) : void
      {
         preSwitchChanges(this.totalScene);
      }
      
      public function setCheckmar(level:int) : void
      {
         if(level == 0)
         {
            this.m_checkmarkOneMc.visible = true;
         }
         else if(level == 1)
         {
            this.m_checkmarkTwoMc.visible = true;
         }
         else if(level == 2)
         {
            this.m_checkmarkThreeMc.visible = true;
         }
      }
      
      public function onEarnMouseOver(e:MouseEvent) : void
      {
         this.m_hoverEarnMc.visible = true;
      }
      
      public function onEarnMouseOut(e:MouseEvent) : void
      {
         this.m_hoverEarnMc.visible = false;
      }
      
      public function onLimitMouseOver(e:MouseEvent) : void
      {
         this.m_hoverLimitMc.visible = true;
      }
      
      public function onLimitMouseOut(e:MouseEvent) : void
      {
         this.m_hoverLimitMc.visible = false;
      }
      
      public function onNpcClose(event:Event) : void
      {
         this.m_npcCalloutMc.visible = false;
      }
   }
}

