package Managers
{
   import Classes.Constants.Experiments;
   import DataSources.BaseDataSource;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.external.ExternalInterface;
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   
   public class ExperimentManager extends EventDispatcher
   {
      
      private static var m_initialized:Boolean = false;
      
      protected static var m_variantList:Dictionary = new Dictionary();
      
      public static const EVENT_SERVER_VARIANTS_LOADED:String = "server_variants_loaded";
      
      public function ExperimentManager()
      {
         super();
      }
      
      public static function getItemExperimentFromXml(itemXml:XML, itemData:BaseDataSource = null) : String
      {
         var experiment:String = null;
         var experimentGate:* = undefined;
         var isEmpty:Boolean = false;
         var data:* = undefined;
         if(itemData)
         {
            experiment = itemData.getString("experiment");
            if(experiment == "")
            {
               experimentGate = itemData.getData("experimentGate");
               if(Boolean(experimentGate) && getQualifiedClassName(experimentGate) == "String")
               {
                  experiment = itemData.getString("experimentGate");
               }
               else
               {
                  isEmpty = true;
                  var _loc7_:int = 0;
                  var _loc8_:* = experimentGate;
                  for(data in _loc8_)
                  {
                     isEmpty = false;
                  }
                  if(!isEmpty)
                  {
                     experiment = experimentGate.toString();
                  }
               }
            }
         }
         else
         {
            experiment = itemXml.@experiment;
            if(experiment == "")
            {
               experiment = itemXml.experimentGate;
            }
         }
         return experiment;
      }
      
      public static function getItemExperimentVariantsFromXml(itemXml:XML, itemData:BaseDataSource = null) : Array
      {
         var variants:String = null;
         var variantsArray:Array = null;
         var i:int = 0;
         if(itemData)
         {
            variants = itemData.getString("experimentVariant");
         }
         else
         {
            variants = itemXml.@experimentVariant;
            if(variants == "")
            {
               variants = itemXml.experimentVariant;
            }
         }
         var result:Array = new Array();
         if(variants != "")
         {
            variantsArray = variants.split(",");
            for(i = 0; i < variantsArray.length; i++)
            {
               result.push(Number(variantsArray[i]));
            }
         }
         return result;
      }
      
      public static function isOrganicMainExperimentOn() : Boolean
      {
         return Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_PLANET_ORGANIC) == 3;
      }
      
      public function get initialized() : Boolean
      {
         return m_initialized;
      }
      
      public function checkAndLoadExperiments() : void
      {
         var experimentData:Object = null;
         if(!m_initialized && ExternalInterface.available)
         {
            experimentData = ExternalInterface.call("getExperiments");
            this.loadServerVariants(experimentData);
         }
      }
      
      public function loadServerVariants(experiments:Object) : void
      {
         var variant:int = 0;
         var experiment:String = null;
         var foundVariant:Boolean = false;
         if(experiments)
         {
            for(experiment in experiments)
            {
               variant = int(experiments[experiment]);
               this.setVariant(experiment,variant);
               foundVariant = true;
            }
         }
         if(foundVariant)
         {
            m_initialized = true;
            dispatchEvent(new Event(ExperimentManager.EVENT_SERVER_VARIANTS_LOADED));
         }
      }
      
      public function getAllExperiments() : Dictionary
      {
         this.checkAndLoadExperiments();
         return m_variantList;
      }
      
      public function setVariant(exp:String, variant:int) : void
      {
         m_variantList[exp] = variant;
      }
      
      public function getExperimentVariant(name:String) : int
      {
         this.checkAndLoadExperiments();
         var variant:int = 0;
         if(m_variantList.hasOwnProperty(name))
         {
            variant = int(m_variantList[name]);
         }
         else
         {
            GlobalEngine.log("Experiment",name + " not found on front-end. Please check that you named your constant beginning with EXPERIMENT_FLASH_ in Experiments.class.php");
         }
         return variant;
      }
      
      public function hasExperimentVariant(name:String) : Boolean
      {
         this.checkAndLoadExperiments();
         var result:Boolean = false;
         if(m_variantList[name] != null)
         {
            result = true;
         }
         return result;
      }
   }
}

