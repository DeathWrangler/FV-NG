package Classes
{
   public class NPCConfigData
   {
      
      public static const TYPE_NORMAL:String = "normal";
      
      public static const TYPE_MODELFARM:String = "modelfarm";
      
      protected var m_id:String;
      
      protected var m_type:String = "normal";
      
      protected var m_name:String;
      
      protected var m_stat:String;
      
      protected var m_gamemode:String = null;
      
      protected var m_assets:Object;
      
      protected var m_world:String;
      
      protected var m_motd:String;
      
      public function NPCConfigData(rawData:Object)
      {
         super();
         this.parseData(rawData);
      }
      
      protected function parseData(rawData:Object) : void
      {
         if(rawData)
         {
            if(rawData.id)
            {
               this.m_id = rawData.id;
            }
            if(rawData.type)
            {
               this.m_type = rawData.type;
            }
            if(rawData.name)
            {
               this.m_name = rawData.name;
            }
            if(rawData.stat)
            {
               this.m_stat = rawData.stat;
            }
            if(rawData.gamemode)
            {
               this.m_gamemode = rawData.gamemode;
            }
            if(rawData.assets)
            {
               this.m_assets = rawData.assets;
            }
            if(rawData.world)
            {
               this.m_world = rawData.world;
            }
            if(rawData.motd)
            {
               this.m_motd = rawData.motd;
            }
         }
      }
      
      public function get assets() : Object
      {
         return this.m_assets;
      }
      
      public function get id() : String
      {
         return this.m_id;
      }
      
      public function get type() : String
      {
         return this.m_type;
      }
      
      public function get name() : String
      {
         return this.m_name;
      }
      
      public function get stat() : String
      {
         return this.m_stat;
      }
      
      public function get gamemode() : String
      {
         return this.m_gamemode;
      }
      
      public function get world() : String
      {
         return this.m_world;
      }
      
      public function get motd() : String
      {
         return this.m_motd;
      }
   }
}

