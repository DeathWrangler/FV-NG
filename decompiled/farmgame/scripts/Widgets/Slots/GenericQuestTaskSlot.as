package Widgets.Slots
{
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmQuestSettingsInit;
   import Classes.Quest.FarmTask;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Transactions.Quests.TSkipQuestTask;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.GenericQuestWithRewardWindow;
   import ZQuest.Events.QuestEvent;
   import ZQuest.Managers.QuestManager;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class GenericQuestTaskSlot extends ZwFrame
   {
      
      private var m_task:FarmTask;
      
      private var m_parentWindow:GenericQuestWithRewardWindow;
      
      private var m_checkMark:ZwBaseWidget;
      
      private var m_helperButton:FarmAnimatedTextButton;
      
      private var m_buyButton:FarmAnimatedCashButton;
      
      private var m_counterText:ZwTextField;
      
      public function GenericQuestTaskSlot(element:DisplayObject, parentWindow:GenericQuestWithRewardWindow, task:FarmTask)
      {
         super(element);
         this.m_parentWindow = parentWindow;
         this.m_task = task;
         QuestManager.getInstance().addEventListener(QuestEvent.PROGRESS,this.onQuestUpdates);
         addWidget(new ZwTextField(m_element.title_tf,task.titleText));
         addWidget(new FarmIcon(m_element.icon_mc,task.iconUrl));
         addWidget(this.m_checkMark = new ZwBaseWidget(m_element.check_mc),false);
         var currentCount:int = this.m_task.progress;
         var total:int = task.total;
         addWidget(this.m_counterText = new ZwTextField(m_element.count_tf,currentCount + "/" + total));
         addWidget(this.m_buyButton = new FarmAnimatedCashButton(m_element.unlock_bt,ZLocUtils.t("Dialogs","Buy"),task.cashValue.toString(),this.purchaseClickCallback));
         if(task.hasHelper())
         {
            addWidget(this.m_helperButton = new FarmAnimatedTextButton(m_element.start_bt,task.helperText,this.taskHelperClickCallback));
         }
         if(task.isComplete())
         {
            this.m_buyButton.visible = false;
            if(this.m_helperButton)
            {
               this.m_helperButton.visible = false;
            }
            this.m_checkMark.visible = true;
         }
      }
      
      private function onQuestUpdates(event:QuestEvent) : void
      {
         var currentCount:int = 0;
         var total:int = 0;
         if(event.quest.name == this.m_task.questName)
         {
            currentCount = this.m_task.progress;
            total = this.m_task.total;
            if(this.m_counterText)
            {
               this.m_counterText.text = currentCount + "/" + total;
            }
         }
      }
      
      private function purchaseClickCallback(event:Event) : void
      {
         var farmQuest:FarmQuest = FarmQuestSettingsInit.getInstance().getItemByName(this.m_task.questName) as FarmQuest;
         UI.displayMessage(ZLocUtils.t("Dialogs",farmQuest.chain + "BuyConfirmPopup",{"cashQuantity":this.m_task.cashValue}),GenericPopup.TYPE_ACCEPTCANCEL,this.onConfirmBuyPopupClose,"",true);
      }
      
      private function onConfirmBuyPopupClose(event:GenericPopupEvent) : void
      {
         var cash:int = 0;
         if(event.button == GenericPopup.YES)
         {
            cash = this.m_task.cashValue;
            if(Global.player.canBuyCash(cash))
            {
               Global.player.cash -= cash;
               TransactionManager.addTransaction(new TSkipQuestTask(this.m_task.questName,this.m_task.taskIndex),true);
               if(this.m_buyButton)
               {
                  this.m_buyButton.visible = false;
               }
               if(this.m_helperButton)
               {
                  this.m_helperButton.visible = false;
               }
               if(this.m_checkMark)
               {
                  this.m_checkMark.visible = true;
               }
            }
            if(this.m_parentWindow)
            {
               this.m_parentWindow.refreshData();
            }
         }
         if(this.m_parentWindow)
         {
            this.m_parentWindow.show();
         }
      }
      
      private function taskHelperClickCallback(event:Event) : void
      {
         m_parent.close();
         this.m_task.performHelperAction();
      }
      
      override public function release() : void
      {
         this.m_checkMark = null;
         this.m_buyButton = null;
         this.m_helperButton = null;
         this.m_counterText = null;
         QuestManager.getInstance().removeEventListener(QuestEvent.PROGRESS,this.onQuestUpdates);
         super.release();
      }
   }
}

