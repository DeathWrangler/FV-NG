package Widgets.Windows.Quests.MultiStageQuests
{
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmTask;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Transactions.Quests.TSkipQuestTask;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Slots.MultiCollectItemSlot;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class StageMultiCollectItemWidget extends AbstractStageWidget
   {
      
      private static const SLOT_PREFIX:String = "giftPanel";
      
      private var m_completeCost:int;
      
      private var m_completeBtn:FarmAnimatedCashButton;
      
      private var m_progress:MovieClip = null;
      
      private var m_completeCallback:Function;
      
      public function StageMultiCollectItemWidget(element:DisplayObject, quest:FarmQuest, parentWindow:FarmWindow = null, stage:int = 1, completeCallback:Function = null)
      {
         var task:FarmTask = null;
         super(element,quest,parentWindow,stage);
         this.m_completeCallback = completeCallback;
         this.m_completeBtn = addWidget(new FarmAnimatedCashButton(m_element.buy_bt,ZLocUtils.t("Dialogs","CompleteNowCamel"),"00",this.onCompleteNowCallback,false,false,true)) as FarmAnimatedCashButton;
         if(m_element.hasOwnProperty("prizeIcon_mc"))
         {
            addWidget(new ZwBaseWidget(m_element.prizeIcon_mc));
            (m_element.prizeIcon_mc as MovieClip).play();
         }
         if(m_element.hasOwnProperty("progress_mc"))
         {
            addWidget(new ZwBaseWidget(m_element.progress_mc));
            this.m_progress = m_element.progress_mc;
         }
         var index:int = 1;
         for each(task in quest.farmTasks)
         {
            if(m_element[SLOT_PREFIX + index.toString()])
            {
               addWidget(new MultiCollectItemSlot(m_element[SLOT_PREFIX + index.toString()],task,this,index,m_stage));
            }
            index++;
         }
         this.refresh();
      }
      
      public function refresh() : void
      {
         var task:FarmTask = null;
         var allComplete:Boolean = true;
         var required:int = 0;
         var progress:int = 0;
         this.m_completeCost = 0;
         for each(task in m_farmQuest.farmTasks)
         {
            required += task.total;
            progress += task.progress;
            if(!task.isComplete())
            {
               allComplete = false;
               this.m_completeCost += task.cashValue;
            }
         }
         this.m_completeBtn.setAmountText(String(this.m_completeCost));
         if(Boolean(this.m_progress) && required > 0)
         {
            this.m_progress.gotoAndStop(Math.floor(progress * 100 / required));
         }
         if(allComplete)
         {
            this.onComplete();
         }
      }
      
      protected function onCompleteNowCallback(event:Event) : void
      {
         var index:int = 0;
         var task:FarmTask = null;
         var canBuy:Boolean = Global.player.canBuyCash(this.m_completeCost,true);
         if(canBuy)
         {
            index = 0;
            Global.player.cash -= this.m_completeCost;
            for each(task in m_farmQuest.farmTasks)
            {
               if(!task.isComplete())
               {
                  TransactionManager.addTransaction(new TSkipQuestTask(m_farmQuest.name,index));
               }
               index++;
            }
            TransactionManager.sendAllTransactions(true);
            this.onComplete();
         }
      }
      
      protected function onComplete() : void
      {
         if(m_parentWindow)
         {
            m_parentWindow.close();
         }
         if(this.m_completeCallback != null)
         {
            this.m_completeCallback();
         }
      }
   }
}

