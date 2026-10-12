package Classes
{
   import Classes.ZItem.FarmItem;
   import Classes.consumables.CFeatureBuildingTicket;
   import Classes.consumables.CHarvestAllAnimals;
   import Classes.consumables.CHarvestAnimals;
   import Classes.consumables.CHarvestOrchards;
   import Classes.consumables.CLootTicket;
   import Classes.consumables.COrganicFertilizer;
   import Classes.consumables.CSuperPlot;
   import Engine.Managers.TransactionManager;
   import Transactions.TUseConsumable;
   import flash.utils.getDefinitionByName;
   
   public class Consumable extends ItemInstance
   {
      
      private var subClasses:Array = [CFeatureBuildingTicket,CLootTicket,COrganicFertilizer,CSuperPlot,CHarvestAnimals,CHarvestAllAnimals,CHarvestOrchards];
      
      public function Consumable(itemName:String)
      {
         super(itemName);
      }
      
      public static function createConsumable(itemName:String, data:Object = null) : Consumable
      {
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         var tempClass:Class = getDefinitionByName("Classes.consumables." + item.className) as Class;
         var consumable:Consumable = new tempClass(itemName);
         consumable.initialize(data);
         return consumable;
      }
      
      public static function createDynamicConsumable(itemName:String, className:String = "") : Consumable
      {
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         var tempClass:Class = getDefinitionByName("Classes.consumables." + className) as Class;
         return new tempClass(itemName);
      }
      
      public function onUse() : void
      {
      }
      
      public function onFailedPerform() : void
      {
      }
      
      public function canUse() : Boolean
      {
         return true;
      }
      
      public function isOptimistic() : Boolean
      {
         return false;
      }
      
      public function setTargetsBusy() : Array
      {
         return null;
      }
      
      public function initialize(data:Object) : void
      {
      }
      
      public function consume(isGift:Boolean = true, allowReshopping:Boolean = true, userID:String = "", isFree:Boolean = false, storageId:int = -1, itemCount:int = 1) : void
      {
         TransactionManager.addTransaction(new TUseConsumable(this,isGift,allowReshopping,userID,isFree,storageId,itemCount),true);
      }
      
      public function extraTransactionParams() : Object
      {
         return {};
      }
   }
}

