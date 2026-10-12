package Init
{
   import Classes.Avatar.AvatarConfigSettings;
   
   public class AvatarSettingsInit extends XMLSettingsInit
   {
      
      public static const INIT_ID:String = "AvatarSettings";
      
      public function AvatarSettingsInit(buildVersion:Number)
      {
         super(INIT_ID,"avatar.xml",buildVersion);
         addDependency(ZGameSettingsInit.INIT_ID);
      }
      
      override protected function onLoadCallback(xml:XML) : void
      {
         Global.avatarConfigSettings = new AvatarConfigSettings(xml);
         super.onLoadCallback(xml);
      }
   }
}

