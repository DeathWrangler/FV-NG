package Classes.FeatureCrafting
{
   import Classes.util.FarmGameUtil;
   import Engine.Managers.TransactionManager;
   import Managers.FeatureCraftingManager;
   import Transactions.FeatureCrafting.THarvestFeatureCraftingStation;
   import Transactions.TGenericTransaction;
   
   public class FeatureCraftingStation
   {
      
      public static const ASSET_STATE_IDLE:String = "idle";
      
      public static const ASSET_STATE_ACTIVE:String = "active";
      
      public static const ASSET_STATE_READY:String = "ready";
      
      private var m_system:FeatureCraftingSystem;
      
      private var m_name:String;
      
      private var m_assetUrl:String;
      
      private var m_assetScale:Number;
      
      private var m_assetX:Number;
      
      private var m_assetY:Number;
      
      private var m_exportPrefix:String;
      
      private var m_iconUrl:String;
      
      private var m_autoStart:String;
      
      private var m_active:Boolean;
      
      private var m_startTime:int;
      
      private var m_recipeName:String;
      
      private var m_unlockPointCount:int = 0;
      
      private var m_unlockLevel:int = 0;
      
      private var m_unlockCost:int;
      
      private var m_recipes:Array;
      
      private var m_upgrades:Array;
      
      private var m_outputCount:int = 1;
      
      private var m_friendlyTitle:String;
      
      private var m_completeNow:int;
      
      private var m_prereqName:String;
      
      public function FeatureCraftingStation(system:FeatureCraftingSystem, config:XML)
      {
         var recipeXml:XML = null;
         var upgradesXml:XMLList = null;
         var upgradeXml:XML = null;
         super();
         this.m_system = system;
         this.m_name = config.@name.toString();
         this.m_assetUrl = config.assetUrl.toString();
         this.m_assetScale = config.hasOwnProperty("assetScale") ? parseFloat(config.assetScale.toString()) : 1;
         this.m_assetX = config.hasOwnProperty("assetX") ? parseFloat(config.assetX.toString()) : 0;
         this.m_assetY = config.hasOwnProperty("assetY") ? parseFloat(config.assetY.toString()) : 0;
         this.m_exportPrefix = config.exportPrefix.toString();
         this.m_iconUrl = config.iconUrl.toString();
         this.m_autoStart = config.hasOwnProperty("@autoStart") ? config.@autoStart.toString() : "";
         if(config.hasOwnProperty("@unlockLevel"))
         {
            this.m_unlockLevel = parseInt(config.@unlockLevel.toString());
            this.m_unlockPointCount = this.m_system.getPointsNeededForGivenLevel(this.m_unlockLevel);
         }
         else if(config.hasOwnProperty("@unlockPointCount"))
         {
            this.m_unlockPointCount = parseInt(config.@unlockPointCount.toString());
            this.m_unlockLevel = this.m_system.getPointLevelFromPointCount(this.m_unlockPointCount);
         }
         this.m_unlockCost = config.hasOwnProperty("@unlockCost") ? int(parseInt(config.@unlockCost)) : 0;
         this.m_completeNow = config.hasOwnProperty("@completeNow") ? int(parseInt(config.@completeNow)) : 0;
         this.m_prereqName = config.@prereqName.toString();
         this.m_friendlyTitle = "";
         this.m_startTime = 0;
         this.m_recipes = [];
         var recipesXml:XMLList = config.recipes.recipe;
         for each(recipeXml in recipesXml)
         {
            this.m_recipes.push(recipeXml.@name.toString());
         }
         this.m_upgrades = [];
         upgradesXml = config.upgrades.upgrade;
         for each(upgradeXml in upgradesXml)
         {
            this.m_upgrades.push(new FeatureCraftingStationUpgrade(this,upgradeXml));
         }
      }
      
      public function get system() : FeatureCraftingSystem
      {
         return this.m_system;
      }
      
      public function get name() : String
      {
         return this.m_name;
      }
      
      public function get assetUrl() : String
      {
         return this.m_assetUrl;
      }
      
      public function get assetScale() : Number
      {
         return this.m_assetScale;
      }
      
      public function get assetX() : Number
      {
         return this.m_assetX;
      }
      
      public function get assetY() : Number
      {
         return this.m_assetY;
      }
      
      public function get exportPrefix() : String
      {
         return this.m_exportPrefix;
      }
      
      public function get iconUrl() : String
      {
         return this.m_iconUrl;
      }
      
      public function get prereqName() : String
      {
         return this.m_prereqName;
      }
      
      public function getFullExportName(exportName:String, includeOutputCount:Boolean = true) : String
      {
         var result:String = this.m_exportPrefix + exportName;
         if(includeOutputCount && this.m_outputCount > 1)
         {
            result += "x" + this.m_outputCount;
         }
         return result;
      }
      
      public function get autoStart() : String
      {
         return this.m_autoStart;
      }
      
      public function currentRecipeName() : String
      {
         return this.m_recipeName;
      }
      
      public function get startTime() : Number
      {
         return this.m_startTime;
      }
      
      public function completeNow() : Boolean
      {
         var recipe:FeatureCraftingRecipe = null;
         var inventory:FeatureCraftingInventory = null;
         var cost:int = 0;
         var hasAutoStart:Boolean = false;
         var result:Boolean = false;
         if(this.m_active && !this.canHarvest())
         {
            recipe = this.m_system.getRecipe(this.m_recipeName);
            if(recipe)
            {
               inventory = this.m_system.getInventory(recipe.finishedGood.storageName);
               if(Boolean(inventory) && inventory.canAddInventory(this.m_outputCount))
               {
                  cost = this.getCompleteNowCost();
                  if(Global.player.canBuyCash(cost))
                  {
                     Global.player.cash -= cost;
                     hasAutoStart = this.m_autoStart != "";
                     TransactionManager.addTransaction(new THarvestFeatureCraftingStation(this.m_system.name,this.m_name,this.m_recipeName,hasAutoStart,true),true);
                     this.finishHarvest(recipe);
                     result = true;
                  }
               }
               else
               {
                  inventory.displayFullMessage();
               }
            }
         }
         return result;
      }
      
      public function getCompleteNowCost() : int
      {
         var recipe:FeatureCraftingRecipe = null;
         var deltaTime:int = 0;
         var timeLeftInSeconds:int = 0;
         var timeLeftInMin:int = 0;
         var cost:int = 0;
         if(this.m_active && this.m_completeNow == 0)
         {
            recipe = this.m_system.getRecipe(this.m_recipeName);
            if(recipe)
            {
               deltaTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - this.m_startTime;
               timeLeftInSeconds = recipe.finishTime - deltaTime;
               if(timeLeftInSeconds > 0)
               {
                  timeLeftInMin = Math.ceil(timeLeftInSeconds / FarmGameUtil.NUM_SECS_IN_MINUTE);
                  cost = Math.ceil(timeLeftInMin * this.m_system.speedUpCostMultiplier());
                  cost = Math.max(cost,recipe.minFinishCost);
               }
            }
         }
         else
         {
            cost = this.m_completeNow;
         }
         return cost;
      }
      
      public function getAllRecipeNames() : Array
      {
         return this.m_recipes;
      }
      
      public function get unlocked() : Boolean
      {
         return this.m_system.points >= this.m_unlockPointCount;
      }
      
      public function get unlockLevel() : int
      {
         return this.m_unlockLevel;
      }
      
      public function get unlockNowCost() : int
      {
         var result:int = this.m_unlockCost;
         if(this.m_system.name != FeatureCraftingSystem.SYSTEM_DAIRY_CRAFTING)
         {
            result = this.m_system.getUnlockCost(this.m_unlockPointCount);
         }
         return result;
      }
      
      public function get active() : Boolean
      {
         if(!this.m_active && this.unlocked && this.m_autoStart != "")
         {
            this.m_active = true;
            this.m_recipeName = this.m_autoStart;
         }
         return this.m_active;
      }
      
      public function getEndTime() : Number
      {
         var result:Number = NaN;
         var recipe:FeatureCraftingRecipe = null;
         if(this.m_active)
         {
            recipe = this.m_system.getRecipe(this.m_recipeName);
            if(recipe)
            {
               result = this.m_startTime + recipe.finishTime;
            }
         }
         return result;
      }
      
      public function get outputCount() : int
      {
         return this.m_outputCount;
      }
      
      public function startRecipe(recipeName:String) : Boolean
      {
         var result:Boolean = false;
         var params:Array = null;
         var ingredient:FeatureCraftingRequiredGood = null;
         var recipe:FeatureCraftingRecipe = this.m_system.getRecipe(recipeName);
         if(recipe)
         {
            if(this.canStartRecipe(recipe))
            {
               params = [this.m_system.name,this.m_name,recipeName];
               TransactionManager.addTransaction(new TGenericTransaction(FeatureCraftingManager.SERVICE_NAME,"startRecipe",null,params),true);
               this.m_active = true;
               this.m_startTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
               this.m_recipeName = recipeName;
               for each(ingredient in recipe.requiredGoods())
               {
                  ingredient.good.decrementCount(ingredient.numRequired);
               }
               if(this.m_system.currentContentsWindow)
               {
                  this.m_system.currentContentsWindow.refreshInventoryCounts();
                  this.m_system.currentContentsWindow.refreshOrders(false);
               }
               result = true;
            }
         }
         return result;
      }
      
      private function canStartRecipe(recipe:FeatureCraftingRecipe) : Boolean
      {
         var ingredients:FeatureCraftingRequiredGood = null;
         var result:Boolean = false;
         if(recipe.unlocked && this.unlocked && !this.m_active && this.m_recipes.indexOf(recipe.name) != -1)
         {
            result = true;
            for each(ingredients in recipe.requiredGoods())
            {
               if(!ingredients.hasEnough)
               {
                  result = false;
                  break;
               }
            }
         }
         return result;
      }
      
      public function isReady() : Boolean
      {
         var recipe:FeatureCraftingRecipe = null;
         var deltaTime:int = 0;
         var result:Boolean = false;
         if(this.m_active)
         {
            recipe = this.m_system.getRecipe(this.m_recipeName);
            if(recipe)
            {
               deltaTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - this.m_startTime;
               if(deltaTime >= recipe.finishTime)
               {
                  result = true;
               }
            }
         }
         return result;
      }
      
      public function canHarvest() : Boolean
      {
         var recipe:FeatureCraftingRecipe = null;
         var inventory:FeatureCraftingInventory = null;
         var result:Boolean = false;
         if(this.isReady())
         {
            recipe = this.m_system.getRecipe(this.m_recipeName);
            if(recipe)
            {
               inventory = this.m_system.getInventory(recipe.finishedGood.storageName);
               result = Boolean(inventory) && inventory.canAddInventory();
            }
         }
         return result;
      }
      
      public function harvest() : Boolean
      {
         var recipe:FeatureCraftingRecipe = null;
         var inventory:FeatureCraftingInventory = null;
         var hasAutoStart:Boolean = false;
         var result:Boolean = false;
         if(this.isReady())
         {
            recipe = this.m_system.getRecipe(this.m_recipeName);
            if(recipe)
            {
               inventory = this.m_system.getInventory(recipe.finishedGood.storageName);
               if(inventory.canAddInventory(this.m_outputCount))
               {
                  hasAutoStart = this.m_autoStart != "";
                  TransactionManager.addTransaction(new THarvestFeatureCraftingStation(this.m_system.name,this.m_name,this.m_recipeName,hasAutoStart),true);
                  this.finishHarvest(recipe);
                  result = true;
               }
               else
               {
                  inventory.displayFullMessage();
               }
            }
         }
         return result;
      }
      
      private function finishHarvest(recipe:FeatureCraftingRecipe) : void
      {
         this.m_system.incrementPointCount(recipe.pointYield);
         recipe.incrementMastery();
         recipe.finishedGood.incrementCount(this.m_outputCount);
         if(this.m_autoStart != "")
         {
            this.m_startTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            this.m_recipeName = this.m_autoStart;
         }
         else
         {
            this.m_active = false;
            this.m_recipeName = "";
            this.m_startTime = 0;
         }
         if(this.m_system.currentContentsWindow)
         {
            this.m_system.currentContentsWindow.refreshInventoryCounts();
            this.m_system.currentContentsWindow.refreshOrders(false);
            this.m_system.currentContentsWindow.refreshStations();
         }
      }
      
      public function get friendlyTitle() : String
      {
         if(!this.m_friendlyTitle)
         {
            this.m_friendlyTitle = this.m_system.getLocalizedString("Station_" + this.m_name);
         }
         var outputCountSuffix:String = this.m_outputCount > 1 ? " x" + this.m_outputCount : "";
         return this.m_friendlyTitle + outputCountSuffix;
      }
      
      public function buyUnlock() : Boolean
      {
         var cost:int = 0;
         var pointsNeeded:int = 0;
         var params:Array = null;
         var result:Boolean = false;
         if(!this.unlocked && this.m_unlockPointCount > 0)
         {
            cost = this.unlockNowCost;
            if(cost > 0 && Global.player.canBuyCash(cost))
            {
               Global.player.cash -= cost;
               pointsNeeded = this.m_unlockPointCount - this.m_system.points;
               this.m_system.incrementPointCount(pointsNeeded);
               params = [this.m_system.name,this.m_name];
               TransactionManager.addTransaction(new TGenericTransaction(FeatureCraftingManager.SERVICE_NAME,"buyStationUnlock",null,params));
               result = true;
            }
         }
         return result;
      }
      
      public function setUserData(data:Object) : void
      {
         this.m_active = data["active"] as Boolean;
         this.m_startTime = data["startTime"] as int;
         this.m_recipeName = data["recipe"] as String;
         this.m_outputCount = data.hasOwnProperty("outputCount") && data["outputCount"] > 0 ? data["outputCount"] as int : 1;
      }
      
      public function get isNextStationToUnlock() : Boolean
      {
         var station:FeatureCraftingStation = null;
         var stations:Array = null;
         var result:Boolean = true;
         if(!this.unlocked)
         {
            stations = this.m_system.getStations();
            for each(station in stations)
            {
               if(!station.unlocked && station.autoStart.length > 0 == this.autoStart.length > 0 && station.name != this.name && station.m_unlockPointCount < this.m_unlockPointCount)
               {
                  result = false;
                  break;
               }
            }
         }
         return result;
      }
      
      public function canUnlock() : Boolean
      {
         return this.m_system.name != FeatureCraftingSystem.SYSTEM_HORSE_CRAFTING && this.m_system.name != FeatureCraftingSystem.SYSTEM_HOLLYBRIGHT_PARK && this.m_system.name != FeatureCraftingSystem.SYSTEM_JUNGLE_HIDEAWAY && this.m_system.name != FeatureCraftingSystem.SYSTEM_TINMAN_FOUNTAIN && this.m_system.name != FeatureCraftingSystem.SYSTEM_AZURE_EMPORIUM && this.m_system.name != FeatureCraftingSystem.SYSTEM_ARABIAN_STALLIONS && this.m_system.name != FeatureCraftingSystem.SYSTEM_MAGICGARDEN && this.m_system.name != FeatureCraftingSystem.SYSTEM_BLACKJACKBARN && this.m_system.name != FeatureCraftingSystem.SYSTEM_TOYSHOPPE && this.m_system.name != FeatureCraftingSystem.SYSTEM_FORESTFAIR && this.m_system.name != FeatureCraftingSystem.SYSTEM_ROYALSTABLE && (this.m_system.name != FeatureCraftingSystem.SYSTEM_RODEORANCH && this.m_system.name != FeatureCraftingSystem.SYSTEM_TIDEHOMESTEAD && this.m_system.name != FeatureCraftingSystem.SYSTEM_SAVANNAHRESERVE && this.m_system.name != FeatureCraftingSystem
         .SYSTEM_XTR_ELITEHORSES) && this.m_system.name != FeatureCraftingSystem.SYSTEM_XWI_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XIN_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XJP_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XJP_ELITEHORSES_MS && this.m_system.name != FeatureCraftingSystem.SYSTEM_XJM_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XMO_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XBO_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XCH_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XHH_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XTI_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XDW_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XFE_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XBR_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XHH_ELITEHORSES && this
         .m_system.name != FeatureCraftingSystem.SYSTEM_XHA_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XFW_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XUW_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XDV_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XTY_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XCB_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XRU_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XNF_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XIS_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XHX_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XWX_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XCA_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XBL_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XRT_ELITEHORSES && this.m_system.name != FeatureCraftingSystem
         .SYSTEM_XSU_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XCL_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XID_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XHF_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XWS_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XFS_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XMT_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XBB_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XDM_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XCD_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XAH_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XPU_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XYT_ELITEHORSES;
      }
      
      public function getNextUpgrade() : FeatureCraftingStationUpgrade
      {
         var upgrade:FeatureCraftingStationUpgrade = null;
         var result:FeatureCraftingStationUpgrade = null;
         if(Boolean(this.m_upgrades) && this.m_upgrades.length > 0)
         {
            for each(upgrade in this.m_upgrades)
            {
               if(upgrade.outputCount > this.m_outputCount)
               {
                  result = upgrade;
                  break;
               }
            }
         }
         return result;
      }
      
      public function buyUpgrade() : Boolean
      {
         var params:Array = null;
         var result:Boolean = false;
         var nextUpgrade:FeatureCraftingStationUpgrade = this.getNextUpgrade();
         if(Boolean(nextUpgrade) && Global.player.canBuyCash(nextUpgrade.unlockCost))
         {
            Global.player.cash -= nextUpgrade.unlockCost;
            this.m_outputCount = nextUpgrade.outputCount;
            params = [this.m_system.name,this.m_name];
            TransactionManager.addTransaction(new TGenericTransaction(FeatureCraftingManager.SERVICE_NAME,"buyStationUpgrade",null,params));
            result = true;
         }
         return result;
      }
   }
}

