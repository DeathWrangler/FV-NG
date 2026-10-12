package Managers
{
   import Classes.MapResource;
   import Classes.VisitorManager;
   import Engine.Events.TransactionEvent;
   import Engine.Managers.TransactionManager;
   import flash.events.Event;
   
   public class InstanceDataStoreManager
   {
      
      private static var s_dataStore:Object = {};
      
      private static var s_initialized:Boolean = false;
      
      private static var s_nextValidId:Number = 0;
      
      private static var s_earlyAttachList:Array = new Array();
      
      private static var s_disabled:Boolean = false;
      
      public function InstanceDataStoreManager()
      {
         super();
      }
      
      public static function get isEnabled() : Boolean
      {
         return !s_disabled;
      }
      
      private static function get dataStore() : Object
      {
         if(Global.worldManager.isVisitingNeighbor())
         {
            return VisitorManager.getInstance().instanceDataStore;
         }
         return s_dataStore;
      }
      
      public static function attachInstanceToKey(mapResource:MapResource) : void
      {
         var storageKey:String = mapResource.persistentDataKey;
         if(storageKey)
         {
            if(!dataStore.hasOwnProperty(storageKey))
            {
               dataStore[storageKey] = new Object();
            }
            if(s_initialized)
            {
               mapResource.attachSuccessCallback(storageKey);
            }
            else
            {
               s_earlyAttachList.push(mapResource);
            }
         }
      }
      
      public static function onUserChange(e:Event) : void
      {
         var resource:MapResource = null;
         var storageKey:String = null;
         for each(resource in s_earlyAttachList)
         {
            resource.attachSuccessCallback(resource.persistentDataKey);
         }
         s_earlyAttachList = null;
         for(storageKey in s_dataStore)
         {
            Global.world.dispatchEvent(new Event(eventIdForKey(storageKey)));
         }
      }
      
      public static function detatchInstanceFromKey(mapResource:MapResource) : void
      {
      }
      
      public static function destroyInstanceData(storageKey:String) : void
      {
         if(Boolean(storageKey) && dataStore.hasOwnProperty(storageKey))
         {
            delete dataStore[storageKey];
         }
      }
      
      public static function getPersistentData(mapResource:MapResource, featureName:String, dataName:String) : Object
      {
         return getPersistentDataForKey(mapResource.persistentDataKey,featureName,dataName);
      }
      
      public static function getPersistentDataForKey(storageKey:String, featureName:String, dataName:String) : Object
      {
         var result:Object = null;
         if(Boolean(dataStore[storageKey]) && Boolean(dataStore[storageKey][featureName]))
         {
            if(dataName)
            {
               if(dataStore[storageKey][featureName].hasOwnProperty(dataName))
               {
                  result = dataStore[storageKey][featureName][dataName];
               }
            }
            else
            {
               result = dataStore[storageKey][featureName];
            }
         }
         return result;
      }
      
      private static function setSpecificPersistentDataVolatile(storageKey:String, persistentData:Object, featureName:String, dataName:String = null) : void
      {
         if(!dataStore[storageKey])
         {
            dataStore[storageKey] = new Object();
         }
         if(dataName)
         {
            if(!dataStore[storageKey].hasOwnProperty(featureName))
            {
               dataStore[storageKey][featureName] = new Object();
            }
            dataStore[storageKey][featureName][dataName] = persistentData;
         }
         else
         {
            dataStore[storageKey][featureName] = persistentData;
         }
      }
      
      public static function setPersistentDataVolatile(mapResource:MapResource, persistentData:Object, featureName:String, dataName:String = null) : void
      {
         var storageKey:String = mapResource.persistentDataKey;
         if(!storageKey)
         {
            storageKey = getTempId(mapResource);
            mapResource.attachToPersistentData(storageKey);
         }
         setSpecificPersistentDataVolatile(storageKey,persistentData,featureName,dataName);
      }
      
      public static function loadObject(persistentStore:Object) : void
      {
         if(persistentStore)
         {
            s_dataStore = persistentStore;
            initialize();
         }
         else
         {
            s_disabled = true;
         }
      }
      
      public static function getTempId(mapResource:MapResource) : String
      {
         var result:String = mapResource.getId() + ":" + s_nextValidId.toString(16);
         ++s_nextValidId;
         return result;
      }
      
      private static function isTempId(storageKey:String) : Boolean
      {
         return storageKey.search(":") == -1;
      }
      
      private static function loadInstanceData(storageKey:String, persistentData:Object, featureName:String) : void
      {
         if(!dataStore.hasOwnProperty(storageKey))
         {
            dataStore[storageKey] = new Object();
         }
         dataStore[storageKey][featureName] = persistentData;
      }
      
      public static function initialize() : void
      {
         if(!s_initialized)
         {
            s_initialized = true;
            TransactionManager.getInstance().addEventListener(TransactionEvent.COMPLETED,onTransactionComplete);
         }
      }
      
      public static function eventIdForKey(storageKey:String) : String
      {
         return "IDS." + storageKey;
      }
      
      public static function listenForChange(storageKey:String, handler:Function, useWeakReference:Boolean = false) : void
      {
         Global.world.addEventListener(eventIdForKey(storageKey),handler,false,0,useWeakReference);
      }
      
      public static function stopListeningForChange(storageKey:String, handler:Function) : void
      {
         Global.world.removeEventListener(eventIdForKey(storageKey),handler,false);
      }
      
      private static function onTransactionComplete(event:TransactionEvent) : void
      {
         var storageKeyChanges:Array = null;
         var keyChange:Object = null;
         var storageKey:String = null;
         var instanceId:int = 0;
         var worldId:String = null;
         var instance:MapResource = null;
         var oldKey:String = null;
         var instanceStoreData:Array = null;
         var instanceChange:Object = null;
         var instanceKey:String = null;
         var featureName:String = null;
         var newValue:Object = null;
         if(Boolean(event && event.transaction && event.transaction.rawResult) && Boolean(event.transaction.rawResult) && Boolean(event.transaction.rawResult.metadata))
         {
            if(event.transaction.rawResult.metadata.StorageKeyChanges)
            {
               storageKeyChanges = event.transaction.rawResult.metadata.StorageKeyChanges;
               if(storageKeyChanges)
               {
                  for each(keyChange in storageKeyChanges)
                  {
                     storageKey = keyChange.key;
                     instanceId = int(keyChange.id);
                     worldId = keyChange.world;
                     if(worldId == Global.worldManager.currentWorldType)
                     {
                        instance = Global.world.getObjectById(instanceId) as MapResource;
                        if(instance)
                        {
                           oldKey = instance.persistentDataKey;
                           if(Boolean(oldKey) && isTempId(oldKey))
                           {
                              destroyInstanceData(oldKey);
                           }
                           instance.attachToPersistentData(storageKey);
                        }
                     }
                  }
               }
            }
            if(event.transaction.rawResult.metadata.InstanceDataStore)
            {
               instanceStoreData = event.transaction.rawResult.metadata.InstanceDataStore;
               if(instanceStoreData != null)
               {
                  for each(instanceChange in instanceStoreData)
                  {
                     instanceKey = instanceChange.key;
                     featureName = instanceChange.feature;
                     newValue = instanceChange.value;
                     setSpecificPersistentDataVolatile(instanceKey,newValue,featureName);
                     Global.world.dispatchEvent(new Event(eventIdForKey(instanceKey)));
                  }
               }
            }
         }
      }
   }
}

