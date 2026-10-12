package Classes.UserDrivenTerrain
{
   import Engine.Constants;
   import Engine.Managers.LoadingManager;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Matrix;
   
   public class UDTPaletteEntry
   {
      
      protected static const MAX_ZOOM_LEVEL:Number = 2;
      
      protected static var zoomMatrix:Matrix = new Matrix();
      
      protected var m_name:String;
      
      protected var m_code:int;
      
      protected var m_bitmapDatas:Array;
      
      protected var m_height:int;
      
      protected var m_zoomedBitmapDatas:Array;
      
      protected var m_zoomLevels:Vector.<Vector.<Number>>;
      
      protected var m_probabilities:Vector.<Vector.<int>>;
      
      protected var m_config:Object;
      
      public var isWet:Boolean = false;
      
      public var pathable:Boolean = true;
      
      public var numTypes:int = 0;
      
      protected var m_swf:MovieClip = null;
      
      protected var m_tiles:Array = [];
      
      protected var m_changedTiles:Array = [];
      
      public function UDTPaletteEntry(a_code:int)
      {
         super();
         this.m_code = a_code;
         this.m_config = UDTConfig.getConfigObject(this.m_code);
         LoadingManager.load(Global.getAssetURL(this.m_config.url),this.onTileLoaded);
         this.m_name = this.m_config.name;
         if(this.m_config.wet == true)
         {
            this.isWet = true;
         }
         if(this.m_config.pathable == false)
         {
            this.pathable = false;
         }
         this.m_height = this.m_config.height;
         this.numTypes = this.m_config.numTypes;
         this.m_bitmapDatas = new Array(this.numTypes);
         this.m_zoomedBitmapDatas = new Array(this.numTypes);
         this.m_zoomLevels = new Vector.<Vector.<Number>>(this.numTypes);
         var i:int = 0;
         var numVariants:int = 0;
         this.m_probabilities = this.m_config.probabilities;
         for(i = 0; i < this.m_bitmapDatas.length; i++)
         {
            numVariants = int((this.m_probabilities[i] as Vector.<int>).length);
            this.m_bitmapDatas[i] = new Array(numVariants);
            this.m_zoomedBitmapDatas[i] = new Array(numVariants);
            this.m_zoomLevels[i] = new Vector.<Number>(numVariants);
         }
      }
      
      protected function onTileLoaded(e:Event) : void
      {
         this.m_swf = e.target.content;
         GlobalEngine.viewport.setDirty();
         (Global.world.terrainMap as UDTMap).setDirty(true);
      }
      
      public function cleanup() : void
      {
         var i:int = 0;
         var j:int = 0;
         for(i = 0; i < this.m_bitmapDatas.length; i++)
         {
            for(j = 0; j < (this.m_bitmapDatas[i] as Array).length; j++)
            {
               if(Boolean(this.m_bitmapDatas[i][j]) && this.m_bitmapDatas[i][j] is BitmapData)
               {
                  (this.m_bitmapDatas[i][j] as BitmapData).dispose();
               }
            }
            this.m_bitmapDatas[i] = null;
         }
         this.m_bitmapDatas = null;
      }
      
      public function get name() : String
      {
         return this.m_name;
      }
      
      public function get height() : int
      {
         return this.m_height;
      }
      
      public function getTileBitmapData(type:int, key:int, zoomLevel:Number = 2) : BitmapData
      {
         var variant:int = 0;
         var t:* = undefined;
         var className:String = null;
         var imgClass:Class = null;
         var result:BitmapData = null;
         if(this.m_swf != null && type >= 0)
         {
            variant = this.getVariant(type,key);
            t = this.m_bitmapDatas[type][variant];
            if(!this.m_bitmapDatas[type][variant])
            {
               className = this.m_name + "_" + variant.toString() + "_" + type.toString();
               if(this.m_swf.loaderInfo.applicationDomain.hasDefinition(className))
               {
                  imgClass = this.m_swf.loaderInfo.applicationDomain.getDefinition(className) as Class;
                  this.m_bitmapDatas[type][variant] = new imgClass(0,0) as BitmapData;
               }
               else if(Config.DEBUG_MODE)
               {
                  GlobalEngine.error("UDT Map","Tile class not found in file. class = " + className + " url = " + this.m_config.url);
               }
            }
            if(zoomLevel != MAX_ZOOM_LEVEL)
            {
               if(this.m_zoomedBitmapDatas[type][variant] == null)
               {
                  this.m_zoomedBitmapDatas[type][variant] = new BitmapData(Constants.TILE_WIDTH * MAX_ZOOM_LEVEL,Constants.TILE_HEIGHT * MAX_ZOOM_LEVEL,true,0);
                  zoomMatrix.identity();
                  zoomMatrix.scale(zoomLevel / MAX_ZOOM_LEVEL,zoomLevel / MAX_ZOOM_LEVEL);
                  (this.m_zoomedBitmapDatas[type][variant] as BitmapData).draw(this.m_bitmapDatas[type][variant] as BitmapData,zoomMatrix);
               }
               else if(this.m_zoomLevels[type][variant] != zoomLevel)
               {
                  (this.m_zoomedBitmapDatas[type][variant] as BitmapData).fillRect((this.m_zoomedBitmapDatas[type][variant] as BitmapData).rect,0);
                  zoomMatrix.identity();
                  zoomMatrix.scale(zoomLevel / MAX_ZOOM_LEVEL,zoomLevel / MAX_ZOOM_LEVEL);
                  (this.m_zoomedBitmapDatas[type][variant] as BitmapData).draw(this.m_bitmapDatas[type][variant] as BitmapData,zoomMatrix);
                  this.m_zoomLevels[type][variant] = zoomLevel;
               }
               result = this.m_zoomedBitmapDatas[type][variant] as BitmapData;
            }
            else
            {
               result = this.m_bitmapDatas[type][variant];
            }
         }
         return result;
      }
      
      public function getVariant(type:int, key:int) : int
      {
         var index:int = 0;
         var weights:Vector.<int> = this.m_probabilities[type];
         var probability:int = key % this.m_config.pTotals[type];
         for(var length:int = int(weights.length); index < length; )
         {
            if(weights[index] >= probability)
            {
               break;
            }
            probability -= weights[index];
            index++;
         }
         return index;
      }
      
      public function addTile(index:int, isDelta:Boolean = false) : void
      {
         if(isDelta)
         {
            this.m_changedTiles.push(index);
         }
         else
         {
            this.m_tiles.push(index);
         }
      }
      
      public function getTiles(isDelta:Boolean = false) : Array
      {
         return isDelta ? this.m_changedTiles : this.m_tiles;
      }
      
      public function resetTiles() : void
      {
         this.m_changedTiles = [];
         this.m_tiles = [];
      }
   }
}

