package Init
{
   import Classes.MarketConfigSettings;
   
   public class MarketSettingsInit extends XMLSettingsInit
   {
      
      public static const INIT_ID:String = "MarketSettings";
      
      public function MarketSettingsInit(buildVersion:Number)
      {
         super(INIT_ID,"MarketData.xml",buildVersion);
         addDependency(AssetHashInit.INIT_ID);
      }
      
      override protected function onLoadCallback(xml:XML) : void
      {
         Global.marketConfigSettings = new MarketConfigSettings(xml);
         super.onLoadCallback(xml);
      }
   }
}

