package Widgets.Windows.QuestManager
{
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmQuestManager;
   import Classes.Quest.FarmQuestSettingsInit;
   import Classes.util.ZLocUtils;
   import Display.Quests.QuestProgressBar;
   import Managers.FarmStatsManager;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class QMWActiveQuestSlot extends ZwSlotFrame
   {
      
      private var m_mainWindow:QuestManagerWindowV2 = null;
      
      private var m_timeLeft:ZwTextField = null;
      
      private var m_questIcon:FarmIcon = null;
      
      private var m_farmQuest:FarmQuest = null;
      
      private var m_blank:ZwFrame = null;
      
      public function QMWActiveQuestSlot(element:DisplayObject, parentWindow:QuestManagerWindowV2)
      {
         super(element);
         this.m_mainWindow = parentWindow;
         if(m_element.hasOwnProperty("timeLeft_tf"))
         {
            this.m_timeLeft = addWidget(new ZwTextField(m_element.timeLeft_tf,"")) as ZwTextField;
         }
         if(m_element.hasOwnProperty("icon_mc"))
         {
            this.m_questIcon = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
         }
         if(m_element.hasOwnProperty("none_mc"))
         {
            this.m_blank = addWidget(new ZwFrame(m_element.none_mc)) as ZwFrame;
            this.m_blank.attachTooltip(new FarmTextTooltip(ZLocUtils.t("Dialogs","QuestManager_ActiveFrame_EmptySlotTooltip")));
         }
      }
      
      override public function release() : void
      {
         super.release();
         this.m_mainWindow = null;
         this.m_timeLeft = null;
         this.m_questIcon = null;
         this.m_farmQuest = null;
         this.m_blank = null;
      }
      
      override public function clearView() : void
      {
         super.clearView();
         this.visible = true;
         this.m_blank.visible = true;
      }
      
      override public function populate(data:Object) : void
      {
         var questName:String = null;
         var progressBar:QuestProgressBar = null;
         super.populate(data);
         questName = String(data);
         this.m_farmQuest = FarmQuestSettingsInit.getInstance().getItemByName(questName) as FarmQuest;
         if(this.m_farmQuest)
         {
            if(this.m_farmQuest.displayIcon != FarmQuest.ICON_NONE)
            {
               this.m_questIcon.loadIcon(this.m_farmQuest.displayIcon);
            }
            this.m_questIcon.visible = true;
            this.m_questIcon.registerEventListener(MouseEvent.CLICK,this.onClickIcon);
            this.m_questIcon.attachTooltip(new FarmTextTooltip(ZLocUtils.t("Dialogs",questName + "_iconTooltip")));
            this.m_blank.visible = false;
            this.m_timeLeft.text = this.m_farmQuest.getArrowExpiryString();
            this.m_timeLeft.visible = true;
            if(FarmQuestManager.getInstance().isQuestActive(this.m_farmQuest.name) && m_element.hasOwnProperty("progressbar_mc") && m_element["progressbar_mc"] != null)
            {
               progressBar = new QuestProgressBar(-23,96,0.4,0.4);
               m_element.addChild(progressBar);
               progressBar.playAnimation(this.m_farmQuest.progressByTasks,false);
            }
         }
      }
      
      private function onClickIcon(event:MouseEvent) : void
      {
         this.m_farmQuest.showProgress();
         FarmStatsManager.count("quest_manager","view",this.m_farmQuest.name);
         this.m_mainWindow.close();
      }
   }
}

