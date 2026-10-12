package Classes.FeatureComponents
{
   import Classes.FeatureDataObjects.BuildingExpansionData;
   import Classes.MapResource;
   import DataSources.BaseDataSource;
   import Events.GenericPopupEvent;
   
   public interface IExpandComponent
   {
      
      function get frictionless() : Boolean;
      
      function refreshPartData(param1:Object = null) : void;
      
      function refreshAskMethods() : void;
      
      function get inAppPurchase() : Boolean;
      
      function set storageLevel(param1:uint) : void;
      
      function get storageLevel() : uint;
      
      function get showExpansionOnBuild() : Boolean;
      
      function initialize(param1:Function, param2:Function) : void;
      
      function frictionlessExpand() : void;
      
      function beginCompleteExpansionFlow(param1:int = 0) : void;
      
      function onStoreExpandable(param1:GenericPopupEvent) : void;
      
      function isValidExpansionPart(param1:MapResource) : Boolean;
      
      function getNextExpansionData() : XML;
      
      function getNextExpansionDataSource() : BaseDataSource;
      
      function getNextBuildingExpansionData() : BuildingExpansionData;
      
      function hasNextExpansion() : Boolean;
      
      function getExpandSlotData() : Array;
      
      function getExpansionPartCount(param1:String) : int;
      
      function getTotalExpansionPartCount() : int;
      
      function getTotalExpansionLimitCount() : int;
      
      function getExpansionPartLimit(param1:String) : int;
      
      function hasReachedMaxExpansionLevel() : Boolean;
      
      function addExpansionPart(param1:MapResource) : Boolean;
      
      function maxExpansionLevel() : int;
      
      function onStoreComplete(param1:Object) : void;
      
      function grantUpgradeAwards(param1:Array) : void;
      
      function getNextUpgradeAward() : String;
      
      function getExpandCashNeeded() : int;
      
      function get expandPriceMultiplier() : Number;
      
      function getExpansionPartString() : String;
      
      function getFriendRewardNameByType(param1:String) : String;
      
      function getPartAskMethod(param1:String) : String;
      
      function conditionallySwapOnFullyExpanded() : void;
      
      function completeExpansionLevel() : void;
      
      function expandBuildingUsingCurrencyOrCash() : Boolean;
      
      function getPriceForExpansion() : Object;
   }
}

