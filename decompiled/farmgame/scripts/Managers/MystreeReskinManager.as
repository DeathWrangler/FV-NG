package Managers
{
   import flash.events.Event;
   import flash.utils.Dictionary;
   
   public class MystreeReskinManager
   {
      
      protected static var m_instance:Dictionary = new Dictionary();
      
      private static var m_initialized:Boolean = false;
      
      public static const PLOT_STATE_EMPTY:int = 0;
      
      public function MystreeReskinManager(featureName:String)
      {
         super();
         m_initialized = true;
         FeatureOptionsManager.getInstance().addEventListener(FeatureOptionsManager.EVENT_FEATURE_OPTIONS_UPDATED,this.updateStateFromServer);
      }
      
      public static function getInstance(featureName:String) : IMystreeReskinManager
      {
         var supportsEMH:String = null;
         var useManagerWithEMH:Boolean = false;
         var featureXML:XML = Global.farmGameSettingsManager.getFeatureXML(featureName);
         if(featureXML != null)
         {
            m_initialized = true;
            supportsEMH = featureXML.supportsEMH.toString();
            if(supportsEMH == "yes")
            {
               useManagerWithEMH = true;
            }
         }
         if(useManagerWithEMH)
         {
            return MystreeReskinManagerWithEMH.getInstance(featureName);
         }
         return MystreeReskinManagerWithoutEMH.getInstance(featureName);
      }
      
      public function isInitialized() : Boolean
      {
         return m_initialized;
      }
      
      private function updateStateFromServer(e:Event) : void
      {
      }
   }
}

