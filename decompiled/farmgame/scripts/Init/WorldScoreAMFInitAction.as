package Init
{
   import Engine.Init.InitializationAction;
   import Engine.Init.InitializationManager;
   
   public class WorldScoreAMFInitAction extends InitializationAction
   {
      
      public static const GLOBAL_WORLDSCORE_AMF:String = "worldScore.amf";
      
      public function WorldScoreAMFInitAction(id:String)
      {
         super(id);
         this.addDependency(ZGameSettingsInit.INIT_ID);
      }
      
      override public function execute() : void
      {
         var initManager:InitializationManager = GlobalEngine.initializationManager;
         initManager.add(new WorldScoreAMFInit(Number(getActionId()),GLOBAL_WORLDSCORE_AMF));
         super.execute();
      }
   }
}

