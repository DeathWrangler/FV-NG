package Widgets.Windows.Quests.MultiStageQuests
{
   import Classes.Quest.FarmQuest;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Transactions.Quests.TSkipQuestTask;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class StageWaitingWidget extends AbstractStageWidget
   {
      
      private var m_completeNowButton:FarmAnimatedCashButton;
      
      private var m_completeCallback:Function;
      
      public function StageWaitingWidget(element:DisplayObject, quest:FarmQuest, parentWindow:FarmWindow = null, stage:int = 1, completeCallback:Function = null)
      {
         super(element,quest,parentWindow,stage);
         this.m_completeNowButton = addWidget(new FarmAnimatedCashButton(m_element.buy_bt,ZLocUtils.t("Quests",m_farmQuest.textBundle + "_SkipButton"),"00",this.onCompleteNowClick,false,false,true)) as FarmAnimatedCashButton;
         this.m_completeNowButton.setAmountText(String(m_farmQuest.farmTasks[0].cashValue));
         this.m_completeCallback = completeCallback;
         var parent:MultiStageQuestDialog = m_parentWindow as MultiStageQuestDialog;
         if(Boolean(parent && parent.isTemplateUIEnabled() && parent.animatedScene) && Boolean(m_element) && Boolean(m_element["animation_mc"]))
         {
            addWidget(new FarmIcon(m_element.animation_mc,parent.animatedScene));
         }
         if(m_element.hasOwnProperty("waitIcon_mc" + (stage + 1)))
         {
            addWidget(new ZwBaseWidget(m_element["waitIcon_mc" + (stage + 1)]));
         }
      }
      
      private function onCompleteNowClick(event:Event) : void
      {
         var cash:int = m_farmQuest.farmTasks[0].cashValue;
         if(Global.player.canBuyCash(cash))
         {
            Global.player.cash -= cash;
            TransactionManager.addTransaction(new TSkipQuestTask(m_farmQuest.name,0),true);
            this.m_completeNowButton.enabled = false;
         }
      }
      
      override public function release() : void
      {
         super.release();
         this.m_completeCallback = null;
         this.m_completeNowButton = null;
      }
   }
}

