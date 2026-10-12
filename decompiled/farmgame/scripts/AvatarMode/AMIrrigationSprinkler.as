package AvatarMode
{
   import Classes.Avatar.FarmAvatar;
   import Classes.Equipment;
   import Classes.Plot;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Managers.IrrigationManager;
   import Transactions.TIrrigationAction;
   import flash.geom.Point;
   
   public class AMIrrigationSprinkler extends AMEquipment
   {
      
      public function AMIrrigationSprinkler(avatar:FarmAvatar, plots:Array, equipment:Equipment, centerPos:Point)
      {
         super(avatar,plots,equipment,centerPos);
      }
      
      override public function update(delta:Number) : void
      {
         var progress:Number = NaN;
         if(m_actionStarted)
         {
            m_actionTime += delta;
            progress = m_actionTime / Global.farmGameSettingsManager.getNumber("plantTime");
            if(progress > 1)
            {
               this.executeServiceCall();
               m_avatar.getStateMachine().removeState(this);
            }
         }
      }
      
      private function executeServiceCall() : void
      {
         var plot:Plot = null;
         var validPlots:Array = [];
         for each(plot in m_plots)
         {
            validPlots.push({"id":plot.getId()});
            plot.waterHarvestableResource(0.5);
         }
         FarmStatsManager.count("water","sprinkler","water_crops");
         TransactionManager.addTransaction(new TIrrigationAction(IrrigationManager.WATER_PLOTS,validPlots,this.onServiceCallCompletion));
      }
      
      private function onServiceCallCompletion(result:Object) : void
      {
      }
   }
}

