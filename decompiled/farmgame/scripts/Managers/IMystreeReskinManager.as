package Managers
{
   import flash.utils.Dictionary;
   
   public interface IMystreeReskinManager
   {
      
      function getSaplingTendStartFor(param1:String) : int;
      
      function getTotalTendTimeFor(param1:int) : int;
      
      function getMystree(param1:String) : void;
      
      function plantSapling(param1:String) : void;
      
      function getLevelData(param1:String) : Dictionary;
      
      function hasSunshineBuckets(param1:String) : Boolean;
      
      function tendSapling(param1:String, param2:Boolean = true) : void;
      
      function getPlotUnlockCost() : int;
      
      function onBuyPlot(param1:String) : Boolean;
      
      function canTend(param1:String) : Boolean;
      
      function getSaplingLevelFor(param1:String) : int;
      
      function isAnySaplingWaiting() : Boolean;
      
      function isAdBtnShouldbeAvailable() : Boolean;
      
      function getMaxLevel() : Number;
      
      function getPlotData() : Object;
      
      function openMystreeUI() : void;
      
      function handleHUDClick() : void;
      
      function getSpeedUpCost() : int;
      
      function getWindowName() : String;
      
      function getTimeUntilPostFeedEnabled() : int;
      
      function canPostFeed() : Boolean;
      
      function postGeneralFeed(param1:Function = null) : void;
      
      function showCraftingWindowWithItem() : void;
      
      function getBucketPackages() : Array;
      
      function buySunshineBuckets(param1:String) : void;
      
      function getUniqueMystreeCount() : int;
      
      function setClaimedTreeFeatureOption(param1:String) : void;
      
      function onMystreePlaced(param1:String) : void;
      
      function getByDialogURL() : String;
      
      function canGetMystree(param1:String) : Boolean;
      
      function isFeatureAvailable() : Boolean;
   }
}

