package Classes.Growable
{
   import Classes.MapResource;
   
   public interface IGrowableResource
   {
      
      function get currentVisibleStage() : Object;
      
      function get startTime() : Number;
      
      function get growthProgress() : int;
      
      function get nextGrowthAt() : int;
      
      function get totalFedCount() : int;
      
      function get currentVisibleStageName() : String;
      
      function get growableMapResource() : MapResource;
      
      function refreshVisibleToActual(param1:String = null) : void;
      
      function feedConsumable(param1:int, param2:Function = null, param3:Boolean = false) : void;
      
      function checkAgeExpired() : Boolean;
      
      function canStillGrow() : Boolean;
      
      function get isFixed() : Boolean;
      
      function get hasPendingPartnerAction() : Boolean;
      
      function get partnerId() : Number;
      
      function get progress() : int;
      
      function get stopGrowingTime() : String;
      
      function get timeSinceStarted() : String;
      
      function get totalGrowingTime() : String;
      
      function get fixedTime() : Number;
      
      function get lockFlag() : Boolean;
      
      function get persistentDataKey() : String;
      
      function getGrowableInstanceData() : Object;
      
      function isPartOfContest() : String;
      
      function getTimeTilExpire(param1:Boolean = false, param2:Boolean = false) : String;
      
      function get maximumFedCount() : int;
      
      function get consumableCash() : int;
      
      function get completionCash() : int;
      
      function get completionCount() : int;
      
      function getFriendlyStageName() : String;
      
      function getStageName() : String;
   }
}

