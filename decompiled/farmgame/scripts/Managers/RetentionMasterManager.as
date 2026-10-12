package Managers
{
   import Classes.Constants.Experiments;
   import Classes.Doobers.Doober;
   
   public class RetentionMasterManager
   {
      
      private static var m_masterExperimentVariant:int = -1;
      
      public function RetentionMasterManager()
      {
         super();
      }
      
      public static function inMasterExperiment() : Boolean
      {
         if(m_masterExperimentVariant == -1)
         {
            m_masterExperimentVariant = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_RETENTION_MASTER);
         }
         return m_masterExperimentVariant == 2;
      }
      
      public static function shouldSuppressHarvestStatusText() : Boolean
      {
         var hoobersVariant:int = 0;
         var result:Boolean = false;
         if(inMasterExperiment())
         {
            hoobersVariant = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_HOOBERS);
            if(hoobersVariant == 2 || hoobersVariant == 3)
            {
               result = DefconManager.defconLevel < Doober.NO_DOOBER_DEFCON_LEVEL;
            }
            else if(hoobersVariant == 5 || hoobersVariant == 6)
            {
               result = true;
            }
         }
         return result;
      }
   }
}

