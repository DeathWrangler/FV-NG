package Managers
{
   import Classes.EmbeddedArt;
   import Classes.Terrain.TerrainUtil;
   import Classes.UserDrivenTerrain.UDTMap;
   import Engine.Helpers.Vector2;
   import Engine.IsoMath;
   import Engine.Managers.TransactionManager;
   import GameMode.GMDefault;
   import GameMode.GMTerrainClear;
   import GameMode.GMTerrainDefault;
   import GameMode.GMTerrainMove;
   import GameMode.GMTerrainPlace;
   import Transactions.TSetTerrainMapping;
   import flash.events.MouseEvent;
   
   public class UDTManager
   {
      
      private static var m_objInstance:UDTManager;
      
      public static const DEFAULT:Class = GMTerrainDefault;
      
      public static const PLACEMENT:Class = GMTerrainPlace;
      
      public static const MOVE:Class = GMTerrainMove;
      
      public static const CLEAR:Class = GMTerrainClear;
      
      protected var m_lastDataPoint:Object;
      
      public function UDTManager(objEnforcer:SingletonEnforcer)
      {
         super();
         this.m_lastDataPoint = null;
      }
      
      public static function get udt() : UDTManager
      {
         if(m_objInstance == null)
         {
            m_objInstance = new UDTManager(new SingletonEnforcer());
         }
         return m_objInstance;
      }
      
      public static function enterTerrainEditor(mode:Class = null, code:int = 0) : void
      {
         if(mode == null)
         {
            mode = UDTManager.DEFAULT;
         }
         var terrainMode:GMTerrainDefault = new mode();
         if(mode == UDTManager.PLACEMENT)
         {
            (terrainMode as GMTerrainPlace).setTerrainCode(code);
         }
         Global.world.addGameMode(terrainMode,true);
      }
      
      public static function exitTerrainEditor() : void
      {
         TransactionManager.addTransaction(new TSetTerrainMapping((Global.world.terrainMap as UDTMap).getCurrentTerrainCodeMapping()),true);
         Global.world.addGameMode(new GMDefault(),true);
      }
      
      public static function enableTransparencyMap() : void
      {
         GlobalEngine.viewport.objectBase.alpha = 0.15;
      }
      
      public static function disableTransparencyMap() : void
      {
         GlobalEngine.viewport.objectBase.alpha = 1;
      }
      
      public static function get actionMenuItem() : Object
      {
         return {
            "toolTip":"Terrain",
            "text":"Terrain",
            "icon":EmbeddedArt.hud_act_move,
            "onClick":enterTerrainEditor
         };
      }
      
      public static function setSizeAccordingToZoom() : uint
      {
         var zoomLevel:Number = GlobalEngine.viewport.getZoom();
         var multiplier:Number = 2;
         var size:uint = Math.floor(multiplier / zoomLevel);
         return 18;
      }
      
      public function getLastDataPointCode() : int
      {
         var result:int = TerrainUtil.DEFAULT_TERRAIN_CODE;
         if(this.m_lastDataPoint)
         {
            result = int(this.m_lastDataPoint.code);
         }
         return result;
      }
      
      public function clearLastDataPoint() : void
      {
         if(this.m_lastDataPoint != null)
         {
            (Global.world.terrainMap as UDTMap).setDataPoint(this.m_lastDataPoint.position.x / 2,this.m_lastDataPoint.position.y / 2,this.m_lastDataPoint.code);
            this.m_lastDataPoint = null;
            GlobalEngine.viewport.setDirty();
         }
      }
      
      public function updateUDTMap(actionType:int, event:MouseEvent, newType:int, processAsClick:Boolean = false) : void
      {
         this.clearLastDataPoint();
         var eventPosition:Vector2 = IsoMath.screenPosToTilePos(event.stageX,event.stageY);
         var eventPositionCode:int = (Global.world.terrainMap as UDTMap).getDataPointCode(eventPosition.x / 2,eventPosition.y / 2);
         if(!processAsClick)
         {
            this.m_lastDataPoint = {
               "position":eventPosition,
               "code":eventPositionCode
            };
         }
         (Global.world.terrainMap as UDTMap).setDataPoint(eventPosition.x / 2,eventPosition.y / 2,newType,processAsClick,actionType,0,0);
         GlobalEngine.viewport.setDirty();
      }
      
      public function multiUpdateUDTMap(actionType:int, event:MouseEvent, newType:int, sizeX:int = 3, sizeY:int = 3) : void
      {
         var j:int = 0;
         this.updateUDTMap(actionType,event,newType,true);
         var size:uint = setSizeAccordingToZoom();
         sizeX = int(size);
         sizeY = int(size);
         var eventPosition:Vector2 = IsoMath.screenPosToTilePos(event.stageX,event.stageY);
         var posX:uint = eventPosition.x / 2;
         var posY:uint = eventPosition.y / 2;
         for(var i:int = 0; i < sizeX; i++)
         {
            for(j = 0; j < sizeY; j++)
            {
               (Global.world.terrainMap as UDTMap).setDataPoint(posX + i,posY + j,newType,true,actionType,0,0);
            }
         }
         GlobalEngine.viewport.setDirty();
      }
   }
}

class SingletonEnforcer
{
   
   public function SingletonEnforcer()
   {
      super();
   }
}
