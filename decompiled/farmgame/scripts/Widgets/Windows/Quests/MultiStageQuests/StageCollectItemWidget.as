package Widgets.Windows.Quests.MultiStageQuests
{
   import Classes.Quest.FarmQuest;
   import Engine.Managers.TransactionManager;
   import Managers.TemplateUIUtility;
   import Transactions.Quests.TSkipQuestTask;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class StageCollectItemWidget extends AbstractStageWidget
   {
      
      private static var ITEMPREFIX:String = "item";
      
      private static const TASK_INDEX:Number = 0;
      
      private var m_askForHelpBt:FarmAnimatedButton = null;
      
      private var m_completeCallback:Function;
      
      public function StageCollectItemWidget(element:DisplayObject, quest:FarmQuest, parentWindow:FarmWindow = null, stage:int = 1, completeCallback:Function = null)
      {
         var templateStageElementName:String = null;
         var itemMc:MovieClip = null;
         super(element,quest,parentWindow,stage);
         var itemIndex:Number = 1;
         var taskLength:int = m_farmQuest.farmTasks[TASK_INDEX].total;
         this.m_completeCallback = completeCallback;
         var parent:MultiStageQuestDialog = m_parentWindow as MultiStageQuestDialog;
         var counterTextField:ZwTextField = addWidget(new ZwTextField(m_element.counter_tf,m_farmQuest.farmTasks[TASK_INDEX].progress.toString() + "/" + m_farmQuest.farmTasks[TASK_INDEX].total.toString())) as ZwTextField;
         if(Boolean(counterTextField && m_parentWindow) && Boolean(parent) && parent.isTemplateUIEnabled())
         {
            TemplateUIUtility.applyTextColor(counterTextField,TemplateUIUtility.ESCAPADE,parent.textColor);
            templateStageElementName = "items" + (taskLength - 1) + "_mc";
            if(m_element[templateStageElementName])
            {
               addWidget(new ZwBaseWidget(m_element[templateStageElementName]));
               while(Boolean(m_element[templateStageElementName][ITEMPREFIX + itemIndex.toString() + "_mc"]) && itemIndex <= taskLength)
               {
                  addWidget(new StageCollectItemProgressWidget(m_element[templateStageElementName][ITEMPREFIX + itemIndex.toString() + "_mc"],m_farmQuest,itemIndex));
                  itemIndex++;
               }
            }
         }
         else
         {
            while(m_element[ITEMPREFIX + itemIndex.toString() + "_mc"] != null && itemIndex <= taskLength)
            {
               itemMc = m_element[ITEMPREFIX + itemIndex.toString() + "_mc"] as MovieClip;
               addWidget(new ZwBaseWidget(itemMc));
               if(m_farmQuest.farmTasks[TASK_INDEX].progress >= itemIndex)
               {
                  itemMc.gotoAndStop(2);
               }
               else
               {
                  itemMc.gotoAndStop(1);
               }
               itemIndex++;
            }
         }
         var amountText:String = m_farmQuest.farmTasks[TASK_INDEX].cashValue.toString();
         addWidget(new FarmAnimatedCashButton(m_element.buy_bt,"Complete Now",amountText,this.onCompleteNowCallback,false,false,true));
         this.m_askForHelpBt = addWidget(new FarmAnimatedButton(m_element.ask_bt,this.onAskCallback)) as FarmAnimatedButton;
         if(m_element.hasOwnProperty("prizeIcon_mc"))
         {
            addWidget(new ZwBaseWidget(m_element.prizeIcon_mc));
            (m_element.prizeIcon_mc as MovieClip).play();
         }
         this.refreshAskButton();
      }
      
      protected function onAskCallback(event:Event) : void
      {
         if(m_farmQuest.farmTasks[TASK_INDEX].canAskForHelp())
         {
            m_farmQuest.farmTasks[TASK_INDEX].performHelperAction(null,this.refreshAskButton);
         }
         this.m_askForHelpBt.enabled = false;
      }
      
      private function refreshAskButton(resultData:Boolean = false) : void
      {
         this.m_askForHelpBt.enabled = m_farmQuest.farmTasks[TASK_INDEX].canAskForHelp();
      }
      
      protected function onCompleteNowCallback(event:Event) : void
      {
         var cash:int = m_farmQuest.farmTasks[TASK_INDEX].cashValue;
         var canBuy:Boolean = Global.player.canBuyCash(cash,true);
         if(canBuy)
         {
            Global.player.cash -= m_farmQuest.farmTasks[TASK_INDEX].cashValue;
            TransactionManager.addTransaction(new TSkipQuestTask(m_farmQuest.name,TASK_INDEX),true);
            if(m_parentWindow)
            {
               m_parentWindow.close();
            }
         }
      }
   }
}

