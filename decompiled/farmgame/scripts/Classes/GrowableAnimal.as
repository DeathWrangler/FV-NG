package Classes
{
   import Classes.Growable.GrowableContest;
   import Classes.Growable.GrowableInstanceDataProxy;
   import Classes.Growable.GrowableResourceDelegate;
   import Classes.Growable.IGrowableResource;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Display.UI;
   import Managers.FarmGameSettingsManager;
   import Managers.GrowableContestManager;
   import Widgets.Tooltips.GrowableObjectToolTip;
   import Widgets.Windows.GrowableContestWindow;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class GrowableAnimal extends Animal implements IGrowableResource
   {
      
      private var m_growthDelegate:GrowableResourceDelegate;
      
      private var m_toolTip:GrowableObjectToolTip;
      
      private var m_instanceDataProxy:GrowableInstanceDataProxy;
      
      public function GrowableAnimal(animalType:String = null)
      {
         super(animalType);
         this.m_growthDelegate = new GrowableResourceDelegate(this);
      }
      
      override public function onObjectDrop() : void
      {
         super.onObjectDrop();
         this.conditionallyAttachTooltip();
      }
      
      public function isPartOfContest() : String
      {
         return this.m_growthDelegate.isPartOfContest();
      }
      
      override public function isStorable() : Boolean
      {
         return !this.isPartOfContest();
      }
      
      override public function onMouseOver(event:MouseEvent) : void
      {
         if(this.m_toolTip != null)
         {
            this.m_toolTip.onItemMouseOver();
         }
         super.onMouseOver(event);
      }
      
      override public function onMouseOut() : void
      {
         if(this.m_toolTip != null)
         {
            this.m_toolTip.onItemMouseOut();
         }
         super.onMouseOut();
      }
      
      override protected function replaceContent(newContent:DisplayObject, shouldRedrawMask:Boolean = false) : void
      {
         super.replaceContent(newContent,shouldRedrawMask);
         if(isPlaced() || isGrown())
         {
            this.conditionallyAttachTooltip();
            this.conditionallyAttachHarvestArrow();
         }
      }
      
      private function conditionallyAttachHarvestArrow() : void
      {
         if(this.isPartOfContest())
         {
            hideArrowDisplay();
         }
      }
      
      private function conditionallyAttachTooltip() : void
      {
         if(this.m_toolTip == null && GrowableObjectToolTip.checkToolTipGate() && isAttached() && Boolean(this.isPartOfContest()))
         {
            this.m_toolTip = new GrowableObjectToolTip(getPosition(),this);
            UI.addHoverWindow(this.m_toolTip);
         }
      }
      
      override public function isHarvestable() : Boolean
      {
         return this.isPartOfContest() ? false : Boolean(super.isHarvestable());
      }
      
      override public function shouldShowInstagrowMenuOption() : Boolean
      {
         return this.isPartOfContest() ? false : Boolean(super.shouldShowInstagrowMenuOption());
      }
      
      public function get currentVisibleStage() : Object
      {
         return this.m_growthDelegate.currentVisibleStage;
      }
      
      public function get startTime() : Number
      {
         return this.m_growthDelegate.startTime;
      }
      
      public function get growthProgress() : int
      {
         return this.m_growthDelegate.progress;
      }
      
      public function get nextGrowthAt() : int
      {
         return this.m_growthDelegate.currentActualStage.consumables;
      }
      
      public function get currentVisibleStageName() : String
      {
         return this.currentVisibleStage.name;
      }
      
      public function get growableMapResource() : MapResource
      {
         return this;
      }
      
      override public function attachSuccessCallback(storageKey:String) : void
      {
         super.attachSuccessCallback(storageKey);
         this.m_growthDelegate.onAttachToStorage();
         this.conditionallyAttachTooltip();
      }
      
      override public function initEmptyPersistentData() : void
      {
         super.initEmptyPersistentData();
         this.m_growthDelegate.initEmptyPersistentData();
      }
      
      override public function getCurrentImageName() : String
      {
         var baseName:String = super.getCurrentImageName();
         if(this.m_growthDelegate)
         {
            baseName = this.m_growthDelegate.getCurrentImageName(baseName);
         }
         return baseName;
      }
      
      public function feedConsumable(numConsumables:int, callback:Function = null, buy:Boolean = false) : void
      {
         this.m_growthDelegate.feed(numConsumables,callback,buy);
      }
      
      public function checkAgeExpired() : Boolean
      {
         return this.m_growthDelegate.checkAgeExpired();
      }
      
      public function getTimeTilExpire(useShortFormat:Boolean = false, useSingleUnit:Boolean = false) : String
      {
         return this.m_growthDelegate.getTimeTilExpire(useShortFormat,useSingleUnit);
      }
      
      public function getStageName() : String
      {
         return this.m_growthDelegate.getActualStageName();
      }
      
      public function getFriendlyStageName() : String
      {
         return ZLocUtils.t("Dialogs","GrowableAnimalStage_" + this.getStageName());
      }
      
      public function getFriendlyProgressString() : String
      {
         var result:String = null;
         var progress:int = this.totalFedCount;
         var remaining:int = this.maximumFedCount;
         if(!this.canStillGrow())
         {
            result = ZLocUtils.t("Dialogs","GrowableAnimalStatus_Fixed");
         }
         else if(this.m_growthDelegate.currentActualStage == this.m_growthDelegate.currentVisibleStage)
         {
            result = ZLocUtils.t("Dialogs","GrowableAnimalStatus_Growing",{
               "progress":progress,
               "remaining":remaining
            });
         }
         else
         {
            result = ZLocUtils.t("Dialogs","GrowableAnimalStatus_Partner",{});
         }
         return result;
      }
      
      public function getFriendlyStatusString() : String
      {
         return ZLocUtils.t("Dialogs","GrowableAnimalStatus_Compound",{
            "stage":this.getFriendlyStageName(),
            "status":this.getFriendlyProgressString()
         });
      }
      
      public function refreshVisibleToActual(stage:String = null) : void
      {
         this.m_growthDelegate.refreshVisibleToActual(stage);
      }
      
      public function canStillGrow() : Boolean
      {
         return this.m_growthDelegate.canStillGrow();
      }
      
      public function get consumableCash() : int
      {
         return this.m_growthDelegate.consumableCash;
      }
      
      public function get completionCash() : int
      {
         return this.m_growthDelegate.completionCost;
      }
      
      public function get completionCount() : int
      {
         return this.m_growthDelegate.completionCount;
      }
      
      public function get totalFedCount() : int
      {
         return this.m_growthDelegate.totalFedCount;
      }
      
      public function get maximumFedCount() : int
      {
         return this.m_growthDelegate.maximumFedCount;
      }
      
      public function get isFixed() : Boolean
      {
         return this.m_growthDelegate.isFixed;
      }
      
      public function get hasPendingPartnerAction() : Boolean
      {
         return this.m_growthDelegate.hasPendingPartnerAction;
      }
      
      public function get partnerId() : Number
      {
         return this.m_growthDelegate.partnerId;
      }
      
      public function get progress() : int
      {
         return this.m_growthDelegate.progress;
      }
      
      public function get stopGrowingTime() : String
      {
         return this.m_growthDelegate.stopGrowingTime;
      }
      
      public function get timeSinceStarted() : String
      {
         return this.m_growthDelegate.getTimeSinceStart();
      }
      
      public function get totalGrowingTime() : String
      {
         return this.m_growthDelegate.totalGrowingTime();
      }
      
      public function get fixedTime() : Number
      {
         return this.m_growthDelegate.fixedTime;
      }
      
      public function get lockFlag() : Boolean
      {
         return this.m_growthDelegate.lockFlag;
      }
      
      public function get visibleStageName() : String
      {
         return this.m_growthDelegate.visibleStageName;
      }
      
      public function getGrowableInstanceData() : Object
      {
         return this.instanceDataProxy.getCurrentData();
      }
      
      override public function setPersistentDataVolatile(persistentData:Object, featureName:String, dataName:String = null) : void
      {
         super.setPersistentDataVolatile(persistentData,featureName,dataName);
         this.instanceDataProxy.updateFromDataStore();
      }
      
      private function get instanceDataProxy() : GrowableInstanceDataProxy
      {
         if(this.m_instanceDataProxy == null)
         {
            this.m_instanceDataProxy = GrowableInstanceDataProxy.getInstanceForResource(this);
         }
         return this.m_instanceDataProxy;
      }
      
      private function hasPartner() : Boolean
      {
         var entry:Object = null;
         var result:Boolean = false;
         var contest:GrowableContest = GrowableContestManager.instance.getContestForInstance(this);
         if(contest)
         {
            entry = contest.getContestEntryForKey(this.persistentDataKey);
            if(entry)
            {
               result = Boolean(entry.partner);
            }
         }
         return result;
      }
      
      override public function onSell() : void
      {
         var contest:GrowableContest = null;
         if(this.isSellable())
         {
            contest = GrowableContestManager.instance.getContestForInstance(this);
            if(contest)
            {
               contest.locallyRemoveParticipant(this);
            }
            super.onSell();
         }
      }
      
      override public function isSellable() : Boolean
      {
         return Boolean(Global.flashHotParams["USE_INSTANCE_BASED_DELETE"]) && !this.hasPartner();
      }
      
      override public function canBeSurfaced() : Boolean
      {
         return !this.isPartOfContest() && Boolean(super.canBeSurfaced());
      }
      
      override public function allowDelete() : Boolean
      {
         return Boolean(Global.flashHotParams["USE_INSTANCE_BASED_DELETE"]) && !this.hasPartner();
      }
      
      override public function isClearable() : Boolean
      {
         return this.allowDelete();
      }
      
      override protected function canShowSellMenuItem() : Boolean
      {
         return this.isSellable();
      }
      
      override protected function generateMenuItems() : void
      {
         var contest:GrowableContest = null;
         var buildingItemName:String = null;
         var buildingItem:FarmItem = null;
         var buildingName:String = null;
         super.generateMenuItems();
         if(this.isPartOfContest())
         {
            contest = GrowableContestManager.instance.getContestForInstance(this);
            buildingItemName = contest.getBuildingName();
            buildingItem = Global.farmGameSettingsManager.getFarmItemByName(buildingItemName);
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               buildingName = buildingItem.getStringFromDataSource("buildingName");
            }
            else
            {
               buildingName = buildingItem.xml.@buildingName;
            }
            m_menuItems.push({
               "label":ZLocUtils.t("Dialogs",buildingName + "_ContextMenuOpenContestText"),
               "action":GrowableContestWindow.ACTION_OPEN_CONTEST
            });
         }
      }
      
      override public function detach() : void
      {
         if(this.m_toolTip != null)
         {
            this.m_toolTip.detach();
            this.m_toolTip = null;
         }
         this.m_growthDelegate.detach();
         super.detach();
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            if(m_wanderingObject != this)
            {
               switch(item.action)
               {
                  case GrowableContestWindow.ACTION_OPEN_CONTEST:
                     GrowableContestWindow.showWindowForContest(GrowableContestManager.instance.getContestForInstance(this));
                     break;
                  default:
                     super.onMenuClick(event);
               }
            }
         }
      }
   }
}

