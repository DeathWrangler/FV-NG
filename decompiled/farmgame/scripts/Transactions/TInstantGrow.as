package Transactions
{
   import Classes.Airplane;
   import Classes.Consumable;
   import Classes.Plot;
   import Classes.Terrain.TerrainUtil;
   
   public class TInstantGrow extends TWorldState
   {
      
      public static const ACTION_INSTANT_GROW:String = "instantGrow";
      
      public static const CONTEXT_INSTA_GROW:String = "instantGrow";
      
      private var m_type:uint;
      
      private var m_isAutoPPH:Boolean = false;
      
      private var m_plotBundle:Object;
      
      private var m_preActionPlotItems:Object;
      
      private var m_growCount:int = 0;
      
      private var m_action:String = "combine";
      
      private var bloomConsumable:Consumable;
      
      private var gardenConsumable:Consumable;
      
      private var animalConsumable:Consumable;
      
      private var animalStorageConsumable:Consumable;
      
      private var orchardConsumable:Consumable;
      
      private var treeConsumable:Consumable;
      
      private var m_autoHarvest:Object;
      
      private var m_aoeSources:Object;
      
      public function TInstantGrow(plane:Airplane, type:uint, isAutoPPH:Boolean, plots:Object = null, preActionPlotItems:Object = null, growCount:int = 0, autoHarvest:Object = null, aoeSources:Object = null)
      {
         super(plane);
         this.m_type = type;
         this.m_isAutoPPH = isAutoPPH;
         this.m_plotBundle = plots;
         this.m_preActionPlotItems = preActionPlotItems;
         this.m_growCount = growCount;
         this.m_autoHarvest = autoHarvest;
         this.m_autoHarvest["autoPPH"] = isAutoPPH;
         this.m_aoeSources = aoeSources;
      }
      
      override public function perform() : void
      {
         signedWorldAction(ACTION_INSTANT_GROW,{
            "type":this.m_type,
            "autoHarvest":this.m_autoHarvest,
            "aoeSources":this.m_aoeSources
         });
      }
      
      override protected function onComplete(result:Object) : void
      {
         var action:TWorldState = null;
         var plotIdx:int = 0;
         var plotInfo:Object = null;
         var plot:Plot = null;
         if(!this.m_isAutoPPH)
         {
            super.onComplete(result);
         }
         else if(Boolean(result) && result is Array)
         {
            if(this.m_isAutoPPH)
            {
               plotIdx = 0;
               for each(plotInfo in this.m_plotBundle)
               {
                  if(result[plotIdx])
                  {
                     this.onAmfComplete(result[plotIdx]);
                     plot = Global.world.getObjectById(plotInfo.id) as Plot;
                     switch(this.m_action)
                     {
                        case TEquipmentAction.ACTION_HARVEST:
                           action = new THarvest(plot,0,0);
                           break;
                        case TEquipmentAction.ACTION_PLANT:
                           action = new TPlant(plot);
                           break;
                        case TEquipmentAction.ACTION_PLOW:
                           action = new TPlow(plot,0,0);
                     }
                     action.onMultiComplete(result[plotIdx]);
                  }
                  action = null;
                  plotIdx++;
               }
            }
         }
         else if(this.m_action == TEquipmentAction.ACTION_COMBINE && Boolean(result))
         {
            if(result.hasOwnProperty(TEquipmentAction.ACTION_HARVEST))
            {
               this.m_action = TEquipmentAction.ACTION_HARVEST;
               this.onComplete(result.harvest.data as Array);
            }
            if(result.hasOwnProperty(TEquipmentAction.ACTION_PLOW))
            {
               this.m_action = TEquipmentAction.ACTION_PLOW;
               this.onComplete(result.plow.data as Array);
            }
            if(result.hasOwnProperty(TEquipmentAction.ACTION_PLANT))
            {
               this.m_action = TEquipmentAction.ACTION_PLANT;
               this.onComplete(result.place.data as Array);
            }
         }
      }
      
      override public function getTransactionData() : Object
      {
         var count:int = 0;
         var codeArray:Array = null;
         var key:String = null;
         var x:int = 0;
         var y:int = 0;
         var result:Object = new Object();
         if(!this.m_isAutoPPH)
         {
            result.method = TWorldState.METHOD_PERFORM_ACTION;
            result.action = TInstantGrow.ACTION_INSTANT_GROW;
            result.preActionPlotItems = this.m_preActionPlotItems;
            result.growCount = this.m_growCount;
         }
         else
         {
            result.method = TEquipmentAction.METHOD_USE_EQUIPMENT;
            result.action = TEquipmentAction.ACTION_COMBINE;
            result.context = CONTEXT_INSTA_GROW;
            result.preActionPlotItems = this.m_preActionPlotItems;
            result.type = new Array();
            count = 0;
            codeArray = new Array();
            for(key in this.m_plotBundle)
            {
               x = int(this.m_plotBundle[key].position.x);
               y = int(this.m_plotBundle[key].position.y);
               count++;
               codeArray = TerrainUtil.getTerrainCodesInArea(x,y,x + Plot.SIZE_X,y + Plot.SIZE_Y);
               result.type.push(codeArray);
            }
            result.numPlotsPlowed = count;
         }
         return result;
      }
   }
}

