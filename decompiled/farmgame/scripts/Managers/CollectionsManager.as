package Managers
{
   import Classes.Collections.Collectible;
   import Classes.Collections.Collection;
   import Classes.Collections.CollectionSource;
   import Classes.Collections.CollectionsRewardViewController;
   import Classes.Constants.CollectionsConstants;
   import Classes.HarvestableResource;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Engine.Helpers.Vector3;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Transactions.TCancelFriendReward;
   import Transactions.TGiftGive;
   import Widgets.Windows.Collections.CollectionsToasterWindow;
   import flash.utils.Dictionary;
   
   public class CollectionsManager
   {
      
      public static const INIT_SALT_KEY:String = "initSalt";
      
      public static const BASE_COIN_REWARD:String = "baseCoins";
      
      public static const BASE_XP_REWARD:String = "baseXP";
      
      public static const FRIEND_REWARD_TIME_LIMIT:String = "collectionFriendRewardTimeLimit";
      
      public static const FRIEND_REWARD_ACTION_KEY:String = "CollectionsManager";
      
      public static const COLLECTION_START_LEVEL:String = "collectionStartLevel";
      
      private static var m_initialized:Boolean = false;
      
      private static var m_instance:CollectionsManager = null;
      
      private static const SHARE_IDLE_TIMEOUT_SECS:Number = 3;
      
      public static const FEATURE_LIGHTNING_COUNTDOWN_TOASTER:String = "LightningCountdownToaster";
      
      private var m_isSaltInitialized:Boolean = false;
      
      private var m_salt:int;
      
      private var m_discoveredItems:Array = new Array();
      
      private var m_rarestItem:Object = null;
      
      private var m_shareDialog:GenericIconPopup = null;
      
      private var m_lastCollectibleReceivedTime:Number = 0;
      
      protected var m_collectionList:Dictionary;
      
      protected var m_configData:XMLList;
      
      protected var m_collectionsXML:XML;
      
      private var m_sources:Array;
      
      public function CollectionsManager()
      {
         super();
         if(!m_initialized)
         {
            this.m_collectionList = new Dictionary();
            this.m_sources = new Array();
            m_initialized = true;
         }
      }
      
      public static function getInstance() : CollectionsManager
      {
         if(m_instance == null)
         {
            m_instance = new CollectionsManager();
         }
         return m_instance;
      }
      
      public function setInitSalt(initSalt:Number) : void
      {
         if(!this.m_isSaltInitialized)
         {
            this.m_isSaltInitialized = true;
            this.m_salt = initSalt;
         }
      }
      
      public function setConfigXml(configXml:XML) : void
      {
         var collectionXml:XML = null;
         var sourceXml:XML = null;
         var collection:Collection = null;
         this.m_collectionsXML = configXml;
         for each(collectionXml in configXml.collection)
         {
            collection = new Collection(collectionXml);
            this.m_collectionList[collection.name] = collection;
         }
         for each(sourceXml in configXml.sources)
         {
            this.m_sources.push(new CollectionSource(sourceXml));
         }
         this.m_configData = configXml.collectionConfig;
      }
      
      public function getConfigAttribute(attributeKey:String) : Number
      {
         var result:Number = 0;
         switch(attributeKey)
         {
            case BASE_COIN_REWARD:
               result = Number(this.m_configData.@collectionBaseCoinsReward);
               break;
            case BASE_XP_REWARD:
               result = Number(this.m_configData.@collectionBaseXpReward);
               break;
            case FRIEND_REWARD_TIME_LIMIT:
               result = Number(this.m_configData.@collectionFriendRewardTimeLimit);
               break;
            case COLLECTION_START_LEVEL:
               result = Number(this.m_configData.@collectionStartLevel);
         }
         return result;
      }
      
      public function executeCollectionAction(actionName:String, actionObject:HarvestableResource, position:Vector3) : Boolean
      {
         var collectionSource:CollectionSource = null;
         var harvestableResource:HarvestableResource = null;
         var index:int = 0;
         var sourceName:String = null;
         var collection:Collection = null;
         var collectible:Collectible = null;
         var viewController:CollectionsRewardViewController = null;
         var result:Boolean = false;
         if(Global.player.level >= this.getConfigAttribute(COLLECTION_START_LEVEL))
         {
            collectionSource = null;
            harvestableResource = actionObject as HarvestableResource;
            for(index = 0; index < this.m_sources.length; index++)
            {
               if(this.m_sources[index].subtype != "" && this.m_sources[index].subtype == harvestableResource.getItem().subType)
               {
                  collectionSource = this.m_sources[index];
                  break;
               }
               for each(sourceName in (this.m_sources[index] as CollectionSource).getSourceNames())
               {
                  if(sourceName == harvestableResource.getItem().name)
                  {
                     collectionSource = this.m_sources[index];
                     break;
                  }
               }
            }
            if(collectionSource != null)
            {
               collection = this.m_collectionList[collectionSource.id];
               if(collection != null && collection.isAvailable())
               {
                  collectible = this.rollForCollectible(collection);
                  if(collectible != null)
                  {
                     FarmStatsManager.count("collections","found_collectible",actionName,collectible.item.name,"",Global.worldManager.currentWorldType);
                     if(collection.isCollectionComplete())
                     {
                        FarmStatsManager.count("collections","collection_complete",collection.name,"","",Global.worldManager.currentWorldType);
                     }
                     if(Global.player.collectionCounters[collectible.code] != null)
                     {
                        ++Global.player.collectionCounters[collectible.code];
                     }
                     else
                     {
                        Global.player.collectionCounters[collectible.code] = 1;
                     }
                     viewController = new CollectionsRewardViewController(collectible,position);
                     ToasterManager.getInstance().add(new CollectionsToasterWindow(collectible.code));
                  }
               }
            }
         }
         return result;
      }
      
      private function rollForCollectible(collection:Collection) : Collectible
      {
         var collectibles:Array = null;
         var rareCollectible:Collectible = null;
         var uncommonCollectible:Collectible = null;
         var commonCollectibles:Array = null;
         var collectible:Collectible = null;
         var result:Collectible = null;
         var weight:Number = collection.getWeight() * CollectionsConstants.ROLL_PRECISION_MULTIPLIER;
         ++this.m_salt;
         var randomNumber:Number = FarmGameUtil.getPsuedoRandomNumber(this.m_salt.toString());
         randomNumber = Math.round(randomNumber * CollectionsConstants.ROLL_PRECISION_MULTIPLIER);
         if(randomNumber < weight)
         {
            Global.player.setFeatureLastShown(Collection.COLLECTIBLE_OBTAINED + collection.name,GlobalEngine.serverTime,false);
            collectibles = collection.getCollectibles();
            rareCollectible = null;
            uncommonCollectible = null;
            commonCollectibles = new Array();
            for each(collectible in collectibles)
            {
               if(collectible.rarityString == CollectionsConstants.RARITY_RARE)
               {
                  rareCollectible = collectible;
               }
               else if(collectible.rarityString == CollectionsConstants.RARITY_UNCOMMON)
               {
                  uncommonCollectible = collectible;
               }
               else if(collectible.rarityString == CollectionsConstants.RARITY_COMMON)
               {
                  commonCollectibles.push(collectible);
               }
            }
            randomNumber = Math.round(randomNumber / weight * 100);
            if(randomNumber <= this.m_configData.@collectionRareWeight)
            {
               result = rareCollectible;
            }
            else if(randomNumber <= Number(this.m_configData.@collectionRareWeight) + Number(this.m_configData.@collectionUncommonWeight))
            {
               result = uncommonCollectible;
            }
            else
            {
               result = commonCollectibles[randomNumber % commonCollectibles.length];
            }
         }
         return result;
      }
      
      public function getAllCollectionsByType(type:String) : Array
      {
         var collectionKey:String = null;
         var currCollection:Collection = null;
         var result:Array = new Array();
         for(collectionKey in this.m_collectionList)
         {
            currCollection = this.m_collectionList[collectionKey];
            if(Boolean(currCollection) && Boolean(currCollection.type == type) && currCollection.world == Global.worldManager.currentWorldType)
            {
               result.push(currCollection);
            }
         }
         return result;
      }
      
      public function getAllCollectionXMLByType(type:String) : XMLList
      {
         var result:XMLList = null;
         result = this.m_collectionsXML.collection.(@type == type);
         return result;
      }
      
      public function getAllCollections() : Array
      {
         var id:Collection = null;
         var collection:Collection = null;
         var result:Array = [];
         for each(id in this.m_collectionList)
         {
            collection = this.m_collectionList[id.name];
            if(this.showableCollection(collection))
            {
               result.push(this.m_collectionList[id.name]);
            }
         }
         result.sortOn("name");
         return result;
      }
      
      public function showableCollection(collection:Collection) : Boolean
      {
         var result:Boolean = true;
         if(collection.type == Collection.TYPE_SLOTMACHINE || collection.type == Collection.TYPE_LE || collection.type == Collection.TYPE_BREEDING || collection.type == Collection.TYPE_FISHING)
         {
            result = false;
         }
         return result;
      }
      
      public function get canDisplaySharePopup() : Boolean
      {
         var result:Boolean = false;
         if(GlobalEngine.serverTime / 1000 >= this.m_lastCollectibleReceivedTime + SHARE_IDLE_TIMEOUT_SECS && this.m_rarestItem != null)
         {
            result = true;
         }
         return result;
      }
      
      public function getCollection(name:String) : Collection
      {
         return this.m_collectionList[name];
      }
      
      public function getCollectionByCode(code:String) : Collection
      {
         var collection:Collection = null;
         var result:Collection = null;
         var collectIndex:int = 0;
         for each(collection in this.m_collectionList)
         {
            if(collection.code == code)
            {
               result = collection;
               break;
            }
         }
         return result;
      }
      
      public function getSources() : Array
      {
         return this.m_sources;
      }
      
      public function getCollectionByCollectibleCode(code:String) : Collection
      {
         var collection:Collection = null;
         var result:Collection = null;
         for each(collection in this.m_collectionList)
         {
            if(collection.getCollectable(code) != null)
            {
               result = collection;
               break;
            }
         }
         return result;
      }
      
      public function queueCollectible(collectibleCode:String, rewardShareLink:String) : void
      {
         var collectObject:Object = null;
         var newCollection:Collection = this.getCollectionByCollectibleCode(collectibleCode);
         var newCollectible:Collectible = newCollection.getCollectable(collectibleCode);
         if(newCollectible)
         {
            collectObject = {
               "collectible":newCollectible,
               "shareLink":rewardShareLink
            };
            if(this.m_rarestItem == null || newCollectible.rarityNumber > this.m_rarestItem.collectible.rarityNumber)
            {
               this.m_rarestItem = collectObject;
            }
            this.m_discoveredItems.push(collectObject);
            this.m_lastCollectibleReceivedTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         }
      }
      
      private function cancelUnusedRewards() : void
      {
         var collectObject:Object = null;
         var shareLinkUrls:Array = new Array();
         for each(collectObject in this.m_discoveredItems)
         {
            if(Boolean(collectObject) && Boolean(collectObject.shareLink) && collectObject.shareLink != this.m_rarestItem.shareLink)
            {
               shareLinkUrls.push(collectObject.shareLink);
            }
         }
         if(shareLinkUrls.length > 0)
         {
            TransactionManager.addTransaction(new TCancelFriendReward(shareLinkUrls));
         }
      }
      
      public function displayShareCollectiblePopup() : void
      {
         var newCollectible:Collectible = null;
         var newCollection:Collection = null;
         var message:String = null;
         if(this.m_rarestItem != null && Boolean(this.m_rarestItem.collectible))
         {
            newCollectible = this.m_rarestItem.collectible;
            newCollection = this.getCollectionByCollectibleCode(newCollectible.code);
            if(Boolean(newCollection && newCollectible.item) && Boolean(!Collection.isSlotMachineCollection(newCollection)) && this.m_shareDialog == null)
            {
               message = ZLocUtils.t("Dialogs","CollectionsShareFoundCollectible",{
                  "rarityName":ZLocUtils.t_pk(newCollectible.rarityStringFriendlyName),
                  "item":ZLocUtils.tk_pk(newCollectible.item.friendlyName),
                  "collection":ZLocUtils.tk_pk(newCollection.friendlyName)
               });
               this.m_shareDialog = new GenericIconPopup(message,GenericPopup.TYPE_SHARE,this.onShare,newCollectible.item.icon);
               Global.popupManager.addInactiveUserPopup(this.m_shareDialog);
            }
         }
      }
      
      protected function onShare(event:GenericPopupEvent) : void
      {
         var newCollectible:Collectible = null;
         var newCollection:Collection = null;
         var bundleData:Object = null;
         var messageType:String = null;
         var emailData:Object = null;
         if(event.button == GenericPopup.ACCEPT && Boolean(this.m_rarestItem))
         {
            FarmStatsManager.count("feed","collections","found_rare","","",Global.worldManager.currentWorldType);
            newCollectible = this.m_rarestItem.collectible;
            newCollection = this.getCollectionByCollectibleCode(newCollectible.code);
            if(Boolean(newCollection) && Boolean(newCollectible.item))
            {
               if(newCollectible.rarityString == CollectionsConstants.RARITY_UNCOMMON || newCollectible.rarityString == CollectionsConstants.RARITY_RARE)
               {
                  bundleData = {
                     "collection":newCollection.friendlyName,
                     "rarity":newCollectible.rarityStringFriendlyName,
                     "collectable":newCollectible.item.friendlyName,
                     "reward_link":this.m_rarestItem.shareLink,
                     "images":[{
                        "href":"{SN_APP_URL}" + this.m_rarestItem.shareLink,
                        "src":newCollectible.item.icon
                     }]
                  };
                  messageType = "LightningCollectionFoundRare";
                  GlobalEngine.socialNetwork.publishFeedStory(messageType,bundleData,[],false);
                  emailData = {
                     "item_name":newCollectible.item.friendlyName,
                     "reward_link":this.m_rarestItem.shareLink
                  };
                  TransactionManager.addTransaction(new TGiftGive(messageType,emailData,[]));
                  FarmStatsManager.count("Shortfeed","feed_lightning_collection",newCollection.friendlyName,newCollectible.item.friendlyName);
               }
               else if(newCollectible.rarityString == CollectionsConstants.RARITY_COMMON)
               {
                  FarmStatsManager.count("FBDeprecation","gift","lightning_collection",newCollection.friendlyName,newCollectible.item.name);
               }
            }
         }
         else if(this.m_rarestItem.shareLink)
         {
            TransactionManager.addTransaction(new TCancelFriendReward([this.m_rarestItem.shareLink]));
         }
         this.m_shareDialog.close();
         this.m_shareDialog = null;
         this.cancelUnusedRewards();
         this.m_rarestItem = null;
         this.m_discoveredItems = new Array();
      }
   }
}

