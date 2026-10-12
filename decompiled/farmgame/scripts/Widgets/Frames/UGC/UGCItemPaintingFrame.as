package Widgets.Frames.UGC
{
   import Classes.CompositeMapResource;
   import Classes.MapResource;
   import Classes.MapResourceLayer;
   import Classes.UGC.UGCConstants;
   import Classes.UGC.UGCItemDefinition;
   import Classes.UGC.UGCItemLayer;
   import Classes.UGC.UGCItemLayerDefinition;
   import Classes.ZItem.FarmItem;
   import Engine.Utilities;
   import Events.DynamicObjectEvent;
   import Widgets.Frames.ObjectPreviewFrame;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   
   public class UGCItemPaintingFrame extends ObjectPreviewFrame
   {
      
      private var m_dict:Dictionary;
      
      private var m_activeColor:uint;
      
      private var m_resource:CompositeMapResource;
      
      private var m_ugcItemDefinition:UGCItemDefinition;
      
      public function UGCItemPaintingFrame(element:MovieClip, item:FarmItem, zoomLevels:Array = null)
      {
         super(element,item,null,zoomLevels);
         this.m_activeColor = UGCConstants.COLOR_UNSET;
         this.m_dict = new Dictionary(true);
         this.m_resource = m_mapResource as CompositeMapResource;
      }
      
      public function get isPaintingEnabled() : Boolean
      {
         return this.m_activeColor < UGCConstants.COLOR_UNSET;
      }
      
      public function set ugcItemDefinition(value:UGCItemDefinition) : void
      {
         var oldColor:uint = 0;
         if(this.m_ugcItemDefinition != value)
         {
            if(this.isPaintingEnabled)
            {
               oldColor = this.m_activeColor;
               this.disablePainting();
               this.m_ugcItemDefinition = value;
               this.togglePainting(oldColor);
            }
            else
            {
               this.m_ugcItemDefinition = value;
            }
         }
      }
      
      override public function release() : void
      {
         this.disablePainting();
         super.release();
      }
      
      public function togglePainting(color:uint) : void
      {
         if(color === this.m_activeColor)
         {
            this.disablePainting();
         }
         else
         {
            this.enablePainting(color);
         }
      }
      
      private function enablePainting(color:uint) : void
      {
         var ugcItemLayer:UGCItemLayer = null;
         var ugcLayerDef:UGCItemLayerDefinition = null;
         var layer:MapResourceLayer = null;
         if(this.m_resource != null && this.m_ugcItemDefinition != null)
         {
            if(!this.isPaintingEnabled)
            {
               this.m_resource.pause();
            }
            this.m_activeColor = color;
            if(this.m_ugcItemDefinition.base.isColorable)
            {
               this.addPaintableContent(this.m_resource,this.m_ugcItemDefinition.base);
            }
            for each(layer in this.m_resource.layers)
            {
               ugcItemLayer = layer as UGCItemLayer;
               ugcLayerDef = ugcItemLayer.ugcImageDef.ugcItemLayerDefinition;
               if(ugcItemLayer != null && ugcLayerDef != this.m_ugcItemDefinition.base && ugcLayerDef.isColorable)
               {
                  this.addPaintableContent(layer,ugcLayerDef);
               }
            }
         }
      }
      
      private function addPaintableContent(resource:MapResource, layerDef:UGCItemLayerDefinition) : void
      {
         var content:DisplayObject = null;
         var display:DisplayObjectContainer = null;
         if(resource != null)
         {
            content = resource.getContent();
            display = resource.getDisplayObject() as DisplayObjectContainer;
            if(content != null && display != null && this.m_dict[content] == null)
            {
               content.addEventListener(MouseEvent.MOUSE_OVER,this.onLayerOver,false,0,true);
               content.addEventListener(MouseEvent.MOUSE_OUT,this.onLayerOut,false,0,true);
               content.addEventListener(MouseEvent.CLICK,this.onLayerClick,false,0,true);
               Utilities.toggleInputAndChildren(display,true);
               this.m_dict[content] = {
                  "resource":resource,
                  "layerDef":layerDef,
                  "display":display
               };
            }
         }
      }
      
      public function disablePainting() : void
      {
         var content:DisplayObject = null;
         var display:DisplayObjectContainer = null;
         var key:Object = null;
         if(this.isPaintingEnabled)
         {
            for(key in this.m_dict)
            {
               content = key as DisplayObject;
               if(content != null)
               {
                  content.removeEventListener(MouseEvent.MOUSE_OVER,this.onLayerOver);
                  content.removeEventListener(MouseEvent.MOUSE_OUT,this.onLayerOut);
                  content.removeEventListener(MouseEvent.CLICK,this.onLayerClick);
               }
               display = this.m_dict[key].display as DisplayObjectContainer;
               if(display != null)
               {
                  Utilities.toggleInputAndChildren(display,false);
               }
            }
            this.m_dict = new Dictionary(true);
            this.m_activeColor = UGCConstants.COLOR_UNSET;
            this.m_resource.play(true);
         }
      }
      
      private function onLayerOver(event:MouseEvent) : void
      {
         this.toggleHighlighted(event,true);
      }
      
      private function onLayerOut(event:MouseEvent) : void
      {
         this.toggleHighlighted(event,false);
      }
      
      private function toggleHighlighted(event:MouseEvent, highlighted:Boolean) : void
      {
         var context:Object = null;
         var content:DisplayObject = event.currentTarget as DisplayObject;
         if(content != null)
         {
            context = this.m_dict[content];
            (context.resource as MapResource).setHighlighted(highlighted);
         }
      }
      
      private function onLayerClick(event:MouseEvent) : void
      {
         var context:Object = null;
         var content:DisplayObject = event.currentTarget as DisplayObject;
         if(content != null)
         {
            context = this.m_dict[content];
            dispatchEvent(new DynamicObjectEvent(UGCConstants.EVENT_PAINT_RESOURCE,{
               "color":this.m_activeColor,
               "layerDef":context.layerDef
            }));
         }
      }
   }
}

