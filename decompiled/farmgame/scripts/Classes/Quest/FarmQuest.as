package Classes.Quest
{
   import Classes.AsyncCall;
   import Classes.Constants.ArrowType;
   import Classes.Constants.Experiments;
   import Classes.Constants.PrerequisiteConstants;
   import Classes.Constants.QuestConstants;
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.UserRewardUtil;
   import Classes.util.ZLocFailoverEntry;
   import Classes.util.ZLocUtils;
   import Display.DataDrivenOkayPopup;
   import Display.Dialogs.CutsceneDialog;
   import Display.Dialogs.NpcImageInfoDialog;
   import Display.Dialogs.NpcMultiSpeechBubble;
   import Display.Dialogs.NpcSpeechBubble;
   import Display.DynamicIconQueue;
   import Display.FarmDynamicDialog;
   import Display.HUD.ScoreMeter;
   import Display.HUD.ScoreMeterConfig;
   import Display.Party.TeaPartyDialog;
   import Display.Quests.QuestChapterRewardDialog;
   import Display.Quests.QuestProgressDialog;
   import Display.Quests.QuestRewardDialog;
   import Display.QueuedIcons.QuestManagerQueuedIcon;
   import Display.QueuedIcons.QuestQueuedIcon;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.ExpiredQuestRewardPurchaseManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureMessagingManager;
   import Managers.FeatureTrackingManager;
   import Managers.PartyManager;
   import Managers.QuestManagerDisplay;
   import Managers.ToasterManager;
   import Replay.ArrayUtils;
   import Transactions.Quests.TUserTaskSeen;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.AOEBuildableRewardWindow;
   import Widgets.Windows.ContextMenuQuestToaster;
   import Widgets.Windows.CountdownRewardDialog;
   import Widgets.Windows.QuestMapWindow;
   import Widgets.Windows.Quests.ContextMenuQuestRewardWindow;
   import Widgets.Windows.Quests.MultiStageQuests.MultiStageQuestDialog;
   import Widgets.Windows.Quests.NoShareQuestChainCompleteWindow;
   import Widgets.Windows.Quests.QuestBonusStagesFute;
   import Widgets.Windows.Quests.QuestBonusStagesUnlock;
   import Widgets.Windows.Quests.QuestCompleteWindowWithRewardItem;
   import Widgets.Windows.Quests.QuestDifficultySelect;
   import Widgets.Windows.Quests.QuestRewardWindowFor30DayQuest;
   import Widgets.Windows.Quests.TieredQuestRewardWindow;
   import Widgets.Windows.ThemedQuestRewardWindow;
   import Widgets.Windows.ToasterWindow;
   import Widgets.Windows.Toasters.ThemedQuestToasterWindow;
   import ZQuest.Classes.Quest;
   import ZQuest.Events.QuestEvent;
   import ZQuest.Init.QuestSettingsInit;
   import ZQuest.Managers.QuestManager;
   import com.troyer.widget.controller.ButtonController;
   import com.troyer.widget.controller.ImageController;
   import com.troyer.widget.event.WidgetControllerEvent;
   import com.troyer.widget.view.TextFieldView;
   import flash.display.DisplayObject;
   import flash.utils.getDefinitionByName;
   
   public class FarmQuest extends Quest
   {
      
      private static const DEFAULT_PROGRESS_DIALOG_NAME:String = "questProgress";
      
      private static const DEFAULT_REWARD_DIALOG_NAME:String = "questReward";
      
      private static const QUEST_OBJECT_IMPORT_NAME:String = "questObject";
      
      private static const QUEST_TIME_EXPIRATION_NOT_DETERMINED:Number = -2;
      
      public static const QUEST_TIME_DO_NOT_EXPIRE:Number = -1;
      
      public static const NOT_PARSED:int = -2;
      
      public static const W2W_FEATURE_SUFFIX:String = "_quests";
      
      public static const W2W_ASK_FOR_HELP_SUFFIX:String = "_askforhelp";
      
      public static const W2W_SEND_HELP_SUFFIX:String = "_sendhelp";
      
      public static const ICON_NONE:String = "none";
      
      private static const EXPIRATION_VIEW_NONE:String = "none";
      
      public static const COMPLETE_SHARE_ICON_FRIEND_REWARD:String = "friendReward";
      
      private static const SKIP_ALL_DISCOUNT:int = 10;
      
      public static const QUEST_FINISH_RATIO:int = 1;
      
      private static var QuestRewardWindows:Array = [QuestCompleteWindowWithRewardItem,ContextMenuQuestRewardWindow,NoShareQuestChainCompleteWindow,QuestRewardWindowFor30DayQuest,TieredQuestRewardWindow];
      
      protected var m_category:String = "";
      
      protected var m_priority:int = 0;
      
      protected var m_taskCompletionCount:int = 0;
      
      protected var m_skippable:Boolean = false;
      
      protected var m_replayable:Boolean = false;
      
      protected var m_killable:Boolean = false;
      
      protected var m_avatarHeadImage:String = null;
      
      protected var m_avatarBodyImage:String = null;
      
      protected var m_circularProgressBarIconUrl:String = null;
      
      protected var m_textBundle:String = null;
      
      protected var m_chapter:int = -2;
      
      protected var m_chain:String = "";
      
      protected var m_chatperTitle:String = "";
      
      protected var m_questNumber:int = -2;
      
      protected var m_location:int = -2;
      
      protected var m_children:Vector.<Object> = new Vector.<Object>();
      
      protected var m_parents:Vector.<Object> = new Vector.<Object>();
      
      protected var m_prerequisites:Vector.<Object> = new Vector.<Object>();
      
      protected var m_farmRewards:Vector.<Object> = new Vector.<Object>();
      
      protected var m_farmTasks:Vector.<FarmTask> = new Vector.<FarmTask>();
      
      protected var m_events:Vector.<Object> = new Vector.<Object>();
      
      protected var m_helpAction:Object = null;
      
      protected var m_completeShareFeedIcon:String = "";
      
      protected var m_introSeenFlag:String = "";
      
      protected var m_expirationTime:Number = -2;
      
      protected var m_mfs_item:String = "";
      
      protected var m_customIntroWidget:String = "";
      
      protected var m_nextChapter:String = "";
      
      protected var m_prevChapter:String = "";
      
      protected var m_chapterIcon:String = "";
      
      private var m_questManagerProgress:Boolean = false;
      
      private var m_hasTestedForReplayableQuestPrereqs:Boolean = false;
      
      public function FarmQuest(xml:XML)
      {
         super(xml);
         m_xml = xml;
         m_name = String(xml.@name);
         m_icon = xml.frontend.icon.toString();
         this.m_completeShareFeedIcon = xml.frontend.completeShareFeedIcon.toString();
         this.m_introSeenFlag = xml.frontend.introFlag.toString();
         this.m_customIntroWidget = xml.frontend.customIntroWidget.toString();
         this.m_nextChapter = xml.frontend.nextIntroChapter.toString();
         this.m_prevChapter = xml.frontend.prevIntroChapter.toString();
         this.m_chapterIcon = xml.frontend.chapterIcon.toString();
         this.m_avatarHeadImage = xml.frontend.avatarHeadImage.toString();
         this.m_avatarBodyImage = xml.frontend.avatarBodyImage.toString();
         this.m_circularProgressBarIconUrl = xml.frontend.circularProgressBarIconUrl.toString();
         this.m_textBundle = xml.frontend.textBundle.toString();
         this.m_category = String(xml.@category);
         this.m_priority = int(xml.@priority);
         if(m_xml.mapLocation.toString() != "")
         {
            this.m_location = m_xml.mapLocation.toString().split("-")[0];
         }
         this.m_skippable = String(xml.@skip) == "true";
         this.m_replayable = String(xml.@replay) == "true";
         this.m_killable = String(xml.@kill) == "true";
         this.m_taskCompletionCount = int(xml.@taskCompletionCount);
         this.m_children = this.processDescriptionGroup(xml.children);
         this.m_parents = this.processDescriptionGroup(xml.parents);
         this.m_prerequisites = this.processDescriptionGroup(xml.prereqs);
         this.m_farmRewards = this.processDescriptionGroup(xml.rewards);
         this.m_events = this.processDescriptionGroup(xml.frontend.events);
         m_tasks = this.processDescriptionGroup(xml.tasks);
         this.m_farmTasks = this.convertTasks(m_tasks);
      }
      
      private function processDescriptionGroup(groupList:XMLList) : Vector.<Object>
      {
         var node:XML = null;
         var objToAdd:Object = null;
         var result:Vector.<Object> = new Vector.<Object>();
         var list:XMLList = groupList.children();
         if(list.length() == 0)
         {
            list = groupList;
         }
         for each(node in list)
         {
            objToAdd = new Object();
            if(node.name() == "OR")
            {
               objToAdd.orGroup = this.processDescriptionGroup(node.children());
            }
            else
            {
               objToAdd = FarmGameUtil.xmlNodeToAttributes(node);
            }
            result.push(objToAdd);
         }
         return result;
      }
      
      private function convertTasks(taskList:Vector.<Object>) : Vector.<FarmTask>
      {
         var taskObj:Object = null;
         var result:Vector.<FarmTask> = new Vector.<FarmTask>();
         for each(taskObj in taskList)
         {
            taskObj.questName = m_name;
            taskObj.taskIndex = taskList.indexOf(taskObj);
            result.push(new FarmTask(taskObj));
         }
         return result;
      }
      
      public function get isNew() : Boolean
      {
         var result:Boolean = false;
         var progressData:Object = FarmQuestManager.getInstance().getQuestProgressByName(m_name);
         if(progressData != null && progressData["new"] != null)
         {
            result = progressData["new"] == QuestConstants.NEW_QUEST;
         }
         return result;
      }
      
      public function get expirationTime() : Number
      {
         var index:int = 0;
         var preReq:Object = null;
         if(this.m_expirationTime == QUEST_TIME_EXPIRATION_NOT_DETERMINED)
         {
            this.m_expirationTime = QUEST_TIME_DO_NOT_EXPIRE;
            for(index = 0; index < this.prerequisites.length; index++)
            {
               preReq = this.prerequisites[index];
               if(preReq.type == PrerequisiteConstants.PREREQUISITE_END_TIME)
               {
                  this.m_expirationTime = FarmGameUtil.synchronizedDateTimeToNumber(preReq.value);
                  break;
               }
            }
         }
         return this.m_expirationTime;
      }
      
      public function get startTime() : Number
      {
         var preReq:Object = null;
         var startTime:Number = -1;
         for(var index:int = 0; index < this.prerequisites.length; index++)
         {
            preReq = this.prerequisites[index];
            if(preReq.type == PrerequisiteConstants.PREREQUISITE_START_TIME)
            {
               startTime = FarmGameUtil.synchronizedDateTimeToNumber(preReq.value);
               break;
            }
         }
         return startTime;
      }
      
      public function get timeRemaining() : Number
      {
         var result:Number = QUEST_TIME_DO_NOT_EXPIRE;
         if(this.expirationTime != QUEST_TIME_DO_NOT_EXPIRE)
         {
            result = (this.expirationTime - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
            if(result < 0)
            {
               result = 0;
            }
         }
         return result;
      }
      
      public function setAsSeen() : void
      {
         var progressData:Object = FarmQuestManager.getInstance().getQuestProgressByName(m_name);
         if(progressData != null && progressData["new"] != null)
         {
            progressData["new"] = QuestConstants.NON_NEW_QUEST;
         }
      }
      
      public function getQueuedIcon() : QuestQueuedIcon
      {
         return Global.hud.iconQueue.getIconByName(this.name) as QuestQueuedIcon;
      }
      
      public function addIconToIconQueue() : QuestQueuedIcon
      {
         var iconUrl:String = this.icon;
         var icon:QuestQueuedIcon = null;
         switch(iconUrl)
         {
            case ICON_NONE:
               break;
            default:
               icon = Global.hud.iconQueue.addIcon("QuestGenericIcon",DynamicIconQueue.ADD_BY_PRIORITY,this.icon,{"quest":this}) as QuestQueuedIcon;
               if(icon != null)
               {
                  icon.onAdd();
               }
         }
         return icon;
      }
      
      public function onProgress() : QuestQueuedIcon
      {
         var circularProgressBarIconUrl:String = null;
         var questManagerIcon:QuestManagerQueuedIcon = null;
         this.m_questManagerProgress = true;
         var iconUrl:String = this.icon;
         var icon:QuestQueuedIcon = null;
         switch(iconUrl)
         {
            case "none":
               break;
            default:
               icon = Global.hud.iconQueue.getIconByName(this.name) as QuestQueuedIcon;
               circularProgressBarIconUrl = this.circularProgressBarIconUrl;
               if(icon != null)
               {
                  icon.attachArrow(ArrowType.ARROWUPDATE);
                  icon.playProgressBarAnimation();
                  icon = null;
               }
               else
               {
                  icon = this.addIconToIconQueue();
                  if(Global.hud.iconQueue.getIconByName(this.name) == null)
                  {
                     if(!(FarmQuestManager.getInstance().isQuestExpiringSoon(this) && this.shouldShowTimeLeftHUDSurfacing()))
                     {
                        questManagerIcon = Global.hud.iconQueue.getIconByName(QuestManagerQueuedIcon.QUEST_MANAGER_ICON_NAME) as QuestManagerQueuedIcon;
                        if(questManagerIcon != null)
                        {
                           questManagerIcon.attachArrow(ArrowType.ARROWUPDATE);
                        }
                     }
                  }
               }
               QuestManagerDisplay.getInstance().refreshWindow();
         }
         return icon;
      }
      
      public function showTaskComplete(taskIndex:int) : void
      {
         var toaster:ToasterWindow = null;
         var themedToaster:ToasterWindow = null;
         switch(this.taskCompletionView)
         {
            case "ContextMenuQuestCompletionToaster":
               toaster = new ContextMenuQuestToaster(this,taskIndex);
               ToasterManager.getInstance().add(toaster);
               break;
            case "ThemedQuestCompletionToaster":
               themedToaster = new ThemedQuestToasterWindow(this,ThemedQuestToasterWindow.TASK_COMPLETE);
               ToasterManager.getInstance().add(themedToaster);
         }
      }
      
      public function removeIconFromIconQueue(hasExpired:Boolean = false) : QuestQueuedIcon
      {
         var iconUrl:String = this.icon;
         var icon:QuestQueuedIcon = null;
         switch(iconUrl)
         {
            case ICON_NONE:
               break;
            default:
               icon = Global.hud.iconQueue.getIconByName(this.name) as QuestQueuedIcon;
               if(icon != null)
               {
                  if(hasExpired == true)
                  {
                     icon.onExpired();
                  }
                  else
                  {
                     icon.onComplete();
                  }
               }
         }
         return icon;
      }
      
      public function shouldAutoShowProgress() : Boolean
      {
         var result:Boolean = true;
         var value:String = m_xml.frontend.autoShowProgressView.toString();
         if(value == "false")
         {
            result = false;
         }
         return result;
      }
      
      public function showProgress() : void
      {
         var swfurl:String = null;
         var questBonusFtueUrl:String = null;
         var ftuePopUp:QuestBonusStagesFute = null;
         var questBonusUnlockUrl:String = null;
         var generic1TF:String = null;
         var generic2TF:String = null;
         var generic3TF:String = null;
         var askcountTF:int = 0;
         var titleTF:String = null;
         var viptextTF:String = null;
         var bonusStageUnlockCost:int = 0;
         var feedItemCode:String = null;
         var unlockPopUp:QuestBonusStagesUnlock = null;
         var progressView:Object = null;
         var respectPopupQueue:Boolean = true;
         switch(this.progressViewType)
         {
            case "TeaPartyDialog":
               progressView = PartyManager.getInstance().getPartyWindow(TeaPartyDialog.FRIEND_SET_CODE);
               break;
            case "questBonusFtue":
               if(!Global.player.getSeenFlag("QuestBonusFtue" + this.name))
               {
                  questBonusFtueUrl = m_xml.frontend.questBonusFtueUrl.toString();
                  ftuePopUp = new QuestBonusStagesFute(questBonusFtueUrl,this.name);
                  UI.displayPopup(ftuePopUp,false);
                  UI.bringToFront(ftuePopUp);
               }
               else
               {
                  progressView = FarmDynamicDialog.createDialog(DEFAULT_PROGRESS_DIALOG_NAME,QuestProgressDialog);
                  progressView.addImport(QUEST_OBJECT_IMPORT_NAME,this);
                  respectPopupQueue = false;
               }
               break;
            case "questBonusUnlock":
               if(!Global.player.getSeenFlag("QuestBonusUnlocked" + this.name))
               {
                  questBonusUnlockUrl = m_xml.frontend.questBonusUnlockUrl.toString();
                  generic1TF = m_xml.frontend.generic1TF.toString();
                  generic2TF = m_xml.frontend.generic2TF.toString();
                  generic3TF = m_xml.frontend.generic3TF.toString();
                  askcountTF = int(m_xml.frontend.askcountTF);
                  titleTF = m_xml.frontend.titleTF.toString();
                  viptextTF = m_xml.frontend.viptextTF.toString();
                  bonusStageUnlockCost = int(m_xml.frontend.bonusStageUnlockCost);
                  feedItemCode = m_xml.frontend.feedItemCode;
                  unlockPopUp = new QuestBonusStagesUnlock(questBonusUnlockUrl,this.name,feedItemCode,bonusStageUnlockCost,generic1TF,generic2TF,generic3TF,askcountTF,titleTF,viptextTF);
                  UI.displayPopup(unlockPopUp,false);
                  UI.bringToFront(unlockPopUp);
               }
               else
               {
                  progressView = FarmDynamicDialog.createDialog(DEFAULT_PROGRESS_DIALOG_NAME,QuestProgressDialog);
                  progressView.addImport(QUEST_OBJECT_IMPORT_NAME,this);
                  respectPopupQueue = false;
               }
               break;
            case "":
               progressView = FarmDynamicDialog.createDialog(DEFAULT_PROGRESS_DIALOG_NAME,QuestProgressDialog);
               progressView.addImport(QUEST_OBJECT_IMPORT_NAME,this);
               break;
            case "none":
               break;
            case "difficultySelect":
               progressView = new QuestDifficultySelect(this.name);
               break;
            case "multiStageQuestDialog":
               swfurl = Global.farmGameSettingsManager.getString("multiStageQuestDialog_" + this.chain + "_swf");
               progressView = new MultiStageQuestDialog(this,this.questNumber,swfurl);
               FarmStatsManager.count("fv_contextQuest",this.chain,"showUI",this.questNumber.toString());
               break;
            case "tieredQuestWindow":
               FeatureMessagingManager.getInstance().openFeatureUI(this.chain);
               break;
            default:
               progressView = FarmDynamicDialog.createDialog(this.progressViewType,QuestProgressDialog);
               progressView.addImport(QUEST_OBJECT_IMPORT_NAME,this);
         }
         if(progressView)
         {
            this.displayUiElement(progressView,respectPopupQueue);
         }
      }
      
      public function get progressViewType() : String
      {
         var result:String = "";
         if(m_xml)
         {
            result = m_xml.frontend.progressView.toString();
         }
         return result;
      }
      
      public function get taskCompletionView() : String
      {
         var result:String = "";
         if(m_xml)
         {
            result = m_xml.frontend.taskCompletionView.toString();
         }
         return result;
      }
      
      public function get mfsItemName() : String
      {
         if(Boolean(this.m_mfs_item == "") && Boolean(m_xml) && Boolean(m_xml.frontend) && Boolean(m_xml.frontend.MFSitem))
         {
            this.m_mfs_item = m_xml.frontend.MFSitem.toString();
         }
         return this.m_mfs_item;
      }
      
      public function get questManagerProgress() : Boolean
      {
         return this.m_questManagerProgress;
      }
      
      public function set questManagerProgress(newQuestManagerProgress:Boolean) : void
      {
         this.m_questManagerProgress = newQuestManagerProgress;
      }
      
      public function get taskCompletionCount() : int
      {
         return this.m_taskCompletionCount;
      }
      
      public function isViewDialogQuest() : Boolean
      {
         var result:Boolean = false;
         if(this.m_farmTasks.length == 1 && this.m_farmTasks[0].action == QuestConstants.TASK_VIEW_DIALOG && this.m_farmRewards.length == 0)
         {
            result = true;
         }
         return result;
      }
      
      public function showReward() : Object
      {
         var respectPopupQueue:Boolean;
         var rewardType:String = null;
         var cutsceneUrl:String = null;
         var bonusImageUrl:String = null;
         var callback:Function = null;
         var themedFeatureName:String = null;
         var currentWorldType:String = null;
         var worldConfig:Object = null;
         var dialog:CountdownRewardDialog = null;
         var swf:String = null;
         var dialogBackground:String = null;
         var preAOEitemName:String = null;
         var AOEItemName:String = null;
         var PostAOEIcon:String = null;
         var questClass:Class = null;
         var scoreMeterConfig:ScoreMeterConfig = null;
         var dialogParams:Array = null;
         var classObj:Class = null;
         var childIcon:String = this.displayIcon;
         var rewardView:Object = null;
         if(Boolean(this.mouseOverFeatureEnabled) && Boolean(m_xml.rewards) && m_xml.rewards.toString() != "")
         {
            rewardType = "QuestRewardWindowFor30DayQuest";
         }
         else
         {
            rewardType = m_xml.frontend.rewardView.toString();
         }
         respectPopupQueue = true;
         switch(rewardType)
         {
            case "cutsceneDialog":
               rewardView = FarmDynamicDialog.createDialog("cutscene",CutsceneDialog);
               cutsceneUrl = m_xml.frontend.cutsceneUrl.toString();
               rewardView.addImport(CutsceneDialog.CUTSCENE_IMPORT,cutsceneUrl);
               rewardView.setShortcutAttribute("button",ButtonController.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","Skip"));
               break;
            case QuestConstants.QUEST_BUBBLE_SMALL:
               rewardView = FarmDynamicDialog.createDialog("npcSpeechBubble",NpcSpeechBubble);
               rewardView.addImport(NpcSpeechBubble.LOC_BUNDLE_NAME_IMPORT,"Quests");
               rewardView.addImport(NpcSpeechBubble.LOC_RESOURCE_NAME_IMPORT,this.textBundle);
               rewardView.addImport(NpcSpeechBubble.BUTTON_TEXT_LOC_KEY_IMPORT,this.textBundle + "_button");
               rewardView.addImport(NpcSpeechBubble.NPC_IMAGE_URL_IMPORT,this.avatarBodyImage);
               rewardView.addImport(NpcSpeechBubble.BUTTON_CALLBACK_IMPORT,this.onViewReward);
               break;
            case QuestConstants.QUEST_BUBBLE_PICTORIAL:
               rewardView = FarmDynamicDialog.createDialog("pictorialBubble",NpcSpeechBubble);
               rewardView.addImport(NpcSpeechBubble.BUTTON_TEXT_LOC_KEY_IMPORT,this.textBundle + "_button");
               rewardView.addImport(NpcSpeechBubble.NPC_IMAGE_URL_IMPORT,this.bubbleImage);
               rewardView.addImport(NpcSpeechBubble.BUTTON_CALLBACK_IMPORT,this.onViewReward);
               break;
            case QuestConstants.QUEST_BUBLE_FULL:
               rewardView = FarmDynamicDialog.createDialog("npcSpeechBubbleFull",NpcMultiSpeechBubble);
               rewardView.addImport(NpcSpeechBubble.LOC_BUNDLE_NAME_IMPORT,"Quests");
               rewardView.addImport(NpcSpeechBubble.LOC_RESOURCE_NAME_IMPORT,this.textBundle);
               rewardView.addImport(NpcSpeechBubble.BUTTON_TEXT_LOC_KEY_IMPORT,this.textBundle + "_button");
               rewardView.addImport(NpcSpeechBubble.NPC_IMAGE_URL_IMPORT,this.avatarBodyImage);
               rewardView.addImport(NpcSpeechBubble.BUTTON_CALLBACK_IMPORT,this.onViewReward);
               break;
            case "questBonusStageImage":
               bonusImageUrl = m_xml.frontend.bonusImageUrl.toString();
               rewardView = FarmDynamicDialog.createDialog("npcSpeechBubbleFullBonus",NpcMultiSpeechBubble);
               rewardView.addImport(NpcSpeechBubble.LOC_BUNDLE_NAME_IMPORT,"Quests");
               rewardView.addImport(NpcSpeechBubble.LOC_RESOURCE_NAME_IMPORT,this.textBundle);
               rewardView.addImport(NpcSpeechBubble.BUTTON_TEXT_LOC_KEY_IMPORT,this.textBundle + "_button");
               rewardView.addImport(NpcSpeechBubble.NPC_IMAGE_URL_IMPORT,this.avatarBodyImage);
               rewardView.addImport(NpcSpeechBubble.BUTTON_CALLBACK_IMPORT,this.onViewReward);
               rewardView.setShortcutAttribute("bonusImage",ImageController.ATTRIBUTE_SOURCE,bonusImageUrl);
               respectPopupQueue = false;
               break;
            case "englandSellScreenPostcard":
               rewardView = FarmDynamicDialog.createDialog("englandSellPostcard",NpcImageInfoDialog);
               rewardView.addImport(NpcImageInfoDialog.BUTTON_TEXT_IMPORT,ZLocUtils.t("Quests","england_sell_postcardButtonText"));
               rewardView.addImport(NpcImageInfoDialog.IMAGE_ASSET_IMPORT,"assets/dialogs/FV_Support/FV_Expansions_Features/SellScreens/expansions_mainSell.png");
               rewardView.addImport(NpcImageInfoDialog.NPC_ASSET_IMPORT,this.avatarHeadImage);
               rewardView.addImport(NpcImageInfoDialog.SPEECH_TEXT_IMPORT,ZLocUtils.t("Quests","england_sell_postcardText"));
               rewardView.setShortcutAttribute("titleText",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Quests","england_sell_postcardTitle"));
               callback = function(event:WidgetControllerEvent):void
               {
                  var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(m_farmRewards[0].value);
                  if(item)
                  {
                     Global.world.enterForcePlaceMode(item.name);
                  }
               };
               rewardView.addImport(NpcImageInfoDialog.CALLBACK_IMPORT,callback);
               break;
            case QuestConstants.REWARD_THEMED_QUEST:
               themedFeatureName = m_xml.frontend.themedFeatureName.toString();
               if(themedFeatureName)
               {
                  rewardView = new ThemedQuestRewardWindow(themedFeatureName,this,ThemedQuestRewardWindow.PUZZLE_ALL_COMPLETE);
                  respectPopupQueue = false;
               }
               break;
            case "englandSellScreenSoil":
               rewardView = FarmDynamicDialog.createDialog("englandBuffySoilSell",NpcImageInfoDialog);
               rewardView.addImport(NpcImageInfoDialog.BUTTON_TEXT_IMPORT,ZLocUtils.t("Dialogs","Okay"));
               rewardView.addImport(NpcImageInfoDialog.IMAGE_ASSET_IMPORT,"assets/dialogs/FV_Support/FV_Expansions_Features/SellScreens/expansions_soilSell.png");
               rewardView.addImport(NpcImageInfoDialog.NPC_ASSET_IMPORT,this.avatarHeadImage);
               rewardView.addImport(NpcImageInfoDialog.SPEECH_TEXT_IMPORT,ZLocUtils.t("Quests","england_sell_soilText"));
               break;
            case "englandSellScreenSheep":
               rewardView = FarmDynamicDialog.createDialog("englandSheepPenSell",NpcImageInfoDialog);
               rewardView.addImport(NpcImageInfoDialog.BUTTON_TEXT_IMPORT,ZLocUtils.t("Dialogs","Okay"));
               rewardView.addImport(NpcImageInfoDialog.IMAGE_ASSET_IMPORT,"assets/dialogs/FV_Support/FV_Expansions_Features/SellScreens/expansions_sheepSell.png");
               rewardView.addImport(NpcImageInfoDialog.NPC_ASSET_IMPORT,this.avatarHeadImage);
               rewardView.addImport(NpcImageInfoDialog.SPEECH_TEXT_IMPORT,ZLocUtils.t("Quests","england_sell_sheepText"));
               break;
            case "englandSellScreenNPCs":
               rewardView = FarmDynamicDialog.createDialog("englandSheepPenSell",NpcImageInfoDialog);
               rewardView.addImport(NpcImageInfoDialog.BUTTON_TEXT_IMPORT,ZLocUtils.t("Dialogs","Okay"));
               rewardView.addImport(NpcImageInfoDialog.IMAGE_ASSET_IMPORT,"assets/dialogs/FV_Support/FV_Expansions_Features/SellScreens/expansions_NPCSell.png");
               rewardView.addImport(NpcImageInfoDialog.NPC_ASSET_IMPORT,this.avatarHeadImage);
               rewardView.addImport(NpcImageInfoDialog.SPEECH_TEXT_IMPORT,ZLocUtils.t("Quests","england_sell_npcText"));
               break;
            case "questMap":
               currentWorldType = Global.worldManager.currentWorldType;
               rewardView = new QuestMapWindow(QuestMapWindow.getAssetPathByWorld(currentWorldType),currentWorldType,false,true,true,true);
               break;
            case "chapterRewardDialog":
               rewardView = FarmDynamicDialog.createDialog("QuestBigReward",QuestChapterRewardDialog);
               rewardView.addImport(QUEST_OBJECT_IMPORT_NAME,this);
               break;
            case "worldScoreWhatIsThis":
               worldConfig = Global.worldSettingsManager.getConfigByWorld(Global.worldManager.currentWorldType);
               if(worldConfig != null && worldConfig.hudSkinConfig != null && worldConfig.hudSkinConfig.worldScoreConfig != null)
               {
                  scoreMeterConfig = worldConfig.hudSkinConfig.worldScoreConfig;
                  dialogParams = scoreMeterConfig.getWhatIsThisDialogParams(Global.worldManager.currentWorldScoreId,Global.player.currentWorldScore,Global.player.currentWorldLevel);
                  rewardView = new DataDrivenOkayPopup(ScoreMeter.WHAT_IS_THIS_DIALOG_NAME,dialogParams);
               }
               break;
            case "none":
               break;
            case "farmVillageFtueReward":
               dialog = new CountdownRewardDialog("assets/dialogs/Village/FV_village_FTUE_congrats.swf",ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"FarmVillageFtue_Title"),ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"FarmVillageFtue_Body1"),ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"FarmVillageFtue_Body2"));
               UI.displayPopup(dialog,false);
               rewardView = dialog;
               break;
            case "AOEBuildingReward":
               swf = m_xml.frontend.swf.toString();
               dialogBackground = m_xml.frontend.dialogBackground.toString();
               preAOEitemName = m_xml.frontend.itemName.toString();
               AOEItemName = m_xml.frontend.AOEItemName.toString();
               PostAOEIcon = "";
               if(m_xml.frontend.PostAOEIcon != null)
               {
                  PostAOEIcon = m_xml.frontend.PostAOEIcon.toString();
               }
               respectPopupQueue = false;
               rewardView = new AOEBuildableRewardWindow(swf,preAOEitemName,AOEItemName,PostAOEIcon,dialogBackground);
               break;
            case "QuestRewardWindowFor30DayQuest":
               questClass = getDefinitionByName("Widgets.Windows.Quests.QuestRewardWindowFor30DayQuest") as Class;
               rewardView = new questClass(this);
               break;
            case "":
               rewardView = FarmDynamicDialog.createDialog(DEFAULT_REWARD_DIALOG_NAME,QuestRewardDialog);
               rewardView.addImport(QUEST_OBJECT_IMPORT_NAME,this);
               break;
            default:
               rewardView = FarmDynamicDialog.createDialog(rewardType,QuestRewardDialog);
               if(rewardView != null)
               {
                  rewardView.addImport(QUEST_OBJECT_IMPORT_NAME,this);
               }
               else
               {
                  classObj = getDefinitionByName("Widgets.Windows.Quests." + rewardType) as Class;
                  rewardView = new classObj(this);
               }
         }
         if(this.isViewDialogQuest())
         {
            TransactionManager.addTransaction(new TUserTaskSeen(name));
         }
         this.displayUiElement(rewardView,respectPopupQueue);
         return rewardView;
      }
      
      private function onViewReward(event:WidgetControllerEvent) : void
      {
         FarmQuestManager.getInstance().onQuestRewardDialogClosed();
         this.dispatchQuestEvents(QuestConstants.ON_USER_EVENT_QUEST_REWARD_DIALOG);
      }
      
      public function showExpiration() : void
      {
         var expireText:String = null;
         var classObj:Class = null;
         var expirationViewClass:Object = null;
         var dialogShown:Boolean = false;
         var expirationDialog:FarmDynamicDialog = null;
         var expirationViewName:String = m_xml.frontend.expirationView.toString();
         if("none" != expirationViewName)
         {
            try
            {
               classObj = getDefinitionByName(expirationViewName) as Class;
            }
            catch(e:Error)
            {
            }
            if(classObj)
            {
               expirationViewClass = new classObj(this);
               if(expirationViewClass["showExpiration"])
               {
                  expirationViewClass.showExpiration();
               }
            }
            else
            {
               if(ZLocUtils.hasString("Quests",this.name + "_ExpiredQuestAlert"))
               {
                  expireText = ZLocUtils.t("Quests",this.name + "_ExpiredQuestAlert");
               }
               else
               {
                  expireText = ZLocUtils.t("Quests","ExpiredQuestAlert",{"questTitle":this.titleText});
               }
               dialogShown = false;
               if(expirationViewName != null)
               {
                  expirationDialog = FarmDynamicDialog.createDialog(expirationViewName,FarmDynamicDialog);
                  if(expirationDialog)
                  {
                     expirationDialog.setShortcutAttribute("bodyText",TextFieldView.ATTRIBUTE_TEXT,expireText);
                     expirationDialog.show(true);
                     dialogShown = true;
                  }
               }
            }
         }
      }
      
      public function showQuestRecaptureFlow() : void
      {
         ExpiredQuestRewardPurchaseManager.showDialog(this);
      }
      
      private function displayUiElement(uiElement:Object, respectPopupQueue:Boolean = true) : void
      {
         var farmDynamicDialog:FarmDynamicDialog = null;
         if(uiElement != null)
         {
            if(uiElement is FarmDynamicDialog)
            {
               farmDynamicDialog = uiElement as FarmDynamicDialog;
               farmDynamicDialog.setup();
               farmDynamicDialog.show(true,farmDynamicDialog.getView().name,false);
            }
            else if(uiElement is DisplayObject)
            {
               UI.displayPopup(uiElement as DisplayObject,respectPopupQueue);
            }
            FeatureTrackingManager.instance.uiOpen(this.chain);
         }
      }
      
      public function get progress() : Number
      {
         var task:FarmTask = null;
         var totalTaskProgress:Number = 0;
         for each(task in this.m_farmTasks)
         {
            totalTaskProgress += task.progressPercent;
         }
         return totalTaskProgress / this.m_farmTasks.length;
      }
      
      public function get numOfCompletedTasks() : int
      {
         var task:FarmTask = null;
         var result:int = 0;
         for each(task in this.m_farmTasks)
         {
            if(task.isComplete())
            {
               result++;
            }
         }
         return result;
      }
      
      public function get progressByTasks() : Number
      {
         return Number(this.numOfCompletedTasks) / this.m_farmTasks.length;
      }
      
      public function get skippable() : Boolean
      {
         return this.m_skippable;
      }
      
      public function get replayable() : Boolean
      {
         return this.m_replayable;
      }
      
      public function isQuestManagerReplayableQuest() : Boolean
      {
         var result:Boolean = false;
         var farmQuestSettingsInit:FarmQuestSettingsInit = FarmQuestSettingsInit.getInstance();
         if(farmQuestSettingsInit.hasBeenInitialized())
         {
            result = farmQuestSettingsInit.questManagerQuestChainCacheContains(this.name);
         }
         return result;
      }
      
      public function get children() : Vector.<Object>
      {
         return this.m_children;
      }
      
      public function get parents() : Vector.<Object>
      {
         return this.m_parents;
      }
      
      public function get prerequisites() : Vector.<Object>
      {
         var farmQuestSettingsInit:FarmQuestSettingsInit = null;
         var filteredPrereqs:Array = null;
         if(!this.m_hasTestedForReplayableQuestPrereqs)
         {
            farmQuestSettingsInit = FarmQuestSettingsInit.getInstance();
            if(farmQuestSettingsInit.hasBeenInitialized())
            {
               if(this.isQuestManagerReplayableQuest())
               {
                  filteredPrereqs = PrerequisiteUtility.filterPrerequisitesFromVector(this.m_prerequisites,[PrerequisiteConstants.PREREQUISITE_START_TIME,PrerequisiteConstants.PREREQUISITE_END_TIME],false);
                  this.m_prerequisites = ArrayUtils.arrayToVectorObject(filteredPrereqs);
                  this.m_expirationTime = QUEST_TIME_DO_NOT_EXPIRE;
               }
               this.m_hasTestedForReplayableQuestPrereqs = true;
            }
         }
         return this.m_prerequisites;
      }
      
      public function get events() : Vector.<Object>
      {
         return this.m_events;
      }
      
      public function dispatchQuestEvents(trigger:String) : void
      {
         var event:Object = null;
         for(var eventIndex:int = 0; eventIndex < this.m_events.length; eventIndex++)
         {
            event = this.m_events[eventIndex];
            if(event.trigger == trigger)
            {
               AsyncCall.call(QuestManager.getInstance().dispatchEvent,new QuestEvent(event.send,this));
            }
         }
      }
      
      public function get farmRewards() : Vector.<Object>
      {
         return this.m_farmRewards;
      }
      
      public function get farmTasks() : Vector.<FarmTask>
      {
         return this.m_farmTasks;
      }
      
      public function get avatarHeadImage() : String
      {
         return this.m_avatarHeadImage;
      }
      
      public function get avatarBodyImage() : String
      {
         return this.m_avatarBodyImage;
      }
      
      public function get bubbleImage() : String
      {
         return this.m_avatarBodyImage;
      }
      
      public function get circularProgressBarIconUrl() : String
      {
         return this.m_circularProgressBarIconUrl;
      }
      
      public function get creativeBundleName() : String
      {
         return String(m_xml.friendReward.@bundle);
      }
      
      public function get friendRewardItem() : FarmItem
      {
         var result:FarmItem = null;
         var itemCode:String = String(m_xml.friendReward.@item);
         if(itemCode != null)
         {
            result = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
         }
         return result;
      }
      
      public function get delayRewardViewOnNeighborFarm() : Number
      {
         var result:Number = NaN;
         if(Boolean(m_xml) && Boolean(m_xml.frontend) && Boolean(m_xml.frontend.delayRewardViewOnNeighborFarm) && m_xml.frontend.delayRewardViewOnNeighborFarm.toString() != "")
         {
            result = Number(m_xml.frontend.delayRewardViewOnNeighborFarm.toString());
         }
         else
         {
            result = Global.farmGameSettingsManager.getAttribute("questDelayRewardViewOnNeighborFarm",0);
         }
         return result;
      }
      
      public function get textBundle() : String
      {
         return this.m_textBundle;
      }
      
      public function get titleText() : String
      {
         var resource:String = this.m_textBundle + "_Title";
         return ZLocUtils.t("Quests",resource);
      }
      
      public function get bodyText() : String
      {
         var resource:String = this.m_textBundle + "_Body";
         return ZLocUtils.t("Quests",resource);
      }
      
      public function get rewardText() : String
      {
         var resource:String = this.m_textBundle + "_Reward";
         return ZLocUtils.t("Quests",resource);
      }
      
      public function get extraRewardText() : String
      {
         var resource:String = this.m_textBundle + "_ExtraReward";
         return ZLocUtils.t("Quests",resource);
      }
      
      public function get rewardShareButtonText() : String
      {
         var buttonText:String = "";
         var resource:String = this.m_textBundle + "_RewardShare";
         if(ZLocUtils.hasString("Quests",resource))
         {
            buttonText = ZLocUtils.t("Quests",resource);
         }
         else
         {
            buttonText = ZLocUtils.t("Dialogs","GenericShareButton");
         }
         return buttonText;
      }
      
      public function get chapterRewardTitle() : String
      {
         var resource:String = this.m_textBundle + "_BigRewardTitle";
         return ZLocUtils.t("Quests",resource);
      }
      
      public function get chapterRewardInfo() : String
      {
         var resource:String = this.m_textBundle + "_BigRewardInfo";
         return ZLocUtils.t("Quests",resource);
      }
      
      public function get chapterRewardImage() : String
      {
         return m_xml.frontend.chapterRewardImage.toString();
      }
      
      public function get chapterRewardThumbImage() : String
      {
         return m_xml.frontend.chapterRewardThumbImage.toString();
      }
      
      public function get chapterRewardThumbName() : String
      {
         var resource:String = this.m_textBundle + "_BigRewardPrizeName";
         return ZLocUtils.t("Quests",resource);
      }
      
      public function get completeShareFeedIcon() : String
      {
         var rewardItem:FarmItem = null;
         var iconPath:String = icon;
         if(this.m_completeShareFeedIcon != null && this.m_completeShareFeedIcon.length > 0)
         {
            if(this.m_completeShareFeedIcon == COMPLETE_SHARE_ICON_FRIEND_REWARD)
            {
               rewardItem = this.friendRewardItem;
               if(rewardItem)
               {
                  iconPath = rewardItem.iconRelativeUrl;
               }
            }
            else
            {
               iconPath = this.m_completeShareFeedIcon;
            }
         }
         return iconPath;
      }
      
      public function shouldShowIntro() : Boolean
      {
         var show:Boolean = false;
         if(this.m_introSeenFlag != null && this.m_introSeenFlag.length > 0)
         {
            show = !Global.player.getSeenFlag(this.m_introSeenFlag);
         }
         return show;
      }
      
      public function setIntroSeen() : void
      {
         if(this.m_introSeenFlag != null && this.m_introSeenFlag.length > 0)
         {
            Global.player.setSeenFlag(this.m_introSeenFlag);
         }
      }
      
      public function get displayIcon() : String
      {
         var child:Object = null;
         var questName:String = null;
         var quest:FarmQuest = null;
         var result:String = m_icon;
         if(!m_icon || m_icon.length == 0 || m_icon == ICON_NONE)
         {
            for each(child in this.m_children)
            {
               if(child.hasOwnProperty("value") && child.hasOwnProperty("type") && child["type"] == "Quest")
               {
                  questName = child["value"];
                  quest = (QuestSettingsInit.getInstance() as FarmQuestSettingsInit).getItemByName(questName) as FarmQuest;
                  if(quest)
                  {
                     result = quest.displayIcon;
                     if(Boolean(result) && result != ICON_NONE)
                     {
                        break;
                     }
                  }
               }
            }
         }
         return result;
      }
      
      public function getPurchaseDataAtIndex(index:int) : Object
      {
         var reward:Object = null;
         var item:FarmItem = null;
         var result:Object = null;
         reward = this.m_farmRewards[index];
         if(reward != null)
         {
            switch(reward.type)
            {
               case QuestConstants.REWARD_GRANT_BUSHEL_ITEM:
               case QuestConstants.REWARD_GRANT_BREEDING_ITEM:
               case QuestConstants.REWARD_GRANT_ITEM:
                  item = Global.farmGameSettingsManager.getFarmItemByCode(reward.value);
                  if(item != null && !item.isConsumable && !item.isBuildingPart())
                  {
                     result = new Object();
                     result.buyable = item.buyable;
                     result.marketType = item.market;
                     result.cost = item.cash;
                     result.item = item;
                  }
            }
         }
         return result;
      }
      
      public function getImageForRewardAtIndex(index:int) : String
      {
         var result:String = "";
         var reward:Object = this.m_farmRewards[index];
         if(reward != null)
         {
            result = UserRewardUtil.getImageForReward(reward);
         }
         return result;
      }
      
      public function getValueForRewardAtIndex(index:int) : String
      {
         var result:String = "";
         var reward:Object = this.m_farmRewards[index];
         if(reward != null)
         {
            result = UserRewardUtil.getValueForReward(reward);
         }
         return result;
      }
      
      public function get chapterTitle() : String
      {
         var chapterStr:String = null;
         if(!this.m_chatperTitle)
         {
            chapterStr = this.chapter < 10 ? "0" + this.chapter : this.chapter.toString();
            this.m_chatperTitle = ZLocUtils.getFailoverLocString([new ZLocFailoverEntry("Quests",this.chain + "-" + chapterStr + "_ChapterTitle"),new ZLocFailoverEntry("Quests",this.chain + "_ChapterTitle")]);
         }
         return this.m_chatperTitle;
      }
      
      public function get chain() : String
      {
         if(NOT_PARSED == this.m_chapter)
         {
            this.parseName();
         }
         return this.m_chain;
      }
      
      public function get chapter() : int
      {
         if(NOT_PARSED == this.m_chapter)
         {
            this.parseName();
         }
         return this.m_chapter;
      }
      
      public function get questNumber() : int
      {
         if(NOT_PARSED == this.m_chapter)
         {
            this.parseName();
         }
         return this.m_questNumber;
      }
      
      public function get location() : int
      {
         return this.m_location;
      }
      
      public function get totalLocations() : int
      {
         var result:int = 0;
         if(m_xml.mapLocation != null && m_xml.mapLocation != "")
         {
            result = int(m_xml.mapLocation.toString().split("-")[1]);
         }
         else
         {
            result = NOT_PARSED;
         }
         return result;
      }
      
      protected function parseName() : void
      {
         var split:Array = this.name.split("-");
         this.m_chapter = split[1];
         this.m_chain = split[0];
         this.m_questNumber = split[2];
      }
      
      public function get helpAction() : Object
      {
         if(null == this.m_helpAction)
         {
            if(m_xml.friendHelp != null && m_xml.friendHelp.@itemCode != "")
            {
               this.m_helpAction = {};
               this.m_helpAction.senderGold = m_xml.friendHelp.@senderGold;
               this.m_helpAction.itemCode = m_xml.friendHelp.@itemCode;
            }
         }
         return this.m_helpAction;
      }
      
      public function get category() : String
      {
         return this.m_category;
      }
      
      public function getW2WFeatureName() : String
      {
         return this.chain + W2W_FEATURE_SUFFIX;
      }
      
      public function getW2WFeedName(askOrSend:Boolean) : String
      {
         return m_name + (askOrSend ? W2W_ASK_FOR_HELP_SUFFIX : W2W_SEND_HELP_SUFFIX);
      }
      
      public function doesRequireServerResponse() : Boolean
      {
         var farmTask:FarmTask = null;
         var result:Boolean = false;
         for each(farmTask in this.farmTasks)
         {
            if(farmTask.doesRequireServerResponse() == true)
            {
               result = true;
               break;
            }
         }
         return result;
      }
      
      public function shouldShowExpiration() : Boolean
      {
         return !(Global.experimentManager.getExperimentVariant(Experiments.EXPERIEMNT_FLASH_UX_QUEST_DESURFACING) == 1 && this.progress == 0 && this.questNumber == 1);
      }
      
      public function shouldShowQuestRecaptureFlow() : Boolean
      {
         var xmlCheck:Boolean = false;
         var result:Boolean = false;
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_QUEST_RECAPTURE) >= 2)
         {
            xmlCheck = !(Boolean(m_xml.frontend) && (Boolean(m_xml.frontend.questRecaptureFlow) && m_xml.frontend.questRecaptureFlow.toString() == "false"));
            result = xmlCheck && !Global.player.getSeenSessionFlag("QuestRecaptureFlow");
         }
         return result;
      }
      
      public function shouldShowTimeLeftHUDSurfacing() : Boolean
      {
         return !(Global.experimentManager.getExperimentVariant(Experiments.EXPERIEMNT_FLASH_UX_QUEST_DESURFACING) == 1 && this.progress == 0 && this.questNumber == 1);
      }
      
      public function get nextChapter() : String
      {
         return this.m_nextChapter;
      }
      
      public function get previousChapter() : String
      {
         return this.m_prevChapter;
      }
      
      public function get introSeenFlag() : String
      {
         return this.m_introSeenFlag;
      }
      
      public function get chapterIcon() : String
      {
         return this.m_chapterIcon;
      }
      
      public function get customIntroWidget() : String
      {
         return this.m_customIntroWidget;
      }
      
      public function getSkipQuestCashCost() : int
      {
         var task:FarmTask = null;
         var discount:int = 0;
         var discountAsPercent:Number = NaN;
         var result:int = 0;
         var farmQuestSettingsInit:FarmQuestSettingsInit = FarmQuestSettingsInit.getInstance();
         var firstQuestNameInChain:String = farmQuestSettingsInit.questManagerGetNameOfFirstQuestInReplayableChain(this.name);
         var defaultTaskCashValue:int = 0;
         if(firstQuestNameInChain != null && firstQuestNameInChain != "")
         {
            defaultTaskCashValue = farmQuestSettingsInit.questManagerGetDefaultTaskCashValueForReplayableQuestChain(firstQuestNameInChain);
         }
         var numUncompletedTasks:int = 0;
         for each(task in this.m_farmTasks)
         {
            if(!task.isComplete())
            {
               numUncompletedTasks++;
               result += task.cashValue > 0 ? task.cashValue : defaultTaskCashValue;
            }
         }
         if(numUncompletedTasks > 0 && result <= 0)
         {
            throw new Error("getSkipQuestCashCost() should never return 0 if there are tasks that haven\'t been completed");
         }
         discount = this.getCashSkipDiscount();
         if(discount > 0)
         {
            discountAsPercent = (100 - discount) / 100;
            result = Math.round(result * discountAsPercent);
         }
         return result;
      }
      
      public function getCashSkipDiscount() : int
      {
         var farmTask:FarmTask = null;
         var discount:int = 0;
         var numUncompletedTasks:int = 0;
         if(!this.isQuestManagerReplayableQuest())
         {
            for each(farmTask in this.m_farmTasks)
            {
               if(!farmTask.isComplete())
               {
                  numUncompletedTasks++;
               }
            }
            if(numUncompletedTasks > 1)
            {
               discount = SKIP_ALL_DISCOUNT;
            }
         }
         return discount;
      }
      
      public function skipQuest() : Boolean
      {
         var cost:int = 0;
         var task:FarmTask = null;
         var skipped:Boolean = false;
         if(this.canBeSkipped())
         {
            cost = this.getSkipQuestCashCost();
            if(cost > 0 && Global.player.canBuyCash(cost))
            {
               TransactionManager.addTransaction(new TGenericTransaction("FarmQuestService","skipEntireQuest",null,[this.name]));
               Global.player.cash -= cost;
               for each(task in this.m_farmTasks)
               {
                  FarmQuestManager.getInstance().addRewardForTask(task,task.progress);
                  task.markComplete();
               }
               FarmQuestManager.getInstance().removeActiveQuestByName(this.name);
               if(this.children.length == 0)
               {
                  this.removeIconFromIconQueue();
               }
               skipped = true;
            }
         }
         return skipped;
      }
      
      public function canBeSkipped() : Boolean
      {
         var task:FarmTask = null;
         var result:Boolean = false;
         var numTasks:int = int(this.m_farmTasks.length);
         for(var i:int = 0; i < numTasks; i++)
         {
            task = this.m_farmTasks[i];
            if(task.canBeSkipped())
            {
               result = true;
               break;
            }
         }
         return result;
      }
      
      public function getArrowExpiryString() : String
      {
         var days:Number = 0;
         if(this.timeRemaining != FarmQuest.QUEST_TIME_DO_NOT_EXPIRE)
         {
            days = Math.floor(this.timeRemaining / FarmGameUtil.NUM_SECS_IN_DAY);
         }
         var arrowExpiryString:String = FarmGameUtil.getTimeLeftTextInDays(days);
         if(days == 0)
         {
            arrowExpiryString = ZLocUtils.t("Dialogs","ExpiringToday");
         }
         return arrowExpiryString;
      }
      
      public function get duration() : int
      {
         return int(Math.round((this.expirationTime - this.startTime) / (1000 * 60 * 60 * 24)));
      }
      
      public function get mouseOverFeatureEnabled() : Boolean
      {
         return (this.duration == 30 || this.duration == 14) && Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_QUEST_MOUSEOVER_TOOLTIP) >= 3;
      }
   }
}

