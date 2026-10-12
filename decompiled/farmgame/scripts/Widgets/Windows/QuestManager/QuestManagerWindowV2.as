package Widgets.Windows.QuestManager
{
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmQuestManager;
   import Classes.Quest.FarmQuestSettingsInit;
   import Classes.util.ZLocUtils;
   import Managers.QuestManagerDisplay;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmTabButton;
   import Widgets.Core.Constants.ZwToggleState;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Windows.FarmWindow;
   import ZQuest.Classes.Quest;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.utils.Dictionary;
   
   public class QuestManagerWindowV2 extends FarmWindow
   {
      
      public static const QUEST_MANAGER_V2_VIEWED:String = "QUEST_MANAGER_V2_VIEWED";
      
      private static const ASSET_PATH:String = "assets/dialogs/FV_questManager3.swf";
      
      private var m_tutorial:MovieClip = null;
      
      private var m_activeQuestsSlotFrame:QMWActiveQuestsSlotFrame = null;
      
      private var m_currentlyVisibleReplayableQuestsFrame:FarmSlotContainerFrame = null;
      
      private var m_currentlySelectedReplayableQuestsButton:FarmTabButton = null;
      
      private var m_activeReplayableQuestsFrame:QMWReplayableQuestsActiveSlotFrame = null;
      
      private var m_newReplayableQuestsFrame:QMWReplayableQuestsNewSlotFrame = null;
      
      private var m_completedReplayableQuestsFrame:QMWReplayableQuestsCompletedSlotFrame = null;
      
      private var m_activeReplayableQuestsButton:FarmTabButton = null;
      
      private var m_newReplayableQuestsButton:FarmTabButton = null;
      
      private var m_completedReplayableQuestsButton:FarmTabButton = null;
      
      private var m_isMOTDFlow:Boolean;
      
      private var m_activeQuestsStandard:Dictionary = new Dictionary();
      
      public function QuestManagerWindowV2(isMOTDFlow:Boolean = false)
      {
         super(ASSET_PATH,true,true);
         this.m_isMOTDFlow = isMOTDFlow;
      }
      
      override protected function postLoadComplete() : void
      {
         if(m_window.hasOwnProperty("title_tf") && m_window["title_tf"] != null)
         {
            addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","QuestManager_Title")));
         }
         if(m_window.hasOwnProperty("whatisthis_mc") && m_window["whatisthis_mc"] != null)
         {
            addWidget(new FarmAnimatedTextButton(m_window.whatisthis_mc,ZLocUtils.t("Dialogs","HowDoesThisWork"),this.howDoesThisWorkClick));
         }
         if(m_window.hasOwnProperty("tutorial_mc") && m_window["tutorial_mc"] != null)
         {
            this.m_tutorial = m_window.tutorial_mc as MovieClip;
         }
         if(m_window.hasOwnProperty("quests_mc") && m_window["quests_mc"] != null)
         {
            this.m_activeQuestsSlotFrame = addWidget(new QMWActiveQuestsSlotFrame(m_window.quests_mc,this)) as QMWActiveQuestsSlotFrame;
         }
         if(m_window.hasOwnProperty("tab0_mc") && m_window["tab0_mc"] != null)
         {
            this.m_activeReplayableQuestsButton = new FarmTabButton(m_window.tab0_mc,ZLocUtils.t("Dialogs","QuestManagerV2_replayableActiveQuestsButtonText"),this.onReplayableQuestsActiveButtonClicked);
            addWidget(this.m_activeReplayableQuestsButton);
         }
         if(m_window.hasOwnProperty("tab1_mc") && m_window["tab1_mc"] != null)
         {
            this.m_newReplayableQuestsButton = new FarmTabButton(m_window.tab1_mc,ZLocUtils.t("Dialogs","QuestManagerV2_replayableNewQuestsButtonText"),this.onReplayableQuestsNewButtonClicked);
            addWidget(this.m_newReplayableQuestsButton);
         }
         if(m_window.hasOwnProperty("tab2_mc") && m_window["tab2_mc"] != null)
         {
            this.m_completedReplayableQuestsButton = new FarmTabButton(m_window.tab2_mc,ZLocUtils.t("Dialogs","QuestManagerV2_replayableCompletedQuestsButtonText"),this.onReplayableQuestsCompletedButtonClicked);
            addWidget(this.m_completedReplayableQuestsButton);
         }
         if(m_window.hasOwnProperty("questsActive_mc") && m_window["questsActive_mc"] != null)
         {
            this.m_activeReplayableQuestsFrame = new QMWReplayableQuestsActiveSlotFrame(m_window.questsActive_mc,this);
            addWidget(this.m_activeReplayableQuestsFrame);
            this.m_activeReplayableQuestsFrame.visible = false;
         }
         if(m_window.hasOwnProperty("questsNew_mc") && m_window["questsNew_mc"] != null)
         {
            this.m_newReplayableQuestsFrame = new QMWReplayableQuestsNewSlotFrame(m_window.questsNew_mc,this);
            addWidget(this.m_newReplayableQuestsFrame);
            this.m_newReplayableQuestsFrame.visible = false;
         }
         if(m_window.hasOwnProperty("questsCompleted_mc") && m_window["questsCompleted_mc"] != null)
         {
            this.m_completedReplayableQuestsFrame = new QMWReplayableQuestsCompletedSlotFrame(m_window.questsCompleted_mc,this);
            addWidget(this.m_completedReplayableQuestsFrame);
            this.m_completedReplayableQuestsFrame.visible = false;
         }
         var numTimesSeen:int = Global.player.getActionCount(QUEST_MANAGER_V2_VIEWED);
         var actionCountLimit:int = int(Global.flashHotParams[QUEST_MANAGER_V2_VIEWED]);
         if(this.m_isMOTDFlow || numTimesSeen < actionCountLimit)
         {
            this.setNewSelectedButton(this.m_newReplayableQuestsButton);
            this.setNewActiveFrame(this.m_newReplayableQuestsFrame);
            Global.player.setActionCount(QUEST_MANAGER_V2_VIEWED,actionCountLimit,true);
         }
         else
         {
            this.setNewSelectedButton(this.m_activeReplayableQuestsButton);
            this.setNewActiveFrame(this.m_activeReplayableQuestsFrame);
         }
      }
      
      public function get activeQuestsStandard() : Dictionary
      {
         return this.m_activeQuestsStandard;
      }
      
      private function howDoesThisWorkClick(event:Event = null) : void
      {
         if(this.m_tutorial)
         {
            this.m_tutorial.visible = true;
            this.m_tutorial.gotoAndPlay(2);
         }
      }
      
      override public function close() : void
      {
         super.close();
         QuestManagerDisplay.getInstance().releaseWindow();
      }
      
      override protected function onShow() : void
      {
         this.refreshWindow();
      }
      
      override public function refreshWindow() : void
      {
         this.gatherActiveQuestData();
         if(this.m_activeQuestsSlotFrame != null)
         {
            this.m_activeQuestsSlotFrame.forceRefresh();
         }
         if(this.m_activeReplayableQuestsFrame != null)
         {
            this.m_activeReplayableQuestsFrame.refresh();
         }
         if(this.m_newReplayableQuestsFrame != null)
         {
            this.m_newReplayableQuestsFrame.refresh();
         }
         if(this.m_completedReplayableQuestsFrame != null)
         {
            this.m_completedReplayableQuestsFrame.refresh();
         }
      }
      
      private function setNewSelectedButton(newSelectedButton:FarmTabButton) : void
      {
         if(newSelectedButton != null)
         {
            if(this.m_currentlySelectedReplayableQuestsButton != null)
            {
               this.m_currentlySelectedReplayableQuestsButton.setToggleState(ZwToggleState.DESELECTED);
            }
            this.m_currentlySelectedReplayableQuestsButton = newSelectedButton;
            this.m_currentlySelectedReplayableQuestsButton.setToggleState(ZwToggleState.SELECTED);
         }
      }
      
      private function setNewActiveFrame(newActiveFrame:FarmSlotContainerFrame) : void
      {
         if(newActiveFrame != null)
         {
            if(this.m_currentlyVisibleReplayableQuestsFrame != null)
            {
               this.m_currentlyVisibleReplayableQuestsFrame.visible = false;
            }
            this.m_currentlyVisibleReplayableQuestsFrame = newActiveFrame;
            this.m_currentlyVisibleReplayableQuestsFrame.visible = true;
         }
      }
      
      private function onReplayableQuestsActiveButtonClicked(event:Event) : void
      {
         this.onReplayableQuestsButtonClickedHelper(this.m_activeReplayableQuestsButton,this.m_activeReplayableQuestsFrame);
      }
      
      private function onReplayableQuestsNewButtonClicked(event:Event = null) : void
      {
         this.onReplayableQuestsButtonClickedHelper(this.m_newReplayableQuestsButton,this.m_newReplayableQuestsFrame);
      }
      
      private function onReplayableQuestsCompletedButtonClicked(event:Event) : void
      {
         this.onReplayableQuestsButtonClickedHelper(this.m_completedReplayableQuestsButton,this.m_completedReplayableQuestsFrame);
      }
      
      private function onReplayableQuestsButtonClickedHelper(clickedButton:FarmTabButton, frameToShow:QMWReplayableQuestsBaseSlotFrame) : void
      {
         this.setNewSelectedButton(clickedButton);
         this.setNewActiveFrame(frameToShow);
      }
      
      public function showNewReplayableQuestsFrame() : void
      {
         this.onReplayableQuestsNewButtonClicked();
      }
      
      private function gatherActiveQuestData() : void
      {
         var farmQuest:FarmQuest = null;
         var farmQuestSettingsInit:FarmQuestSettingsInit = FarmQuestSettingsInit.getInstance();
         var farmQuestManager:FarmQuestManager = FarmQuestManager.getInstance();
         var activeQuests:Vector.<Quest> = farmQuestManager.getActiveQuests();
         this.m_activeQuestsStandard = new Dictionary();
         var tmpReplayableHashByChainName:Array = new Array();
         var tmpActiveHashByChainName:Array = new Array();
         for each(farmQuest in activeQuests)
         {
            if(farmQuestSettingsInit.questManagerQuestChainCacheContains(farmQuest.name))
            {
               if(farmQuest.progress >= 1 && farmQuest.children.length == 0)
               {
                  farmQuestManager.removeActiveQuestByName(farmQuest.name);
               }
               else if(!tmpReplayableHashByChainName.hasOwnProperty(farmQuest.chain))
               {
                  tmpReplayableHashByChainName[farmQuest.chain] = farmQuest;
               }
               else if(farmQuest.questNumber > tmpReplayableHashByChainName[farmQuest.chain].questNumber)
               {
                  farmQuestManager.removeActiveQuestByName((tmpReplayableHashByChainName[farmQuest.chain] as FarmQuest).name);
                  tmpReplayableHashByChainName[farmQuest.chain] = farmQuest;
               }
               else if(farmQuest.questNumber <= tmpReplayableHashByChainName[farmQuest.chain].questNumber)
               {
                  farmQuestManager.removeActiveQuestByName(farmQuest.name);
               }
            }
            else if(!tmpActiveHashByChainName.hasOwnProperty(farmQuest.chain) || farmQuest.questNumber > tmpActiveHashByChainName[farmQuest.chain].questNumber)
            {
               tmpActiveHashByChainName[farmQuest.chain] = farmQuest;
            }
         }
         for each(farmQuest in tmpActiveHashByChainName)
         {
            this.m_activeQuestsStandard[farmQuest.name] = farmQuest;
         }
      }
   }
}

