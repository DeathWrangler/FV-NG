package Widgets.Frames.ThemedQuest
{
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmTask;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Transactions.Quests.TSkipQuestTask;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ThemedQuestPieceSlotFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.ProgressBars.FarmProgressBar;
   import Widgets.Slots.ThemedQuest.ThemedQuestPieceSlot;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class ThemedQuestToolTipFrame extends ZwFrame
   {
      
      private var m_completeNow:FarmAnimatedCashButton;
      
      private var m_completeNow2:FarmAnimatedCashButton;
      
      private var m_askButton:FarmAnimatedTextButton;
      
      private var m_taskProgres:FarmProgressBar;
      
      private var m_title:ZwTextField;
      
      private var m_taskIcon:FarmIcon;
      
      private var m_quest:FarmQuest;
      
      private var m_taskIndex:int;
      
      private var m_piece:ThemedQuestPieceSlot;
      
      private var m_progressCounter:ZwTextField;
      
      public function ThemedQuestToolTipFrame(element:DisplayObject, piece:ThemedQuestPieceSlot)
      {
         super(element);
         this.m_piece = piece;
         addWidget(new ZwFrame(m_element.tooltip_mc));
         if(m_element.tooltip_mc.title_tf)
         {
            this.m_title = addWidget(new ZwTextField(m_element.tooltip_mc.title_tf)) as ZwTextField;
         }
         if(m_element.tooltip_mc.meter_mc)
         {
            this.m_taskProgres = addWidget(new FarmProgressBar(m_element.tooltip_mc.meter_mc)) as FarmProgressBar;
         }
         if(m_element.tooltip_mc.icon_mc)
         {
            this.m_taskIcon = addWidget(new FarmIcon(m_element.tooltip_mc.icon_mc)) as FarmIcon;
         }
         if(m_element.tooltip_mc.unlock_bt)
         {
            this.m_completeNow = addWidget(new FarmAnimatedCashButton(m_element.tooltip_mc.unlock_bt,"Complete","",this.onCompleteNow)) as FarmAnimatedCashButton;
         }
         if(m_element.tooltip_mc.unlock2_bt)
         {
            this.m_completeNow2 = addWidget(new FarmAnimatedCashButton(m_element.tooltip_mc.unlock2_bt,"Complete","",this.onCompleteNow)) as FarmAnimatedCashButton;
         }
         if(m_element.tooltip_mc.start_bt)
         {
            this.m_askButton = addWidget(new FarmAnimatedTextButton(m_element.tooltip_mc.start_bt,"Ask",this.onAskForHelp)) as FarmAnimatedTextButton;
         }
         if(m_element.tooltip_mc.progressText_tf)
         {
            this.m_progressCounter = addWidget(new ZwTextField(m_element.tooltip_mc.progressText_tf)) as ZwTextField;
         }
      }
      
      public function setTaskData(quest:FarmQuest, taskIndex:int) : void
      {
         var canAskForHelp:Boolean = false;
         var taskCashValue:String = null;
         this.m_quest = quest;
         this.m_taskIndex = taskIndex;
         var task:FarmTask = this.m_quest.farmTasks[this.m_taskIndex];
         if(task)
         {
            if(this.m_title)
            {
               this.m_title.text = task.titleText;
            }
            if(this.m_taskProgres)
            {
               this.m_taskProgres.progress = task.progress / task.total * 100;
            }
            if(this.m_progressCounter)
            {
               this.m_progressCounter.text = task.progress.toString() + "/" + task.total.toString();
            }
            if(this.m_taskIcon)
            {
               this.m_taskIcon.loadIcon(task.iconUrl);
               this.m_taskIcon.setIconSize(100,100);
            }
            canAskForHelp = task.canAskForHelp();
            taskCashValue = task.cashValue.toString();
            if(this.m_askButton)
            {
               this.m_askButton.text = task.helperText;
               this.m_askButton.enabled = this.m_askButton.visible = this.m_completeNow2.visible = canAskForHelp;
            }
            if(this.m_completeNow)
            {
               this.m_completeNow.setAmountText(taskCashValue);
               this.m_completeNow2.setAmountText(taskCashValue);
               this.m_completeNow.visible = !canAskForHelp;
            }
         }
      }
      
      private function onAskForHelp(e:Event) : void
      {
         var task:FarmTask = this.m_quest.farmTasks[this.m_taskIndex];
         if(Boolean(task) && task.canAskForHelp())
         {
            task.performHelperAction();
         }
      }
      
      private function onCompleteNow(e:Event) : void
      {
         var cash:int = 0;
         var frame:ThemedQuestPieceSlotFrame = null;
         var task:FarmTask = this.m_quest.farmTasks[this.m_taskIndex];
         if(task)
         {
            cash = task.cashValue;
            if(Global.player.canBuyCash(cash))
            {
               Global.player.cash -= cash;
               StatsManager.count("fv_cash_buy","fv_puzz_house","prize_puzzhouse",cash.toString(),"task_complete");
               TransactionManager.addTransaction(new TSkipQuestTask(this.m_quest.name,this.m_taskIndex),true);
               frame = this.m_piece.parent as ThemedQuestPieceSlotFrame;
               if(frame)
               {
                  frame.refresh();
                  frame.parentWindow.conditionallyShowQuestCompleteDialog();
                  frame.parentWindow.refreshSkipPrice();
               }
            }
         }
      }
   }
}

