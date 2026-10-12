package Classes.DisplayLoading
{
   import Classes.Constants.Experiments;
   import Classes.ItemImage;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.FarmItemImageData;
   import Classes.util.FarmGameUtil;
   import Engine.Classes.URLResourceLoader;
   import Engine.Events.LoaderEvent;
   import Engine.Helpers.Vector2;
   import Engine.IsoMath;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.StatsManager;
   import Managers.PerformanceExperimentManager;
   import com.urbansquall.ginger.Animation;
   import com.urbansquall.ginger.AnimationPlayer;
   import com.urbansquall.ginger.tools.AnimationBuilder;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.display.MovieClip;
   import flash.display.StageQuality;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import flash.media.SoundTransform;
   import flash.net.URLLoader;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   
   public class MapResourceDL extends EventDispatcher
   {
      
      private static var m_loadedUrls:Array = [];
      
      private var m_cachedImages:Array = [];
      
      private var m_addedToLoadQueue:Boolean = false;
      
      private var m_needsLoading:Boolean = false;
      
      private var m_shouldUseAnimation:Boolean = false;
      
      private var m_instanceCount:int = 0;
      
      private var m_imageData:FarmItemImageData;
      
      private var m_boxWidth:int;
      
      private var m_item:FarmItem;
      
      public function MapResourceDL(item:FarmItem)
      {
         super();
         this.m_item = item;
         this.m_imageData = this.m_item.getImageData();
         var deltaX:Vector2 = IsoMath.getPixelDeltaFromTileDelta(this.m_item.sizeX,0);
         var deltaY:Vector2 = IsoMath.getPixelDeltaFromTileDelta(0,this.m_item.sizeY);
         this.m_boxWidth = Math.abs(deltaX.x - deltaY.x);
         if(this.m_boxWidth == 0)
         {
            this.m_boxWidth = 100;
            GlobalEngine.log("MapResourceDL","Warning, item has bad sizeX and sizeY");
         }
         var length:int = int((this.m_imageData.images as Array).length);
         this.m_cachedImages = this.m_imageData.images;
         this.m_imageData.images = null;
         for(var imgIdx:int = 0; imgIdx < length; imgIdx++)
         {
            this.m_cachedImages[imgIdx].lowResBitmapData = null;
            this.m_cachedImages[imgIdx].loader = null;
            this.m_cachedImages[imgIdx].loaded = false;
         }
      }
      
      public static function makeAnimation(disp:MovieClip, actualScale:Number, image:Object) : Animation
      {
         var currentQuality:String = null;
         var oldScale:Vector2 = null;
         var result:Animation = null;
         if(PerformanceExperimentManager.isInAnimationMemoryExperiment)
         {
            result = new Animation(image,30,1,disp,actualScale,getQualifiedClassName(disp));
            result.isLooping = true;
            result.start();
            DLManager.registerAnimation(result);
         }
         else
         {
            currentQuality = Global.stage.quality;
            Global.stage.quality = StageQuality.HIGH;
            oldScale = new Vector2(disp.scaleX,disp.scaleY);
            disp.scaleX = actualScale;
            disp.scaleY = actualScale;
            if(PerformanceExperimentManager.isInRasterMetadataExperiment)
            {
               result = AnimationBuilder.importDisplayObject(disp,30,image);
            }
            else
            {
               result = AnimationBuilder.importDisplayObject(disp,60,null);
            }
            result.isLooping = true;
            disp.scaleX = oldScale.x;
            disp.scaleY = oldScale.y;
            Global.stage.quality = currentQuality;
         }
         return result;
      }
      
      public function incrementInstanceCount() : void
      {
         ++this.m_instanceCount;
         var redrawObjects:Boolean = false;
         if(!this.m_shouldUseAnimation && DLManager.hasLoadingBegun)
         {
            this.m_shouldUseAnimation = DLManager.shouldUseAnimation(this);
            if(this.m_shouldUseAnimation)
            {
               redrawObjects = this.convertCachedMoviesToAnimations();
            }
            if(redrawObjects)
            {
               Global.world.switchRenderSystemByType(this.m_item.code);
            }
         }
      }
      
      public function decrementInstanceCount() : void
      {
         --this.m_instanceCount;
      }
      
      public function getInstanceCount() : int
      {
         return this.m_instanceCount;
      }
      
      public function cleanup() : void
      {
         var asset:Object = null;
         var image:Object = null;
         for each(asset in m_loadedUrls)
         {
            if(asset.loader)
            {
               if(asset.loader is Loader)
               {
                  asset.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.onImageLoaded);
               }
               else if(asset.loader is URLLoader)
               {
                  asset.loader.removeEventListener(Event.COMPLETE,this.onUrlImageLoaded);
               }
               asset.loader = null;
            }
         }
         for each(image in this.m_cachedImages)
         {
            if(Boolean(image.bitmapData) && image.bitmapData is BitmapData)
            {
               (image.bitmapData as BitmapData).dispose();
            }
            if(Boolean(image.lowResBitmapData) && image.lowResBitmapData is BitmapData)
            {
               (image.lowResBitmapData as BitmapData).dispose();
            }
         }
      }
      
      public function getImageByName(imageName:String, disallowAltAnimation:Boolean = false, label:String = null) : ItemImage
      {
         var result:ItemImage = null;
         for(var imgIdx:int = 0; imgIdx < this.m_cachedImages.length; imgIdx++)
         {
            if(this.m_cachedImages[imgIdx].name == imageName)
            {
               if(label == null || this.m_cachedImages[imgIdx].label === label)
               {
                  result = this.createItemImage(imgIdx,disallowAltAnimation);
                  break;
               }
            }
         }
         return result;
      }
      
      public function getImageStatusByIndex(index:int) : Boolean
      {
         return this.m_cachedImages[index].loaded;
      }
      
      public function hasImageNameDefined(imageName:String) : Boolean
      {
         var imgIdx:int = 0;
         var result:Boolean = false;
         if(this.m_item)
         {
            for(imgIdx = 0; imgIdx < this.m_cachedImages.length; imgIdx++)
            {
               if(this.m_cachedImages[imgIdx].name == imageName)
               {
                  result = true;
                  break;
               }
            }
         }
         return result;
      }
      
      private function createItemImage(imgIdx:int, disallowAltAnimation:Boolean = false) : ItemImage
      {
         var result:ItemImage = null;
         var usingAltAnimation:Boolean = false;
         var animation:Animation = null;
         var converted:Boolean = false;
         var loader:Loader = null;
         var image:Object = this.m_cachedImages[imgIdx];
         result = null;
         if(!image.loaded)
         {
            this.requestImage(image);
         }
         else if(image.loader != null || Boolean(image.loaded))
         {
            result = new ItemImage();
            if(image.trackAnimation)
            {
               result.trackAnimation = image.trackAnimation == "true";
            }
            if(image.pixelPerfectPick)
            {
               result.pixelPerfectPick = image.pixelPerfectPick == "true";
            }
            if(PerformanceExperimentManager.isInAnimationMemoryExperiment)
            {
               animation = image.animation as Animation;
               if(Boolean(animation) && animation.isDisposed)
               {
                  if(!DLManager.shouldMakeAnimations())
                  {
                     image.animation = null;
                  }
               }
            }
            usingAltAnimation = !disallowAltAnimation && image.animation != null;
            if(image.bitmapData != null)
            {
               result.image = new Bitmap(image.bitmapData);
            }
            else if(image.contentClass != null && !usingAltAnimation)
            {
               converted = false;
               if(!disallowAltAnimation && this.m_shouldUseAnimation)
               {
                  converted = this.convertCachedMovieToAnimation(imgIdx);
               }
               if(disallowAltAnimation || !converted && image.animation == null)
               {
                  try
                  {
                     result.image = new image.contentClass();
                  }
                  catch(error:Error)
                  {
                     GlobalEngine.log("itemLoading","Error creating movie clip");
                     result.image = null;
                  }
                  if(result.image != null && result.image is MovieClip)
                  {
                     this.setupMovieClip(result.image as MovieClip,image);
                  }
               }
            }
            else if(Boolean(image.loaded) && Boolean(image.content) && Boolean(image.clipFromBytes))
            {
               if(image.firstContent != null)
               {
                  result.image = image.firstContent;
                  image.firstContent = null;
               }
               else
               {
                  loader = new Loader();
                  loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onLoadBytesError);
                  loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onLoadBytesError);
                  loader.loadBytes(image.content);
                  result.image = loader;
               }
            }
            if(!disallowAltAnimation)
            {
               if(image.animation)
               {
                  result.image = this.makeAnimationPlayer(image);
               }
            }
            if(result)
            {
               if(result.image == null)
               {
                  result = null;
               }
               else
               {
                  if(image.forceScale != null && image.forceScale > 0)
                  {
                     result.forceScale = image.forceScale;
                  }
                  if(image.lowResBitmapData)
                  {
                     result.lowResImage = image.lowResBitmapData;
                  }
                  if(image.lowResImageDisplacement)
                  {
                     result.lowResImageDisplacement = image.lowResImageDisplacement;
                  }
                  result.boxWidth = this.m_boxWidth;
               }
            }
         }
         return result;
      }
      
      private function makeAnimationPlayer(image:Object) : AnimationPlayer
      {
         image.forceScale = null;
         var aPlayer:AnimationPlayer = new AnimationPlayer();
         aPlayer.addAnimation("default",image.animation);
         aPlayer.play("default");
         return aPlayer;
      }
      
      private function setupMovieClip(mc:MovieClip, image:Object) : void
      {
         var actualScale:Number = NaN;
         if(Boolean(mc) && mc.width > 0)
         {
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_TILE_MEMORY_REDUCTION) > 0 && this.isTileAsset(this.m_item))
            {
               image.forceScale = Global.flashHotParams.hasOwnProperty("TILE_ASSET_SCALE") ? Number(Global.flashHotParams["TILE_ASSET_SCALE"]) : 0.5;
            }
            else if(null == image.forceScale)
            {
               actualScale = this.getAssetScale(mc.width,image);
               image.forceScale = actualScale;
            }
            mc.scaleX = mc.scaleY = image.forceScale;
            if(image.lowResBitmapData == null)
            {
               image.lowResBitmapData = this.createBitmapDataFromMovieClip(mc,image);
            }
         }
      }
      
      private function isTileAsset(item:FarmItem) : Boolean
      {
         var result:Boolean = false;
         switch(item.className)
         {
            case "MultiRewardTreasureConstructionBuilding":
            case "MultiRewardTreasurePayerConstructionBuilding":
            case "MultiRewardTreasurePayerBundleConstructionBuilding":
            case "MultiRewardTreasurePayerLandBundleConstructionBuilding":
            case "LandBundleUnlockFeatureTreasureConstructionBuilding":
               result = true;
               break;
            default:
               result = false;
         }
         return result;
      }
      
      private function createBitmapDataFromMovieClip(mc:MovieClip, image:Object) : BitmapData
      {
         var bitmapData:BitmapData = null;
         var errorMessage:String = null;
         var currentQuality:String = null;
         var animation:MovieClip = null;
         var displacement:Vector2 = null;
         var rect:Rectangle = null;
         var transMatrix:Matrix = null;
         var mcStartFrame:int = -1;
         if(Boolean(image.lowResBitmapFrame) && image.lowResBitmapFrame is int)
         {
            mcStartFrame = mc.currentFrame;
            mc.gotoAndStop(image.lowResBitmapFrame);
         }
         try
         {
            bitmapData = new BitmapData(mc.width,mc.height,true,0);
         }
         catch(e:ArgumentError)
         {
            errorMessage = e.message;
            errorMessage += ",source=MapResourceDL.createBitmapDataFromMovieClip";
            errorMessage += ",image.url=" + image.url;
            errorMessage += ",mc.name=" + mc.name;
            errorMessage += ",mc.width=" + mc.width;
            errorMessage += ",mc.height=" + mc.height;
            FarmGameUtil.reportClientLog(errorMessage);
         }
         if(bitmapData)
         {
            currentQuality = Global.stage.quality;
            Global.stage.quality = StageQuality.HIGH;
            animation = mc.getChildAt(0) as MovieClip;
            if(animation)
            {
               animation.gotoAndStop(0);
            }
            displacement = new Vector2();
            rect = mc.getBounds(mc);
            displacement.x = rect.left * mc.scaleX;
            displacement.y = rect.top * mc.scaleY;
            transMatrix = mc.transform.matrix;
            transMatrix.tx = -displacement.x;
            transMatrix.ty = -displacement.y;
            bitmapData.draw(mc,transMatrix,null,null,null,true);
            image.lowResImageDisplacement = displacement;
            Global.stage.quality = currentQuality;
         }
         if(mcStartFrame != -1)
         {
            mc.gotoAndStop(mcStartFrame);
         }
         return bitmapData;
      }
      
      private function requestImage(image:Object) : void
      {
         if(!image.requested)
         {
            image.requested = true;
         }
         this.m_needsLoading = true;
         if(!this.m_addedToLoadQueue)
         {
            this.m_addedToLoadQueue = true;
            DLManager.addDL(this);
         }
      }
      
      private function loadImage(imgIdx:int) : void
      {
         var loader:EventDispatcher = null;
         var options:Object = null;
         var shortUrl:String = null;
         var image:Object = this.m_cachedImages[imgIdx];
         var url:String = image.url;
         var useUrlLoader:Boolean = false;
         if(image.loadClass == "" && url.indexOf(".swf") > 0)
         {
            useUrlLoader = true;
         }
         image.loadingRasterMetaData = false;
         if(PerformanceExperimentManager.isInRasterMetadataExperiment)
         {
            if(Boolean(image.rasterMetaDataUrl) && image.rasterMetaDataUrl != "")
            {
               image.loadingRasterMetaData = true;
            }
         }
         var asset:Object = this.getAssetByUrl(url);
         image.requested = true;
         image.loading = true;
         if(null == asset)
         {
            options = new Object();
            if(useUrlLoader)
            {
               options.completeCallback = this.onUrlImageLoaded;
               options.resourceLoaderClass = URLResourceLoader;
            }
            else
            {
               options.completeCallback = this.onImageLoaded;
            }
            loader = LoadingManager.loadFromUrl(url,options);
            shortUrl = this.shortenUrl(url);
            asset = {
               "loading":true,
               "loaded":false,
               "loader":loader,
               "url":url,
               "shortUrl":shortUrl,
               "content":null,
               "loadingRasterMetaData":image.loadingRasterMetaData
            };
            m_loadedUrls.push(asset);
            this.m_needsLoading = true;
         }
         else if(Boolean(asset.loading) && asset.loader is Loader)
         {
            asset.loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onImageLoaded);
         }
         else if(Boolean(asset.loading) && asset.loader is URLLoader)
         {
            asset.loader.addEventListener(Event.COMPLETE,this.onUrlImageLoaded);
         }
         else
         {
            this.handleContent(url,asset.content);
         }
      }
      
      public function loadObjects() : void
      {
         var imgIdx:int = 0;
         var image:Object = null;
         if(this.m_needsLoading)
         {
            for(imgIdx = 0; imgIdx < this.m_cachedImages.length; imgIdx++)
            {
               image = this.m_cachedImages[imgIdx];
               if(image.requested != null && true == image.requested && !image.loading)
               {
                  this.loadImage(imgIdx);
               }
            }
            this.m_needsLoading = false;
            this.m_addedToLoadQueue = false;
         }
      }
      
      private function shortenUrl(url:String) : String
      {
         var result:String = url;
         if(Boolean(result) && result.indexOf("assets/") > 0)
         {
            result = result.substr(result.indexOf("assets/"),result.length - result.indexOf("assets/"));
         }
         return result;
      }
      
      private function getAssetByUrl(url:String) : Object
      {
         return this.getArrayElementByProperty(m_loadedUrls,"shortUrl",this.shortenUrl(url));
      }
      
      private function getAssetByLoader(loader:EventDispatcher) : Object
      {
         var result:Object = null;
         if(loader != null)
         {
            result = this.getArrayElementByProperty(m_loadedUrls,"loader",loader);
         }
         return result;
      }
      
      private function getArrayElementByProperty(array:Array, prop:String, value:*) : Object
      {
         var obj:Object = null;
         var result:Object = null;
         for each(obj in array)
         {
            if(obj[prop] == value)
            {
               result = obj;
               break;
            }
         }
         return result;
      }
      
      private function onUrlImageLoaded(event:Event, data:* = null) : void
      {
         var image:Object = null;
         var imgIdx:int = 0;
         var loader:Loader = null;
         var url:String = "";
         if(data is Object && Boolean(data.hasOwnProperty("url")))
         {
            url = data.url;
         }
         else
         {
            url = data as String;
         }
         var asset:Object = null;
         if(url != "")
         {
            asset = this.getAssetByUrl(url);
         }
         if(asset == null && event.currentTarget is URLLoader)
         {
            event.currentTarget.removeEventListener(Event.COMPLETE,this.onUrlImageLoaded);
            asset = this.getAssetByLoader(event.currentTarget as URLLoader);
         }
         if(asset)
         {
            asset.loading = false;
            image = null;
            for(imgIdx = 0; imgIdx < this.m_cachedImages.length; imgIdx++)
            {
               image = this.m_cachedImages[imgIdx];
               if(image.url == asset.url)
               {
                  image.loaded = true;
                  image.loader = null;
                  image.clipFromBytes = true;
                  image.content = asset.loader.data;
                  loader = new Loader();
                  image.contentLoader = loader;
                  loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onBytesLoaded);
                  loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onLoadBytesError);
                  loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onLoadBytesError);
                  loader.loadBytes(image.content);
               }
            }
         }
         else
         {
            GlobalEngine.log("itemLoading","rasterAsset not found [url=" + url + "]");
         }
      }
      
      private function onBytesLoaded(event:Event) : void
      {
         var image:Object = null;
         var loaderInfo:LoaderInfo = event.currentTarget as LoaderInfo;
         loaderInfo.removeEventListener(Event.COMPLETE,this.onBytesLoaded);
         var loader:Loader = loaderInfo.loader;
         for each(image in this.m_cachedImages)
         {
            if(image.contentLoader == loader)
            {
               image.contentLoader = null;
               image.firstContent = loader.content;
               if(image.firstContent is MovieClip)
               {
                  this.setupMovieClip(image.firstContent,image);
               }
            }
         }
         dispatchEvent(new LoaderEvent(LoaderEvent.LOADED));
      }
      
      private function onLoadBytesError(event:ErrorEvent) : void
      {
         FarmGameUtil.reportClientLog("MapResourceDL ErrorEvent - " + event.type + " during call to loadBytes.");
      }
      
      private function onImageLoaded(event:Event) : void
      {
         var asset:Object;
         var finalize:Boolean = false;
         var imgIdx:int = 0;
         var image:Object = null;
         var symbolClass:Class = null;
         var symbolName:String = null;
         var loaderInfo:LoaderInfo = event.currentTarget as LoaderInfo;
         var loader:Loader = loaderInfo.loader;
         loaderInfo.removeEventListener(Event.COMPLETE,this.onImageLoaded);
         this.m_addedToLoadQueue = false;
         asset = null;
         if(Boolean(loaderInfo.url) && loaderInfo.url != "")
         {
            asset = this.getAssetByUrl(loaderInfo.url);
         }
         if(asset == null)
         {
            asset = this.getAssetByLoader(loader);
         }
         if(asset)
         {
            finalize = true;
            if(asset.loadingRasterMetaData)
            {
               image = null;
               for(imgIdx = 0; imgIdx < this.m_cachedImages.length; imgIdx++)
               {
                  image = this.m_cachedImages[imgIdx];
                  if(image.url == asset.url)
                  {
                     image.loaded = true;
                     image.requested = true;
                     image.loadingRasterMetaData = false;
                     symbolName = "_res._" + this.determineClassNameForImage(image);
                     try
                     {
                        symbolClass = getDefinitionByName(symbolName) as Class;
                     }
                     catch(error:Error)
                     {
                        symbolClass = null;
                     }
                     if(symbolClass)
                     {
                        image.rasterMetaData = new symbolClass();
                     }
                     else
                     {
                        image.rasterMetaDataUrl = null;
                        image.rasterMetaData = null;
                     }
                  }
               }
            }
            if(finalize)
            {
               asset.loading = false;
               if(null == asset.content)
               {
                  asset.content = loader.content;
               }
               this.handleContent(asset.url,loader.content as DisplayObject);
            }
         }
         else
         {
            GlobalEngine.log("itemLoading","asset not found: " + loaderInfo.url);
         }
      }
      
      private function determineClassNameForImage(image:Object) : String
      {
         var tempStr:String = "";
         if(image.prefix)
         {
            tempStr = image.prefix;
         }
         else
         {
            tempStr = this.m_item.name;
         }
         var overrideName:String = this.m_item.overrideExportName;
         if(overrideName != "")
         {
            tempStr = overrideName;
         }
         var nameStr:String = tempStr.replace("_cash","");
         nameStr = nameStr.replace("_finished","");
         nameStr = nameStr.replace("_sale","");
         nameStr = nameStr.replace("_3lc","");
         return nameStr + "_" + image.name;
      }
      
      private function handleContent(url:String, content:DisplayObject) : void
      {
         var bitmapData:BitmapData = null;
         var mc:MovieClip = null;
         var st:SoundTransform = null;
         var className:String = null;
         var pathArray:Array = null;
         var errorFilename:String = null;
         var errorServer:String = null;
         var dataClass:Class = null;
         var dataObject:Object = null;
         var imgIdx:int = 0;
         var image:Object = null;
         if(content is Bitmap)
         {
            bitmapData = new BitmapData(content.width,content.height,true,0);
            bitmapData.draw(content);
            for(imgIdx = 0; imgIdx < this.m_cachedImages.length; imgIdx++)
            {
               image = this.m_cachedImages[imgIdx];
               if(image.url == url)
               {
                  image.bitmapData = bitmapData;
               }
            }
         }
         else if(content is MovieClip)
         {
            mc = content as MovieClip;
            for(imgIdx = 0; imgIdx < this.m_cachedImages.length; imgIdx++)
            {
               image = this.m_cachedImages[imgIdx];
               if(image.name == "static")
               {
                  st = new SoundTransform();
                  if(Global.player.isSfxDisabled())
                  {
                     st.volume = 0;
                  }
                  else
                  {
                     st.volume = 1;
                  }
                  mc.soundTransform = st;
               }
               if(image.url == url && image.loadClass != "" && image.requested == true)
               {
                  className = this.determineClassNameForImage(image);
                  pathArray = url.split("/");
                  errorFilename = "unknownFilename";
                  errorServer = "unknownServer";
                  if(Boolean(pathArray) && pathArray.length > 0)
                  {
                     errorFilename = pathArray[pathArray.length - 1];
                     if(pathArray.length > 2)
                     {
                        errorServer = pathArray[2];
                     }
                  }
                  if(mc.loaderInfo.applicationDomain.hasDefinition(className))
                  {
                     dataClass = mc.loaderInfo.applicationDomain.getDefinition(className) as Class;
                     if(dataClass)
                     {
                        if(image.loadClass == "mc")
                        {
                           image.contentClass = dataClass;
                        }
                        else if(image.bitmapData == null)
                        {
                           image.bitmapData = new dataClass(0,0);
                           if(image.bitmapData == null || image.bitmapData.width == 0 || image.bitmapData.height == 0)
                           {
                              ErrorManager.addError("Invalid bitmap data for class " + className + " in " + url);
                              StatsManager.sample(10,"errors","asset_missing_loadClass_1",className,errorFilename,errorServer);
                           }
                        }
                     }
                  }
                  else if(className.indexOf("frt_cycle") == -1 && className.indexOf("bk_cycle") == -1)
                  {
                     if(Config.DEBUG_MODE || Global.flashHotParams[FarmGame.FEATURE_FLASHPARAM_REPORT_SWF_EXPORT_ERRORS] > 0)
                     {
                        ErrorManager.addError("MapResourceDL: Class " + className + " not found in " + url);
                     }
                     StatsManager.sample(StatsManager.FEATURE_SAMPLE_RATE,"errors","asset_missing_loadClass_mc",className,errorFilename,errorServer);
                  }
               }
               else if(image.url == url && image.loadClass == "")
               {
                  image.content = content;
               }
            }
         }
         else
         {
            ErrorManager.addError("Unknown content class " + getQualifiedClassName(content) + " found for " + this.m_item.name + " for url: " + url);
         }
         for(imgIdx = 0; imgIdx < this.m_cachedImages.length; imgIdx++)
         {
            image = this.m_cachedImages[imgIdx];
            if(image.url == url && image.requested == true)
            {
               image.loaded = true;
               image.loader = null;
               if(image.bitmapData == null && image.contentClass == null)
               {
                  image.content = content;
               }
            }
         }
         dispatchEvent(new LoaderEvent(LoaderEvent.LOADED));
      }
      
      public function set useAnimation(shouldUse:Boolean) : void
      {
         this.m_shouldUseAnimation = shouldUse;
      }
      
      public function get canUseAnimation() : Boolean
      {
         return this.m_imageData.canUseAnimation;
      }
      
      public function get loadPriority() : Number
      {
         return this.m_instanceCount;
      }
      
      public function addImageToCache(image:Object) : void
      {
         this.m_cachedImages.push(image);
      }
      
      private function convertCachedMoviesToAnimations() : Boolean
      {
         var name:String = null;
         var result:Boolean = false;
         for(var imgIdx:int = 0; imgIdx < this.m_cachedImages.length; imgIdx++)
         {
            name = this.m_cachedImages[imgIdx].name;
            if(Boolean(name) && name.indexOf("idle") >= 0)
            {
               result ||= this.convertCachedMovieToAnimation(imgIdx);
            }
         }
         return result;
      }
      
      private function convertCachedMovieToAnimation(imgIdx:int) : Boolean
      {
         var image:Object = null;
         var content:MovieClip = null;
         var actualScale:Number = NaN;
         var result:Boolean = false;
         if(DLManager.shouldMakeAnimations())
         {
            image = this.m_cachedImages[imgIdx];
            if(null != image.contentClass)
            {
               content = new image.contentClass();
            }
            if(Boolean(content) && Boolean(content.totalFrames > 0) && image.animation == null)
            {
               content.gotoAndStop(0);
               actualScale = this.getAssetScale(content.width,image);
               this.m_cachedImages[imgIdx].animation = makeAnimation(content,actualScale,image);
               this.m_cachedImages[imgIdx].lowResBitmapData = (this.m_cachedImages[imgIdx].animation as Animation).getFrameBitmapData(0);
               this.m_cachedImages[imgIdx].forceScale = null;
               result = true;
            }
         }
         return result;
      }
      
      private function getAssetScale(contentWidth:Number, image:Object) : Number
      {
         var actualScale:Number = 2 * this.m_boxWidth / contentWidth;
         if(this.m_imageData.imageScale is Number && this.m_imageData.imageScale > 0)
         {
            actualScale *= this.m_imageData.imageScale;
         }
         return actualScale;
      }
      
      protected function processRasterMetaData(event:Event, success:Boolean) : void
      {
         var loader:URLLoader = null;
         var image:Object = null;
         var errorStr:String = null;
         if(success)
         {
            loader = URLLoader(event.target);
            for each(image in this.m_cachedImages)
            {
               if(image.rasterLoader == loader)
               {
                  break;
               }
            }
         }
         else
         {
            errorStr = (event as ErrorEvent).text;
            for each(image in this.m_cachedImages)
            {
               if(errorStr.indexOf(image.rasterMetaDataUrl) >= 0)
               {
                  loader = image.rasterLoader;
                  break;
               }
            }
         }
         loader.removeEventListener(Event.COMPLETE,this.onRasterMetaDataLoadComplete);
         loader.removeEventListener(IOErrorEvent.IO_ERROR,this.onRasterMetaDataLoadError);
         loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onRasterMetaDataLoadError);
         image.loaded = true;
         image.loadingRasterMetaData = false;
         image.rasterLoader = null;
         if(success)
         {
            image.rasterMetaData = loader.data;
         }
         else
         {
            image.rasterMetaDataUrl = null;
            image.rasterMetaData = null;
         }
         var mcLoaderInfo:LoaderInfo = image.mcLoaderInfo;
         var mcLoader:Loader = mcLoaderInfo.loader;
         image.mcLoaderInfo = null;
         var asset:Object = null;
         if(Boolean(mcLoaderInfo.url) && mcLoaderInfo.url != "")
         {
            asset = this.getAssetByUrl(mcLoaderInfo.url);
         }
         if(asset == null)
         {
            asset = this.getAssetByLoader(mcLoader);
         }
         var finishedLoad:Boolean = true;
         for each(image in this.m_cachedImages)
         {
            if(asset.url == image.url)
            {
               if(image.loadingRasterMetaData == true)
               {
                  finishedLoad = false;
                  break;
               }
            }
         }
         if(finishedLoad)
         {
            this.m_addedToLoadQueue = false;
            asset.loading = false;
            asset.loadingRasterMetaData = false;
            if(null == asset.content)
            {
               asset.content = mcLoader.content;
            }
            this.handleContent(asset.url,mcLoader.content as DisplayObject);
         }
      }
      
      protected function onRasterMetaDataLoadComplete(event:Event) : void
      {
         this.processRasterMetaData(event,true);
      }
      
      protected function onRasterMetaDataLoadError(event:ErrorEvent) : void
      {
         this.processRasterMetaData(event,false);
      }
   }
}

