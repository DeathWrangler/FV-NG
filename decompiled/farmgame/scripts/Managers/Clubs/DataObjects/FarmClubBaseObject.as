package Managers.Clubs.DataObjects
{
   import Classes.util.FarmGameUtil;
   
   public class FarmClubBaseObject implements IFarmClubObject
   {
      
      public static const UNINITIALIZED:int = 0;
      
      public static const TRANSACTION_PENDING:int = 1;
      
      public static const IS_LOADED:int = 2;
      
      public static const IS_DIRTY:int = 3;
      
      protected var m_data:* = null;
      
      private var m_state:int = 0;
      
      private var m_lastUpdated:Number;
      
      private var m_type:String;
      
      private var m_ttl:int;
      
      public function FarmClubBaseObject(type:String, ttl:int)
      {
         super();
         this.m_type = type;
         this.m_ttl = ttl * FarmGameUtil.NUM_MSECS_IN_SECOND;
      }
      
      public function get isLoaded() : Boolean
      {
         return this.m_state == IS_LOADED;
      }
      
      public function get isPending() : Boolean
      {
         return this.m_state == TRANSACTION_PENDING;
      }
      
      public function setIsPending() : void
      {
         this.m_state = TRANSACTION_PENDING;
      }
      
      public function setDirty() : void
      {
         this.m_state = IS_DIRTY;
      }
      
      public function get isStale() : Boolean
      {
         return GlobalEngine.serverTime > this.m_lastUpdated + this.m_ttl;
      }
      
      public function get data() : *
      {
         return this.m_data;
      }
      
      public function onLoadData(result:Object) : void
      {
         this.parseData(result);
         this.dataLoaded();
      }
      
      protected function parseData(result:Object) : void
      {
         this.m_data = result;
      }
      
      protected function dataLoaded() : void
      {
         this.m_lastUpdated = GlobalEngine.serverTime;
         this.m_state = IS_LOADED;
      }
   }
}

