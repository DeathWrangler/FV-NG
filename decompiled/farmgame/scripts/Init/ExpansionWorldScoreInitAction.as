package Init
{
   import Classes.Constants.WorldsConstants;
   import Classes.ZItem.ExpansionData;
   import Engine.Init.InitializationAction;
   import Engine.Init.InitializationManager;
   
   public class ExpansionWorldScoreInitAction extends InitializationAction
   {
      
      public static const INIT_ID:String = "ExpansionWorldScoreInit";
      
      private var m_fileRevision:Number = 0;
      
      public function ExpansionWorldScoreInitAction(id:String)
      {
         super(INIT_ID + id);
         this.m_fileRevision = Number(id);
      }
      
      override public function execute() : void
      {
         var worldId:String = null;
         var expansionData:ExpansionData = null;
         var scoreFile:String = null;
         var initManager:InitializationManager = GlobalEngine.initializationManager;
         for each(worldId in WorldsConstants.ALL_WORLDS)
         {
            expansionData = Global.farmGameSettingsManager.getExpansionData(worldId);
            if(expansionData != null)
            {
               scoreFile = expansionData.scoreFile;
               if(scoreFile != null)
               {
                  initManager.add(new WorldScoreInit(this.m_fileRevision,scoreFile));
               }
            }
         }
         super.execute();
      }
   }
}

