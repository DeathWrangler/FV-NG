package Init
{
   import Classes.Leaderboard.LeaderboardConfigSettings;
   import ZQuest.Init.QuestSettingsInit;
   
   public class LeaderboardSettingsInit extends XMLSettingsInit
   {
      
      public static const INIT_ID:String = "LeaderboardSettings";
      
      public function LeaderboardSettingsInit(buildVersion:Number)
      {
         super(INIT_ID,"leaderboards.xml",buildVersion);
         addDependency(AssetHashInit.INIT_ID);
         addDependency(QuestSettingsInit.INIT_ID);
      }
      
      override protected function onLoadCallback(xml:XML) : void
      {
         Global.leaderboardConfigSettings = new LeaderboardConfigSettings(xml);
         super.onLoadCallback(xml);
      }
   }
}

