package Transactions
{
   import Classes.Constants.Experiments;
   import Classes.Equipment;
   import Classes.HarvestableResource;
   import Classes.Plot;
   import Classes.Terrain.TerrainUtil;
   import Engine.Helpers.Vector3;
   import Engine.Managers.ErrorManager;
   import Managers.FarmStatsManager;
   import Widgets.Windows.Toasters.AddFuelOrTurboToasterWindow;
   
   public class TEquipmentAction extends TFarmTransaction
   {
      
      public static const ACTION_HARVEST:String = "harvest";
      
      public static const ACTION_PLOW:String = "plow";
      
      public static const ACTION_PLANT:String = "place";
      
      public static const ACTION_COMBINE:String = "combine";
      
      public static const ACTION_PLOTREMOVE:String = "plotRemove";
      
      public static const METHOD_USE_EQUIPMENT:String = "onUseEquipment";
      
      private static const OWN_BATCH_LIMIT_RUNTIME_KEY:String = "EQUIPMENT_OWNBATCH_PLOT_COUNT";
      
      private static var ownBatchLimit:int = 1000;
      
      private var m_action:String = "";
      
      protected var m_equipmentBundle:Object;
      
      protected var m_plotBundle:Object;
      
      protected var m_preActionPlotItems:Object = null;
      
      private var m_itemName:String = "";
      
      private var m_equipment:Equipment = null;
      
      private var m_numPlotsSeeded:int;
      
      private var m_shouldHaveOwnBatch:Boolean = false;
      
      public function TEquipmentAction(action:String, equipment:Equipment, plots:Object, itemName:String = null, preActionPlotItems:Object = null, numPlotsSeeded:int = 0, numTurbosConsumed:int = 1)
      {
         var plot:* = undefined;
         this.m_equipmentBundle = {};
         this.m_plotBundle = {};
         super();
         if(itemName == null)
         {
            itemName = Plot.STATE_PLOWED;
         }
         this.m_action = action;
         this.m_equipment = equipment;
         var plotCount:int = 0;
         for(plot in plots)
         {
            plotCount++;
            if(Boolean(plots[plot].hasOwnProperty("position")) && plots[plot]["position"] is Vector3)
            {
               plots[plot]["position"] = (plots[plot]["position"] as Vector3).toObject();
            }
         }
         if(Global.flashHotParams.hasOwnProperty(TEquipmentAction.OWN_BATCH_LIMIT_RUNTIME_KEY))
         {
            ownBatchLimit = Global.flashHotParams[TEquipmentAction.OWN_BATCH_LIMIT_RUNTIME_KEY];
         }
         if(plotCount >= ownBatchLimit)
         {
            this.m_shouldHaveOwnBatch = true;
         }
         if(plotCount > equipment.getActionSize().x * equipment.getActionSize().y)
         {
            Global.player.turboChargers -= numTurbosConsumed;
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FUEL_TURBO_TOASTER) > 1 && Global.player.turboChargers < AddFuelOrTurboToasterWindow.THRESHHOLD)
            {
               AddFuelOrTurboToasterWindow.showToasterWindow(AddFuelOrTurboToasterWindow.TURBO);
            }
         }
         var potentialKey:String = equipment.getItem().code + ":" + equipment.equipmentPartsCount;
         var id:Number = isNaN(equipment.getId()) ? -1 : equipment.getId();
         this.m_equipmentBundle = {
            "id":id,
            "key":potentialKey
         };
         this.m_plotBundle = plots;
         this.m_itemName = itemName;
         this.m_preActionPlotItems = preActionPlotItems;
         this.m_numPlotsSeeded = numPlotsSeeded;
      }
      
      override public function perform() : void
      {
         var plot:* = undefined;
         var sampleStr:String = GlobalEngine.getFlashVar("FLASHVAR_FARM_66598_SAMPLE") as String;
         var sampleRate:int = 0;
         try
         {
            sampleRate = parseInt(sampleStr);
         }
         catch(err:Error)
         {
            ErrorManager.addError("Error parsing FLASHVAR_FARM_66598_SAMPLE");
         }
         FarmStatsManager.sample(sampleRate,"FARM-66598","EquipmentWorldService." + METHOD_USE_EQUIPMENT,this.m_action,this.m_itemName);
         for(plot in this.m_plotBundle)
         {
            if(Boolean(this.m_plotBundle[plot].hasOwnProperty("tempId")) && Boolean(this.m_plotBundle[plot]["tempId"]) && Boolean(this.m_plotBundle[plot].hasOwnProperty("itemRef")))
            {
               this.m_plotBundle[plot]["id"] = this.m_plotBundle[plot]["itemRef"].getId();
            }
            if(this.m_plotBundle[plot].hasOwnProperty("itemRef"))
            {
               if(this.m_plotBundle[plot]["itemRef"] as HarvestableResource)
               {
                  this.m_plotBundle[plot]["itemRef"] = (this.m_plotBundle[plot]["itemRef"] as HarvestableResource).getAOESourceIds();
               }
               else
               {
                  this.m_plotBundle[plot]["itemRef"] = null;
               }
            }
         }
         signedCall("EquipmentWorldService." + METHOD_USE_EQUIPMENT,this.m_action,this.m_equipmentBundle,this.m_plotBundle,this.m_itemName);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var action:TWorldState = null;
         var plotIdx:int = 0;
         var plotInfo:Object = null;
         var plot:Plot = null;
         if(Boolean(result) && result is Array)
         {
            plotIdx = 0;
            for each(plotInfo in this.m_plotBundle)
            {
               if(result[plotIdx])
               {
                  this.onAmfComplete(result[plotIdx]);
                  plot = Global.world.getObjectById(plotInfo.id) as Plot;
                  if(plot)
                  {
                     switch(this.m_action)
                     {
                        case ACTION_HARVEST:
                           action = new THarvest(plot,0,0);
                           break;
                        case ACTION_PLANT:
                           action = new TPlant(plot);
                           break;
                        case ACTION_PLOW:
                           action = new TPlow(plot,0,0);
                           break;
                        case ACTION_PLOTREMOVE:
                           action = new TClear(plot);
                     }
                     action.onMultiComplete(result[plotIdx]);
                  }
               }
               action = null;
               plotIdx++;
            }
         }
         else if(this.m_action == ACTION_COMBINE && Boolean(result))
         {
            if(result.hasOwnProperty(ACTION_HARVEST))
            {
               this.m_action = ACTION_HARVEST;
               this.onComplete(result.harvest.data as Array);
            }
            if(result.hasOwnProperty(ACTION_PLOW))
            {
               this.m_action = ACTION_PLOW;
               this.onComplete(result.plow.data as Array);
            }
            if(result.hasOwnProperty(ACTION_PLANT))
            {
               this.m_action = ACTION_PLANT;
               this.onComplete(result.place.data as Array);
            }
            if(result.hasOwnProperty(ACTION_PLOTREMOVE))
            {
               this.m_action = ACTION_PLOTREMOVE;
               this.onComplete(result.place.data as Array);
            }
         }
      }
      
      override public function getTransactionData() : Object
      {
         var key:String = null;
         var x:int = 0;
         var y:int = 0;
         var result:Object = new Object();
         result.method = METHOD_USE_EQUIPMENT;
         result.action = this.m_action;
         result.preActionPlotItems = this.m_preActionPlotItems;
         result.item = Global.farmGameSettingsManager.getFarmItemByName(this.m_itemName);
         result.numPlotsSeeded = this.m_numPlotsSeeded;
         result.equipmentItem = this.m_equipment.getItem();
         result.numPlotsPlowed = this.getNumPlotsPlowed();
         result.type = new Array();
         var codeArray:Array = new Array();
         for(key in this.m_plotBundle)
         {
            x = int(this.m_plotBundle[key].position.x);
            y = int(this.m_plotBundle[key].position.y);
            codeArray = TerrainUtil.getTerrainCodesInArea(x,y,x + Plot.SIZE_X,y + Plot.SIZE_Y);
            result.type.push(codeArray);
         }
         return result;
      }
      
      private function getNumPlotsPlowed() : int
      {
         var plotState:String = null;
         var numPlotsPlowed:int = 0;
         for(plotState in this.m_preActionPlotItems)
         {
            switch(plotState)
            {
               case Plot.STATE_FALLOW:
               case Plot.STATE_WITHERED:
                  numPlotsPlowed += this.m_preActionPlotItems[plotState].length;
                  break;
               case Plot.STATE_GROWN:
                  if(this.m_action == ACTION_COMBINE)
                  {
                     numPlotsPlowed += this.m_preActionPlotItems[plotState].length;
                  }
            }
         }
         return numPlotsPlowed;
      }
      
      override public function shouldHaveOwnBatch() : Boolean
      {
         return this.m_shouldHaveOwnBatch;
      }
   }
}

