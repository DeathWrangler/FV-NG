package Classes.Growable
{
   import Classes.GrowableAnimalItem;
   import Classes.MapResource;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.IGrowableItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericXMLDialog;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Managers.GrowableContestManager;
   import Transactions.TGenericTransaction;
   import Transactions.TGrowableUseConsumable;
   import flash.events.Event;
   
   public class GrowableResourceDelegate
   {
      
      public static var GROWABLE_PERSISTENT_STORE_KEY:String = "Growable";
      
      private var m_staticData:Object = null;
      
      private var m_resource:IGrowableResource = null;
      
      private var m_visibleStage:String = null;
      
      private var m_instanceDataProxy:GrowableInstanceDataProxy;
      
      public function GrowableResourceDelegate(resource:IGrowableResource)
      {
         super();
         this.m_resource = resource;
      }
      
      public static function getItemCodeFromStageKey(stageKey:String, defaultCode:String = null) : String
      {
         var stageFields:Array = null;
         var result:String = defaultCode;
         if(stageKey)
         {
            stageFields = stageKey.split(":",2);
            if(stageFields.length == 2)
            {
               result = stageFields[0];
            }
         }
         return result;
      }
      
      public function onAttachToStorage() : void
      {
         this.m_visibleStage = this.instanceData.stage;
         this.growableMapResource.reloadImage();
      }
      
      private function get instanceDataProxy() : GrowableInstanceDataProxy
      {
         if(this.m_instanceDataProxy == null)
         {
            this.m_instanceDataProxy = GrowableInstanceDataProxy.getInstanceForResource(this.m_resource);
            this.m_instanceDataProxy.addEventListener(GrowableConstants.EVENT_STAGE_CHANGED,this.onResourceStageChange);
         }
         return this.m_instanceDataProxy;
      }
      
      public function detach() : void
      {
         if(this.m_instanceDataProxy != null)
         {
            this.m_instanceDataProxy.removeEventListener(GrowableConstants.EVENT_STAGE_CHANGED,this.onResourceStageChange);
         }
      }
      
      private function onResourceStageChange(e:Event) : void
      {
         var contest:GrowableContest = null;
         var contestEntry:Object = null;
         var feedType:String = null;
         var promptItem:FarmItem = null;
         var prompt:GenericXMLDialog = null;
         this.m_visibleStage = this.instanceData.stage;
         if(Boolean(this.growableMapResource) && (!this.growableMapResource.getItem() || this.instanceData.code != this.growableMapResource.getItem().code))
         {
            this.setItemByCode(this.instanceData.code);
         }
         this.growableMapResource.reloadImage();
         if(Boolean(this.m_resource.growableMapResource.isAttached() && this.isPartOfContest()) && Boolean(!this.m_resource.isFixed) && this.m_resource.totalFedCount < this.m_resource.maximumFedCount)
         {
            contest = GrowableContestManager.instance.getContestForInstance(this.m_resource);
            if(contest)
            {
               contestEntry = contest.getContestEntryForKey(this.m_resource.persistentDataKey);
               feedType = contestEntry["partner"] ? GrowableContest.FEED_TYPE_PROGRESSION_PARTNER : GrowableContest.FEED_TYPE_PROGRESSION_SOLO;
               if(contest.canPostFeed(feedType,null,this.m_resource.persistentDataKey))
               {
                  promptItem = this.m_resource.growableMapResource.getItem();
                  if(promptItem is GrowableAnimalItem)
                  {
                     promptItem = Global.farmGameSettingsManager.getFarmItemByCode((promptItem as GrowableAnimalItem).growthConsumable);
                  }
                  contest.statCount("state_change_dialog","impression",this.m_resource.getStageName());
                  prompt = new GenericXMLDialog(null,null,null,Global.farmGameSettingsManager.getImageByName(promptItem.name,"icon",false),100,100,contest.getZLocString("Notifications","StageProgression_ShortStory_UserMessagePrompt",{"stageName":this.m_resource.getFriendlyStageName()}),null,true,ZLocUtils.t_pk("Dialogs:Share"),function(event:Event):void
                  {
                     contest.postGeneralFeed(feedType,handlePostProgressionFeedCallback,null,m_resource.persistentDataKey);
                     contest.statCount("state_change_dialog","share",m_resource.getStageName());
                  },null,function(event:Event):void
                  {
                     contest.statCount("state_change_dialog","close",m_resource.getStageName());
                  });
                  UI.displayPopup(prompt,false,"",true);
               }
            }
         }
      }
      
      private function handlePostProgressionFeedCallback(result:Object) : void
      {
      }
      
      private function get instanceData() : Object
      {
         var result:Object = this.instanceDataProxy.getCurrentData();
         if(Boolean(result.stage) && !this.m_visibleStage)
         {
            this.m_visibleStage = result.stage;
            this.growableMapResource.reloadImage();
         }
         return result;
      }
      
      public function get storageId() : String
      {
         return this.m_resource.growableMapResource.persistentDataKey;
      }
      
      private function get staticData() : Object
      {
         var baseItem:IGrowableItem = null;
         if(!this.m_staticData)
         {
            baseItem = this.m_resource.growableMapResource.getItem() as IGrowableItem;
            if(baseItem)
            {
               this.m_staticData = baseItem.staticData;
            }
         }
         return this.m_staticData;
      }
      
      private function setItemByCode(code:String) : void
      {
         this.m_staticData = null;
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(code);
         if(item)
         {
            this.growableMapResource.setItem(item);
            this.growableMapResource.setDisplayObjectDirty(true);
            this.growableMapResource.reloadImage();
         }
      }
      
      public function get growableMapResource() : MapResource
      {
         return this.m_resource.growableMapResource;
      }
      
      public function get visibleStageName() : String
      {
         return this.m_visibleStage;
      }
      
      private function setStageActual(newStage:String) : void
      {
         this.instanceDataProxy.setStageActualVolatile(newStage);
      }
      
      public function get progress() : int
      {
         return this.instanceData.pro as int;
      }
      
      public function get startTime() : Number
      {
         var result:Number = Number(this.instanceData["startTime"]);
         if(!result)
         {
            result = GlobalEngine.serverTime / 1000;
         }
         return result;
      }
      
      public function get isFixed() : Boolean
      {
         return this.instanceData.fixed as Boolean;
      }
      
      public function get hasPendingPartnerAction() : Boolean
      {
         return this.instanceData.pendingPartnerAction;
      }
      
      public function get partnerId() : Number
      {
         return this.instanceData.partner as Number;
      }
      
      public function get stopGrowingTime() : String
      {
         return this.instanceData.stopGrowingTime;
      }
      
      public function get fixedTime() : Number
      {
         return this.instanceData.timeFixed;
      }
      
      public function get lockFlag() : Boolean
      {
         return this.instanceData.lockFlag as Boolean;
      }
      
      public function get currentVisibleStage() : Object
      {
         var stage:Object = null;
         var firstStage:Object = null;
         var data:Object = this.staticData;
         var currentStageName:String = this.visibleStageName;
         for each(stage in data.stages)
         {
            if(!firstStage)
            {
               if(stage.name == "default")
               {
                  firstStage = stage;
               }
            }
            if(stage.name == currentStageName)
            {
               return stage;
            }
         }
         return firstStage;
      }
      
      public function getStageDataByStageKey(stageName:String) : Object
      {
         var stages:Object = null;
         var stageData:Object = null;
         var result:Object = null;
         var code:String = getItemCodeFromStageKey(stageName,this.instanceData.code);
         var farmItem:IGrowableItem = Global.farmGameSettingsManager.getFarmItemByCode(code) as IGrowableItem;
         if(farmItem)
         {
            stages = farmItem.staticData.stages;
            if(stages)
            {
               for each(stageData in stages)
               {
                  if(!result && (stageData.name == "" || stageData.name == "default"))
                  {
                     result = stageData;
                  }
                  else if(stageData.name == stageName)
                  {
                     result = stageData;
                     break;
                  }
               }
            }
         }
         return result;
      }
      
      public function get currentActualStage() : Object
      {
         return this.getStageDataByStageKey(this.instanceData.actual);
      }
      
      public function getCurrentImageName(baseImageNodeName:String) : String
      {
         var stage:Object = this.currentVisibleStage;
         if(stage)
         {
            baseImageNodeName += stage.image;
         }
         return baseImageNodeName;
      }
      
      public function feed(numConsumables:int = 1, callbackFunc:Function = null, buy:Boolean = false) : void
      {
         var success:Boolean = false;
         var cashRequired:int = 0;
         var dataProxy:GrowableInstanceDataProxy = null;
         var transactionCallBack:Function = null;
         var data:Object = this.instanceData;
         if(!data.lockFlag)
         {
            if(this.currentActualStage.consumables > 0 && !this.checkAgeExpired())
            {
               success = false;
               if(!buy)
               {
                  Global.player.removeGiftWithKey(this.consumableItemCode);
                  success = true;
               }
               else
               {
                  cashRequired = this.consumableItem.cash * numConsumables;
                  if(Global.player.canBuyCash(cashRequired))
                  {
                     Global.player.cash -= cashRequired;
                     success = true;
                  }
                  else
                  {
                     FarmStatsManager.count(GrowableContest.STATS_COUNTER,"errors","feed","insufficient_cash");
                     callbackFunc({
                        "complete":true,
                        "stage":this.currentActualStage.name
                     });
                  }
               }
               if(success)
               {
                  dataProxy = this.instanceDataProxy;
                  transactionCallBack = this.onFeedComplete;
                  if(data.pro + numConsumables >= this.currentActualStage.consumables)
                  {
                     dataProxy.setLockFlag();
                     transactionCallBack = function(data:Object):void
                     {
                        dataProxy.unsetLockFlag();
                     };
                  }
                  TransactionManager.addTransaction(new TGrowableUseConsumable(this,numConsumables,transactionCallBack,buy));
                  dataProxy.incrementFeedVolatile(numConsumables);
                  callbackFunc({
                     "complete":true,
                     "stage":this.currentActualStage.name
                  });
               }
            }
         }
      }
      
      public function onFeedComplete(data:Object) : void
      {
         if(data.hasOwnProperty("feedData") && data.feedData != null)
         {
         }
      }
      
      private function handleFeedPostReturn(result:Object, success:Boolean) : void
      {
      }
      
      public function initEmptyPersistentData() : Object
      {
         return this.instanceDataProxy.getEmptyPersistentData();
      }
      
      public function checkAgeExpired() : Boolean
      {
         var isExpired:Boolean = false;
         if(this.instanceDataProxy.checkAgeExpired())
         {
            isExpired = true;
            TransactionManager.addTransaction(new TGenericTransaction(GrowableConstants.SERVICE_GROWABLE,"checkAgeExpired",null,[this.growableMapResource.persistentDataKey]));
         }
         return isExpired;
      }
      
      private function convertSecondsToString(seconds:Number, useSingleUnit:Boolean = false) : String
      {
         if(seconds < FarmGameUtil.NUM_SECS_IN_MINUTE)
         {
            return ZLocUtils.t("Dialogs","Growable_TimeLessThanMinute");
         }
         return FarmGameUtil.toFriendlyTime(seconds,useSingleUnit);
      }
      
      public function getTimeTilExpire(useShortFormat:Boolean = false, useSingleUnit:Boolean = false) : String
      {
         var result:String = null;
         var timeLeft:Number = this.instanceData.stopGrowingTime - GlobalEngine.serverTime / 1000;
         if(this.isFixed)
         {
            result = ZLocUtils.t("Dialogs","Growable_TimeReady");
         }
         else if(useShortFormat)
         {
            result = ZLocUtils.t("Dialogs","Growable_TimeLeftShort",{"timeLeft":this.convertSecondsToString(timeLeft,useSingleUnit)});
         }
         else
         {
            result = ZLocUtils.t("Dialogs","Growable_TimeLeft",{"timeLeft":this.convertSecondsToString(timeLeft,useSingleUnit)});
         }
         return result;
      }
      
      public function getTimeSinceStart() : String
      {
         var time:Number = GlobalEngine.serverTime / 1000 - this.startTime;
         return this.convertSecondsToString(time);
      }
      
      public function totalGrowingTime() : String
      {
         var result:String = null;
         var time:Number = NaN;
         if(this.fixedTime)
         {
            time = this.fixedTime - this.startTime;
            result = this.convertSecondsToString(time);
         }
         else
         {
            result = this.getTimeSinceStart();
         }
         return result;
      }
      
      public function getActualStageName() : String
      {
         return String(this.instanceData.actual);
      }
      
      public function refreshVisibleToActual(actualOverride:String = null) : void
      {
         var resourceIds:Array = null;
         var resourceId:Number = NaN;
         var currentData:Object = this.instanceData;
         var actual:String = currentData.actual;
         if(actualOverride)
         {
            actual = actualOverride;
         }
         if(actual == "")
         {
            actual = "default";
         }
         if(actual != this.m_visibleStage)
         {
            this.m_visibleStage = actual;
            this.setStageActual(actual);
            this.growableMapResource.setDisplayObjectDirty(true);
            this.growableMapResource.reloadImage();
            resourceId = this.growableMapResource.getId();
            if(resourceId > 0)
            {
               resourceIds = [resourceId];
            }
            TransactionManager.addTransaction(new TGenericTransaction(GrowableConstants.SERVICE_GROWABLE,"onAcceptGrowth",null,[this.storageId,resourceIds]));
         }
      }
      
      public function isPartOfContest() : String
      {
         var result:String = null;
         if(!Global.worldManager.isVisiting() && Global.player.initFinished)
         {
            result = GrowableContestManager.instance.getContestIdForInstance(this.m_resource);
         }
         return result;
      }
      
      public function canStillGrow() : Boolean
      {
         var result:Boolean = true;
         if(this.isFixed || this.totalFedCount >= this.maximumFedCount)
         {
            result = false;
         }
         return result;
      }
      
      public function get consumableItemCode() : String
      {
         return (this.growableMapResource.getItem() as GrowableAnimalItem).growthConsumable;
      }
      
      public function get consumableItem() : FarmItem
      {
         return Global.farmGameSettingsManager.getFarmItemByCode(this.consumableItemCode);
      }
      
      public function get consumableCash() : int
      {
         return this.consumableItem.cash;
      }
      
      public function get completionCost() : int
      {
         return this.completionCount * this.consumableCash;
      }
      
      public function get completionCount() : int
      {
         return this.maximumFedCount - this.totalFedCount;
      }
      
      public function get totalFedCount() : int
      {
         return this.instanceData.totalFed;
      }
      
      public function get maximumFedCount() : int
      {
         return this.staticData.maxConsumables;
      }
   }
}

