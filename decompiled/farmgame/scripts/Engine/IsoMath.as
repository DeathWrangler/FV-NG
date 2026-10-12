package Engine
{
   import Engine.Classes.World;
   import Engine.Helpers.Vector2;
   import Engine.Helpers.Vector3;
   import flash.display.DisplayObject;
   import flash.geom.Matrix;
   import flash.geom.Point;
   
   public class IsoMath
   {
      
      public static const DIRECTION_VECTORS:Array = [{
         "x":new Vector2(1,-1),
         "y":new Vector2(-1,-1)
      },{
         "x":new Vector2(1,1),
         "y":new Vector2(1,-1)
      },{
         "x":new Vector2(-1,1),
         "y":new Vector2(1,1)
      },{
         "x":new Vector2(-1,-1),
         "y":new Vector2(-1,1)
      }];
      
      public function IsoMath()
      {
         super();
      }
      
      public static function tilePosToPixelPos(param1:Number, param2:Number, param3:Number = 0, param4:Boolean = false) : Vector2
      {
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:World = World.getInstance();
         var _loc8_:Vector2 = new Vector2();
         var _loc9_:int = param4 ? _loc7_.getRotation() : Constants.ROTATION_0;
         var _loc10_:int = _loc7_.getGridWidth();
         var _loc11_:int = _loc7_.getGridHeight();
         switch(_loc9_)
         {
            case Constants.ROTATION_0:
               _loc8_.x = _loc10_ * Constants.TILE_WIDTH / 2;
               _loc8_.y = _loc11_ * Constants.TILE_HEIGHT;
               break;
            case Constants.ROTATION_90:
               _loc8_.x = 0;
               _loc8_.y = _loc11_ * Constants.TILE_HEIGHT / 2;
               break;
            case Constants.ROTATION_180:
               _loc8_.x = _loc10_ * Constants.TILE_WIDTH / 2;
               _loc8_.y = 0;
               break;
            case Constants.ROTATION_270:
               _loc8_.x = _loc10_ * Constants.TILE_WIDTH;
               _loc8_.y = _loc11_ * Constants.TILE_HEIGHT / 2;
         }
         var _loc12_:Object = DIRECTION_VECTORS[_loc9_];
         _loc5_ = (_loc12_.x.x * param1 + _loc12_.y.x * param2) * (Constants.TILE_WIDTH / 2) + _loc8_.x;
         _loc6_ = (_loc12_.x.y * param1 + _loc12_.y.y * param2) * (Constants.TILE_HEIGHT / 2) + _loc8_.y;
         return new Vector2(_loc5_,_loc6_);
      }
      
      public static function screenPosToTilePos(param1:Number, param2:Number, param3:Boolean = false) : Vector2
      {
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Point = IsoMath.stageToViewport(new Point(param1,param2));
         param1 = _loc6_.x;
         param2 = _loc6_.y;
         var _loc7_:World = World.getInstance();
         var _loc8_:int = _loc7_.getGridWidth();
         var _loc9_:int = _loc7_.getGridHeight();
         var _loc10_:int = param3 ? _loc7_.getRotation() : Constants.ROTATION_0;
         var _loc11_:Vector3 = new Vector3();
         switch(_loc10_)
         {
            case Constants.ROTATION_0:
               _loc11_.x = _loc8_ * Constants.TILE_WIDTH / 2;
               _loc11_.y = _loc9_ * Constants.TILE_HEIGHT;
               break;
            case Constants.ROTATION_90:
               _loc11_.x = 0;
               _loc11_.y = _loc9_ * Constants.TILE_HEIGHT / 2;
               break;
            case Constants.ROTATION_180:
               _loc11_.x = _loc8_ * Constants.TILE_WIDTH / 2;
               _loc11_.y = 0;
               break;
            case Constants.ROTATION_270:
               _loc11_.x = _loc8_ * Constants.TILE_WIDTH;
               _loc11_.y = _loc9_ * Constants.TILE_HEIGHT / 2;
         }
         var _loc12_:Object = DIRECTION_VECTORS[_loc10_];
         param1 = (param1 - _loc11_.x) / (Constants.TILE_WIDTH / 2);
         param2 = (param2 - _loc11_.y) / (Constants.TILE_HEIGHT / 2);
         _loc5_ = (param2 / _loc12_.x.y - param1 / _loc12_.x.x) / (_loc12_.y.y / _loc12_.x.y - _loc12_.y.x / _loc12_.x.x);
         _loc4_ = (param1 - _loc12_.y.x * _loc5_) / _loc12_.x.x;
         return new Vector2(_loc4_,_loc5_);
      }
      
      public static function getPixelDeltaFromTileDelta(param1:Number, param2:Number, param3:Boolean = true) : Vector2
      {
         var _loc4_:World = World.getInstance();
         var _loc5_:Vector2 = new Vector2();
         if(param3)
         {
            switch(_loc4_.getRotation())
            {
               case Constants.ROTATION_0:
                  _loc5_.x = (param1 - param2) / 2 * Constants.TILE_WIDTH;
                  _loc5_.y = -(param1 + param2) / 2 * Constants.TILE_HEIGHT;
                  break;
               case Constants.ROTATION_90:
                  _loc5_.x = (param1 + param2) / 2 * Constants.TILE_WIDTH;
                  _loc5_.y = (param1 - param2) / 2 * Constants.TILE_HEIGHT;
                  break;
               case Constants.ROTATION_180:
                  _loc5_.x = (param2 - param1) / 2 * Constants.TILE_WIDTH;
                  _loc5_.y = (param1 + param2) / 2 * Constants.TILE_HEIGHT;
                  break;
               case Constants.ROTATION_270:
                  _loc5_.x = -(param1 + param2) / 2 * Constants.TILE_WIDTH;
                  _loc5_.y = (param2 - param1) / 2 * Constants.TILE_HEIGHT;
            }
         }
         else
         {
            _loc5_.x = (param1 - param2) / 2 * Constants.TILE_WIDTH;
            _loc5_.y = -(param1 + param2) / 2 * Constants.TILE_HEIGHT;
         }
         return _loc5_;
      }
      
      public static function getRotatedDirection(param1:int, param2:Boolean = false) : int
      {
         var _loc3_:int = 0;
         var _loc4_:World = World.getInstance();
         if(param2 == false)
         {
            _loc3_ = param1 - _loc4_.getRotation();
            if(_loc3_ < 0)
            {
               _loc3_ += 4;
            }
         }
         else
         {
            _loc3_ = param1 + _loc4_.getRotation();
         }
         return _loc3_ % 4;
      }
      
      public static function getRotatedPosition(param1:Vector3, param2:Boolean = false) : Vector3
      {
         var _loc3_:Vector3 = new Vector3();
         var _loc4_:World = World.getInstance();
         var _loc5_:int = _loc4_.getGridWidth();
         var _loc6_:int = _loc4_.getGridHeight();
         switch(_loc4_.getRotation())
         {
            case Constants.ROTATION_0:
               _loc3_.x = param1.x;
               _loc3_.y = param1.y;
               break;
            case Constants.ROTATION_90:
               _loc3_.x = param1.y;
               _loc3_.y = _loc6_ - 1 - param1.x;
               break;
            case Constants.ROTATION_180:
               _loc3_.x = _loc5_ - 1 - param1.x;
               _loc3_.y = _loc6_ - 1 - param1.y;
               break;
            case Constants.ROTATION_270:
               _loc3_.x = _loc5_ - 1 - param1.y;
               _loc3_.y = param1.x;
         }
         _loc3_.z = param1.z;
         if(param2)
         {
            if(_loc3_.x < 0)
            {
               _loc3_.x = 0;
            }
            if(_loc3_.y < 0)
            {
               _loc3_.y = 0;
            }
         }
         return _loc3_;
      }
      
      public static function generateIsoTileMatrix(param1:DisplayObject, param2:Vector2 = null) : Matrix
      {
         var _loc3_:World = World.getInstance();
         if(param2 == null)
         {
            param2 = new Vector2(1,1);
         }
         param2.x *= Constants.TILE_WIDTH;
         param2.y *= Constants.TILE_HEIGHT;
         var _loc4_:Point = new Point(param2.x / (param1.width * Math.SQRT2),param2.y / (param1.height * Math.SQRT2));
         var _loc5_:Matrix = new Matrix();
         _loc5_.translate(-param1.width / 2,-param1.height / 2);
         _loc5_.rotate((-45 + _loc3_.getRotation() * 90) * Math.PI / 180);
         _loc5_.translate(param1.width / 2 * Math.SQRT2,param1.height / 2 * Math.SQRT2);
         _loc5_.scale(_loc4_.x,_loc4_.y);
         return _loc5_;
      }
      
      public static function stageToViewport(param1:Point) : Point
      {
         var _loc2_:Matrix = GlobalEngine.viewport.getTransformMatrix().clone();
         _loc2_.invert();
         var _loc3_:Point = param1.clone();
         return _loc2_.transformPoint(_loc3_);
      }
      
      public static function viewportToStage(param1:Point) : Point
      {
         var _loc2_:Point = param1.clone();
         return GlobalEngine.viewport.getTransformMatrix().transformPoint(_loc2_);
      }
   }
}

