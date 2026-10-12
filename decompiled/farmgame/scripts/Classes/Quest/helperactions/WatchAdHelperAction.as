package Classes.Quest.helperactions
{
   import Classes.Constants.QuestConstants;
   import Classes.Idle.IdleTaskQueue;
   import Classes.Idle.WatchAdWhenAvailableIdleTask;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Managers.InGameConsole.ConsoleAmexTreeCommandsModule;
   import Transactions.Quests.TIncrementGenericFarmTask;
   
   public class WatchAdHelperAction extends QuestHelperAction
   {
      
      protected var m_placementId:String;
      
      public function WatchAdHelperAction(questName:String, placementId:String)
      {
         super(questName);
         m_shouldCloseOnPerform = true;
         this.m_placementId = placementId;
      }
      
      override public function perform() : void
      {
         var placeId:String = this.m_placementId;
         if(ConsoleAmexTreeCommandsModule.altPlacementId != "")
         {
            placeId = ConsoleAmexTreeCommandsModule.altPlacementId;
         }
         IdleTaskQueue.getInstance().addTask(new WatchAdWhenAvailableIdleTask(placeId));
         TransactionManager.addTransaction(new TIncrementGenericFarmTask(QuestConstants.ACTION_WATCH_AD));
         super.perform();
      }
      
      override public function get readableText() : String
      {
         return ZLocUtils.t("Quests","Helper_WatchAd_Button");
      }
   }
}

