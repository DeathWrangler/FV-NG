package Widgets.Windows.QuestManager
{
   import Classes.Constants.StatsTrackingConstants;
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmQuestManager;
   import Classes.Quest.FarmQuestSettingsInit;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class QMWReplayableQuestsBaseSlot extends ZwSlotFrame
   {
      
      protected static const PROMPT_UNIQUE_NAME:String = "QMPrompt";
      
      protected var m_mainWindow:QuestManagerWindowV2 = null;
      
      protected var m_questIcon:FarmIcon = null;
      
      protected var m_farmQuest:FarmQuest = null;
      
      protected var m_blank:ZwFrame = null;
      
      protected var m_tooltipMC:ZwWidget = null;
      
      protected var m_prompt:GenericPopup = null;
      
      private var m_tooltipTitle:FarmTextField = null;
      
      private var m_tooltipBody:FarmTextField = null;
      
      protected var m_tooltipMaxActiveReplayableQuestsText:FarmTextField = null;
      
      protected var m_viewQuestButton:FarmAnimatedTextButton = null;
      
      protected var m_endQuestButton:FarmAnimatedTextButton = null;
      
      protected var m_startQuestButton:FarmAnimatedTextButton = null;
      
      public function QMWReplayableQuestsBaseSlot(element:DisplayObject, mainWindow:QuestManagerWindowV2)
      {
         this.m_mainWindow = mainWindow;
         super(element);
         if(m_element.hasOwnProperty("icon_mc"))
         {
            this.m_questIcon = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
         }
         if(m_element.hasOwnProperty("empty_mc"))
         {
            this.m_blank = addWidget(new ZwFrame(m_element.empty_mc)) as ZwFrame;
         }
         if(m_element.hasOwnProperty("tooltip_mc") && m_element["tooltip_mc"] != null)
         {
            this.m_tooltipMC = addWidget(new ZwWidget(m_element.tooltip_mc)) as ZwWidget;
            if(this.m_tooltipMC != null)
            {
               if(this.m_tooltipMC.element.hasOwnProperty("questName_tf") && this.m_tooltipMC.element["questName_tf"] != null)
               {
                  this.m_tooltipTitle = addWidget(new FarmTextField(this.m_tooltipMC.element.questName_tf)) as FarmTextField;
               }
               if(this.m_tooltipMC.element.hasOwnProperty("questCopy_tf") && this.m_tooltipMC.element["questCopy_tf"] != null)
               {
                  this.m_tooltipBody = addWidget(new FarmTextField(this.m_tooltipMC.element.questCopy_tf)) as FarmTextField;
               }
               if(this.m_tooltipMC.element.hasOwnProperty("view_bt") && this.m_tooltipMC.element["view_bt"] != null)
               {
                  this.m_viewQuestButton = addWidget(new FarmAnimatedTextButton(this.m_tooltipMC.element.view_bt,ZLocUtils.t("Dialogs","QuestManagerV2_viewquest_buttontext"),this.onViewQuestButtonClicked)) as FarmAnimatedTextButton;
               }
               if(this.m_tooltipMC.element.hasOwnProperty("end_bt") && this.m_tooltipMC.element["end_bt"] != null)
               {
                  this.m_endQuestButton = addWidget(new FarmAnimatedTextButton(this.m_tooltipMC.element.end_bt,ZLocUtils.t("Dialogs","QuestManagerV2_endquest_buttontext"),this.onEndQuestButtonClicked)) as FarmAnimatedTextButton;
               }
               if(this.m_tooltipMC.element.hasOwnProperty("start_bt") && this.m_tooltipMC.element["start_bt"] != null)
               {
                  this.m_startQuestButton = addWidget(new FarmAnimatedTextButton(this.m_tooltipMC.element.start_bt,ZLocUtils.t("Dialogs","QuestManagerV2_startquest_buttontext"),this.onStartQuestButtonClicked)) as FarmAnimatedTextButton;
               }
               if(this.m_tooltipMC.element.hasOwnProperty("error_tf") && this.m_tooltipMC.element["error_tf"] != null)
               {
                  this.m_tooltipMaxActiveReplayableQuestsText = addWidget(new FarmTextField(this.m_tooltipMC.element.error_tf,ZLocUtils.t("Dialogs","QuestManagerV2_maxactivequests_text",{"numActiveQuests":FarmQuestSettingsInit.getInstance().getMaxActiveReplayableQuests()}))) as FarmTextField;
               }
            }
         }
      }
      
      private function onStartQuestButtonClicked(event:MouseEvent) : void
      {
         if(!FarmQuestManager.getInstance().hasReachedMaxActiveReplayableQuests())
         {
            this.m_mainWindow.enableInput = false;
            this.destroyPrompt();
            this.m_prompt = UI.displayMessage(ZLocUtils.t("Dialogs","QuestManager_ReplayFrame_StartDialog_Copy"),GenericPopup.TYPE_MODAL,null,PROMPT_UNIQUE_NAME,true);
            FarmQuestManager.getInstance().prepForStartReplayableQuestChain(this.m_farmQuest.name);
            TransactionManager.addTransaction(new TGenericTransaction("FarmQuestService","questManagerStartReplayableQuestChain",this.onFinishStartReplayableQuestTransaction,[this.m_farmQuest.name]));
            FarmStatsManager.count(StatsTrackingConstants.QUEST_MANAGER,StatsTrackingConstants.START,this.m_farmQuest.name);
         }
      }
      
      private function onFinishStartReplayableQuestTransaction(result:Object) : void
      {
         this.destroyPrompt();
         this.m_mainWindow.close();
      }
      
      private function onViewQuestButtonClicked(event:Event) : void
      {
         if(this.m_farmQuest != null)
         {
            if(this.m_farmQuest.getQueuedIcon() != null)
            {
               this.m_farmQuest.getQueuedIcon().hideArrow();
            }
            this.m_farmQuest.showProgress();
            FarmStatsManager.count(StatsTrackingConstants.QUEST_MANAGER,StatsTrackingConstants.DIALOG_STATS_VIEW_PHYLUM,this.m_farmQuest.name);
            this.m_mainWindow.close();
         }
      }
      
      private function onEndQuestButtonClicked(event:Event) : void
      {
         this.m_mainWindow.enableInput = false;
         this.destroyPrompt();
         this.m_prompt = UI.displayMessage(ZLocUtils.t("Dialogs","QuestManager_ReplayFrame_EndDialog_Copy"),GenericPopup.TYPE_ACCEPTCANCEL,this.onHandleEndQuestPrompt,PROMPT_UNIQUE_NAME,true);
         this.m_prompt.setAcceptTextName("QuestManager_ReplayFrame_EndDialog_AcceptBtn");
      }
      
      private function onHandleEndQuestPrompt(event:GenericPopupEvent) : void
      {
         this.m_mainWindow.enableInput = true;
         if(event.button == GenericPopup.ACCEPT)
         {
            FarmQuestManager.getInstance().prepForEndReplayableQuestChain(this.m_farmQuest.name);
            TransactionManager.addTransaction(new TGenericTransaction("FarmQuestService","questManagerEndReplayableQuestChain",null,[this.m_farmQuest.name]));
            FarmStatsManager.count(StatsTrackingConstants.QUEST_MANAGER,StatsTrackingConstants.END,this.m_farmQuest.name);
            this.destroyPrompt();
            this.m_mainWindow.refreshWindow();
         }
      }
      
      private function destroyPrompt() : void
      {
         if(this.m_prompt != null)
         {
            this.m_prompt.close();
            this.m_prompt = null;
         }
      }
      
      override public function release() : void
      {
         super.release();
         this.m_mainWindow = null;
         this.m_questIcon = null;
         this.m_farmQuest = null;
         this.m_blank = null;
         this.m_endQuestButton = null;
         this.m_startQuestButton = null;
         this.m_viewQuestButton = null;
         this.m_prompt = null;
         this.m_tooltipBody = null;
         this.m_tooltipMaxActiveReplayableQuestsText = null;
         this.m_tooltipMC = null;
         this.m_tooltipTitle = null;
         this.unregisterEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         this.unregisterEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
      }
      
      override public function clearView() : void
      {
         super.clearView();
         this.visible = true;
         if(this.m_blank != null)
         {
            this.m_blank.visible = true;
         }
         this.unregisterEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         this.unregisterEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_farmQuest = data as FarmQuest;
         if(this.m_farmQuest != null)
         {
            if(this.m_farmQuest.displayIcon != FarmQuest.ICON_NONE)
            {
               this.m_questIcon.loadIcon(this.m_farmQuest.displayIcon);
            }
            this.m_questIcon.visible = true;
            this.registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
            this.registerEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
            this.m_tooltipTitle.text = FarmQuestManager.getInstance().getQuestChainFriendlyName(this.m_farmQuest.name);
            this.m_tooltipBody.text = this.m_farmQuest.titleText;
         }
      }
      
      protected function showTooltipButtonOrText() : void
      {
         if(FarmQuestManager.getInstance().hasReachedMaxActiveReplayableQuests())
         {
            this.m_tooltipMaxActiveReplayableQuestsText.visible = true;
         }
         else
         {
            this.m_startQuestButton.visible = true;
         }
      }
      
      protected function onMouseOver(event:MouseEvent) : void
      {
         var element:DisplayObject = m_element as DisplayObject;
         var parent:DisplayObjectContainer = element.parent as DisplayObjectContainer;
         parent.addChild(element);
         if(this.m_tooltipMC != null)
         {
            this.m_tooltipMC.visible = true;
         }
         this.m_tooltipTitle.visible = true;
         this.m_tooltipBody.visible = true;
         this.m_endQuestButton.visible = false;
         this.m_startQuestButton.visible = false;
         this.m_tooltipMaxActiveReplayableQuestsText.visible = false;
         this.m_viewQuestButton.visible = false;
      }
      
      protected function onMouseOut(event:MouseEvent) : void
      {
         if(this.m_tooltipMC != null)
         {
            this.m_tooltipMC.visible = false;
         }
      }
   }
}

