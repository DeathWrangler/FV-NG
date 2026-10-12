package GameMode
{
   import Classes.Constants.ClickTrackingConstants;
   import Classes.EmbeddedArt;
   import Classes.FarmGameObject;
   import Classes.ItemInstance;
   import Classes.MapResource;
   import Classes.Terrain.TerrainUtil;
   import Classes.WorldObjectTypes;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.DeleteConfirm;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Classes.WorldObject;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.ClickTrackingManager;
   import Managers.FarmStatsManager;
   import Transactions.TClear;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import gs.TweenLite;
   
   public class GMClear extends GMDefault
   {
      
      private static const DELAY_AMOUNT:Number = 0.3;
      
      private var m_highlightedPoint:Point;
      
      private var m_object:WorldObject;
      
      private var m_persistentDeleting:Boolean = false;
      
      private var m_deleteConfirm:DeleteConfirm;
      
      private var m_categoryType:String;
      
      private var m_objectToSellOrDelete:WorldObject;
      
      private var m_deleteLE:Boolean = false;
      
      private var m_isDelay:Boolean = false;
      
      public function GMClear()
      {
         super();
         m_cursorImage = EmbeddedArt.cursor_clear;
      }
      
      override protected function getSelectableTypes() : int
      {
         return WorldObjectTypes.BUILDING | WorldObjectTypes.PLOT | WorldObjectTypes.TREE | WorldObjectTypes.ANIMAL | WorldObjectTypes.DECORATION;
      }
      
      override public function onMouseMove(event:MouseEvent) : Boolean
      {
         super.onMouseMove(event);
         if(m_highlightedObject != null)
         {
            if(m_dragging)
            {
               this.deselectObject();
            }
         }
         return true;
      }
      
      override protected function handleClick(event:MouseEvent) : void
      {
         var object:FarmGameObject = null;
         var isQuickDelete:Boolean = false;
         var obj:ItemInstance = null;
         var farmItem:FarmItem = null;
         var allowDelete:Boolean = false;
         var itemType:String = null;
         var terrainLimitGroupName:String = null;
         var objXML:XML = null;
         var hasStorageType:String = null;
         ClickTrackingManager.getInstance().countClick(ClickTrackingConstants.CLICK_TYPE_DELETE_ITEM);
         var mapObject:MapResource = null;
         var isItemSellable:Boolean = false;
         if(m_highlightedObject)
         {
            this.m_objectToSellOrDelete = m_highlightedObject;
            object = m_highlightedObject as FarmGameObject;
            mapObject = m_highlightedObject as MapResource;
         }
         var isWorldEmpty:Boolean = false;
         if(Global.world.getNumObjects() <= 2)
         {
            isWorldEmpty = true;
         }
         if(Boolean(object) && !isWorldEmpty)
         {
            if(object.isClearable() && !this.m_isDelay)
            {
               this.m_isDelay = true;
               if(this.m_deleteConfirm)
               {
                  this.m_persistentDeleting = this.m_deleteConfirm.getPersistentDeletingFlag();
               }
               isQuickDelete = Global.quickDeleteOn;
               obj = object as ItemInstance;
               farmItem = null;
               allowDelete = true;
               if(obj.getItem() == null && m_highlightedObject.getClassName() == "Plot")
               {
                  itemType = "plot";
               }
               else
               {
                  itemType = obj.getItem().type;
                  if(Global.flashHotParams["USE_INSTANCE_BASED_DELETE"])
                  {
                     isItemSellable = obj.isSellable();
                  }
                  else
                  {
                     isItemSellable = obj.getItem().sellable;
                  }
                  farmItem = Global.farmGameSettingsManager.getFarmItemByCode(obj.getItem().code);
                  allowDelete = obj.allowDelete();
               }
               terrainLimitGroupName = "";
               if(obj)
               {
                  terrainLimitGroupName = obj.getLimitGroupNamesForStatHit();
               }
               if(allowDelete)
               {
                  switch(itemType)
                  {
                     case "plot":
                        this.deletePlots(isQuickDelete,object,itemType,obj);
                        break;
                     case "seed":
                        this.deletePlots(isQuickDelete,object,itemType,obj);
                        break;
                     case "animal":
                        if(Global.player.level > 7)
                        {
                           this.deleteObject(obj,isQuickDelete,object,isItemSellable,itemType);
                        }
                        break;
                     case "decoration":
                        this.deleteObject(obj,isQuickDelete,object,isItemSellable,itemType);
                        break;
                     case "vehicle":
                        this.deleteObject(obj,isQuickDelete,object,isItemSellable,itemType);
                        break;
                     case "tree":
                        this.deleteObject(obj,isQuickDelete,object,isItemSellable,itemType);
                        break;
                     case "building":
                     case "bloom":
                        hasStorageType = farmItem.getPropertyFromItemCashSaleSource("storageType");
                        if(farmItem.isLimitedItem())
                        {
                           obj.sell();
                        }
                        else if(hasStorageType != "" || !this.m_persistentDeleting && !isQuickDelete || this.m_persistentDeleting && this.m_categoryType != m_highlightedObject.getTypeName())
                        {
                           this.showDeleteConfirmationDialog(object);
                        }
                        else if(this.m_persistentDeleting && this.m_categoryType == m_highlightedObject.getTypeName() || isQuickDelete)
                        {
                           if(isItemSellable)
                           {
                              FarmStatsManager.count("deletetool","item_sold","",itemType,terrainLimitGroupName);
                              obj.sell();
                           }
                           else
                           {
                              FarmStatsManager.count("deletetool","item_deleted","",itemType,terrainLimitGroupName);
                              this.setObjectToDelete();
                           }
                        }
                  }
               }
               if(isQuickDelete || this.m_persistentDeleting || Boolean(farmItem) && Boolean(farmItem.isLimitedItem()))
               {
                  this.deselectObject();
               }
            }
         }
         TweenLite.to(obj,DELAY_AMOUNT,{"onComplete":this.removeDelay});
         if(Boolean(isWorldEmpty) && Boolean(m_highlightedObject) && Boolean(mapObject))
         {
            mapObject.handleZeroWorldPopup();
         }
      }
      
      public function deletePlots(isQuickDelete:Boolean, object:FarmGameObject, itemType:String, itemInst:ItemInstance = null) : void
      {
         var terrainLimitGroupName:String = null;
         var terrainCodes:Array = null;
         var terrainCodesByLimitIndex:Array = null;
         var limitGroupIndex:String = null;
         if(this.m_persistentDeleting && this.m_categoryType == m_highlightedObject.getTypeName() || isQuickDelete)
         {
            terrainLimitGroupName = "";
            if(itemInst)
            {
               terrainLimitGroupName = itemInst.getLimitGroupNamesForStatHit();
            }
            this.m_object = object;
            FarmStatsManager.count("deletetool","item_deleted","",itemType,terrainLimitGroupName);
            this.m_object.detach();
            if(this.m_object is MapResource)
            {
               (this.m_object as MapResource).onDelete();
            }
            if(this.m_object.getClassName() == "Plot")
            {
               terrainCodes = TerrainUtil.getTerrainCodesForItemInstance(this.m_object as ItemInstance);
               terrainCodesByLimitIndex = Global.worldManager.convertTerrainCodesToCodesByLimitIndex(terrainCodes);
               for(limitGroupIndex in terrainCodesByLimitIndex)
               {
                  Global.world.decrementPlotCount(terrainCodesByLimitIndex[limitGroupIndex]);
               }
            }
            this.setObjectToDelete();
         }
         else
         {
            this.showDeleteConfirmationDialog(object);
         }
      }
      
      private function deleteObject(obj:ItemInstance, isQuickDelete:Boolean, object:FarmGameObject, isItemSellable:Boolean, itemType:String) : void
      {
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(obj.getItem().code);
         var terrainLimitGroupName:String = "";
         if(obj)
         {
            terrainLimitGroupName = obj.getLimitGroupNamesForStatHit();
         }
         if(obj.getItem().isLimitedItem())
         {
            obj.sell();
         }
         else if(!this.m_persistentDeleting && !isQuickDelete || this.m_persistentDeleting && this.m_categoryType != m_highlightedObject.getTypeName())
         {
            this.showDeleteConfirmationDialog(object);
         }
         else if(this.m_persistentDeleting && this.m_categoryType == m_highlightedObject.getTypeName() || isQuickDelete)
         {
            if(isItemSellable)
            {
               FarmStatsManager.count("deletetool","item_sold","",itemType,terrainLimitGroupName);
               obj.sell();
            }
            else
            {
               FarmStatsManager.count("deletetool","item_deleted","",itemType,terrainLimitGroupName);
               this.setObjectToDelete();
            }
         }
      }
      
      private function removeDelay() : void
      {
         this.m_isDelay = false;
      }
      
      private function showDeleteConfirmationDialog(object:FarmGameObject) : void
      {
         this.m_categoryType = m_highlightedObject.getTypeName();
         var map:MapResource = object as MapResource;
         var objType:String = map.getItemFriendlyName();
         var catFriendlyName:String = "Items:" + this.m_categoryType + "Category_friendlyName";
         var objFriendlyName:String = objType;
         if(objType == "")
         {
            objType = "Plot";
            objFriendlyName = "Items:plotCategory_friendlyName";
         }
         if(this.m_categoryType == "item")
         {
            this.m_categoryType = "plot";
            catFriendlyName = "Items:plotCategory_friendlyName";
         }
         if(!this.m_deleteConfirm)
         {
            this.m_deleteConfirm = new DeleteConfirm(objFriendlyName,catFriendlyName,true);
            this.m_deleteConfirm.setReference(this);
            UI.displayPopup(this.m_deleteConfirm,false);
         }
         else
         {
            this.m_deleteConfirm.setCatAndObjType(catFriendlyName,objFriendlyName);
            this.m_deleteConfirm.defaultCheck1ToEmpty();
            UI.displayPopup(this.m_deleteConfirm,false);
         }
         if(this.m_categoryType == "plot")
         {
            this.m_categoryType = "item";
         }
      }
      
      public function killDeleteConfirm() : void
      {
         Global.persistentSell = false;
         this.m_persistentDeleting = false;
      }
      
      public function sellOrDeleteObject() : void
      {
         var isItemSellable:Boolean = false;
         var objResource:MapResource = null;
         var object:FarmGameObject = this.m_objectToSellOrDelete as FarmGameObject;
         var obj:ItemInstance = object as ItemInstance;
         if(obj.getItem())
         {
            if(Global.flashHotParams["USE_INSTANCE_BASED_DELETE"])
            {
               isItemSellable = obj.isSellable();
            }
            else
            {
               isItemSellable = obj.getItem().sellable;
            }
            if(isItemSellable && (obj.getItem().type != "plot" && obj.getItem().type != "seed" && obj.getItem().type != "building"))
            {
               obj.sellWithOutAsking();
               this.deselectObject();
            }
            else if(obj.getItem().type == "building")
            {
               objResource = obj as MapResource;
               if(objResource)
               {
                  objResource.onDelete();
                  this.deselectObject();
               }
            }
            else
            {
               this.setObjectToDelete();
            }
         }
         else
         {
            this.setObjectToDelete();
         }
      }
      
      public function setObjectToDelete() : void
      {
         this.m_object = m_highlightedObject;
         this.clearCloseHandler();
      }
      
      override protected function selectObject(object:WorldObject, event:MouseEvent = null) : void
      {
         var farmObj:FarmGameObject = null;
         var mapResource:MapResource = null;
         if(object != m_highlightedObject)
         {
            farmObj = object as FarmGameObject;
            this.deselectObject();
            if(Boolean(farmObj) && farmObj.isClearable())
            {
               m_highlightedObject = object;
            }
            else
            {
               m_highlightedObject = null;
            }
            if(m_highlightedObject)
            {
               mapResource = object as MapResource;
               if(mapResource)
               {
                  mapResource.setOverrideToolTip(this.qDeleteToolTip(mapResource));
               }
               m_highlightedObject.onMouseOver(event);
            }
            updateCursor();
         }
      }
      
      private function qDeleteToolTip(mapResource:MapResource) : String
      {
         var item:FarmItem = null;
         var isItemSellable:Boolean = false;
         var tooltip:String = "";
         if(Boolean(mapResource) && Boolean(mapResource.getItem()))
         {
            item = mapResource.getItem();
            if(item.specialValentinesItem && Boolean(item.friendlyName))
            {
               tooltip = item.friendlyTitle;
            }
            else if(!item.isLimitedItem())
            {
               if(Global.flashHotParams["USE_INSTANCE_BASED_DELETE"])
               {
                  isItemSellable = mapResource.isSellable();
               }
               else
               {
                  isItemSellable = mapResource.getItem().sellable;
               }
               if(isItemSellable && item.type !== "plot" && item.type !== "seed")
               {
                  tooltip = ZLocUtils.t("FarmGame","QuickDeleteSellsFor",{"quantity":String(item.sellPrice)});
               }
               else
               {
                  tooltip = ZLocUtils.t("FarmGame","ClickToClear");
               }
            }
            else
            {
               tooltip = ZLocUtils.t("FarmGame","QuickDeleteLimitedEdition");
            }
         }
         return tooltip;
      }
      
      override protected function deselectObject() : void
      {
         var farmObj:FarmGameObject = m_highlightedObject as FarmGameObject;
         if(farmObj is MapResource)
         {
            (farmObj as MapResource).setOverrideToolTip("");
         }
         super.deselectObject();
      }
      
      override protected function getCursor() : Object
      {
         return m_cursorImage;
      }
      
      private function clearCloseHandler(event:GenericPopupEvent = null) : void
      {
         var result:Boolean = false;
         var terrainCodes:Array = null;
         var terrainCodesByLimitIndex:Array = null;
         var limitGroupIndex:String = null;
         if(event)
         {
            result = event.button == GenericPopup.YES;
         }
         else
         {
            result = true;
         }
         if(Boolean(this.m_object) && result == true)
         {
            this.m_object.detach();
            if(this.m_object is MapResource)
            {
               (this.m_object as MapResource).onDelete();
            }
            if(this.m_object.getClassName() == "Plot")
            {
               terrainCodes = TerrainUtil.getTerrainCodesForItemInstance(this.m_object as ItemInstance);
               terrainCodesByLimitIndex = Global.worldManager.convertTerrainCodesToCodesByLimitIndex(terrainCodes);
               for(limitGroupIndex in terrainCodesByLimitIndex)
               {
                  Global.world.decrementPlotCount(terrainCodesByLimitIndex[limitGroupIndex]);
               }
            }
            TransactionManager.addTransaction(new TClear(this.m_object));
         }
         this.deselectObject();
      }
   }
}

