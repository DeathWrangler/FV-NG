package Classes.FeatureComponents
{
   import Classes.HarvestYieldsGroup;
   import Classes.ZItem.FarmItem;
   import flash.geom.Point;
   
   public interface IHarvestComponent
   {
      
      function getHarvestArrow() : Class;
      
      function canAcceptHarvestReward() : Boolean;
      
      function displayMessageForUnclaimableHarvestReward() : void;
      
      function canHarvest() : Boolean;
      
      function getTHarvestExtraParams() : Object;
      
      function getHarvestArrowOffset() : Point;
      
      function getHarvestWindowDialogUrl() : String;
      
      function getHarvestWindowNpcUrl() : String;
      
      function getHarvestWindowDialogBgUrl() : String;
      
      function getHarvestWindowLocPrefix() : String;
      
      function getHarvestWindowClassName() : String;
      
      function onPreHarvest() : void;
      
      function getHarvestCurrency() : String;
      
      function getHarvestAmount() : int;
      
      function getHarvestYieldMultiplier(param1:HarvestYieldsGroup, param2:FarmItem) : int;
      
      function onHarvestComplete(param1:Object) : void;
      
      function get needItemsForHarvest() : Boolean;
      
      function get harvestReward() : FarmItem;
   }
}

