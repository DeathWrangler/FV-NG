package Widgets.Frames
{
   import Classes.Quest.FarmTask;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmRunQuestManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.FarmRunQuestTaskSlot;
   import Widgets.Windows.FarmRunQuestWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class FarmRunQuestTaskFrame extends GenericSlotContainerFrame
   {
      
      private var m_owner:FarmRunQuestWindow;
      
      private var m_featureName:String;
      
      private var m_skipallbutton:FarmAnimatedCashButton;
      
      private var m_skipToNextStagebutton:FarmAnimatedCashButton;
      
      public function FarmRunQuestTaskFrame(element:DisplayObject, owner:FarmRunQuestWindow, featureName:String)
      {
         this.m_owner = owner;
         var items:Array = new Array();
         this.m_featureName = featureName;
         super(element,FarmRunQuestTaskSlot,items,this.m_owner);
         if(m_element.hasOwnProperty("taskTitle_tf"))
         {
            m_element.taskTitle_tf.text = ZLocUtils.t("Dialogs","ofquest-01_stage" + FarmRunQuestManager.getInstance().getCurrentStage().toString() + "_Title");
            m_element.taskTitle_tf.visible = true;
         }
         if(FarmRunQuestManager.getInstance().isFeatureReplayed() == false)
         {
            if(m_element.hasOwnProperty("buy_bt"))
            {
               this.m_skipallbutton = addWidget(new FarmAnimatedCashButton(m_element.buy_bt,"Buy All","",this.onSkipAllTasksWithFCClick),true) as FarmAnimatedCashButton;
            }
         }
         else
         {
            if(m_element.hasOwnProperty("buyReplay_bt"))
            {
               this.m_skipallbutton = addWidget(new FarmAnimatedCashButton(m_element.buyReplay_bt,"Buy All","",this.onSkipAllTasksWithFCClick),true) as FarmAnimatedCashButton;
            }
            if(m_element.hasOwnProperty("skipStage_bt"))
            {
               this.m_skipToNextStagebutton = addWidget(new FarmAnimatedCashButton(m_element.skipStage_bt,"Skip Stage","",this.onSkipAllTasksWithoutFCClick),true) as FarmAnimatedCashButton;
            }
         }
         this.setSkipAllCost();
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new FarmRunQuestTaskSlot(slotElement,this.m_owner,this.m_featureName);
      }
      
      private function onSkipAllTasksClick(e:Event) : void
      {
         FarmRunQuestManager.getInstance().skipAllTasks();
      }
      
      private function onSkipAllTasksWithFCClick(e:Event) : void
      {
         var message:String = null;
         var replayPrompt:GenericPopup = null;
         var skipAllCash:int = FarmRunQuestManager.getInstance().getSkipAllCashValue();
         if(skipAllCash > 0 && Global.player.canBuyCash(skipAllCash))
         {
            FarmRunQuestManager.getInstance().closeFarmRunQuestUI();
            message = "Hey Farmer! Are you sure you want to spend " + skipAllCash + " Farm Cash to skip to the next stage of the DreamCatcher\'s Trail?";
            replayPrompt = new GenericPopup(message,GenericPopup.TYPE_YESNO,this.onSkipAllTasksWithFCClickQuestPrompt);
            if(replayPrompt)
            {
               TransactionManager.sendAllTransactions(true);
               UI.displayPopup(replayPrompt);
               FarmStatsManager.count("farmrun_onSkipAllTasksWithFCClick","dialog_impressions");
            }
         }
      }
      
      private function onSkipAllTasksWithFCClickQuestPrompt(event:GenericPopupEvent) : void
      {
         if(Boolean(event) && event.button == GenericPopup.ACCEPT)
         {
            FarmStatsManager.count("farmrun_onSkipAllTasksWithFCClick","dialog_clicks","click_accept");
            FarmRunQuestManager.getInstance().skipAllTasks();
         }
         else
         {
            FarmRunQuestManager.getInstance().openFarmRunQuestUI();
            FarmStatsManager.count("farmrun_onSkipAllTasksWithFCClick","dialog_clicks","click_close");
         }
      }
      
      private function onSkipAllTasksWithoutFCClick(e:Event) : void
      {
         FarmRunQuestManager.getInstance().closeFarmRunQuestUI();
         var message:String = "Do you want to skip to next stage of the DreamCatcher\'s Trail?";
         var replayPrompt:GenericPopup = new GenericPopup(message,GenericPopup.TYPE_YESNO,this.onSkipAllTasksWithoutFCClickQuestPrompt);
         if(replayPrompt)
         {
            TransactionManager.sendAllTransactions(true);
            UI.displayPopup(replayPrompt);
            FarmStatsManager.count("farmrun_onSkipAllTasksWithoutFCClick","dialog_impressions");
         }
      }
      
      private function onSkipAllTasksWithoutFCClickQuestPrompt(event:GenericPopupEvent) : void
      {
         if(Boolean(event) && event.button == GenericPopup.ACCEPT)
         {
            FarmStatsManager.count("farmrun_onSkipAllTasksWithoutFCClick","dialog_clicks","click_accept");
            FarmRunQuestManager.getInstance().skipAllTasksWithoutReward();
         }
         else
         {
            FarmRunQuestManager.getInstance().openFarmRunQuestUI();
            FarmStatsManager.count("farmrun_onSkipAllTasksWithoutFCClick","dialog_clicks","click_close");
         }
      }
      
      override protected function getSlotPrefix() : String
      {
         return "giftPanel";
      }
      
      override protected function getSlotPostfix() : String
      {
         return "";
      }
      
      public function setSkipAllCost() : void
      {
         var skipAllCash:int = FarmRunQuestManager.getInstance().getSkipAllCashValue();
         if(this.m_skipallbutton)
         {
            this.m_skipallbutton.setAmountText(skipAllCash.toString());
         }
      }
      
      override protected function setupData() : void
      {
         var questTasks1:Vector.<FarmTask> = null;
         m_slotData = [];
         questTasks1 = FarmRunQuestManager.getInstance().getTasks();
         for(var i:int = 0; i < questTasks1.length; i++)
         {
            m_slotData.push({
               "questTaskSlotNumber":i,
               "questTask":questTasks1[i],
               "questType":questTasks1[i].action,
               "questText":questTasks1[i].titleText,
               "helperText":questTasks1[i].helperText,
               "taskType":questTasks1[i].helperType,
               "skipCashValue":questTasks1[i].skipCashValue
            });
         }
      }
      
      override public function release() : void
      {
         this.m_featureName = null;
         this.m_skipallbutton = null;
         this.m_skipToNextStagebutton = null;
      }
   }
}

