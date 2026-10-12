package Widgets.Slots
{
   import Classes.util.FarmGameUtil;
   import Display.HUD.HUD;
   import Managers.OrderBoard.Halloween2019InnovationManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.Halloween2019InnovationMainWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class Halloween2019InnovationCandyKidSlot extends ZwSlotFrame
   {
      
      private static const CANDY_COUNT_TF:String = "candy_main_count_tf";
      
      private static const CANDY_IMAGE_MC:String = "candy_main_icon_mc";
      
      private static const KID_WAIT_SKIP_COST:int = 1;
      
      private static const WEEK_NO:int = 0;
      
      private var m_featureName:String;
      
      private var m_owner:Halloween2019InnovationMainWindow;
      
      private var m_candyCountTf:ZwTextField;
      
      private var m_candyIcon:FarmIcon;
      
      private var m_candy_all_req_mc:MovieClip;
      
      private var m_candy_normal_req_mc:MovieClip;
      
      private var m_get_candy_mc:MovieClip;
      
      private var m_get_candy_bt:FarmAnimatedTextButton;
      
      private var m_no_candy_tf:ZwTextField;
      
      private var m_no_candy_timer_tf:ZwTextField;
      
      private var m_give_candy_mc:MovieClip;
      
      private var m_give_all_bt:FarmAnimatedTextButton;
      
      private var m_give_normal_bt:FarmAnimatedTextButton;
      
      private var m_got_candy_mc:MovieClip;
      
      private var m_buy_bt:FarmAnimatedCashButton;
      
      private var m_got_candy_tf:ZwTextField;
      
      private var m_got_candy_timer_tf:ZwTextField;
      
      private var m_kid_emo_state_mc:FarmIcon;
      
      private var m_kid_img_mc:FarmIcon;
      
      private var m_noCandyKidTf:ZwTextField;
      
      private var m_kidNameTf:ZwTextField;
      
      private var m_dayDoneMc:MovieClip;
      
      private var candyMcArray:Array;
      
      private var normalCandyMcArray:Array;
      
      private var m_normalCandyImages:Array;
      
      private var m_candyImages:Array;
      
      private var m_candyOverlay:Array;
      
      private var m_normalCandyOverlay:Array;
      
      private var m_currentEmoState:FarmIcon;
      
      private var m_futureEmoState:FarmIcon;
      
      private var m_currentEmoStateSpec:FarmIcon;
      
      private var m_futureEmoStateSpec:FarmIcon;
      
      private var m_candyCount:Array;
      
      private var m_candyNames:Array;
      
      private var m_specialCandy:String;
      
      private var m_kidWaitTimer:Timer;
      
      private var m_kidReturnTimer:Timer;
      
      private var to_make_tf_above:ZwTextField;
      
      private var to_make_tf_below:ZwTextField;
      
      private var m_kidName:String;
      
      private var m_slotnumber:int = -1;
      
      private var m_normalCandyAvailable:Boolean = false;
      
      private var m_specialCandyAvailable:Boolean = false;
      
      private var m_toolTipText:String = "";
      
      public function Halloween2019InnovationCandyKidSlot(featureName:String, element:DisplayObject, window:Halloween2019InnovationMainWindow)
      {
         var ind:int = 0;
         this.candyMcArray = [];
         this.normalCandyMcArray = [];
         this.m_normalCandyImages = [];
         this.m_candyImages = [];
         this.m_candyOverlay = [];
         this.m_normalCandyOverlay = [];
         this.m_candyCount = [];
         this.m_candyNames = [];
         this.m_featureName = featureName;
         this.m_owner = window;
         super(element);
         if(m_element.hasOwnProperty("candy_all_req_mc"))
         {
            this.m_candy_all_req_mc = m_element["candy_all_req_mc"] as MovieClip;
            this.m_candy_all_req_mc.visible = false;
            for(ind = 0; ind < 3; ind++)
            {
               if(this.m_candy_all_req_mc.hasOwnProperty("candy_req_" + ind.toString() + "_mc"))
               {
                  this.candyMcArray[ind] = this.m_candy_all_req_mc["candy_req_" + ind.toString() + "_mc"] as MovieClip;
               }
               if(this.candyMcArray[ind].hasOwnProperty("candy_req_icon_1_mc"))
               {
                  this.m_candyImages[ind] = new FarmIcon(this.candyMcArray[ind]["candy_req_icon_1_mc"]);
                  this.m_candyImages[ind].visible = true;
               }
               if(this.candyMcArray[ind].hasOwnProperty("dark_overlay_mc"))
               {
                  this.m_candyOverlay[ind] = this.candyMcArray[ind]["dark_overlay_mc"] as MovieClip;
                  this.m_candyOverlay[ind].visible = false;
               }
            }
            if(this.m_candy_all_req_mc.hasOwnProperty("to_make_all_tf"))
            {
               addWidget(this.to_make_tf_below = new ZwTextField(this.m_candy_all_req_mc["to_make_all_tf"],""));
               this.to_make_tf_below.visible = true;
            }
            if(this.m_candy_all_req_mc.hasOwnProperty("current_emo_state_spec_mc"))
            {
               addWidget(this.m_currentEmoStateSpec = new FarmIcon(this.m_candy_all_req_mc["current_emo_state_spec_mc"]));
               this.m_currentEmoStateSpec.visible = true;
            }
            if(this.m_candy_all_req_mc.hasOwnProperty("future_emo_state_spec_mc"))
            {
               addWidget(this.m_futureEmoStateSpec = new FarmIcon(this.m_candy_all_req_mc["future_emo_state_spec_mc"]));
               this.m_futureEmoStateSpec.visible = true;
            }
         }
         if(m_element.hasOwnProperty("candy_normal_req_mc"))
         {
            this.m_candy_normal_req_mc = m_element["candy_normal_req_mc"] as MovieClip;
            this.m_candy_normal_req_mc.visible = false;
            if(this.m_candy_normal_req_mc.hasOwnProperty("to_make_tf"))
            {
               addWidget(this.to_make_tf_above = new ZwTextField(this.m_candy_normal_req_mc["to_make_tf"],""));
               this.to_make_tf_above.visible = true;
            }
            for(ind = 0; ind < 2; ind++)
            {
               if(this.m_candy_normal_req_mc.hasOwnProperty("candy_req_" + ind.toString() + "_mc"))
               {
                  this.normalCandyMcArray[ind] = this.m_candy_normal_req_mc["candy_req_" + ind.toString() + "_mc"] as MovieClip;
               }
               if(this.normalCandyMcArray[ind].hasOwnProperty("candy_req_icon_1_mc"))
               {
                  this.m_normalCandyImages[ind] = new FarmIcon(this.normalCandyMcArray[ind]["candy_req_icon_1_mc"]);
                  this.m_normalCandyImages[ind].visible = true;
               }
               if(this.normalCandyMcArray[ind].hasOwnProperty("dark_overlay_mc"))
               {
                  this.m_normalCandyOverlay[ind] = this.normalCandyMcArray[ind]["dark_overlay_mc"] as MovieClip;
                  this.m_normalCandyOverlay[ind].visible = false;
               }
            }
            if(this.m_candy_normal_req_mc.hasOwnProperty("current_emo_state_mc"))
            {
               addWidget(this.m_currentEmoState = new FarmIcon(this.m_candy_normal_req_mc["current_emo_state_mc"]));
               this.m_currentEmoState.visible = true;
            }
            if(this.m_candy_normal_req_mc.hasOwnProperty("future_emo_state_mc"))
            {
               addWidget(this.m_futureEmoState = new FarmIcon(this.m_candy_normal_req_mc["future_emo_state_mc"]));
               this.m_futureEmoState.visible = true;
            }
         }
         if(m_element.hasOwnProperty("got_candy_mc"))
         {
            this.m_got_candy_mc = m_element["got_candy_mc"] as MovieClip;
            this.m_got_candy_mc.visible = false;
            if(this.m_got_candy_mc.buy_bt)
            {
               addWidget(this.m_buy_bt = new FarmAnimatedCashButton(this.m_got_candy_mc["buy_bt"],"Skip",KID_WAIT_SKIP_COST.toString(),this.onClickSkipBt));
               this.m_buy_bt.visible = true;
            }
            if(this.m_got_candy_mc.got_candy_timer_tf)
            {
               addWidget(this.m_got_candy_timer_tf = new ZwTextField(this.m_got_candy_mc["got_candy_timer_tf"]));
               this.m_got_candy_timer_tf.visible = true;
            }
            if(this.m_got_candy_mc.got_candy_tf)
            {
               addWidget(this.m_got_candy_tf = new ZwTextField(this.m_got_candy_mc["got_candy_tf"],"Back in"));
               this.m_got_candy_tf.visible = true;
            }
         }
         if(m_element.hasOwnProperty("give_candy_mc"))
         {
            this.m_give_candy_mc = m_element["give_candy_mc"] as MovieClip;
            this.m_give_candy_mc.visible = false;
            if(this.m_give_candy_mc.give_all_bt)
            {
               addWidget(this.m_give_all_bt = new FarmAnimatedTextButton(this.m_give_candy_mc["give_all_bt"],"Give All x1",this.onClickGiveAllBt));
               this.m_give_all_bt.visible = true;
            }
            if(this.m_give_candy_mc.give_normal_bt)
            {
               addWidget(this.m_give_normal_bt = new FarmAnimatedTextButton(this.m_give_candy_mc["give_normal_bt"],"Give x1",this.onClickGiveBt));
               this.m_give_normal_bt.visible = true;
            }
         }
         if(m_element.hasOwnProperty("get_candy_mc"))
         {
            this.m_get_candy_mc = m_element["get_candy_mc"] as MovieClip;
            this.m_get_candy_mc.visible = false;
            if(this.m_get_candy_mc.get_candy_bt)
            {
               addWidget(this.m_get_candy_bt = new FarmAnimatedTextButton(this.m_get_candy_mc["get_candy_bt"],"Get Candy",this.onClickOrderboardOpenBt));
               this.m_get_candy_bt.visible = true;
            }
            if(this.m_get_candy_mc.new_no_candy_tf)
            {
               addWidget(this.m_noCandyKidTf = new ZwTextField(this.m_get_candy_mc["new_no_candy_tf"],""));
               this.m_noCandyKidTf.visible = true;
            }
            if(this.m_get_candy_mc.no_candy_tf)
            {
               addWidget(this.m_no_candy_tf = new ZwTextField(this.m_get_candy_mc["no_candy_tf"],"You don’t have the kids candies!"));
               this.m_no_candy_tf.visible = true;
            }
            if(this.m_get_candy_mc.no_candy_timer_tf)
            {
               addWidget(this.m_no_candy_timer_tf = new ZwTextField(this.m_get_candy_mc["no_candy_timer_tf"],""));
               this.m_no_candy_timer_tf.visible = true;
            }
         }
         if(m_element.hasOwnProperty("kid_img_mc"))
         {
            addWidget(this.m_kid_img_mc = new FarmIcon(m_element["kid_img_mc"]));
            this.m_kid_img_mc.visible = true;
         }
         if(m_element.hasOwnProperty("kid_emo_state_mc"))
         {
            addWidget(this.m_kid_emo_state_mc = new FarmIcon(m_element["kid_emo_state_mc"]));
            this.m_kid_emo_state_mc.visible = true;
         }
         if(m_element.hasOwnProperty("kid_name_tf"))
         {
            addWidget(this.m_kidNameTf = new ZwTextField(m_element["kid_name_tf"],""));
            this.m_kidNameTf.visible = true;
         }
         if(m_element.hasOwnProperty("day_done_mc"))
         {
            this.m_dayDoneMc = m_element["day_done_mc"] as MovieClip;
            this.m_dayDoneMc.visible = false;
         }
      }
      
      override public function populate(data:Object) : void
      {
         var basicCandyNameURL:Object = null;
         var specialCandyNameURL:Object = null;
         var week:int = 0;
         var kidChar:String = null;
         var kidState:String = null;
         var candyDetails:Array = null;
         var i:int = 0;
         var timeLeft:int = 0;
         var kidReturnTime:int = 0;
         super.populate(data);
         this.m_specialCandyAvailable = false;
         this.m_normalCandyAvailable = false;
         this.m_toolTipText = "";
         this.m_candy_all_req_mc.visible = false;
         this.m_candy_normal_req_mc.visible = false;
         this.m_got_candy_mc.visible = false;
         this.m_give_candy_mc.visible = false;
         this.m_get_candy_mc.visible = false;
         this.m_kid_img_mc.visible = true;
         this.m_kid_emo_state_mc.visible = true;
         this.m_dayDoneMc.visible = false;
         if(data)
         {
            if(data.hasOwnProperty("questOrderSlotNumber"))
            {
               this.m_slotnumber = data.questOrderSlotNumber;
            }
            this.m_kidNameTf.text = data["kidName"];
            this.m_kidNameTf.visible = true;
            this.m_kidName = data["kidName"];
            this.m_noCandyKidTf.text = this.m_kidName + " will become";
            this.to_make_tf_below.text = this.m_kidName + " will become";
            this.to_make_tf_above.text = this.m_kidName + " will become";
            this.to_make_tf_below.visible = true;
            this.to_make_tf_above.visible = true;
            this.m_noCandyKidTf.visible = true;
            basicCandyNameURL = this.manager.getBasicCandyNameURLS();
            specialCandyNameURL = this.manager.getSpecialCandyNameURLS();
            week = this.manager.getWeekNumber();
            kidChar = "assets/newsfeed/kid_" + this.manager.KID_CHAR_ARRAY[week * 3 + this.m_slotnumber] + "_" + this.manager.KID_EMOTION_ARRAY[this.manager.getKidStateByKid("kid" + (this.m_slotnumber + 1))] + "_icon_200.png";
            kidState = this.manager.KID_EMOTION_ARRAY[this.manager.getKidStateByKid("kid" + (this.m_slotnumber + 1))];
            if(kidState == "happy")
            {
               this.m_kid_emo_state_mc.loadIcon("assets/dialogs/spooky/innovation/icon_smile.png");
               this.m_currentEmoState.loadIcon("assets/dialogs/spooky/innovation/icon_smile.png");
               this.m_futureEmoState.loadIcon("assets/dialogs/spooky/innovation/icon_smile.png");
               this.m_currentEmoStateSpec.loadIcon("assets/dialogs/spooky/innovation/icon_smile.png");
               this.m_futureEmoStateSpec.loadIcon("assets/dialogs/spooky/innovation/icon_excited.png");
            }
            else if(kidState == "sad")
            {
               this.m_kid_emo_state_mc.loadIcon("assets/dialogs/spooky/innovation/icon_sad.png");
               this.m_currentEmoState.loadIcon("assets/dialogs/spooky/innovation/icon_sad.png");
               this.m_futureEmoState.loadIcon("assets/dialogs/spooky/innovation/icon_smile.png");
               this.m_currentEmoStateSpec.loadIcon("assets/dialogs/spooky/innovation/icon_sad.png");
               this.m_futureEmoStateSpec.loadIcon("assets/dialogs/spooky/innovation/icon_excited.png");
            }
            else if(kidState == "excitement")
            {
               this.m_kid_emo_state_mc.loadIcon("assets/dialogs/spooky/innovation/icon_excited.png");
               this.m_currentEmoState.loadIcon("assets/dialogs/spooky/innovation/icon_excited.png");
               this.m_futureEmoState.loadIcon("assets/dialogs/spooky/innovation/icon_sad.png");
               this.m_currentEmoStateSpec.loadIcon("assets/dialogs/spooky/innovation/icon_excited.png");
               this.m_futureEmoStateSpec.loadIcon("assets/dialogs/spooky/innovation/icon_excited.png");
            }
            this.m_kid_emo_state_mc.setIconSize(40,40);
            this.m_currentEmoState.setIconSize(30,30);
            this.m_futureEmoState.setIconSize(30,30);
            this.m_currentEmoStateSpec.setIconSize(30,30);
            this.m_futureEmoStateSpec.setIconSize(30,30);
            if(data.hasOwnProperty("candyDetails"))
            {
               this.m_normalCandyAvailable = this.manager.isNormalCandiesAvilable(data.candyDetails);
               candyDetails = data.candyDetails;
               for(i = 0; i < candyDetails.length; i++)
               {
                  if(basicCandyNameURL[data.candyDetails[i]])
                  {
                     this.m_candyImages[i].loadIcon(basicCandyNameURL[data.candyDetails[i]]);
                  }
                  else
                  {
                     this.m_candyImages[i].loadIcon(specialCandyNameURL[data.candyDetails[i]]);
                  }
                  this.m_candyImages[i].attachTooltip(new FarmTextTooltip(data.candyDetails[i]));
                  this.m_candyImages[i].setIconSize(30,30);
                  this.m_candyImages[i].visible = true;
                  if(i != 2)
                  {
                     this.m_normalCandyImages[i].loadIcon(basicCandyNameURL[data.candyDetails[i]]);
                     this.m_normalCandyImages[i].setIconSize(30,30);
                     this.m_normalCandyImages[i].visible = true;
                     this.m_normalCandyImages[i].attachTooltip(new FarmTextTooltip(data.candyDetails[i]));
                     if(this.manager.getBasicCandyCountByName(data.candyDetails[i]) > 0)
                     {
                     }
                     this.m_candyNames[i] = data.candyDetails[i];
                  }
                  else
                  {
                     this.m_specialCandy = data.candyDetails[i];
                     if(this.manager.getSpecialCandyCountByName(data.candyDetails[i]) > 0)
                     {
                        this.m_specialCandyAvailable = true;
                     }
                  }
               }
               if(this.manager.getDailyOderboardTaskCount() == this.manager.getMaxDailyOderboardCount() && (this.manager.getBasicCandyCountByName(this.m_candyNames[0]) == 0 || this.manager.getBasicCandyCountByName(this.m_candyNames[1]) == 0))
               {
                  this.m_dayDoneMc.visible = true;
                  this.m_candy_normal_req_mc.visible = false;
                  this.m_candy_all_req_mc.visible = false;
                  this.m_give_candy_mc.visible = false;
                  this.m_get_candy_mc.visible = false;
                  this.normalCandyVisibility(false);
                  this.allCandyVisibility(false);
                  this.stopKidReturnTimer();
                  this.stopKidWaitTimer();
               }
               else
               {
                  timeLeft = this.manager.getKidWaitTime() - this.manager.getKidWaitTimeByKid("kid" + (this.m_slotnumber + 1) + "WaitTime");
                  if(timeLeft > 0)
                  {
                     this.m_candy_normal_req_mc.visible = false;
                     this.m_candy_all_req_mc.visible = false;
                     this.m_got_candy_mc.visible = true;
                     this.normalCandyVisibility(false);
                     this.allCandyVisibility(false);
                     this.startKidWaitTimer();
                  }
                  else if(!this.m_normalCandyAvailable)
                  {
                     kidReturnTime = this.manager.getMaxKidReturnTime() - this.manager.getKidRetuenTimeByKid("kid" + (this.m_slotnumber + 1) + "ReturnTime");
                     if(kidReturnTime >= 0)
                     {
                        this.m_got_candy_mc.visible = false;
                        this.stopKidWaitTimer();
                        this.startKidReturnTimer();
                     }
                     else
                     {
                        this.manager.updateKidStatusReturnTime(this.m_slotnumber,this.m_candyNames[0],this.m_candyNames[1]);
                     }
                  }
                  else
                  {
                     this.m_candy_normal_req_mc.visible = true;
                     this.m_candy_all_req_mc.visible = true;
                     this.m_currentEmoState.visible = true;
                     this.m_futureEmoState.visible = true;
                     this.m_currentEmoStateSpec.visible = true;
                     this.m_futureEmoStateSpec.visible = true;
                     this.m_noCandyKidTf.visible = true;
                     if(this.m_specialCandyAvailable && this.m_normalCandyAvailable)
                     {
                        this.m_give_candy_mc.visible = true;
                        this.m_give_all_bt.visible = true;
                        this.m_give_all_bt.enabled = true;
                        this.m_give_normal_bt.visible = true;
                        this.m_give_normal_bt.enabled = true;
                        this.m_give_all_bt.detachTooltip();
                     }
                     else if(this.m_normalCandyAvailable)
                     {
                        this.m_give_candy_mc.visible = true;
                        this.m_give_all_bt.visible = true;
                        this.m_give_all_bt.enabled = false;
                        this.m_give_normal_bt.visible = true;
                        FarmGameUtil.disableButtonAndShowTooltip(this.m_give_all_bt,"You don\'t have the special candy required");
                     }
                  }
                  this.m_kid_img_mc.loadIcon(kidChar);
                  this.m_kid_img_mc.setIconSize(170,170);
                  this.m_kid_img_mc.visible = true;
               }
            }
         }
      }
      
      private function startKidWaitTimer() : void
      {
         this.m_kidWaitTimer = new Timer(1000);
         this.m_kidWaitTimer.addEventListener(TimerEvent.TIMER,this.onKidWaitTimer);
         this.m_kidWaitTimer.start();
      }
      
      private function startKidReturnTimer() : void
      {
         this.m_kidReturnTimer = new Timer(1000);
         this.m_kidReturnTimer.addEventListener(TimerEvent.TIMER,this.onKidReturnTimer);
         this.m_kidReturnTimer.start();
      }
      
      private function onKidReturnTimer(event:TimerEvent) : void
      {
         var kidReturnTime:int = this.manager.getMaxKidReturnTime() - this.manager.getKidRetuenTimeByKid("kid" + (this.m_slotnumber + 1) + "ReturnTime");
         this.m_got_candy_mc.visible = false;
         this.m_get_candy_mc.visible = true;
         this.m_get_candy_bt.visible = true;
         this.m_noCandyKidTf.text = this.m_kidName + " will become";
         this.m_noCandyKidTf.visible = true;
         this.m_no_candy_timer_tf.text = HUD.getformattedTimeLeft(kidReturnTime);
         this.m_no_candy_timer_tf.visible = true;
         this.m_no_candy_tf.visible = true;
         if(kidReturnTime <= 0 || this.manager.getBasicCandyCountByName(this.m_candyNames[0]) > 0 && this.manager.getBasicCandyCountByName(this.m_candyNames[1]) > 0)
         {
            this.m_get_candy_mc.visible = false;
            this.stopKidReturnTimer();
            this.manager.refreshKidSlot(this.m_slotnumber);
         }
      }
      
      public function stopKidReturnTimer() : void
      {
         if(this.m_kidReturnTimer)
         {
            this.m_kidReturnTimer.stop();
            this.m_kidReturnTimer.removeEventListener(TimerEvent.TIMER,this.onKidReturnTimer);
            this.m_kidReturnTimer = null;
         }
      }
      
      private function onKidWaitTimer(event:TimerEvent) : void
      {
         var timeLeft:int = this.manager.getKidWaitTime() - this.manager.getKidWaitTimeByKid("kid" + (this.m_slotnumber + 1) + "WaitTime");
         this.m_got_candy_timer_tf.visible = true;
         this.m_got_candy_timer_tf.text = HUD.getformattedTimeLeft(timeLeft);
         this.m_got_candy_tf.visible = true;
         this.m_buy_bt.visible = true;
         if(timeLeft <= 0)
         {
            this.m_got_candy_timer_tf.visible = false;
            this.stopKidWaitTimer();
            this.manager.refreshKidSlot(this.m_slotnumber);
         }
      }
      
      public function stopKidWaitTimer() : void
      {
         if(this.m_kidWaitTimer)
         {
            this.m_kidWaitTimer.stop();
            this.m_kidWaitTimer.removeEventListener(TimerEvent.TIMER,this.onKidWaitTimer);
            this.m_kidWaitTimer = null;
         }
      }
      
      private function updateTimer() : void
      {
      }
      
      public function getFormattedTimeLeft(timeLeft:Number) : String
      {
         var minutes:int = 0;
         var seconds:int = 0;
         var resultMin:String = "";
         var resultSec:String = "";
         var result:String = "";
         if(timeLeft < 0)
         {
            timeLeft = 0;
            return "00:00";
         }
         var timeLeftArray:Array = FarmGameUtil.parseTimeLeft(timeLeft);
         if(Boolean(timeLeftArray) && timeLeftArray.length > 3)
         {
            minutes = int(timeLeftArray[2]);
            seconds = int(timeLeftArray[3]);
            resultMin = "0" + minutes.toString();
            if(seconds < 10)
            {
               resultSec = "0" + seconds.toString();
            }
            else
            {
               resultSec = seconds.toString();
            }
         }
         return resultMin + ":" + resultSec;
      }
      
      public function onClickSpecialCandyBt(event:Event) : void
      {
         this.manager.openCandyConversionWindow();
      }
      
      public function onClickOrderboardOpenBt(event:Event) : void
      {
         this.manager.openOrderBoardWindow();
      }
      
      public function onClickGiveBt(event:Event) : void
      {
         this.manager.grantPointForNormalCandies(this.m_candyNames,this.m_slotnumber + 1);
      }
      
      public function onClickGiveAllBt(event:Event) : void
      {
         this.manager.grantPointForSpecialCandies(this.m_candyNames,this.m_specialCandy,this.m_slotnumber + 1);
      }
      
      public function onClickSkipBt(event:Event) : void
      {
         this.m_owner.tintWindow();
         this.m_owner.enableInput = false;
         this.manager.onSkipKidWaitTime(KID_WAIT_SKIP_COST,"kid" + (this.m_slotnumber + 1) + "WaitTime",this.m_slotnumber);
      }
      
      public function normalCandyVisibility(shown:Boolean) : void
      {
         for(var i:int = 0; i < this.m_normalCandyImages.length; i++)
         {
            this.m_normalCandyImages[i].visible = shown;
         }
      }
      
      public function allCandyVisibility(shown:Boolean) : void
      {
         for(var i:int = 0; i < this.m_candyImages.length; i++)
         {
            this.m_candyImages[i].visible = shown;
         }
      }
      
      private function get manager() : Halloween2019InnovationManager
      {
         return Halloween2019InnovationManager.getInstance(this.m_featureName);
      }
   }
}

