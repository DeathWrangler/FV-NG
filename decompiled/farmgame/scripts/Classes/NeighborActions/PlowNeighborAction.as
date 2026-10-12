package Classes.NeighborActions
{
   import Classes.NeighborVisitAvatar;
   import Classes.Plot;
   import Engine.Classes.WorldObject;
   import Engine.Managers.TransactionManager;
   import Transactions.NeighborActions.TPlowNeighbor;
   
   public class PlowNeighborAction extends BaseNeighborAction
   {
      
      public function PlowNeighborAction(plot:Plot)
      {
         super(plot);
      }
      
      override protected function getType() : String
      {
         return NeighborActionConstants.ACTION_TYPE_PLOW;
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
               if(plot.isPlowable())
               {
                  plot.executeNeighborPlow(neighborId);
                  objectFound = true;
               }
            }
         }
         if(!objectFound)
         {
            super.redeem(neighborId,neighborAvatar);
         }
      }
      
      override public function getRedeemXpYield() : Number
      {
         return Global.farmGameSettingsManager.getInt("plowXp",1);
      }
      
      override public function execute() : void
      {
         var plot:Plot = this.m_object as Plot;
         if(plot)
         {
            plot.executePlow();
            TransactionManager.addTransaction(new TPlowNeighbor(plot));
            super.execute();
         }
      }
      
      override protected function getExecuteXpYield() : int
      {
         return Global.farmGameSettingsManager.getInt("neighborPlowBonusXp",1);
      }
      
      override protected function getExecuteCoinYield() : int
      {
         return Global.farmGameSettingsManager.getInt("neighborPlowBonusGold",10);
      }
   }
}

