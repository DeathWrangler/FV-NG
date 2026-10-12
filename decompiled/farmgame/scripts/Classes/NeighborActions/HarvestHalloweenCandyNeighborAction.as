package Classes.NeighborActions
{
   import Classes.HalloweenHauntedHouseBuilding;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Transactions.NeighborActions.THarvestHalloweenCandy;
   
   public class HarvestHalloweenCandyNeighborAction extends BaseNeighborAction
   {
      
      public function HarvestHalloweenCandyNeighborAction(hauntedHouse:HalloweenHauntedHouseBuilding)
      {
         super(hauntedHouse);
      }
      
      override protected function getType() : String
      {
         return NeighborActionConstants.ACTION_TYPE_HARVEST_HALLOWEEN_CANDY;
      }
      
      override public function getLimitType() : String
      {
         return NeighborActionConstants.LIMIT_TYPE_HARVEST_HALLOWEEN_CANDY;
      }
      
      override public function execute() : void
      {
         var hauntedHouse:HalloweenHauntedHouseBuilding = this.m_object as HalloweenHauntedHouseBuilding;
         if(hauntedHouse)
         {
            TransactionManager.addTransaction(new THarvestHalloweenCandy(hauntedHouse));
            Global.selectedAvatar.displayStatus(ZLocUtils.t("FarmGame","Status_HarvestHalloweenCandy",{"quantity":hauntedHouse.storageLevel}));
         }
      }
   }
}

