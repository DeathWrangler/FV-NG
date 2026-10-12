package cipro.Profiler
{
   public class ModeManager
   {
      
      public var currentGameModes:Vector.<int> = new Vector.<int>();
      
      private var m_allIndex:int = -1;
      
      public function ModeManager()
      {
         super();
         this.m_allIndex = GameTagManager.addGameMode("All");
         this.currentGameModes.push(this.m_allIndex);
      }
      
      public function gameModeString() : String
      {
         return this.currentGameModes.toString();
      }
      
      public function recalculateCurrentGameModes() : void
      {
         this.currentGameModes.length = 1;
         this.currentGameModes[0] = this.m_allIndex;
      }
   }
}

