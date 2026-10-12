package Classes.NeighborActions
{
   import Classes.NeighborVisitAvatar;
   import Classes.Plot;
   import Engine.Classes.WorldObject;
   import Engine.Managers.TransactionManager;
   import Transactions.NeighborActions.TFertilizeNeighbor;
   
   public class FertNeighborAction extends BaseNeighborAction
   {
      
      public function FertNeighborAction(plot:Plot)
      {
         super(plot);
      }
      
      override protected function getType() : String
      {
         return NeighborActionConstants.ACTION_TYPE_FERT;
      }
      
      override public function execute() : void
      {
         var plot:Plot = this.m_object as Plot;
         if(plot)
         {
            plot.executeFertilize();
            TransactionManager.addTransaction(new TFertilizeNeighbor(plot));
            super.execute();
         }
      }
      
      override public function redeem(neighborId:String, neighborAvatar:NeighborVisitAvatar) : void
      {
         var plot:Plot = null;
         var objectFound:Boolean = false;
         var workedObject:WorldObject = Global.world.getObjectById(this.getWorkedObject().getId());
         if(workedObject)
         {
            plot = workedObject as Plot;
            if(plot)
            {
               if(plot.isFertilizable())
               {
                  plot.redeemNeighborFertilize(neighborId,this.getRedeemXpYield(),this.getRedeemCoinYield());
                  objectFound = true;
               }
            }
         }
         if(!objectFound)
         {
            super.redeem(neighborId,neighborAvatar);
         }
      }
      
      override protected function getExecuteXpYield() : int
      {
         return Global.farmGameSettingsManager.getInt("fertilizeSuccessXpGain");
      }
      
      override protected function getExecuteCoinYield() : int
      {
         return Global.farmGameSettingsManager.getInt("fertilizeSuccessCoinGain",10);
      }
   }
}

