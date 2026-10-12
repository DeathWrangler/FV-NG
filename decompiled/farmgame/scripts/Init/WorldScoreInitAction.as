package Init
{
   import Classes.Constants.WorldsConstants;
   import Classes.ZItem.ExpansionData;
   import Engine.Init.InitializationAction;
   import Engine.Init.InitializationManager;
   
   public class WorldScoreInitAction extends InitializationAction
   {
      
      public static const GLOBAL_WORLDSCORE_FILENAME:String = "worldScoreGlobal.xml";
      
      public function WorldScoreInitAction(id:String)
      {
         super(id);
         this.addDependency(ZGameSettingsInit.INIT_ID);
      }
      
      override public function execute() : void
      {
         var worldId:String = null;
         var expansionData:ExpansionData = null;
         var scoreFile:String = null;
         var initManager:InitializationManager = GlobalEngine.initializationManager;
         initManager.add(new WorldScoreInit(Number(getActionId()),GLOBAL_WORLDSCORE_FILENAME));
         for each(worldId in WorldsConstants.ALL_WORLDS)
         {
            expansionData = Global.farmGameSettingsManager.getExpansionData(worldId);
            if(expansionData != null)
            {
               scoreFile = expansionData.scoreFile;
               if(scoreFile != null)
               {
                  initManager.add(new WorldScoreInit(Number(getActionId()),scoreFile));
               }
            }
         }
         super.execute();
      }
   }
}

