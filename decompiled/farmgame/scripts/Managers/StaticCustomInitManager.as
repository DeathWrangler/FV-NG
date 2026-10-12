package Managers
{
   import Classes.IFeatureMessagingCustomInit;
   import Classes.util.FarmGameUtil;
   import Engine.Managers.ErrorManager;
   import flash.utils.getDefinitionByName;
   
   public class StaticCustomInitManager implements IFeatureMessagingCustomInit
   {
      
      private var m_customInitFeatureName:String;
      
      private var m_callbackClassPath:String;
      
      private var m_staticCallbackFunction:String;
      
      private var m_optionalParam:String;
      
      public function StaticCustomInitManager(featureXML:XML)
      {
         super();
         this.m_customInitFeatureName = featureXML.attribute("name").toString();
         this.m_callbackClassPath = featureXML.customInit.attribute("callbackClassPath").toString();
         this.m_staticCallbackFunction = featureXML.customInit.attribute("staticCallbackFunction").toString();
         this.m_optionalParam = featureXML.customInit.attribute("optionalParam").toString();
      }
      
      public function initialize() : void
      {
         var classDefinition:Class = null;
         var functionToUse:Function = null;
         if(Boolean(this.m_customInitFeatureName) && Boolean(this.m_callbackClassPath) && Boolean(this.m_staticCallbackFunction))
         {
            try
            {
               classDefinition = getDefinitionByName(this.m_callbackClassPath) as Class;
            }
            catch(e:Error)
            {
               ErrorManager.addError(ErrorManager.getFormattedErrorMessage("Invalid class path: ","callbackClassPath=" + m_callbackClassPath,"staticCallbackFunction=" + m_staticCallbackFunction));
            }
            if(Boolean(classDefinition) && Boolean(classDefinition[this.m_staticCallbackFunction]))
            {
               if(this.m_optionalParam)
               {
                  functionToUse = FarmGameUtil.applyPartialStatic(classDefinition[this.m_staticCallbackFunction],[this.m_optionalParam]);
               }
               else
               {
                  functionToUse = classDefinition[this.m_staticCallbackFunction];
               }
            }
            FeatureMessagingManager.getInstance().registerFeatureInitialized(this.m_customInitFeatureName,functionToUse);
         }
      }
   }
}

