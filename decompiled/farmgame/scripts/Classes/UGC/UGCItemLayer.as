package Classes.UGC
{
   import Classes.IMapResourceLayerContainer;
   import Classes.ItemImage;
   import Classes.MapResourceLayer;
   import Classes.ZItem.FarmItem;
   import Classes.util.ColorUtil;
   import Engine.Utilities;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   
   public class UGCItemLayer extends MapResourceLayer
   {
      
      private static const BASE_LAYER_PRIORITY:int = 0;
      
      private var m_ugcImageDef:UGCItemLayerImageDefinition;
      
      private var m_ugcItemState:UGCItemLayerState;
      
      public var itemImage:ItemImage = null;
      
      public var imageContent:DisplayObject = null;
      
      public function UGCItemLayer(imageDef:UGCItemLayerImageDefinition, ugcState:UGCItemLayerState)
      {
         this.m_ugcImageDef = imageDef;
         this.m_ugcItemState = ugcState;
         var itemName:String = Global.farmGameSettingsManager.getFarmItemNameByCode(this.m_ugcItemState.itemCode);
         super(itemName);
      }
      
      public function get ugcImageDef() : UGCItemLayerImageDefinition
      {
         return this.m_ugcImageDef;
      }
      
      public function get ugcItemState() : UGCItemLayerState
      {
         return this.m_ugcItemState;
      }
      
      public function set ugcItemState(value:UGCItemLayerState) : void
      {
         var itemChanged:Boolean = false;
         var oldState:UGCItemLayerState = this.m_ugcItemState;
         if(this.m_ugcItemState != value)
         {
            this.m_ugcItemState = value;
         }
         if(this.m_ugcItemState.item != getItem())
         {
            this.setItem(this.m_ugcItemState.item);
            itemChanged = true;
         }
         if(itemChanged || oldState != null && this.m_ugcItemState != null && oldState.color != this.m_ugcItemState.color)
         {
            this.reloadImage();
            this.initializeFilters();
         }
      }
      
      override public function setItem(item:FarmItem) : void
      {
         if(item == null && m_container != null)
         {
            item = m_container.getItem();
         }
         super.setItem(item);
      }
      
      override public function set container(value:IMapResourceLayerContainer) : void
      {
         super.container = value;
         if(m_container != null && m_item == null)
         {
            super.setItem(m_container.getItem());
         }
      }
      
      override public function reloadImage() : void
      {
         if(m_displayObject != null)
         {
            Utilities.removeAllChildren(m_displayObject as DisplayObjectContainer);
            m_content = null;
         }
         super.reloadImage();
      }
      
      override protected function getCurrentImage() : ItemImage
      {
         var result:ItemImage = null;
         if(m_item != null)
         {
            result = m_item.getCachedImage(this.m_ugcImageDef.exportName,true);
         }
         return result;
      }
      
      override protected function initializeFilters() : void
      {
         if(this.m_ugcItemState.isCustomColor)
         {
            m_colorMatrixFilter = ColorUtil.getColorMatrixFilter(this.m_ugcItemState.color,UGCConstants.COLOR_ALPHA);
         }
         else
         {
            m_colorMatrixFilter = null;
         }
         if(m_content != null)
         {
            if(m_colorMatrixFilter != null)
            {
               m_content.filters = [m_colorMatrixFilter];
            }
         }
      }
      
      private function getLayerItemPriority(layer:UGCItemLayer) : int
      {
         var itemName:String = null;
         var layerPriority:int = layer.ugcImageDef.layerPriority;
         var itemPriorityHash:Object = layer.ugcImageDef.ugcItemLayerDefinition.itemPriorityByItemNameHash;
         if(Boolean(layer && layer.ugcItemState) && Boolean(layer.ugcItemState.item) && Boolean(layer.ugcItemState.item.name))
         {
            itemName = layer.ugcItemState.item.name;
            if(itemPriorityHash.hasOwnProperty(itemName) && itemPriorityHash[itemName] != 0)
            {
               layerPriority = int(itemPriorityHash[itemName]);
            }
         }
         return layerPriority;
      }
      
      override public function compareTo(otherLayer:MapResourceLayer) : int
      {
         var layerB:UGCItemLayer = otherLayer as UGCItemLayer;
         var result:int = 0;
         if(layerB != null)
         {
            result = this.comparePriorities(this.getLayerItemPriority(this),this.getLayerItemPriority(layerB));
         }
         return result;
      }
      
      override public function compareToBase() : int
      {
         return this.comparePriorities(this.getLayerItemPriority(this),BASE_LAYER_PRIORITY);
      }
      
      private function comparePriorities(priorityA:int, priorityB:int) : int
      {
         var result:int = 0;
         if(priorityA < priorityB)
         {
            result = -1;
         }
         else if(priorityA > priorityB)
         {
            result = 1;
         }
         return result;
      }
   }
}

