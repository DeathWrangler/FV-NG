package Classes.Quest.skipactions
{
   import Classes.Quest.FarmQuestManager;
   import Classes.Quest.FarmTask;
   import Classes.util.ZLocUtils;
   import Display.Dialogs.GenericDialog;
   import Display.Quests.QuestProgressDialog;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Transactions.Quests.TSkipQuestTask;
   import ZQuest.Events.QuestEvent;
   import com.troyer.widget.view.TextFieldView;
   import flash.events.Event;
   
   public class QuestSkipAction
   {
      
      private static const PREREQ_FRICTIONLESS_QUEST_DISABLE_NON_PAYER:String = "quest_1clickpurchase_disable_non_payer";
      
      protected var m_cost:int = 0;
      
      protected var m_questName:String = "";
      
      protected var m_taskIndex:int = 0;
      
      protected var m_dialog:QuestProgressDialog = null;
      
      protected var m_skipConfDialog:GenericDialog = null;
      
      public function QuestSkipAction(cost:int, questName:String, taskIndex:int, dialog:QuestProgressDialog)
      {
         super();
         this.m_cost = cost;
         this.m_questName = questName;
         this.m_taskIndex = taskIndex;
         this.m_dialog = dialog;
      }
      
      public function perform() : void
      {
         this.m_skipConfDialog = UI.showMessage("",UI.BUTTON_LAYOUT_YES_NO,null,null,false,this.onClickAcceptPopup);
         this.m_skipConfDialog.setShortcutAttribute("bodyText",TextFieldView.ATTRIBUTE_ALIGN,"center");
         this.m_skipConfDialog.setShortcutAttribute("bodyText",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Quests","SkipTaskConfirmText",{"quantity":this.m_cost}));
         if(this.m_dialog)
         {
            this.m_dialog.setSkipConfirmationDialog(this.m_skipConfDialog);
         }
      }
      
      public function onClickAcceptPopup(event:Event) : void
      {
         var task:FarmTask = null;
         var currentProgress:int = 0;
         if(this.m_questName)
         {
            task = FarmQuestManager.getInstance().getActiveQuestByName(this.m_questName).farmTasks[this.m_taskIndex];
            if(task)
            {
               currentProgress = task.progress;
            }
         }
         this.conditionallyKillParentDialog();
         if(Global.player.canBuyCash(this.m_cost,true,"quest_skip_" + this.m_questName))
         {
            TransactionManager.addTransaction(this.getTransaction(),true);
            Global.player.cash -= this.m_cost;
            if(this.m_questName)
            {
               if(task)
               {
                  FarmQuestManager.getInstance().addRewardForTask(task,currentProgress);
               }
            }
         }
      }
      
      private function conditionallyKillParentDialog() : void
      {
         if(this.m_dialog)
         {
            this.m_dialog.setSkipConfirmationDialog(null);
         }
         if(this.m_skipConfDialog != null)
         {
            this.m_skipConfDialog.destroy();
         }
         this.addQuestEventListeners();
      }
      
      private function onQuestCompleted(event:QuestEvent) : void
      {
         this.removeQuestEventListeners();
         if(this.m_dialog)
         {
            this.m_dialog.destroy();
         }
      }
      
      private function onQuestProgress(event:QuestEvent) : void
      {
         this.removeQuestEventListeners();
         if(this.m_dialog)
         {
            this.m_dialog.refreshTaskCells();
            this.m_dialog.setSkipAllPrice();
         }
      }
      
      private function addQuestEventListeners() : void
      {
         FarmQuestManager.getInstance().addEventListener(QuestEvent.COMPLETED,this.onQuestCompleted);
         FarmQuestManager.getInstance().addEventListener(QuestEvent.PROGRESS,this.onQuestProgress);
      }
      
      private function removeQuestEventListeners() : void
      {
         FarmQuestManager.getInstance().removeEventListener(QuestEvent.COMPLETED,this.onQuestCompleted);
         FarmQuestManager.getInstance().removeEventListener(QuestEvent.PROGRESS,this.onQuestProgress);
      }
      
      protected function getTransaction() : TSkipQuestTask
      {
         return new TSkipQuestTask(this.m_questName,this.m_taskIndex);
      }
   }
}

