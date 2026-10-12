package Init
{
   import Classes.ZapCampaignSettings;
   
   public class ZapCampaignInit extends XMLSettingsInit
   {
      
      public static const INIT_ID:String = "zapcampaign";
      
      public function ZapCampaignInit(buildVersion:Number)
      {
         super(INIT_ID,"zapcampaign.xml",buildVersion);
         addDependency(GlobalsInit.INIT_ID);
      }
      
      override protected function onLoadCallback(xml:XML) : void
      {
         Global.zapCampaignSettings = new ZapCampaignSettings(xml);
         super.onLoadCallback(xml);
      }
   }
}

