package Widgets.Slots
{
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmTask;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Transactions.Quests.TSkipQuestTask;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class MultiTaskProgressSlot extends ZwFrame
   {
      
      private var m_onCompleteTaskCallback:Function;
      
      private var m_quest:FarmQuest;
      
      private var m_taskIndex:int;
      
      public function MultiTaskProgressSlot(element:DisplayObject, quest:FarmQuest, taskIndex:int, onCompleteCallback:Function = null)
      {
         super(element);
         this.m_onCompleteTaskCallback = onCompleteCallback;
         this.m_quest = quest;
         this.m_taskIndex = taskIndex;
         var task:FarmTask = quest.farmTasks[taskIndex];
         addWidget(new ZwTextField(m_element.title_tf,task.titleText));
         addWidget(new ZwTextField(m_element.progressText_tf,ZLocUtils.t("Dialogs","MultiTaskPRogressSlot_progress",{
            "progress":task.progress,
            "total":task.total
         })));
         addWidget(new ZwTextField(m_element.description_tf,task.getFlavorText()));
         addWidget(new FarmIcon(m_element.icon_mc,task.iconUrl));
         if(task.isComplete())
         {
            addWidget(new ZwWidget(m_element.checkmark_mc));
         }
         else
         {
            addWidget(new FarmAnimatedCashButton(m_element.finishButton_bt,ZLocUtils.t("Dialogs","skip"),task.cashValue.toString(),this.onCompleteNowClick,false,false,true));
         }
      }
      
      private function onCompleteNowClick(event:Event) : void
      {
         var task:FarmTask = null;
         var progressTf:ZwTextField = null;
         var cash:int = this.m_quest.farmTasks[this.m_taskIndex].cashValue;
         if(Global.player.canBuyCash(cash))
         {
            Global.player.cash -= cash;
            TransactionManager.addTransaction(new TSkipQuestTask(this.m_quest.name,this.m_taskIndex),true);
            m_element.finishButton_bt.visible = false;
            m_element.checkmark_mc.visible = true;
            task = this.m_quest.farmTasks[this.m_taskIndex];
            progressTf = getWidget(m_element.progressText_tf) as ZwTextField;
            if(Boolean(progressTf) && Boolean(task))
            {
               progressTf.text = ZLocUtils.t("Dialogs","MultiTaskPRogressSlot_progress",{
                  "progress":task.total,
                  "total":task.total
               });
            }
            if(this.m_onCompleteTaskCallback != null && this.m_onCompleteTaskCallback is Function)
            {
               this.m_onCompleteTaskCallback();
            }
         }
      }
   }
}

