package Init
{
   import Classes.PremiumHudAd;
   import Classes.WatchToEarnManager;
   import Display.HUD.HUD;
   import Engine.Init.InitializationAction;
   
   public class WatchToEarnInit extends InitializationAction
   {
      
      public static const INIT_ID:String = "WatchToEarnInit";
      
      public static const COUNTER:String = "w2e";
      
      public static const KINGDOM:String = "unknown";
      
      public function WatchToEarnInit()
      {
         super(INIT_ID);
      }
      
      override public function execute() : void
      {
         if(!Global.watchToEarn)
         {
            Global.watchToEarn = WatchToEarnManager.getInstance();
            HUD.initializeWatchToEarn();
            PremiumHudAd.initializeWatchToEarn();
         }
         super.execute();
      }
   }
}

