package Managers
{
   import Classes.FeatureBuilding;
   import Classes.MapResource;
   import Classes.ZItem.FarmItem;
   
   public class FeatureBuildingGiftContentDataManager
   {
      
      private static var s_instances:Object = {};
      
      private static var s_canInstantiate:Boolean = false;
      
      private static const UNPLACED_KEY:String = "unplaced";
      
      private static const OPTION_NAME:String = "giftData";
      
      private var m_data:Object;
      
      private var m_featureOptionsManager:FeatureOptionsManager;
      
      private var m_featureName:String;
      
      public function FeatureBuildingGiftContentDataManager(featureName:String)
      {
         super();
         if(!s_canInstantiate)
         {
            throw new Error("Cannot instantiate FeatureBuildingGiftContentDataManager directly. Use FeatureBuildingGiftContentDataManager.getInstance.");
         }
         this.m_featureOptionsManager = FeatureOptionsManager.getInstance();
         this.m_featureName = featureName;
         this.readFeatureOptions();
      }
      
      public static function getInstance(featureName:String) : FeatureBuildingGiftContentDataManager
      {
         var result:FeatureBuildingGiftContentDataManager = null;
         var newInstance:FeatureBuildingGiftContentDataManager = null;
         if(s_instances[featureName])
         {
            result = s_instances[featureName];
         }
         else
         {
            s_canInstantiate = true;
            newInstance = new FeatureBuildingGiftContentDataManager(featureName);
            s_instances[featureName] = newInstance;
            result = newInstance;
            s_canInstantiate = false;
         }
         return result;
      }
      
      public static function sellStorageItem(itemCode:String, count:int = 1) : void
      {
         var classType:Class = null;
         var mapResource:MapResource = null;
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
         if(farmItem)
         {
            classType = farmItem.getMapResourceClass();
            if(classType)
            {
               mapResource = new classType(farmItem.name);
               if(mapResource)
               {
                  sellWorldItem(mapResource,count,true);
               }
            }
         }
      }
      
      public static function sellWorldItem(item:MapResource, count:int = 1, fromStorage:Boolean = false) : void
      {
         var itemName:String = null;
         var farmItem:FarmItem = null;
         var storage:String = null;
         var optionData:FeatureBuildingGiftContentDataManager = null;
         for(itemName in s_instances)
         {
            farmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
            if(farmItem)
            {
               storage = farmItem.storageClass;
               if(Global.storageSettings.storageCanTake(storage,item))
               {
                  optionData = s_instances[itemName];
                  optionData.removeGiftItemFromBuilding(item.getItem().code,1,-1,false);
               }
            }
         }
      }
      
      public static function sellBuilding(building:FeatureBuilding) : void
      {
         var contentData:FeatureBuildingGiftContentDataManager = s_instances[building.getItemName()];
         if(contentData)
         {
            contentData.clearAllItems(building.getId());
         }
      }
      
      public function clearAllItems(buildingId:Number) : void
      {
         this.readFeatureOptions();
         var buildingKey:String = this.getBuildingKeyFromId(buildingId);
         if(this.m_data[buildingKey])
         {
            this.m_data[buildingKey] = null;
            delete this.m_data[buildingKey];
            this.writeFeatureOptions();
         }
      }
      
      public function getFriendListForItemCode(itemCode:String, buildingId:Number) : Array
      {
         var i:int = 0;
         var friends:Object = null;
         var friendKey:String = null;
         var amount:Number = NaN;
         var friendUID:String = null;
         this.readFeatureOptions();
         var buildingKey:String = this.getBuildingKeyFromId(buildingId);
         var buildingData:Object = this.m_data[buildingKey];
         var result:Array = new Array();
         if(Boolean(buildingData) && Boolean(buildingData["c" + itemCode]))
         {
            friends = buildingData["c" + itemCode];
            for(friendKey in friends)
            {
               amount = Number(friends[friendKey]);
               friendUID = friendKey.substring(1,friendKey.length);
               for(i = 0; i < amount; i++)
               {
                  result.push(friendUID);
               }
            }
         }
         return result;
      }
      
      public function addGiftItemToBuilding(itemCode:String, buildingId:Number) : void
      {
         this.readFeatureOptions();
         var senderUIDKey:String = this.decrementItemCode(UNPLACED_KEY,itemCode);
         if(senderUIDKey)
         {
            this.incrementItemCode(this.getBuildingKeyFromId(buildingId),itemCode,senderUIDKey);
            this.writeFeatureOptions();
         }
      }
      
      public function removeGiftItemFromBuilding(itemCode:String, count:int, buildingId:Number, addToUnplaced:Boolean = true) : void
      {
         var senderUIDKey:String = null;
         this.readFeatureOptions();
         var changedData:Boolean = false;
         var removedItems:int = 0;
         var buildingKey:String = this.getBuildingKeyFromId(buildingId);
         while(removedItems < count)
         {
            senderUIDKey = this.decrementItemCode(buildingKey,itemCode);
            if(senderUIDKey)
            {
               changedData = true;
               if(addToUnplaced)
               {
                  this.incrementItemCode(UNPLACED_KEY,itemCode,senderUIDKey);
               }
            }
            removedItems++;
         }
         if(changedData)
         {
            this.writeFeatureOptions();
         }
      }
      
      private function readFeatureOptions() : void
      {
         if(!this.m_data && Global.player.initFinished)
         {
            this.m_data = this.m_featureOptionsManager.getFeatureOption(this.m_featureName,OPTION_NAME);
            if(!this.m_data)
            {
               this.m_data = {};
            }
         }
      }
      
      private function writeFeatureOptions() : void
      {
         this.m_featureOptionsManager.setFeatureOption(this.m_featureName,OPTION_NAME,this.m_data);
         this.m_featureOptionsManager.save();
      }
      
      private function decrementItemCode(buildingKey:String, itemCode:String) : String
      {
         var friends:Object = null;
         var numFriends:Number = NaN;
         var deletedFriends:Number = NaN;
         var friendKey:String = null;
         var amount:int = 0;
         var optionData:Object = this.m_data[buildingKey];
         if(!optionData)
         {
            optionData = {};
         }
         var returnValue:String = null;
         var itemCodeKey:String = "c" + itemCode;
         if(optionData[itemCodeKey])
         {
            friends = optionData[itemCodeKey];
            numFriends = 0;
            deletedFriends = 0;
            for(friendKey in friends)
            {
               numFriends++;
               amount = int(friends[friendKey]);
               if(!isNaN(amount))
               {
                  amount--;
                  if(amount > 0)
                  {
                     friends[friendKey] = amount;
                  }
                  else
                  {
                     delete friends[friendKey];
                     deletedFriends++;
                  }
                  returnValue = friendKey;
                  break;
               }
               deletedFriends++;
               delete friends[friendKey];
            }
            if(deletedFriends > 0 && deletedFriends == numFriends)
            {
               delete optionData[itemCodeKey];
            }
         }
         this.m_data[buildingKey] = optionData;
         return friendKey;
      }
      
      private function incrementItemCode(buildingKey:String, itemCode:String, senderUidKey:String) : void
      {
         var newItemCodeData:Object = null;
         var optionData:Object = this.m_data[buildingKey];
         if(!optionData)
         {
            optionData = {};
         }
         var itemCodeKey:String = "c" + itemCode;
         if(optionData[itemCodeKey])
         {
            if(optionData[itemCodeKey][senderUidKey])
            {
               optionData[itemCodeKey][senderUidKey] += 1;
            }
            else
            {
               optionData[itemCodeKey][senderUidKey] = 1;
            }
         }
         else
         {
            newItemCodeData = {};
            newItemCodeData[senderUidKey] = 1;
            optionData[itemCodeKey] = newItemCodeData;
         }
         this.m_data[buildingKey] = optionData;
      }
      
      private function getBuildingKeyFromId(buildingId:Number) : String
      {
         return buildingId < 0 ? UNPLACED_KEY : "b" + buildingId;
      }
   }
}

