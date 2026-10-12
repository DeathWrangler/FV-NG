package Classes.NeighborActions
{
   import Classes.FeatureBuilding;
   import Engine.Managers.TransactionManager;
   import Transactions.NeighborActions.TNeighborHarvestFeatureBuilding;
   
   public class HarvestFeatureBuildingNeighborAction extends BaseNeighborAction
   {
      
      public function HarvestFeatureBuildingNeighborAction(building:FeatureBuilding)
      {
         super(building);
      }
      
      override protected function getType() : String
      {
         return NeighborActionConstants.LIMIT_TYPE_DYNAMIC;
      }
      
      override public function getLimitType() : String
      {
         return NeighborActionConstants.LIMIT_TYPE_DYNAMIC;
      }
      
      override public function getActionKey() : String
      {
         return (m_object as FeatureBuilding).neighborActionManager.key;
      }
      
      override public function execute() : void
      {
         var building:FeatureBuilding = m_object as FeatureBuilding;
         if(building)
         {
            building.harvester.onPreHarvest();
            TransactionManager.addTransaction(new TNeighborHarvestFeatureBuilding(building));
            building.doHarvestDropOff(Global.player.avatar);
         }
      }
   }
}

