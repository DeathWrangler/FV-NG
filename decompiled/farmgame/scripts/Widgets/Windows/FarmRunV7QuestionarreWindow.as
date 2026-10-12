package Widgets.Windows
{
   import Classes.ImageLoader;
   import Classes.ZItem.FarmItem;
   import Display.HUD.HUD;
   import Managers.OrderBoard.FarmRunV7Manager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmRunV7QuestionarreFrame;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.Event;
   
   public class FarmRunV7QuestionarreWindow extends FarmWindow
   {
      
      private static const FEATURE_NAME:String = "FarmRunV7";
      
      public static const FEATURE_OPTIONS_KEY:String = "FarmRunV7";
      
      protected var m_featureName:String = null;
      
      private var m_reward:FarmItem = null;
      
      private var m_callback:Function = null;
      
      protected var title_tf:ZwTextField = null;
      
      protected var m_question_tf:ZwTextField;
      
      protected var m_time_tf:ZwTextField;
      
      public var m_talk_tf:ZwTextField;
      
      protected var points_tf:ZwTextField;
      
      protected var m_zoomingScale:int = 3;
      
      private var m_dialogBackground:String;
      
      private var m_bgLoader:ImageLoader = null;
      
      private var m_bgIcon:DisplayObject = null;
      
      private var m_iconUrl:String;
      
      private var m_buildingName:String;
      
      private var m_shareBt:FarmAnimatedTextButton;
      
      private const TIMER_TF:String = "time_tf";
      
      private const TIMER_PREFIX:String = "00:";
      
      private const TIMER_PREFIX_SECONDS:String = "00:0";
      
      private var m_showGiftMc:Boolean;
      
      private var m_scoreMc:MovieClip;
      
      public var m_countMc:MovieClip;
      
      public var start_count:int = 0;
      
      private var m_questionData:Array;
      
      private var m_FarmRunQuestionarreFrame:FarmRunV7QuestionarreFrame;
      
      private var m_pointsMc:MovieClip;
      
      public var m_talkMc:MovieClip;
      
      public var m_timerMc:MovieClip;
      
      public var m_timeranimMc:MovieClip;
      
      private var m_closeBt:SimpleButton;
      
      private var m_overlayMc:MovieClip;
      
      public function FarmRunV7QuestionarreWindow(dialogAsset:String, featureName:String, rewardItem:FarmItem = null, buttonCallback:Function = null, dialogBackground:String = null, iconUrl:String = "", building:String = "hardy", showGift:Boolean = false)
      {
         super(dialogAsset,true,true);
         this.m_reward = rewardItem;
         this.m_featureName = featureName;
         this.m_callback = buttonCallback;
         this.m_dialogBackground = dialogBackground;
         this.m_iconUrl = iconUrl;
         this.m_showGiftMc = showGift;
         this.m_buildingName = building;
         if(this.m_dialogBackground != null)
         {
            this.m_bgLoader = ImageLoader.getInstance(Global.getAssetURL(this.m_dialogBackground));
            this.m_bgLoader.getContent(this.onBgLoad);
         }
         this.manager.parseQuestionarreDataFromConfig(FEATURE_NAME);
      }
      
      private function onBgLoad(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_bgIcon = dispObj;
      }
      
      override protected function postLoadComplete() : void
      {
         var currWorld:String = null;
         var worldNum:int = 0;
         var worldId:String = null;
         var i:int = 0;
         var points:String = null;
         var quesText:String = null;
         var questSlotId:String = null;
         super.postLoadComplete();
         this.manager.startTimer();
         this.m_questionData = this.manager.getQuestionData();
         this.start_count = this.manager.getQuestionCount(FEATURE_OPTIONS_KEY);
         if(m_window != null)
         {
            if(m_window.hasOwnProperty("points_mc"))
            {
               this.m_pointsMc = m_window.points_mc as MovieClip;
               this.m_pointsMc.visible = true;
            }
            if(m_window.hasOwnProperty("close_bt"))
            {
               this.m_closeBt = m_window.close_bt;
               this.m_closeBt.enabled = false;
               this.m_closeBt.visible = false;
            }
            if(m_window.hasOwnProperty("talk_mc"))
            {
               this.m_talkMc = m_window.talk_mc as MovieClip;
               this.m_talkMc.visible = true;
            }
            if(Boolean(this.m_talkMc) && this.m_talkMc.hasOwnProperty("npc_tf"))
            {
               addWidget(this.m_talk_tf = new ZwTextField(this.m_talkMc["npc_tf"]));
               this.m_talk_tf.text = "\nHere is Question 1";
               this.m_talk_tf.visible = true;
            }
            if(m_window.hasOwnProperty("timer_mc"))
            {
               this.m_timerMc = m_window.timer_mc as MovieClip;
               this.m_timerMc.visible = true;
            }
            if(this.m_timerMc.hasOwnProperty(this.TIMER_TF))
            {
               addWidget(this.m_time_tf = new ZwTextField(this.m_timerMc[this.TIMER_TF],"01:00"));
            }
            if(this.m_timerMc.hasOwnProperty("timer_anim"))
            {
               this.m_timeranimMc = this.m_timerMc.timer_anim as MovieClip;
               this.m_timeranimMc.visible = false;
            }
            if(Boolean(this.m_pointsMc) && this.m_pointsMc.hasOwnProperty("points_tf"))
            {
               points = this.manager.getCurrentScore(FEATURE_OPTIONS_KEY) as String;
            }
            if(m_window.hasOwnProperty("question_tf"))
            {
               quesText = this.m_questionData[this.start_count].questionText;
               addWidget(this.m_question_tf = new ZwTextField(m_window["question_tf"],quesText));
               this.m_question_tf.visible = true;
            }
            if(m_window.hasOwnProperty("title_tf"))
            {
               addWidget(this.title_tf = new ZwTextField(m_window["title_tf"],this.m_featureName));
               this.title_tf.visible = true;
            }
            currWorld = Global.worldManager.currentWorldType;
            worldNum = this.manager.getworldIndexFromName(currWorld);
            worldId = "world" + (worldNum + 1) + "BG_mc";
            if(m_window.hasOwnProperty(worldId))
            {
               m_window[worldId].visible = true;
               m_window[worldId].enabled = true;
            }
            if(m_window.hasOwnProperty("slots_mc"))
            {
               this.m_FarmRunQuestionarreFrame = new FarmRunV7QuestionarreFrame(m_window["slots_mc"],this,this.m_featureName);
               this.m_FarmRunQuestionarreFrame.visible = true;
            }
            if(m_window.hasOwnProperty("score_mc"))
            {
               this.m_scoreMc = m_window.score_mc as MovieClip;
               this.m_scoreMc.visible = true;
               this.m_scoreMc.enabled = true;
            }
            for(i = 0; i < 3; i++)
            {
               questSlotId = "count_mc_" + i;
               this.m_countMc = this.m_scoreMc[questSlotId] as MovieClip;
               this.m_countMc.visible = true;
               this.m_countMc.enabled = true;
               this.m_countMc.gotoAndStop(1);
            }
            if(m_window.hasOwnProperty("share_bt") && this.m_buildingName != "finalReward")
            {
               addWidget(this.m_shareBt = new FarmAnimatedTextButton(m_window["share_bt"],"Share!",this.buttonCallback));
            }
            else if(m_window.hasOwnProperty("accept_bt"))
            {
               addWidget(new FarmAnimatedTextButton(m_window["accept_bt"],"Awesome",this.buttonCallback));
            }
            if(m_window.hasOwnProperty("overlay"))
            {
               this.m_overlayMc = m_window["overlay"] as MovieClip;
               this.m_overlayMc.visible = true;
            }
         }
      }
      
      private function buttonCallback(evt:Event) : void
      {
         if(this.m_callback != null)
         {
            this.m_callback(evt);
         }
         close();
      }
      
      public function updateTime() : void
      {
         var seconds:int = 0;
         if(this.m_time_tf)
         {
            seconds = this.manager.getQuizTimeRemaining();
            if(seconds / 10 < 1)
            {
               this.m_time_tf.text = this.TIMER_PREFIX_SECONDS + seconds.toString();
            }
            else
            {
               this.m_time_tf.text = this.TIMER_PREFIX + seconds.toString();
            }
         }
      }
      
      private function getTimeLeft() : String
      {
         var timeRemaining:Array = this.manager.getTimeRemaining();
         var timeLeft:String = "";
         if(parseInt(timeRemaining[3]) > 1)
         {
            timeLeft = timeRemaining[3] + " seconds";
         }
         else
         {
            timeLeft = HUD.getformattedTimeLeftFromArray(timeRemaining);
         }
         return timeLeft;
      }
      
      private function getQuizTimeLeft() : String
      {
         var timeRemaining:Number = this.manager.getQuizTimeRemaining();
         return timeRemaining.toString();
      }
      
      private function get manager() : FarmRunV7Manager
      {
         return FarmRunV7Manager.getInstance(FEATURE_NAME);
      }
      
      override public function refreshWindow() : void
      {
         var slotKey:String = null;
         var questSlotId:String = null;
         var progress:Number = this.manager.getNPCProgress();
         this.start_count = this.manager.getQuestionCount(FEATURE_OPTIONS_KEY);
         this.m_talk_tf.visible = true;
         var quesText:String = this.m_questionData[this.start_count].questionText;
         this.m_question_tf.text = quesText;
         this.m_question_tf.visible = true;
         for(var i:int = 0; i < 3; i++)
         {
            slotKey = this.manager.getKeyForQuestion(i);
            questSlotId = "count_mc_" + i;
            if(this.m_scoreMc.hasOwnProperty(questSlotId))
            {
               this.m_countMc = this.m_scoreMc[questSlotId] as MovieClip;
               this.m_countMc.visible = true;
               this.m_countMc.enabled = true;
               this.m_countMc.gotoAndStop(0);
               if(this.manager.wasAnsweredCorrectly(slotKey))
               {
                  this.m_countMc.gotoAndStop(2);
               }
               else if(this.manager.wasNotAttempted(slotKey))
               {
                  this.m_countMc.gotoAndStop(1);
               }
               else
               {
                  this.m_countMc.gotoAndStop(3);
               }
            }
         }
         this.refreshTaskFrame();
      }
      
      public function refreshTaskFrame() : void
      {
         this.m_FarmRunQuestionarreFrame.refresh();
      }
      
      override protected function onClose(evt:Event) : void
      {
         this.manager.stopTimer();
         super.onClose(evt);
      }
   }
}

