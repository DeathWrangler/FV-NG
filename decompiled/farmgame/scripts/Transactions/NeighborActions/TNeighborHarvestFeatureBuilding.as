package Transactions.NeighborActions
{
   import Classes.FeatureBuilding;
   import Classes.NeighborActions.NeighborActionConstants;
   
   public class TNeighborHarvestFeatureBuilding extends TBaseNeighborAction
   {
      
      public function TNeighborHarvestFeatureBuilding(building:FeatureBuilding)
      {
         m_actionType = NeighborActionConstants.ACTION_TYPE_NEIGHBOR_HARVEST_FEATURE_BUILDING;
         super(building,building.harvester.getTHarvestExtraParams());
      }
      
      override protected function onComplete(result:Object) : void
      {
         var building:FeatureBuilding = m_object as FeatureBuilding;
         if(building)
         {
            building.onHarvestComplete(result);
         }
      }
   }
}

