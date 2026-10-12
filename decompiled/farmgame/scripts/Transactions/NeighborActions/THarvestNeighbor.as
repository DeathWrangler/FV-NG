package Transactions.NeighborActions
{
   import Classes.SimpleHarvestableResource;
   
   public class THarvestNeighbor extends TBaseNeighborAction
   {
      
      public function THarvestNeighbor(resource:SimpleHarvestableResource)
      {
         m_actionType = "harvest";
         super(resource);
      }
   }
}

