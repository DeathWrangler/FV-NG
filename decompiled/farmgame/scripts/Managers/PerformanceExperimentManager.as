package Managers
{
   import Classes.Constants.Experiments;
   
   public class PerformanceExperimentManager
   {
      
      private static var m_isMasterLoadTimeVariantInitialized:Boolean = false;
      
      private static var m_isMasterFrameRateVariantInitialized:Boolean = false;
      
      private static var m_isDefconHideExperimentInitialized:Boolean = false;
      
      private static var m_isInDefconHideExperiment:Boolean = false;
      
      private static var m_isBuildtimeConfigExperimentInitialized:Boolean = false;
      
      private static var m_isInBuildtimeConfigExperiment:Boolean = false;
      
      private static var m_isAnimationMemoryExperimentInitialized:Boolean = false;
      
      private static var m_isMultipleBuildableSwfsExperimentInitialized:Boolean = false;
      
      private static var m_isInAnimationMemoryExperiment:Boolean = false;
      
      private static var m_isInMultipleBuildableSwfsExperiment:Boolean = false;
      
      private static var m_isRasterMetadataExperimentInitialized:Boolean = false;
      
      private static var m_isInRasterMetadataExperiment:Boolean = false;
      
      private static var m_isInOptimizedSwfExperimentInitialized:Boolean = false;
      
      private static var m_isInOptimizedSwfExperiment:Boolean = false;
      
      private static var m_isInOptimizedSwfQAExperiment:Boolean = false;
      
      private static var m_isExtremePerformanceLimiterExperimentInitialized:Boolean = false;
      
      private static var m_isInExtremePerformanceLimiterExperiment:Boolean = false;
      
      private static var m_isInterruptFreeItemParsingExperimentInitialized:Boolean = false;
      
      private static var m_isInInterruptFreeItemParsingExperiment:Boolean = false;
      
      public function PerformanceExperimentManager()
      {
         super();
      }
      
      public static function get isInBuildtimeConfigExperiment() : Boolean
      {
         var variant:int = 0;
         if(!m_isBuildtimeConfigExperimentInitialized)
         {
            if(!GlobalEngine.getFlashVar("config_swf_disabled"))
            {
               Global.experimentManager.checkAndLoadExperiments();
               variant = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_PERF_BUILDTIME_CONFIG);
               m_isInBuildtimeConfigExperiment = variant == 3 || variant == 4;
            }
            m_isBuildtimeConfigExperimentInitialized = true;
         }
         return m_isInBuildtimeConfigExperiment;
      }
      
      public static function get isInMultipleBuildableSwfsExperiment() : Boolean
      {
         var variant:int = 0;
         if(!m_isMultipleBuildableSwfsExperimentInitialized && Global.experimentManager.initialized)
         {
            variant = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_PERF_MULTIPLE_BUILDABLES_SWFS);
            m_isInMultipleBuildableSwfsExperiment = variant == 3 || variant == 4;
            m_isMultipleBuildableSwfsExperimentInitialized = true;
         }
         return m_isInMultipleBuildableSwfsExperiment;
      }
      
      public static function get isInDefconHideExperiment() : Boolean
      {
         var variant:int = 0;
         if(!m_isDefconHideExperimentInitialized && Global.experimentManager.initialized)
         {
            variant = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_DEFCON_HIDE);
            m_isInDefconHideExperiment = variant == 1;
            m_isDefconHideExperimentInitialized = true;
         }
         return m_isInDefconHideExperiment;
      }
      
      public static function get isInRasterMetadataExperiment() : Boolean
      {
         var variant:int = 0;
         if(!m_isRasterMetadataExperimentInitialized && Global.experimentManager.initialized)
         {
            variant = Global.eosManager.getEosVariant(Experiments.EXPERIMENT_PERF_ANIM_RASTER_METADATA);
            m_isInRasterMetadataExperiment = variant == 3 || variant == 4;
            m_isRasterMetadataExperimentInitialized = true;
         }
         return m_isInRasterMetadataExperiment;
      }
      
      public static function get isInFriendManagerJSONExperiment() : Boolean
      {
         var result:Boolean = false;
         var variant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_PERF_FRIEND_MANAGER_JSON);
         return variant == 2;
      }
      
      public static function get isInOptimizedSwfExperiment() : Boolean
      {
         var variant:int = 0;
         var variant2:int = 0;
         if(!m_isInOptimizedSwfExperimentInitialized && Global.experimentManager.initialized)
         {
            variant = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_PERF_OPTIMIZED_SWF);
            m_isInOptimizedSwfExperiment = variant == 3 || variant == 4;
            variant2 = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_PERF_OPTIMIZED_SWF_QA);
            m_isInOptimizedSwfQAExperiment = variant2 == 3 || variant2 == 4;
            m_isInOptimizedSwfExperimentInitialized = true;
         }
         return m_isInOptimizedSwfExperiment;
      }
      
      public static function get isInOptimizedSwfQAExperiment() : Boolean
      {
         return m_isInOptimizedSwfQAExperiment;
      }
      
      public static function get isInAnimationMemoryExperiment() : Boolean
      {
         var variant:int = 0;
         if(!m_isAnimationMemoryExperimentInitialized && Global.experimentManager.initialized)
         {
            variant = Global.experimentManager.getExperimentVariant("fv_perf_animation_memory");
            m_isInAnimationMemoryExperiment = variant == 3 || variant == 4;
            m_isAnimationMemoryExperimentInitialized = true;
         }
         return m_isInAnimationMemoryExperiment;
      }
      
      public static function get isInExtremePerformanceLimiterExperiment() : Boolean
      {
         var variant:int = 0;
         if(!m_isExtremePerformanceLimiterExperimentInitialized && Global.experimentManager.initialized)
         {
            variant = Global.experimentManager.getExperimentVariant("fv_perf_extreme_limit");
            m_isInExtremePerformanceLimiterExperiment = variant == 3 || variant == 4;
            m_isExtremePerformanceLimiterExperimentInitialized = true;
         }
         return m_isInExtremePerformanceLimiterExperiment;
      }
      
      public static function get isInInterruptFreeItemParsingExperiment() : Boolean
      {
         var variant:int = 0;
         if(!m_isInterruptFreeItemParsingExperimentInitialized && Global.experimentManager.initialized)
         {
            variant = Global.experimentManager.getExperimentVariant("fv_perf_interrupt_free_item_parse");
            m_isInInterruptFreeItemParsingExperiment = variant == 3 || variant == 4;
            m_isInterruptFreeItemParsingExperimentInitialized = true;
         }
         return m_isInInterruptFreeItemParsingExperiment;
      }
      
      public static function get isInQuestCategoriesExperiment() : Boolean
      {
         var variant:int = 0;
         if(Global.experimentManager.initialized)
         {
            variant = Global.experimentManager.getExperimentVariant("fv_ops_use_farmconfig_qstcategories");
         }
         return variant == 1;
      }
   }
}

