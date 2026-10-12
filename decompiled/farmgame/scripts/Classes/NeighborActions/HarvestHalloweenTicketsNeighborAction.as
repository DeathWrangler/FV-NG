package Classes.NeighborActions
{
   import Classes.HalloweenCastleDuckulaBuilding;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Transactions.NeighborActions.THarvestHalloweenTickets;
   
   public class HarvestHalloweenTicketsNeighborAction extends BaseNeighborAction
   {
      
      public function HarvestHalloweenTicketsNeighborAction(castleDuckula:HalloweenCastleDuckulaBuilding)
      {
         super(castleDuckula);
      }
      
      override protected function getType() : String
      {
         return NeighborActionConstants.ACTION_TYPE_HARVEST_HALLOWEEN_TICKETS;
      }
      
      override public function getLimitType() : String
      {
         return NeighborActionConstants.LIMIT_TYPE_HARVEST_HALLOWEEN_TICKETS;
      }
      
      override public function execute() : void
      {
         var castleDuckula:HalloweenCastleDuckulaBuilding = this.m_object as HalloweenCastleDuckulaBuilding;
         if(castleDuckula)
         {
            TransactionManager.addTransaction(new THarvestHalloweenTickets(castleDuckula));
            Global.selectedAvatar.displayStatus(ZLocUtils.t("FarmGame","Status_HarvestHalloweenTickets",{"quantity":(castleDuckula.storageLevel + 2) / 3}));
         }
      }
   }
}

