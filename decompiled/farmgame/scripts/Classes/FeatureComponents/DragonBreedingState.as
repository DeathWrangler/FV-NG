package Classes.FeatureComponents
{
   import Classes.DragonBreeding.DragonBreedingSession;
   
   public class DragonBreedingState
   {
      
      public static var HISTORY_GENDER_MAX_DUPES:int = 3;
      
      public static const MAX_SESSIONS:int = 4;
      
      private var m_breedingQueue:Array = new Array();
      
      private var m_featureName:String;
      
      public function DragonBreedingState(featureName:String)
      {
         super();
         this.m_featureName = featureName;
      }
      
      public function loadObject(data:Object, suiteSlot:int = -1) : void
      {
         var breedSession:DragonBreedingSession = null;
         var breedObj:Object = null;
         if(data != null)
         {
            if(data.hasOwnProperty("breedingQueue"))
            {
               this.getBreedingQueue();
               if(suiteSlot != -1 && data.breedingQueue[suiteSlot] != null && this.getBreedSession(suiteSlot) != null)
               {
                  breedSession = this.getBreedSession(suiteSlot);
                  breedObj = data.breedingQueue[suiteSlot];
                  breedSession.loadObject(breedObj);
                  this.m_breedingQueue[suiteSlot] = breedSession;
               }
               else
               {
                  for each(breedObj in data.breedingQueue)
                  {
                     if(breedObj != null)
                     {
                        breedSession = new DragonBreedingSession(this.m_featureName);
                        breedSession.loadObject(breedObj);
                        this.m_breedingQueue[breedObj.suiteSlot] = breedSession;
                     }
                  }
               }
            }
         }
      }
      
      public function setBreedingSession(breedingSession:DragonBreedingSession, shouldReset:Boolean = false) : void
      {
         var index:Number = NaN;
         if(breedingSession)
         {
            index = breedingSession.suiteSlot;
            if(index >= 0 && index < MAX_SESSIONS)
            {
               if(shouldReset)
               {
                  this.m_breedingQueue[index] = null;
               }
               else
               {
                  this.m_breedingQueue[index] = breedingSession;
               }
            }
         }
      }
      
      public function getBreedingQueue() : Array
      {
         if(!this.m_breedingQueue)
         {
            this.m_breedingQueue = new Array();
         }
         return this.m_breedingQueue;
      }
      
      public function getBreedSession(index:Number) : DragonBreedingSession
      {
         return this.m_breedingQueue[index];
      }
      
      public function getNumCompletedSessions() : Number
      {
         var animalSession:DragonBreedingSession = null;
         var numComplete:Number = 0;
         for(var i:Number = 0; i < this.m_breedingQueue.length; i++)
         {
            animalSession = this.m_breedingQueue[i] as DragonBreedingSession;
            if(animalSession != null && animalSession.isComplete())
            {
               numComplete++;
            }
         }
         return numComplete;
      }
   }
}

