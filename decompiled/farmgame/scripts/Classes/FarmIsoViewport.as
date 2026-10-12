package Classes
{
   import Classes.Constants.WorldsConstants;
   import Display.FarmTileMap;
   import Engine.Classes.IsoViewport;
   import Engine.Classes.World;
   import Engine.Helpers.Vector2;
   import Engine.MathUtil;
   import Managers.DefconManager;
   import Managers.PerformanceExperimentManager;
   import flash.geom.Point;
   
   public class FarmIsoViewport extends IsoViewport
   {
      
      public static const ZOOM_STEP:Number = 0.283;
      
      public static const ZOOM_OUT_LIMIT:Number = 0.302;
      
      public static const ZOOM_OUT_LIMIT_SPECIFIC:Number = 0.2;
      
      public static const ZOOM_OUT_LIMIT_SPECIFIC_FARMS:Array = new Array(WorldsConstants.WORLD_ID_WILDWEST,WorldsConstants.WORLD_ID_TREASURETIDES,WorldsConstants.WORLD_ID_AFRICA,WorldsConstants.WORLD_ID_TRANSYLVANIA,WorldsConstants.WORLD_ID_WINTER,WorldsConstants.WORLD_ID_INDIA,WorldsConstants.WORLD_ID_JAPAN,WorldsConstants.WORLD_ID_JUNGLE,WorldsConstants.WORLD_ID_MOUNT,WorldsConstants.WORLD_ID_LIMBO,WorldsConstants.WORLD_ID_XMAS,WorldsConstants.WORLD_ID_MIDWEST,WorldsConstants.WORLD_ID_UNDERWATER,WorldsConstants.WORLD_ID_TURTLEISLAND,WorldsConstants.WORLD_ID_ANGLOFRENCH,WorldsConstants.WORLD_ID_DREAMWORLD,WorldsConstants.WORLD_ID_BRAZIL,WorldsConstants.WORLD_ID_HALLOWEENUSA,WorldsConstants.WORLD_ID_DRAGONVALLEY,WorldsConstants.WORLD_ID_WHITEWINTER,WorldsConstants.WORLD_ID_RUSSIA,WorldsConstants.WORLD_ID_TUSCANY,WorldsConstants.WORLD_ID_ISRAEL,WorldsConstants.WORLD_ID_CARIBBEAN,WorldsConstants.WORLD_ID_NEWFRONTIER,WorldsConstants.WORLD_ID_HALLOWEENMAD,WorldsConstants.WORLD_ID_WINTERNORD,WorldsConstants
      .WORLD_ID_CASABLANCA,WorldsConstants.WORLD_ID_SOUTHINDIA,WorldsConstants.WORLD_ID_TWENTIES,WorldsConstants.WORLD_ID_ALASKA,WorldsConstants.WORLD_ID_COCOLAND,WorldsConstants.WORLD_ID_IRELAND,WorldsConstants.WORLD_ID_SANTAVILLAGE,WorldsConstants.WORLD_ID_SPOOKY,WorldsConstants.WORLD_ID_BORABORA,WorldsConstants.WORLD_ID_FARMFEST,WorldsConstants.WORLD_ID_MADAGASCAR,WorldsConstants.WORLD_ID_AMSTERDAM,WorldsConstants.WORLD_ID_CANADA,WorldsConstants.WORLD_ID_ALOHA,WorldsConstants.WORLD_ID_PUMPKIN,WorldsConstants.WORLD_ID_YULETIDE);
      
      public static const ZOOM_OUT_LIMIT_RESTRICTED:Number = 0.868;
      
      public static const ZOOM_IN_LIMIT:Number = 2;
      
      public function FarmIsoViewport()
      {
         super();
      }
      
      override protected function render(forceRender:Boolean = false, updateCullingAfterDrawBackground:Boolean = true) : Boolean
      {
         updateCullingAfterDrawBackground = false;
         return super.render(forceRender,updateCullingAfterDrawBackground);
      }
      
      public function zoomIn(steps:int = 1) : Boolean
      {
         return this.setZoom(getZoom() + ZOOM_STEP * steps);
      }
      
      public function zoomOut(steps:int = 1) : Boolean
      {
         return this.setZoom(getZoom() - ZOOM_STEP * steps);
      }
      
      public function zoomToLevel(level:int) : Boolean
      {
         return this.setZoom(ZOOM_IN_LIMIT - ZOOM_STEP * level);
      }
      
      override public function setZoom(zoom:Number) : Boolean
      {
         var changed:Boolean = false;
         var currentWorld:String = Global.worldManager.currentWorldType;
         var zoomOutLimit:Number = PerformanceExperimentManager.isInExtremePerformanceLimiterExperiment ? ZOOM_OUT_LIMIT_RESTRICTED : (ZOOM_OUT_LIMIT_SPECIFIC_FARMS.lastIndexOf(currentWorld) == -1 ? ZOOM_OUT_LIMIT : ZOOM_OUT_LIMIT_SPECIFIC);
         zoom = MathUtil.clamp(zoom,zoomOutLimit,ZOOM_IN_LIMIT);
         if(zoom != getZoom())
         {
            changed = super.setZoom(zoom);
            if(stage)
            {
               this.setScrollPosition(getScrollPosition());
            }
            DefconManager.refresh();
         }
         return changed;
      }
      
      override public function setScrollPosition(newPos:Vector2) : void
      {
         var boundaryPoints:Array = null;
         var point1:Point = null;
         var point2:Point = null;
         if(stage != null)
         {
            boundaryPoints = FarmTileMap(World.getInstance().getTileMap()).getFarmScrollBoundaries();
            point1 = boundaryPoints[0];
            point2 = boundaryPoints[1];
            if(newPos.x > point1.x)
            {
               newPos.x = point1.x;
            }
            if(newPos.x < point2.x)
            {
               newPos.x = point2.x;
            }
            if(newPos.y < point1.y)
            {
               newPos.y = point1.y;
            }
            if(newPos.y > point2.y)
            {
               newPos.y = point2.y;
            }
         }
         super.setScrollPosition(newPos);
      }
   }
}

