package Managers
{
   import Classes.Airplane;
   import Classes.HarvestableResource;
   import Classes.MapResource;
   import Engine.Managers.TransactionManager;
   import Transactions.TInstantGrow;
   
   public class InstagrowHelper extends MapResourceHelper
   {
      
      private var m_discount:Number;
      
      private var m_isAutoPPH:Boolean = false;
      
      private var m_isRePop:Boolean = false;
      
      private var m_isAutoTH:Boolean = false;
      
      private var m_isAutoAH:Boolean = false;
      
      private var m_isAutoBH:Boolean = false;
      
      public function InstagrowHelper(type:uint = 15, analyzeTheWorld:Boolean = true)
      {
         super(type,analyzeTheWorld);
         this.m_discount = 0;
      }
      
      public static function playerCanSeeFeature() : Boolean
      {
         var requiredLevel:int = Global.farmGameSettingsManager.getInt("instantGrowStartingLevel",15);
         var runtimeRequiredLevel:int = int(Global.flashHotParams["INSTANT_GROW_STARTING_LEVEL"]);
         if(runtimeRequiredLevel > 0)
         {
            requiredLevel = runtimeRequiredLevel;
         }
         return Global.player.level >= requiredLevel;
      }
      
      override protected function featureEnabled() : Boolean
      {
         return InstagrowHelper.playerCanSeeFeature();
      }
      
      public function setAutoPPH(value:Boolean) : void
      {
         this.m_isAutoPPH = value;
      }
      
      public function get isAutoPPH() : Boolean
      {
         return this.m_isAutoPPH;
      }
      
      public function setRePop(value:Boolean) : void
      {
         this.m_isRePop = value;
      }
      
      public function setAutoTH(value:Boolean) : void
      {
         this.m_isAutoTH = value;
      }
      
      public function get isAutoTH() : Boolean
      {
         return this.m_isAutoTH;
      }
      
      public function setAutoAH(value:Boolean) : void
      {
         this.m_isAutoAH = value;
      }
      
      public function get isAutoAH() : Boolean
      {
         return this.m_isAutoAH;
      }
      
      public function setAutoBH(value:Boolean) : void
      {
         this.m_isAutoBH = value;
      }
      
      public function get isAutoBH() : Boolean
      {
         return this.m_isAutoBH;
      }
      
      public function get isRePop() : Boolean
      {
         return this.m_isRePop;
      }
      
      override public function calculateCost(type:uint = 15) : int
      {
         setType(type);
         var plotTimeHours:Number = 0;
         var treeTimeHours:Number = 0;
         var animalTimeHours:Number = 0;
         var bloomTimeHours:Number = 0;
         var plotCost:Number = 0;
         var treeCost:Number = 0;
         var animalCost:Number = 0;
         var bloomCost:Number = 0;
         var treeHarvestCost:Number = 1;
         var animalHarvestCost:Number = 1;
         var bloomHarvestCost:Number = 1;
         var inGameSecsPerHour:Number = Global.farmGameSettingsManager.getInt("inGameDaySeconds") / 24;
         if(isTypeActionable(TYPE_PLOTS))
         {
            plotTimeHours = totalPlotTime() / inGameSecsPerHour;
            if(plotTimeHours > 0)
            {
               plotCost = this.getPlotsPrice(plotTimeHours);
            }
         }
         if(isTypeActionable(TYPE_TREES))
         {
            treeTimeHours = this.getHarvestTimeLeft(m_trees,m_orchards) / inGameSecsPerHour;
            if(treeTimeHours > 0)
            {
               treeCost = this.getTreesPrice(treeTimeHours);
               if(this.isAutoTH)
               {
                  treeHarvestCost = this.getHarvestPrice(treeCost);
                  treeCost += treeHarvestCost;
               }
            }
         }
         if(isTypeActionable(TYPE_ANIMALS))
         {
            animalTimeHours = this.getHarvestTimeLeft(m_animals,m_animalStorageBuildings) / inGameSecsPerHour;
            if(animalTimeHours > 0)
            {
               animalCost = this.getPriceAnimal(animalTimeHours);
               if(this.isAutoAH)
               {
                  animalHarvestCost = this.getHarvestPrice(animalCost);
                  animalCost += animalHarvestCost;
               }
            }
         }
         if(isTypeActionable(TYPE_BLOOMS))
         {
            bloomTimeHours = this.getHarvestTimeLeft(m_blooms,m_gardens) / inGameSecsPerHour;
            if(bloomTimeHours > 0)
            {
               bloomCost = this.getBloomPrice(bloomTimeHours);
               if(this.isAutoBH)
               {
                  bloomHarvestCost = this.getHarvestPrice(bloomCost);
                  bloomCost += bloomHarvestCost;
               }
            }
         }
         plotCost = plotCost > 0 ? Math.max(1,Math.floor(plotCost)) : 0;
         treeCost = treeCost > 0 ? Math.max(1,Math.floor(treeCost)) : 0;
         animalCost = animalCost > 0 ? Math.max(1,Math.floor(animalCost)) : 0;
         bloomCost = bloomCost > 0 ? Math.max(1,Math.floor(bloomCost)) : 0;
         return plotCost + treeCost + animalCost + bloomCost;
      }
      
      override protected function executeOnSingleObject(object:MapResource) : void
      {
         if(object is HarvestableResource)
         {
            (object as HarvestableResource).setFullGrown();
            return;
         }
         throw new Error("InstagrowHelper.as :: executeOnSingleObject() object is not a HarvestableResource: " + object.getItemName());
      }
      
      public function sendTransaction(plots:Object = null, preActionPlotItems:Object = null, aoeSources:Object = null) : void
      {
         var airplane:Airplane = null;
         var planes:Array = Global.world.getObjectsByClass(Airplane);
         var autoHarvest:Object = this.getAutoHarvest();
         if(planes.length > 0)
         {
            airplane = planes[0];
            if(airplane)
            {
               TransactionManager.addTransaction(new TInstantGrow(airplane,getType(),this.m_isAutoPPH,plots,preActionPlotItems,totalItemsToApplyTo(),autoHarvest,aoeSources));
            }
         }
      }
      
      public function getDiscount() : Number
      {
         return this.m_discount;
      }
      
      public function applyDiscount(price:Number) : Number
      {
         var newPrice:Number = NaN;
         newPrice = price * (1 - this.m_discount);
         return Math.floor(newPrice);
      }
      
      override protected function getPlotsPrice(time:Number) : Number
      {
         var price:Number = 1 + time * 0.002;
         var minPrice:Number = 4;
         return Math.max(minPrice,price);
      }
      
      override protected function getTreesPrice(time:Number) : Number
      {
         var price:Number = time * 0.002;
         var minPrice:Number = 3;
         return Math.max(minPrice,price);
      }
      
      override protected function getPriceAnimal(time:Number) : Number
      {
         var price:Number = time * 0.0015;
         var maxPrice:Number = 18;
         var minPrice:Number = 3;
         price = Math.max(minPrice,price);
         return Math.min(maxPrice,price);
      }
      
      override protected function getBloomPrice(time:Number) : Number
      {
         var minPrice:Number = 1;
         return Math.max(minPrice,time * 0.004);
      }
      
      protected function getAutoHarvest() : Object
      {
         var res:Object = {};
         if(this.isAutoTH)
         {
            res["autoTH"] = this.isAutoTH;
         }
         if(this.isAutoAH)
         {
            res["autoAH"] = this.isAutoAH;
         }
         if(this.isAutoBH)
         {
            res["autoBH"] = this.isAutoBH;
         }
         return res;
      }
      
      protected function getHarvestPrice(price:Number) : Number
      {
         var harvestPrice:Number = 1;
         var priceDiv:Number = 3;
         var maxPrice:Number = 5;
         if(price >= priceDiv)
         {
            harvestPrice = Math.min(Math.floor(price / priceDiv),maxPrice);
         }
         return harvestPrice;
      }
   }
}

