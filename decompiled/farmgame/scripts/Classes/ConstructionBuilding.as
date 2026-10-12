package Classes
{
   import Classes.Constants.Experiments;
   import Classes.Constants.QuestConstants;
   import Classes.Constants.StatsTrackingConstants;
   import Classes.Terrain.TerrainUtil;
   import Classes.ZItem.BuildingItem;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.OnboardingUtil;
   import Classes.util.ZLocFailoverEntry;
   import Classes.util.ZLocUtils;
   import DataSources.BaseDataSource;
   import Display.BaseConstructionBuildingWithdrawal;
   import Display.BeehiveConstructionWithdrawal;
   import Display.BotanicalGardenConstructionWithdrawal;
   import Display.ConstructionBuildingWithdrawal;
   import Display.ContextMenuItem;
   import Display.FarmDynamicDialog;
   import Display.FeatureBuildingWithdrawal;
   import Display.FishermansCoveDialog;
   import Display.FrenchChateauConstructionWithdrawal;
   import Display.GarageConstructionWithdrawal;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.GreenhouseWithdrawal;
   import Display.HUD.StatsDropDown;
   import Display.HalloweenCastleDuckulaConstructionWithdrawal;
   import Display.HalloweenHauntedHouseConstructionWithdrawal;
   import Display.JapaneseBarnConstructionWithdrawal;
   import Display.LootableFixedFeatureBuildingWithdrawal;
   import Display.MultiStageConstructionFrameWithdrawal;
   import Display.NurseryConstructionWithdrawal;
   import Display.OrchardConstructionWithdrawal;
   import Display.PigpenConstructionWithdrawal;
   import Display.RuntimeDrivenCharityWindow;
   import Display.Snowman2010Dialog;
   import Display.Snowman2010FrameConstructionWithdrawal;
   import Display.SpringGardenBuildable2011Dialog;
   import Display.SpringGardenBuildable2011FrameConstructionWithdrawal;
   import Display.SpringWaterWheelBuildable2011Dialog;
   import Display.SpringWaterWheelBuildable2011FrameConstructionWithdrawal;
   import Display.StorageWithdrawalDynamicDialog;
   import Display.Stpatty2011BuildingDialog;
   import Display.Stpatty2011FrameConstructionWithdrawal;
   import Display.UI;
   import Display.Valentines2011BuildingDialog;
   import Display.Valentines2011FrameConstructionWithdrawal;
   import Display.WinterWorkshopDialog;
   import Engine.Helpers.Vector3;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import GameMode.GMBuildingPart;
   import GameMode.GameMode;
   import Managers.AOEManager;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureMessagingManager;
   import Managers.PartyManager;
   import Transactions.TCancelFriendReward;
   import Transactions.TTransformBuilding;
   import Widgets.Windows.AnimalBreeding.AnimalBreedingWindow;
   import Widgets.Windows.BloomContentsWindow;
   import Widgets.Windows.Breeding.AnimalBreedingContentsWindow;
   import Widgets.Windows.Breeding.BabyNurseryContentsWindow;
   import Widgets.Windows.Breeding.BreedingWindow;
   import Widgets.Windows.Breeding.LabContentsWindow;
   import Widgets.Windows.Breeding.NurseryContentsWindow;
   import Widgets.Windows.Breeding.RandomPlacementContentsWindow;
   import Widgets.Windows.Breeding.SeedlingNurseryContentsWindow;
   import Widgets.Windows.BushelBaby.BushelBabyBuildingShimWindow;
   import Widgets.Windows.CaptureFeatureWindow;
   import Widgets.Windows.CaringTreeWindow;
   import Widgets.Windows.ContingencyBuildableDialog;
   import Widgets.Windows.Crafting.CraftingSiloWindow;
   import Widgets.Windows.Crafting.CraftingWorkshopWindow;
   import Widgets.Windows.Crafting.CraftshopWindow;
   import Widgets.Windows.Crafting.PizzashopWindow;
   import Widgets.Windows.Crafting.VillageIngredientStorageWindow;
   import Widgets.Windows.Doghouse.DoghouseContentsWindow;
   import Widgets.Windows.DragonBreedingWindow;
   import Widgets.Windows.DuckPond.DuckPondWindow;
   import Widgets.Windows.ExpiredCaringTreeWindow;
   import Widgets.Windows.FeatureBuildingShimWindow;
   import Widgets.Windows.FeatureBuildingUGCShimWindow;
   import Widgets.Windows.FeatureCrafting.FeatureCraftingContentsWindow;
   import Widgets.Windows.FeatureCraftingBuildingShimWindow;
   import Widgets.Windows.FishingDerby.FishingDerbyCollectionWindow;
   import Widgets.Windows.FishingDerby.FishingDerbyStoreWindow;
   import Widgets.Windows.GivingBuildingWindow;
   import Widgets.Windows.GroomingBarnWindow;
   import Widgets.Windows.GrowableContestWindow;
   import Widgets.Windows.HollyBrightTreeWindow;
   import Widgets.Windows.IrrigationWellLookInsideWindow;
   import Widgets.Windows.ItemCollectionWindow;
   import Widgets.Windows.ItemContest.ItemContestWindow;
   import Widgets.Windows.JMIOnClickTileWindow;
   import Widgets.Windows.LootTicketBooth.LootTicketBoothWindow;
   import Widgets.Windows.MasterySignCollectionWindow;
   import Widgets.Windows.MultiStageBuildingDialog;
   import Widgets.Windows.Orchards.OrchardFeatureBuildingManagementWindow;
   import Widgets.Windows.PigPen.PigPenWindow;
   import Widgets.Windows.PuzzleHouseWindow;
   import Widgets.Windows.RecipeBooth.RecipeBoothWindow;
   import Widgets.Windows.SeedDispenser.SeedDispenserContentsWindow;
   import Widgets.Windows.SheepPen.SheepPenWindow;
   import Widgets.Windows.SocialRaffle.SocialRaffleWindow;
   import Widgets.Windows.SpecialTileWindow;
   import Widgets.Windows.UGCDecoWindow;
   import Widgets.Windows.WishingFountainWindow;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   
   public class ConstructionBuilding extends StorageBuilding
   {
      
      public static const MENU_COMPLETE_NOW:String = "complete_now";
      
      public static const MENU_ASK_FOR_PARTS:String = "ask_for_parts";
      
      private static const MENU_COMPLETE_NOW_PRICE:String = "completeNowPrice";
      
      public static const FALLBACK_KEY:String = "constructionBuilding_";
      
      protected static const EMPTY_TRANSFORM:String = "none";
      
      private static const REWARD_TYPE_MATERIAL_COMPLETE:String = "MaterialComplete";
      
      private static const REWARD_TYPE_INCREMENTAL:String = "IncrementalReward";
      
      private static const REWARD_TYPE_HALFWAY_COMPLETE:String = "HalfwayComplete";
      
      private var m_matCompletePrefix:String = "";
      
      private var m_matComplete:String = "";
      
      private var m_matCompleteSuffix:String = ".png";
      
      protected var m_buildingName:String;
      
      protected var m_dialogName:String;
      
      protected var m_disableBuildOnPlace:Boolean;
      
      protected var m_sawFullyFinished:Boolean = false;
      
      protected var m_displayStorageDialog:Boolean = true;
      
      public var m_displayFinishedDialog:Boolean = true;
      
      protected var m_menuEnabled:Boolean = true;
      
      protected var m_storageLimitedEnd:String = null;
      
      protected var m_transformObj:MapResource = null;
      
      protected var m_dialogConfig:Object = null;
      
      public var m_queueRewardFeedPopup:Boolean = true;
      
      private var ClassCompilingArray:Array;
      
      public function ConstructionBuilding(buildingType:String = null)
      {
         var item:XML = null;
         var imageList:XMLList = null;
         var itemName:String = null;
         this.ClassCompilingArray = [BeehiveConstructionWithdrawal,BotanicalGardenConstructionWithdrawal,DuckPondWindow,GreenhouseWithdrawal,FeatureBuildingWithdrawal,FrenchChateauConstructionWithdrawal,GarageConstructionWithdrawal,JapaneseBarnConstructionWithdrawal,NurseryConstructionWithdrawal,HalloweenHauntedHouseConstructionWithdrawal,HalloweenCastleDuckulaConstructionWithdrawal,OrchardConstructionBuilding,PigpenConstructionWithdrawal,BaseConstructionBuildingWithdrawal,OrchardConstructionWithdrawal,TurkeyRoostBuilding,WinterWorkshopDialog,Snowman2010Dialog,Snowman2010FrameConstructionWithdrawal,StorageWithdrawalDynamicDialog,Stpatty2011BuildingDialog,Stpatty2011FrameConstructionWithdrawal,SpringGardenBuildable2011Dialog,SpringGardenBuildable2011FrameConstructionWithdrawal,SpringWaterWheelBuildable2011Dialog,SpringWaterWheelBuildable2011FrameConstructionWithdrawal,Valentines2011BuildingDialog,Valentines2011FrameConstructionWithdrawal,MutableAnimalBaby,MutableAnimalCrate,MutableAnimalEgg,BreedingWindow
         ,PigPenWindow,SheepPenWindow,SocialRaffleWindow,CraftingWorkshopWindow,CraftshopWindow,PizzashopWindow,CraftingSiloWindow,VillageIngredientStorageWindow,FishermansCoveDialog,LootableFixedFeatureBuildingWithdrawal,LabContentsWindow,DoghouseContentsWindow,AnimalBreedingContentsWindow,AnimalBreedingWindow,FishingDerbyStoreWindow,FishingDerbyCollectionWindow,BloomContentsWindow,RandomPlacementContentsWindow,MultiStageBuildingDialog,MultiStageConstructionFrameWithdrawal,MasterySignCollectionWindow,ItemCollectionWindow,CaptureFeatureWindow,FeatureCraftingContentsWindow,LootTicketBoothWindow,RecipeBoothWindow,SeedDispenserContentsWindow,UGCDecoWindow,FeatureBuildingUGCShimWindow,FeatureBuildingShimWindow,FeatureCraftingBuildingShimWindow,BushelBabyBuildingShimWindow,GrowableContestWindow,ItemContestWindow,NurseryContentsWindow,BabyNurseryContentsWindow,SeedlingNurseryContentsWindow,WishingFountainWindow,PuzzleHouseWindow,OrchardFeatureBuildingManagementWindow,CaringTreeWindow,ExpiredCaringTreeWindow
         ,IrrigationWellLookInsideWindow,RuntimeDrivenCharityWindow,HangingGardensCraftingShopBuilding,HollyBrightTreeWindow,GivingBuildingWindow,VillageResourceBuilding,GroomingBarnWindow,ContingencyBuildableDialog,DragonBreedingWindow,SpecialTileWindow,JMIOnClickTileWindow];
         super(buildingType);
         m_isFullyBuilt = false;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            if(m_item.hasPropertyInDataSource("buildingName"))
            {
               this.m_buildingName = m_item.getStringFromDataSource("buildingName");
            }
            else
            {
               this.m_buildingName = m_item.getStringFromDataSource("className");
               this.m_buildingName = this.m_buildingName.substring(0,this.m_buildingName.indexOf("ConstructionBuilding"));
            }
            if(m_item.hasPropertyInDataSource("dialogName"))
            {
               this.m_dialogName = m_item.getStringFromDataSource("dialogName");
            }
            else
            {
               this.m_dialogName = this.m_buildingName;
            }
            if(m_item.hasPropertyInDataSource("storageLimitedEnd"))
            {
               this.m_storageLimitedEnd = m_item.getStringFromDataSource("storageLimitedEnd");
            }
            if(m_item.hasPropertyInDataSource("disableBuildOnPlace"))
            {
               this.m_disableBuildOnPlace = m_item.getBoolFromDataSource("disableBuildOnPlace");
            }
            this.m_matCompletePrefix = m_item.getStringFromDataSourceArray("name","matCompletePrefix","prefixUrl","image");
            this.m_matComplete = m_item.getStringFromDataSourceArray("name","matCompletePrefix","url","image");
            this.m_matCompleteSuffix = m_item.getStringFromDataSourceArray("name","matCompleteSuffix","suffixUrl","image");
         }
         else
         {
            item = m_item.xml;
            if(item.hasOwnProperty("@buildingName") && Boolean(item.@buildingName.length()))
            {
               this.m_buildingName = item.@buildingName;
            }
            else
            {
               this.m_buildingName = item.@className;
               this.m_buildingName = this.m_buildingName.substring(0,this.m_buildingName.indexOf("ConstructionBuilding"));
            }
            if(item.hasOwnProperty("@dialogName") && Boolean(item.@dialogName.length()))
            {
               this.m_dialogName = item.@dialogName;
            }
            else
            {
               this.m_dialogName = this.m_buildingName;
            }
            if(item.hasOwnProperty("storageLimitedEnd"))
            {
               this.m_storageLimitedEnd = item.storageLimitedEnd;
            }
            if(item.hasOwnProperty("@disableBuildOnPlace") && item.@disableBuildOnPlace == "true")
            {
               this.m_disableBuildOnPlace = true;
            }
            else
            {
               this.m_disableBuildOnPlace = false;
            }
            imageList = item.elements("image");
            for each(item in imageList)
            {
               itemName = item.@name;
               switch(itemName)
               {
                  case "matCompletePrefix":
                     this.m_matCompletePrefix = item.@prefixUrl;
                     this.m_matComplete = item.@url;
                     break;
                  case "matCompleteSuffix":
                     this.m_matCompleteSuffix = item.@suffixUrl;
               }
            }
         }
         this.m_dialogConfig = Global.farmGameSettingsManager.getBuildingDialogConfig(this.getItem().name);
         if(this.m_dialogConfig == null)
         {
            this.m_dialogConfig = Global.farmGameSettingsManager.getBuildingDialogConfig(this.m_buildingName);
         }
      }
      
      override public function loadObject(data:Object) : void
      {
         super.loadObject(data);
         FeatureMessagingManager.getInstance().registerFeatureInitialized(this.buildingName,this.displayStorageDialog);
      }
      
      public function getDialogConfig() : Object
      {
         return this.m_dialogConfig;
      }
      
      public function get buildingName() : String
      {
         return this.m_buildingName;
      }
      
      override public function onBuildComplete(result:Object) : void
      {
         super.onBuildComplete(result);
         setState(STATE_CONSTRUCTION);
         var statsKingdom:String = this.getItem().resourcePrefix + "_" + StatsTrackingConstants.DIALOG_STATE_PLACE_KINGDOM;
         this.displayStorageDialog(ConstructionBuilding.MENU_ASK_FOR_PARTS);
         FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,statsKingdom,StatsTrackingConstants.DIALOG_STATS_VIEW_PHYLUM);
         FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,this.getItem().name,"level1",StatsTrackingConstants.DIALOG_STATE_PLACE_KINGDOM,StatsTrackingConstants.DIALOG_STATS_VIEW_PHYLUM);
      }
      
      protected function onMaterialComplete(result:Object) : void
      {
         var farmItem:FarmItem = null;
         var friendlyName:String = null;
         var feedIcon:String = null;
         var statsKingdom:String = null;
         if(Boolean(result.rewardLink) && Boolean(result.rewardItem) && this.m_matCompleteSuffix.length != 0)
         {
            farmItem = Global.farmGameSettingsManager.getFarmItemByName(result.rewardItem);
            friendlyName = farmItem.friendlyName;
            feedIcon = this.m_matComplete ? this.m_matComplete : this.m_matCompletePrefix + result.rewardItem + this.m_matCompleteSuffix;
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FACEBOOK_FEED_ICONS) > 1)
            {
               feedIcon = farmItem.getImageByName("feed",false);
            }
            statsKingdom = this.getItem().resourcePrefix + "_" + StatsTrackingConstants.DIALOG_STATE_MATERIALS_COMPLETE_KINGDOM;
            this.createRewardFeed(this.m_buildingName + "MaterialComplete",statsKingdom,result.rewardLink,feedIcon,null,farmItem.icon,this.statCountConstructableMaterialComplete,friendlyName,{
               "item":ZLocUtils.tk_pk(friendlyName),
               "items":ZLocUtils.tk_pk(friendlyName)
            },StatsTrackingConstants.DIALOG_STATE_MATERIALS_COMPLETE_KINGDOM,this.m_dialogName + "MaterialComplete","",FALLBACK_KEY + "MaterialComplete",{"subcategory":m_item.name});
         }
      }
      
      protected function onHalfWayFinished(result:Object) : void
      {
         var statsKingdom:String = this.getItem().resourcePrefix + "_" + StatsTrackingConstants.DIALOG_STATE_HALFWAY_COMPLETE_KINGDOM;
         var halfDialogIcon:String = getItem().getImageByName("halfDialogIcon",false);
         var dialogIcon:String = halfDialogIcon != null ? Global.getAssetURL(halfDialogIcon) : this.getItem().icon;
         var feedIcon:String = getItem().getImageByName("halfIcon",false);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FACEBOOK_FEED_ICONS) > 1)
         {
            feedIcon = getItem().getImageByName("feed",false);
         }
         this.createRewardFeed(this.m_buildingName + "HalfBuilt",statsKingdom,result.rewardLink,feedIcon,null,dialogIcon,this.statCountConstructableHalfway,null,null,StatsTrackingConstants.DIALOG_STATE_HALFWAY_COMPLETE_KINGDOM,this.m_dialogName + "HalfBuilt","",FALLBACK_KEY + "HalfBuilt",{"subcategory":m_item.name},true);
      }
      
      public function onFullyFinished(result:Object, transformedObj:MapResource = null) : void
      {
         var statsKingdom:String = null;
         var completeDialogIcon:String = null;
         var dialogIcon:String = null;
         var dialogName:String = null;
         var hasLocalization:Boolean = false;
         var finishedRewardItemName:String = null;
         var feedIcon:String = null;
         var finishedStorageBuilding:StorageBuilding = null;
         this.grantFinishedReward(result);
         if(result.hasOwnProperty("rewardLink") && Boolean(result.rewardLink))
         {
            statsKingdom = this.getItem().resourcePrefix + "_" + StatsTrackingConstants.DIALOG_STATE_EXPANSION_COMPLETE_KINGDOM;
            completeDialogIcon = getItem().getImageByName("completeDialogIcon",false);
            dialogIcon = completeDialogIcon != null ? Global.getAssetURL(completeDialogIcon) : this.getItem().icon;
            dialogName = this.m_buildingName + "FullyBuilt";
            hasLocalization = ZLocUtils.hasString("Dialogs",dialogName);
            if(!hasLocalization)
            {
               dialogName = this.m_dialogName + "FullyBuilt";
            }
            finishedRewardItemName = result.hasOwnProperty("gift") && Boolean(result.gift) ? result.gift : "";
            feedIcon = getItem().getImageByName("completeIcon",false);
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FACEBOOK_FEED_ICONS) > 1)
            {
               feedIcon = getItem().getImageByName("feed",false);
            }
            this.createRewardFeed(this.m_buildingName + "FullyBuilt",statsKingdom,result.rewardLink,feedIcon,this.showFinishedDialog,dialogIcon,this.statCountConstructableComplete,null,null,StatsTrackingConstants.DIALOG_STATE_EXPANSION_COMPLETE_KINGDOM,dialogName,finishedRewardItemName,FALLBACK_KEY + "FullyBuilt",{"subcategory":m_item.name});
         }
         if(isSmartBuildablesEnabled())
         {
            finishedStorageBuilding = transformedObj as StorageBuilding;
            if(finishedStorageBuilding)
            {
               finishedStorageBuilding.applySmartSystems(result);
            }
            else
            {
               finishedStorageBuilding = this.m_transformObj as StorageBuilding;
               if(finishedStorageBuilding)
               {
                  finishedStorageBuilding.applySmartSystems(result);
               }
            }
         }
      }
      
      protected function grantFinishedReward(result:Object) : void
      {
         if(result.hasOwnProperty("gift") && Boolean(result.gift))
         {
            Global.player.addGift(result.gift);
         }
      }
      
      protected function statCountConstructableComplete() : void
      {
         FarmStatsManager.count("shortfeed","feed_constructable_complete",this.m_buildingName);
         this.showFinishedDialog();
      }
      
      protected function statCountConstructableHalfway() : void
      {
         FarmStatsManager.count("shortfeed","feed_constructable_halfway",this.m_buildingName);
      }
      
      protected function statCountConstructableStarted() : void
      {
         FarmStatsManager.count("shortfeed","feed_constructable_started",this.m_buildingName);
      }
      
      protected function statCountConstructableMaterialComplete() : void
      {
         FarmStatsManager.count("shortfeed","feed_constructable_materialcomplete",this.m_buildingName);
      }
      
      override protected function showStorageContextMenu() : Boolean
      {
         var result:Boolean = super.showStorageContextMenu();
         if(result)
         {
            if(null != this.m_storageLimitedEnd)
            {
               result = FarmGameUtil.checkEndDateGate(this.m_storageLimitedEnd);
            }
            else
            {
               result = true;
            }
         }
         return result;
      }
      
      override public function displayStorageDialog(defaultAction:String = "") : void
      {
         var dialogClassName:String = null;
         var dialogClass:Class = null;
         var dialog:* = undefined;
         var dialogName:String = null;
         var searchName:String = null;
         var key:String = null;
         var storage4DDialog:StorageWithdrawalDynamicDialog = null;
         var constructionDialog:Class = null;
         var constructDialog:ConstructionBuildingWithdrawal = null;
         if(!this.showStorageContextMenu())
         {
            return;
         }
         if(this.m_dialogConfig)
         {
            dialogClassName = this.m_dialogConfig.className;
            dialogClass = getDefinitionByName(dialogClassName) as Class;
            dialog = new dialogClass(this);
            dialog.defaultAction = defaultAction;
            UI.displayStorageDialog(dialog);
         }
         else
         {
            dialogName = "Display.ConstructionBuildingWithdrawal";
            searchName = this.m_buildingName + "ConstructionWithdrawal";
            for(key in this.ClassCompilingArray)
            {
               if(this.ClassCompilingArray[key].toString().search(searchName) != -1)
               {
                  dialogName = "Display." + searchName;
                  break;
               }
            }
            if(Boolean(this.getItem().constructionUI) && this.getItem().constructionUI.search(".swf") == -1)
            {
               this["on" + this.getItem().constructionUI.charAt(0).toUpperCase() + this.getItem().constructionUI.substr(1)]();
            }
            else
            {
               storage4DDialog = FarmDynamicDialog.createDialog(this.m_buildingName,StorageWithdrawalDynamicDialog) as StorageWithdrawalDynamicDialog;
               if(storage4DDialog != null)
               {
                  storage4DDialog.addImport("building",this);
                  storage4DDialog.addImport("defaultAction",defaultAction);
                  storage4DDialog.setup();
                  storage4DDialog.show(true);
               }
               else
               {
                  constructionDialog = getDefinitionByName(dialogName) as Class;
                  constructDialog = new constructionDialog(this);
                  if(null != constructDialog)
                  {
                     constructDialog.defaultAction = defaultAction;
                     UI.displayStorageDialog(constructDialog);
                  }
               }
            }
         }
      }
      
      protected function showFinishedDialog() : void
      {
         var key2:String = null;
         var buildingClass:Class = null;
         var buildings:Array = null;
         var finishedItem:FarmItem = null;
         var fItemArray:Array = null;
         var arrayObj:Object = null;
         var buildingName:String = "";
         if(this.m_displayFinishedDialog)
         {
            for(key2 in this.ClassCompilingArray)
            {
               if(this.ClassCompilingArray[key2].toString().search(this.m_buildingName + "Building") != -1)
               {
                  buildingName = "Classes." + this.m_buildingName + "Building";
                  break;
               }
            }
            if(buildingName != "")
            {
               buildingClass = getDefinitionByName(buildingName) as Class;
               buildings = Global.world.getObjectsByClass(buildingClass);
               buildings[0].displayStorageDialog();
            }
            else if(this.m_transformObj != null && this.m_transformObj.hasOwnProperty("displayStorageDialog"))
            {
               (this.m_transformObj as Object).displayStorageDialog();
            }
            else
            {
               finishedItem = this.getFinishedItem();
               if(null != finishedItem)
               {
                  fItemArray = Global.world.getObjectsByName(finishedItem.name);
                  if(fItemArray.length > 0)
                  {
                     arrayObj = fItemArray[0] as Object;
                     if(arrayObj.hasOwnProperty("displayStorageDialog"))
                     {
                        fItemArray[0].displayStorageDialog();
                     }
                  }
               }
            }
         }
      }
      
      override public function move() : void
      {
         FarmStatsManager.count(this.getItem().name,"context_menu","move");
         super.move();
      }
      
      override public function sell() : void
      {
         var dialog:GenericPopup = null;
         FarmStatsManager.count(this.getItem().name,"context_menu","sell");
         var message:String = ZLocUtils.getFailoverLocString([new ZLocFailoverEntry("Dialogs",this.m_dialogName + "_Sell"),new ZLocFailoverEntry("Dialogs",FALLBACK_KEY + "Sell")],{"building":ZLocUtils.tk_pk(m_item.friendlyName)});
         dialog = new GenericPopup(message,GenericPopup.TYPE_ACCEPTCANCEL,this.onSellHandler);
         UI.displayPopup(dialog);
         FeatureMessagingManager.getInstance().unregisterFeatureInitialized(this.buildingName);
      }
      
      override protected function onAddToInventory() : void
      {
         FarmStatsManager.count(this.getItem().name,"context_menu","store");
         super.onAddToInventory();
      }
      
      private function onSellHandler(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            super.sell();
         }
      }
      
      override public function isBuilt() : Boolean
      {
         return state == STATE_CONSTRUCTION || Boolean(super.isBuilt());
      }
      
      override public function addItem(resource:MapResource, fromStorage:int = 0, isGift:Boolean = false, sendStoreItem:Boolean = true, force:Boolean = false) : Boolean
      {
         var key:String = null;
         var success:Boolean = super.addItem(resource,fromStorage,isGift,sendStoreItem,force);
         if(!isFullyBuilt() && m_count < getMaterialsNeeded())
         {
            setState(STATE_CONSTRUCTION);
            if(!isGift && this.m_displayStorageDialog)
            {
               this.displayStorageDialog();
            }
         }
         else if(!isFullyBuilt() && m_count >= getMaterialsNeeded())
         {
            m_isFullyBuilt = true;
            for(key in m_contents)
            {
               setAmount(key,0);
            }
            this.m_menuEnabled = false;
            setState(STATE_BUILT);
         }
         return success;
      }
      
      override protected function onBuilt() : void
      {
         super.onBuilt();
         setState(STATE_BUSY);
      }
      
      override public function showMenu() : void
      {
         var actionName:String = null;
         var label:String = null;
         var menuItemsArr:Array = null;
         var itemDS:BaseDataSource = null;
         var origLabel:String = null;
         var menuItems:XMLList = null;
         var item:XML = null;
         if(this.m_menuEnabled)
         {
            if(this.state == STATE_BUSY)
            {
               showObjectBusy();
            }
            else
            {
               if(FarmGameSettingsManager.isInDataSourceExperiment())
               {
                  menuItemsArr = this.m_item.getArrayFromDataSource("extraMenuItem");
                  for each(itemDS in menuItemsArr)
                  {
                     origLabel = itemDS.toString();
                     if(origLabel.length > 0)
                     {
                        if(origLabel == ConstructionBuilding.MENU_COMPLETE_NOW_PRICE)
                        {
                           label = this.getCompleteNowContextString();
                        }
                        else
                        {
                           label = ZLocUtils.t("Items",origLabel);
                        }
                        actionName = "on" + origLabel.charAt(0).toUpperCase() + origLabel.substr(1);
                        m_menuItems.push({
                           "label":label,
                           "action":actionName
                        });
                     }
                  }
               }
               else
               {
                  menuItems = this.m_item.xml.child("extraMenuItem");
                  for each(item in menuItems)
                  {
                     if(item.children()[0].toString().length > 0)
                     {
                        label = "";
                        if(item.children()[0] == ConstructionBuilding.MENU_COMPLETE_NOW_PRICE)
                        {
                           label = this.getCompleteNowContextString();
                        }
                        else
                        {
                           label = ZLocUtils.t("Items",item.children()[0]);
                        }
                        actionName = "on" + item.children()[0].toString().charAt(0).toUpperCase() + item.children()[0].toString().substr(1);
                        m_menuItems.push({
                           "label":label,
                           "action":actionName
                        });
                     }
                  }
               }
               super.showMenu();
            }
         }
      }
      
      public function onViewParty() : void
      {
         var item:XML = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            PartyManager.getInstance().displayBuildingPartyWindow(m_item.getStringFromDataSource("partyReference"),null,this);
         }
         else
         {
            item = m_item.xml;
            PartyManager.getInstance().displayBuildingPartyWindow(item.child("partyReference").toString(),null,this);
         }
      }
      
      public function onAskForParts() : void
      {
         this.displayStorageDialog(ConstructionBuilding.MENU_ASK_FOR_PARTS);
      }
      
      public function onCompleteNow() : void
      {
         if(this.getItemName() == "xuk_sheep_pen")
         {
            this.frictionlessCompleteNow();
         }
         else
         {
            this.displayStorageDialog(ConstructionBuilding.MENU_COMPLETE_NOW);
         }
      }
      
      public function onCompleteNowPrice() : void
      {
         this.onCompleteNow();
      }
      
      private function getCompleteNowContextString() : String
      {
         return ZLocUtils.t("Dialogs","FixedTreasure_Menu_Complete_FC",{"cashCost":getCashNeeded().toString()});
      }
      
      public function frictionlessCompleteNow(transformBuildingOnComplete:Boolean = false, callback:Function = null) : void
      {
         var newBuilding:Object = null;
         var discount:int = 0;
         var cashNeeded:int = getCashNeeded();
         var purchaseStatName:String = "Other";
         var finishedItem:FarmItem = this.getFinishedItem();
         if(finishedItem != null)
         {
            purchaseStatName = finishedItem.type;
         }
         if(Global.player.canBuyCash(cashNeeded,true,purchaseStatName))
         {
            newBuilding = this.transformBuilding() as Object;
            if(this.m_transformObj == null)
            {
               this.m_transformObj = newBuilding as MapResource;
            }
            if(newBuilding)
            {
               discount = newBuilding.getItem().cash - cashNeeded;
               Global.player.tryBuy(newBuilding as MapResource,false,newBuilding.getItem(),discount);
            }
            else
            {
               Global.player.cash -= cashNeeded;
            }
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_BUILDING_UI_CASH_BUY_COUNTER) > 0)
            {
               FarmStatsManager.sample(100,"fv_cash_buy","building",this.getItem().name,"complete_now",cashNeeded.toString());
            }
            TransactionManager.addTransaction(new TTransformBuilding(this,transformBuildingOnComplete,callback));
         }
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            if(item.action in this)
            {
               this[item.action]();
            }
            else
            {
               super.onMenuClick(event);
            }
         }
      }
      
      protected function generateOnConfirmShareFeed(feedAction:String, bundleData:Object, statsKingdom:String, statsClass:String, itemName:String, callbackFunction:Function = null, callbackFunctionOnAccept:Function = null) : Function
      {
         return function(event:GenericPopupEvent):void
         {
            var seenFlagStr:* = undefined;
            var seenFirstReward:* = undefined;
            if(event.button == GenericPopup.ACCEPT)
            {
               GlobalEngine.socialNetwork.publishFeedStory(feedAction,bundleData,[],false);
               if(statsKingdom != "")
               {
                  FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,statsKingdom,StatsTrackingConstants.DIALOG_STATS_SHARE_CLICK_PHYLUM);
                  FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,itemName,"level1",statsClass,StatsTrackingConstants.DIALOG_STATS_SHARE_CLICK_PHYLUM);
                  if(callbackFunctionOnAccept != null)
                  {
                     callbackFunctionOnAccept();
                  }
               }
            }
            else
            {
               TransactionManager.addTransaction(new TCancelFriendReward([bundleData["reward_link"]]));
               if(statsKingdom != "")
               {
                  FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,statsKingdom,StatsTrackingConstants.DIALOG_STATS_X_CLICK_PHYLUM);
                  FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,itemName,"level1",statsClass,StatsTrackingConstants.DIALOG_STATS_X_CLICK_PHYLUM);
               }
               if(m_disableBuildOnPlace)
               {
                  seenFlagStr = m_buildingName + "_firstReward";
                  seenFirstReward = Global.player.getSeenFlag(seenFlagStr);
               }
               if(callbackFunction != null && !(m_disableBuildOnPlace && !seenFirstReward))
               {
                  callbackFunction();
               }
               if(m_disableBuildOnPlace && !seenFirstReward && Global.worldManager.currentWorldType != "farm")
               {
                  Global.player.setSeenFlag(seenFlagStr);
               }
            }
         };
      }
      
      override public function buildStatusMessage(messageData:Array) : String
      {
         if(messageData.length < 2)
         {
            return "";
         }
         return ZLocUtils.t("FarmGame","Status_AddPart",{
            "quantity":messageData[0],
            "item":ZLocUtils.tk_pk(messageData[1])
         });
      }
      
      override protected function updateToolTipText() : void
      {
         var capacityText:String = null;
         var key:String = null;
         var mode:GameMode = null;
         var toolTip:String = null;
         if(isHighlighted())
         {
            if(Global.worldManager.isVisiting() == false)
            {
               capacityText = "";
               key = "";
               mode = Global.world.getTopGameMode();
               if(mode is GMBuildingPart)
               {
                  capacityText = getBuildingPartCapacityToolTipText((mode as GMBuildingPart).buildingPart.itemName);
               }
               else
               {
                  if(isFullyBuilt())
                  {
                     key = this.getToolTipKey("_capacity");
                  }
                  else
                  {
                     key = key = this.getToolTipKey("_mats");
                  }
                  capacityText = ZLocUtils.t("Items",key,{
                     "quantity":m_count,
                     "maximum":capacity
                  });
               }
               switch(state)
               {
                  case STATE_CONSTRUCTION:
                     toolTip = ZLocUtils.t("FarmGame","AnimalBuilding_capacity",{
                        "item":ZLocUtils.tk_pk(m_item.friendlyName),
                        "capacityStr":capacityText
                     });
                     break;
                  default:
                     toolTip = m_item.friendlyTitle;
               }
            }
            else if(Global.worldManager.isVisiting() == true)
            {
               toolTip = m_item.friendlyTitle;
            }
            if(state == STATE_BUILT)
            {
               toolTip = ZLocUtils.tk_pk_asTitle(this.getBuiltToolTipText());
            }
         }
         setToolTip(toolTip);
         updateToolTipPosition();
      }
      
      private function getToolTipKey(suffix:String) : String
      {
         var finishedBuilding:FarmItem = null;
         var key:String = this.m_buildingName + suffix;
         if(!ZLocUtils.hasString("Items",key))
         {
            key = m_item.name + suffix;
            if(!ZLocUtils.hasString("Items",key))
            {
               finishedBuilding = this.getFinishedItem();
               if(finishedBuilding != null)
               {
                  key = finishedBuilding.name + suffix;
               }
            }
         }
         return key;
      }
      
      protected function getBuiltToolTipText() : String
      {
         return m_item.friendlyName;
      }
      
      override public function onStoreComplete(result:Object) : void
      {
         var finishedItem:FarmItem = null;
         var emptyTransform:Boolean = false;
         var newBuilding:MapResource = null;
         super.onStoreComplete(result);
         switch(result.rewardType)
         {
            case REWARD_TYPE_MATERIAL_COMPLETE:
               this.onMaterialComplete(result);
               break;
            case REWARD_TYPE_INCREMENTAL:
               this.onIncrementFinished(result);
               break;
            case REWARD_TYPE_HALFWAY_COMPLETE:
               this.onHalfWayFinished(result);
               break;
            default:
               if(isFullyBuilt() && !this.m_sawFullyFinished && Boolean(result.finishedName))
               {
                  finishedItem = null;
                  emptyTransform = result.finishedName == EMPTY_TRANSFORM;
                  if(!emptyTransform)
                  {
                     finishedItem = this.getFinishedItemFromResult(result);
                     if(finishedItem == null)
                     {
                        finishedItem = this.getFinishedItem();
                     }
                  }
                  if(Boolean(finishedItem) || emptyTransform)
                  {
                     this.m_sawFullyFinished = true;
                     newBuilding = this.transformBuilding(result);
                     if(this.m_transformObj == null && !emptyTransform)
                     {
                        this.m_transformObj = newBuilding;
                     }
                     this.onFullyFinished(result,newBuilding);
                  }
               }
         }
         stopOverlay();
      }
      
      protected function onIncrementFinished(result:Object) : void
      {
         var farmItem:FarmItem = null;
         var friendlyName:String = null;
         var statsKingdom:String = null;
         var feedIcon:String = null;
         if(Boolean(result.rewardLink) && Boolean(result.rewardItem) && this.m_matCompleteSuffix.length != 0)
         {
            farmItem = Global.farmGameSettingsManager.getFarmItemByName(result.rewardItem);
            friendlyName = farmItem.friendlyName;
            statsKingdom = this.getItem().resourcePrefix + "_" + StatsTrackingConstants.DIALOG_STATE_MATERIALS_INTERVAL_KINGDOM;
            feedIcon = this.m_matComplete ? this.m_matComplete : this.m_matCompletePrefix + result.rewardItem + this.m_matCompleteSuffix;
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FACEBOOK_FEED_ICONS) > 1)
            {
               feedIcon = farmItem.getImageByName("feed",false);
            }
            this.createRewardFeed(this.m_buildingName + "IncrementFinished",statsKingdom,result.rewardLink,feedIcon,null,getItem().icon,this.statCountConstructableMaterialComplete,friendlyName,{"item":ZLocUtils.tk_pk(friendlyName)},StatsTrackingConstants.DIALOG_STATE_MATERIALS_INTERVAL_KINGDOM,this.m_dialogName + "IncrementFinished",FALLBACK_KEY + "IncrementFinished","",{"subcategory":m_item.name});
         }
      }
      
      public function transformBuilding(resultData:Object = null) : MapResource
      {
         var tempClass:Class = null;
         var typeAsClassName:String = null;
         var checkIfPlaceable:Boolean = false;
         var itemPlacable:Boolean = false;
         var overlappingAreas:Boolean = false;
         var phylum:String = null;
         var finishedItem:FarmItem = null;
         finishedItem = this.getFinishedItemFromResult(resultData);
         if(finishedItem == null)
         {
            finishedItem = this.getFinishedItem();
         }
         var currentItemName:String = getItem().name;
         Global.player.removeLimitedItem(currentItemName);
         var currentPosition:Vector3 = this.getPosition();
         var id:Number = this.getId();
         this.detach();
         if(m_count < capacity)
         {
            Global.player.updatePlayerStat(StatsDropDown.INDEX_BUILDINGS,0);
         }
         if(finishedItem != null)
         {
            if(finishedItem.className != "")
            {
               tempClass = getDefinitionByName("Classes." + finishedItem.className) as Class;
            }
            else if(finishedItem.type)
            {
               typeAsClassName = "Classes." + FarmGameUtil.toUpperCaseFirst(finishedItem.type);
               tempClass = getDefinitionByName(typeAsClassName) as Class;
               if(!tempClass)
               {
                  tempClass = getDefinitionByName("Classes.Building") as Class;
               }
            }
            else
            {
               tempClass = getDefinitionByName("Classes.Building") as Class;
            }
         }
         OnboardingUtil.conditionallyAwardOnboardingItem(this.m_buildingName);
         var transformedObject:MapResource = null;
         if(finishedItem != null)
         {
            checkIfPlaceable = this.checkIfTransformIsPlaceable();
            itemPlacable = TerrainUtil.isAreaAcceptable(finishedItem.getTerrainCodes(),currentPosition.x,currentPosition.y,currentPosition.x + finishedItem.sizeX,currentPosition.y + finishedItem.sizeY) && (!checkIfPlaceable || finishedItem.allMissingRequirements.length == 0);
            if(itemPlacable && !isStoredFeature)
            {
               transformedObject = new tempClass(finishedItem.name);
               transformedObject.setMetadata(this.getMetadata());
               transformedObject.setOuter(Global.world);
               transformedObject.setPosition(currentPosition.x,currentPosition.y,currentPosition.z);
               transformedObject.conditionallyReattach();
               transformedObject.setId(id);
               if(transformedObject is Building)
               {
                  (transformedObject as Building).setState(STATE_BUILT);
               }
               else if(transformedObject is SimpleHarvestableResource)
               {
                  (transformedObject as SimpleHarvestableResource).setState(STATE_BARE);
               }
               if(transformedObject.isAoeSource())
               {
                  overlappingAreas = AOEManager.getInstance().hasOverlappingAreas(transformedObject);
                  phylum = overlappingAreas ? "area_overlaps_another" : "area_doesnt_overlap";
                  FarmStatsManager.count(AOEManager.STATS_COUNTER_NAME,this.buildingName,"placed_and_finished",phylum);
               }
            }
            else
            {
               Global.player.addGift(finishedItem.name);
            }
         }
         if(!Global.player.getSeenFlag(this.m_buildingName + "_FirstComplete"))
         {
            Global.player.setSeenFlag(this.m_buildingName + "_FirstComplete");
            FarmStatsManager.count(AOEManager.STATS_COUNTER_NAME,this.buildingName,"first_frame_completed");
         }
         if(Boolean(transformedObject) && Boolean(resultData) && resultData.hasOwnProperty("persistantKey"))
         {
            transformedObject.attachToPersistentData(resultData["persistantKey"]);
         }
         return transformedObject;
      }
      
      protected function checkIfTransformIsPlaceable() : Boolean
      {
         return false;
      }
      
      protected function createRewardFeed(feedActionName:String, statsKingdom:String, rewardLink:String, iconURL:String, postFeedCallback:Function = null, dialogIconURL:String = null, postFeedCallbackAccept:Function = null, friendlyItemName:String = null, locParams:Object = null, statsClass:String = "", dialogName:String = null, finishedRewardItemName:String = "", fallbackFeedKey:String = "", fallbackStats:Object = null, canSuppressPopup:Boolean = false, checkboxVersion:Boolean = false, checkboxText:String = "") : void
      {
         var bundleData:Object = null;
         var dialogExtraPrizeSuffix:String = null;
         var buildingItem:BuildingItem = null;
         var localizedText:String = null;
         var dialogAsset:String = null;
         var finishedRewardItem:FarmItem = null;
         var newDialogName:String = null;
         var message:GenericIconPopup = null;
         var popupType:int = 0;
         if(null == dialogName)
         {
            dialogName = feedActionName;
         }
         var hasLocalization:Boolean = ZLocUtils.hasString("Dialogs",dialogName);
         if(!hasLocalization)
         {
            if(ZLocUtils.hasString("Dialogs",fallbackFeedKey))
            {
               hasLocalization = true;
               dialogName = fallbackFeedKey;
            }
         }
         if(Boolean(rewardLink) && hasLocalization)
         {
            if(Boolean(iconURL) && iconURL.indexOf("http") != 0)
            {
               iconURL = Global.getAssetURL(iconURL);
            }
            bundleData = {
               "first_name":Global.player.firstName,
               "reward_link":rewardLink,
               "images":[{
                  "href":"{SN_APP_URL}" + rewardLink,
                  "src":iconURL
               }]
            };
            if(fallbackFeedKey != "")
            {
               bundleData.fallbackAction = fallbackFeedKey;
               if(fallbackStats != null)
               {
                  bundleData.fallbackStats = fallbackStats;
               }
            }
            if(friendlyItemName != null)
            {
               bundleData["item"] = friendlyItemName;
            }
            bundleData["building"] = m_item.friendlyName;
            if(locParams)
            {
               locParams["building"] = ZLocUtils.tk_pk(m_item.friendlyName);
            }
            else
            {
               locParams = {"building":ZLocUtils.tk_pk(m_item.friendlyName)};
            }
            if(finishedRewardItemName)
            {
               finishedRewardItem = Global.farmGameSettingsManager.getFarmItemByName(finishedRewardItemName);
               if(finishedRewardItem != null)
               {
                  bundleData["finishedReward"] = finishedRewardItem.friendlyName;
                  if(locParams)
                  {
                     locParams["finishedReward"] = ZLocUtils.tk_pk(finishedRewardItem.friendlyName);
                  }
                  else
                  {
                     locParams = {"finishedReward":ZLocUtils.tk_pk(finishedRewardItem.friendlyName)};
                  }
               }
            }
            dialogExtraPrizeSuffix = "";
            buildingItem = this.getItem() as BuildingItem;
            if(Boolean(buildingItem) && buildingItem.completeWorldScore > 0)
            {
               newDialogName = dialogName + "_" + QuestConstants.REWARD_WORLD_SCORE;
               if(ZLocUtils.hasString("Dialogs",newDialogName))
               {
                  locParams["scoreAmount"] = buildingItem.completeWorldScore;
                  locParams["scoreUnit"] = ZLocUtils.t("FarmGame",buildingItem.completeWorldScoreUnit);
                  dialogName = newDialogName;
               }
            }
            if(!dialogIconURL)
            {
               dialogIconURL = iconURL;
            }
            if(locParams)
            {
               localizedText = ZLocUtils.t("Dialogs",dialogName,locParams);
            }
            else
            {
               localizedText = ZLocUtils.t("Dialogs",dialogName);
            }
            dialogAsset = GenericIconPopup.GENERIC_CALLOUT_ASSET_CHECKBOX;
            if(this.showPopUpSideCard())
            {
               dialogAsset = GenericIconPopup.GENERIC_CALLOUT_ASSET_CHECKBOX_SIDECARD;
            }
            if(canSuppressPopup && UI.shouldBlockPopupForRetention() && Global.farmGameSettingsManager.shouldBlockProgressionPopupForItem(this.getItem()))
            {
               UI.handlePopupDisplayForRetention(localizedText,GenericPopup.TYPE_SHARE,this.generateOnConfirmShareFeed(feedActionName,bundleData,statsKingdom,statsClass,getItem().name,postFeedCallback,postFeedCallbackAccept),dialogIconURL,"feed-" + feedActionName,{"addToQueue":true});
            }
            else
            {
               if(Global.player.inExperimentFeedCheckBoxV2())
               {
                  popupType = GenericPopup.TYPE_SHARE;
                  if(checkboxVersion)
                  {
                     popupType = GenericPopup.TYPE_SHARECHECKBOX;
                  }
                  message = new GenericIconPopup(localizedText,popupType,this.generateOnConfirmShareFeed(feedActionName,bundleData,statsKingdom,statsClass,getItem().name,postFeedCallback,postFeedCallbackAccept),dialogIconURL,false,!checkboxVersion,"",false,dialogAsset,null,false,false,checkboxText);
                  message.setSideCardText(this.sideCardAdditionalText());
               }
               else
               {
                  message = new GenericIconPopup(localizedText,GenericPopup.TYPE_SHARE,this.generateOnConfirmShareFeed(feedActionName,bundleData,statsKingdom,statsClass,getItem().name,postFeedCallback,postFeedCallbackAccept),dialogIconURL);
               }
               message.setTrackerKey("feed-" + feedActionName);
               UI.displayPopup(message,this.m_queueRewardFeedPopup);
            }
            FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,statsKingdom,StatsTrackingConstants.DIALOG_STATS_VIEW_PHYLUM);
            FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,this.getItem().name,"level1",statsClass,StatsTrackingConstants.DIALOG_STATS_VIEW_PHYLUM);
         }
         else if(Config.DEBUG_MODE)
         {
            if(hasLocalization)
            {
               if(rewardLink)
               {
               }
            }
         }
      }
      
      public function getFinishedItem() : FarmItem
      {
         var finishedName:String = getItem().getFinishedName();
         var returnItem:FarmItem = null;
         if(finishedName != null)
         {
            returnItem = Global.farmGameSettingsManager.getFarmItemByName(getItem().getFinishedName());
         }
         return returnItem;
      }
      
      protected function getFinishedItemFromResult(resultData:Object) : FarmItem
      {
         var finishedItem:FarmItem = null;
         if(Boolean(resultData) && resultData.hasOwnProperty("finishedName"))
         {
            finishedItem = Global.farmGameSettingsManager.getFarmItemByName(resultData.finishedName);
         }
         return finishedItem;
      }
      
      override public function onObjectDrop() : void
      {
         super.onObjectDrop();
         FeatureMessagingManager.getInstance().registerFeatureInitialized(this.buildingName,this.displayStorageDialog);
      }
      
      override public function detach() : void
      {
         FeatureMessagingManager.getInstance().unregisterFeatureInitialized(this.buildingName);
         super.detach();
      }
      
      override public function applySmartSystems(result:Object) : int
      {
         var parts:Object = null;
         var itemCode:String = null;
         var partsAdded:int = 0;
         if(result.hasOwnProperty(SMART_SYSTEM_RESULTS_KEY))
         {
            tuneHarderForSmartSystems();
            m_count = 0;
            parts = result.smartSystemResult;
            for(itemCode in parts)
            {
               m_contents[itemCode] = parts[itemCode];
               m_count += parts[itemCode];
            }
            partsAdded = m_count;
         }
         return partsAdded;
      }
      
      public function showPopUpSideCard() : Boolean
      {
         return false;
      }
      
      public function sideCardAdditionalText() : String
      {
         return "";
      }
   }
}

