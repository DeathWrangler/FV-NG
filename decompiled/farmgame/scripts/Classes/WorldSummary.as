package Classes
{
   import Managers.WorldManager;
   
   public class WorldSummary
   {
      
      public static const FIRST_LOADED:String = "firstLoaded";
      
      public static const LAST_LOADED:String = "lastLoaded";
      
      public static const STORAGE_ID:String = "storageId";
      
      private var m_firstLoaded:Number;
      
      private var m_lastLoaded:Number;
      
      private var m_storageId:Number = WorldManager.HOME_INVENTORY_ID;
      
      private var m_worldType:String;
      
      public function WorldSummary(worldType:String, summaryData:Object)
      {
         super();
         this.m_worldType = worldType;
         if(summaryData[FIRST_LOADED])
         {
            this.m_firstLoaded = summaryData[FIRST_LOADED];
         }
         if(summaryData[LAST_LOADED])
         {
            this.m_lastLoaded = summaryData[LAST_LOADED];
         }
         if(summaryData[STORAGE_ID])
         {
            this.m_storageId = summaryData[STORAGE_ID];
         }
      }
      
      public function getStorageId() : Number
      {
         return this.m_storageId;
      }
      
      public function getWorldType() : String
      {
         return this.m_worldType;
      }
      
      public function getFirstLoaded() : Number
      {
         return this.m_firstLoaded;
      }
      
      public function getLastLoaded() : Number
      {
         return this.m_lastLoaded;
      }
   }
}

