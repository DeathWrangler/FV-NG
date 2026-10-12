package Classes.Growable
{
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.IGrowableItem;
   import Managers.InstanceDataStoreManager;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class GrowableInstanceDataProxy extends EventDispatcher
   {
      
      private static var s_instances:Object = {};
      
      private var m_storageKey:String;
      
      private var m_itemCode:String;
      
      private var m_previousProgress:int;
      
      private var m_previousTotalFed:int;
      
      private var m_visitedStages:Object;
      
      private var m_previousActual:String;
      
      private var m_previousStage:String;
      
      private var m_object:Object;
      
      private var m_lockFlag:Boolean;
      
      private var m_lockCount:int;
      
      private var m_item:IGrowableItem;
      
      private var m_stageData:Object;
      
      public function GrowableInstanceDataProxy(storageKey:String, itemCode:String)
      {
         super();
         this.m_storageKey = storageKey;
         this.m_itemCode = itemCode;
         InstanceDataStoreManager.listenForChange(storageKey,this.handleInstanceDataChanged,true);
         this.reset();
      }
      
      public static function getInstanceForResource(resource:IGrowableResource) : GrowableInstanceDataProxy
      {
         var proxy:GrowableInstanceDataProxy = null;
         if(resource != null && resource.growableMapResource.getItem() != null)
         {
            proxy = getInstanceForKey(resource.persistentDataKey,resource.growableMapResource.getItem().code);
         }
         return proxy;
      }
      
      public static function getInstanceForKey(storageKey:String, itemCode:String) : GrowableInstanceDataProxy
      {
         var lookupKey:String = null;
         var proxy:GrowableInstanceDataProxy = null;
         if(storageKey != null && storageKey != "" && itemCode != null && itemCode != "")
         {
            lookupKey = storageKey + "_" + itemCode;
            if(!s_instances.hasOwnProperty(lookupKey))
            {
               s_instances[lookupKey] = proxy = new GrowableInstanceDataProxy(storageKey,itemCode);
            }
            else
            {
               proxy = s_instances[lookupKey];
            }
         }
         return proxy;
      }
      
      public static function resetInstances() : void
      {
         var proxy:GrowableInstanceDataProxy = null;
         for each(proxy in s_instances)
         {
            proxy.reset();
         }
      }
      
      public function reset() : void
      {
         this.m_previousProgress = 0;
         this.m_previousTotalFed = 0;
         this.m_visitedStages = {"default":true};
         this.m_previousActual = null;
         this.m_previousStage = null;
         this.m_lockFlag = false;
         this.m_lockCount = 0;
         this.m_item = null;
         this.m_stageData = null;
         this.m_object = this.getEmptyPersistentData();
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_itemCode);
         if(item is IGrowableItem)
         {
            this.m_item = item as IGrowableItem;
            this.m_stageData = this.m_item.staticData.stages;
         }
         this.updateFromDataStore(false);
      }
      
      private function handleInstanceDataChanged(e:Event) : void
      {
         this.updateFromDataStore();
      }
      
      public function updateFromDataStore(notifyOnInit:Boolean = true) : void
      {
         var newObject:Object = null;
         var fieldId:String = null;
         var isDirty:Boolean = false;
         var instanceData:Object = InstanceDataStoreManager.getPersistentDataForKey(this.m_storageKey,"Growable",null);
         var isStageChange:Boolean = false;
         if(instanceData == null)
         {
            if(this.m_object == null)
            {
               this.m_object = this.getEmptyPersistentData();
               isDirty = isStageChange = notifyOnInit;
            }
         }
         else
         {
            newObject = {};
            for(fieldId in instanceData)
            {
               newObject[fieldId] = instanceData[fieldId];
            }
            if(this.m_object == null)
            {
               this.m_object = newObject;
               this.m_object["storageKey"] = this.m_storageKey;
               isDirty = isStageChange = notifyOnInit;
            }
            else
            {
               if(newObject.actual != this.m_previousActual)
               {
                  newObject.pro = this.m_previousProgress = 0;
               }
               if(newObject.stage != null && newObject.stage != "" && !this.m_visitedStages.hasOwnProperty(newObject.stage))
               {
                  newObject.code = GrowableResourceDelegate.getItemCodeFromStageKey(newObject.stage,newObject.code);
                  isStageChange = this.m_previousStage != null && this.m_previousStage != "";
               }
               else
               {
                  newObject.stage = this.m_previousStage;
               }
               if(newObject.pro < this.m_previousProgress)
               {
                  newObject.pro = this.m_previousProgress;
               }
               if(newObject.totalFed < this.m_previousTotalFed)
               {
                  newObject.totalFed = this.m_previousTotalFed;
               }
               newObject["lockFlag"] = this.m_lockFlag;
               newObject["storageKey"] = this.m_storageKey;
               for(fieldId in newObject)
               {
                  if(newObject[fieldId] != this.m_object[fieldId])
                  {
                     this.m_object = newObject;
                     isDirty = true;
                     break;
                  }
               }
            }
         }
         this.m_visitedStages[this.m_object.stage] = true;
         this.m_previousActual = this.m_object.actual;
         this.m_previousStage = this.m_object.stage;
         this.m_previousProgress = this.m_object.pro;
         this.m_previousTotalFed = this.m_object.totalFed;
         if(isStageChange)
         {
            this.notifyStageChange();
         }
         if(isDirty)
         {
            this.notifyDataChange();
         }
      }
      
      public function getEmptyPersistentData() : Object
      {
         return {
            "storageKey":this.m_storageKey,
            "code":(this.m_itemCode ? this.m_itemCode : ""),
            "actual":"",
            "stage":"",
            "pro":0,
            "totalFed":0,
            "fixed":false,
            "startTime":null,
            "stopGrowingTime":null,
            "timeFixed":null,
            "lockFlag":false
         };
      }
      
      private function notifyStageChange() : void
      {
         dispatchEvent(new Event(GrowableConstants.EVENT_STAGE_CHANGED));
      }
      
      private function notifyDataChange() : void
      {
         dispatchEvent(new Event(GrowableConstants.EVENT_DATA_CHANGED));
      }
      
      public function incrementFeedVolatile(value:int) : void
      {
         this.m_previousTotalFed += value;
         this.m_previousProgress += value;
         this.m_object.pro = this.m_previousProgress;
         this.m_object.totalFed = this.m_previousTotalFed;
         this.notifyDataChange();
      }
      
      public function setStageActualVolatile(stage:String) : void
      {
         if(stage == "" || stage == null)
         {
            stage = "default";
         }
         if(Boolean(stage) && !this.m_visitedStages.hasOwnProperty(stage))
         {
            this.m_visitedStages[stage] = true;
            this.m_previousStage = this.m_object.stage = this.m_object.actual = stage;
            this.m_object.code = GrowableResourceDelegate.getItemCodeFromStageKey(this.m_object.stage,this.m_object.code);
            this.notifyDataChange();
            this.notifyStageChange();
         }
      }
      
      public function checkAgeExpired() : Boolean
      {
         if(Boolean(this.m_object) && !this.m_object.fixed)
         {
            if(this.m_object.hasOwnProperty("stopGrowingTime") && this.m_object.stopGrowingTime != null)
            {
               if(this.m_object.stopGrowingTime < GlobalEngine.serverTime / 1000)
               {
                  this.m_object.fixed = true;
                  this.notifyDataChange();
               }
            }
         }
         return this.m_object.fixed;
      }
      
      public function setLockFlag() : void
      {
         ++this.m_lockCount;
         if(!this.m_lockFlag)
         {
            this.m_lockFlag = true;
            this.m_object["lockFlag"] = this.m_lockFlag;
            this.notifyDataChange();
         }
      }
      
      public function unsetLockFlag() : void
      {
         if(this.m_lockCount > 0)
         {
            --this.m_lockCount;
            this.m_lockFlag = this.m_lockCount > 0;
            this.m_object["lockFlag"] = this.m_lockFlag;
            if(!this.m_lockCount)
            {
               this.notifyDataChange();
            }
         }
      }
      
      public function getCurrentData() : Object
      {
         return this.m_object;
      }
   }
}

