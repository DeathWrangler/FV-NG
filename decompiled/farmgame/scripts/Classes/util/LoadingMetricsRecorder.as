package Classes.util
{
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   import flash.utils.describeType;
   
   public class LoadingMetricsRecorder
   {
      
      private static var m_instance:LoadingMetricsRecorder;
      
      public const KEY_LOADTIME_FLASHCONTROLLER:String = "req_FlashControllerStartTimestamp";
      
      public const KEY_LOADTIME_INITUSER:String = "req_initUserStartTimestamp";
      
      public const KEY_LOADTIME_POSTINIT:String = "req_postInitEndTimestamp";
      
      public const KEY_LOADTIME_POSTINIT_COMPLETE_START:String = "req_postInitCompleteStartFlashTime";
      
      public const KEY_LOADTIME_POSTINIT_COMPLETE_END:String = "req_postInitCompleteEndFlashTime";
      
      public const KEY_MEM_CONSTRUCTION:String = "req_memConstruction";
      
      public const KEY_MEM_PVT_CONSTRUCTION:String = "req_pvtMemConstruction";
      
      public const OPT_MEM_NUM_CONSTRUCTION:String = "opt_memConstruction";
      
      public const KEY_MEM_GAME_INIT:String = "req_memGameInit";
      
      public const KEY_MEM_PVT_GAME_INIT:String = "req_pvtMemGameInit";
      
      public const OPT_MEM_NUM_GAME_INIT:String = "opt_memGameInit";
      
      public const KEY_MEM_INTERACTIVE_PHASE:String = "req_memInteractivePhase";
      
      public const KEY_MEM_PVT_INTERACTIVE_PHASE:String = "req_pvtMemInteractivePhase";
      
      public const OPT_MEM_NUM_INTERACTIVE_PHASE:String = "opt_memInteractivePhase";
      
      public const KEY_MEM_MILESTONE_INTERACTIVE_PHASE:String = "req_milestoneInteractivePhase";
      
      public const KEY_MEM_LOAD_COMPLETE_PHASE:String = "req_memLoadCompletePhase";
      
      public const KEY_MEM_PVT_LOAD_COMPLETE_PHASE:String = "req_pvtMemLoadCompletePhase";
      
      public const OPT_MEM_NUM_LOAD_COMPLETE_PHASE:String = "opt_memLoadCompletePhase";
      
      public const KEY_MEM_MILESTONE_LOAD_COMPLETE_PHASE:String = "req_milestoneLoadCompletePhase";
      
      public const KEY_MEM_ITEMS_PARSED:String = "req_memItemsParsed";
      
      public const KEY_MEM_PVT_ITEMS_PARSED:String = "req_pvtMemItemsParsed";
      
      public const OPT_MEM_NUM_ITEMS_PARSED:String = "opt_memItemsParsed";
      
      public const KEY_MEM_MILESTONE_ITEMS_PARSED:String = "req_milestoneItemsParsed";
      
      public const KEY_METADATA_WORLD:String = "req_worldMetadata";
      
      public const LOADTIME_OBJECT_INDEX:String = "loadtimeIdx";
      
      public const MEMORY_OBJECT_INDEX:String = "memoryIdx";
      
      public const MEMORY_TIME_OBJECT_INDEX:String = "memoryTimeIdx";
      
      public const METADATA_OBJECT_INDEX:String = "metadataIdx";
      
      private var m_metricsDefinedCount:int;
      
      private var m_timingMetrics:Object;
      
      private var m_memoryMetrics:Object;
      
      private var m_memoryTimestampMetrics:Object;
      
      private var m_metadata:Object;
      
      private var m_optionalValues:Object;
      
      private var m_totalMetricCount:int;
      
      public function LoadingMetricsRecorder()
      {
         super();
         this.m_timingMetrics = new Object();
         this.m_memoryMetrics = new Object();
         this.m_memoryTimestampMetrics = new Object();
         this.m_metadata = new Object();
         this.m_optionalValues = new Object();
         this.m_totalMetricCount = 0;
         this.getMetricsDefinedCount();
      }
      
      public static function getInstance() : LoadingMetricsRecorder
      {
         if(m_instance == null)
         {
            m_instance = new LoadingMetricsRecorder();
         }
         return m_instance;
      }
      
      private function addMetricHelper(metricObject:Object, metricKey:String, metricValue:*) : Boolean
      {
         var objToSend:Object = null;
         var optStr:String = null;
         var metricAdded:Boolean = false;
         if(metricObject[metricKey] == null)
         {
            metricObject[metricKey] = metricValue;
            metricAdded = true;
            if(this.isMetricRequired(metricKey))
            {
               ++this.m_totalMetricCount;
            }
            if(this.shouldTriggerTransaction())
            {
               objToSend = new Object();
               objToSend[this.LOADTIME_OBJECT_INDEX] = this.m_timingMetrics;
               objToSend[this.MEMORY_OBJECT_INDEX] = this.m_memoryMetrics;
               objToSend[this.MEMORY_TIME_OBJECT_INDEX] = this.m_memoryTimestampMetrics;
               objToSend[this.METADATA_OBJECT_INDEX] = this.m_metadata;
               TransactionManager.addTransaction(new TGenericTransaction("LoadingMetricsRecorderService","recordMetrics",null,[objToSend]));
               optStr = this.optionalValuesToString();
               if(optStr.length > 0)
               {
                  FarmGameUtil.reportClientLog("peakMeasuredLoadMemory is negative(" + optStr + ")");
               }
            }
         }
         return metricAdded;
      }
      
      private function optionalValuesToString() : String
      {
         var key:String = null;
         var retStr:String = "";
         for(key in this.m_optionalValues)
         {
            retStr += key + "=\"" + this.m_optionalValues[key] + "\", ";
         }
         return retStr;
      }
      
      public function addOptionalMetric(metricKey:String, metricValue:*) : Boolean
      {
         return this.addMetricHelper(this.m_optionalValues,metricKey,metricValue);
      }
      
      public function addMemoryMetric(metricKey:String, metricValue:Number) : Boolean
      {
         return this.addMetricHelper(this.m_memoryMetrics,metricKey,metricValue);
      }
      
      public function addMemoryTimestampMetric(metricKey:String, metricValue:String) : Boolean
      {
         return this.addMetricHelper(this.m_memoryTimestampMetrics,metricKey,metricValue);
      }
      
      public function addTimingMetric(metricKey:String, metricValue:String) : Boolean
      {
         return this.addMetricHelper(this.m_timingMetrics,metricKey,metricValue);
      }
      
      public function addMetadata(metadataKey:String, metadataValue:String) : Boolean
      {
         return this.addMetricHelper(this.m_metadata,metadataKey,metadataValue);
      }
      
      private function shouldTriggerTransaction() : Boolean
      {
         var shouldTrigger:Boolean = false;
         return this.m_totalMetricCount >= this.m_metricsDefinedCount;
      }
      
      private function isMetricRequired(metricName:String) : Boolean
      {
         var isRequired:Boolean = false;
         if(metricName.indexOf("req_") == 0)
         {
            isRequired = true;
         }
         return isRequired;
      }
      
      private function getMetricsDefinedCount() : int
      {
         var variable:XML = null;
         var constName:String = null;
         var constVal:String = null;
         this.m_metricsDefinedCount = 0;
         var typeXml:XML = describeType(this);
         for each(variable in typeXml.constant)
         {
            constName = variable.@name.toString();
            constVal = this[constName];
            if(this.isMetricRequired(constVal))
            {
               ++this.m_metricsDefinedCount;
            }
         }
         return this.m_metricsDefinedCount;
      }
   }
}

