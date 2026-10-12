package Widgets.Frames
{
   import Classes.Constants.QuestConstants;
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmTask;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.TieredQuestWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class TieredQuestTaskFrame extends ZwFrame
   {
      
      private var m_quest:FarmQuest;
      
      private var m_taskIndex:int;
      
      private var m_taskProgressTf:FarmTextField;
      
      private var m_itemTitleTf:FarmTextField;
      
      private var m_icon:FarmIcon;
      
      private var m_skipBt:FarmAnimatedCashButton;
      
      private var m_actionBt:FarmAnimatedTextButton;
      
      private var m_taskCompleteIcon:ZwWidget;
      
      private var m_window:TieredQuestWindow;
      
      public function TieredQuestTaskFrame(element:DisplayObject, quest:FarmQuest, taskIndex:int, window:TieredQuestWindow)
      {
         super(element);
         this.m_quest = quest;
         this.m_taskIndex = taskIndex;
         this.m_window = window;
         var task:FarmTask = this.m_quest.farmTasks[this.m_taskIndex];
         if(m_element.alive_tf)
         {
            this.m_taskProgressTf = addWidget(new FarmTextField(m_element.alive_tf),true) as FarmTextField;
            this.m_taskProgressTf.text = ZLocUtils.t("Dialogs","MultiTaskPRogressSlot_progress",{
               "progress":task.progress,
               "total":task.total
            });
         }
         if(m_element.itemTitle_tf)
         {
            this.m_itemTitleTf = addWidget(new FarmTextField(m_element.itemTitle_tf),true) as FarmTextField;
         }
         if(m_element.available_tf)
         {
            addWidget(new FarmTextField(m_element.available_tf),false) as FarmTextField;
         }
         if(m_element.icon)
         {
            this.m_icon = addWidget(new FarmIcon(m_element.icon,task.iconUrl),true) as FarmIcon;
         }
         if(m_element.sendMaterials_tf)
         {
            addWidget(new FarmTextField(m_element.sendMaterials_tf),false) as FarmTextField;
         }
         if(m_element.iconBox_mc)
         {
            addWidget(new ZwWidget(m_element.iconBox_mc),true);
         }
         if(m_element.buy2_bt)
         {
            addWidget(new ZwWidget(m_element.buy2_bt),false);
         }
         if(m_element.doober_mc)
         {
            addWidget(new ZwWidget(m_element.doober_mc),false);
         }
         if(m_element.fcPrice_mc)
         {
            addWidget(new ZwWidget(m_element.fcPrice_mc),false);
         }
         if(m_element.buy_bt)
         {
            this.m_skipBt = addWidget(new FarmAnimatedCashButton(m_element.buy_bt,ZLocUtils.t("Dialogs","Skip"),"",this.onSkipTaskClick),true) as FarmAnimatedCashButton;
         }
         if(m_element.use_mat_bt)
         {
            addWidget(new ZwWidget(m_element.use_mat_bt),false);
         }
         if(m_element.use_bt)
         {
            addWidget(new ZwWidget(m_element.use_bt),false);
         }
         if(m_element.completeNow_bt)
         {
            addWidget(new ZwWidget(m_element.completeNow_bt),false);
         }
         if(m_element.present_bt)
         {
            addWidget(new ZwWidget(m_element.present_bt),false);
         }
         if(m_element.getThis_bt)
         {
            this.m_actionBt = addWidget(new FarmAnimatedTextButton(m_element.getThis_bt,"",this.onActionClick),true) as FarmAnimatedTextButton;
         }
         if(m_element.completeIcon_mc)
         {
            this.m_taskCompleteIcon = addWidget(new ZwWidget(m_element.completeIcon_mc),false) as ZwWidget;
         }
      }
      
      private function onSkipTaskClick(ev:Event = null) : void
      {
         var task:FarmTask = this.m_quest.farmTasks[this.m_taskIndex];
         if(task)
         {
            task.skip(null);
         }
      }
      
      private function onActionClick(ev:Event = null) : void
      {
         var task:FarmTask = this.m_quest.farmTasks[this.m_taskIndex];
         if(task)
         {
            task.performHelperAction(null,this.onAskFeedPosted);
         }
         if(task.action == QuestConstants.TASK_USE_ITEM_BY_CODE)
         {
            this.m_actionBt.enabled = false;
            this.m_actionBt.text = ZLocUtils.t("Quests","Helper_AskForHelp_InProgress");
         }
         else
         {
            this.m_window.close();
         }
      }
      
      private function onAskFeedPosted(success:Boolean) : void
      {
         var task:FarmTask = this.m_quest.farmTasks[this.m_taskIndex];
         if(Boolean(this.m_actionBt) && Boolean(task))
         {
            if(task.canAskForHelp())
            {
               this.m_actionBt.enabled = true;
               this.m_actionBt.text = ZLocUtils.t("Quests","Helper_AskForHelp_Button");
            }
            else
            {
               this.m_actionBt.enabled = false;
               this.m_actionBt.text = ZLocUtils.t("Quests","Helper_AskForHelp_Sent");
            }
         }
      }
      
      public function refreshUI() : void
      {
         var task:FarmTask = null;
         if(m_element)
         {
            task = this.m_quest.farmTasks[this.m_taskIndex];
            if(task)
            {
               this.m_itemTitleTf.text = task.titleText;
               this.m_actionBt.text = task.helperText;
               this.m_skipBt.setAmountText(task.cashValue.toString());
               this.m_taskProgressTf.text = ZLocUtils.t("Dialogs","MultiTaskPRogressSlot_progress",{
                  "progress":task.progress,
                  "total":task.total
               });
               if(task.isComplete() || !task.hasHelper())
               {
                  this.m_actionBt.visible = false;
               }
               else
               {
                  this.m_actionBt.visible = true;
                  this.m_actionBt.enabled = true;
                  if(task.action == QuestConstants.TASK_USE_ITEM_BY_CODE && !task.canAskForHelp())
                  {
                     this.m_actionBt.enabled = false;
                  }
               }
               if(task.isComplete())
               {
                  this.m_skipBt.visible = false;
                  this.m_taskCompleteIcon.visible = true;
               }
               else
               {
                  this.m_skipBt.visible = true;
                  this.m_taskCompleteIcon.visible = false;
               }
            }
         }
      }
   }
}

