package Classes.Idle
{
   import Classes.Constants.Experiments;
   import Display.RetentionItemPopup;
   import Managers.RetentionMasterManager;
   
   public class RetentionItemPopupIdleTask extends BaseIdleTask
   {
      
      public function RetentionItemPopupIdleTask(params:Object = null)
      {
         super();
      }
      
      override public function fire() : void
      {
         RetentionItemPopup.conditionallyShow();
      }
      
      override public function get shouldAdd() : Boolean
      {
         var variant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_RETENTION_FREE_ORCHARD);
         return RetentionMasterManager.inMasterExperiment() && variant == 2;
      }
   }
}

