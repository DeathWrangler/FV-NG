package Init
{
   import Engine.Init.InitializationAction;
   import Engine.Init.InitializationManager;
   
   public class GlobalWorldScoreInitAction extends InitializationAction
   {
      
      public static const INIT_ID:String = "GlobalWorldScoreInit";
      
      private var m_fileRevision:Number = 0;
      
      public function GlobalWorldScoreInitAction(id:String)
      {
         super(INIT_ID + id);
         this.m_fileRevision = Number(id);
         this.addDependency(ZGameSettingsInit.INIT_ID);
      }
      
      override public function execute() : void
      {
         var initManager:InitializationManager = GlobalEngine.initializationManager;
         initManager.add(new WorldScoreInit(this.m_fileRevision,WorldScoreInitAction.GLOBAL_WORLDSCORE_FILENAME));
         super.execute();
      }
   }
}

