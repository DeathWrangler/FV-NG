package Widgets.Frames
{
   import Classes.Quest.FarmTask;
   import Managers.OrderBoard.BobBerryManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.BobsBerryQuestTaskSlot;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.BobBerryFarmWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class BobsBerryQuestTaskContainerFrame extends FarmSlotContainerFrame
   {
      
      private var m_owner:BobBerryFarmWindow;
      
      private var m_featureName:String;
      
      private var m_changefreebutton:FarmAnimatedTextButton;
      
      private var m_changeByCashButton:FarmAnimatedCashButton;
      
      private var m_skipallbutton:FarmAnimatedCashButton;
      
      private var m_waitTimer:FarmTextField;
      
      private var m_rewardCount:FarmTextField;
      
      public function BobsBerryQuestTaskContainerFrame(element:DisplayObject, owner:BobBerryFarmWindow, featureName:String)
      {
         this.m_owner = owner;
         this.m_featureName = featureName;
         super(element);
         if(m_element.hasOwnProperty("title2_tf"))
         {
            m_element.title2_tf.text = "REWARD";
            m_element.title2_tf.visible = true;
         }
         if(m_element.hasOwnProperty("wait_tf"))
         {
            this.m_waitTimer = addWidget(new FarmTextField(m_element.wait_tf,""),false) as FarmTextField;
         }
         if(m_element.hasOwnProperty("reward_tf"))
         {
            this.m_rewardCount = addWidget(new FarmTextField(m_element.reward_tf,""),true) as FarmTextField;
         }
         if(m_element.hasOwnProperty("changefree_bt"))
         {
            this.m_changefreebutton = addWidget(new FarmAnimatedTextButton(m_element.changefree_bt,"Change Quest",this.onChangeQuestClick),true) as FarmAnimatedTextButton;
            this.m_changefreebutton.visible = BobBerryManager.getInstance(this.m_featureName).isFreeDifficultyChangeAllowed();
         }
         if(m_element.hasOwnProperty("change_bt"))
         {
            this.m_changeByCashButton = addWidget(new FarmAnimatedCashButton(m_element.change_bt,"Change Quest","",this.onChangeQuestWithCashClick),true) as FarmAnimatedCashButton;
            this.m_changeByCashButton.setAmountText(BobBerryManager.CASH_VALUE_FOR_DIFFICULTY_CHANGE.toString());
            this.m_changeByCashButton.visible = !BobBerryManager.getInstance(this.m_featureName).isFreeDifficultyChangeAllowed();
         }
         if(m_element.hasOwnProperty("skipall_bt"))
         {
            this.m_skipallbutton = addWidget(new FarmAnimatedCashButton(m_element.skipall_bt,"Skip All","",this.onSkipAllTasksClick),true) as FarmAnimatedCashButton;
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new BobsBerryQuestTaskSlot(slotElement,this.m_owner,this.m_featureName);
      }
      
      public function onChangeQuestClick(ev:Event = null) : void
      {
         BobBerryManager.getInstance(this.m_featureName).changeQuestWithoutCash();
         this.m_owner.showLevelFrame();
      }
      
      public function onChangeQuestWithCashClick(ev:Event = null) : void
      {
         if(Global.player.canBuyCash(BobBerryManager.CASH_VALUE_FOR_DIFFICULTY_CHANGE))
         {
            BobBerryManager.getInstance(this.m_featureName).deductCashForDifficulty();
            this.m_owner.showLevelFrame();
         }
      }
      
      private function onSkipAllTasksClick(e:Event) : void
      {
         BobBerryManager.getInstance(this.m_featureName).skipAllTasks();
         this.m_owner.refreshMainUI();
      }
      
      override public function refresh() : void
      {
         this.setupData();
         var rewards:Vector.<Object> = BobBerryManager.getInstance(this.m_featureName).getRewards();
         this.m_rewardCount.text = rewards[0].value;
         var skipAllCash:int = BobBerryManager.getInstance(this.m_featureName).getSkipAllCashValue();
         this.m_skipallbutton.setAmountText(skipAllCash.toString());
         if(skipAllCash >= 10)
         {
            this.m_skipallbutton.showPaymentConfirmation = true;
         }
         this.m_changeByCashButton.visible = !BobBerryManager.getInstance(this.m_featureName).isFreeDifficultyChangeAllowed();
         this.m_changefreebutton.visible = BobBerryManager.getInstance(this.m_featureName).isFreeDifficultyChangeAllowed();
         if(this.m_changeByCashButton.visible)
         {
            this.m_waitTimer.text = BobBerryManager.getInstance(this.m_featureName).getWaitTimeText();
            this.m_waitTimer.visible = true;
         }
         super.refresh();
      }
      
      override protected function setupData() : void
      {
         var completedTask:Boolean = false;
         var questTasks1:Vector.<FarmTask> = null;
         m_slotData = [];
         questTasks1 = BobBerryManager.getInstance(this.m_featureName).getTasks();
         for(var i:int = 0; i < questTasks1.length; i++)
         {
            completedTask = BobBerryManager.getInstance(this.m_featureName).getTaskProgress(i) >= questTasks1[i].total;
            m_slotData.push({
               "questTaskSlotNumber":i,
               "questTask":questTasks1[i],
               "questType":questTasks1[i].action,
               "questText":questTasks1[i].titleText,
               "helperText":questTasks1[i].helperText,
               "taskType":questTasks1[i].helperType,
               "skipCashValue":questTasks1[i].skipCashValue,
               "progress":BobBerryManager.getInstance(this.m_featureName).getTaskProgress(i),
               "completed":completedTask
            });
         }
      }
      
      override public function release() : void
      {
         this.m_owner = null;
         this.m_changeByCashButton = null;
         this.m_changefreebutton = null;
         this.m_featureName = null;
         this.m_rewardCount = null;
         this.m_skipallbutton = null;
         this.m_waitTimer = null;
      }
   }
}

