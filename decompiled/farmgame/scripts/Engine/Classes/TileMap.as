package Engine.Classes
{
   import Engine.Constants;
   import Engine.Helpers.IntVector2;
   import Engine.Interfaces.ITerrainMap;
   import Engine.IsoMath;
   import flash.display.*;
   import flash.events.*;
   import flash.geom.*;
   
   public class TileMap
   {
      
      protected static const LOT_OUTLINE_THICKNESS:Number = 1;
      
      protected static const LOT_OUTLINE_BORDER_THICKNESS:Number = 1;
      
      protected var m_width:int;
      
      protected var m_height:int;
      
      protected var m_drawingTarget:Object;
      
      protected var m_lotOutline:Sprite = new Sprite();
      
      protected var m_terrain:ITerrainMap;
      
      public function TileMap(param1:int, param2:int)
      {
         super();
         this.m_width = param1;
         this.m_height = param2;
         this.m_drawingTarget = GlobalEngine.viewport;
         this.m_drawingTarget.graphics.clear();
         while(this.m_drawingTarget.numChildren > 0)
         {
            this.m_drawingTarget.removeChildAt(0);
         }
         this.generateLotOutline();
         this.m_lotOutline.visible = false;
         this.m_drawingTarget.addChild(this.m_lotOutline);
      }
      
      public static function drawTileArea(param1:Object, param2:Point, param3:Point, param4:Point) : void
      {
         param1.graphics.moveTo(param2.x,param2.y);
         param1.graphics.lineTo(param2.x + param3.x,param2.y + param3.y);
         param1.graphics.lineTo(param2.x + param3.x + param4.x,param2.y + param3.y + param4.y);
         param1.graphics.lineTo(param2.x + param4.x,param2.y + param4.y);
         param1.graphics.lineTo(param2.x,param2.y);
      }
      
      public function setTerrain(param1:ITerrainMap) : void
      {
         this.m_terrain = param1;
      }
      
      public function getTerrain() : ITerrainMap
      {
         return this.m_terrain;
      }
      
      public function render(param1:Viewport) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:Point = null;
         var _loc5_:Tile = null;
         var _loc6_:BitmapData = null;
         if(this.m_terrain)
         {
            _loc2_ = 0;
            while(_loc2_ < this.m_height / Constants.TILE_SCALE)
            {
               _loc3_ = 0;
               while(_loc3_ < this.m_width / Constants.TILE_SCALE)
               {
                  _loc4_ = IsoMath.tilePosToPixelPos(_loc3_ * Constants.TILE_SCALE,_loc2_ * Constants.TILE_SCALE,0,true);
                  _loc4_.x -= Constants.TILE_WIDTH / 2 * Constants.TILE_SCALE;
                  _loc4_.y -= Constants.TILE_HEIGHT * Constants.TILE_SCALE;
                  if(!(_loc3_ < this.m_terrain.width && _loc2_ < this.m_terrain.height))
                  {
                     break;
                  }
                  _loc5_ = this.m_terrain.tileAt(_loc3_,_loc2_);
                  _loc6_ = _loc5_.getBitmapData();
                  param1.copyPixels(_loc6_,_loc6_.rect,_loc4_,null,null,true);
                  _loc3_++;
               }
               _loc2_++;
            }
         }
      }
      
      public function getReferencedAssets() : Array
      {
         var _loc3_:int = 0;
         var _loc4_:Tile = null;
         var _loc1_:Array = [];
         var _loc2_:int = 0;
         while(_loc2_ < this.m_height)
         {
            _loc3_ = 0;
            while(_loc3_ < this.m_width)
            {
               _loc4_ = this.m_terrain.tileAt(_loc3_,_loc2_);
               if(_loc4_ != null)
               {
                  if(_loc1_.indexOf(_loc4_) == -1)
                  {
                     _loc1_.push(_loc4_);
                  }
               }
               _loc3_++;
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      public function setLotOutlineVisible(param1:Boolean) : void
      {
         this.m_lotOutline.visible = param1;
      }
      
      public function isLotOutlineVisible() : Boolean
      {
         return this.m_lotOutline.visible;
      }
      
      private function generateLotOutline() : void
      {
         var _loc1_:Point = IsoMath.tilePosToPixelPos(0,0,0,true);
         var _loc2_:Point = IsoMath.getPixelDeltaFromTileDelta(this.m_width,0,true);
         var _loc3_:Point = IsoMath.getPixelDeltaFromTileDelta(0,this.m_height,true);
         this.m_lotOutline.graphics.clear();
         this.m_lotOutline.graphics.moveTo(_loc1_.x,_loc1_.y);
         this.m_lotOutline.graphics.lineStyle(TileMap.LOT_OUTLINE_THICKNESS + 2 * TileMap.LOT_OUTLINE_BORDER_THICKNESS,Constants.COLOR_LOT_OUTLINE_BORDER,Constants.ALPHA_LOT_OUTLINE_BORDER);
         drawTileArea(this.m_lotOutline,_loc1_,_loc2_,_loc3_);
         this.m_lotOutline.graphics.lineStyle(0,0);
         this.m_lotOutline.graphics.moveTo(_loc1_.x,_loc1_.y);
         this.m_lotOutline.graphics.lineStyle(TileMap.LOT_OUTLINE_THICKNESS,Constants.COLOR_LOT_OUTLINE,Constants.ALPHA_LOT_OUTLINE);
         drawTileArea(this.m_lotOutline,_loc1_,_loc2_,_loc3_);
         this.m_lotOutline.graphics.lineStyle(0,0);
      }
      
      public function floodFill(param1:int, param2:int, param3:Tile) : void
      {
         var _loc8_:IntVector2 = null;
         var _loc9_:* = 0;
         var _loc4_:Array = new Array();
         var _loc5_:Tile = this.getTileForPosition(param1,param2);
         var _loc6_:Boolean = false;
         var _loc7_:Boolean = true;
         if(_loc5_ != param3)
         {
            _loc4_.push(new IntVector2(param1,param2));
            while(_loc4_.length)
            {
               _loc8_ = _loc4_.pop() as IntVector2;
               _loc9_ = _loc8_.y;
               while(this.getTileForPosition(_loc8_.x,_loc9_) == _loc5_)
               {
                  _loc9_--;
               }
               _loc9_++;
               _loc7_ = false;
               _loc6_ = false;
               while(this.getTileForPosition(_loc8_.x,_loc9_) == _loc5_)
               {
                  this.m_terrain.setTile(_loc8_.x,_loc9_,param3);
                  if(!_loc6_ && this.getTileForPosition(_loc8_.x - 1,_loc9_) == _loc5_)
                  {
                     _loc4_.push(new IntVector2(_loc8_.x - 1,_loc9_));
                     _loc6_ = true;
                  }
                  else if(_loc6_ && this.getTileForPosition(_loc8_.x - 1,_loc9_) != _loc5_)
                  {
                     _loc6_ = false;
                  }
                  if(!_loc7_ && this.getTileForPosition(_loc8_.x + 1,_loc9_) == _loc5_)
                  {
                     _loc4_.push(new IntVector2(_loc8_.x + 1,_loc9_));
                     _loc7_ = true;
                  }
                  else if(_loc7_ && this.getTileForPosition(_loc8_.x + 1,_loc9_) != _loc5_)
                  {
                     _loc7_ = false;
                  }
                  _loc9_++;
               }
            }
            this.fullyRedrawTileMap();
         }
      }
      
      public function getWidth() : int
      {
         return this.m_width;
      }
      
      public function getHeight() : int
      {
         return this.m_height;
      }
      
      public function getTileForPosition(param1:int, param2:int) : Tile
      {
         var _loc3_:Tile = null;
         if(param1 >= 0 && param1 < this.m_width && param2 >= 0 && param2 < this.m_height)
         {
            _loc3_ = this.m_terrain.tileAt(param1,param2);
         }
         return _loc3_;
      }
      
      public function fullyRedrawTileMap() : void
      {
         this.m_drawingTarget.graphics.clear();
         this.generateLotOutline();
      }
   }
}

