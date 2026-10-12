package Classes.FeatureComponents
{
   import Classes.MapResource;
   import Classes.ZItem.FarmItem;
   
   public interface IStorageComponent
   {
      
      function getStorageItemClass() : String;
      
      function buildContainedItem(param1:String) : Object;
      
      function getContents() : Array;
      
      function getStorageTypes() : Array;
      
      function removeContents(param1:String, param2:int = 1, param3:int = 0) : void;
      
      function matchesOrigin(param1:int) : Boolean;
      
      function setAmount(param1:String, param2:int) : void;
      
      function getAmount(param1:String) : Number;
      
      function getItemLimit(param1:FarmItem) : Number;
      
      function showStorageFullDialog() : void;
      
      function canTakeItem(param1:MapResource, param2:Boolean = true) : Boolean;
      
      function showItemStorageLimitFullDialog(param1:MapResource) : void;
      
      function addItem(param1:MapResource, param2:int = 0, param3:Boolean = false, param4:Boolean = true, param5:Boolean = false, param6:int = 1) : Boolean;
      
      function get maxPotentialCapacity() : Number;
      
      function onStoreComplete(param1:Object) : void;
      
      function get capacity() : Number;
      
      function set capacity(param1:Number) : void;
      
      function showStorageContextMenu() : Boolean;
      
      function addItemUsingCurrency(param1:MapResource, param2:int = 0, param3:Boolean = false, param4:Boolean = true, param5:Boolean = false, param6:String = "", param7:int = 1) : Boolean;
   }
}

