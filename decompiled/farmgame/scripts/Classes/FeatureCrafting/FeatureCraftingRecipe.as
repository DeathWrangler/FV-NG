package Classes.FeatureCrafting
{
   import Display.GenericPopup;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FeatureCraftingManager;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.FeatureCrafting.FeatureCraftingMasteryWindow;
   import Widgets.Windows.FeatureCrafting.FeatureCraftingStorageWindow;
   
   public class FeatureCraftingRecipe
   {
      
      private var m_system:FeatureCraftingSystem;
      
      private var m_name:String;
      
      private var m_unlockPointCount:int = 0;
      
      private var m_unlockLevel:int = 0;
      
      private var m_unlockCost:int;
      
      private var m_finishTime:int;
      
      private var m_finishNowMin:int;
      
      private var m_masteryCount:int;
      
      private var m_requiredGoods:Array;
      
      private var m_pointYield:int;
      
      private var m_friendlyTitle:String;
      
      private var m_finishedGood:FeatureCraftingGood;
      
      private var m_masteryConfig:XMLList;
      
      private var m_station:FeatureCraftingStation;
      
      public function FeatureCraftingRecipe(system:FeatureCraftingSystem, config:XML)
      {
         var goodsXml:XMLList = null;
         var goodXml:XML = null;
         super();
         this.m_system = system;
         this.m_name = config.@name.toString();
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
         this.m_finishTime = parseInt(config.@finishTime);
         this.m_finishNowMin = config.hasOwnProperty("@finishNowMin") ? int(parseInt(config.@finishNowMin.toString())) : 1;
         this.m_pointYield = config.hasOwnProperty("@pointsYield") ? int(parseInt(config.@pointsYield.toString())) : 0;
         this.m_masteryConfig = config.hasOwnProperty("mastery") ? config.mastery.level : null;
         this.m_friendlyTitle = "";
         this.m_requiredGoods = [];
         if(config.goods)
         {
            goodsXml = config.goods.good;
            for each(goodXml in goodsXml)
            {
               this.m_requiredGoods.push(new FeatureCraftingIngredient(this.m_system,goodXml));
            }
         }
         this.m_finishedGood = this.m_system.getGoodByName(this.m_name);
      }
      
      public function get system() : FeatureCraftingSystem
      {
         return this.m_system;
      }
      
      public function get name() : String
      {
         return this.m_name;
      }
      
      public function get unlocked() : Boolean
      {
         return this.m_system.points >= this.m_unlockPointCount;
      }
      
      public function get unlockPointCount() : int
      {
         return this.m_unlockPointCount;
      }
      
      public function get unlockLevel() : int
      {
         return this.m_unlockLevel;
      }
      
      public function get unlockCost() : int
      {
         var result:int = this.m_unlockCost;
         if(this.m_system.name != FeatureCraftingSystem.SYSTEM_DAIRY_CRAFTING && this.m_system.name != FeatureCraftingSystem.SYSTEM_HORSE_CRAFTING && this.m_system.name != FeatureCraftingSystem.SYSTEM_HOLLYBRIGHT_PARK && this.m_system.name != FeatureCraftingSystem.SYSTEM_JUNGLE_HIDEAWAY && this.m_system.name != FeatureCraftingSystem.SYSTEM_TINMAN_FOUNTAIN && this.m_system.name != FeatureCraftingSystem.SYSTEM_AZURE_EMPORIUM && this.m_system.name != FeatureCraftingSystem.SYSTEM_ARABIAN_STALLIONS && this.m_system.name != FeatureCraftingSystem.SYSTEM_MAGICGARDEN && this.m_system.name != FeatureCraftingSystem.SYSTEM_BLACKJACKBARN && this.m_system.name != FeatureCraftingSystem.SYSTEM_TOYSHOPPE && this.m_system.name != FeatureCraftingSystem.SYSTEM_FORESTFAIR && this.m_system.name != FeatureCraftingSystem.SYSTEM_ROYALSTABLE && this.m_system.name != FeatureCraftingSystem.SYSTEM_RODEORANCH && this.m_system.name != FeatureCraftingSystem.SYSTEM_TIDEHOMESTEAD && this.m_system.name != FeatureCraftingSystem.SYSTEM_SAVANNAHRESERVE && this
         .m_system.name != FeatureCraftingSystem.SYSTEM_XTR_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XWI_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XIN_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XJP_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XJP_ELITEHORSES_MS && this.m_system.name != FeatureCraftingSystem.SYSTEM_XJM_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XMO_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XBO_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XCH_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XHH_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XTI_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XDW_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XFE_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XHA_ELITEHORSES && this.m_system.name != FeatureCraftingSystem
         .SYSTEM_XFW_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XBR_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XUW_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XTY_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XDV_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XCB_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XRU_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XNF_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XIS_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XHX_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XWX_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XCA_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XRT_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XSU_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XCL_ELITEHORSES && this
         .m_system.name != FeatureCraftingSystem.SYSTEM_XID_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XHF_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XWS_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XFS_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XMT_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XBB_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XDM_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XCD_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XAH_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XPU_ELITEHORSES && this.m_system.name != FeatureCraftingSystem.SYSTEM_XYT_ELITEHORSES)
         {
            result = this.m_system.getUnlockCost(this.m_unlockPointCount);
         }
         return result;
      }
      
      public function get finishTime() : int
      {
         return this.m_finishTime;
      }
      
      public function requiredGoods() : Array
      {
         return this.m_requiredGoods;
      }
      
      public function get pointYield() : int
      {
         return this.m_pointYield;
      }
      
      public function get minFinishCost() : int
      {
         return this.m_finishNowMin;
      }
      
      public function get iconUrl() : String
      {
         return this.m_finishedGood.iconUrl();
      }
      
      public function get friendlyTitle() : String
      {
         if(!this.m_friendlyTitle)
         {
            this.m_friendlyTitle = this.m_system.getLocalizedString("Recipe_" + this.m_name);
         }
         return this.m_friendlyTitle;
      }
      
      public function get finishedGood() : FeatureCraftingGood
      {
         return this.m_finishedGood;
      }
      
      public function get masteryHarvests() : int
      {
         return this.m_masteryCount;
      }
      
      public function incrementMastery() : void
      {
         var masteryLevel:XML = null;
         var starCount:int = this.masteryStarCount;
         this.m_masteryCount += 1;
         var newStarCount:int = this.masteryStarCount;
         if(starCount < newStarCount)
         {
            if(this.m_masteryConfig != null)
            {
               masteryLevel = this.m_masteryConfig[newStarCount - 1];
               if(masteryLevel.hasOwnProperty("@xp"))
               {
                  Global.player.xp += parseInt(masteryLevel.@xp);
               }
               if(masteryLevel.hasOwnProperty("@coins"))
               {
                  Global.player.gold += parseInt(masteryLevel.@coins);
               }
               if(masteryLevel.hasOwnProperty("@gift"))
               {
                  Global.player.addGift(masteryLevel.@gift.toString());
               }
               FeatureCraftingMasteryWindow.display(this,newStarCount);
            }
         }
      }
      
      public function get masteryStarCount() : int
      {
         var cumulativeHarvests:int = 0;
         var masteryLevel:XML = null;
         var result:int = 0;
         if(this.m_masteryCount > 0 && Boolean(this.m_masteryConfig))
         {
            cumulativeHarvests = 0;
            for each(masteryLevel in this.m_masteryConfig)
            {
               cumulativeHarvests += parseInt(masteryLevel.@harvests);
               if(this.m_masteryCount < cumulativeHarvests)
               {
                  break;
               }
               result++;
            }
         }
         return result;
      }
      
      public function getMasteryHarvestsForGivenLevel(level:int) : int
      {
         var index:int = 0;
         var result:int = 0;
         if(this.m_masteryConfig != null)
         {
            if(level > 0 && level <= this.m_masteryConfig.length())
            {
               for(index = 0; index < level; index++)
               {
                  result += parseInt(this.m_masteryConfig[index].@harvests);
               }
            }
         }
         return result;
      }
      
      public function get hasAllRequiredGoods() : Boolean
      {
         var ingredient:FeatureCraftingIngredient = null;
         var result:Boolean = true;
         for each(ingredient in this.m_requiredGoods)
         {
            if(!ingredient.hasEnough)
            {
               result = false;
               break;
            }
         }
         return result;
      }
      
      public function recipeBuyAllGoodsCost() : int
      {
         var requiredGood:FeatureCraftingIngredient = null;
         var result:int = 0;
         for each(requiredGood in this.m_requiredGoods)
         {
            if(!requiredGood.hasEnough)
            {
               result += requiredGood.good.costToBuy(requiredGood.numRequired - requiredGood.good.inventoryCount);
            }
         }
         return result;
      }
      
      public function buyAllGoods() : Boolean
      {
         var requiredGood:FeatureCraftingIngredient = null;
         var fullInventory:FeatureCraftingInventory = null;
         var inventoryName:String = null;
         var needed:int = 0;
         var inventory:FeatureCraftingInventory = null;
         var result:Boolean = false;
         var cost:int = this.recipeBuyAllGoodsCost();
         var inventoryCounts:Object = {};
         for each(requiredGood in this.m_requiredGoods)
         {
            if(!requiredGood.hasEnough)
            {
               needed = requiredGood.numRequired - requiredGood.good.inventoryCount;
               if(inventoryCounts.hasOwnProperty(requiredGood.good.storageName))
               {
                  inventoryCounts[requiredGood.good.storageName] += needed;
               }
               else
               {
                  inventoryCounts[requiredGood.good.storageName] = needed;
               }
            }
         }
         for(inventoryName in inventoryCounts)
         {
            inventory = this.m_system.getInventory(inventoryName);
            if(!inventory.canAddInventory(inventoryCounts[inventoryName]))
            {
               fullInventory = inventory;
               break;
            }
         }
         if(!fullInventory)
         {
            if(Global.player.canBuyCash(cost))
            {
               result = true;
               Global.player.cash -= cost;
               for each(requiredGood in this.m_requiredGoods)
               {
                  if(!requiredGood.hasEnough)
                  {
                     requiredGood.good.incrementCount(requiredGood.numRequired - requiredGood.good.inventoryCount);
                  }
               }
               TransactionManager.addTransaction(new TGenericTransaction(FeatureCraftingManager.SERVICE_NAME,"buyAllGoods",null,[this.m_system.name,this.m_name]));
            }
         }
         else
         {
            fullInventory.displayFullMessage();
         }
         return result;
      }
      
      private function generatorOnInventoryFullMessageClose(inventoryName:String) : Function
      {
         return function(event:GenericPopupEvent):void
         {
            var inventory:* = undefined;
            if(event.button == GenericPopup.ACCEPT)
            {
               inventory = m_system.getInventory(inventoryName);
               FeatureCraftingStorageWindow.display(inventory,true);
            }
         };
      }
      
      public function buyUnlock() : Boolean
      {
         var cost:int = 0;
         var pointsNeeded:int = 0;
         var params:Array = null;
         var result:Boolean = false;
         if(!this.unlocked && this.m_unlockPointCount > 0)
         {
            cost = this.unlockCost;
            if(cost > 0 && Global.player.canBuyCash(cost))
            {
               Global.player.cash -= cost;
               pointsNeeded = this.m_unlockPointCount - this.m_system.points;
               this.m_system.incrementPointCount(pointsNeeded);
               params = [this.m_system.name,this.m_name];
               TransactionManager.addTransaction(new TGenericTransaction(FeatureCraftingManager.SERVICE_NAME,"buyRecipeUnlock",null,params));
               result = true;
            }
         }
         return result;
      }
      
      public function setUserData(data:Object) : void
      {
         this.m_masteryCount = data as int;
      }
      
      public function adminSetMasteryHarvests(harvestCount:int) : void
      {
         this.m_masteryCount = harvestCount;
      }
      
      public function get isNextRecipeToUnlock() : Boolean
      {
         var recipes:Array = null;
         var recipe:FeatureCraftingRecipe = null;
         var station:FeatureCraftingStation = null;
         var result:Boolean = true;
         if(!this.unlocked)
         {
            recipes = this.m_system.getRecipes();
            for each(recipe in recipes)
            {
               if(!recipe.unlocked && recipe.name != this.m_name && recipe.unlockPointCount < this.m_unlockPointCount)
               {
                  station = this.m_system.getStationThatMakesRecipe(recipe.name);
                  if(!station.autoStart)
                  {
                     result = false;
                     break;
                  }
               }
            }
         }
         return result;
      }
      
      public function get station() : FeatureCraftingStation
      {
         return this.m_station;
      }
      
      public function set station(station:FeatureCraftingStation) : void
      {
         this.m_station = station;
      }
   }
}

