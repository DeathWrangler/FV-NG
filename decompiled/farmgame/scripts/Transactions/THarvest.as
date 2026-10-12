package Transactions
{
   import Classes.BeehiveBuilding;
   import Classes.Constants.QuestConstants;
   import Classes.Constants.ToasterIconPaths;
   import Classes.HarvestStorageBuilding;
   import Classes.HarvestableResource;
   import Classes.ItemBuff;
   import Classes.MapResource;
   import Classes.StorageBuilding;
   import Classes.ZItem.BuildingItem;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.HarvestableItem;
   import Classes.util.ZLocUtils;
   import Display.BumperCrop;
   import Display.FlowerBunchPopup;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.LootableConsumableStorageWithdrawal;
   import Display.PottingShedWithdrawal;
   import Display.SlotDialog;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.DynamicObjectEvent;
   import Events.GenericPopupEvent;
   import Managers.Crafting.CraftingManager;
   import Managers.CrossPromoManager;
   import Managers.FarmStatsManager;
   import Managers.HangingGardensManager;
   import Managers.ItemBuffManager;
   import Managers.ItemContestManager;
   import Managers.ToasterManager;
   import Widgets.Windows.IconTitleToasterWindow;
   import flash.geom.Point;
   import flash.utils.getDefinitionByName;
   
   public class THarvest extends TWorldState
   {
      
      protected var m_resource:HarvestableResource;
      
      protected var m_energySource:int = 0;
      
      protected var m_energy:Number = 0;
      
      protected var m_energyMetadata:Object = null;
      
      protected var m_buildingID:int;
      
      protected var m_storageFullPopup:GenericPopup;
      
      protected var m_foundItem:Object;
      
      protected const WAIT_TIME:int = 60000;
      
      private var m_forSelfOrShare:String = null;
      
      private var m_itemFoundName:String;
      
      private var m_itemFoundRewardUrl:String;
      
      private var m_itemFoundFeedBundle:String;
      
      protected var m_bonusXp:int = 0;
      
      protected var m_itemBuffRewardUrl:String = null;
      
      protected var m_itemBuffFeedBundle:String = null;
      
      protected var m_itemBuffFeedIcon:String = null;
      
      protected var m_itemBuffCropName:String = null;
      
      protected var m_neighborId:String = "";
      
      protected var m_extraParams:Object = null;
      
      protected var m_aoeSources:Array;
      
      public function THarvest(resource:HarvestableResource, energySource:int, energy:Number, energyMetadata:Object = null, neighborId:String = "0", extraParams:Object = null, aoeSources:Array = null)
      {
         this.m_energySource = energySource;
         this.m_resource = resource;
         this.m_energy = energy;
         this.m_energyMetadata = energyMetadata;
         this.m_neighborId = neighborId;
         this.m_extraParams = extraParams;
         this.m_aoeSources = aoeSources;
         super(resource);
      }
      
      override public function perform() : void
      {
         signedWorldAction("harvest",{
            "energySource":this.m_energySource,
            "energyCost":this.m_energy,
            "energyMetadata":this.m_energyMetadata,
            "neighborId":this.m_neighborId,
            "extraParams":this.m_extraParams,
            "aoeSources":this.m_aoeSources
         });
      }
      
      override protected function onComplete(result:Object) : void
      {
         var crossPromoManager:CrossPromoManager = null;
         var iconUrl:String = null;
         var message:String = null;
         var dialog:GenericIconPopup = null;
         var params:Array = null;
         var originalCrop:FarmItem = null;
         var itemBuff:ItemBuff = null;
         var msg:String = null;
         var msgDialog:GenericPopup = null;
         this.checkForBuildingHarvestBushels(result);
         if(Boolean(this.m_resource.getItem() as HarvestableItem) && Boolean((this.m_resource.getItem() as HarvestableItem).bushelItemCode) || result.hasOwnProperty("foundBushel"))
         {
            if(Boolean(result) && Boolean(result.bumperCropFlag))
            {
               UI.displayPopup(new BumperCrop(BumperCrop.STATUS_BUMPER_CROP,this.m_resource.getItem().name),true,"bumperCropPopup",true);
               FarmStatsManager.count("bumper_crop","flag_set","originator",this.m_resource.getItem().name);
            }
            this.checkHarvestProduce(result);
         }
         if(Boolean(HangingGardensManager.isInHangingGardensExperiment()) && Boolean(result) && result.hasOwnProperty(QuestConstants.REWARD_TROWELS))
         {
            HangingGardensManager.instance.awardTrowels(this.m_resource,result.trowels);
         }
         if(null != result["foundItem"])
         {
            this.m_foundItem = result["foundItem"];
            this.onFoundTuscanWeddingIngredient();
         }
         if(this.m_resource)
         {
            this.m_resource.onHarvestComplete(result);
         }
         if(result["completedPromoIds"] != null)
         {
            crossPromoManager = CrossPromoManager.getInstance();
            crossPromoManager.notifyCanClaimReward(result["completedPromoIds"]);
         }
         var itemFound:FarmItem = null;
         this.m_forSelfOrShare = null;
         if(null != result.itemFoundName && "" != result.itemFoundName)
         {
            this.m_itemFoundName = result.itemFoundName;
            itemFound = Global.farmGameSettingsManager.getFarmItemByName(this.m_itemFoundName);
            Global.player.addGift(this.m_itemFoundName);
            this.m_forSelfOrShare = "found_for_self";
         }
         else if(null != result.itemShareName)
         {
            this.m_itemFoundName = result.itemShareName;
            itemFound = Global.farmGameSettingsManager.getFarmItemByName(this.m_itemFoundName);
            this.m_forSelfOrShare = "found_for_share";
         }
         if(Boolean(itemFound) && Boolean(this.m_forSelfOrShare) && this.m_itemFoundName == "beehive_queen")
         {
            FarmStatsManager.count("beehive",this.m_itemFoundName,this.m_forSelfOrShare);
         }
         if(Boolean(itemFound) && Boolean(result.itemFoundDialogText))
         {
            iconUrl = Global.farmGameSettingsManager.getImageByName(this.m_itemFoundName,"icon");
            message = ZLocUtils.t("Dialogs",result.itemFoundDialogText,{"item":ZLocUtils.tk_pk(itemFound.friendlyName)});
            dialog = null;
            if(result.itemFoundRewardUrl != "" && result.itemFoundFeedBundle != "")
            {
               this.m_itemFoundRewardUrl = result.itemFoundRewardUrl;
               this.m_itemFoundFeedBundle = result.itemFoundFeedBundle;
               dialog = new GenericIconPopup(message,GenericPopup.TYPE_SHARECANCEL,this.onAcceptShareItemFeed,iconUrl);
            }
            else if(result.itemFoundName != "")
            {
               dialog = new GenericIconPopup(message,GenericPopup.TYPE_OK,null,iconUrl);
            }
            if(dialog)
            {
               Global.popupManager.addInactiveUserPopup(dialog);
            }
         }
         else if(Boolean(itemFound) && Boolean(result.itemFoundToasterText))
         {
            iconUrl = Global.farmGameSettingsManager.getImageByName(this.m_itemFoundName,"icon");
            message = ZLocUtils.t("Dialogs",result.itemFoundToasterText,{"item":ZLocUtils.tk_pk(itemFound.friendlyName)});
            ToasterManager.getInstance().add(new IconTitleToasterWindow("",message,iconUrl,ToasterIconPaths.DIALOG_ASSET,0.5,new Point(15,8)));
         }
         if(null != result.itemBuffName && null != result.itemBuffCode && null != result.itemBuffStartTime)
         {
            params = new Array();
            originalCrop = Global.farmGameSettingsManager.getFarmItemByCode(result.itemBuffCode);
            itemBuff = new ItemBuff(result.itemBuffName,originalCrop.code,int(result.itemBuffStartTime));
            this.m_itemBuffCropName = originalCrop.friendlyName;
            ItemBuffManager.getInstance().addItemBuff(itemBuff);
            if(null != result.itemBuffDialogText)
            {
               params.push(this.m_itemBuffCropName);
               if(null != result.bonusXp)
               {
                  params.push(result.bonusXp);
                  this.m_bonusXp = result.bonusXp as int;
               }
               msg = ZLocUtils.t("Dialogs",result.itemBuffDialogText,{
                  "item":ZLocUtils.tk_pk(this.m_itemBuffCropName),
                  "quantity":Global.player.calculateXp(result.bonusXp as int)
               });
               if(null != result.itemBuffRewardUrl && null != result.itemBuffFeedBundle && null != result.itemBuffFeedIcon)
               {
                  this.m_itemBuffRewardUrl = result.itemBuffRewardUrl;
                  this.m_itemBuffFeedBundle = result.itemBuffFeedBundle;
                  this.m_itemBuffFeedIcon = result.itemBuffFeedIcon;
                  msgDialog = new GenericPopup(msg,GenericPopup.TYPE_SHARECANCEL,this.onAcceptShareBuffFeed);
                  msgDialog.setTrackerKey("Feed_beehive_pollinated_seeds");
               }
               else
               {
                  msgDialog = new GenericPopup(msg,GenericPopup.TYPE_OK,this.onAcceptShareBuffFeed);
               }
               UI.displayPopup(msgDialog);
            }
         }
         BeehiveBuilding.conditionallyDisplayBeesFlyAwayPopUp(result);
         if(Boolean(result) && result.hasOwnProperty("mulchYield"))
         {
            Global.world.dispatchEvent(new DynamicObjectEvent(ItemContestManager.EVENTLISTENER_CONTEST_TYPE,{"mulches":result.mulchYield}));
         }
      }
      
      private function checkForBuildingHarvestBushels(result:Object) : void
      {
         var iBushelType:Number = NaN;
         var buildingItem:BuildingItem = this.m_resource.getItem() as BuildingItem;
         if(buildingItem != null && result.foundBushelArray != null && result.foundBushelArray.length > 0)
         {
            for(iBushelType = 0; iBushelType < result.foundBushelArray.length; iBushelType++)
            {
               this.checkHarvestProduce(result.foundBushelArray[iBushelType]);
            }
         }
      }
      
      protected function onAcceptShareBuffFeed(event:GenericPopupEvent) : void
      {
         var iconUrl:String = null;
         var params:Object = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            if(null != this.m_itemBuffFeedBundle && null != this.m_itemBuffRewardUrl)
            {
               iconUrl = Global.getAssetURL(this.m_itemBuffFeedIcon);
               params = new Object();
               params.images = [{
                  "src":iconUrl,
                  "href":"{SN_APP_URL}" + this.m_itemBuffRewardUrl
               }];
               params.reward_link = this.m_itemBuffRewardUrl;
               params.crop_name = this.m_itemBuffCropName;
               GlobalEngine.socialNetwork.publishFeedStory(this.m_itemBuffFeedBundle,params,[],false);
            }
         }
         else
         {
            TransactionManager.addTransaction(new TCancelFriendReward([this.m_itemBuffRewardUrl]));
         }
         if(this.m_bonusXp)
         {
            Global.player.xp += this.m_bonusXp;
         }
      }
      
      private function onAcceptShareItemFeed(event:GenericPopupEvent) : void
      {
         var itemFound:FarmItem = null;
         var friendName:String = null;
         var iconUrl:String = null;
         var params:Object = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            FarmStatsManager.count("beehive",this.m_itemFoundName,this.m_forSelfOrShare,"share");
            itemFound = Global.farmGameSettingsManager.getFarmItemByName(this.m_itemFoundName);
            if(itemFound)
            {
               friendName = Global.worldManager.getVisitName(true);
               iconUrl = Global.farmGameSettingsManager.getImageByName(this.m_itemFoundName,"icon");
               params = new Object();
               params.images = [{
                  "src":iconUrl,
                  "href":"{SN_APP_URL}" + this.m_itemFoundRewardUrl
               }];
               params.reward_link = this.m_itemFoundRewardUrl;
               params.friend = friendName;
               GlobalEngine.socialNetwork.publishFeedStory(this.m_itemFoundFeedBundle,params,[],false);
            }
         }
         else
         {
            FarmStatsManager.count("beehive",this.m_itemFoundName,this.m_forSelfOrShare,"cancel");
            TransactionManager.addTransaction(new TCancelFriendReward([this.m_itemFoundRewardUrl]));
         }
      }
      
      protected function checkHarvestProduce(result:Object) : void
      {
         var message:String = null;
         var building:HarvestStorageBuilding = null;
         var harvestedItem:FarmItem = null;
         var classType:Class = null;
         var mapResource:MapResource = null;
         var sessionSeenPromptFlag:String = null;
         var isStorageFull:Boolean = Boolean(result) && result.hasOwnProperty("storageFull") && result.storageFull == "true";
         var buildingName:String = result.buildingName;
         var sessionSeenFlag:String = "harvestStorageFull" + buildingName;
         if(isStorageFull && !Global.player.getSeenSessionFlag(sessionSeenFlag))
         {
            this.m_buildingID = result.buildingId;
            message = ZLocUtils.t("Dialogs","StorageFull_" + buildingName);
            this.m_storageFullPopup = new GenericPopup(message,GenericPopup.TYPE_YESNO,this.onShareHarvest);
            this.m_storageFullPopup.setAcceptTextName("ShareHarvest");
            this.m_storageFullPopup.setTrackerKey("StorageFull_" + buildingName);
            UI.displayPopup(this.m_storageFullPopup);
            FarmStatsManager.count("harvestStorage",buildingName,"storage_full");
            Global.player.setSeenSessionFlag(sessionSeenFlag);
         }
         if(Boolean(result) && Boolean(result.hasOwnProperty("producedItem")) && result.hasOwnProperty("producedSeed"))
         {
            if(result.hasOwnProperty("buildingId") && result.buildingId > 0)
            {
               building = Global.world.getObjectById(result.buildingId) as HarvestStorageBuilding;
               if(building)
               {
                  harvestedItem = Global.farmGameSettingsManager.getFarmItemByName(result.producedItem);
                  classType = getDefinitionByName("Classes." + harvestedItem.className) as Class;
                  mapResource = new classType(result.producedItem);
                  building.addItem(mapResource);
               }
            }
            else if(Boolean(result.hasOwnProperty("promptShareHarvest")) && Boolean(result.promptShareHarvest) && result.hasOwnProperty("showBuyStorageBuilding"))
            {
               sessionSeenPromptFlag = "seenBuyStorageBuildingPrompt" + buildingName;
               if(!Global.player.getSeenSessionFlag(sessionSeenPromptFlag))
               {
                  Global.popupManager.addInactiveUserPopup(new FlowerBunchPopup(buildingName,result.producedSeed,result.producedItem,this.m_resource.getId(),result.showBuyStorageBuilding));
                  Global.player.setSeenSessionFlag(sessionSeenPromptFlag);
               }
            }
         }
         CraftingManager.handleBushelFound(result);
      }
      
      private function onShareHarvest(event:GenericPopupEvent) : void
      {
         var building:StorageBuilding = null;
         var className:String = null;
         var dialog:SlotDialog = null;
         if(event.button == GenericPopup.YES)
         {
            building = Global.world.getObjectById(this.m_buildingID) as StorageBuilding;
            className = building.getItem().className;
            if("LootableConsumableStorage" == className)
            {
               dialog = new LootableConsumableStorageWithdrawal(building);
            }
            else
            {
               dialog = new PottingShedWithdrawal(building);
            }
            UI.displayStorageDialog(dialog);
         }
         this.m_storageFullPopup = null;
      }
      
      private function onFoundTuscanWeddingIngredient() : void
      {
         var item:FarmItem = null;
         var message:String = null;
         var sharePopup:GenericPopup = null;
         if(Boolean(this.m_foundItem) && null != this.m_foundItem["friendRewardLink"])
         {
            Global.player.addFeatureCredits(this.m_foundItem["itemName"],Global.farmGameSettingsManager.getInt("tuscanWeddingIngredientDailyRewardCount",5));
            item = Global.farmGameSettingsManager.getFarmItemByName(this.m_foundItem["itemName"]);
            if(null != item)
            {
               this.m_foundItem["itemname"] = item.friendlyName;
               message = ZLocUtils.t("Dialogs","TuscanWeddingRedeemFriendReward_prompt",{"item":ZLocUtils.tk_pk(this.m_foundItem["itemname"])});
               sharePopup = new GenericPopup(message,GenericPopup.TYPE_ACCEPTCANCEL,this.onShareFoundTuscanWeddingIngredientClose,GenericPopup.GENERIC_ASSET,this.m_foundItem["friendRewardLink"]);
               sharePopup.setAcceptTextName("GenericShareButton");
               sharePopup.setCancelTextName("Cancel");
               UI.displayPopup(sharePopup);
            }
         }
         else
         {
            Global.player.addFeatureCredits(this.m_foundItem["itemName"],Global.farmGameSettingsManager.getInt("tuscanWeddingIngredientRandomRewardCount",1));
         }
      }
      
      private function onShareFoundTuscanWeddingIngredientClose(evt:GenericPopupEvent) : void
      {
         var feedImage:String = null;
         var bundleData:Object = null;
         if(evt.button == GenericPopup.YES)
         {
            feedImage = Global.getAssetURL(this.m_foundItem["feedImage"]);
            bundleData = {
               "reward_link":this.m_foundItem["friendRewardLink"],
               "itemname":this.m_foundItem["itemname"],
               "images":[{
                  "href":"{SN_APP_URL}",
                  "src":feedImage
               }]
            };
            GlobalEngine.socialNetwork.publishFeedStory("TuscanWeddingIngredientFriendReward",bundleData,[],false);
            FarmStatsManager.count("Tuscan_Wedding","Feed_tuscan_wedding_find_item");
         }
      }
      
      override public function getTransactionData() : Object
      {
         var result:Object = new Object();
         result.method = TWorldState.METHOD_PERFORM_ACTION;
         result.action = "harvest";
         result.item = this.m_resource.getItem();
         result.resource = this.m_resource;
         return result;
      }
   }
}

