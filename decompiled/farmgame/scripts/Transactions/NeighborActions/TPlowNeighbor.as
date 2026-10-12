package Transactions.NeighborActions
{
   import Classes.Plot;
   
   public class TPlowNeighbor extends TBaseNeighborAction
   {
      
      public function TPlowNeighbor(plot:Plot)
      {
         m_actionType = "plow";
         super(plot);
      }
   }
}

