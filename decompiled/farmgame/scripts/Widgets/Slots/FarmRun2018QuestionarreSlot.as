package Widgets.Slots
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.OrderBoard.FarmRun2018Manager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.FarmRun2018QuestionarreWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class FarmRun2018QuestionarreSlot extends ZwSlotFrame
   {
      
      public static const FEATURE_OPTIONS_KEY:String = "FarmRunV10_2020";
      
      public static const FV_FARMRUN2018_QUESTION:String = "farmrun2018_question_count";
      
      private static const SERVICE_NAME:String = "FarmRun2018Service";
      
      public static const COUNT_SLOT_PREFIX:String = "count_";
      
      public static const COUNT_SLOT_SUFFIX:String = "_mc";
      
      public static const FV_FARMRUN2018_CURRENT_STATE:String = "farmrun2018_state";
      
      public static const FARMRUN_QUIZ_TUTORIAL_SEEN_FLAG:String = "FarmRun2018_QuizTutorialSeen";
      
      public static const VALIDATION_SUCCESSFUL:String = "success";
      
      public static const SCORE_FOR_RIGHT_ANSWER:int = 7;
      
      public static const SCORE_FOR_WRONG_ANSWER:int = 0;
      
      private var m_window:FarmRun2018QuestionarreWindow;
      
      private var m_data:Object;
      
      protected var m_world:String = null;
      
      private var m_index:int = -1;
      
      public var start_count:int = 0;
      
      protected var m_option:String = null;
      
      protected var m_slotNum:int = 0;
      
      private var m_iconTooltip:FarmTextTooltip;
      
      private var m_questionData:Array;
      
      private var m_featureData:Object;
      
      private const FEATURE_NAME:String = "FarmRunV10_2020";
      
      private const IVYFENCE_URL:String = "assets/decorations/deco_ivyfence_icon_50.png";
      
      private const XCOVE_WHITEBENCH_URL:String = "assets/decorations/expansions/xcove/xcove_deco_whitebench_icon_50.png";
      
      private var m_worldName:ZwTextField;
      
      private var m_select_bt:FarmAnimatedTextButton;
      
      private var m_checkmarkMc:MovieClip;
      
      private var m_lockMc:MovieClip;
      
      private var m_iconMc:FarmIcon;
      
      public var m_scoreMc:MovieClip;
      
      public function FarmRun2018QuestionarreSlot(element:DisplayObject, window:FarmRun2018QuestionarreWindow)
      {
         this.m_window = window;
         super(element);
         this.m_questionData = this.manager.getQuestionData();
         this.start_count = this.manager.getQuestionCount(FEATURE_OPTIONS_KEY);
         if(this.m_window.hasOwnProperty("score_mc"))
         {
            this.m_scoreMc = this.m_window["score_mc"] as MovieClip;
            this.m_scoreMc.visible = true;
            this.m_scoreMc.enabled = false;
         }
         if(m_element.icon_mc != null)
         {
            addWidget(this.m_iconMc = new FarmIcon(m_element.icon_mc));
         }
         if(m_element.hasOwnProperty("name_tf"))
         {
            addWidget(this.m_worldName = new ZwTextField(element["name_tf"],"Something"));
         }
         if(m_element.hasOwnProperty("correct_mc"))
         {
            m_element.correct_mc.visible = false;
            m_element.correct_mc.enabled = false;
         }
         if(m_element.hasOwnProperty("incorrect_mc"))
         {
            m_element.incorrect_mc.visible = false;
            m_element.incorrect_mc.enabled = false;
         }
         if(m_element.hasOwnProperty("select_bt"))
         {
            addWidget(this.m_select_bt = new FarmAnimatedTextButton(m_element.select_bt,"Select",this.onClickSelectOption));
            this.m_select_bt.visible = true;
            this.m_select_bt.enabled = true;
         }
         if(m_element.hasOwnProperty("checkmark_mc"))
         {
            this.m_checkmarkMc = m_element.checkmark_mc as MovieClip;
            this.m_checkmarkMc.visible = true;
            this.m_checkmarkMc.visible = true;
            this.m_checkmarkMc.visible = true;
         }
         if(m_element.hasOwnProperty("lock_mc"))
         {
            this.m_lockMc = m_element.lock_mc as MovieClip;
            this.m_lockMc.visible = true;
         }
      }
      
      private function refreshSlotData() : void
      {
      }
      
      public function onClickTravel() : void
      {
         this.manager.openQuestionarreWindow();
      }
      
      private function onClickSelectOption(evt:Event) : void
      {
         this.m_select_bt.enabled = false;
         this.start_count = this.manager.getQuestionCount(FEATURE_OPTIONS_KEY);
         this.manager.incrementQuestionCount(FEATURE_OPTIONS_KEY);
         var worldName:String = Global.worldManager.currentWorldType;
         var ansKey:String = worldName + "_" + this.FEATURE_NAME + "_q" + (this.start_count + 1);
         var answer:String = ZLocUtils.t("Dialogs",ansKey);
         var selectedAnswer:String = this.m_questionData[this.start_count].options[this.m_slotNum];
         if(selectedAnswer == answer)
         {
            this.manager.incrementScore(SCORE_FOR_RIGHT_ANSWER);
            this.manager.markAnsweredCorrectly();
            m_element.correct_mc.visible = true;
            m_element.correct_mc.enabled = true;
            this.m_window.m_talk_tf.text = "That is correct!\nKeep going!\n" + this.manager.getNPCText();
         }
         else
         {
            m_element.incorrect_mc.enabled = true;
            m_element.incorrect_mc.visible = true;
            this.m_window.m_talk_tf.text = "Whoopsie!\nBetter luck next time!\n" + this.manager.getNPCText();
            this.manager.markAnsweredWrong();
         }
         this.manager.incrementQuesQueueNumAndState(FEATURE_OPTIONS_KEY);
         this.manager.validatedAnswer(selectedAnswer);
         var currTurnQuestionCount:int = this.manager.getNumberofQuestionsAskedSoFar();
         var questionSlot:String = COUNT_SLOT_PREFIX + currTurnQuestionCount + COUNT_SLOT_SUFFIX;
         if(this.manager.getNumberofQuestionsAskedSoFar() < 3)
         {
            this.m_window.refreshWindow();
         }
         else
         {
            this.m_window.close();
            this.manager.incrementOverallScore();
            this.manager.openScoreBoard();
            this.manager.stopTimer();
         }
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         m_element.incorrect_mc.visible = false;
         m_element.correct_mc.visible = false;
         this.m_select_bt.visible = true;
         this.m_select_bt.enabled = true;
         this.m_option = data.option;
         this.m_slotNum = data.slotNumber;
         this.start_count = this.manager.getQuestionCount(FEATURE_OPTIONS_KEY);
         var slotNo:int = int(data["slotNumber"]);
         var itemName:String = this.m_questionData[this.start_count].options[this.m_slotNum];
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         this.m_iconMc.loadIcon(item.iconUrl);
         this.m_iconMc.setIconSize(100,100);
         this.m_iconMc.visible = true;
         this.refreshSlotData();
      }
      
      private function get manager() : FarmRun2018Manager
      {
         return FarmRun2018Manager.getInstance(this.FEATURE_NAME);
      }
      
      override public function release() : void
      {
         super.release();
      }
   }
}

