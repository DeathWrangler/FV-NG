package Classes
{
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmQuestManager;
   import Classes.Quest.FarmQuestSettingsInit;
   import Classes.Quest.FarmTask;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Events.FeatureMessageEvent;
   import Managers.FarmStatsManager;
   import Managers.FeatureMessagingManager;
   import Managers.FeatureTrackingManager;
   import Managers.TemplateUIUtility;
   import Managers.ToasterManager;
   import Widgets.Windows.IconTitleToasterWindow;
   import Widgets.Windows.Quests.MultiStageQuests.MultiStageQuestDialog;
   import ZQuest.Classes.Quest;
   import ZQuest.Events.QuestEvent;
   import ZQuest.Init.QuestSettingsInit;
   import ZQuest.Managers.QuestManager;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class QuestChainMapTrigger extends StationaryMapTrigger
   {
      
      protected var m_questMapping:Array = null;
      
      private var m_defaultState:String = "";
      
      protected var m_stage:Number = 1;
      
      protected var m_farmQuest:FarmQuest = null;
      
      private var m_lastQuestName:String = "";
      
      protected var m_expireView:String = "";
      
      private var m_ui:MultiStageQuestDialog = null;
      
      private var m_pendingUIShow:Boolean = false;
      
      private var m_pendingExpiredQuests:Array = new Array();
      
      private var m_currentDialogAsset:String = "";
      
      protected var m_assetPersistState:String = "";
      
      protected var m_persistTooltipKey:String = "";
      
      public function QuestChainMapTrigger(itemName:String, stateToSet:String = "static")
      {
         super(itemName,stateToSet);
         this.m_defaultState = stateToSet;
         QuestManager.getInstance().addEventListener(QuestEvent.COMPLETED,this.onQuestComplete);
         QuestManager.getInstance().addEventListener(QuestEvent.PROGRESS,this.onQuestUpdates);
         FarmQuestManager.getInstance().addEventListener(QuestEvent.EXPIRED,this.onQuestExpired);
      }
      
      override public function loadObject(data:Object) : void
      {
         super.loadObject(data);
         detach();
      }
      
      override public function loadXmlData(xmlData:XML) : void
      {
         var farmQuest:FarmQuest = null;
         var messagingManager:FeatureMessagingManager = null;
         var questToBuiltStateXml:XML = null;
         var questMap:Object = null;
         var textColorXml:XMLList = null;
         var dialogBackgroundXml:XMLList = null;
         var animatedSceneXml:XMLList = null;
         var lastQuestName:String = null;
         this.m_questMapping = new Array();
         var defaultDialogUrl:String = null;
         var defaultDialogUrlXml:XMLList = xmlData.child("dialogUrl");
         if(Boolean(defaultDialogUrlXml) && Boolean(defaultDialogUrlXml[0]))
         {
            defaultDialogUrl = defaultDialogUrlXml[0].toString();
         }
         var questsToBuiltStatesXml:XMLList = xmlData.child("questsToBuiltStates");
         if(questsToBuiltStatesXml.length() != 0)
         {
            for each(questToBuiltStateXml in questsToBuiltStatesXml[0].children())
            {
               if(questToBuiltStateXml.name() == "quest" && questToBuiltStateXml.attribute("questName") != "" && questToBuiltStateXml.attribute("state") != "" && !isNaN(parseInt(questToBuiltStateXml.attribute("stage").toString())))
               {
                  if(questToBuiltStateXml.attribute("expireTextBody").toString() != "")
                  {
                     questMap = {
                        "state":questToBuiltStateXml.attribute("state").toString(),
                        "stage":parseInt(questToBuiltStateXml.attribute("stage").toString()),
                        "expireView":true,
                        "expireIcon":questToBuiltStateXml.attribute("expireIcon").toString(),
                        "expireTextBody":questToBuiltStateXml.attribute("expireTextBody").toString()
                     };
                  }
                  else
                  {
                     questMap = {
                        "state":questToBuiltStateXml.attribute("state").toString(),
                        "stage":parseInt(questToBuiltStateXml.attribute("stage").toString()),
                        "expireView":false
                     };
                  }
                  if(questToBuiltStateXml.attribute("dialogUrl").toString() != "")
                  {
                     questMap.dialogUrl = questToBuiltStateXml.attribute("dialogUrl").toString();
                  }
                  else
                  {
                     questMap.dialogUrl = defaultDialogUrl;
                  }
                  if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.ESCAPADE))
                  {
                     textColorXml = xmlData.child("textColor");
                     if(Boolean(textColorXml) && Boolean(textColorXml[0]))
                     {
                        questMap.textColor = textColorXml[0].toString();
                     }
                     dialogBackgroundXml = xmlData.child("dialogBackground");
                     if(Boolean(dialogBackgroundXml) && Boolean(dialogBackgroundXml[0]))
                     {
                        questMap.dialogBackground = dialogBackgroundXml[0].toString();
                     }
                     animatedSceneXml = xmlData.child("animatedScene");
                     if(Boolean(animatedSceneXml) && Boolean(animatedSceneXml[0]))
                     {
                        questMap.animatedScene = animatedSceneXml[0].toString();
                     }
                     if(Boolean(questMap["textColor"]) && Boolean(questMap["dialogBackground"]) && Boolean(questMap["animatedScene"]))
                     {
                        questMap.dialogUrl = TemplateUIUtility.ESCAPADE_TEMPLATE_SWF;
                        questMap.templateUIenabled = true;
                     }
                  }
                  this.m_questMapping[questToBuiltStateXml.attribute("questName").toString()] = questMap;
               }
            }
         }
         if(xmlData.child("lastQuestName").length() > 0)
         {
            lastQuestName = xmlData.child("lastQuestName")[0].toString();
            if(this.m_questMapping.hasOwnProperty(lastQuestName))
            {
               this.m_lastQuestName = lastQuestName;
            }
         }
         if(xmlData.child("expireView").length() > 0)
         {
            this.m_expireView = xmlData.child("expireView")[0].toString();
         }
         if(xmlData.child("assetPersistState").length() > 0)
         {
            this.m_assetPersistState = xmlData.child("assetPersistState")[0].toString();
            if(xmlData.child("persistTooltipKey").length() > 0)
            {
               this.m_persistTooltipKey = xmlData.child("persistTooltipKey")[0].toString();
            }
         }
         if(xmlData.child("highlightColor").length() > 0)
         {
            highlightColor = xmlData.child("highlightColor")[0].toString();
         }
         this.updateStateAndStage();
         for each(farmQuest in this.m_pendingExpiredQuests)
         {
            this.showExpirationToaster(farmQuest);
         }
         messagingManager = FeatureMessagingManager.getInstance();
         if(messagingManager != null && this.m_farmQuest != null && "chain" in this.m_farmQuest)
         {
            messagingManager.registerFeatureInitialized(this.m_farmQuest.chain,this.showUI);
         }
         this.m_pendingExpiredQuests = new Array();
         if(this.m_farmQuest)
         {
            FarmStatsManager.sample(100,"fv_multistage",this.m_farmQuest.chain,"game_asset","view","stage_" + this.m_stage);
         }
      }
      
      protected function onQuestUpdates(event:QuestEvent) : void
      {
         var oldQuest:FarmQuest = null;
         if(Boolean(event) && event.hasOwnProperty("quest"))
         {
            oldQuest = this.m_farmQuest;
            this.updateStateAndStage();
            if(Boolean(this.m_farmQuest) && Boolean(oldQuest) && oldQuest != this.m_farmQuest)
            {
               if(event.quest is FarmQuest)
               {
                  FeatureMessagingManager.getInstance().dispatchFeatureMessage(new FeatureMessageEvent(FeatureMessageEvent.FEATURE_STATE_CHANGE,(event.quest as FarmQuest).chain));
               }
               if(this.m_ui != null && this.m_farmQuest != null)
               {
                  this.m_ui.setNewStage(this.m_farmQuest,this.m_stage);
               }
            }
         }
      }
      
      protected function onQuestComplete(event:QuestEvent) : void
      {
         if(Boolean(event) && Boolean(event.hasOwnProperty("quest")) && event.quest.hasOwnProperty("name"))
         {
            if(event.quest.name == this.m_lastQuestName)
            {
               this.unregisterMessagingManager();
               this.updateOrExpire(event);
            }
            else
            {
               if(event.quest is FarmQuest)
               {
                  FeatureMessagingManager.getInstance().dispatchFeatureMessage(new FeatureMessageEvent(FeatureMessageEvent.FEATURE_STATE_CHANGE,(event.quest as FarmQuest).chain));
               }
               this.updateStateAndStage();
            }
         }
      }
      
      private function unregisterMessagingManager() : void
      {
         if(this.m_farmQuest != null && "chain" in this.m_farmQuest)
         {
            FeatureMessagingManager.getInstance().unregisterFeatureInitialized(this.m_farmQuest.chain);
         }
      }
      
      private function onQuestExpired(event:QuestEvent) : void
      {
         if(Boolean(event) && event.hasOwnProperty("quest"))
         {
            if(this.m_questMapping != null)
            {
               this.showExpirationToaster(event.quest as FarmQuest);
               if(event.quest.name == this.m_lastQuestName)
               {
                  this.unregisterMessagingManager();
                  this.updateOrExpire(event);
               }
               else
               {
                  this.updateStateAndStage();
               }
            }
            else
            {
               this.m_pendingExpiredQuests.push(event.quest as FarmQuest);
            }
         }
      }
      
      protected function updateOrExpire(event:QuestEvent) : void
      {
         if(this.m_assetPersistState != "")
         {
            this.m_farmQuest = null;
            this.updateStateAndStage();
         }
         else
         {
            detach();
         }
      }
      
      protected function showExpirationToaster(farmQuest:FarmQuest) : void
      {
         var questData:Object = null;
         if(this.m_questMapping != null)
         {
            questData = this.m_questMapping[farmQuest.name];
            if(questData != null && questData["expireView"] == true && this.m_expireView != null && this.m_expireView != "")
            {
               ToasterManager.getInstance().add(new IconTitleToasterWindow(farmQuest.titleText,ZLocUtils.t("Dialogs",questData["expireTextBody"]),questData["expireIcon"],this.m_expireView,1,null,this.onclickExpiresToaster));
               FarmStatsManager.count("fv_multistage",farmQuest.chain,"toaster_expired","stage_" + questData["stage"]);
            }
         }
      }
      
      protected function updateStateAndStage() : void
      {
         var newState:String = null;
         var curFarmQuest:FarmQuest = this.findCurrentFarmQuest();
         if(curFarmQuest != null && !Global.worldManager.isVisiting())
         {
            if(this.m_farmQuest == null)
            {
               conditionallyReattach(true);
            }
            this.m_farmQuest = curFarmQuest;
            newState = this.m_questMapping[curFarmQuest.name].state;
            this.m_stage = this.m_questMapping[curFarmQuest.name].stage;
            if(newState != null)
            {
               setState(newState);
            }
            if(Boolean(this.m_ui) && this.m_currentDialogAsset != this.m_questMapping[curFarmQuest.name].dialogUrl)
            {
               this.m_ui.close();
               this.m_pendingUIShow = true;
            }
            if(this.m_pendingUIShow)
            {
               this.m_pendingUIShow = false;
               this.showUI();
            }
         }
         else if(this.m_assetPersistState != "")
         {
            setState(this.m_assetPersistState);
            conditionallyReattach();
         }
      }
      
      protected function findCurrentFarmQuest() : FarmQuest
      {
         var activeQuests:Vector.<Quest> = null;
         var farmQuest:FarmQuest = null;
         var result:FarmQuest = null;
         if(this.m_questMapping != null)
         {
            activeQuests = FarmQuestManager.getInstance().getActiveQuests();
            for each(farmQuest in activeQuests)
            {
               if(this.m_questMapping.hasOwnProperty(farmQuest.name) && FarmQuestManager.getInstance().isQuestActive(farmQuest.name))
               {
                  result = farmQuest;
                  break;
               }
            }
         }
         return result;
      }
      
      override public function cleanUp() : void
      {
         QuestManager.getInstance().removeEventListener(QuestEvent.COMPLETED,this.onQuestComplete);
         QuestManager.getInstance().removeEventListener(QuestEvent.PROGRESS,this.onQuestUpdates);
         FarmQuestManager.getInstance().removeEventListener(QuestEvent.EXPIRED,this.onQuestExpired);
         if(this.m_ui)
         {
            this.m_ui.removeEventListener(Event.CLOSE,this.closeUICallback);
         }
         super.cleanUp();
      }
      
      override public function onClick() : void
      {
         this.showUI();
      }
      
      public function showUI() : void
      {
         if(this.m_farmQuest != null && FarmQuestManager.getInstance().isQuestActive(this.m_farmQuest.name))
         {
            FarmStatsManager.count("fv_multistage",this.m_farmQuest.chain,"game_asset","click","stage_" + this.m_stage);
            this.m_currentDialogAsset = this.m_questMapping[this.m_farmQuest.name].dialogUrl;
            if(Boolean(this.m_questMapping[this.m_farmQuest.name]) && this.m_questMapping[this.m_farmQuest.name]["templateUIenabled"] == true)
            {
               this.m_ui = new MultiStageQuestDialog(this.m_farmQuest,this.m_stage,this.m_currentDialogAsset,this.m_questMapping[this.m_farmQuest.name]["textColor"],this.m_questMapping[this.m_farmQuest.name]["dialogBackground"],this.m_questMapping[this.m_farmQuest.name]["animatedScene"]);
            }
            else
            {
               this.m_ui = new MultiStageQuestDialog(this.m_farmQuest,this.m_stage,this.m_currentDialogAsset);
            }
            this.m_ui.addEventListener(Event.CLOSE,this.closeUICallback);
            UI.displayPopup(this.m_ui,true,this.name,this.name != "");
            FeatureTrackingManager.instance.uiOpen(this.m_farmQuest.chain);
         }
         else
         {
            this.m_pendingUIShow = true;
         }
      }
      
      private function closeUICallback(event:Event) : void
      {
         this.m_ui.removeEventListener(Event.CLOSE,this.closeUICallback);
         this.m_ui = null;
      }
      
      override public function getCurrentImageName() : String
      {
         return state;
      }
      
      override protected function updateToolTipText() : void
      {
         var timeLeftSeconds:Number = NaN;
         var timeLeftString:String = null;
         var completedTaskItems:Number = NaN;
         var totalTaskItems:Number = NaN;
         var farmtask:FarmTask = null;
         var toolTip:String = "";
         if(this.m_farmQuest != null)
         {
            toolTip = this.m_farmQuest.titleText + "\n";
            timeLeftSeconds = (this.m_farmQuest.expirationTime - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
            if(timeLeftSeconds < 0)
            {
               timeLeftSeconds = 0;
            }
            timeLeftString = FarmGameUtil.toFriendlyTime(timeLeftSeconds);
            if(this.m_farmQuest.farmTasks.length == 1 && this.m_farmQuest.farmTasks[0].action == "waitOrPay")
            {
               toolTip += ZLocUtils.t("Dialogs","MultiStageQuest_" + this.m_farmQuest.chain + "_WaitingToolTip",{"timeLeft":timeLeftString});
            }
            else
            {
               toolTip += ZLocUtils.t("Dialogs","MultiStageQuest_" + this.m_farmQuest.chain + "_stage" + this.m_stage + "Indicator");
               completedTaskItems = 0;
               totalTaskItems = 0;
               for each(farmtask in this.m_farmQuest.farmTasks)
               {
                  completedTaskItems += farmtask.progress;
                  totalTaskItems += farmtask.total;
               }
               toolTip += ZLocUtils.t("Dialogs","MultiStageQuestGeneric_ProgressToolTip",{
                  "quantity":completedTaskItems,
                  "needed":totalTaskItems
               });
               toolTip += ZLocUtils.t("Dialogs","MultiStageQuestGeneric_TimeRemainingToolTip",{"timeLeft":timeLeftString});
            }
         }
         else if(this.m_assetPersistState != "" && this.m_persistTooltipKey != "")
         {
            if(this.isQuestChainFinished())
            {
               toolTip = ZLocUtils.t("Dialogs",this.m_persistTooltipKey);
            }
            else
            {
               toolTip = ZLocUtils.t("Dialogs","MultiStageQuest_" + this.name + "_InitializingToolTip");
            }
         }
         setToolTip(toolTip);
         updateToolTipPosition();
      }
      
      protected function isQuestChainFinished() : Boolean
      {
         var isLastQuestComplete:Boolean = FarmQuestManager.getInstance().isQuestComplete(this.m_lastQuestName);
         var lastQuest:FarmQuest = (QuestSettingsInit.getInstance() as FarmQuestSettingsInit).getItemByName(this.m_lastQuestName) as FarmQuest;
         var isLastQuestExpired:Boolean = false;
         if(lastQuest)
         {
            isLastQuestExpired = GlobalEngine.serverTime > lastQuest.expirationTime;
         }
         else
         {
            isLastQuestExpired = true;
         }
         return isLastQuestComplete || isLastQuestExpired;
      }
      
      private function onclickExpiresToaster(event:MouseEvent) : void
      {
         if(!Global.worldManager.isVisiting())
         {
            this.showUI();
         }
      }
      
      override public function stop() : void
      {
         pause();
      }
   }
}

