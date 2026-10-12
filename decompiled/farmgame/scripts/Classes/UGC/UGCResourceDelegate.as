package Classes.UGC
{
   import Classes.CompositeMapResource;
   import Classes.MapResource;
   import Classes.VisitorManager;
   import Classes.util.ColorUtil;
   import Engine.Managers.ErrorManager;
   import Events.FarmGameWorldEvent;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.utils.Dictionary;
   
   public class UGCResourceDelegate
   {
      
      private static var s_loadQueue:Array = [];
      
      private var m_resource:IUGCMapResource;
      
      private var m_ugcItemState:UGCItemState;
      
      private var m_ugcItemDefinition:UGCItemDefinition;
      
      public function UGCResourceDelegate(ugcResource:IUGCMapResource, ugcUuid:String = null)
      {
         super();
         this.m_resource = ugcResource;
         if(this.m_resource == null)
         {
            ErrorManager.addError("null CompositeMapResource passed to UGCResourceDelegate, this will not work.");
         }
         this.m_ugcItemDefinition = Global.farmGameSettingsManager.getUGCItemDefinition((this.m_resource as MapResource).getItemName());
         if(ugcUuid == null)
         {
            ugcUuid = this.m_resource.ugcUuid;
         }
         if(ugcUuid != null)
         {
            this.loadUGCItemState(ugcUuid);
         }
      }
      
      private static function deferUGCStateLoad(uuid:String, delegate:UGCResourceDelegate) : void
      {
         if(uuid != null)
         {
            s_loadQueue.push({
               "uuid":uuid,
               "delegate":delegate
            });
            Global.world.addEventListener(FarmGameWorldEvent.USER_CHANGED,onUserChanged);
         }
      }
      
      private static function onUserChanged(event:Event) : void
      {
         var data:Object = null;
         for each(data in s_loadQueue)
         {
            (data.delegate as UGCResourceDelegate).loadUGCItemState(data.uuid as String);
         }
         Global.world.removeEventListener(FarmGameWorldEvent.USER_CHANGED,onUserChanged);
         s_loadQueue = [];
      }
      
      public function setInitialUuid(uuid:String) : void
      {
         if(Boolean(this.ugcItemState) && !this.ugcItemState.hasUUID())
         {
            this.ugcItemState.insertInitialUuid(uuid);
            Global.player.ugcItemData.addUGCItemState(this.ugcItemState);
         }
      }
      
      public function loadUGCItemState(uuid:String) : void
      {
         var itemName:String = null;
         var ugcItemDef:UGCItemDefinition = null;
         var state:UGCItemState = null;
         var layerDef:UGCItemLayerDefinition = null;
         var itemCode:String = null;
         if(uuid != null)
         {
            if(Global.worldManager.isVisitingNeighbor())
            {
               this.ugcItemState = VisitorManager.getInstance().ugcItemData.getStateByUUID(uuid);
            }
            else if(Global.player.isDataLoaded)
            {
               if(uuid != "")
               {
                  this.ugcItemState = Global.player.ugcItemData.getStateByUUID(uuid);
               }
               else
               {
                  itemName = (this.m_resource as MapResource).getItemName();
                  ugcItemDef = Global.farmGameSettingsManager.getUGCItemDefinition(itemName);
                  if(ugcItemDef == null)
                  {
                     throw new Error("Unable to find ugcItem definition for item named: " + itemName);
                  }
                  state = UGCItemState.createFromDefinition(ugcItemDef);
                  if(this.m_resource.getItem().keyword == UGCConstants.FISH_KEYWORD)
                  {
                     for each(layerDef in ugcItemDef.layers)
                     {
                        if(layerDef.name != "body" && layerDef.itemNames.length >= 1)
                        {
                           itemCode = Global.farmGameSettingsManager.getFarmItemCodeByName(layerDef.itemNames[0]);
                           state.addLayerState(layerDef,new UGCItemLayerState(itemCode));
                        }
                     }
                  }
                  this.ugcItemState = state;
               }
            }
            else
            {
               deferUGCStateLoad(uuid,this);
            }
         }
      }
      
      public function getInventoryCode(baseCode:String) : String
      {
         return baseCode + ":" + this.ugcItemState.uuid;
      }
      
      public function createStateFromCode(storageCode:String) : void
      {
         var uuid:String = storageCode.substring(storageCode.indexOf(":"),storageCode.length);
         this.loadUGCItemState(uuid);
      }
      
      public function get ugcItemState() : UGCItemState
      {
         return this.m_ugcItemState;
      }
      
      public function set ugcItemState(value:UGCItemState) : void
      {
         var oldValue:UGCItemState = null;
         if(this.m_ugcItemState != value)
         {
            oldValue = this.m_ugcItemState;
            this.m_ugcItemState = value;
            if(this.m_ugcItemState != null || this.m_ugcItemState == null && oldValue != null)
            {
               this.refresh();
            }
         }
      }
      
      public function refresh() : void
      {
         var lookup:Dictionary = null;
         var existingLayer:UGCItemLayer = null;
         var layer:UGCItemLayer = null;
         var layerState:UGCItemLayerState = null;
         var layerDefinition:UGCItemLayerDefinition = null;
         var baseLayer:UGCItemLayerDefinition = null;
         var baseLayerAdded:Boolean = false;
         var layerItemName:String = null;
         var layerKey:String = null;
         var unusedLayer:UGCItemLayer = null;
         var image:UGCItemLayerImageDefinition = null;
         var baseItemCode:String = null;
         var baseState:UGCItemLayerState = null;
         var baseImage:UGCItemLayerImageDefinition = null;
         if(this.m_ugcItemState != null && this.m_ugcItemDefinition != null)
         {
            lookup = new Dictionary();
            for each(existingLayer in this.m_resource.layers)
            {
               lookup[existingLayer.ugcImageDef] = existingLayer;
            }
            baseLayer = this.m_ugcItemDefinition.base;
            baseLayerAdded = false;
            layerItemName = null;
            for(layerKey in this.m_ugcItemState.layers)
            {
               layerState = this.m_ugcItemState.getLayerStateByKey(layerKey);
               layerDefinition = this.m_ugcItemDefinition.getLayerByKey(layerKey);
               if(layerDefinition != null)
               {
                  if(layerDefinition.layerKey == baseLayer.layerKey)
                  {
                     baseLayerAdded = true;
                  }
                  for each(image in layerDefinition.images)
                  {
                     layer = lookup[image] as UGCItemLayer;
                     layerItemName = null;
                     if(layer != null && layer.ugcItemState != null && layer.ugcItemState.item != null)
                     {
                        layerItemName = layer.ugcItemState.item.name;
                     }
                     if(layer == null || layerState != null && layerState.item != null && layerItemName != layerState.item.name)
                     {
                        this.m_resource.addLayer(new UGCItemLayer(image,layerState));
                     }
                     else
                     {
                        layer.ugcItemState = layerState;
                        delete lookup[image];
                     }
                  }
               }
               else
               {
                  GlobalEngine.error("UGC","State layerKey=" + layerKey + " is not defined for item=" + this.m_ugcItemDefinition.itemName);
               }
            }
            if(!baseLayerAdded)
            {
               baseItemCode = Global.farmGameSettingsManager.getFarmItemCodeByName(this.m_ugcItemDefinition.itemName);
               baseState = new UGCItemLayerState(baseItemCode);
               for each(baseImage in baseLayer.images)
               {
                  layer = lookup[baseImage] as UGCItemLayer;
                  layerItemName = null;
                  if(layer != null && layer.ugcItemState != null && layer.ugcItemState.item != null)
                  {
                     layerItemName = layer.ugcItemState.item.name;
                  }
                  if(layer == null || baseState != null && baseState.item != null && layerItemName != baseState.item.name)
                  {
                     this.m_resource.addLayer(new UGCItemLayer(baseImage,baseState));
                  }
                  else
                  {
                     layer.ugcItemState = baseState;
                     delete lookup[baseImage];
                  }
               }
            }
            for each(unusedLayer in lookup)
            {
               this.m_resource.removeLayer(unusedLayer,false);
            }
         }
         this.m_resource.drawDisplayObject();
      }
      
      public function getCurrentImageName() : String
      {
         return this.m_ugcItemDefinition.base.name;
      }
      
      public function initializeFilters(content:DisplayObject) : void
      {
         if(content != null)
         {
            content.filters = this.getBaseFilters();
         }
         (this.m_resource as CompositeMapResource).toggleAnimation();
      }
      
      public function getBaseFilters() : Array
      {
         var baseState:UGCItemLayerState = null;
         var result:Array = [];
         if(this.m_ugcItemState != null)
         {
            baseState = this.m_ugcItemState.getLayerStateByDefinition(this.m_ugcItemDefinition.base);
            if(baseState != null && this.m_ugcItemDefinition.base.isColorable && baseState.isCustomColor)
            {
               result.push(ColorUtil.getColorMatrixFilter(baseState.color,UGCConstants.COLOR_ALPHA));
            }
         }
         return result;
      }
      
      public function get totalCash() : int
      {
         var layerState:UGCItemLayerState = null;
         var cash:int = 0;
         if(this.m_ugcItemState)
         {
            for each(layerState in this.m_ugcItemState.layers)
            {
               if(layerState.isCustomItem)
               {
                  cash += layerState.item.cash;
               }
            }
         }
         return cash;
      }
   }
}

