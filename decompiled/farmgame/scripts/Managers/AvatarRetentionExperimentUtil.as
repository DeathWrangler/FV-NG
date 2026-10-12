package Managers
{
   import Classes.Constants.Experiments;
   
   public class AvatarRetentionExperimentUtil
   {
      
      protected static var s_inLockedExperiment:Boolean;
      
      protected static var s_inNoWaitExperiment:Boolean;
      
      protected static var s_initialized:Boolean = false;
      
      public function AvatarRetentionExperimentUtil()
      {
         super();
      }
      
      public static function init() : void
      {
         var variant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FAST_HARVEST);
         s_inLockedExperiment = RetentionMasterManager.inMasterExperiment() && (variant == 2 || variant == 3 || variant == 5 || variant == 6);
         s_inNoWaitExperiment = RetentionMasterManager.inMasterExperiment() && (variant == 5 || variant == 6);
         s_initialized = true;
      }
      
      public static function inLockedExperiment() : Boolean
      {
         if(s_initialized == false)
         {
            init();
         }
         return s_inLockedExperiment;
      }
      
      public static function inNoWaitExperiment() : Boolean
      {
         if(s_initialized == false)
         {
            init();
         }
         return s_inNoWaitExperiment;
      }
   }
}

