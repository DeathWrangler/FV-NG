package Classes.Quest.helperactions
{
   import Classes.Constants.Experiments;
   import Classes.Constants.MFSConstants;
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmQuestManager;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Managers.FeatureTrackingManager;
   import Managers.MFSRequestManager;
   import ZQuest.Init.QuestSettingsInit;
   
   public class AskForItemByMFSRequestHelperAction extends ItemHelperAction
   {
      
      private const FEATURE_NAME:String = "questR4R";
      
      private var m_actionCountKey:String;
      
      private var m_taskIndex:int;
      
      public function AskForItemByMFSRequestHelperAction(questName:String, itemName:String, actionCountKey:String, taskIndex:int)
      {
         super(questName,itemName);
         this.m_actionCountKey = actionCountKey;
         this.m_taskIndex = taskIndex;
      }
      
      override public function perform() : void
      {
         super.perform();
         MFSRequestManager.getInstance().makeAskItemsRequest(this.FEATURE_NAME,itemName,"","",MFSConstants.SOURCE_DIALOG_CLICKED,null,null,"","","","",m_callback);
         var farmQuest:FarmQuest = QuestSettingsInit.getInstance().getItemByName(m_questName) as FarmQuest;
         if(farmQuest)
         {
            FeatureTrackingManager.instance.sendR4R(farmQuest.chain);
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
      
      protected function getTimeIntervalSuffix() : String
      {
         return "_TimeInterval_mfs";
      }
      
      private function getIntervalLimitSuffix() : String
      {
         return "_IntervalLimit_mfs";
      }
   }
}

