package Widgets.Windows
{
   import Classes.PrereqDrivenWindowComponent;
   import Classes.Quest.PrerequisiteUtility;
   import Engine.Managers.ErrorManager;
   import Managers.BaseFeatureManager;
   
   public class PrereqDrivenWindow extends FarmWindow
   {
      
      protected var m_featureName:String;
      
      protected var m_baseFeatureManager:BaseFeatureManager;
      
      private var m_components:Vector.<PrereqDrivenWindowComponent> = new Vector.<PrereqDrivenWindowComponent>();
      
      public function PrereqDrivenWindow(featureName:String)
      {
         this.m_featureName = featureName;
         this.m_baseFeatureManager = this.manager;
         super(this.m_baseFeatureManager.getConstantsStringWithKey("assetPath"));
         this.parseConfig();
      }
      
      protected function get manager() : BaseFeatureManager
      {
         return BaseFeatureManager.getInstance(this.m_featureName);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         this.refreshWindow();
      }
      
      override public function refreshWindow() : void
      {
         var component:PrereqDrivenWindowComponent = null;
         var end:int = 0;
         var mcIndex:int = 0;
         var mcKey:String = null;
         super.refreshWindow();
         if(m_window)
         {
            for each(component in this.m_components)
            {
               end = component.end;
               for(mcIndex = component.start; mcIndex <= end; mcIndex++)
               {
                  mcKey = component.prefix + mcIndex + component.suffix;
                  if(m_window[mcKey])
                  {
                     if(PrerequisiteUtility.checkPrereqByName(this.m_featureName + "_" + mcKey))
                     {
                        m_window[mcKey].visible = true;
                        if(component.breakOnTrue)
                        {
                           break;
                        }
                     }
                     else
                     {
                        m_window[mcKey].visible = false;
                     }
                  }
               }
            }
         }
      }
      
      private function parseConfig() : void
      {
         var config:XML = null;
         var mcKeys:XMLList = null;
         var mcKey:XML = null;
         var prefix:String = null;
         var suffix:String = null;
         var start:int = 0;
         var end:int = 0;
         var breakOnTrue:Boolean = false;
         var startNumber:Number = NaN;
         var endNumber:Number = NaN;
         if(this.m_baseFeatureManager)
         {
            config = this.m_baseFeatureManager.featureConfig;
            if(Boolean(config) && config.mcKeys.mcKey.toString() != "")
            {
               mcKeys = config.mcKeys.mcKey;
               for each(mcKey in mcKeys)
               {
                  if(mcKey.@prefix.toString() != "")
                  {
                     prefix = mcKey.@prefix.toString();
                  }
                  if(mcKey.@suffix.toString() != "")
                  {
                     suffix = mcKey.@suffix.toString();
                  }
                  start = -1;
                  if(mcKey.@start.toString() != "")
                  {
                     startNumber = parseInt(mcKey.@start.toString());
                     if(!isNaN(startNumber))
                     {
                        start = startNumber;
                     }
                  }
                  end = -1;
                  if(mcKey.@end.toString() != "")
                  {
                     endNumber = parseInt(mcKey.@end.toString());
                     if(!isNaN(endNumber))
                     {
                        end = endNumber;
                     }
                  }
                  if(mcKey.@breakOnTrue.toString() != "")
                  {
                     breakOnTrue = mcKey.@breakOnTrue.toString() == "true";
                  }
                  if(Boolean(prefix && suffix) && Boolean(start != -1) && end != -1)
                  {
                     this.m_components.push(new PrereqDrivenWindowComponent(prefix,suffix,start,end,breakOnTrue));
                  }
                  else
                  {
                     ErrorManager.addError(ErrorManager.getFormattedErrorMessage("Missing or invalid \'prefix\', \'suffix\', \'start\', or \'end\' attribute in mcKey tag for feature. ","featureName=" + this.m_featureName));
                  }
               }
            }
         }
      }
      
      override protected function release() : void
      {
         super.release();
         this.m_featureName = null;
         this.m_baseFeatureManager = null;
         this.m_components = null;
      }
   }
}

