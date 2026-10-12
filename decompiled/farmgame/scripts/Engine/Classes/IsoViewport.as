package Engine.Classes
{
   import Engine.Helpers.Vector2;
   import Engine.IsoMath;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.geom.Point;
   
   public class IsoViewport extends Viewport
   {
      
      public static const LOADED:String = "loaded";
      
      protected var m_objectLayers:Array = [];
      
      public function IsoViewport()
      {
         super();
      }
      
      public function addObjectLayer(param1:ObjectLayer) : void
      {
         this.m_objectLayers.push(param1);
         this.m_objectLayers.sortOn("priority",Array.NUMERIC);
         while(objectBase.numChildren > 0)
         {
            objectBase.removeChildAt(0);
         }
         var _loc2_:int = 0;
         while(_loc2_ < this.m_objectLayers.length)
         {
            objectBase.addChild(this.m_objectLayers[_loc2_].getDisplayObject());
            _loc2_++;
         }
      }
      
      public function removeObjectLayer(param1:ObjectLayer) : void
      {
         var _loc3_:DisplayObject = null;
         var _loc2_:int = this.m_objectLayers.indexOf(param1);
         if(_loc2_ >= 0)
         {
            this.m_objectLayers.splice(_loc2_,1);
            _loc3_ = param1.getDisplayObject();
            if(Boolean(_loc3_) && Boolean(_loc3_.parent))
            {
               _loc3_.parent.removeChild(_loc3_);
            }
         }
      }
      
      override protected function drawBackground(param1:BitmapData, param2:Boolean = true) : void
      {
         param1.fillRect(param1.rect,Config.VIEWPORT_CLEAR_COLOR);
         var _loc3_:World = World.getInstance();
         var _loc4_:TileMap = _loc3_.getTileMap();
         _loc4_.render(this);
         if(param2)
         {
            _loc3_.updateCulling();
         }
      }
      
      override protected function render(param1:Boolean = false, param2:Boolean = true) : Boolean
      {
         var _loc3_:Boolean = super.render(param1,param2);
         var _loc4_:World = World.getInstance();
         var _loc5_:Boolean = _loc4_.enableSkipCulling == false && _loc4_.skipCullingFlag == true;
         if(_loc5_)
         {
            _loc4_.skipCullingFlag = false;
         }
         if(_loc3_ || _loc5_)
         {
            _loc4_.updateCulling();
         }
         return _loc3_;
      }
      
      override public function centerViewport() : void
      {
         var _loc1_:World = World.getInstance();
         var _loc2_:TileMap = _loc1_.getTileMap();
         this.centerOnTilePos(_loc2_.getWidth() / 2,_loc2_.getHeight() / 2);
      }
      
      public function centerOnTilePos(param1:Number, param2:Number) : void
      {
         var _loc3_:Vector2 = new Vector2();
         var _loc4_:World = World.getInstance();
         var _loc5_:TileMap = _loc4_.getTileMap();
         var _loc6_:Point = IsoMath.getPixelDeltaFromTileDelta(_loc5_.getWidth(),0);
         var _loc7_:Point = IsoMath.getPixelDeltaFromTileDelta(0,_loc5_.getHeight());
         var _loc8_:Point = _loc6_.add(_loc7_);
         var _loc9_:int = param1 - _loc5_.getWidth() / 2;
         var _loc10_:int = param2 - _loc5_.getHeight() / 2;
         var _loc11_:Point = IsoMath.getPixelDeltaFromTileDelta(_loc9_,0);
         var _loc12_:Point = IsoMath.getPixelDeltaFromTileDelta(0,_loc10_);
         var _loc13_:Point = _loc11_.add(_loc12_);
         if(this.stage != null)
         {
            _loc3_.x = (this.stage.stageWidth - (_loc6_.x - _loc7_.x)) / 2 - _loc13_.x;
            _loc3_.y = (this.stage.stageHeight + _loc8_.y) / 2 - _loc13_.y;
            setScrollPosition(_loc3_);
         }
      }
   }
}

