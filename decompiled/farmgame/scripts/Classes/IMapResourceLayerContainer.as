package Classes
{
   import Classes.ZItem.FarmItem;
   import flash.display.DisplayObject;
   
   public interface IMapResourceLayerContainer
   {
      
      function get layers() : Array;
      
      function addLayer(param1:MapResourceLayer) : void;
      
      function removeLayer(param1:MapResourceLayer, param2:Boolean = true) : void;
      
      function removeAllLayers(param1:Boolean = true) : void;
      
      function drawDisplayObject() : void;
      
      function createDisplayObject() : DisplayObject;
      
      function deleteDisplayObject() : void;
      
      function getDisplayObject() : DisplayObject;
      
      function getItem() : FarmItem;
      
      function getContent() : DisplayObject;
      
      function get isAnimating() : Boolean;
   }
}

