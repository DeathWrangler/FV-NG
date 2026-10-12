package Classes.DragonBreeding
{
   import Classes.util.FarmGameUtil;
   import Managers.DragonBreedingConfigManager;
   
   public class DragonBreedingSession
   {
      
      private var m_startTime:Number = 0;
      
      private var m_finishTime:Number = 0;
      
      private var m_numPotions:Number = 0;
      
      private var m_suiteSlot:Number = 0;
      
      private var m_dragonBreedObject:Object = new Object();
      
      private var m_patternGuarantee:Boolean = false;
      
      private var m_offspringObj:MutableDragonState = null;
      
      private var m_isComplete:Boolean = false;
      
      private var m_isVisitingDragon:String = "";
      
      private var m_visitingDragonSender:String = "";
      
      private var m_featureName:String;
      
      private var m_isMaleVisitingDragon:String = "";
      
      private var m_isFemaleVistingDragon:String = "";
      
      private var m_maleVisitingDragonSender:String = "";
      
      private var m_femaleVisitingDragonSender:String = "";
      
      public function DragonBreedingSession(featureName:String)
      {
         super();
         this.m_featureName = featureName;
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
         if(data.hasOwnProperty("featureName"))
         {
            this.m_featureName = data.featureName;
         }
         if(data.hasOwnProperty("suiteSlot"))
         {
            this.m_suiteSlot = data.suiteSlot;
         }
         if(data.hasOwnProperty("isComplete"))
         {
            this.m_isComplete = data.isComplete;
         }
         if(data.hasOwnProperty("isMaleVD"))
         {
            this.m_isMaleVisitingDragon = data.isMaleVD;
         }
         if(data.hasOwnProperty("isFemaleVD"))
         {
            this.m_isFemaleVistingDragon = data.isFemaleVD;
         }
         if(data.hasOwnProperty("maleVDSender"))
         {
            this.m_maleVisitingDragonSender = data.maleVDSender;
         }
         if(data.hasOwnProperty("femaleVDSender"))
         {
            this.m_femaleVisitingDragonSender = data.femaleVDSender;
         }
         if(data.hasOwnProperty("breedObjs"))
         {
            breedObj = data.breedObjs;
            if(breedObj.hasOwnProperty(DragonBreedingConfigManager.GENDER_CODE_MALE) && breedObj.hasOwnProperty(DragonBreedingConfigManager.GENDER_CODE_FEMALE) && breedObj.hasOwnProperty(DragonBreedingConfigManager.CODE_OFFSPRING))
            {
               this.addBreedObjects(breedObj[DragonBreedingConfigManager.GENDER_CODE_MALE],breedObj[DragonBreedingConfigManager.GENDER_CODE_FEMALE],breedObj[DragonBreedingConfigManager.CODE_OFFSPRING]);
            }
         }
         if(data.hasOwnProperty("patternGuarantee"))
         {
            this.m_patternGuarantee = data.patternGuarantee;
         }
      }
      
      public function addBreedObjects(maleItemId:String, femaleItemId:String, offSpringId:int = 1) : void
      {
         this.m_dragonBreedObject[DragonBreedingConfigManager.GENDER_CODE_MALE] = maleItemId;
         this.m_dragonBreedObject[DragonBreedingConfigManager.GENDER_CODE_FEMALE] = femaleItemId;
         this.m_dragonBreedObject[DragonBreedingConfigManager.CODE_OFFSPRING] = offSpringId;
      }
      
      public function getDragonBreedObject(type:String) : String
      {
         return this.m_dragonBreedObject[type] as String;
      }
      
      public function getOffspringCode() : Number
      {
         return this.m_dragonBreedObject[DragonBreedingConfigManager.CODE_OFFSPRING];
      }
      
      public function getDragonBreedObjects() : Object
      {
         return this.m_dragonBreedObject;
      }
      
      public function hasValidBreedObjects() : Boolean
      {
         return this.m_dragonBreedObject.hasOwnProperty(DragonBreedingConfigManager.GENDER_CODE_MALE) && this.m_dragonBreedObject.hasOwnProperty(DragonBreedingConfigManager.GENDER_CODE_FEMALE) && this.m_dragonBreedObject.hasOwnProperty(DragonBreedingConfigManager.CODE_OFFSPRING);
      }
      
      public function serializeForPhp() : Object
      {
         var phpObject:Object = {};
         phpObject["start_ts"] = this.m_startTime;
         phpObject["finish_ts"] = this.m_finishTime;
         phpObject["numPotions"] = this.m_numPotions;
         phpObject["featureName"] = this.m_featureName;
         phpObject["suiteSlot"] = this.m_suiteSlot;
         phpObject["breedObjs"] = this.m_dragonBreedObject;
         phpObject["patternGuarantee"] = this.m_patternGuarantee;
         phpObject["isMaleVD"] = this.m_isMaleVisitingDragon;
         phpObject["isFemaleVD"] = this.m_isFemaleVistingDragon;
         phpObject["maleVDSender"] = this.m_maleVisitingDragonSender;
         phpObject["femaleVDSender"] = this.m_femaleVisitingDragonSender;
         return phpObject;
      }
      
      public function get featureName() : String
      {
         return this.m_featureName;
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
      
      public function set featureName(value:String) : void
      {
         this.m_featureName = value;
      }
      
      public function get suiteSlot() : Number
      {
         return this.m_suiteSlot;
      }
      
      public function set suiteSlot(value:Number) : void
      {
         this.m_suiteSlot = value;
      }
      
      public function get isVisitingDragon() : String
      {
         return this.m_isVisitingDragon;
      }
      
      public function set isVisitingDragon(value:String) : void
      {
         if(value == DragonBreedingConfigManager.GENDER_CODE_MALE || value == DragonBreedingConfigManager.GENDER_CODE_FEMALE)
         {
            this.m_isVisitingDragon = value;
         }
         else
         {
            this.m_isVisitingDragon = "";
         }
      }
      
      public function set isMaleVD(value:String) : void
      {
         if(value == DragonBreedingConfigManager.GENDER_CODE_MALE)
         {
            this.m_isMaleVisitingDragon = value;
         }
         else
         {
            this.m_isMaleVisitingDragon = "";
         }
      }
      
      public function set isFemaleVD(value:String) : void
      {
         if(value == DragonBreedingConfigManager.GENDER_CODE_FEMALE)
         {
            this.m_isFemaleVistingDragon = value;
         }
         else
         {
            this.m_isFemaleVistingDragon = "";
         }
      }
      
      public function get isMaleVD() : String
      {
         return this.m_isMaleVisitingDragon;
      }
      
      public function get isFemaleVD() : String
      {
         return this.m_isFemaleVistingDragon;
      }
      
      public function set visitingDragonSender(value:String) : void
      {
         this.m_visitingDragonSender = value;
      }
      
      public function get visitingDragonSender() : String
      {
         return this.m_visitingDragonSender;
      }
      
      public function set maleVDSender(value:String) : void
      {
         this.m_maleVisitingDragonSender = value;
      }
      
      public function get maleVDSender() : String
      {
         return this.m_maleVisitingDragonSender;
      }
      
      public function set femaleVDSender(value:String) : void
      {
         this.m_femaleVisitingDragonSender = value;
      }
      
      public function get femaleVDSender() : String
      {
         return this.m_femaleVisitingDragonSender;
      }
      
      public function set patternGuarantee(value:Boolean) : void
      {
         this.m_patternGuarantee = value;
      }
      
      public function get patternGuarantee() : Boolean
      {
         return this.m_patternGuarantee;
      }
      
      public function get collected() : Boolean
      {
         return this.m_isComplete;
      }
      
      public function set collected(value:Boolean) : void
      {
         this.m_isComplete = value;
      }
      
      public function isComplete() : Boolean
      {
         return this.m_finishTime <= GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
      }
      
      public function get breedingTimeRemaining() : Number
      {
         return this.m_finishTime - GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
      }
   }
}

