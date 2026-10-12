package Classes
{
   import Engine.Classes.World;
   import flash.utils.getTimer;
   
   public class WorldObjectBatchLoader
   {
      
      private static const MIN_BATCH_MILLISECONDS:int = 1;
      
      private static const MAX_BATCH_MILLISECONDS:int = 15000;
      
      private var m_objectsToLoad:Array;
      
      private var m_batchTimeOutMilliseconds:int;
      
      private var m_numObjectsToLoad:int;
      
      private var m_numObjectsLoaded:int;
      
      private var m_world:World;
      
      private var m_worldData:Object;
      
      public function WorldObjectBatchLoader(data:Object, batchTimeOutMilliseconds:int, world:World)
      {
         super();
         this.m_worldData = data;
         this.m_objectsToLoad = data.objects as Array;
         this.m_numObjectsToLoad = this.m_objectsToLoad.length;
         this.m_batchTimeOutMilliseconds = batchTimeOutMilliseconds;
         this.m_numObjectsLoaded = 0;
         this.m_world = world;
         if(this.m_batchTimeOutMilliseconds < MIN_BATCH_MILLISECONDS)
         {
            this.m_batchTimeOutMilliseconds = MIN_BATCH_MILLISECONDS;
         }
         if(this.m_batchTimeOutMilliseconds > MAX_BATCH_MILLISECONDS)
         {
            this.m_batchTimeOutMilliseconds = MAX_BATCH_MILLISECONDS;
         }
      }
      
      public function getWorldData() : Object
      {
         return this.m_worldData;
      }
      
      public function cleanUp() : void
      {
         this.m_world = null;
         this.m_objectsToLoad = null;
         this.m_worldData = null;
      }
      
      public function loadWorldObjectBatch() : Boolean
      {
         var objectToLoad:Object = null;
         var isFinished:Boolean = false;
         var batchEndTime:int = getTimer() + this.m_batchTimeOutMilliseconds;
         while(this.m_numObjectsLoaded < this.m_numObjectsToLoad && getTimer() < batchEndTime)
         {
            objectToLoad = this.m_objectsToLoad[this.m_numObjectsLoaded];
            this.m_world.attachWorldObject(objectToLoad);
            ++this.m_numObjectsLoaded;
         }
         if(this.m_numObjectsLoaded >= this.m_numObjectsToLoad)
         {
            isFinished = true;
         }
         return isFinished;
      }
   }
}

