package Classes.FeatureDataObjects
{
   import Classes.StorageBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.storage.PartItem;
   
   public class BuildingExpansionData
   {
      
      private var m_parts:Vector.<PartItem>;
      
      private var m_experimentGate:String;
      
      private var m_experimentVariant:int;
      
      private var m_runtimeGate:String;
      
      private var m_level:int;
      
      private var m_capacity:int;
      
      private var m_numTotalPartsNeeded:int;
      
      public function BuildingExpansionData(parts:Vector.<PartItem>, pLevel:int, pCapacity:int, experimentGate:String = null, experimentVariant:int = 0, runtimeGate:String = null)
      {
         var part:PartItem = null;
         super();
         this.m_parts = parts;
         this.m_level = pLevel;
         this.m_capacity = pCapacity;
         this.m_experimentGate = experimentGate;
         this.m_experimentVariant = experimentVariant;
         this.m_runtimeGate = runtimeGate;
         this.m_numTotalPartsNeeded = 0;
         for each(part in this.m_parts)
         {
            this.m_numTotalPartsNeeded += part.qtyNeeded;
         }
      }
      
      public function get level() : int
      {
         return this.m_level;
      }
      
      public function get capacity() : int
      {
         return this.m_capacity;
      }
      
      public function get matsNeeded() : int
      {
         return this.m_numTotalPartsNeeded;
      }
      
      public function get parts() : Vector.<PartItem>
      {
         return this.m_parts;
      }
      
      public function getPartByCode(itemCode:String) : PartItem
      {
         var part:PartItem = null;
         var result:PartItem = null;
         if(this.m_parts)
         {
            for each(part in this.m_parts)
            {
               if(part.item.code == itemCode)
               {
                  result = part;
                  break;
               }
            }
         }
         return result;
      }
      
      public function getPartByName(itemName:String) : PartItem
      {
         var part:PartItem = null;
         var result:PartItem = null;
         for each(part in this.m_parts)
         {
            if(part.item.name == itemName)
            {
               result = part;
               break;
            }
         }
         return result;
      }
      
      public function getPartNames() : Array
      {
         var part:PartItem = null;
         var result:Array = [];
         for each(part in this.m_parts)
         {
            result.push(part.item.name);
         }
         return result;
      }
      
      public function generateWithdrawalUIData(building:StorageBuilding, shouldAddSendGiftsObject:Boolean) : Array
      {
         var partItem:PartItem = null;
         var partFarmItem:FarmItem = null;
         var partData:Object = null;
         var object:Object = null;
         var result:Array = [];
         for each(partItem in this.m_parts)
         {
            partFarmItem = partItem.item;
            if(partFarmItem)
            {
               partData = new Object();
               partData.sendGiftsToFriends = false;
               partData.itemCode = partFarmItem.code;
               partData.name = partFarmItem.name;
               partData.needCount = partItem.qtyNeeded;
               partData.currentCount = building.getExpansionPartCount(partFarmItem.code);
               partData.friendlyName = partFarmItem.friendlyName;
               partData.icon = partFarmItem.icon;
               partData.cost = String(partFarmItem.cash);
               result.push(partData);
            }
         }
         if(shouldAddSendGiftsObject)
         {
            object = new Object();
            object.sendGiftsToFriends = true;
            result.push(object);
         }
         return result;
      }
      
      public function getTotalPartsOnHand(building:StorageBuilding) : int
      {
         var partItem:PartItem = null;
         var partFarmItem:FarmItem = null;
         var result:int = 0;
         for each(partItem in this.m_parts)
         {
            partFarmItem = partItem.item;
            if(partFarmItem)
            {
               result += building.getExpansionPartCount(partFarmItem.code);
            }
         }
         return result;
      }
      
      public function isEnabled() : Boolean
      {
         var experimentOn:Boolean = true;
         var runtimeOn:Boolean = true;
         if(this.m_experimentGate)
         {
            experimentOn = Global.experimentManager.getExperimentVariant(this.m_experimentGate) == this.m_experimentVariant;
         }
         if(this.m_runtimeGate)
         {
            runtimeOn = Global.flashHotParams[this.m_runtimeGate] > 0;
         }
         return experimentOn && runtimeOn;
      }
   }
}

