package Classes.util
{
   import Classes.Constants.WorldsConstants;
   import cipro.Profiler.GameTagManager;
   import cipro.Profiler.GameTagSampler;
   import cipro.Profiler.ModeManager;
   
   public class FarmModeManager extends ModeManager
   {
      
      public static const LOAD_APP_PHASE_NAME:String = "loadapp";
      
      public static const ITEMS_PARSED:String = "itemsparsed";
      
      public static const INTERACTIVE_PHASE_NAME:String = "interactive";
      
      public static const USER_INIT:String = "userinit";
      
      public static const LOAD_COMPLETE_PHASE_NAME:String = "loadcomplete";
      
      private var m_worldModeIndices:Object;
      
      private var m_playtimeIndex:int = -1;
      
      private var m_loadingIndex:int = -1;
      
      private var m_playtimeBeforeLoadCompleteIndex:int = -1;
      
      private var m_playtimeAfterLoadCompleteIndex:int = -1;
      
      private var m_loadPhase:GameTagSampler = null;
      
      private var m_playState:GameTagSampler = null;
      
      public function FarmModeManager()
      {
         var world:String = null;
         var index:int = 0;
         this.m_worldModeIndices = {};
         super();
         this.m_loadingIndex = GameTagManager.addGameMode("Loading");
         this.m_playtimeIndex = GameTagManager.addGameMode("Playtime");
         this.m_playtimeBeforeLoadCompleteIndex = GameTagManager.addGameMode("PlaytimeBeforeLoadComplete");
         this.m_playtimeAfterLoadCompleteIndex = GameTagManager.addGameMode("PlaytimeAfterLoadComplete");
         for each(world in WorldsConstants.ALL_WORLDS)
         {
            index = GameTagManager.addGameMode("Playtime-" + world);
            this.m_worldModeIndices[world] = index;
         }
         currentGameModes.push(this.m_loadingIndex);
         this.onTagAdded("LoadPhase");
         this.onTagAdded("PlayState");
         if(!this.m_loadPhase || !this.m_playState)
         {
            GameTagManager.registerAddTagCallback(this.onTagAdded);
         }
      }
      
      public function onTagAdded(name:String = null) : void
      {
         if(!this.m_loadPhase && name == "LoadPhase")
         {
            this.m_loadPhase = GameTagManager.registerGameModeTag(name);
         }
         else if(!this.m_playState && name == "PlayState")
         {
            this.m_playState = GameTagManager.registerGameModeTag(name);
         }
      }
      
      override public function recalculateCurrentGameModes() : void
      {
         var currentWorldType:String = null;
         super.recalculateCurrentGameModes();
         if(Boolean(this.m_loadPhase) && Boolean(this.m_playState))
         {
            if(this.m_loadPhase.value() == LOAD_APP_PHASE_NAME)
            {
               currentGameModes.push(this.m_loadingIndex);
            }
            else if(this.m_playState.value() == "Active")
            {
               currentGameModes.push(this.m_playtimeIndex);
               if(this.m_loadPhase.value() == INTERACTIVE_PHASE_NAME)
               {
                  currentGameModes.push(this.m_playtimeBeforeLoadCompleteIndex);
               }
               else
               {
                  currentGameModes.push(this.m_playtimeAfterLoadCompleteIndex);
               }
               currentWorldType = Global.worldManager.currentWorldType;
               currentGameModes.push(this.m_worldModeIndices[currentWorldType]);
            }
         }
      }
   }
}

