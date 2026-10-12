package Init.PostInitActionHandlers
{
   import Classes.Constants.Experiments;
   import Managers.PostInitSettings;
   
   public class PrizeMachinePostInitAction extends AbstractPostInitAction
   {
      
      public function PrizeMachinePostInitAction(callback:Function = null)
      {
         super(callback);
      }
      
      override public function execute() : void
      {
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_PRIZE_MACHINE) >= 3)
         {
            PostInitSettings.showPrizeMachineWindow();
         }
         m_isFinished = true;
      }
   }
}

