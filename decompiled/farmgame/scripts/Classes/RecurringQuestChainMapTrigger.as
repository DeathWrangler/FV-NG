package Classes
{
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmQuestManager;
   import Classes.Quest.FarmQuestSettingsInit;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsManager;
   import Managers.ToasterManager;
   import Widgets.Windows.GenericQuestWithRewardWindow;
   import Widgets.Windows.IconTitleToasterWindow;
   import ZQuest.Events.QuestEvent;
   import ZQuest.Init.QuestSettingsInit;
   
   public class RecurringQuestChainMapTrigger extends QuestChainMapTrigger
   {
      
      private static const LAST_QUEST_PROGRESSED:String = "last_quest_progressed";
      
      private static const FEATUREOPTIONS_NAME:String = "sashagrocer";
      
      protected var m_nextQuest:FarmQuest = null;
      
      protected var m_chainOrder:Array = null;
      
      public function RecurringQuestChainMapTrigger(itemName:String, stateToSet:String = "static")
      {
         super(itemName,stateToSet);
      }
      
      override public function showUI() : void
      {
         if(m_farmQuest != null && FarmQuestManager.getInstance().isQuestActive(m_farmQuest.name))
         {
            GenericQuestWithRewardWindow.showWindow(m_farmQuest.name,m_questMapping[m_farmQuest.name].dialogUrl);
         }
      }
      
      override public function onClick() : void
      {
         super.onClick();
         if(m_farmQuest)
         {
            FarmStatsManager.count(m_farmQuest.chain,"npc_station","click");
         }
      }
      
      override public function loadXmlData(xmlData:XML) : void
      {
         var questToBuiltStateXml:XML = null;
         super.loadXmlData(xmlData);
         var questsToBuiltStatesXml:XMLList = xmlData.child("questsToBuiltStates");
         if(questsToBuiltStatesXml.length() != 0 && m_questMapping != null)
         {
            this.m_chainOrder = new Array();
            for each(questToBuiltStateXml in questsToBuiltStatesXml[0].children())
            {
               if(questToBuiltStateXml.name() == "quest" && questToBuiltStateXml.attribute("questName") != "")
               {
                  this.m_chainOrder.push(questToBuiltStateXml.attribute("questName").toString());
               }
            }
         }
      }
      
      override protected function updateOrExpire(event:QuestEvent) : void
      {
         super.updateOrExpire(event);
         m_farmQuest = findCurrentFarmQuest();
         if(m_farmQuest == null)
         {
            this.setNextQuest();
         }
      }
      
      override protected function onQuestUpdates(event:QuestEvent) : void
      {
         if(m_farmQuest != null && m_farmQuest.name == (event.quest as FarmQuest).name)
         {
            FeatureOptionsManager.getInstance().setFeatureOption(FEATUREOPTIONS_NAME,LAST_QUEST_PROGRESSED,m_farmQuest.name);
            FeatureOptionsManager.getInstance().save();
         }
         super.onQuestUpdates(event);
      }
      
      override protected function updateStateAndStage() : void
      {
         super.updateStateAndStage();
         m_farmQuest = findCurrentFarmQuest();
         if(m_farmQuest == null)
         {
            this.setNextQuest();
         }
      }
      
      private function setNextQuest() : void
      {
         var questName:String = null;
         var quest:FarmQuest = null;
         var now:Number = GlobalEngine.serverTime;
         if(m_farmQuest == null)
         {
            if(m_questMapping != null && this.m_chainOrder != null)
            {
               for each(questName in this.m_chainOrder)
               {
                  quest = (QuestSettingsInit.getInstance() as FarmQuestSettingsInit).getItemByName(questName) as FarmQuest;
                  if(Boolean(quest) && Boolean(!FarmQuestManager.getInstance().isQuestActive(questName)) && quest.startTime > now)
                  {
                     this.m_nextQuest = quest;
                     break;
                  }
               }
            }
         }
      }
      
      private function timeTillNextQuest() : String
      {
         var secondsLeft:Number = NaN;
         var timeLeftFriendlyName:String = "";
         var nextQuest:FarmQuest = this.m_nextQuest;
         if(!nextQuest)
         {
            this.setNextQuest();
         }
         if(nextQuest)
         {
            secondsLeft = (nextQuest.startTime - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
            timeLeftFriendlyName = FarmGameUtil.toFriendlyTime(secondsLeft);
         }
         return timeLeftFriendlyName;
      }
      
      override protected function updateToolTipText() : void
      {
         var timeLeftSeconds:Number = NaN;
         var timeLeftString:String = null;
         var progress:Number = NaN;
         var total:Number = NaN;
         var toolTip:String = "";
         if(this.m_farmQuest != null)
         {
            timeLeftSeconds = (m_farmQuest.expirationTime - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
            if(timeLeftSeconds < 0)
            {
               timeLeftSeconds = 0;
            }
            timeLeftString = FarmGameUtil.toFriendlyTime(timeLeftSeconds);
            if(m_farmQuest.farmTasks.length == 1 && m_farmQuest.farmTasks[0].action == "waitOrPay")
            {
               toolTip += ZLocUtils.t("Dialogs","MultiStageQuest_" + m_farmQuest.chain + "_WaitingToolTip",{"timeLeft":timeLeftString});
            }
            else
            {
               toolTip += ZLocUtils.t("Dialogs","MultiStageQuest_" + m_farmQuest.chain + "_stage" + m_stage + "Indicator");
               progress = m_farmQuest.numOfCompletedTasks;
               total = m_farmQuest.tasks.length;
               toolTip += ZLocUtils.t("Dialogs","MultiStageQuestGeneric_ProgressToolTip",{
                  "quantity":progress,
                  "needed":total
               });
               toolTip += ZLocUtils.t("Dialogs","MultiStageQuestGeneric_TimeRemainingToolTip",{"timeLeft":timeLeftString});
            }
         }
         else if(m_assetPersistState != "" && m_persistTooltipKey != "")
         {
            if(isQuestChainFinished())
            {
               toolTip = ZLocUtils.t("Dialogs",m_persistTooltipKey + "Finished");
            }
            else
            {
               toolTip = ZLocUtils.t("Dialogs",m_persistTooltipKey,{"time":this.timeTillNextQuest()});
            }
         }
         setToolTip(toolTip);
         updateToolTipPosition();
      }
      
      override protected function showExpirationToaster(farmQuest:FarmQuest) : void
      {
         var lastProgressedQuestInChain:Object = null;
         var questData:Object = null;
         var title:String = null;
         var timeLeftFriendlyName:String = null;
         var childQuest:FarmQuest = null;
         var secondsLeft:Number = NaN;
         var text:String = "";
         if(m_questMapping != null && m_farmQuest == null)
         {
            lastProgressedQuestInChain = FeatureOptionsManager.getInstance().getFeatureOption(FEATUREOPTIONS_NAME,LAST_QUEST_PROGRESSED);
            questData = m_questMapping[farmQuest.name];
            if(Boolean(questData != null && questData["expireView"] == true && m_expireView != null && m_expireView != "") && Boolean(lastProgressedQuestInChain) && lastProgressedQuestInChain as String == farmQuest.name)
            {
               title = ZLocUtils.t("Dialogs",farmQuest.chain + "_ExpireTitle");
               timeLeftFriendlyName = "";
               childQuest = FarmQuestManager.getInstance().getFirstChildQuest(farmQuest);
               if(childQuest)
               {
                  secondsLeft = (childQuest.startTime - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
                  timeLeftFriendlyName = FarmGameUtil.toFriendlyTime(secondsLeft);
               }
               if(timeLeftFriendlyName != "")
               {
                  text = ZLocUtils.t("Dialogs",questData["expireTextBody"],{"timeLeft":timeLeftFriendlyName});
               }
               else
               {
                  text = ZLocUtils.t("Dialogs",questData["expireTextBody"]);
               }
               ToasterManager.getInstance().add(new IconTitleToasterWindow(title,text,"",m_expireView,1,null));
            }
         }
      }
   }
}

