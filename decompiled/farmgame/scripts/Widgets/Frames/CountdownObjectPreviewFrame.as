package Widgets.Frames
{
   import Classes.MapResource;
   import Classes.ZItem.FarmItem;
   import flash.display.MovieClip;
   import flash.geom.Point;
   
   public class CountdownObjectPreviewFrame extends ObjectPreviewFrame
   {
      
      public function CountdownObjectPreviewFrame(element:MovieClip, item:FarmItem, zoomCallback:Function = null, zoomLevels:Array = null, zoomWidths:Array = null, imageState:String = "", metaData:String = "", mapResource:MapResource = null, offset:Point = null)
      {
         super(element,item,zoomCallback,zoomLevels,zoomWidths,imageState,metaData,mapResource,offset);
      }
      
      override protected function computeImageOffset(newDimensions:Object) : Point
      {
         return new Point(0,newDimensions.height / -2);
      }
   }
}

