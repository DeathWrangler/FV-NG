package Classes.NeighborActions
{
   import Classes.NeighborVisitAvatar;
   import Classes.Plot;
   import Engine.Classes.WorldObject;
   import Engine.Managers.TransactionManager;
   import Transactions.NeighborActions.TUnwitherNeighbor;
   
   public class UnwitherNeighborAction extends BaseNeighborAction
   {
      
      public function UnwitherNeighborAction(plot:Plot)
      {
         super(plot);
      }
      
      override protected function getType() : String
      {
         return NeighborActionConstants.ACTION_TYPE_UNWITHER;
      }
      
      override public function execute() : void
      {
         var plot:Plot = this.m_object as Plot;
         if(plot)
         {
            plot.executeUnwither();
            TransactionManager.addTransaction(new TUnwitherNeighbor(plot));
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
               if(plot.isWithered())
               {
                  plot.redeemNeighborUnwither(neighborId,this.getRedeemXpYield(),this.getRedeemCoinYield());
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
         return Global.farmGameSettingsManager.getInt("unwitherXpReward",1);
      }
      
      override protected function getExecuteCoinYield() : int
      {
         return Global.farmGameSettingsManager.getInt("unwitherGoldReward",10);
      }
   }
}

