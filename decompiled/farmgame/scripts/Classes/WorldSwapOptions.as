package Classes
{
   public class WorldSwapOptions
   {
      
      private var m_worldType:String;
      
      private var m_shouldFreezeFarm:Boolean;
      
      private var m_priorWorldType:String;
      
      public function WorldSwapOptions(worldType:String, priorWorldType:String, shouldFreezeFarm:Boolean)
      {
         super();
         GlobalEngine.assert(worldType != null,"worldType cannot be null in WorldSwapOptions!");
         GlobalEngine.assert(priorWorldType != null,"priorWorldType cannot be null in WorldSwapOptions!");
         this.m_worldType = worldType;
         this.m_priorWorldType = priorWorldType;
         this.m_shouldFreezeFarm = shouldFreezeFarm;
      }
      
      public function get worldType() : String
      {
         return this.m_worldType;
      }
      
      public function get shouldFreezeFarm() : Boolean
      {
         return this.m_shouldFreezeFarm;
      }
      
      public function get priorWorldType() : String
      {
         return this.m_priorWorldType;
      }
   }
}

