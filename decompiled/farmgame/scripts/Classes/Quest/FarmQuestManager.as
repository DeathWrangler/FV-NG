package Classes.Quest
{
   import Classes.Constants.ArrowType;
   import Classes.Constants.Experiments;
   import Classes.Constants.PrerequisiteConstants;
   import Classes.Constants.QuestConstants;
   import Classes.Friend;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.UserRewardUtil;
   import Classes.util.ZLocUtils;
   import DataSources.BaseDataSource;
   import Display.Dialogs.GenericDialog;
   import Display.Dialogs.GenericDialogConfig;
   import Display.FarmDynamicDialog;
   import Display.GenericPopup;
   import Display.QueuedIcons.QuestQueuedIcon;
   import Display.UI;
   import Engine.Events.TransactionEvent;
   import Engine.Init.InitializationManager;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.TransactionManager;
   import Engine.Transactions.Transaction;
   import Events.GenericPopupEvent;
   import Init.PostInitActionHandlers.PostInitFunctionCall;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.JournalManager;
   import Managers.ReturningUserExperienceManager;
   import Transactions.Quests.TFullQuestRefresh;
   import Transactions.Quests.TKillQuest;
   import Transactions.Quests.TPauseQuest;
   import Transactions.Quests.TReplayQuestChapter;
   import Transactions.TFarmTransaction;
   import Transactions.TRefreshGifts;
   import Transactions.TWorldLoad;
   import Widgets.Windows.Quests.QuestRewardWindowFor30DayQuest;
   import Widgets.Windows.Quests.TieredQuestRewardWindow;
   import ZQuest.Classes.Quest;
   import ZQuest.Events.QuestEvent;
   import ZQuest.Init.QuestSettingsInit;
   import ZQuest.Managers.QuestManager;
   import com.troyer.widget.view.TextFieldView;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import gs.TweenLite;
   
   public class FarmQuestManager extends QuestManager
   {
      
      public static const NO_TASK_COMPLETED:int = -1;
      
      private static var m_instance:FarmQuestManager = null;
      
      public static const CAN_HELP:int = 0;
      
      public static const CAN_SEND:int = 1;
      
      public static const WAIT_HELP:int = 2;
      
      public static const WAIT_SEND:int = 3;
      
      public static const CANT_HELP:int = 4;
      
      public static const CANT_SEND:int = 5;
      
      public static const SECOND_CHAPTER_SUFFIX:String = "-02-001";
      
      public static const SKIP_QUEST_COPY:String = "QuestManager_ReplayFrame_SkipDialog_Copy";
      
      public static const SKIP_QUEST_ACCEPT_TEXT:String = "QuestManager_ReplayFrame_SkipDialog_AcceptBtn";
      
      private var m_recentlyAddedIcons:Vector.<QuestQueuedIcon> = new Vector.<QuestQueuedIcon>();
      
      private var m_skipQuestDialog:GenericDialog = null;
      
      private var m_sessionCompletedQuests:Array = [];
      
      private var m_previouslyCompletedQuests:Array = new Array();
      
      private var m_questDialogsInQueue:Array = new Array();
      
      private var m_deferredExpiredQuests:Array = new Array();
      
      private var m_startedPostInit:Boolean = false;
      
      private var m_lastCompletedFarmQuest:FarmQuest = null;
      
      protected var m_questRefreshTimer:Timer = null;
      
      private var m_completedQuestsByIcon:Object = {};
      
      private var m_showInitQuestsImmediately:Boolean = false;
      
      private var m_completedReplayableQuests:Vector.<ReplayableFarmQuestData> = new Vector.<ReplayableFarmQuestData>();
      
      public function FarmQuestManager()
      {
         super();
      }
      
      public static function getInstance() : FarmQuestManager
      {
         return QuestManager.getInstance() as FarmQuestManager;
      }
      
      public static function requestFullQuestRefresh() : void
      {
         TransactionManager.addTransaction(new TFullQuestRefresh());
      }
      
      public static function showSkipQuestConfirmation(questSkipCashCost:int, uniqueDialogName:String, callback:Function) : GenericPopup
      {
         var confirmationDialog:GenericPopup = UI.displayMessage(ZLocUtils.t("Dialogs",SKIP_QUEST_COPY,{"price":questSkipCashCost}),GenericPopup.TYPE_ACCEPTCANCEL,callback,uniqueDialogName,true,true);
         confirmationDialog.setAcceptTextName(SKIP_QUEST_ACCEPT_TEXT);
         return confirmationDialog;
      }
      
      public function get completedReplayableQuests() : Vector.<ReplayableFarmQuestData>
      {
         return this.m_completedReplayableQuests;
      }
      
      public function hasReplayableQuestBeenCompleted(questName:String) : Boolean
      {
         var replayableQuestDatum:ReplayableFarmQuestData = null;
         var result:Boolean = false;
         for each(replayableQuestDatum in this.m_completedReplayableQuests)
         {
            if(questName === replayableQuestDatum.questName)
            {
               result = true;
            }
         }
         return result;
      }
      
      public function set completedReplayableQuests(completedReplayableQuests:Vector.<ReplayableFarmQuestData>) : void
      {
         if(completedReplayableQuests == null)
         {
            completedReplayableQuests = new Vector.<ReplayableFarmQuestData>();
         }
         this.m_completedReplayableQuests = completedReplayableQuests;
      }
      
      public function isQuestActive(questName:String) : Boolean
      {
         var quest:FarmQuest = null;
         var progress:Object = null;
         var result:Boolean = false;
         var activeQuests:Vector.<Quest> = getActiveQuests();
         for each(quest in activeQuests)
         {
            if(questName == quest.name)
            {
               progress = this.getQuestProgressByName(quest.name);
               if(progress.complete == false)
               {
                  result = true;
                  break;
               }
            }
         }
         return result;
      }
      
      public function getActiveQuestByName(questName:String) : FarmQuest
      {
         var quest:FarmQuest = null;
         var result:FarmQuest = null;
         var activeQuests:Vector.<Quest> = getActiveQuests();
         for each(quest in activeQuests)
         {
            if(questName == quest.name)
            {
               result = quest;
            }
         }
         return result;
      }
      
      override public function initialize() : void
      {
         super.initialize();
         this.setupQuestListeners();
      }
      
      private function setupQuestListeners() : void
      {
         QuestManager.getInstance().addEventListener(QuestEvent.COMPLETED,this.onQuestComplete);
         QuestManager.getInstance().addEventListener(QuestEvent.EXPIRED,this.onQuestExpired);
         InitializationManager.getInstance().addEventListener(Event.COMPLETE,this.onGameInitComplete);
      }
      
      private function onGameInitComplete(event:Event) : void
      {
         InitializationManager.getInstance().removeEventListener(Event.COMPLETE,this.onGameInitComplete);
         this.questRefreshTimerInit();
      }
      
      private function questRefreshTimerInit(event:TimerEvent = null) : void
      {
         var timeDiff:int = 0;
         if(this.m_questRefreshTimer)
         {
            this.m_questRefreshTimer.stop();
            this.m_questRefreshTimer.removeEventListener(TimerEvent.TIMER,this.questRefreshTimerCallback);
            this.m_questRefreshTimer = null;
         }
         var timeStampOfNextChange:Number = (QuestSettingsInit.getInstance() as FarmQuestSettingsInit).getNextStartOrEndTimestamp();
         if(timeStampOfNextChange > 0)
         {
            timeDiff = timeStampOfNextChange - GlobalEngine.serverTime;
            if(timeDiff > 0)
            {
               this.m_questRefreshTimer = new Timer(timeDiff);
               this.m_questRefreshTimer.addEventListener(TimerEvent.TIMER,this.questRefreshTimerCallback);
               this.m_questRefreshTimer.start();
            }
         }
      }
      
      private function questRefreshTimerCallback(event:TimerEvent) : void
      {
         this.questRefreshTimerInit();
         requestFullQuestRefresh();
      }
      
      public function setPreviouslyCompletedQuests(memstoreQuestIds:Array) : void
      {
         this.m_previouslyCompletedQuests = QuestSettingsInit.getInstance().getNamedQuestsFromMemstoreIds(memstoreQuestIds,true);
      }
      
      public function isQuestComplete(name:String) : Boolean
      {
         return this.m_previouslyCompletedQuests.indexOf(name) != -1 || this.m_sessionCompletedQuests.indexOf(name) != -1;
      }
      
      public function isQuestExpired(name:String) : Boolean
      {
         var startTimePrereq:Object = null;
         var endTimePrereq:Object = null;
         var prereq:Object = null;
         var result:Boolean = false;
         var quest:FarmQuest = QuestSettingsInit.getInstance().getItemByName(name) as FarmQuest;
         if(quest)
         {
            startTimePrereq = null;
            endTimePrereq = null;
            for each(prereq in quest.prerequisites)
            {
               if(prereq.type == "start_time")
               {
                  startTimePrereq = prereq;
               }
               if(prereq.type == "end_time")
               {
                  endTimePrereq = prereq;
               }
            }
            if(PrerequisiteUtility.isPrerequisiteMet(startTimePrereq) && GlobalEngine.serverTime >= FarmGameUtil.synchronizedDateTimeToNumber(endTimePrereq.value))
            {
               result = true;
            }
         }
         else
         {
            result = true;
         }
         return result;
      }
      
      private function analyzeAndSampleError(event:TransactionEvent) : void
      {
         var sampleStr:String = GlobalEngine.getFlashVar("FLASHVAR_FARM_65294_SAMPLE") as String;
         var sampleRate:int = 0;
         try
         {
            sampleRate = parseInt(sampleStr);
         }
         catch(err:Error)
         {
            ErrorManager.addError("Error parsing FLASHVAR_FARM_65294_SAMPLE");
         }
         if(event)
         {
            if(event.transaction)
            {
               if(event.transaction.rawResult)
               {
                  if(event.transaction.rawResult.hasOwnProperty("metadata"))
                  {
                     if(event.transaction.rawResult.metadata)
                     {
                        if(event.transaction.rawResult.metadata.hasOwnProperty("QuestComponent"))
                        {
                           if(event.transaction.rawResult.metadata.QuestComponent)
                           {
                              FarmStatsManager.sample(sampleRate,"FARM-65294","should_never_happen");
                           }
                           else
                           {
                              FarmStatsManager.sample(sampleRate,"FARM-65294","null_QuestComponent");
                           }
                        }
                        else
                        {
                           FarmStatsManager.sample(sampleRate,"FARM-65294","missing_QuestComponent");
                        }
                     }
                     else
                     {
                        FarmStatsManager.sample(sampleRate,"FARM-65294","null_metadata");
                     }
                  }
                  else
                  {
                     FarmStatsManager.sample(sampleRate,"FARM-65294","missing_metadata");
                  }
               }
               else
               {
                  FarmStatsManager.sample(sampleRate,"FARM-65294","null_rawResult");
               }
            }
            else
            {
               FarmStatsManager.sample(sampleRate,"FARM-65294","null_transaction");
            }
         }
         else
         {
            FarmStatsManager.sample(sampleRate,"FARM-65294","null_event");
         }
      }
      
      override protected function onTransactionComplete(event:TransactionEvent) : void
      {
         if(Boolean(event && event.transaction && event.transaction.rawResult) && Boolean(event.transaction.rawResult.hasOwnProperty("metadata")) && Boolean(event.transaction.rawResult.metadata) && Boolean(event.transaction.rawResult.metadata.hasOwnProperty("QuestComponent")) && Boolean(event.transaction.rawResult.metadata.QuestComponent))
         {
            this.conditionallyRefreshGiftbox(event.transaction.rawResult.metadata.QuestComponent);
         }
         else
         {
            this.analyzeAndSampleError(event);
         }
         super.onTransactionComplete(event);
         if(event.transaction.isInitTransaction())
         {
            Global.postInitActionsManager.addInitAction(new PostInitFunctionCall(this.onPostTInitUser),false);
            if(GlobalEngine.isFlashVarSetAndTrue(FarmGame.OPS_FGSM_QUEST_ITEM_CAT_ENABLED_FLASH_VAR))
            {
               (QuestSettingsInit.getInstance() as FarmQuestSettingsInit).parseCategories();
            }
            else
            {
               (QuestSettingsInit.getInstance() as FarmQuestSettingsInit).forceParseCategories();
            }
            (QuestSettingsInit.getInstance() as FarmQuestSettingsInit).parseQuestManager();
         }
         else if(event.transaction is TWorldLoad)
         {
            this.handleWorldLoadQuestRefresh(event);
         }
      }
      
      public function onPostTInitUser() : void
      {
         this.m_startedPostInit = true;
         QuestManager.getInstance().addEventListener(QuestEvent.PROGRESS,this.onQuestProgress);
         this.addInitHudIcons();
         while(this.m_deferredExpiredQuests.length > 0)
         {
            dispatchEvent(new QuestEvent(QuestEvent.EXPIRED,this.m_deferredExpiredQuests.pop()));
         }
      }
      
      public function processTransactionOnServerComplete(event:TransactionEvent) : void
      {
         this.UpdateQuestsWithTransactionEvent(event);
      }
      
      override protected function onTransactionAdded(event:TransactionEvent) : void
      {
         this.UpdateQuestsWithTransactionEvent(event);
      }
      
      protected function UpdateQuestsWithTransactionEvent(event:TransactionEvent) : void
      {
         var questX:int = 0;
         var active:Object = null;
         var quest:Quest = null;
         var result:Object = null;
         if(QuestSettingsInit.getInstance().isClientPredictionEnabled)
         {
            GlobalEngine.log("QuestManager","Transaction added: " + event.transaction);
            for(questX = 0; questX < m_activeQuests.length; questX++)
            {
               active = m_activeQuests[questX];
               quest = QuestSettingsInit.getInstance().getItemByName(active.name);
               if(!(quest == null || Boolean(active.complete)))
               {
                  result = this.updateProgress(quest,active,event.transaction);
                  if(this.shouldUpdateProgressFromServerResponse(quest) == false)
                  {
                     performClientProgressUpdate(quest,active,result);
                  }
               }
            }
         }
      }
      
      private function conditionallyRefreshGiftbox(questData:Object) : void
      {
         var quest:Object = null;
         var farmQuest:FarmQuest = null;
         var task:FarmTask = null;
         var shouldRefreshGifts:Boolean = false;
         if(questData != null)
         {
            for each(quest in questData)
            {
               if(Boolean(quest) && Boolean(quest.hasOwnProperty("name")) && getQuestProgressIndexByName(quest.name) < 0)
               {
                  farmQuest = (QuestSettingsInit.getInstance() as FarmQuestSettingsInit).getItemByName(quest.name) as FarmQuest;
                  if(Boolean(farmQuest) && Boolean(farmQuest.hasOwnProperty("farmTasks")) && Boolean(farmQuest.farmTasks))
                  {
                     for each(task in farmQuest.farmTasks)
                     {
                        if(task.action == QuestConstants.TASK_USE_ITEM_BY_CODE)
                        {
                           shouldRefreshGifts = true;
                           break;
                        }
                     }
                     if(shouldRefreshGifts)
                     {
                        break;
                     }
                  }
               }
            }
         }
         if(shouldRefreshGifts)
         {
            TransactionManager.addTransaction(new TRefreshGifts(),true);
         }
      }
      
      private function handleWorldLoadQuestRefresh(event:TransactionEvent) : void
      {
         var questdata:Object = null;
         var questX:int = 0;
         var questObject:Object = null;
         var shouldRemoveQuest:Boolean = false;
         var quest:FarmQuest = null;
         var activeQuestIdx:int = 0;
         var serverProgress:Object = null;
         var taskX:int = 0;
         var currentClientProgress:int = 0;
         var progress:QuestEvent = null;
         if(Boolean(event && event.transaction && event.transaction.rawResult) && Boolean(event.transaction.rawResult.hasOwnProperty("metadata")) && Boolean(event.transaction.rawResult.metadata) && Boolean(event.transaction.rawResult.metadata.hasOwnProperty("QuestComponent")) && Boolean(event.transaction.rawResult.metadata.QuestComponent))
         {
            questdata = event.transaction.rawResult.metadata.QuestComponent;
            if(questdata != null)
            {
               for(questX = 0; questX < questdata.length; questX++)
               {
                  questObject = questdata[questX];
                  shouldRemoveQuest = questObject.hasOwnProperty("removed") && questObject.removed == true || questObject.hasOwnProperty("expired") && questObject.expired == true;
                  if(shouldRemoveQuest)
                  {
                     Global.hud.iconQueue.removeIconByName(questObject.name);
                     this.removeActiveQuestByName(questObject.name);
                  }
                  else if(!(questObject.hasOwnProperty("complete") && questObject.complete == true))
                  {
                     quest = QuestSettingsInit.getInstance().getItemByName(questObject.name) as FarmQuest;
                     if(quest)
                     {
                        activeQuestIdx = getQuestProgressIndexByName(questObject.name);
                        serverProgress = questObject.progress;
                        for(taskX = 0; taskX < quest.farmTasks.length; taskX++)
                        {
                           currentClientProgress = int(quest.farmTasks[taskX].progress);
                           if(serverProgress.hasOwnProperty(String(taskX)) && serverProgress[taskX] != currentClientProgress)
                           {
                              if(m_activeQuests.hasOwnProperty(String(activeQuestIdx)))
                              {
                                 m_activeQuests[activeQuestIdx] = questObject;
                              }
                              progress = new QuestEvent(QuestEvent.PROGRESS,quest);
                              progress.taskCompleted = taskX;
                              dispatchEvent(progress);
                           }
                        }
                     }
                  }
               }
            }
         }
      }
      
      public function removeActiveQuestByName(questName:String) : void
      {
         var tmpObj:Object = null;
         var keepers:Vector.<Object> = new Vector.<Object>();
         while(m_activeQuests.length > 0)
         {
            tmpObj = m_activeQuests.pop();
            if(tmpObj.name != questName)
            {
               keepers.push(tmpObj);
            }
         }
         m_activeQuests = keepers;
      }
      
      private function addInitHudIcons() : void
      {
         var farmQuest:FarmQuest = null;
         var quests:Vector.<Quest> = this.getActiveQuests();
         var icon:QuestQueuedIcon = null;
         for each(farmQuest in quests)
         {
            icon = farmQuest.addIconToIconQueue();
            if(icon != null)
            {
               this.m_recentlyAddedIcons.push(icon);
            }
         }
      }
      
      private function onQuestProgress(event:QuestEvent) : void
      {
         var progressedFarmQuest:FarmQuest = null;
         var icon:QuestQueuedIcon = null;
         var nextQuestProgressEvent:QuestEvent = null;
         if(Boolean(event) && Boolean(event.quest))
         {
            progressedFarmQuest = event.quest as FarmQuest;
            icon = progressedFarmQuest.onProgress();
            if(icon)
            {
               this.m_recentlyAddedIcons.push(icon);
               nextQuestProgressEvent = new QuestEvent(QuestConstants.USER_EVENT_TRY_OPEN_NEXT_QUEST_PROGRESS,progressedFarmQuest);
               dispatchEvent(nextQuestProgressEvent);
            }
            if(event.taskCompleted != NO_TASK_COMPLETED)
            {
               progressedFarmQuest.showTaskComplete(event.taskCompleted);
            }
            progressedFarmQuest.dispatchQuestEvents(QuestConstants.ON_USER_EVENT_QUEST_PROGRESS);
         }
      }
      
      private function onQuestComplete(event:QuestEvent) : void
      {
         var completedFarmQuest:FarmQuest = null;
         if(Boolean(event) && Boolean(event.quest))
         {
            completedFarmQuest = event.quest as FarmQuest;
            completedFarmQuest.removeIconFromIconQueue();
            TransactionManager.sendAllTransactions(true);
            this.m_sessionCompletedQuests.push(completedFarmQuest.name);
            UserRewardUtil.grantUserRewards(completedFarmQuest.farmRewards);
            this.onQuestCompleteConditionallyShowRewardDialog(completedFarmQuest);
            Global.world.setDefaultGameMode();
         }
      }
      
      private function onQuestCompleteConditionallyShowRewardDialog(completedFarmQuest:FarmQuest) : void
      {
         var delayRewardDialogOnNeighborFarm:Number = completedFarmQuest.delayRewardViewOnNeighborFarm;
         if((Global.worldManager.isVisitingNPC() || Global.worldManager.isVisiting()) && delayRewardDialogOnNeighborFarm > 0)
         {
            TweenLite.to(this,0,{
               "delay":delayRewardDialogOnNeighborFarm,
               "onComplete":function():void
               {
                  onQuestCompleteShowRewardDialog(completedFarmQuest);
               }
            });
         }
         else
         {
            this.onQuestCompleteShowRewardDialog(completedFarmQuest);
         }
      }
      
      private function onQuestCompleteShowRewardDialog(paramCompletedFarmQuest:FarmQuest) : void
      {
         Global.postInitActionsManager.addInitAction(new PostInitFunctionCall(this.onPostTInitUserShowReward,{"completedFarmQuest":paramCompletedFarmQuest}),false);
      }
      
      private function shouldDeferInitQuestRewardDisplay() : Boolean
      {
         var result:Boolean = false;
         if(!this.m_showInitQuestsImmediately)
         {
            result = true;
         }
         return result;
      }
      
      public function isQuestAlreadyEnqueued(farmQuest:FarmQuest) : Boolean
      {
         var iconQuests:Array = null;
         var i:int = 0;
         var testQuest:FarmQuest = null;
         var result:Boolean = false;
         var icon:String = farmQuest.displayIcon;
         if(Boolean(icon) && icon != FarmQuest.ICON_NONE)
         {
            iconQuests = this.m_completedQuestsByIcon[icon] as Array;
            if(iconQuests)
            {
               for(i = 0; i < iconQuests.length; i++)
               {
                  testQuest = iconQuests[i] as FarmQuest;
                  if(testQuest.name == farmQuest.name)
                  {
                     result = true;
                     break;
                  }
               }
            }
         }
         return result;
      }
      
      public function onPostTInitUserShowReward(params:Object) : void
      {
         var icon:String = null;
         var questIcon:QuestQueuedIcon = null;
         var completedFarmQuest:FarmQuest = params.completedFarmQuest;
         if(!this.isQuestAlreadyEnqueued(completedFarmQuest))
         {
            icon = completedFarmQuest.displayIcon;
            if(Boolean(icon && (Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_QUEST_BUBBLE_SUPPRESSION) >= Experiments.SINGLE_CONTROL_VALID_VARIANT_START || ReturningUserExperienceManager.shouldHideQuestBubble() || completedFarmQuest.icon != FarmQuest.ICON_NONE)) && Boolean(this.shouldDeferInitQuestRewardDisplay()) && completedFarmQuest.farmRewards.length == 0)
            {
               if(!this.m_completedQuestsByIcon.hasOwnProperty(icon) || !this.m_completedQuestsByIcon[icon])
               {
                  this.m_completedQuestsByIcon[icon] = [];
               }
               (this.m_completedQuestsByIcon[icon] as Array).push(completedFarmQuest);
               questIcon = Global.hud.iconQueue.getIconByImage(icon) as QuestQueuedIcon;
               if(questIcon)
               {
                  questIcon.conditionallyAttachArrow();
               }
            }
            else
            {
               this.enqueueDisplayQuestReward(completedFarmQuest);
            }
         }
      }
      
      private function enqueueDisplayQuestReward(completedFarmQuest:FarmQuest) : Boolean
      {
         var contextualQuestOpenOtherQuestDialogFixOn:Boolean = false;
         var journalManager:JournalManager = JournalManager.getInstance();
         if(Boolean(journalManager) && journalManager.isJournalActive())
         {
            journalManager.pushQuestBubble(completedFarmQuest.name);
         }
         var shownRewardDialog:Object = completedFarmQuest.showReward();
         var result:Boolean = false;
         if(shownRewardDialog != null)
         {
            UI.stopPopups(true);
            contextualQuestOpenOtherQuestDialogFixOn = Boolean(Global.flashHotParams["CONTEXTUAL_QUEST_OPEN_OTHER_QUEST_DIALOG_FIX"]);
            if(shownRewardDialog is FarmDynamicDialog)
            {
               if(!contextualQuestOpenOtherQuestDialogFixOn)
               {
                  this.m_lastCompletedFarmQuest = completedFarmQuest;
               }
               shownRewardDialog = shownRewardDialog.getView();
            }
            else if(shownRewardDialog is TieredQuestRewardWindow || shownRewardDialog is QuestRewardWindowFor30DayQuest)
            {
               this.m_lastCompletedFarmQuest = completedFarmQuest;
            }
            if(contextualQuestOpenOtherQuestDialogFixOn)
            {
               this.m_lastCompletedFarmQuest = completedFarmQuest;
            }
            (shownRewardDialog as DisplayObject).addEventListener(Event.CLOSE,this.onRewardDialogClosed);
            this.m_questDialogsInQueue.push(shownRewardDialog);
            result = true;
         }
         completedFarmQuest.dispatchQuestEvents(QuestConstants.ON_USER_EVENT_QUEST_COMPLETE);
         return result;
      }
      
      public function getIconCompletedQuests(icon:String) : Array
      {
         var result:Array = [];
         if(this.m_completedQuestsByIcon.hasOwnProperty(icon) && Boolean(this.m_completedQuestsByIcon[icon]))
         {
            result = this.m_completedQuestsByIcon[icon] as Array;
         }
         return result;
      }
      
      public function pumpIconQuestCompletionQueue(icon:String = null) : Boolean
      {
         var quest:FarmQuest = null;
         var quests:Array = this.getIconCompletedQuests(icon);
         var result:Boolean = false;
         for(var i:int = 0; i < quests.length; i++)
         {
            quest = quests[i];
            if(this.enqueueDisplayQuestReward(quest))
            {
               result = true;
            }
         }
         this.m_completedQuestsByIcon[icon] = [];
         this.m_showInitQuestsImmediately = true;
         return result;
      }
      
      public function set showInitQuestsImmediately(flag:Boolean) : void
      {
         this.m_showInitQuestsImmediately = flag;
      }
      
      private function onRewardDialogClosed(event:Event) : void
      {
         var quest:FarmQuest = null;
         var childQuest:FarmQuest = null;
         var nextQuestProgressEvent:QuestEvent = null;
         var closedDialog:DisplayObject = this.m_questDialogsInQueue.shift();
         closedDialog.removeEventListener(Event.CLOSE,this.onRewardDialogClosed);
         if(this.m_questDialogsInQueue.length == 0)
         {
            UI.stopPopups(false);
            quest = this.m_lastCompletedFarmQuest;
            if(quest != null)
            {
               childQuest = this.getFirstChildQuest(quest);
               QuestManager.getInstance().addEventListener(QuestConstants.USER_EVENT_TRY_OPEN_NEXT_QUEST_PROGRESS,this.tryOpenNextQuestProgress);
               nextQuestProgressEvent = new QuestEvent(QuestConstants.USER_EVENT_TRY_OPEN_NEXT_QUEST_PROGRESS,childQuest);
               dispatchEvent(nextQuestProgressEvent);
            }
         }
      }
      
      public function getFirstChildQuest(quest:FarmQuest) : FarmQuest
      {
         var children:Vector.<Object> = null;
         var result:FarmQuest = null;
         if(quest != null)
         {
            children = quest.children;
            if(Boolean(children && children.length != 0) && Boolean(children[0]) && Boolean(children[0].value))
            {
               result = QuestSettingsInit.getInstance().getItemByName(children[0].value) as FarmQuest;
            }
         }
         return result;
      }
      
      public function getLastQuestInList(quest:FarmQuest) : FarmQuest
      {
         var children:Vector.<Object> = null;
         var nextQuest:FarmQuest = null;
         var result:FarmQuest = null;
         if(quest != null)
         {
            children = quest.children;
            if(Boolean(children) && Boolean(children.length != 0) && Boolean(children[0].value))
            {
               nextQuest = QuestSettingsInit.getInstance().getItemByName(children[0].value) as FarmQuest;
               result = this.getLastQuestInList(nextQuest);
            }
            else
            {
               result = quest;
            }
         }
         return result;
      }
      
      private function tryOpenNextQuestProgress(event:QuestEvent) : void
      {
         var quest:FarmQuest = null;
         var lastCompletedQuestChildQuest:FarmQuest = null;
         var hoursRemaining:Number = NaN;
         var timeRemaining:String = null;
         var message:String = null;
         var replayPrompt:GenericPopup = null;
         var minutesRemaining:Number = NaN;
         var daysRemaining:Number = NaN;
         QuestManager.getInstance().removeEventListener(QuestConstants.USER_EVENT_TRY_OPEN_NEXT_QUEST_PROGRESS,this.tryOpenNextQuestProgress);
         if(event != null)
         {
            quest = event.quest as FarmQuest;
            if(quest != null)
            {
               lastCompletedQuestChildQuest = this.getFirstChildQuest(this.m_lastCompletedFarmQuest);
               if(lastCompletedQuestChildQuest != null && lastCompletedQuestChildQuest.name == quest.name)
               {
                  if(this.tryOpenSpecificQuestProgress(quest.name) == false)
                  {
                     QuestManager.getInstance().addEventListener(QuestConstants.USER_EVENT_TRY_OPEN_NEXT_QUEST_PROGRESS,this.tryOpenNextQuestProgress);
                  }
               }
            }
            else if(this.m_lastCompletedFarmQuest.timeRemaining > 0 && this.m_lastCompletedFarmQuest.replayable)
            {
               hoursRemaining = this.m_lastCompletedFarmQuest.timeRemaining / 3600;
               timeRemaining = "";
               if(hoursRemaining < 1)
               {
                  minutesRemaining = int(hoursRemaining * 60);
                  timeRemaining = ZLocUtils.t("Dialogs","TimeRemaining",{
                     "quantity":minutesRemaining,
                     "unit":ZLocUtils.tk("SocialMission","min_word","",minutesRemaining)
                  });
               }
               else if(hoursRemaining <= 24)
               {
                  timeRemaining = ZLocUtils.t("Dialogs","TimeRemaining",{
                     "quantity":int(hoursRemaining),
                     "unit":ZLocUtils.tk("SocialMission","hr_word","",int(hoursRemaining))
                  });
               }
               else
               {
                  daysRemaining = Math.round(hoursRemaining / 24);
                  timeRemaining = ZLocUtils.t("Dialogs","TimeRemaining",{
                     "quantity":int(daysRemaining),
                     "unit":ZLocUtils.tk("SocialMission","day_word","",int(daysRemaining))
                  });
               }
               message = ZLocUtils.t("Quests","ReplayQuestChain",{
                  "questTitle":this.m_lastCompletedFarmQuest.chapterTitle,
                  "timeRemaining":timeRemaining
               });
               replayPrompt = new GenericPopup(message,GenericPopup.TYPE_YESNO,this.onCloseReplayQuestPrompt);
               if(replayPrompt)
               {
                  TransactionManager.sendAllTransactions(true);
                  UI.displayPopup(replayPrompt);
                  FarmStatsManager.count("quest_replay_dialog","dialog_impressions");
               }
            }
         }
      }
      
      private function tryOpenSpecificQuestProgress(questName:String) : Boolean
      {
         var quest:FarmQuest = null;
         var result:Boolean = false;
         var numChildren:Number = this.m_activeQuests.length;
         for(var questIndex:Number = 0; questIndex < numChildren; questIndex++)
         {
            if((m_activeQuests[questIndex] as Object).hasOwnProperty("name"))
            {
               quest = QuestSettingsInit.getInstance().getItemByName(m_activeQuests[questIndex].name) as FarmQuest;
               if(Boolean(quest && quest.name == questName && this.m_sessionCompletedQuests.indexOf(quest.name) == -1) && Boolean(quest.shouldAutoShowProgress() == true) && !Global.worldManager.isVisiting())
               {
                  quest.showProgress();
                  result = true;
                  break;
               }
            }
         }
         return result;
      }
      
      private function onCloseReplayQuestPrompt(event:GenericPopupEvent) : void
      {
         if(Boolean(event) && event.button == GenericPopup.ACCEPT)
         {
            FarmStatsManager.count("quest_replay_dialog","dialog_clicks","click_replay");
            if(Boolean(this.m_lastCompletedFarmQuest) && Boolean(this.m_lastCompletedFarmQuest.name))
            {
               TransactionManager.addTransaction(new TReplayQuestChapter(this.m_lastCompletedFarmQuest.name),true);
            }
         }
         else
         {
            FarmStatsManager.count("quest_replay_dialog","dialog_clicks","click_close");
         }
      }
      
      public function hasReachedMaxActiveReplayableQuests() : Boolean
      {
         var questObject:Object = null;
         var count:int = 0;
         var questSettingsInitInst:FarmQuestSettingsInit = FarmQuestSettingsInit.getInstance();
         for each(questObject in m_activeQuests)
         {
            if(questSettingsInitInst.questManagerQuestChainCacheContains(questObject.name))
            {
               count++;
            }
         }
         return count >= questSettingsInitInst.getMaxActiveReplayableQuests();
      }
      
      public function getQuestChainFriendlyName(anyQuestNameInChain:String) : String
      {
         var result:String = "";
         var farmQuest:FarmQuest = FarmQuestSettingsInit.getInstance().getItemByName(anyQuestNameInChain) as FarmQuest;
         if(farmQuest)
         {
            result = farmQuest.chapterTitle;
         }
         return result;
      }
      
      public function canActivateReplayableQuest(quest:FarmQuest) : Boolean
      {
         var questName:String = null;
         var farmQuestSettingsInit:FarmQuestSettingsInit = null;
         var prereq:Object = null;
         var firstQuestNameInChain:String = null;
         var prereqName:String = null;
         var filteredPrereqs:Array = null;
         var result:Boolean = false;
         if(quest)
         {
            questName = quest.name;
            farmQuestSettingsInit = FarmQuestSettingsInit.getInstance();
            if(farmQuestSettingsInit.questManagerQuestChainCacheContains(questName))
            {
               prereq = null;
               firstQuestNameInChain = farmQuestSettingsInit.questManagerGetNameOfFirstQuestInReplayableChain(questName);
               prereqName = farmQuestSettingsInit.questManagerGetPrereqForReplayableQuestChain(firstQuestNameInChain);
               if(prereqName != null)
               {
                  prereq = Global.farmGameSettingsManager.getPrereqByName(prereqName);
                  if(prereq)
                  {
                     if(PrerequisiteUtility.isPrerequisiteMet(prereq))
                     {
                        result = true;
                     }
                  }
               }
               else
               {
                  result = true;
               }
               if(result != false)
               {
                  filteredPrereqs = PrerequisiteUtility.filterPrerequisitesFromVector(quest.prerequisites,[PrerequisiteConstants.PREREQUISITE_START_TIME,PrerequisiteConstants.PREREQUISITE_END_TIME],false);
                  result = PrerequisiteUtility.arePrerequisitesMet(filteredPrereqs);
               }
            }
         }
         return result;
      }
      
      public function prepForStartReplayableQuestChain(firstQuestName:String) : void
      {
         var questSettingsInitInst:FarmQuestSettingsInit = null;
         var quest:FarmQuest = null;
         var questNamesInChain:Array = null;
         var trimmedQuestsArray:Array = null;
         var questName:String = null;
         var trimmedQuestsVector:Vector.<Object> = null;
         var questObject:Object = null;
         if(Boolean(firstQuestName) && firstQuestName != "")
         {
            questSettingsInitInst = QuestSettingsInit.getInstance() as FarmQuestSettingsInit;
            quest = questSettingsInitInst.getItemByName(firstQuestName) as FarmQuest;
            if(quest)
            {
               questNamesInChain = this.questManagerGetListOfChildQuests(firstQuestName,true);
               if(questNamesInChain != null && questNamesInChain.length > 0)
               {
                  trimmedQuestsArray = new Array();
                  for each(questName in this.m_sessionCompletedQuests)
                  {
                     if(questNamesInChain.indexOf(questName) == -1)
                     {
                        trimmedQuestsArray.push(questName);
                     }
                  }
                  this.m_sessionCompletedQuests = trimmedQuestsArray;
                  trimmedQuestsVector = new Vector.<Object>();
                  for each(questObject in m_activeQuests)
                  {
                     if(questNamesInChain.indexOf(questObject.name) == -1)
                     {
                        trimmedQuestsVector.push(questObject);
                     }
                  }
                  this.m_activeQuests = trimmedQuestsVector;
               }
            }
         }
      }
      
      public function questManagerGetListOfParentQuests(questName:String, includePassedQuest:Boolean = false) : Array
      {
         var questSettingsInitInst:FarmQuestSettingsInit = null;
         var quest:FarmQuest = null;
         var newParent:String = null;
         var curQuestName:String = null;
         var listOfNamesToCheck:Array = null;
         var prereqs:Vector.<Object> = null;
         var prereqType:String = null;
         var parent:Object = null;
         var parentsList:Vector.<Object> = null;
         var prerequisite:Object = null;
         var questNamesInChain:Array = new Array();
         if(Boolean(questName) && questName != "")
         {
            if(includePassedQuest)
            {
               questNamesInChain.push(questName);
            }
            questSettingsInitInst = QuestSettingsInit.getInstance() as FarmQuestSettingsInit;
            quest = questSettingsInitInst.getItemByName(questName) as FarmQuest;
            if(quest)
            {
               newParent = null;
               curQuestName = null;
               listOfNamesToCheck = new Array();
               listOfNamesToCheck.push(questName);
               while(listOfNamesToCheck.length > 0)
               {
                  curQuestName = listOfNamesToCheck.pop();
                  quest = questSettingsInitInst.getItemByName(curQuestName) as FarmQuest;
                  if(quest)
                  {
                     parent = null;
                     parentsList = quest.parents.concat();
                     while(Boolean(parentsList) && parentsList.length > 0)
                     {
                        parent = parentsList.pop();
                        newParent = parent.value;
                        listOfNamesToCheck.push(newParent);
                        questNamesInChain.push(newParent);
                     }
                  }
               }
               prereqs = null;
               prereqType = null;
               listOfNamesToCheck = new Array();
               listOfNamesToCheck.push(questName);
               while(listOfNamesToCheck.length > 0)
               {
                  curQuestName = listOfNamesToCheck.pop();
                  quest = questSettingsInitInst.getItemByName(curQuestName) as FarmQuest;
                  if(quest)
                  {
                     prereqs = quest.prerequisites;
                     for each(prerequisite in prereqs)
                     {
                        prereqType = prerequisite[PrerequisiteConstants.KEY_TYPE];
                        if(prereqType == PrerequisiteConstants.PREREQUISITE_QUEST_COMPLETE)
                        {
                           newParent = prerequisite[PrerequisiteConstants.KEY_VALUE];
                           listOfNamesToCheck.push(newParent);
                           questNamesInChain.push(newParent);
                        }
                     }
                  }
               }
            }
         }
         return questNamesInChain;
      }
      
      public function questManagerGetListOfChildQuests(questName:String, includePassedQuest:Boolean = false) : Array
      {
         var questSettingsInitInst:FarmQuestSettingsInit = null;
         var quest:FarmQuest = null;
         var child:Object = null;
         var childName:String = null;
         var childrenList:Vector.<Object> = null;
         var childQuests:Vector.<Object> = null;
         var childQuest:Object = null;
         var questNamesInChain:Array = new Array();
         if(Boolean(questName) && questName != "")
         {
            if(includePassedQuest)
            {
               questNamesInChain.push(questName);
            }
            questSettingsInitInst = QuestSettingsInit.getInstance() as FarmQuestSettingsInit;
            quest = questSettingsInitInst.getItemByName(questName) as FarmQuest;
            if(quest)
            {
               child = null;
               childName = null;
               childrenList = quest.children.concat();
               while(childrenList.length > 0)
               {
                  child = childrenList.pop();
                  childName = child["value"];
                  if(questSettingsInitInst.questManagerQuestChainCacheContains(childName))
                  {
                     quest = questSettingsInitInst.getItemByName(childName) as FarmQuest;
                     if(quest != null)
                     {
                        questNamesInChain.push(quest.name);
                        childQuests = quest.children.concat();
                        for each(childQuest in childQuests)
                        {
                           childrenList.push(childQuest);
                        }
                     }
                  }
               }
            }
         }
         return questNamesInChain;
      }
      
      public function prepForEndReplayableQuestChain(questName:String) : void
      {
         var curName:String = null;
         var trimmedQuestsVector:Vector.<Object> = null;
         var questObject:Object = null;
         var questNamesInChain:Array = this.questManagerGetListOfChildQuests(questName,true);
         questNamesInChain = questNamesInChain.concat(this.questManagerGetListOfParentQuests(questName,false));
         if(questNamesInChain != null && questNamesInChain.length > 0)
         {
            for each(curName in questNamesInChain)
            {
               Global.hud.iconQueue.removeIconByName(curName);
            }
            trimmedQuestsVector = new Vector.<Object>();
            for each(questObject in m_activeQuests)
            {
               if(questNamesInChain.indexOf(questObject.name) == -1)
               {
                  trimmedQuestsVector.push(questObject);
               }
            }
            this.m_activeQuests = trimmedQuestsVector;
         }
      }
      
      public function onResetLastCompletedQuestChapter(questToReset:FarmQuest = null) : void
      {
         var questChainList:XMLList = null;
         var questNamesInChain:Array = null;
         var questIndex:int = 0;
         var questBubbleChainList:XMLList = null;
         var questBubbleIndex:int = 0;
         var trimmedCompletedQuests:Array = null;
         var questName:String = null;
         var newQuest:FarmQuest = null;
         var newQuestBubble:FarmQuest = null;
         if(questToReset == null)
         {
            questToReset = this.m_lastCompletedFarmQuest;
         }
         if(Boolean(questToReset) && Boolean(questToReset.name) && Boolean(questToReset.chain))
         {
            questChainList = (QuestSettingsInit.getInstance() as FarmQuestSettingsInit).getAllQuestsInChain(questToReset.chain);
            questNamesInChain = new Array();
            for(questIndex = 0; questIndex < questChainList.length(); questIndex++)
            {
               newQuest = new FarmQuest(questChainList[questIndex]);
               questNamesInChain.push(newQuest.name);
               this.removeActiveQuestByName(newQuest.name);
            }
            questBubbleChainList = (QuestSettingsInit.getInstance() as FarmQuestSettingsInit).getAllQuestsInChain(questToReset.chain + "bubble");
            for(questBubbleIndex = 0; questBubbleIndex < questBubbleChainList.length(); questBubbleIndex++)
            {
               newQuestBubble = new FarmQuest(questBubbleChainList[questBubbleIndex]);
               questNamesInChain.push(newQuestBubble.name);
               this.removeActiveQuestByName(newQuestBubble.name);
            }
            trimmedCompletedQuests = new Array();
            for each(questName in this.m_sessionCompletedQuests)
            {
               if(questNamesInChain.indexOf(questName) == -1)
               {
                  trimmedCompletedQuests.push(questName);
               }
            }
            this.m_sessionCompletedQuests = trimmedCompletedQuests;
         }
      }
      
      private function onQuestExpired(event:QuestEvent) : void
      {
         var quest:FarmQuest = event.quest as FarmQuest;
         quest.removeIconFromIconQueue(true);
         if(quest.shouldShowExpiration())
         {
            quest.showExpiration();
         }
         if(quest.shouldShowQuestRecaptureFlow())
         {
            quest.showQuestRecaptureFlow();
         }
         if(quest.category == QuestConstants.DEFER_EXPIRE_CATEGORY && !this.m_startedPostInit)
         {
            this.m_deferredExpiredQuests.push(quest);
         }
         quest.dispatchQuestEvents(QuestConstants.ON_USER_EVENT_QUEST_EXPIRE);
      }
      
      public function onQuestRewardDialogClosed() : void
      {
         this.showAddArrow();
      }
      
      private function showAddArrow() : void
      {
         var icon:QuestQueuedIcon = null;
         for each(icon in this.m_recentlyAddedIcons)
         {
            if(icon != null)
            {
               if(this.isQuestExpiringSoon(icon.quest))
               {
                  icon.attachArrow(ArrowType.ARROWEXPIRY);
               }
               else
               {
                  icon.attachArrow(ArrowType.ARROWNEW);
               }
            }
         }
      }
      
      public function canHelpFriend(friend:Friend, questChain:String, playerQuest:FarmQuest) : int
      {
         var result:int = CANT_SEND;
         var friendQuest:FarmQuest = friend.getActiveQuestByChain(questChain);
         if(friendQuest)
         {
            if(playerQuest != null && friendQuest.chapter >= playerQuest.chapter)
            {
               if(playerQuest.helpAction != null)
               {
                  if(!Global.player.w2wState.getRecentlySent(playerQuest.getW2WFeatureName(),playerQuest.getW2WFeedName(true),friend.uid))
                  {
                     result = CAN_HELP;
                  }
                  else
                  {
                     result = WAIT_HELP;
                  }
               }
               else
               {
                  result = CANT_HELP;
               }
            }
            else if(friendQuest.helpAction != null)
            {
               if(!Global.player.w2wState.getRecentlySent(friendQuest.getW2WFeatureName(),friendQuest.getW2WFeedName(false),friend.uid))
               {
                  result = CAN_SEND;
               }
               else
               {
                  result = WAIT_SEND;
               }
            }
            else
            {
               result = CANT_SEND;
            }
         }
         return result;
      }
      
      public function getActiveQuestByChain(chainName:String, friend:Friend = null) : FarmQuest
      {
         var result:FarmQuest = null;
         var quest:FarmQuest = null;
         var split:Array = null;
         var quests:Vector.<Quest> = null;
         var questIds:Array = null;
         var i:int = 0;
         if(null == friend)
         {
            quests = this.getActiveQuests();
            for(i = 0; i < quests.length; i++)
            {
               quest = quests[i] as FarmQuest;
               if(null != quest && quest.chain == chainName)
               {
                  if(this.m_sessionCompletedQuests.indexOf(quest.name) == -1)
                  {
                     result = quest;
                     break;
                  }
               }
            }
         }
         else
         {
            questIds = friend.questIds;
            if(questIds)
            {
               for(i = 0; i < questIds.length; i++)
               {
                  quest = (QuestSettingsInit.getInstance() as FarmQuestSettingsInit).getItemByCode(questIds[i]);
                  if(Boolean(quest) && quest.chain == chainName)
                  {
                     result = quest;
                     break;
                  }
               }
            }
         }
         return result;
      }
      
      override protected function updateProgress(quest:Quest, status:Object, transaction:Transaction) : Object
      {
         var numQuestTasks:int = 0;
         var newProgress:Array = null;
         var progressChange:Boolean = false;
         var taskCompletedIndex:int = 0;
         var questTaskIndex:int = 0;
         var task:FarmTask = null;
         var newTaskProgression:Number = NaN;
         var taskProgress:int = 0;
         var taskTotal:int = 0;
         var result:Object = {};
         if(transaction != null && status != null && status.expired != true && status.complete != true)
         {
            numQuestTasks = int(quest.tasks.length);
            newProgress = new Array(numQuestTasks);
            progressChange = false;
            taskCompletedIndex = NO_TASK_COMPLETED;
            for(questTaskIndex = 0; questTaskIndex < numQuestTasks; questTaskIndex++)
            {
               task = (quest as FarmQuest).farmTasks[questTaskIndex];
               if(task.action != null)
               {
                  GlobalEngine.info("QuestManager","checking quest " + quest.name + ", task action " + task.action);
                  newTaskProgression = FarmQuestUtility.getInstance().getProgression(task,transaction as TFarmTransaction,quest as FarmQuest);
                  taskProgress = task.progress;
                  taskTotal = task.total;
                  if(newTaskProgression + taskProgress > taskTotal)
                  {
                     newTaskProgression = taskTotal - taskProgress;
                  }
                  newProgress[questTaskIndex] = newTaskProgression;
                  newProgress[questTaskIndex] += status.progress[questTaskIndex];
                  if(newTaskProgression > 0)
                  {
                     progressChange = true;
                  }
                  if(status.progress[questTaskIndex] < taskTotal && newProgress[questTaskIndex] == taskTotal)
                  {
                     taskCompletedIndex = questTaskIndex;
                  }
               }
            }
            status.progress = newProgress;
            result = {
               "progressChange":progressChange,
               "taskCompleted":taskCompletedIndex
            };
         }
         return result;
      }
      
      override protected function checkQuestCompletion(progress:Object, quest:Quest) : Boolean
      {
         var taskIndex:int = 0;
         var result:Boolean = true;
         var farmQuest:FarmQuest = quest as FarmQuest;
         if(farmQuest != null)
         {
            for(taskIndex = 0; taskIndex < farmQuest.farmTasks.length; taskIndex++)
            {
               if(progress.progress[taskIndex] < farmQuest.farmTasks[taskIndex].total)
               {
                  result = false;
                  break;
               }
            }
         }
         if(!result && Boolean(farmQuest.taskCompletionCount))
         {
            result = this.checkAdditionalCompletion(farmQuest,progress);
         }
         return result;
      }
      
      public function onSkipQuest(quest:FarmQuest) : void
      {
         var dialogConfig:GenericDialogConfig = new GenericDialogConfig();
         dialogConfig.setBodyText("");
         dialogConfig.setImageUrl(quest.avatarBodyImage);
         dialogConfig.showCloseButton(false);
         dialogConfig.addButton(ZLocUtils.t("Quests","Keep"),GenericDialogConfig.COLOR_GREEN);
         dialogConfig.addButton(ZLocUtils.t("Quests","DoLater"),GenericDialogConfig.COLOR_TEAL,this.onPauseQuest);
         dialogConfig.addButton(ZLocUtils.t("Quests","DontKeep"),GenericDialogConfig.COLOR_RED,this.onKillQuest);
         this.m_skipQuestDialog = GenericDialog.createFromConfig(dialogConfig);
         this.m_skipQuestDialog.setShortcutAttribute("bodyText",TextFieldView.ATTRIBUTE_ALIGN,"center");
         this.m_skipQuestDialog.setShortcutAttribute("bodyText",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Quests","QuestSkipConfirm"));
         this.m_skipQuestDialog.addImport("quest",quest);
         this.m_skipQuestDialog.show();
      }
      
      private function checkAdditionalCompletion(farmQuest:FarmQuest, progress:Object) : Boolean
      {
         var taskIndex:int = 0;
         var i:int = 0;
         var task:FarmTask = null;
         var index:int = 0;
         var isComplete:Boolean = false;
         var stepsComplete:int = 0;
         var taskTotalByIndex:Array = [];
         var taskIndexByName:Object = [];
         var taskProgressByIndex:Array = [];
         if(farmQuest != null)
         {
            for(taskIndex = 0; taskIndex < farmQuest.farmTasks.length; taskIndex++)
            {
               task = farmQuest.farmTasks[taskIndex];
               index = int(taskIndexByName[task.action]);
               if(index)
               {
                  taskTotalByIndex[index] += task.total;
                  taskProgressByIndex[index] += progress.progress[taskIndex];
               }
               else
               {
                  taskIndexByName[task.action] = taskTotalByIndex.push(task.total) - 1;
                  taskProgressByIndex.push(progress.progress[taskIndex]);
               }
            }
            for(i = 0; i < taskProgressByIndex.length; i++)
            {
               if(taskProgressByIndex[i] >= taskTotalByIndex[i])
               {
                  stepsComplete++;
               }
            }
            if(stepsComplete >= farmQuest.taskCompletionCount)
            {
               isComplete = true;
            }
         }
         return isComplete;
      }
      
      private function onPauseQuest(event:Event) : void
      {
         var pausedQuest:FarmQuest = this.m_skipQuestDialog.getImport("quest") as FarmQuest;
         TransactionManager.addTransaction(new TPauseQuest(pausedQuest.name));
         Global.hud.iconQueue.removeIconByName(pausedQuest.name);
         this.m_skipQuestDialog.destroy();
      }
      
      private function onKillQuest(event:Event) : void
      {
         var killededQuest:FarmQuest = this.m_skipQuestDialog.getImport("quest") as FarmQuest;
         TransactionManager.addTransaction(new TKillQuest(killededQuest.name));
         Global.hud.iconQueue.removeIconByName(killededQuest.name);
         this.m_skipQuestDialog.destroy();
      }
      
      public function get completedQuests() : Array
      {
         return this.m_sessionCompletedQuests;
      }
      
      override protected function shouldUpdateProgressFromServerResponse(quest:Quest) : Boolean
      {
         var shouldUpdateProgress:Boolean = true;
         if(Boolean(quest) && (quest as FarmQuest).doesRequireServerResponse() == false)
         {
            shouldUpdateProgress = super.shouldUpdateProgressFromServerResponse(quest);
         }
         return shouldUpdateProgress;
      }
      
      override protected function shouldDispatchQuestProgress(quest:Quest, event:TransactionEvent) : Boolean
      {
         var shouldDispatchProgress:Boolean = true;
         if(Boolean(quest) && (quest as FarmQuest).doesRequireServerResponse() == false)
         {
            shouldDispatchProgress = super.shouldDispatchQuestProgress(quest,event);
         }
         return shouldDispatchProgress;
      }
      
      public function isQuestExpiringSoon(quest:FarmQuest) : Boolean
      {
         var timeLeft:Number = quest.timeRemaining;
         return timeLeft != FarmQuest.QUEST_TIME_DO_NOT_EXPIRE && timeLeft <= FarmGameUtil.NUM_SECS_IN_DAY * QuestConstants.NUM_DAYS_CONSIDERED_TO_QUEST_EXPIRING_SOON;
      }
      
      public function addRewardForTask(task:FarmTask, currentProgress:int) : void
      {
         var questType:String = null;
         var questItem:FarmItem = null;
         var totalItemsNeeded:int = 0;
         var amountToAdd:int = 0;
         var rewardsData:BaseDataSource = null;
         var rewardsXML:XML = null;
         if(task)
         {
            questType = task.type;
            if(questType != "" && task.action == QuestConstants.TASK_USE_ITEM_BY_CODE)
            {
               questItem = Global.farmGameSettingsManager.getFarmItemByCode(questType);
               if(questItem)
               {
                  totalItemsNeeded = task.total;
                  amountToAdd = totalItemsNeeded - currentProgress;
                  if(FarmGameSettingsManager.isInDataSourceExperiment())
                  {
                     rewardsData = questItem.rewardsData;
                     if(rewardsData != null)
                     {
                        UserRewardUtil.grantUserRewardsFromDataSource(rewardsData,amountToAdd);
                     }
                  }
                  else
                  {
                     rewardsXML = questItem.rewardsXML;
                     if(rewardsXML != null)
                     {
                        UserRewardUtil.grantUserRewardsFromXml(rewardsXML,amountToAdd);
                     }
                  }
               }
            }
         }
      }
   }
}

