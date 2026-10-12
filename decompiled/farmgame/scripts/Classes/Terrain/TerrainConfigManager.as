package Classes.Terrain
{
   public class TerrainConfigManager
   {
      
      private static var m_instance:TerrainConfigManager;
      
      protected var m_codesToObjects:Object = null;
      
      public function TerrainConfigManager()
      {
         super();
         this.m_codesToObjects = {};
      }
      
      public static function getInstance() : TerrainConfigManager
      {
         if(null == m_instance)
         {
            m_instance = new TerrainConfigManager();
         }
         return m_instance;
      }
      
      public function setConfigXml(configXml:XML) : void
      {
         var terrainXml:XML = null;
         var terrain:Terrain = null;
         for each(terrainXml in configXml.terrain)
         {
            terrain = new Terrain(terrainXml);
            this.m_codesToObjects[terrain.code] = terrain;
         }
      }
      
      public function getTerrainCodeToObjects() : Object
      {
         return this.m_codesToObjects;
      }
      
      public function getConfigObject(code:int) : Terrain
      {
         return this.getTerrainCodeToObjects()[code];
      }
      
      public function getConfigByName(a_name:String) : Terrain
      {
         var type:Terrain = null;
         for each(type in this.getTerrainCodeToObjects())
         {
            if(type.name == a_name)
            {
               return type;
            }
         }
         return null;
      }
      
      public function getCodeFromName(a_name:String) : int
      {
         var result:int = -1;
         var configObject:Terrain = this.getConfigByName(a_name);
         if(configObject != null)
         {
            result = configObject.code;
         }
         return result;
      }
      
      public function getNameFromCode(code:int) : String
      {
         var result:String = null;
         var configObject:Terrain = this.getConfigObject(code);
         if(configObject != null)
         {
            result = configObject.name;
         }
         return result;
      }
   }
}

