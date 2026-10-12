package Engine
{
   public class Constants
   {
      
      public static const INDEX_NONE:int = -1;
      
      public static const DRAG_CLICK_EPSILON:int = 4;
      
      public static const POSITION_OFFSET_EPSILON:Number = 0.001;
      
      public static const ASSET_NONE:String = "none";
      
      public static const ASSET_TILE:String = "tile";
      
      public static const ROTATION_0:int = 0;
      
      public static const ROTATION_90:int = 1;
      
      public static const ROTATION_180:int = 2;
      
      public static const ROTATION_270:int = 3;
      
      public static const ROTATION_MAX:int = 4;
      
      public static const DIRECTION_SW:int = 0;
      
      public static const DIRECTION_SE:int = 1;
      
      public static const DIRECTION_NE:int = 2;
      
      public static const DIRECTION_NW:int = 3;
      
      public static const DIRECTION_MAX:int = 4;
      
      public static const OBJECT_NONE:int = 0;
      
      public static const WORLDOBJECT_NONE:int = 0;
      
      public static const WORLDOBJECT_UNKNOWN:int = 1;
      
      public static const WORLDOBJECT_ITEM:int = 2;
      
      public static const WORLDOBJECT_AVATAR:int = 4;
      
      public static const WORLDOBJECT_MESSAGE_SIGN:int = 8;
      
      public static const WORLDOBJECT_ALL_EXCEPT_AVATAR:int = ~WORLDOBJECT_AVATAR;
      
      public static const WORLDOBJECT_ALL:int = 16777215;
      
      public static const OBJECTFLAG_NONE:int = 0;
      
      public static const OBJECTFLAG_INTERACTIVE:int = 1;
      
      public static const OBJECTFLAG_COLLIDABLE:int = 2;
      
      public static const COLLISION_NONE:int = 0;
      
      public static const COLLISION_AVATAR:int = 1;
      
      public static const COLLISION_ALL_EXCEPT_AVATAR:int = 2;
      
      public static const COLLISION_OVERLAP:int = 4;
      
      public static const COLLISION_SAME_ONLY:int = 8;
      
      public static const COLLISION_PATHS:int = 16;
      
      public static const COLLISION_ALL:int = 32;
      
      public static const COLOR_HIGHLIGHT:uint = 16755200;
      
      public static const COLOR_HIGHLIGHT_BLUE:uint = 65535;
      
      public static const COLOR_LOT_OUTLINE:uint = 16776960;
      
      public static const ALPHA_LOT_OUTLINE:Number = 0.8;
      
      public static const COLOR_LOT_OUTLINE_BORDER:uint = 0;
      
      public static const ALPHA_LOT_OUTLINE_BORDER:Number = 0.8;
      
      public static const COLOR_VALID_PLACEMENT:uint = 4521796;
      
      public static const COLOR_OVERLAP:uint = 16777028;
      
      public static const COLOR_NOT_VALID_PLACEMENT:uint = 16729156;
      
      public static const ALPHA_VALID_PLACEMENT:Number = 1;
      
      public static const ALPHA_NOT_VALID_PLACEMENT:Number = 0.5;
      
      public static var TILE_WIDTH:int = 80;
      
      public static var TILE_HEIGHT:int = 40;
      
      public static var TILE_SCALE:Number = 1;
      
      public static const D1DROP_STATS_MAX_TIMESTAMP:int = 90;
      
      public static const NO_NETWORK:Number = 1;
      
      public static const FACEBOOK_NETWORK:Number = 1;
      
      public static const ZLIVE_NETWORK:Number = 18;
      
      public function Constants()
      {
         super();
      }
   }
}

