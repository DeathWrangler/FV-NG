package Managers
{
   import Classes.Friend;
   import Classes.IUser;
   import Classes.ZItem.FarmItem;
   import Classes.breeding.BreedingFeatureState;
   import Classes.breeding.BreedingState;
   import Classes.breeding.BreedingTray;
   import Classes.feed.BreedingPvPFeed;
   import Classes.storage.StorageItem;
   import Display.BuySeedPackages;
   import Engine.Managers.TransactionManager;
   import Transactions.TBreedingProjectBegin;
   
   public class BreedingManager
   {
      
      public static const GREENHOUSE_FEATURE_NAME:String = "greenhousebuildable_finished";
      
      private static var m_initialized:Boolean = false;
      
      private static var m_instance:BreedingManager = null;
      
      protected const BREEDING_URL:String = "breeding.php";
      
      protected const PVP_STAT_MIN:Number = 10;
      
      private var m_startingPvPStats:Object = new Object();
      
      private var m_currentFeatureName:String = "";
      
      public function BreedingManager()
      {
         super();
         if(!m_initialized)
         {
            m_initialized = true;
            return;
         }
         throw new Error("Error: Instantiation failed: Use BreedingManager.getInstance() instead of new.");
      }
      
      public static function getInstance() : BreedingManager
      {
         if(m_instance == null)
         {
            m_instance = new BreedingManager();
         }
         return m_instance;
      }
      
      public function startNewProject(featureName:String, trayIndex:int, ingredients:Object) : void
      {
         TransactionManager.addTransaction(new TBreedingProjectBegin(featureName,trayIndex,ingredients));
      }
      
      public function addProject(featureName:String, trayIndex:int, trayInfo:Object) : void
      {
         var bs:BreedingState = Global.player.breedingState;
         var featureState:BreedingFeatureState = bs.getBreedingFeatureState(featureName);
         featureState.addNewTray(trayIndex,trayInfo);
      }
      
      public function sendHelpRequest(featureName:String, trayIndex:int) : void
      {
         Global.farmSocialNetwork.farmRedirect(this.BREEDING_URL + "?feature=" + featureName + "&trayIndex=" + trayIndex,null,"_blank");
      }
      
      public function addPurchasedHelp(featureName:String, trayIndex:int, price:int, amount:int = 1) : void
      {
         var trayState:BreedingTray = null;
         var bs:BreedingState = Global.player.breedingState;
         var totalCost:int = price * amount;
         var featureState:BreedingFeatureState = bs.getBreedingFeatureState(featureName);
         if(featureState)
         {
            trayState = featureState.getTrayState(trayIndex);
            if(Boolean(trayState) && Global.player.cash >= totalCost)
            {
               Global.player.cash -= totalCost;
               trayState.purchasedHelp += amount;
            }
         }
      }
      
      public function finishBreedingProject(featureName:String, trayIndex:int, bredItemCode:String, quantity:int) : void
      {
         var seedPackageItem:FarmItem = null;
         var seed:FarmItem = null;
         var seedsPurchased:Number = NaN;
         var storedSeed:StorageItem = null;
         var bs:BreedingState = Global.player.breedingState;
         var featureState:BreedingFeatureState = bs.getBreedingFeatureState(featureName);
         if(featureState)
         {
            seedPackageItem = Global.farmGameSettingsManager.getFarmItemByCode(bredItemCode);
            seed = BuySeedPackages.getSeedFromSeedPackageName(seedPackageItem.name);
            seedsPurchased = quantity * Global.farmGameSettingsManager.getInt("CSeedPackageSize_1",1);
            storedSeed = StorageItem.getStorageItem(seedPackageItem.code,[seedsPurchased]);
            if(Boolean(storedSeed && !storedSeed.isEmpty() && storedSeed.item) && Boolean(storedSeed.item.className) && storedSeed.item.className == "CSeedPackage")
            {
               Global.player.addSeedItem(storedSeed);
            }
            featureState.clearTray(trayIndex);
         }
      }
      
      public function getPvPStatByFeatureName(featureName:String) : Number
      {
         var pvpStatName:String = null;
         var statCount:Number = 0;
         var breedingFeatureState:BreedingFeatureState = Global.player.breedingState.getBreedingFeatureState(featureName);
         if(breedingFeatureState)
         {
            pvpStatName = breedingFeatureState.pvpStat;
            statCount = Global.player.getActionCount(pvpStatName);
         }
         return statCount;
      }
      
      public function checkNeighborPassForPvP(featureName:String) : void
      {
         var passNeighborUid:String = null;
         var neighbors:Array = null;
         var startingPvPStat:Number = NaN;
         var neighborIndex:Number = NaN;
         var neighbor:Friend = null;
         var neighborStat:Number = NaN;
         var flagName:String = null;
         var feed:BreedingPvPFeed = null;
         var currentPvPStat:Number = this.getPvPStatByFeatureName(featureName);
         if(currentPvPStat >= this.PVP_STAT_MIN)
         {
            passNeighborUid = "0";
            neighbors = Global.friendManager.neighbors.concat();
            startingPvPStat = this.getStartingPvPStatByFeatureName(featureName);
            for(neighborIndex = 0; neighborIndex < neighbors.length; neighborIndex++)
            {
               neighbor = neighbors[neighborIndex];
               neighborStat = neighbor.getBreedingStatsByFeatureName(featureName);
               if(startingPvPStat <= neighborStat && currentPvPStat > neighborStat)
               {
                  passNeighborUid = new String(neighbor.uid);
                  break;
               }
            }
            if(passNeighborUid != "0")
            {
               flagName = featureName + "_PvP";
               if(false == Global.player.getSeenSessionFlag(flagName))
               {
                  Global.player.setSeenSessionFlag(flagName);
                  feed = new BreedingPvPFeed(featureName,neighbor);
               }
            }
         }
      }
      
      public function getStartingPvPStatByFeatureName(featureName:String) : Number
      {
         var count:Number = 0;
         if(!this.m_startingPvPStats.hasOwnProperty(featureName))
         {
            this.m_startingPvPStats[featureName] = this.getPvPStatByFeatureName(featureName) - 1;
         }
         return this.m_startingPvPStats[featureName];
      }
      
      public function getPvPRankByFeatureName(featureName:String) : Number
      {
         return this.populatePvPFriendsByFeatureName(featureName).ranking;
      }
      
      public function populatePvPFriendsByFeatureName(featureName:String) : Object
      {
         var curFriend:Object = null;
         var ranking:Number = NaN;
         var result:Object = new Object();
         var friends:Array = Global.friendManager.neighbors.concat();
         this.m_currentFeatureName = featureName;
         friends.push(Global.player);
         friends.sort(this.sortFriendsByStatCount);
         for(var sortedIndex:uint = 0; sortedIndex < friends.length; sortedIndex++)
         {
            curFriend = friends[sortedIndex];
            if(curFriend.uid == Global.player.snUser.uid)
            {
               ranking = sortedIndex + 1;
               break;
            }
         }
         result.friends = friends;
         result.ranking = ranking;
         return result;
      }
      
      private function sortFriendsByStatCount(friend1:IUser, friend2:IUser) : int
      {
         var result:int = 0;
         var credits1:int = friend1.getBreedingStatsByFeatureName(this.m_currentFeatureName);
         var credits2:int = friend2.getBreedingStatsByFeatureName(this.m_currentFeatureName);
         if(credits1 > credits2)
         {
            result = -1;
         }
         else if(credits2 > credits1)
         {
            result = 1;
         }
         return result;
      }
   }
}

