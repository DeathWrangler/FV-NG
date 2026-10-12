package Managers
{
   import Classes.Animal;
   import Classes.AnimalStorageBuilding;
   import Classes.Constants.Experiments;
   import Classes.FeatureBuilding;
   import Classes.HarvestableResource;
   import Classes.HarvestableStorageBuilding;
   import Classes.LonelyAnimal;
   import Classes.MapResource;
   import Classes.OrchardBuilding;
   import Classes.OrchardFeatureBuilding;
   import Classes.Plot;
   import Classes.StorageBuilding;
   import Classes.Tree;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Engine.Classes.WorldObject;
   
   public class MapResourceHelper
   {
      
      public static const TYPE_PLOTS:uint = 1;
      
      public static const TYPE_TREES:uint = 2;
      
      public static const TYPE_ANIMALS:uint = 4;
      
      public static const TYPE_BLOOMS:uint = 8;
      
      public static const TYPE_ALL:uint = 15;
      
      public static const TYPE_NONE:uint = 0;
      
      protected var m_plots:Array = null;
      
      protected var m_trees:Array = null;
      
      protected var m_animals:Array = null;
      
      protected var m_orchards:Array = null;
      
      protected var m_animalStorageBuildings:Array = null;
      
      protected var m_blooms:Array = null;
      
      protected var m_gardens:Array = null;
      
      private var m_type:uint = 0;
      
      public function MapResourceHelper(type:uint = 15, analyzeTheWorld:Boolean = true)
      {
         super();
         if(analyzeTheWorld)
         {
            this.analyzeWorld();
         }
         else
         {
            this.clearAllGatheredObjects();
         }
         this.setType(type);
      }
      
      public static function getCounterName(type:uint) : String
      {
         var result:String = "";
         switch(type)
         {
            case TYPE_PLOTS:
               result = "plots";
               break;
            case TYPE_TREES:
               result = "trees";
               break;
            case TYPE_ANIMALS:
               result = "animals";
               break;
            case TYPE_BLOOMS:
               result = "blooms";
         }
         return result;
      }
      
      public static function getTypeFromName(name:String) : uint
      {
         var result:uint = 0;
         switch(name.toLowerCase())
         {
            case "plots":
               result = TYPE_PLOTS;
               break;
            case "trees":
               result = TYPE_TREES;
               break;
            case "animals":
               result = TYPE_ANIMALS;
               break;
            case "blooms":
               result = TYPE_BLOOMS;
         }
         return result;
      }
      
      public function getType() : uint
      {
         return this.m_type;
      }
      
      public function setType(type:uint) : void
      {
         this.m_type = this.filterByValidTypes(type);
      }
      
      protected function getValidTypes() : uint
      {
         return MapResourceHelper.TYPE_ALL;
      }
      
      private function filterByValidTypes(type:uint) : uint
      {
         return this.getValidTypes() & type;
      }
      
      public function isTypeActionable(singleType:uint) : Boolean
      {
         return (this.getValidTypes() & singleType && this.getType() & singleType) > 0;
      }
      
      public function getAllResourcesActedUpon() : Array
      {
         var result:Array = new Array();
         if(this.isTypeActionable(TYPE_PLOTS))
         {
            if(this.m_plots.length > 0)
            {
               result = result.concat(this.m_plots);
            }
         }
         if(this.isTypeActionable(TYPE_TREES))
         {
            if(this.m_trees.length > 0)
            {
               result = result.concat(this.m_trees);
            }
            if(this.m_orchards.length > 0)
            {
               result = result.concat(this.m_orchards);
            }
         }
         if(this.isTypeActionable(TYPE_ANIMALS))
         {
            if(this.m_animals.length > 0)
            {
               result = result.concat(this.m_animals);
            }
            if(this.m_animalStorageBuildings.length > 0)
            {
               result = result.concat(this.m_animalStorageBuildings);
            }
         }
         if(this.isTypeActionable(TYPE_BLOOMS))
         {
            if(this.m_blooms.length > 0)
            {
               result = result.concat(this.m_blooms);
            }
            if(this.m_gardens.length > 0)
            {
               result = result.concat(this.m_gardens);
            }
         }
         return result;
      }
      
      public function hasResourcesToActOn() : Boolean
      {
         var result:Boolean = false;
         if(this.isTypeActionable(TYPE_PLOTS))
         {
            if(this.m_plots.length > 0)
            {
               result = true;
            }
         }
         if(this.isTypeActionable(TYPE_TREES))
         {
            if(this.m_trees.length > 0 || this.m_orchards.length > 0)
            {
               result = true;
            }
         }
         if(this.isTypeActionable(TYPE_ANIMALS))
         {
            if(this.m_animals.length > 0 || this.m_animalStorageBuildings.length > 0)
            {
               result = true;
            }
         }
         if(this.isTypeActionable(TYPE_BLOOMS))
         {
            if(this.m_blooms.length > 0 || this.m_gardens.length > 0)
            {
               result = true;
            }
         }
         return result;
      }
      
      public function calculateCost(type:uint = 15) : int
      {
         this.setType(type);
         var plotTimeHours:Number = 0;
         var treeTimeHours:Number = 0;
         var animalTimeHours:Number = 0;
         var bloomTimeHours:Number = 0;
         var plotCost:Number = 0;
         var treeCost:Number = 0;
         var animalCost:Number = 0;
         var bloomCost:Number = 0;
         var inGameSecsPerHour:Number = Global.farmGameSettingsManager.getInt("inGameDaySeconds") / 24;
         if(this.isTypeActionable(TYPE_PLOTS))
         {
            plotTimeHours = this.totalPlotTime() / inGameSecsPerHour;
            if(plotTimeHours > 0)
            {
               plotCost = this.getPlotsPrice(plotTimeHours);
            }
         }
         if(this.isTypeActionable(TYPE_TREES))
         {
            treeTimeHours = this.getHarvestTimeLeft(this.m_trees,this.m_orchards) / inGameSecsPerHour;
            if(treeTimeHours > 0)
            {
               treeCost = this.getTreesPrice(treeTimeHours);
            }
         }
         if(this.isTypeActionable(TYPE_ANIMALS))
         {
            animalTimeHours = this.getHarvestTimeLeft(this.m_animals,this.m_animalStorageBuildings) / inGameSecsPerHour;
            if(animalTimeHours > 0)
            {
               animalCost = this.getPriceAnimal(animalTimeHours);
            }
         }
         if(this.isTypeActionable(TYPE_BLOOMS))
         {
            bloomTimeHours = this.getHarvestTimeLeft(this.m_blooms,this.m_gardens) / inGameSecsPerHour;
            if(bloomTimeHours > 0)
            {
               bloomCost = this.getBloomPrice(bloomTimeHours);
            }
         }
         plotCost = plotCost > 0 ? Math.max(1,Math.floor(plotCost)) : 0;
         treeCost = treeCost > 0 ? Math.max(1,Math.floor(treeCost)) : 0;
         animalCost = animalCost > 0 ? Math.max(1,Math.floor(animalCost)) : 0;
         bloomCost = bloomCost > 0 ? Math.max(1,Math.floor(bloomCost)) : 0;
         return plotCost + treeCost + animalCost + bloomCost;
      }
      
      public function totalItemsToApplyTo() : int
      {
         var count:int = 0;
         if(this.isTypeActionable(TYPE_PLOTS))
         {
            if(this.m_plots != null)
            {
               count += this.m_plots.length;
            }
         }
         if(this.isTypeActionable(TYPE_TREES))
         {
            if(this.m_trees != null)
            {
               count += this.m_trees.length;
            }
            if(this.m_orchards != null)
            {
               count += this.m_orchards.length;
            }
         }
         if(this.isTypeActionable(TYPE_ANIMALS))
         {
            if(this.m_animals != null)
            {
               count += this.m_animals.length;
            }
            if(this.m_animalStorageBuildings != null)
            {
               count += this.m_animalStorageBuildings.length;
            }
         }
         if(this.isTypeActionable(TYPE_BLOOMS))
         {
            if(this.m_blooms != null)
            {
               count += this.m_blooms.length;
            }
            if(this.m_gardens != null)
            {
               count += this.m_gardens.length;
            }
         }
         return count;
      }
      
      public function execute() : void
      {
         if(this.isTypeActionable(TYPE_PLOTS))
         {
            this.executeOnArrayOfObjects(this.m_plots);
         }
         if(this.isTypeActionable(TYPE_TREES))
         {
            this.executeOnArrayOfObjects(this.m_trees);
            this.executeOnArrayOfObjects(this.m_orchards);
         }
         if(this.isTypeActionable(TYPE_ANIMALS))
         {
            this.executeOnArrayOfObjects(this.m_animals);
            this.executeOnArrayOfObjects(this.m_animalStorageBuildings);
         }
         if(this.isTypeActionable(TYPE_BLOOMS))
         {
            this.executeOnArrayOfObjects(this.m_blooms);
            this.executeOnArrayOfObjects(this.m_gardens);
         }
      }
      
      protected function executeOnArrayOfObjects(items:Array) : void
      {
         var item:MapResource = null;
         for each(item in items)
         {
            this.executeOnSingleObject(item);
         }
      }
      
      protected function executeOnSingleObject(object:MapResource) : void
      {
         throw new Error("MapResourceHelper.as :: executeOnSingleObject() must be overridden by child class.");
      }
      
      private function clearAllGatheredObjects() : void
      {
         this.m_plots = new Array();
         this.m_trees = new Array();
         this.m_orchards = new Array();
         this.m_animals = new Array();
         this.m_animalStorageBuildings = new Array();
         this.m_blooms = new Array();
         this.m_gardens = new Array();
      }
      
      private function analyzeWorld() : void
      {
         var worldObject:WorldObject = null;
         this.clearAllGatheredObjects();
         var worldObjects:Array = Global.world.getObjects();
         for each(worldObject in worldObjects)
         {
            this.canExecuteOnPopulateLists(worldObject);
         }
      }
      
      protected function featureEnabled() : Boolean
      {
         return true;
      }
      
      public function canExecuteOn(worldObject:WorldObject) : Boolean
      {
         return this.featureEnabled() && this.canExecuteOnPopulateLists(worldObject,false);
      }
      
      protected function cullWorldObjectAsNotActionable(worldObject:WorldObject) : Boolean
      {
         return false;
      }
      
      public function canExecuteOnPopulateLists(worldObject:WorldObject, saveResult:Boolean = true) : Boolean
      {
         var plot:Plot = null;
         var tree:Tree = null;
         var orchardBuilding:HarvestableStorageBuilding = null;
         var animal:Animal = null;
         var animalStorageBuilding:AnimalStorageBuilding = null;
         var featureBuilding:FeatureBuilding = null;
         var item:FarmItem = null;
         var result:Boolean = false;
         if(Boolean(worldObject) && !this.cullWorldObjectAsNotActionable(worldObject))
         {
            plot = worldObject as Plot;
            if(Boolean(plot) && plot.isPlanted())
            {
               if(saveResult)
               {
                  this.m_plots.push(plot);
               }
               result = true;
            }
            if(!result)
            {
               tree = worldObject as Tree;
               if(Boolean(tree) && !tree.isHarvestable())
               {
                  if(saveResult)
                  {
                     this.m_trees.push(tree);
                  }
                  result = true;
               }
            }
            if(!result)
            {
               if(worldObject is OrchardBuilding || worldObject is OrchardFeatureBuilding)
               {
                  orchardBuilding = worldObject as HarvestableStorageBuilding;
                  if(Boolean(orchardBuilding) && Boolean(!orchardBuilding.isHarvestable()) && orchardBuilding.count > 0)
                  {
                     if(saveResult)
                     {
                        this.m_orchards.push(orchardBuilding);
                     }
                     result = true;
                  }
               }
            }
            if(!result)
            {
               featureBuilding = worldObject as FeatureBuilding;
               if(featureBuilding)
               {
                  item = featureBuilding.getItem();
                  if(item.type == "bloom" && !featureBuilding.isHarvestable() && featureBuilding.isHarvestEnabled())
                  {
                     if(saveResult)
                     {
                        this.m_blooms.push(featureBuilding);
                     }
                     result = true;
                  }
                  if(!result && item.storageClass == "flower_garden" && !featureBuilding.isHarvestable() && featureBuilding.isHarvestEnabled() && featureBuilding.count > 0)
                  {
                     if(saveResult)
                     {
                        this.m_gardens.push(featureBuilding);
                     }
                     result = true;
                  }
                  if(!result && item.name == "seedlingnursery_finished" && !featureBuilding.isHarvestable() && featureBuilding.isHarvestEnabled() && featureBuilding.count > 0)
                  {
                     if(saveResult)
                     {
                        this.m_trees.push(featureBuilding);
                     }
                     result = true;
                  }
                  if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_BONSAI_GARDEN) == Experiments.VARIANT_BONSAI_GARDEN_ON)
                  {
                     if(!result && item.name == "bonsaigarden_finished" && !featureBuilding.isHarvestable() && featureBuilding.isHarvestEnabled() && featureBuilding.count > 0)
                     {
                        if(saveResult)
                        {
                           this.m_trees.push(featureBuilding);
                        }
                        result = true;
                     }
                  }
               }
            }
            if(!result)
            {
               animal = worldObject as Animal;
               if(Boolean(animal) && Boolean(!animal.isHarvestable()) && !(animal is LonelyAnimal))
               {
                  if(saveResult)
                  {
                     this.m_animals.push(animal);
                  }
                  result = true;
               }
            }
            if(!result)
            {
               animalStorageBuilding = worldObject as AnimalStorageBuilding;
               if(Boolean(animalStorageBuilding && !animalStorageBuilding.isHarvestable()) && Boolean(animalStorageBuilding.count > 0) && animalStorageBuilding.isHarvestEnabled())
               {
                  if(saveResult)
                  {
                     this.m_animalStorageBuildings.push(animalStorageBuilding);
                  }
                  result = true;
               }
            }
         }
         return result;
      }
      
      public function totalPlotTime() : Number
      {
         return this.getHarvestTimeLeft(this.m_plots);
      }
      
      public function totalTreeTime() : Number
      {
         return this.getHarvestTimeLeft(this.m_trees,this.m_orchards);
      }
      
      public function totalAnimalTime() : Number
      {
         return this.getHarvestTimeLeft(this.m_animals,this.m_animalStorageBuildings);
      }
      
      public function totalBloomTime() : Number
      {
         return this.getHarvestTimeLeft(this.m_blooms,this.m_gardens);
      }
      
      public function getTotalAnimals() : Array
      {
         return this.m_animals;
      }
      
      public function getTotalPlots() : Array
      {
         return this.m_plots;
      }
      
      public function getTotalTrees() : Array
      {
         return this.m_trees;
      }
      
      public function getTotalBlooms() : Array
      {
         return this.m_blooms;
      }
      
      protected function getHarvestTimeLeft(items:Array, buildings:Array = null) : Number
      {
         var item:HarvestableResource = null;
         var growTimeLeft:Number = NaN;
         var plot:Plot = null;
         var superPlotMultiplier:int = 0;
         var building:StorageBuilding = null;
         var itemCount:int = 0;
         var result:Number = 0;
         for each(item in items)
         {
            growTimeLeft = item.getGrowTimeLeft();
            plot = item as Plot;
            if(plot)
            {
               superPlotMultiplier = SuperPlotManager.getMultiplier(plot);
               growTimeLeft *= superPlotMultiplier;
            }
            result += growTimeLeft / FarmGameUtil.NUM_MSECS_IN_SECOND;
         }
         if(buildings)
         {
            for each(building in buildings)
            {
               itemCount = building.count;
               result += building.getGrowTimeLeft() / FarmGameUtil.NUM_MSECS_IN_SECOND * itemCount;
            }
         }
         return Math.max(result,0);
      }
      
      protected function getPlotsPrice(time:Number) : Number
      {
         if(this.isTypeActionable(TYPE_PLOTS))
         {
            throw new Error("MapResourceHelper.as :: getPlotsPrice(" + time + ") must be overridden by child class.");
         }
         return 0;
      }
      
      protected function getTreesPrice(time:Number) : Number
      {
         if(this.isTypeActionable(TYPE_TREES))
         {
            throw new Error("MapResourceHelper.as :: getTreesPrice(" + time + ") must be overridden by child class.");
         }
         return 0;
      }
      
      protected function getPriceAnimal(time:Number) : Number
      {
         if(this.isTypeActionable(TYPE_ANIMALS))
         {
            throw new Error("MapResourceHelper.as :: getPriceAnimal(" + time + ") must be overridden by child class.");
         }
         return 0;
      }
      
      protected function getBloomPrice(time:Number) : Number
      {
         if(this.isTypeActionable(TYPE_BLOOMS))
         {
            throw new Error("MapResourceHelper.as :: getBloomPrice(" + time + ") must be overridden by child class.");
         }
         return 0;
      }
   }
}

