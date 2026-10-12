package Widgets.Frames.CaptureFeatureBuilding
{
   import Classes.MapResource;
   import Classes.ZItem.FarmItem;
   import Widgets.Frames.*;
   import flash.display.MovieClip;
   import flash.geom.Point;
   
   public class CaptureFeatureObjectPreviewFrame extends ObjectPreviewFrame
   {
      
      public function CaptureFeatureObjectPreviewFrame(element:MovieClip, item:FarmItem, zoomCallback:Function = null, zoomLevels:Array = null, zoomWidths:Array = null, imageState:String = "", metaData:String = "", mapResource:MapResource = null, offset:Point = null)
      {
         super(element,item,zoomCallback,zoomLevels,zoomWidths,imageState,metaData,mapResource,offset);
      }
      
      override protected function computeImageOffset(newDimensions:Object) : Point
      {
         return new Point(0,newDimensions.height / 2.5);
      }
   }
}

