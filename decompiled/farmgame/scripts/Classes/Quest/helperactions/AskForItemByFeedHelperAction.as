package Classes.Quest.helperactions
{
   import Classes.Constants.Experiments;
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmQuestManager;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureTrackingManager;
   import Transactions.Quests.TAskForQuestItem;
   import Transactions.Quests.TRecordQuestItemRequest;
   import ZQuest.Init.QuestSettingsInit;
   import by.blooddy.crypto.MD5;
   import flash.external.ExternalInterface;
   
   public class AskForItemByFeedHelperAction extends ItemHelperAction
   {
      
      protected var m_taskIndex:int = 0;
      
      protected var m_actionCountKey:String = "";
      
      private var m_pendingRewardId:String = null;
      
      protected var m_timeRequestedAt:String = null;
      
      private var m_statsSampleRate:int = 100;
      
      protected var m_outstandingTransaction:Boolean = false;
      
      public function AskForItemByFeedHelperAction(questName:String, itemName:String, actionCountKey:String, taskIndex:int)
      {
         super(questName,itemName);
         this.m_taskIndex = taskIndex;
         this.m_actionCountKey = actionCountKey;
         this.m_statsSampleRate = parseInt(GlobalEngine.getFlashVar("QUEST_FEED_STATS_SAMPLE") as String);
      }
      
      override public function canPerform() : Boolean
      {
         var currentQuest:FarmQuest = null;
         var result:Boolean = true;
         var actionLimit:int = Global.farmGameSettingsManager.getInt(this.m_actionCountKey + this.getIntervalLimitSuffix(),1);
         var timeInterval:int = Global.farmGameSettingsManager.getInt(this.m_actionCountKey + this.getTimeIntervalSuffix(),21600);
         var currentCount:int = Global.player.getIntervalActionCount(this.m_actionCountKey,timeInterval);
         if(currentCount >= actionLimit)
         {
            result = false;
         }
         var askForItemOOSVariant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_QUEST_ASK_FOR_ITEM);
         if(askForItemOOSVariant > 0)
         {
            currentQuest = FarmQuestManager.getInstance().getActiveQuestByName(m_questName);
            if(currentQuest)
            {
               result = currentQuest.timeRemaining == 0 ? false : result;
            }
         }
         return result;
      }
      
      override public function perform() : void
      {
         super.perform();
         if(!this.m_outstandingTransaction)
         {
            this.m_outstandingTransaction = true;
            TransactionManager.addTransaction(new TAskForQuestItem(this,m_questName,this.m_taskIndex),true);
         }
         else
         {
            FarmStatsManager.sample(this.m_statsSampleRate,"quest_feed_post","perform","trancastion_already_queued",m_questName,this.m_taskIndex.toString());
         }
      }
      
      public function postFeed(result:Object) : void
      {
         var data:Object;
         var callBackName:String = null;
         var key:String = null;
         this.m_outstandingTransaction = false;
         data = result.data;
         if(Boolean(data) && Boolean(data.showFeedDialog))
         {
            if(Boolean(data.attachment) && Boolean(data.actionLink) && Boolean(data.userMessagePrompt))
            {
               this.m_timeRequestedAt = result.ts;
               callBackName = "feedPostCallback";
               FarmStatsManager.sample(this.m_statsSampleRate,"quest_feed_post","postFeedV2","js_call","queued",m_questName);
               try
               {
                  callBackName = "feedPostCallback_" + MD5.hash(data.actionLink[0].href);
               }
               catch(error:Error)
               {
                  FarmStatsManager.sample(m_statsSampleRate,"quest_feed_post","postFeedV2","js_call_queued","exception_quest_feed_substr");
               }
               ExternalInterface.addCallback(callBackName,this.feedPostCallback);
               GlobalEngine.socialNetwork.streamPublish(data.attachment,data.actionLink,null,data.userMessagePrompt);
            }
            else
            {
               if(Config.DEBUG_MODE)
               {
                  key = "";
                  if(this.m_actionCountKey)
                  {
                     key = this.m_actionCountKey;
                  }
                  ErrorManager.addError("UserMessagePrompt, actionLink or attachment is missing for: " + key);
               }
               FarmStatsManager.sample(this.m_statsSampleRate,"quest_feed_post","errors","postFeedV2","invalid_feeddata",m_questName);
               this.handleCallback(false);
            }
         }
         else if(Boolean(data) && Boolean(data.published))
         {
            Global.player.incrementIntervalActionCount(this.m_actionCountKey,Global.farmGameSettingsManager.getInt(this.m_actionCountKey + this.getTimeIntervalSuffix(),21600));
            this.resetAskButton();
            this.handleCallback(true);
            GlobalEngine.socialNetwork.feedPostConfirmation(data);
         }
         else
         {
            FarmStatsManager.sample(this.m_statsSampleRate,"quest_feed_post","errors","postFeedV2","invalid_feeddata_or_showfeed",m_questName);
            this.handleCallback(false);
         }
      }
      
      protected function handleCallback(success:Boolean) : void
      {
         var farmQuest:FarmQuest = null;
         if(success)
         {
            farmQuest = QuestSettingsInit.getInstance().getItemByName(m_questName) as FarmQuest;
            if(farmQuest)
            {
               FeatureTrackingManager.instance.postFeed(farmQuest.chain);
            }
         }
         if(m_callback != null)
         {
            m_callback(success);
         }
      }
      
      public function feedPostCallback(result:Object) : void
      {
         var postSuccess:Boolean = false;
         if(Boolean(result.result) && Boolean(result.postId) && Boolean(result.callBackName))
         {
            if(result.result == "posted")
            {
               TransactionManager.addTransaction(new TRecordQuestItemRequest(m_questName,this.m_taskIndex,this.m_timeRequestedAt));
               Global.player.incrementIntervalActionCount(this.m_actionCountKey,Global.farmGameSettingsManager.getInt(this.m_actionCountKey + this.getTimeIntervalSuffix(),21600));
               FarmStatsManager.sample(this.m_statsSampleRate,"quest_feed_post","js_callback","success",result.result,result.postId);
            }
            else
            {
               FarmStatsManager.sample(this.m_statsSampleRate,"quest_feed_post","errors","js_callback","not_posted",result.result,result.postId);
            }
            this.resetAskButton();
            postSuccess = true;
            ExternalInterface.addCallback(result.callBackName,null);
         }
         else
         {
            FarmStatsManager.sample(this.m_statsSampleRate,"quest_feed_post","errors","js_callback","malformed_result");
         }
         this.handleCallback(postSuccess);
      }
      
      private function resetAskButton() : void
      {
         if(Boolean(m_progressDialog) && m_progressDialog["setAskButtonState"] != null)
         {
            m_progressDialog.setAskButtonState();
         }
      }
      
      override public function get readableText() : String
      {
         var actionLimit:int = 0;
         var timeInterval:int = 0;
         var currentCount:Number = NaN;
         var hoursRemaining:int = 0;
         var result:String = "";
         if(this.canPerform() == true)
         {
            result = ZLocUtils.t("Quests","Helper_AskForHelp_Button");
         }
         else
         {
            actionLimit = Global.farmGameSettingsManager.getInt(this.m_actionCountKey + this.getIntervalLimitSuffix(),1);
            timeInterval = Global.farmGameSettingsManager.getInt(this.m_actionCountKey + this.getTimeIntervalSuffix(),21600);
            currentCount = Global.player.getTimeForIntervalActionCount(this.m_actionCountKey,timeInterval);
            hoursRemaining = currentCount / FarmGameUtil.NUM_SECS_IN_HOUR;
            if(hoursRemaining > 0)
            {
               result = ZLocUtils.t("Quests","Helper_AskForHelp_Button_Wait",{
                  "quantity":hoursRemaining,
                  "hourword":ZLocUtils.tk("SocialMission","hr_word","",hoursRemaining)
               });
            }
            else
            {
               result = ZLocUtils.t("Quests","Helper_AskForHelp_Button_Wait_Less_Than_Hour");
            }
         }
         return result;
      }
      
      protected function getTimeIntervalSuffix() : String
      {
         return "_TimeInterval";
      }
      
      private function getIntervalLimitSuffix() : String
      {
         return "_IntervalLimit";
      }
   }
}

