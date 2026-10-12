package Classes
{
   import Classes.Terrain.TerrainUtil;
   import Classes.ZItem.ExpansionPlotLimits;
   import Classes.ZItem.FarmItem;
   import Engine.Events.LoaderEvent;
   import Engine.Helpers.Vector3;
   import Managers.ToolModeManager;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class ItemInstance extends FarmGameObject
   {
      
      protected var m_item:FarmItem = null;
      
      protected var m_itemName:String = "";
      
      public var tag:DisplayObject;
      
      public function ItemInstance(itemName:String)
      {
         super();
         this.m_itemName = itemName;
         if(itemName)
         {
            this.setItem(Global.farmGameSettingsManager.getFarmItemByName(itemName));
         }
      }
      
      override public function loadObject(data:Object) : void
      {
         super.loadObject(data);
         if(data.itemName)
         {
            this.setItem(Global.farmGameSettingsManager.getFarmItemByName(data.itemName));
         }
      }
      
      public function setItem(item:FarmItem) : void
      {
         if(item != this.m_item)
         {
            if(this.m_item)
            {
               this.m_item.removeEventListener(LoaderEvent.LOADED,this.onItemImageLoaded);
               this.m_item.decrementInstanceCount();
            }
            this.m_item = item;
            if(this.m_item)
            {
               this.m_item.incrementInstanceCount();
               this.m_item.addEventListener(LoaderEvent.LOADED,this.onItemImageLoaded);
               m_size = new Vector3(item.sizeX,item.sizeY);
               this.m_itemName = this.m_item.name;
               if(this.m_item.isToolGenerated)
               {
                  m_toolGenerated = true;
                  setId(ToolModeManager.assignDummyObjectId());
               }
            }
            setDisplayObjectDirty(true);
         }
      }
      
      public function getItem() : FarmItem
      {
         return this.m_item;
      }
      
      public function getItemName() : String
      {
         return this.m_itemName;
      }
      
      public function getItemType() : String
      {
         var result:String = "";
         if(this.m_item)
         {
            result = this.m_item.type;
         }
         return result;
      }
      
      public function getResourceItemName() : String
      {
         var result:String = "";
         if(this.m_item)
         {
            result = this.m_item.name;
         }
         return result;
      }
      
      public function getResourceItemCode() : String
      {
         var result:String = "";
         if(this.m_item)
         {
            result = this.m_item.code;
         }
         return result;
      }
      
      public function getItemFriendlyName() : String
      {
         var friendlyName:String = "";
         if(this.m_item)
         {
            friendlyName = this.m_item.friendlyName;
         }
         return friendlyName;
      }
      
      override public function getSaveObject() : Object
      {
         var obj:Object = super.getSaveObject();
         if(this.m_item)
         {
            if(this.m_itemName != null && this.m_itemName != "" && this.m_item.name != this.m_itemName)
            {
               obj.itemName = this.m_itemName;
            }
            else
            {
               obj.itemName = this.m_item.name;
            }
         }
         else
         {
            obj.itemName = null;
         }
         return obj;
      }
      
      protected function onItemImageLoaded(event:Event) : void
      {
         conditionallyRedraw(true);
         if(this.m_item)
         {
            this.m_item.removeEventListener(LoaderEvent.LOADED,this.onItemImageLoaded);
         }
      }
      
      override public function cleanUp() : void
      {
         if(this.m_item)
         {
            this.m_item.removeEventListener(LoaderEvent.LOADED,this.onItemImageLoaded);
            this.m_item = null;
         }
         super.cleanUp();
      }
      
      override public function isMovable() : Boolean
      {
         var result:Boolean = super.isMovable();
         if(Boolean(this.m_item) && !this.m_item.allowMove)
         {
            result = false;
         }
         return result;
      }
      
      override public function isStorable() : Boolean
      {
         var result:Boolean = super.isStorable();
         if(Boolean(this.m_item) && !this.m_item.allowStore)
         {
            result = false;
         }
         return result;
      }
      
      override public function isClearable() : Boolean
      {
         var result:Boolean = super.isClearable();
         if(Boolean(this.m_item) && !this.m_item.allowDelete)
         {
            result = false;
         }
         return result;
      }
      
      override public function isDecoMoveSupported() : Boolean
      {
         var result:Boolean = super.isDecoMoveSupported();
         if(!this.isMovable())
         {
            result = false;
         }
         return result;
      }
      
      public function getSupportedTerrainCodes() : Array
      {
         var terrains:Array = null;
         if(this.getItem() != null)
         {
            terrains = this.getItem().getTerrainCodes();
         }
         return terrains;
      }
      
      public function getLimitGroupNamesForStatHit(separator:String = "_") : String
      {
         var result:String = ExpansionPlotLimits.DEFAULT_PLOT_LIMIT_GROUP_NAME;
         var terrainCodes:Array = TerrainUtil.getTerrainCodesForItemInstance(this);
         return Global.worldManager.convertTerrainCodesToABCStringOfLimitNames(terrainCodes);
      }
      
      override public function isSellable() : Boolean
      {
         return Boolean(this.m_item) && this.m_item.sellable;
      }
      
      override public function allowDelete() : Boolean
      {
         return Boolean(this.m_item) && this.m_item.allowDelete;
      }
   }
}

