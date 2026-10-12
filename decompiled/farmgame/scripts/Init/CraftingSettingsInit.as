package Init
{
   import Classes.CraftConfigSettings;
   
   public class CraftingSettingsInit extends XMLSettingsInit
   {
      
      public static const INIT_ID:String = "CraftingSettings";
      
      public function CraftingSettingsInit(buildVersion:Number)
      {
         super(INIT_ID,"crafting.xml",buildVersion);
         addDependency(ZGameSettingsInit.INIT_ID);
      }
      
      override protected function onLoadCallback(xml:XML) : void
      {
         Global.craftConfigSettings = new CraftConfigSettings(xml);
         super.onLoadCallback(xml);
      }
   }
}

