package Widgets.Slots
{
   import Classes.Constants.QuestConstants;
   import Classes.Quest.FarmTask;
   import Classes.util.ZLocUtils;
   import Managers.OrderBoard.BobBerryManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Constants.ZwToggleMode;
   import Widgets.Core.Constants.ZwToggleState;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.BobBerryFarmWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.text.TextField;
   
   public class BobsBerryQuestTaskSlot extends ZwSlotFrame
   {
      
      public var m_slotnumber:int;
      
      private var m_owner:BobBerryFarmWindow;
      
      private var m_quest_title:FarmTextField;
      
      private var m_quest_done:FarmTextField;
      
      private var m_ask_button:FarmAnimatedTextButton;
      
      private var m_skip_button:FarmAnimatedCashButton;
      
      private var m_checkmark:MovieClip;
      
      private var m_tasktype:String = "";
      
      private var m_featurename:String;
      
      private var m_task:FarmTask;
      
      private var m_data:Object;
      
      public function BobsBerryQuestTaskSlot(element:DisplayObject, owner:BobBerryFarmWindow, featureName:String)
      {
         this.m_featurename = featureName;
         this.m_owner = owner;
         super(element);
         if(m_element.hasOwnProperty("questtitle_tf"))
         {
            this.m_quest_title = addWidget(new FarmTextField(m_element.questtitle_tf as TextField,""),true) as FarmTextField;
         }
         if(m_element.hasOwnProperty("questdone_tf"))
         {
            this.m_quest_done = addWidget(new FarmTextField(m_element.questdone_tf as TextField,""),true) as FarmTextField;
         }
         if(m_element.hasOwnProperty("task_bt"))
         {
            this.m_ask_button = addWidget(new FarmAnimatedTextButton(m_element.task_bt,"",this.doHelper)) as FarmAnimatedTextButton;
         }
         if(m_element.hasOwnProperty("skip_bt"))
         {
            this.m_skip_button = addWidget(new FarmAnimatedCashButton(m_element.skip_bt,"Skip","",this.skipTask)) as FarmAnimatedCashButton;
         }
         if(m_element.hasOwnProperty("checkmark_mc"))
         {
            this.m_checkmark = m_element.checkmark_mc as MovieClip;
         }
      }
      
      private static function toggleButton(button:FarmAnimatedTextButton, to:Boolean) : void
      {
         button.enabled = to;
         button.applyGrayOut = !to;
      }
      
      private function conditionallyShowProgressComplete() : void
      {
         if(Boolean(this.m_data) && this.m_data.progress >= this.m_task.total)
         {
            this.m_quest_done.visible = false;
            this.m_checkmark.visible = true;
            this.m_skip_button.visible = false;
            this.m_ask_button.visible = false;
         }
      }
      
      private function onAskFeedPosted(success:Boolean) : void
      {
         var task:FarmTask = this.m_task;
         if(Boolean(this.m_ask_button) && Boolean(task))
         {
            if(task.canAskForHelp())
            {
               this.m_ask_button.enabled = true;
               this.m_ask_button.text = ZLocUtils.t("Quests","Helper_AskForHelp_Button");
            }
            else
            {
               this.m_ask_button.enabled = false;
               this.m_ask_button.text = ZLocUtils.t("Quests","Helper_AskForHelp_Sent");
            }
         }
      }
      
      private function doHelper(ev:Event = null) : void
      {
         if(this.m_task)
         {
            this.m_task.performHelperAction(null,this.onAskFeedPosted);
         }
         if(this.m_task.action == QuestConstants.TASK_USE_ITEM_BY_CODE)
         {
            this.m_ask_button.enabled = false;
            this.m_ask_button.text = ZLocUtils.t("Quests","Helper_AskForHelp_InProgress");
         }
         else
         {
            this.m_owner.close();
         }
      }
      
      public function setHelperText(requestText:String) : void
      {
         if(requestText == "" || requestText == null)
         {
            this.m_ask_button.visible = false;
            return;
         }
         if(Boolean(this.m_ask_button.element) && Boolean(this.m_ask_button.element.hasOwnProperty("generic_tf")) && !this.m_checkmark.visible)
         {
            this.m_ask_button.element.generic_tf.text = requestText;
            this.m_ask_button.visible = true;
         }
         else
         {
            this.m_ask_button.visible = false;
         }
      }
      
      public function skipTask(ev:Event = null) : void
      {
         this.m_quest_done.visible = false;
         this.m_checkmark.visible = true;
         this.m_skip_button.visible = false;
         this.m_ask_button.visible = false;
         BobBerryManager.getInstance(this.m_featurename).skipTask(this.m_slotnumber);
         this.m_owner.refreshMainUI();
      }
      
      private function setSkipButton(cost:String, tasktype:String) : void
      {
         if(tasktype != "" || tasktype != null)
         {
            this.m_tasktype = tasktype;
         }
         if(Boolean(this.m_skip_button) && !this.m_checkmark.visible)
         {
            this.m_skip_button.visible = true;
            this.m_skip_button.setAmountText(cost);
            if(parseInt(cost) >= 10)
            {
               this.m_skip_button.showPaymentConfirmation = true;
            }
         }
         else
         {
            this.m_skip_button.visible = false;
         }
      }
      
      override public function populate(data:Object) : void
      {
         var tooltipText:String = null;
         this.m_data = data;
         if(Boolean(data) && data.hasOwnProperty("questTask"))
         {
            this.m_task = data.questTask;
         }
         if(Boolean(data) && data.hasOwnProperty("questTaskSlotNumber"))
         {
            this.m_slotnumber = data.questTaskSlotNumber;
         }
         if(Boolean(data) && data.hasOwnProperty("questText"))
         {
            this.m_quest_title.text = data.questText;
            if(this.m_quest_title)
            {
               this.m_quest_title.visible = true;
            }
         }
         if(Boolean(data) && data.hasOwnProperty("completed"))
         {
            this.m_checkmark.visible = data.completedTask;
         }
         if(data)
         {
            this.m_quest_done.text = data.progress + "/" + this.m_task.total;
            this.m_quest_done.visible = true;
         }
         else
         {
            this.m_quest_done.visible = false;
         }
         if(Boolean(data) && Boolean(data.hasOwnProperty("taskType")) && data.hasOwnProperty("helperText"))
         {
            this.setHelperText(data.helperText);
            this.setSkipButton(data.skipCashValue,data.taskType);
         }
         if(this.m_task.action == QuestConstants.TASK_USE_ITEM_BY_CODE)
         {
            this.m_ask_button.enabled = this.m_task.canAskForHelp();
         }
         this.conditionallyShowProgressComplete();
         if(!this.m_ask_button.enabled)
         {
            tooltipText = data.helperText;
            this.m_ask_button.text = ZLocUtils.t("Quests","Helper_R4R_Button");
            this.disableAskButton(tooltipText);
         }
         else
         {
            toggleButton(this.m_ask_button,true);
         }
      }
      
      private function disableAskButton(tooltipText:String) : void
      {
         if(this.m_ask_button)
         {
            this.m_ask_button.enabled = true;
            this.m_ask_button.setToggleMode(ZwToggleMode.SINGLE_SELECT);
            this.m_ask_button.setToggleState(ZwToggleState.SELECTED);
            this.m_ask_button.applyGrayOut = true;
            this.m_ask_button.element.buttonMode = false;
            this.m_ask_button.attachTooltip(new FarmTextTooltip(tooltipText));
         }
      }
   }
}

