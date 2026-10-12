package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   import Classes.breeding.AnimalBreedingSession;
   import Classes.breeding.MutableAnimalState;
   import flash.utils.Dictionary;
   
   public class AnimalBreedingState extends ExtraDataFManager implements IExtraDataComponent
   {
      
      public static var HISTORY_GENDER_MAX_DUPES:int = 3;
      
      private var m_breedingQueue:Array = new Array();
      
      private var m_breedHistory:Object = new Object();
      
      public function AnimalBreedingState(owner:FeatureBuilding)
      {
         super(owner);
      }
      
      override public function loadObject(data:Object) : void
      {
         var breedObj:Object = null;
         var breedSession:AnimalBreedingSession = null;
         if(Boolean(data) && data.extraDataState != null)
         {
            if(data.extraDataState.hasOwnProperty("breedingQueue"))
            {
               this.m_breedingQueue = new Array();
               for each(breedObj in data.extraDataState.breedingQueue)
               {
                  if(breedObj != null)
                  {
                     breedSession = new AnimalBreedingSession(this.m_owner as FeatureBuilding);
                     breedObj.buildingId = owner.getId();
                     breedSession.loadObject(breedObj);
                     this.m_breedingQueue[breedObj.suiteSlot] = breedSession;
                  }
               }
            }
            if(data.extraDataState.hasOwnProperty("breedHistory"))
            {
               this.m_breedHistory = data.extraDataState.breedHistory;
            }
         }
      }
      
      public function getBreedSession(index:Number) : AnimalBreedingSession
      {
         return this.m_breedingQueue[index];
      }
      
      public function getNumCompletedSessions() : Number
      {
         var animalSession:AnimalBreedingSession = null;
         var numComplete:Number = 0;
         for(var i:Number = 0; i < this.m_breedingQueue.length; i++)
         {
            animalSession = this.m_breedingQueue[i] as AnimalBreedingSession;
            if(animalSession != null && animalSession.isComplete())
            {
               numComplete++;
            }
         }
         return numComplete;
      }
      
      public function getInUseBreedHashes() : Dictionary
      {
         var animalSession:AnimalBreedingSession = null;
         var breedObjs:Array = null;
         var j:Number = NaN;
         var breedObj:MutableAnimalState = null;
         var inUseHashes:Dictionary = new Dictionary();
         for(var i:Number = 0; i < this.m_breedingQueue.length; i++)
         {
            animalSession = this.m_breedingQueue[i] as AnimalBreedingSession;
            if(animalSession != null)
            {
               breedObjs = animalSession.getBreedObjects();
               for(j = 0; j < breedObjs.length; j++)
               {
                  breedObj = animalSession.getBreedObject(j);
                  if(inUseHashes[breedObj.hash] == null)
                  {
                     inUseHashes[breedObj.hash] = 0;
                  }
                  ++inUseHashes[breedObj.hash];
               }
            }
         }
         return inUseHashes;
      }
      
      public function getBreedingHistory() : Object
      {
         return this.m_breedHistory;
      }
   }
}

