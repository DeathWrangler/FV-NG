package Managers
{
   import Classes.Constants.Experiments;
   import Classes.FeatureMessagingDefinition;
   import Classes.IMessagingFeature;
   import Events.FeatureMessageEvent;
   import flash.events.EventDispatcher;
   
   public class FeatureMessagingManager extends EventDispatcher
   {
      
      private static var m_canInstantiate:Boolean = false;
      
      private static var m_instance:FeatureMessagingManager = null;
      
      private var m_allFeatureDefinitions:Object;
      
      private var m_activeFeatureNames:Vector.<String>;
      
      private var m_initializedFeatures:Object = {};
      
      private var m_initializedFeatureComponents:Object = {};
      
      private var m_readyForUpdates:Boolean = false;
      
      private var m_queuedUpdates:Vector.<FeatureMessageEvent> = new Vector.<FeatureMessageEvent>();
      
      public function FeatureMessagingManager()
      {
         super();
         if(!m_canInstantiate)
         {
            throw new Error("Cannot call constructor directly - use getInstance() instead.");
         }
      }
      
      public static function getInstance() : FeatureMessagingManager
      {
         if(null == m_instance)
         {
            m_canInstantiate = true;
            m_instance = new FeatureMessagingManager();
            m_canInstantiate = false;
         }
         return m_instance;
      }
      
      public function loadXML(featureMessagingConfig:XMLList) : void
      {
         var featureDefinition:FeatureMessagingDefinition = null;
         var featureXML:XML = null;
         this.m_allFeatureDefinitions = {};
         for each(featureXML in featureMessagingConfig)
         {
            featureDefinition = new FeatureMessagingDefinition(featureXML);
            this.m_allFeatureDefinitions[featureDefinition.name] = featureDefinition;
         }
      }
      
      public function processFeatures() : void
      {
         var featureDefinition:FeatureMessagingDefinition = null;
         if(this.inExperiment())
         {
            this.m_activeFeatureNames = new Vector.<String>();
            for each(featureDefinition in this.m_allFeatureDefinitions)
            {
               if(featureDefinition.passesPrereqs())
               {
                  this.m_activeFeatureNames.push(featureDefinition.name);
                  if(featureDefinition.customInit)
                  {
                     featureDefinition.customInit.initialize();
                  }
                  featureDefinition.updateIconVisibility();
               }
            }
            this.m_readyForUpdates = true;
            this.processQueuedUpdates();
         }
      }
      
      public function isFeatureActive(featureName:String) : Boolean
      {
         return this.m_activeFeatureNames.indexOf(featureName) != -1;
      }
      
      public function registerFeatureInitialized(featureName:String, openFeatureUICallback:Function = null, featureComponent:IMessagingFeature = null) : void
      {
         this.m_initializedFeatures[featureName] = openFeatureUICallback;
         if(featureComponent)
         {
            this.m_initializedFeatureComponents[featureName] = featureComponent;
         }
      }
      
      public function unregisterFeatureInitialized(featureName:String) : void
      {
         var featureDef:FeatureMessagingDefinition = null;
         if(this.m_allFeatureDefinitions != null && this.m_allFeatureDefinitions.hasOwnProperty(featureName))
         {
            featureDef = this.m_allFeatureDefinitions[featureName];
            if(featureDef != null)
            {
               featureDef.updateIconVisibility();
            }
         }
         if(this.m_initializedFeatures.hasOwnProperty(featureName))
         {
            this.m_initializedFeatures[featureName] = null;
         }
         if(this.m_initializedFeatureComponents.hasOwnProperty(featureName))
         {
            this.m_initializedFeatureComponents[featureName] = null;
         }
      }
      
      public function isFeatureInitialized(featureName:String) : Boolean
      {
         return this.m_initializedFeatures[featureName] != null;
      }
      
      public function getFeatureDefinition(featureName:String) : FeatureMessagingDefinition
      {
         var result:FeatureMessagingDefinition = null;
         if(this.m_allFeatureDefinitions)
         {
            result = this.m_allFeatureDefinitions[featureName];
         }
         return result;
      }
      
      public function openFeatureUI(featureName:String) : void
      {
         if(Boolean(this.m_initializedFeatures[featureName]) && this.m_initializedFeatures[featureName] is Function)
         {
            (this.m_initializedFeatures[featureName] as Function)();
         }
      }
      
      public function isFeatureProgressComplete(featureName:String) : Boolean
      {
         var result:Boolean = false;
         var component:IMessagingFeature = this.m_initializedFeatureComponents[featureName] as IMessagingFeature;
         if(component)
         {
            result = component.isFeatureProgressComplete();
         }
         return result;
      }
      
      public function dispatchFeatureMessage(featureMessage:FeatureMessageEvent) : void
      {
         if(this.m_readyForUpdates)
         {
            dispatchEvent(featureMessage);
         }
         else
         {
            this.m_queuedUpdates.push(featureMessage);
         }
      }
      
      private function processQueuedUpdates() : void
      {
         var featureMessage:FeatureMessageEvent = null;
         for each(featureMessage in this.m_queuedUpdates)
         {
            dispatchEvent(featureMessage);
         }
         this.m_queuedUpdates = new Vector.<FeatureMessageEvent>();
      }
      
      private function inExperiment() : Boolean
      {
         var result:Boolean = false;
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_HUD_FOTW) == Experiments.VARIANT_HUD_FOTW_ON)
         {
            result = true;
         }
         return result;
      }
   }
}

