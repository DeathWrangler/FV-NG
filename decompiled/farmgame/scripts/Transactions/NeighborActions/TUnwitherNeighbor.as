package Transactions.NeighborActions
{
   import Classes.Plot;
   
   public class TUnwitherNeighbor extends TBaseNeighborAction
   {
      
      public function TUnwitherNeighbor(plot:Plot)
      {
         m_actionType = "unwither";
         super(plot);
      }
   }
}

