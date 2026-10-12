package Classes
{
   import Classes.Constants.CollectionsConstants;
   import Classes.Constants.Experiments;
   import Classes.Constants.ToasterIconPaths;
   import Classes.ZItem.BuildingItem;
   import Classes.ZItem.FarmItem;
   import Classes.util.DisplayObjectUtils;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.Dialogs.GenericDialog;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Classes.World;
   import Engine.Helpers.Vector2;
   import Engine.Helpers.Vector3;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.CollectionsManager;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.ItemMembershipManager;
   import Managers.ToasterManager;
   import Transactions.TCancelFriendReward;
   import Widgets.Windows.AOEResourceSurfaceWindow;
   import Widgets.Windows.BuildingSurfaceWindow;
   import Widgets.Windows.Equipment.OrchardHarvesterSurfacingToaster;
   import Widgets.Windows.Orchards.PostBuildingCompleteWindow;
   import Widgets.Windows.TwoIconTitleToasterWindow;
   import com.adobe.serialization.json.JSON;
   import com.urbansquall.ginger.AnimationPlayer;
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.geom.Point;
   
   public class OrchardFeatureBuilding extends FeatureBuilding implements IOrchardBuilding
   {
      
      public static const ORCHARD_FEATUREBUILDING_ENABLED_PREREQ:String = "orchard_featurebuilding_enabled";
      
      public static const ORCHARD_STATS_COUNTER:String = "orchards_feature";
      
      public static const ORCHARD_INSTAGROW_STATS_PHYLUM:String = "orchard";
      
      private static const MYSTERY_SEED_ITEM_NAME:String = "mysteryseedling";
      
      private static const NUM_TREE_PROP_POINTS:int = 20;
      
      private static const HARVEST_ARROW_DISPLACEMENT_Y:Number = -150;
      
      private static const TREE_PROP_POINT_PREFIX:String = "treePropPoint_";
      
      private static const FOREGROUND_MASK_IMAGE_NAME:String = "alpha";
      
      private static const FEATUREFREQUENCY_ORCHARD_FOUNDCONSOLATIONGIFT_THROTTLE:String = "Orchard_FoundConsolationGift";
      
      private static const FOREGROUND_IMAGE_NAME:String = "foreground";
      
      public static const MYSTERY_SEED_FOUND_FEED_BUNDLE_ID:String = "MysterySeedlingFound";
      
      public static const CONSOLATION_GIFT_BUNDLE_ID:String = "WateringCanFound";
      
      private static const OVERLAY_URL:String = "assets/overlays/effect_orchard_sparkling.swf";
      
      private static const OVERLAY_OFFSET:Vector2 = new Vector2(-2,-15);
      
      public static const UPGRADE_PROMPT_ON_HARVEST_SEEN_FLAG_PREFIX:String = "harvest_prompt";
      
      public static const UPGRADE_PROMPT_ON_FILLED_FEATURE_FREQUENCY:String = "upgradePromptOnFilled";
      
      private var m_repromptDialog:GenericDialog;
      
      private var m_orderedItemCodes:Array = new Array();
      
      private var m_orchardTrees:Vector.<OrchardFeatureBuildingTree> = new Vector.<OrchardFeatureBuildingTree>();
      
      private var m_rewardLink:String;
      
      private var m_rewardItem:FarmItem;
      
      private var m_feedBundleId:String;
      
      private var m_rewardsArray:Array;
      
      private var m_lastCoinYield:int;
      
      public function OrchardFeatureBuilding(buildingType:String = null)
      {
         super(buildingType);
         m_instagrowStatsPhylum = ORCHARD_INSTAGROW_STATS_PHYLUM;
      }
      
      override public function loadObject(data:Object) : void
      {
         super.loadObject(data);
         if(data.itemOrder)
         {
            this.m_orderedItemCodes = data.itemOrder;
         }
         this.updateOrchardTreeContents();
      }
      
      public function getTreeGrowState() : String
      {
         var result:String = STATE_BARE;
         if(this.getState() == STATE_RIPE)
         {
            result = STATE_RIPE;
         }
         return result;
      }
      
      override public function showInInventoryWithdrawal() : Boolean
      {
         return false;
      }
      
      override public function shouldShowOverlayOnHighlight() : Boolean
      {
         return false;
      }
      
      override public function getOverlayUrl() : String
      {
         return OrchardFeatureBuilding.OVERLAY_URL;
      }
      
      override protected function getOverlayOffset() : Vector2
      {
         return OrchardFeatureBuilding.OVERLAY_OFFSET;
      }
      
      public function isExpandable() : Boolean
      {
         return this.getItem() != null && this.getItem().expansion != null && this.getItem().expansion != "";
      }
      
      override public function onStoreComplete(result:Object) : void
      {
         var dialogUrl:String = null;
         var dialogBgUrl:String = null;
         var dialog:PostBuildingCompleteWindow = null;
         super.onStoreComplete(result);
         if(result.completeRewardItem)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               dialogUrl = this.getItem().getStringFromDataSource("completeRewardDialog");
               dialogBgUrl = this.getItem().getStringFromDataSource("completeRewardDialogBackground");
            }
            else
            {
               dialogUrl = this.getItem().xml.completeRewardDialog.toString();
               dialogBgUrl = this.getItem().xml.completeRewardDialogBackground.toString();
            }
            dialog = new PostBuildingCompleteWindow(dialogUrl,Global.farmGameSettingsManager.getFarmItemByName(result.completeRewardItem),this.getItemName(),this,dialogBgUrl);
            UI.displayPopup(dialog);
            Global.player.addGift(result.completeRewardItem);
         }
      }
      
      override public function onHarvestComplete(result:Object) : void
      {
         var coinYield:int;
         var shouldDisplayFoundDialog:Boolean;
         var showedBuildingSurfaceWindow:Boolean;
         var prependedStatus:String = null;
         var seedReward:Object = null;
         var consolationReward:Object = null;
         var reward:Object = null;
         var rewardItem:FarmItem = null;
         var contextualBuildings:Array = null;
         var contextualBuildingsVar:String = null;
         var contextualListLenght:int = 0;
         var index:int = 0;
         var building:BuildingItem = null;
         super.onHarvestComplete(result);
         coinYield = 0;
         if(result.coinYield)
         {
            coinYield = int(result.coinYield);
            this.m_lastCoinYield = coinYield;
         }
         shouldDisplayFoundDialog = !result.multiAction;
         if(result.reward)
         {
            prependedStatus = this.m_harvestYieldsGroup.getStatus();
            seedReward = null;
            consolationReward = null;
            for each(reward in result.reward)
            {
               if(reward.isSeed)
               {
                  seedReward = reward;
               }
               else
               {
                  consolationReward = reward;
               }
               rewardItem = Global.farmGameSettingsManager.getFarmItemByCode(reward.itemCode);
               Global.player.addGift(rewardItem.name,"0",reward.itemCount);
            }
            if(seedReward != null)
            {
               if(seedReward.rewardLink)
               {
                  this.m_rewardLink = seedReward.rewardLink;
                  this.m_rewardItem = Global.farmGameSettingsManager.getFarmItemByCode(seedReward.itemCode);
                  this.m_feedBundleId = MYSTERY_SEED_FOUND_FEED_BUNDLE_ID;
                  if(shouldDisplayFoundDialog)
                  {
                     if(consolationReward != null)
                     {
                        this.displayFoundDialog(coinYield,consolationReward.itemCount,Global.player.inExperimentFeedCheckBoxV2() ? "OrchardFeatureBuilding_FoundMysterySeedAndConsolation_v2" : "OrchardFeatureBuilding_FoundMysterySeedAndConsolation",this.onConfirmShare,prependedStatus);
                     }
                     else
                     {
                        this.displayFoundDialog(coinYield,seedReward.itemCount,Global.player.inExperimentFeedCheckBoxV2() ? "Orchard_FoundMysterySeed_v2" : "Orchard_FoundMysterySeed",this.onConfirmShare,prependedStatus);
                     }
                  }
                  FarmStatsManager.featureSample(ORCHARD_STATS_COUNTER,"orchard_harvest_event","mystery_seeds");
               }
            }
            else if(consolationReward)
            {
               if(consolationReward.rewardLink)
               {
                  this.m_rewardLink = consolationReward.rewardLink;
                  this.m_rewardItem = Global.farmGameSettingsManager.getFarmItemByCode(consolationReward.itemCode);
                  this.m_feedBundleId = CONSOLATION_GIFT_BUNDLE_ID;
                  if(shouldDisplayFoundDialog)
                  {
                     this.displayFoundDialog(coinYield,consolationReward.itemCount,"OrchardFeatureBuilding_FoundConsolationGift",this.onConfirmShare,prependedStatus);
                  }
                  FarmStatsManager.featureSample(ORCHARD_STATS_COUNTER,"orchard_harvest_event","watering_cans");
               }
            }
         }
         else
         {
            if(shouldDisplayFoundDialog)
            {
               this.displayNoMysterySeedDialog(coinYield);
            }
            FarmStatsManager.featureSample(ORCHARD_STATS_COUNTER,"orchard_harvest_event","consolation_prize");
         }
         showedBuildingSurfaceWindow = false;
         if(BuildingSurfaceWindow.isOnContextualPlacementPromptExperiement())
         {
            contextualBuildingsVar = Global.flashHotParams["ORCHARD_CONTEXTUAL_BUILDINGS"] as String;
            try
            {
               contextualBuildings = com.adobe.serialization.json.JSON.decode(contextualBuildingsVar) as Array;
            }
            catch(error:Error)
            {
               contextualBuildings = [];
            }
            contextualListLenght = int(contextualBuildings.length);
            for(index = 0; index < contextualListLenght; index++)
            {
               building = Global.farmGameSettingsManager.getFarmItemByName(contextualBuildings[index]) as BuildingItem;
               if(building != null)
               {
                  if(BuildingSurfaceWindow.checkShouldDisplayPlacementPrompt(building))
                  {
                     UI.displayPopup(new BuildingSurfaceWindow(building,null,false,null,null,null,false,true));
                     showedBuildingSurfaceWindow = true;
                     if(result.multiAction)
                     {
                        BuildingSurfaceWindow.setPlacementPromptFeatureLastShown();
                     }
                     break;
                  }
               }
            }
         }
         if(!showedBuildingSurfaceWindow)
         {
            OrchardHarvesterSurfacingToaster.conditionallyShow();
         }
         ItemMembershipManager.conditionallyOnboard(featureName,showedBuildingSurfaceWindow);
      }
      
      override public function updateAnimation(delta:int) : void
      {
         super.updateAnimation(delta);
         if(m_overlay != null && m_overlayXML.@hasAnimation == "true" && m_overlay is AnimationPlayer && Global.playOverlayEffects)
         {
            (m_overlay as AnimationPlayer).update(delta);
         }
      }
      
      private function displayFoundDialog(coinYield:int, itemCount:int, resource:String, closeCallback:Function, prependedStatus:String = "") : void
      {
         var message:GenericIconPopup = null;
         var currentTime:int = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         Global.player.setFeatureLastShown(FEATUREFREQUENCY_ORCHARD_FOUNDCONSOLATIONGIFT_THROTTLE,currentTime,true);
         var localizedText:String = ZLocUtils.t("Dialogs",resource,{
            "coinQuantity":coinYield,
            "quantity":itemCount,
            "harvestYieldsGroup":prependedStatus
         });
         if(this.m_feedBundleId == CONSOLATION_GIFT_BUNDLE_ID && UI.shouldBlockPopupForRetention())
         {
            UI.handlePopupDisplayForRetention(localizedText,GenericPopup.TYPE_SHARE,closeCallback,this.m_rewardItem.icon,"feed-mystery_seeds_found",null);
         }
         else
         {
            if(Global.player.inExperimentFeedCheckBoxV2() && this.m_feedBundleId != CONSOLATION_GIFT_BUNDLE_ID)
            {
               message = new GenericIconPopup(localizedText,GenericPopup.TYPE_SHARECHECKBOX,closeCallback,this.m_rewardItem.icon,false,false,"",false,GenericIconPopup.GENERIC_CALLOUT_ASSET_CHECKBOX,null,false,false,ZLocUtils.t("Dialogs","MysterySeedlingFound_checkboxText"));
            }
            else
            {
               message = new GenericIconPopup(localizedText,GenericPopup.TYPE_SHARE,closeCallback,this.m_rewardItem.icon);
            }
            message.setTrackerKey("feed-mystery_seeds_found");
            UI.displayPopup(message);
         }
      }
      
      private function displayNoMysterySeedDialog(coinYield:int, prependedStatus:String = "") : void
      {
         var localizedText:String = ZLocUtils.t("Dialogs","Orchard_NoFoundMysterySeed",{
            "coinQuantity":coinYield,
            "harvestYieldsGroup":prependedStatus
         });
         var localizedTitle:String = ZLocUtils.t("Dialogs","Orchard_NoFoundMysterySeed_Title",{"coinQuantity":coinYield});
         ToasterManager.getInstance().add(new TwoIconTitleToasterWindow(localizedTitle,localizedText,ToasterIconPaths.CONSUMECOIN_ICON,this.getItem().icon as String,ToasterIconPaths.DIALOG_ASSET,0.5,0.5,new Point(15,8),null,null));
      }
      
      private function onConfirmShare(event:GenericPopupEvent) : void
      {
         var params:Object = null;
         var prependedStatus:String = null;
         var seedReward:Object = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            params = new Object();
            params.sendingUser = Global.player.firstName;
            params.rewardLink = this.m_rewardLink;
            params.images = [{
               "src":this.m_rewardItem.newsfeed,
               "href":"{SN_APP_URL}" + this.m_rewardLink
            }];
            GlobalEngine.socialNetwork.publishFeedStory(this.m_feedBundleId,params,[],false);
         }
         else
         {
            TransactionManager.addTransaction(new TCancelFriendReward([this.m_rewardLink]));
         }
         if(this.m_rewardsArray != null && this.m_rewardsArray.length > 0)
         {
            prependedStatus = this.m_harvestYieldsGroup.getStatus();
            seedReward = this.m_rewardsArray[0];
            this.m_rewardsArray.pop();
            this.m_rewardLink = seedReward.rewardLink;
            this.m_rewardItem = Global.farmGameSettingsManager.getFarmItemByCode(seedReward.itemCode);
            if(seedReward.isSeed)
            {
               this.m_feedBundleId = MYSTERY_SEED_FOUND_FEED_BUNDLE_ID;
               this.displayFoundDialog(this.m_lastCoinYield,seedReward.itemCount,Global.player.inExperimentFeedCheckBoxV2() ? "Orchard_FoundMysterySeed_v2" : "Orchard_FoundMysterySeed",this.onConfirmShare,prependedStatus);
               FarmStatsManager.featureSample(ORCHARD_STATS_COUNTER,"orchard_harvest_event","mystery_seeds");
            }
         }
      }
      
      override protected function setArrowPosition() : void
      {
         super.setArrowPosition();
         m_arrow.y += HARVEST_ARROW_DISPLACEMENT_Y;
      }
      
      override public function getHarvestTime() : Number
      {
         var growTime:Number = NaN;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            growTime = getItem().getNumberFromDataSource("growTime");
         }
         else
         {
            growTime = Number(getItem().xml.growTime);
         }
         return growTime;
      }
      
      override public function harvest(energySource:int = 0, energy:Number = 0, showNoEnergyMessage:Boolean = true, updateBackend:Boolean = true, neighborId:String = "0") : Boolean
      {
         var itemCode:String = null;
         var itemNumber:int = 0;
         var itemName:String = null;
         var i:int = 0;
         var farmObject:FarmGameObject = null;
         var position:Vector3 = this.getPosition();
         for(itemCode in m_contents)
         {
            itemNumber = int(m_contents[itemCode]);
            itemName = Global.farmGameSettingsManager.getFarmItemNameByCode(itemCode);
            for(i = 0; i < itemNumber; i++)
            {
               farmObject = new FarmGameObject();
               CollectionsManager.getInstance().executeCollectionAction(CollectionsConstants.ACTION_HARVEST_TREE,new HarvestableResource(itemName),position);
            }
         }
         if(Boolean(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_HARVEST_ARBORETUM_PROMO)) && !Global.worldManager.isVisiting())
         {
            AOEResourceSurfaceWindow.conditionallyShowPrompt(this,"ArboretumFrame","ArboretumFrame");
         }
         return super.harvest(energySource,energy,showNoEnergyMessage,updateBackend,neighborId);
      }
      
      override protected function updatePlantTimeOnStore(itemCount:int, resource:MapResource) : void
      {
         super.updatePlantTimeOnStore(itemCount,resource);
         if(this.getGrowTimeLeft() > 0)
         {
            this.setState(STATE_BARE);
         }
         else
         {
            this.setState(STATE_RIPE);
         }
      }
      
      private function updateOrchardTreeContents() : void
      {
         var treeType:Object = null;
         var treeItem:FarmItem = null;
         var currentNum:int = 0;
         var orchardTree:OrchardFeatureBuildingTree = null;
         this.m_orchardTrees = new Vector.<OrchardFeatureBuildingTree>();
         var storageContents:Array = this.getContents();
         var treeNumber:int = 0;
         for each(treeType in storageContents)
         {
            treeItem = treeType.item;
            if(treeItem != null)
            {
               for(currentNum = 0; currentNum < treeType.num; currentNum++)
               {
                  orchardTree = new OrchardFeatureBuildingTree(treeItem.name,this);
                  orchardTree.setOuter(this.getOuter() as World);
                  this.m_orchardTrees.push(orchardTree);
               }
            }
         }
         this.sortTreesByExplicitOrder();
      }
      
      private function updateOrchardTreeDisplay() : void
      {
         var propIndex:int = 0;
         var propPointName:String = null;
         var propPoint:MovieClip = null;
         var propPointOffset:int = 0;
         var orchardTree:OrchardFeatureBuildingTree = null;
         if(m_content is MovieClip)
         {
            for(propIndex = 0; propIndex < NUM_TREE_PROP_POINTS; propIndex++)
            {
               propPointName = TREE_PROP_POINT_PREFIX + propIndex;
               if(m_content.hasOwnProperty(propPointName))
               {
                  propPoint = m_content[TREE_PROP_POINT_PREFIX + propIndex];
                  if(propPoint)
                  {
                     while(propPoint.numChildren > 0)
                     {
                        propPoint.removeChildAt(0);
                     }
                     propPointOffset = Math.max(this.m_orchardTrees.length - NUM_TREE_PROP_POINTS,0);
                     if(this.m_orchardTrees.hasOwnProperty((propPointOffset + propIndex).toString()))
                     {
                        orchardTree = this.m_orchardTrees[propPointOffset + propIndex];
                        propPoint.addChild(orchardTree.treeDisplayWrapper);
                     }
                  }
               }
            }
         }
         this.conditionallyRedraw(true);
      }
      
      private function sortTreesByExplicitOrder() : void
      {
         var curOrderedTreeCode:String = null;
         var treeIndex:uint = 0;
         var tree:OrchardFeatureBuildingTree = null;
         var sortedTrees:Vector.<OrchardFeatureBuildingTree> = new Vector.<OrchardFeatureBuildingTree>();
         for(var orderIndex:uint = 0; orderIndex < this.m_orderedItemCodes.length; orderIndex++)
         {
            curOrderedTreeCode = this.m_orderedItemCodes[orderIndex] as String;
            for(treeIndex = 0; treeIndex < this.m_orchardTrees.length; treeIndex++)
            {
               tree = this.m_orchardTrees[treeIndex] as OrchardFeatureBuildingTree;
               if(tree.getItem().code == curOrderedTreeCode)
               {
                  sortedTrees.push(tree);
                  this.m_orchardTrees.splice(treeIndex,1);
                  break;
               }
            }
         }
         this.m_orchardTrees = sortedTrees.concat(this.m_orchardTrees);
      }
      
      override protected function canInstantGrow() : Boolean
      {
         return state != STATE_RIPE && count > 0 && Boolean(super.canInstantGrow());
      }
      
      override public function setOuter(outer:World) : void
      {
         var orchardTree:OrchardFeatureBuildingTree = null;
         super.setOuter(outer);
         for each(orchardTree in this.m_orchardTrees)
         {
            orchardTree.setOuter(outer);
         }
      }
      
      override public function drawDisplayObject() : void
      {
         var orchardTree:OrchardFeatureBuildingTree = null;
         super.drawDisplayObject();
         for each(orchardTree in this.m_orchardTrees)
         {
            orchardTree.drawDisplayObject();
         }
      }
      
      override protected function replaceContent(newContent:DisplayObject, shouldRedrawMask:Boolean = false) : void
      {
         super.replaceContent(newContent,shouldRedrawMask);
         if(newContent is MovieClip)
         {
            this.updateOrchardTreeDisplay();
         }
      }
      
      override protected function getForegroundDisplayObject(content:DisplayObject) : DisplayObject
      {
         var result:DisplayObject = null;
         var transparencyMask:DisplayObject = null;
         var newObject:Object = null;
         var itemImage:ItemImage = m_item.getCachedImage(FOREGROUND_IMAGE_NAME);
         if(itemImage != null)
         {
            result = itemImage.image as Bitmap;
         }
         if(result == null)
         {
            transparencyMask = null;
            if(m_image != null)
            {
               itemImage = m_item.getCachedImage(FOREGROUND_MASK_IMAGE_NAME);
               if(itemImage != null)
               {
                  transparencyMask = itemImage.image as DisplayObject;
               }
            }
            if(transparencyMask != null && !(transparencyMask is Loader))
            {
               result = DisplayObjectUtils.generateMaskedBitmap(content,transparencyMask);
               if(result is Bitmap)
               {
                  newObject = new Object();
                  newObject.name = FOREGROUND_IMAGE_NAME;
                  newObject.url = null;
                  newObject.bitmapData = (result as Bitmap).bitmapData;
                  newObject.lowResBitmapData = null;
                  newObject.loader = null;
                  newObject.loaded = true;
                  newObject.loadClass = null;
                  newObject.boxWidth = m_itemImage.boxWidth;
                  m_item.addImageToCache(newObject);
               }
            }
         }
         return result;
      }
      
      override public function removeContents(itemCode:String, itemCount:int = 1, itemParts:int = 0) : void
      {
         super.removeContents(itemCode,itemCount,itemParts);
         for(var orderIndex:uint = 0; orderIndex < this.m_orderedItemCodes.length; orderIndex++)
         {
            if(this.m_orderedItemCodes[orderIndex] == itemCode)
            {
               this.m_orderedItemCodes.splice(orderIndex,1);
            }
         }
         this.updateOrchardTreeContents();
         this.updateOrchardTreeDisplay();
      }
      
      override public function addItem(resource:MapResource, fromStorage:int = 0, isGift:Boolean = false, sendStoreItem:Boolean = true, force:Boolean = false) : Boolean
      {
         var result:Boolean = super.addItem(resource,fromStorage,isGift,sendStoreItem,force);
         this.m_orderedItemCodes.push(resource.getItem().code);
         this.updateOrchardTreeContents();
         this.updateOrchardTreeDisplay();
         this.showExpansionPromptIfFull();
         return result;
      }
      
      private function showExpansionPromptIfFull() : void
      {
         var lastShown:Number = Global.player.getFeatureLastShown(UPGRADE_PROMPT_ON_FILLED_FEATURE_FREQUENCY);
         var featureFrequency:Number = Global.farmGameSettingsManager.getNumber("orchardExpandPopupFrequency",604800);
         var currentTime:int = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
      }
      
      override public function setState(value:String) : void
      {
         var orchardTree:OrchardFeatureBuildingTree = null;
         super.setState(value);
         var treeState:String = this.getTreeGrowState();
         for each(orchardTree in this.m_orchardTrees)
         {
            orchardTree.setState(treeState);
         }
         this.updateOrchardTreeContents();
         this.updateOrchardTreeDisplay();
      }
      
      override public function updateDisplayObjectTransform() : void
      {
         var orchardTree:OrchardFeatureBuildingTree = null;
         super.updateDisplayObjectTransform();
         for each(orchardTree in this.m_orchardTrees)
         {
            orchardTree.updateDisplayObjectTransform();
         }
      }
      
      override protected function replaceContentWithBitmap(shouldRedrawMask:Boolean = false) : void
      {
         if(!(m_itemImage.image is MovieClip))
         {
            super.replaceContentWithBitmap(shouldRedrawMask);
         }
      }
      
      override public function updateCulling() : void
      {
         var orchardTree:OrchardFeatureBuildingTree = null;
         super.updateCulling();
         for each(orchardTree in this.m_orchardTrees)
         {
            orchardTree.updateCulling();
         }
      }
      
      override public function stop() : void
      {
         pause();
      }
      
      public function get orderedItemCodes() : Array
      {
         return this.m_orderedItemCodes;
      }
      
      override public function shouldCopyPartsWhenReplacing() : Boolean
      {
         return true;
      }
      
      override public function shouldCopyStorageWhenReplacing() : Boolean
      {
         return true;
      }
      
      override public function copyStorage(srcBuilding:StorageBuilding, overrideShouldCopy:Boolean = false) : Boolean
      {
         var result:Boolean = super.copyStorage(srcBuilding,overrideShouldCopy);
         if(result)
         {
            if(srcBuilding is IOrchardBuilding)
            {
               this.m_orderedItemCodes = (srcBuilding as IOrchardBuilding).orderedItemCodes.concat();
            }
         }
         return result;
      }
   }
}

