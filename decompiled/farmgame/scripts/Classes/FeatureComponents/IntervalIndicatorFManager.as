package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   import DataSources.BaseDataSource;
   import Managers.FarmGameSettingsManager;
   
   public class IntervalIndicatorFManager extends ArrowIndicatorFManager implements IStateIndicatorComponent
   {
      
      public static const KEY_SHOW_INTERVAL:String = "showInterval";
      
      protected var m_showInterval:Number = 1.7976931348623157e+308;
      
      protected var m_intervalKey:String = "";
      
      public function IntervalIndicatorFManager(owner:FeatureBuilding)
      {
         var featureData:BaseDataSource = null;
         var featuresXML:XMLList = null;
         var arrowFeature:XMLList = null;
         super(owner);
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            featureData = owner.getFarmItem().getFeatureDataByName(FeatureManager.ARROW_INDICATOR_MENU_FEATURE_NAME);
            if(Boolean(featureData) && featureData.hasProperty(KEY_SHOW_INTERVAL))
            {
               this.m_showInterval = featureData.getNumber(KEY_SHOW_INTERVAL);
            }
         }
         else
         {
            featuresXML = owner.getFarmItem().getFeaturesXML();
            arrowFeature = featuresXML.(@name == FeatureManager.ARROW_INDICATOR_MENU_FEATURE_NAME);
            if(arrowFeature != null)
            {
               if(arrowFeature.hasOwnProperty(KEY_SHOW_INTERVAL))
               {
                  this.m_showInterval = Number(arrowFeature[KEY_SHOW_INTERVAL]);
               }
            }
         }
         this.m_intervalKey = this.owner.bldgName + "_Indicator";
      }
      
      override public function canDisplay() : Boolean
      {
         var result:Boolean = false;
         var lastShown:Number = Global.player.getFeatureLastShown(this.m_intervalKey);
         var curTime:Number = GlobalEngine.serverTime / 1000;
         var difference:Number = curTime - lastShown;
         if(curTime - lastShown > this.m_showInterval)
         {
            result = true;
         }
         return result;
      }
      
      override public function show(state:String = "default") : void
      {
         super.show(state);
         Global.player.setFeatureLastShown(this.m_intervalKey,GlobalEngine.serverTime,true);
      }
   }
}

