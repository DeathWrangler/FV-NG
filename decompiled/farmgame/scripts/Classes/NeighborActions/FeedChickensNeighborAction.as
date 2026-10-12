package Classes.NeighborActions
{
   import Classes.ChickenCoopBuilding;
   import Classes.VisitorManager;
   import Engine.Managers.TransactionManager;
   import Transactions.NeighborActions.TFeedChickens;
   
   public class FeedChickensNeighborAction extends BaseNeighborAction
   {
      
      public function FeedChickensNeighborAction(chickenCoop:ChickenCoopBuilding)
      {
         super(chickenCoop);
      }
      
      override protected function getType() : String
      {
         return NeighborActionConstants.ACTION_TYPE_FEED_CHICKENS;
      }
      
      override public function getLimitType() : String
      {
         return NeighborActionConstants.LIMIT_TYPE_FEED_ACTION;
      }
      
      override public function execute() : void
      {
         var chickenCoop:ChickenCoopBuilding = this.m_object as ChickenCoopBuilding;
         if(chickenCoop)
         {
            TransactionManager.addTransaction(new TFeedChickens(chickenCoop));
            Global.hud.visitIconQueue.removeIconByName(VisitorManager.HUD_ICON_FEED_CHICKENS);
            super.execute();
         }
      }
      
      override protected function getExecuteXpYield() : int
      {
         return Global.farmGameSettingsManager.getInt("feedAnimalSuccessXpGain",1);
      }
      
      override protected function getExecuteCoinYield() : int
      {
         return Global.farmGameSettingsManager.getInt("feedAnimalSuccessCoinGain",10);
      }
   }
}

