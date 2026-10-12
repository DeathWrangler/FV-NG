package Classes.breeding
{
   import Classes.FeatureBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   
   public class AnimalBreedingSession
   {
      
      private var m_startTime:Number = 0;
      
      private var m_finishTime:Number = 0;
      
      private var m_numPotions:Number = 0;
      
      private var m_buildingId:Number = 0;
      
      private var m_suiteSlot:Number = 0;
      
      private var m_breedObjects:Array = new Array();
      
      private var m_owner:FeatureBuilding = null;
      
      private var m_patternGuarantee:Boolean = false;
      
      public function AnimalBreedingSession(owner:FeatureBuilding)
      {
         super();
         this.m_owner = owner;
      }
      
      public function loadObject(data:Object) : void
      {
         var breedObj:Object = null;
         if(data.hasOwnProperty("start_ts"))
         {
            this.m_startTime = data.start_ts;
         }
         if(data.hasOwnProperty("finish_ts"))
         {
            this.m_finishTime = data.finish_ts;
         }
         if(data.hasOwnProperty("numPotions"))
         {
            this.m_numPotions = data.numPotions;
         }
         if(data.hasOwnProperty("buildingId"))
         {
            this.m_buildingId = data.buildingId;
         }
         if(data.hasOwnProperty("suiteSlot"))
         {
            this.m_suiteSlot = data.suiteSlot;
         }
         if(data.hasOwnProperty("breedObjs"))
         {
            for each(breedObj in data.breedObjs)
            {
               this.addBreedObject(breedObj.hash);
            }
         }
         if(data.hasOwnProperty("patternGuarantee"))
         {
            this.m_patternGuarantee = data.patternGuarantee;
         }
      }
      
      public function clone(featureName:String = null) : AnimalBreedingSession
      {
         var breedObj:Object = null;
         var cloneSession:AnimalBreedingSession = new AnimalBreedingSession(this.m_owner);
         cloneSession.startTime = this.m_startTime;
         cloneSession.finishTime = this.m_finishTime;
         cloneSession.numPotions = this.m_numPotions;
         cloneSession.buildingId = this.m_buildingId;
         cloneSession.suiteSlot = this.m_suiteSlot;
         for each(breedObj in this.m_breedObjects)
         {
            cloneSession.addBreedObject(breedObj.hash,featureName);
         }
         cloneSession.patternGuarantee = this.m_patternGuarantee;
         return cloneSession;
      }
      
      public function addBreedObject(hash:String, featureName:String = null) : void
      {
         var jsonString:Object = this.m_owner.getStorageMetaDataForHash(hash);
         var parsedArray:Array = FeatureBuilding.parseMetaDataHash(hash);
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(parsedArray[0]);
         if(jsonString == null)
         {
            if(featureName == null)
            {
               featureName = Global.animalBreedingSettings.getFeatureNameByItem(farmItem.name);
            }
            jsonString = Global.animalBreedingSettings.getVariantJSON(featureName,farmItem.name);
         }
         var mutableAnimalState:MutableAnimalState = MutableAnimalState.createFromPhpString(hash,String(jsonString));
         this.m_breedObjects.push(mutableAnimalState);
      }
      
      public function addBreedObjectAtFirst(mutableAnimalState:MutableAnimalState) : void
      {
         this.m_breedObjects.shift();
         this.m_breedObjects.unshift(mutableAnimalState);
      }
      
      public function removeBreedObject() : void
      {
         this.m_breedObjects.pop();
      }
      
      public function addBreedObjectAtLast(mutableAnimalState:MutableAnimalState) : void
      {
         this.m_breedObjects.push(mutableAnimalState);
      }
      
      public function getBreedObjects() : Array
      {
         return this.m_breedObjects;
      }
      
      public function getBreedObject(index:Number) : MutableAnimalState
      {
         return this.m_breedObjects[index];
      }
      
      public function clearBreedObjects() : void
      {
         this.m_breedObjects = null;
         this.m_breedObjects = new Array();
      }
      
      public function getNumBreedObjects() : Number
      {
         return this.m_breedObjects.length;
      }
      
      public function serializeForPhp() : Object
      {
         var breedObj:Object = null;
         var phpObject:Object = {};
         phpObject["start_ts"] = this.m_startTime;
         phpObject["finish_ts"] = this.m_finishTime;
         phpObject["numPotions"] = this.m_numPotions;
         phpObject["buildingId"] = this.m_buildingId;
         phpObject["suiteSlot"] = this.m_suiteSlot;
         phpObject["breedObjs"] = new Array();
         for each(breedObj in this.m_breedObjects)
         {
            (phpObject["breedObjs"] as Array).push({"hash":breedObj.hash});
         }
         phpObject["patternGuarantee"] = this.m_patternGuarantee;
         return phpObject;
      }
      
      public function get owner() : FeatureBuilding
      {
         return this.m_owner;
      }
      
      public function get startTime() : Number
      {
         return this.m_startTime;
      }
      
      public function set startTime(value:Number) : void
      {
         this.m_startTime = value;
      }
      
      public function get finishTime() : Number
      {
         return this.m_finishTime;
      }
      
      public function set finishTime(value:Number) : void
      {
         this.m_finishTime = value;
      }
      
      public function get numPotions() : Number
      {
         return this.m_numPotions;
      }
      
      public function set numPotions(value:Number) : void
      {
         this.m_numPotions = value;
      }
      
      public function get buildingId() : Number
      {
         return this.m_buildingId;
      }
      
      public function set buildingId(value:Number) : void
      {
         this.m_buildingId = value;
      }
      
      public function get suiteSlot() : Number
      {
         return this.m_suiteSlot;
      }
      
      public function set suiteSlot(value:Number) : void
      {
         this.m_suiteSlot = value;
      }
      
      public function set patternGuarantee(value:Boolean) : void
      {
         this.m_patternGuarantee = value;
      }
      
      public function get patternGuarantee() : Boolean
      {
         return this.m_patternGuarantee;
      }
      
      public function isComplete() : Boolean
      {
         return this.m_finishTime <= GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
      }
   }
}

