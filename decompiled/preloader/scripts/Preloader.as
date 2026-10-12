package
{
   import Cache.Classes.ZCacheClient;
   import Cache.Interfaces.IZCache;
   import com.adobe.images.PNGEncoder;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.GradientType;
   import flash.display.Graphics;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.errors.IOError;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.IEventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.MouseEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.events.TimerEvent;
   import flash.external.ExternalInterface;
   import flash.geom.Matrix;
   import flash.net.URLRequest;
   import flash.net.URLVariables;
   import flash.system.ApplicationDomain;
   import flash.system.Capabilities;
   import flash.system.LoaderContext;
   import flash.system.Security;
   import flash.system.SecurityDomain;
   import flash.utils.ByteArray;
   import flash.utils.Timer;
   import mx.utils.Base64Encoder;
   
   public class Preloader extends MovieClip
   {
      
      private static const WAIT_ON_TRANSACTION_EVENT:* = "Wait_Transaction_Begin";
      
      public var loadBar_mc:MovieClip;
      
      public var farmImageMC:MovieClip;
      
      public var farmImageFrame_mc:MovieClip;
      
      public var loadBarBackground_mc:MovieClip;
      
      private const ALLOWED_DOMAINS:Array = [".zynga.com/",".zgncdn.com/",".farmville.com/",".farmville.zgncdn.com/","zynga1-a.akamaihd.net/","zynga2-a.akamaihd.net/","zynga3-a.akamaihd.net/","zynga4-a.akamaihd.net/"];
      
      private const ALLOWED_SECURITY_DOMAINS:Array = ["farmville-s.assets.zgncdn.com","farmville-s.assets1.zgncdn.com","farmville-s.assets2.zgncdn.com","farmville-s.assets3.zgncdn.com","farm.zgncdn.com","farm-0.zgncdn.com","farm-1.zgncdn.com","farm-2.zgncdn.com","farm-3.zgncdn.com","fv-art-00.farmville.com","fb-tc-0.farmville.com","fb-tc-1.farmville.com","fb-tc-2.farmville.com","fb-tc-3.farmville.com","static.farmville.com","static-0.farmville.com","static-1.farmville.com","static-2.farmville.com","static-3.farmville.com","static.farmville.zgncdn.com","static-0.farmville.zgncdn.com","static-1.farmville.zgncdn.com","static-2.farmville.zgncdn.com","static-3.farmville.zgncdn.com","zcache.zgncdn.com","zynga-a.akamaihd.net","zynga1-a.akamaihd.net","zynga2-a.akamaihd.net","zynga3-a.akamaihd.net","zynga4-a.akamaihd.net"];
      
      private const COUNTER_ERRORS:String = "errors";
      
      private const COUNTER_ZCACHE:String = "zcache";
      
      private const COUNTER_LOAD:String = "load";
      
      private const DEFAULT_STAGE_WIDTH:Number = 760;
      
      private const PROGRESS_BAR_WIDTH:Number = 226.5;
      
      private const PROGRESS_BAR_STAGE_1_WIDTH:Number = 113.25;
      
      private const PROGRESS_BAR_STAGE_2_WIDTH:Number = 56.625;
      
      private const PROGRESS_BAR_STAGE_3_WIDTH:Number = 56.625;
      
      private const PROGRESS_BAR_MAX_PERCENT_TEST_1:* = 0.9;
      
      private const PROGRESS_BAR_MAX_PERCENT_TEST_2:* = 0.75;
      
      private const PROGRESS_BAR_MAX_PERCENT_TEST_3:* = 0.67;
      
      private const PROGRESS_BAR_MAX_PERCENT_DEFAULT:* = 1;
      
      private const ZCACHE_SANDBOX_OFFSET_X:Number = 20;
      
      private const ZCACHE_BUTTON_OFFSET_X:Number = 0;
      
      private const ZCACHE_BUTTON_OFFSET_Y:Number = -10;
      
      private const SIM_PROGRESS_UPDATE_FREQUENCY:int = 200;
      
      private const SIM_PROGRESS_DURATION:int = 30000;
      
      private const KEY_CACHED_GAME_REV:String = "_FarmGame_/cachedRevision";
      
      private const KEY_CACHED_GAME_SWF:String = "_FarmGame_/cachedSWF";
      
      private const LOAD_SRC_NORMAL:int = 0;
      
      private const LOAD_SRC_SPLIT:int = 1;
      
      private const LOAD_SRC_ZCACHE:int = 2;
      
      private var m_variables:URLVariables;
      
      private var m_game:*;
      
      private var m_gameLoader:IEventDispatcher;
      
      private var m_gameUrl:String = "";
      
      private var m_fotd:DisplayObject;
      
      private var m_fotdLoader:Loader;
      
      private var m_fotdUrls:Array;
      
      private var m_zCache:IZCache;
      
      private var m_zCacheLoader:Loader;
      
      private var m_zCacheUrl:String;
      
      private var m_zCacheButton:DisplayObject;
      
      private var m_zCacheButtonLoader:Loader;
      
      private var m_zCacheButtonUrl:String;
      
      private var m_zCacheSandbox:DisplayObject;
      
      private var m_zCacheSandboxLoader:Loader;
      
      private var m_zCacheSandboxShowOnLoad:Boolean;
      
      private var m_zCacheSandboxUrl:String;
      
      private var m_sandboxBg:Sprite;
      
      private var m_sandboxGradient:Sprite;
      
      private var m_fotdTimer:Timer;
      
      private var m_fotdChangeTime:int;
      
      private var m_fotdSeenMap:Object;
      
      private var m_enableSplitLoad:Boolean;
      
      private var m_enableZCacheGameSWF:Boolean;
      
      private var m_gameLoadSource:int;
      
      private var m_flashDialogVisible:Boolean;
      
      private var m_preventClean:Boolean;
      
      private var m_complete:Boolean;
      
      private var m_progressBarRefactorVariant:int = 0;
      
      private var m_timer:Timer;
      
      private const GET_NAVIGATOR_INFO:String = "function() { return { appName: navigator.appName, appVersion: navigator.appVersion, userAgent: navigator.userAgent }; }".toString();
      
      private const REGEX_FIREFOX:RegExp = new RegExp("Firefox[/\\s](\\d+\\.\\d+)","g");
      
      private const REGEX_IE:RegExp = /MSIE (\d+\.\d+);/g;
      
      private const REGEX_OPERA:RegExp = new RegExp("Opera[/\\s](\\d+\\.\\d+)","g");
      
      public function Preloader()
      {
         var fvar:String = null;
         var preloaderStr:String = null;
         this.m_variables = new URLVariables();
         this.m_sandboxBg = new Sprite();
         this.m_sandboxGradient = new Sprite();
         this.m_fotdSeenMap = {};
         super();
         try
         {
            if(ExternalInterface.available)
            {
               ExternalInterface.addCallback("getPreloaderScreenshot",this.exportScreenshot);
               ExternalInterface.call("onLoadStep","preload");
            }
         }
         catch(err:Error)
         {
         }
         for(fvar in LoaderInfo(this.root.loaderInfo).parameters)
         {
            this.m_variables[fvar] = LoaderInfo(this.root.loaderInfo).parameters[fvar];
            if(fvar == "swfLocation")
            {
               if(!(true || this.validateUrl(this.m_variables[fvar],this.ALLOWED_DOMAINS)))
               {
                  throw new Error("invalid domain for game swf");
               }
               this.m_gameUrl = this.m_variables[fvar];
            }
         }
         this.m_enableSplitLoad = this.m_variables["use_splitfileloader"] == "true";
         this.m_enableZCacheGameSWF = this.m_variables["zcache_gameswf"] == "true";
         preloaderStr = this.m_variables["fotd"];
         if(preloaderStr)
         {
            this.m_fotdUrls = preloaderStr.split(";");
         }
         this.m_fotdChangeTime = this.m_variables["fotdChangeTime"] * 1000;
         this.m_zCacheUrl = this.m_variables["zcache_url"];
         this.m_zCacheButtonUrl = this.m_variables["zcache_btn_url"];
         this.m_zCacheSandboxUrl = this.m_variables["zcache_sandbox_url"];
         this.m_progressBarRefactorVariant = int(this.m_variables["progress_bar_refactor_variant"]);
         addChildAt(this.m_sandboxBg,0);
         addChild(this.m_sandboxGradient);
         this.drawBg();
         if(this.m_zCacheUrl)
         {
            this.loadZCache();
         }
         else
         {
            this.loadGame();
         }
      }
      
      public function get zCache() : IZCache
      {
         return this.m_zCache;
      }
      
      private function loadGame() : void
      {
         var cachedGame:ByteArray = null;
         var cachedRevision:String = null;
         var cached:* = undefined;
         var slash:int = 0;
         var baseName:String = null;
         var domain:String = null;
         var partsCount:int = 0;
         var splitloader:SplitFileLoader = null;
         var loader:Loader = null;
         if(!this.m_gameLoader)
         {
            cachedGame = null;
            this.m_enableZCacheGameSWF &&= this.m_zCache && this.m_zCache.allowed;
            if(this.m_enableZCacheGameSWF)
            {
               cachedRevision = this.getCachedGameRevision();
               if(cachedRevision)
               {
                  if(cachedRevision == this.extractBuildRevision(this.m_gameUrl))
                  {
                     cached = this.m_zCache.get(this.KEY_CACHED_GAME_SWF);
                     if(cached)
                     {
                        cachedGame = cached as ByteArray;
                        cachedGame.position = 0;
                     }
                     else
                     {
                        this.m_zCache.remove(this.KEY_CACHED_GAME_REV);
                     }
                  }
                  else
                  {
                     this.m_zCache.remove(this.KEY_CACHED_GAME_REV);
                     this.m_zCache.remove(this.KEY_CACHED_GAME_SWF);
                  }
               }
            }
            if(this.m_enableSplitLoad && !cachedGame)
            {
               slash = this.m_gameUrl.lastIndexOf("/") + 1;
               baseName = this.m_gameUrl.substring(slash);
               domain = this.m_gameUrl.substring(0,slash);
               partsCount = int(this.m_variables["parts_count"]);
               splitloader = new SplitFileLoader([domain]);
               splitloader.addEventListener(Event.COMPLETE,this.onGameDownloadComplete);
               this.addGameLoadListeners(splitloader);
               this.m_gameLoader = splitloader;
               this.m_gameLoadSource = this.LOAD_SRC_SPLIT;
               this.ztrackCount(this.COUNTER_LOAD,"swf_src","remote","split");
               try
               {
                  splitloader.load(baseName,partsCount,"");
               }
               catch(e:Error)
               {
                  this.ztrackCount(this.COUNTER_ERRORS,"splitloader","split name");
                  this.removeGameLoadListeners(splitloader);
               }
            }
            else
            {
               loader = new Loader();
               this.addGameLoadListeners(loader.contentLoaderInfo);
               this.m_gameLoader = loader;
               try
               {
                  if(cachedGame)
                  {
                     this.m_gameLoadSource = this.LOAD_SRC_ZCACHE;
                     this.ztrackCount(this.COUNTER_LOAD,"swf_src","zcache");
                     loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onGameCacheLoadComplete);
                     loader.loadBytes(cachedGame,new LoaderContext(false,ApplicationDomain.currentDomain,null));
                  }
                  else
                  {
                     this.m_gameLoadSource = this.LOAD_SRC_NORMAL;
                     this.ztrackCount(this.COUNTER_LOAD,"swf_src","remote");
                     loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onGameDownloadComplete);
                     loader.load(new URLRequest(this.m_gameUrl),new LoaderContext(true));
                  }
               }
               catch(ioe:IOError)
               {
                  this.removeGameLoadListeners(loader.contentLoaderInfo);
                  this.onGameLoadError();
               }
               catch(se:SecurityError)
               {
                  this.removeGameLoadListeners(loader.contentLoaderInfo);
                  this.onGameLoadError();
               }
            }
            if(this.m_fotdUrls)
            {
               this.m_fotdTimer = new Timer(this.m_fotdChangeTime);
               this.m_fotdTimer.addEventListener(TimerEvent.TIMER,this.loadFOTD);
               this.loadFOTD();
            }
         }
      }
      
      private function addGameLoadListeners(param1:IEventDispatcher) : void
      {
         param1.addEventListener(IOErrorEvent.IO_ERROR,this.onGameLoadError);
         param1.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onGameLoadError);
         param1.addEventListener(ProgressEvent.PROGRESS,this.onProgressHandler);
      }
      
      private function removeGameLoadListeners(param1:IEventDispatcher) : void
      {
         param1.removeEventListener(IOErrorEvent.IO_ERROR,this.onGameLoadError);
         param1.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onGameLoadError);
         param1.removeEventListener(ProgressEvent.PROGRESS,this.onProgressHandler);
      }
      
      private function onGameCacheLoadComplete(param1:Event) : void
      {
         param1.currentTarget.removeEventListener(Event.COMPLETE,this.onGameCacheLoadComplete);
         this.onGameLoadComplete(param1);
      }
      
      private function onGameDownloadComplete(param1:Event) : void
      {
         var _loc2_:ByteArray = null;
         param1.currentTarget.removeEventListener(Event.COMPLETE,this.onGameDownloadComplete);
         if(this.m_enableZCacheGameSWF)
         {
            _loc2_ = null;
            if(this.m_enableSplitLoad)
            {
               _loc2_ = (param1.currentTarget as SplitFileLoader).swfData;
            }
            else
            {
               _loc2_ = (param1.currentTarget as LoaderInfo).bytes;
            }
            if(_loc2_)
            {
               this.m_zCache.put(this.KEY_CACHED_GAME_REV,this.extractBuildRevision(this.m_gameUrl));
               this.m_zCache.put(this.KEY_CACHED_GAME_SWF,_loc2_);
            }
         }
         this.onGameLoadComplete(param1);
      }
      
      private function onGameLoadComplete(param1:Event) : void
      {
         if(this.inRefactorExperiment())
         {
            this.loadBar_mc.width = this.PROGRESS_BAR_STAGE_1_WIDTH;
         }
         else
         {
            this.loadBar_mc.width = this.PROGRESS_BAR_WIDTH / 2;
         }
         this.removeGameLoadListeners(param1.currentTarget as IEventDispatcher);
         if(this.inRefactorExperiment())
         {
            param1.currentTarget.content.addEventListener(WAIT_ON_TRANSACTION_EVENT,this.onSimulateProgressBegin);
         }
         param1.currentTarget.content.addEventListener(ProgressEvent.PROGRESS,this.onActionStarted);
         param1.currentTarget.content.addEventListener(Event.COMPLETE,this.onComplete);
         param1.currentTarget.content.parameters = this.m_variables;
         this.m_game = param1.currentTarget.content;
         addChildAt(this.m_game,0);
         var _loc2_:Number = (stage.stageWidth - this.DEFAULT_STAGE_WIDTH) / 2;
         this.loadBar_mc.x += _loc2_;
         this.loadBarBackground_mc.x += _loc2_;
         this.farmImageFrame_mc.x += _loc2_;
         this.farmImageMC.x += _loc2_;
         var _loc3_:Boolean = false;
         if(this.m_zCacheSandbox && this.m_zCacheSandbox.parent && this == this.m_zCacheSandbox.parent)
         {
            this.m_zCacheSandbox.x += _loc2_;
            _loc3_ = true;
         }
         this.drawBg();
         if(_loc3_)
         {
            this.drawGradient();
         }
         this.positionZCacheButton(_loc2_);
      }
      
      private function onGameLoadError(param1:ErrorEvent = null) : void
      {
         if(param1)
         {
            this.removeGameLoadListeners(param1.currentTarget as IEventDispatcher);
         }
         if(this.m_gameLoadSource == this.LOAD_SRC_ZCACHE)
         {
            this.ztrackLoadError("zcache");
            if(this.m_zCache && this.m_zCache.allowed)
            {
               this.m_zCache.remove(this.KEY_CACHED_GAME_REV);
               this.m_zCache.remove(this.KEY_CACHED_GAME_SWF);
            }
            this.m_enableZCacheGameSWF = false;
            this.m_gameLoader = null;
            this.loadGame();
         }
         else if(this.m_gameLoadSource == this.LOAD_SRC_SPLIT)
         {
            this.ztrackLoadError("split");
            this.m_enableSplitLoad = false;
            this.m_gameLoader = null;
            this.loadGame();
         }
         else
         {
            this.ztrackLoadError();
         }
      }
      
      private function onProgressHandler(param1:ProgressEvent) : void
      {
         var _loc2_:Number = 0;
         if(param1.bytesTotal > 0)
         {
            _loc2_ = param1.bytesLoaded / param1.bytesTotal;
         }
         if(this.inRefactorExperiment())
         {
            this.loadBar_mc.width = this.PROGRESS_BAR_STAGE_1_WIDTH * _loc2_;
         }
         else
         {
            this.loadBar_mc.width = this.PROGRESS_BAR_WIDTH * _loc2_ / 2;
         }
      }
      
      private function onActionStarted(param1:ProgressEvent) : void
      {
         if(param1.bytesTotal > 0)
         {
            if(this.inRefactorExperiment())
            {
               this.loadBar_mc.width = this.PROGRESS_BAR_STAGE_1_WIDTH + this.PROGRESS_BAR_STAGE_2_WIDTH * (param1.bytesLoaded / param1.bytesTotal) * this.maxBarWidthPercent;
            }
            else
            {
               this.loadBar_mc.width = this.PROGRESS_BAR_WIDTH / 2 + this.PROGRESS_BAR_WIDTH / 2 * (param1.bytesLoaded / param1.bytesTotal);
            }
         }
         if(param1.bytesLoaded >= param1.bytesTotal)
         {
            removeChild(this.loadBar_mc);
            removeChild(this.loadBarBackground_mc);
         }
      }
      
      private function onSimulateProgressBegin(param1:Event) : void
      {
         param1.currentTarget.removeEventListener(WAIT_ON_TRANSACTION_EVENT,this.onSimulateProgressBegin);
         this.m_timer = new Timer(this.SIM_PROGRESS_UPDATE_FREQUENCY);
         this.m_timer.addEventListener(TimerEvent.TIMER,this.onSimulateProgressUpdate);
         this.m_timer.start();
      }
      
      private function onSimulateProgressUpdate(param1:TimerEvent) : void
      {
         var _loc2_:int = this.SIM_PROGRESS_DURATION / this.SIM_PROGRESS_UPDATE_FREQUENCY;
         if(param1.target.currentCount < _loc2_)
         {
            this.loadBar_mc.width = this.PROGRESS_BAR_STAGE_1_WIDTH + (this.PROGRESS_BAR_STAGE_2_WIDTH + this.easeOut(param1.target.currentCount,this.PROGRESS_BAR_STAGE_3_WIDTH,_loc2_)) * this.maxBarWidthPercent;
         }
      }
      
      private function easeOut(param1:Number, param2:Number, param3:Number) : Number
      {
         return (0 - param2) * (param1 /= param3) * (param1 - 2);
      }
      
      private function inRefactorExperiment() : Boolean
      {
         return this.m_progressBarRefactorVariant > 1 && this.m_progressBarRefactorVariant != 5;
      }
      
      private function get maxBarWidthPercent() : Number
      {
         /*
          * Decompilation error
          * Code may be obfuscated
          * Tip: You can try enabling "Deobfuscate code" option in Settings
          * Error type: IndexOutOfBoundsException (Index 97 out of bounds for length 97)
          */
         throw new flash.errors.IllegalOperationError("Not decompiled due to error");
      }
      
      private function cleanupSimulateProgress() : void
      {
         if(this.m_timer && this.m_timer.hasEventListener(TimerEvent.TIMER))
         {
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.onSimulateProgressUpdate);
         }
         this.m_timer = null;
      }
      
      private function onComplete(param1:Event) : void
      {
         this.cleanupSimulateProgress();
         this.m_complete = true;
         this.cleanupAll();
      }
      
      private function cleanupAll() : void
      {
         if(!this.m_preventClean)
         {
            this.cleanupFOTD();
            this.cleanupPreloader();
            this.cleanupZCache();
            this.m_game.preloadComplete();
         }
      }
      
      public function cleanupPreloader() : void
      {
         if(this.farmImageFrame_mc)
         {
            if(this.farmImageFrame_mc.parent)
            {
               this.farmImageFrame_mc.parent.removeChild(this.farmImageFrame_mc);
            }
            this.farmImageFrame_mc = null;
         }
         if(this.farmImageMC)
         {
            if(this.farmImageMC.parent)
            {
               this.farmImageMC.parent.removeChild(this.farmImageMC);
            }
            this.farmImageMC = null;
         }
         if(this.m_sandboxBg)
         {
            if(this.m_sandboxBg.parent)
            {
               this.m_sandboxBg.parent.removeChild(this.m_sandboxBg);
            }
            this.m_sandboxBg = null;
         }
      }
      
      private function validateUrl(param1:String, param2:Array) : Boolean
      {
         var _loc5_:int = 0;
         var _loc3_:int = param1.indexOf("://");
         var _loc4_:Boolean = false;
         if(_loc3_ <= 6 && param1.indexOf("http") == 0)
         {
            param1 = param1.substr(_loc3_ + 3);
            param1 = param1.substr(0,param1.indexOf("/") + 1);
            param1 = param1.toLowerCase();
            _loc5_ = 0;
            while(_loc5_ < param2.length)
            {
               _loc3_ = param1.indexOf(param2[_loc5_]);
               if(_loc3_ >= 0 && _loc3_ == param1.length - (param2[_loc5_] as String).length)
               {
                  _loc4_ = true;
                  break;
               }
               _loc5_++;
            }
         }
         return _loc4_;
      }
      
      private function loadFOTD(param1:Event = null) : void
      {
         var context:LoaderContext = null;
         var ind:int = 0;
         var numTries:int = 0;
         var event:Event = param1;
         if(!this.m_fotdLoader)
         {
            this.m_fotdLoader = new Loader();
         }
         this.addFOTDListeners();
         try
         {
            context = new LoaderContext(true,ApplicationDomain.currentDomain,SecurityDomain.currentDomain);
            ind = 0;
            numTries = 0;
            if(this.m_fotdUrls.length != 1)
            {
               while(this.m_fotdSeenMap[ind.toString()] && numTries < 100)
               {
                  ind = Math.random() * this.m_fotdUrls.length;
                  numTries++;
               }
            }
            this.m_fotdSeenMap[ind.toString()] = 1;
            this.m_fotdTimer.stop();
            this.resetOnAllFotdSeen();
            this.m_fotdLoader.load(new URLRequest(this.m_fotdUrls[ind]),context);
            return;
         }
         catch(e:Error)
         {
            this.ztrackCount(this.COUNTER_ERRORS,"load","fotd");
            this.removeFOTDListeners();
            return;
         }
      }
      
      private function addFOTDListeners() : void
      {
         this.m_fotdLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onFOTDLoaded);
         this.m_fotdLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onFOTDError);
         this.m_fotdLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onFOTDError);
      }
      
      private function removeFOTDListeners() : void
      {
         if(this.m_fotdLoader != null && this.m_fotdLoader.hasOwnProperty("contentLoaderInfo") && this.m_fotdLoader.contentLoaderInfo != null)
         {
            this.m_fotdLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.onFOTDLoaded);
            this.m_fotdLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,this.onFOTDError);
            this.m_fotdLoader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onFOTDError);
         }
      }
      
      private function onFOTDLoaded(param1:Event) : void
      {
         if(this.m_fotdLoader != null)
         {
            this.removeFOTDListeners();
            if(this.m_fotd && this.m_fotd.parent != null)
            {
               this.m_fotd.parent.removeChild(this.m_fotd);
            }
            this.m_fotd = this.m_fotdLoader.content as DisplayObject;
            if(!(this.m_fotdLoader.content is MovieClip))
            {
               this.m_fotd.width = this.farmImageMC.width;
               this.m_fotd.height = this.farmImageMC.height;
            }
            this.farmImageMC.addChild(this.m_fotd);
            if(this.m_fotdUrls.length != 1)
            {
               this.m_fotdTimer.start();
            }
         }
      }
      
      private function onFOTDError(param1:ErrorEvent) : void
      {
         this.removeFOTDListeners();
         this.ztrackCount(this.COUNTER_ERRORS,"load","fotd");
      }
      
      private function cleanupFOTD() : void
      {
         if(this.m_fotd)
         {
            if(this.m_fotd.parent)
            {
               this.m_fotd.parent.removeChild(this.m_fotd);
            }
            this.m_fotd = null;
         }
         if(this.m_fotdLoader)
         {
            this.m_fotdLoader.unload();
            this.m_fotdLoader = null;
         }
         if(this.m_fotdTimer)
         {
            this.m_fotdTimer.stop();
            this.m_fotdTimer.removeEventListener(TimerEvent.TIMER,this.loadFOTD);
            this.m_fotdTimer = null;
         }
      }
      
      private function resetOnAllFotdSeen() : void
      {
         var _loc1_:Boolean = true;
         var _loc2_:int = 0;
         while(_loc2_ < this.m_fotdUrls.length)
         {
            if(!this.m_fotdSeenMap[_loc2_.toString()])
            {
               _loc1_ = false;
               break;
            }
            _loc2_++;
         }
         if(_loc1_)
         {
            this.m_fotdSeenMap = {};
         }
      }
      
      private function loadZCache() : void
      {
         if(this.m_zCacheLoader)
         {
            return;
         }
         this.m_zCacheLoader = new Loader();
         this.m_zCacheLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onZCacheLoaded);
         this.m_zCacheLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onZCacheError);
         this.m_zCacheLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onZCacheError);
         try
         {
            this.m_zCacheLoader.load(new URLRequest(this.m_zCacheUrl),new LoaderContext());
            return;
         }
         catch(e:Error)
         {
            this.ztrackCount(this.COUNTER_ERRORS,"zcache","load");
            this.removeZCacheListeners();
            return;
         }
      }
      
      private function removeZCacheListeners() : void
      {
         this.m_zCacheLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.onZCacheLoaded);
         this.m_zCacheLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,this.onZCacheError);
         this.m_zCacheLoader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onZCacheError);
      }
      
      private function onZCacheLoaded(param1:Event) : void
      {
         this.removeZCacheListeners();
         if(this.m_zCacheLoader.contentLoaderInfo.childAllowsParent)
         {
            this.m_zCache = new ZCacheClient(this.m_zCacheLoader.content);
            if(this.m_zCache.init("farm"))
            {
               if(!this.m_zCache.allowed)
               {
                  if(this.isZCacheCompatible())
                  {
                     this.loadZCacheButton();
                     this.preloadZCacheAssets();
                  }
                  else
                  {
                     this.ztrackCount(this.COUNTER_ZCACHE,"loading_button","suppressed");
                  }
               }
            }
            else
            {
               this.ztrackCount(this.COUNTER_ERRORS,"zcache","init");
            }
         }
         this.loadGame();
      }
      
      private function onZCacheError(param1:ErrorEvent) : void
      {
         this.removeZCacheListeners();
         this.ztrackCount(this.COUNTER_ERRORS,"zcache","load");
         this.loadGame();
      }
      
      private function loadZCacheButton() : void
      {
         var context:LoaderContext = null;
         if(!(this.m_zCacheButtonUrl && !this.m_zCacheButtonLoader))
         {
            return;
         }
         this.m_zCacheButtonLoader = new Loader();
         this.m_zCacheButtonLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onZCacheButtonLoaded);
         this.m_zCacheButtonLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onZCacheButtonError);
         this.m_zCacheButtonLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onZCacheButtonError);
         context = new LoaderContext(true,ApplicationDomain.currentDomain);
         if(Security.sandboxType == Security.REMOTE)
         {
            context.securityDomain = SecurityDomain.currentDomain;
         }
         try
         {
            this.m_zCacheButtonLoader.load(new URLRequest(this.m_zCacheButtonUrl),context);
            return;
         }
         catch(e:Error)
         {
            this.ztrackCount(this.COUNTER_ERRORS,"zcache","load_button");
            this.removeZCacheButtonListeners();
            return;
         }
      }
      
      private function removeZCacheButtonListeners() : void
      {
         this.m_zCacheButtonLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.onZCacheButtonLoaded);
         this.m_zCacheButtonLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,this.onZCacheButtonError);
         this.m_zCacheButtonLoader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onZCacheButtonError);
      }
      
      private function onZCacheButtonLoaded(param1:Event) : void
      {
         this.removeZCacheButtonListeners();
         this.m_zCacheButton = this.m_zCacheButtonLoader.content as DisplayObject;
         this.m_zCacheButton.addEventListener(MouseEvent.CLICK,this.onZCacheButtonClick);
         addChild(this.m_zCacheButton);
         this.positionZCacheButton();
         this.ztrackCount(this.COUNTER_ZCACHE,"loading_button","shown");
      }
      
      private function onZCacheButtonError(param1:ErrorEvent) : void
      {
         this.removeZCacheButtonListeners();
         this.ztrackCount(this.COUNTER_ERRORS,"zcache","load_button");
      }
      
      private function positionZCacheButton(param1:Number = 0) : void
      {
         if(this.m_zCacheButton)
         {
            this.m_zCacheButton.x = stage.stageWidth - this.m_zCacheButton.width + this.ZCACHE_BUTTON_OFFSET_X - param1;
            this.m_zCacheButton.y = stage.stageHeight - this.m_zCacheButton.height + this.ZCACHE_BUTTON_OFFSET_Y;
         }
      }
      
      private function removeZCacheButton() : void
      {
         if(this.m_zCacheButton)
         {
            this.m_zCacheButton.removeEventListener(MouseEvent.CLICK,this.onZCacheButtonClick);
            if(this.m_zCacheButton.parent)
            {
               this.m_zCacheButton.parent.removeChild(this.m_zCacheButton);
            }
            this.m_zCacheButton = null;
         }
      }
      
      private function preloadZCacheAssets() : void
      {
         this.loadZCacheSandbox();
      }
      
      public function onZCacheButtonClick(param1:Event) : *
      {
         this.ztrackCount(this.COUNTER_ZCACHE,"loading_button","clicked");
         this.removeZCacheButton();
         this.m_preventClean = true;
         this.showZCacheSandbox();
      }
      
      private function loadZCacheSandbox(param1:Boolean = false) : void
      {
         var context:LoaderContext = null;
         var showOnLoad:Boolean = param1;
         this.m_zCacheSandboxShowOnLoad = showOnLoad;
         if(!(this.m_zCacheSandboxUrl && !this.m_zCacheSandboxLoader))
         {
            return;
         }
         this.m_zCacheSandboxLoader = new Loader();
         this.m_zCacheSandboxLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onZCacheSandboxLoaded);
         this.m_zCacheSandboxLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onZCacheSandboxError);
         this.m_zCacheSandboxLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onZCacheSandboxError);
         context = new LoaderContext(true,ApplicationDomain.currentDomain);
         if(Security.sandboxType == Security.REMOTE)
         {
            context.securityDomain = SecurityDomain.currentDomain;
         }
         try
         {
            this.m_zCacheSandboxLoader.load(new URLRequest(this.m_zCacheSandboxUrl),context);
            return;
         }
         catch(e:Error)
         {
            this.ztrackCount(this.COUNTER_ERRORS,"zcache","load_sandbox");
            this.removeZCacheSandboxListeners();
            return;
         }
      }
      
      private function removeZCacheSandboxListeners() : void
      {
         this.m_zCacheSandboxLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.onZCacheSandboxLoaded);
         this.m_zCacheSandboxLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,this.onZCacheSandboxError);
         this.m_zCacheSandboxLoader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onZCacheSandboxError);
      }
      
      private function onZCacheSandboxLoaded(param1:Event) : void
      {
         this.removeZCacheSandboxListeners();
         this.m_zCacheSandbox = this.m_zCacheSandboxLoader.content as DisplayObject;
         if(this.m_zCacheSandboxShowOnLoad)
         {
            this.showZCacheSandbox();
         }
      }
      
      private function onZCacheSandboxError(param1:ErrorEvent) : void
      {
         this.removeZCacheSandboxListeners();
         this.ztrackCount(this.COUNTER_ERRORS,"zcache","load_sandbox");
      }
      
      private function showZCacheSandbox() : void
      {
         if(this.m_zCacheSandbox)
         {
            this.removeZCacheButton();
            this.m_zCacheSandbox.x = stage.stageWidth / 2 - this.m_zCacheSandbox.width / 2 + this.ZCACHE_SANDBOX_OFFSET_X;
            this.m_zCacheSandbox.y = stage.stageHeight / 2 - this.m_zCacheSandbox.height / 2;
            addChild(this.m_zCacheSandbox);
            this.drawGradient();
            this.m_flashDialogVisible = true;
            this.ztrackCount(this.COUNTER_ZCACHE,"flash_permission","shown");
            this.m_zCache.promptForStorage(this.onStorageAllowed,this.onStorageDenied);
         }
         else
         {
            this.loadZCacheSandbox(true);
         }
      }
      
      private function onStorageAllowed() : void
      {
         this.ztrackCount(this.COUNTER_ZCACHE,"flash_permission","allowed");
         this.onFlashPromptDismissed();
      }
      
      private function onStorageDenied() : void
      {
         this.ztrackCount(this.COUNTER_ZCACHE,"flash_permission","denied");
         this.onFlashPromptDismissed();
      }
      
      private function onFlashPromptDismissed() : void
      {
         this.removeZCacheSandbox();
         this.m_flashDialogVisible = false;
         this.m_preventClean = false;
         if(this.m_complete)
         {
            this.cleanupAll();
         }
      }
      
      private function removeZCacheSandbox() : void
      {
         if(this.m_zCacheSandbox)
         {
            if(this.m_zCacheSandbox.parent && this.m_zCacheSandbox.parent != this.m_zCacheSandboxLoader)
            {
               this.m_zCacheSandbox.parent.removeChild(this.m_zCacheSandbox);
            }
            this.m_zCacheSandbox = null;
         }
         if(this.m_zCacheSandboxLoader)
         {
            this.m_zCacheSandboxLoader.unload();
            this.m_zCacheSandboxLoader = null;
         }
         if(this.m_sandboxGradient)
         {
            this.m_sandboxGradient.graphics.clear();
            if(this.m_sandboxGradient.parent)
            {
               this.m_sandboxGradient.parent.removeChild(this.m_sandboxGradient);
            }
            this.m_sandboxGradient = null;
         }
      }
      
      private function cleanupZCache() : void
      {
         this.removeZCacheButton();
         this.removeZCacheSandbox();
         if(this.m_zCacheLoader)
         {
            this.m_zCacheLoader.unload();
            this.m_zCacheLoader = null;
         }
         this.m_zCache = null;
      }
      
      private function extractBuildRevision(param1:String) : String
      {
         param1 = param1.substring(param1.indexOf("FarmGame") + "FarmGame".length);
         param1 = param1.substring(0,param1.indexOf(".swf"));
         if(param1.indexOf(".") == 0)
         {
            param1 = param1.substring(1);
         }
         return param1;
      }
      
      private function getCachedGameRevision() : String
      {
         var _loc2_:ByteArray = null;
         var _loc1_:String = null;
         if(this.m_zCache && this.m_zCache.allowed)
         {
            _loc2_ = this.m_zCache.get(this.KEY_CACHED_GAME_REV);
            if(_loc2_)
            {
               _loc2_.position = 0;
               _loc1_ = _loc2_.readObject() as String;
            }
         }
         return _loc1_;
      }
      
      private function isZCacheCompatible() : Boolean
      {
         var _loc5_:String = null;
         var _loc1_:Boolean = true;
         var _loc2_:String = Capabilities.os;
         var _loc3_:String = Capabilities.playerType;
         var _loc4_:* = _loc2_.indexOf("Mac OS") == 0;
         if(_loc4_)
         {
            _loc5_ = _loc2_.substring("Mac OS".length);
         }
         var _loc6_:Object = null;
         if(_loc3_ == "ActiveX" || _loc3_ == "PlugIn")
         {
            _loc6_ = this.getBrowserInfo();
            if(_loc6_)
            {
               if(_loc4_ && this.isFirefox(_loc6_))
               {
                  _loc1_ = false;
               }
            }
         }
         return _loc1_;
      }
      
      private function getBrowserInfo() : Object
      {
         var info:Object = null;
         try
         {
            if(ExternalInterface.available)
            {
               info = ExternalInterface.call(this.GET_NAVIGATOR_INFO);
            }
         }
         catch(e:Error)
         {
         }
         return info;
      }
      
      private function isFirefox(param1:Object) : Boolean
      {
         return this.REGEX_FIREFOX.test(param1.userAgent);
      }
      
      private function ztrackCount(param1:String, param2:String, param3:String, param4:String = "") : void
      {
         var counter:String = param1;
         var kingdom:String = param2;
         var phylum:String = param3;
         var zclass:String = param4;
         try
         {
            if(ExternalInterface.available)
            {
               ExternalInterface.call("ztrackCount",counter,kingdom,phylum,zclass);
            }
            return;
         }
         catch(e:Error)
         {
            return;
         }
      }
      
      private function ztrackLoadError(param1:String = "") : void
      {
         this.ztrackCount(this.COUNTER_ERRORS,"gameload",param1);
      }
      
      private function drawBg() : void
      {
         var _loc1_:Graphics = this.m_sandboxBg.graphics;
         _loc1_.clear();
         _loc1_.beginFill(16777215,1);
         _loc1_.drawRect(0,0,stage.stageWidth,stage.stageHeight);
         _loc1_.endFill();
         this.m_sandboxBg.width = stage.stageWidth;
         this.m_sandboxBg.height = stage.stageHeight;
      }
      
      private function drawGradient() : void
      {
         var _loc1_:Matrix = new Matrix();
         _loc1_.createGradientBox(stage.stageWidth * 2,stage.stageHeight * 2,0,(0 - stage.stageWidth) / 2,(0 - stage.stageHeight) / 2);
         var _loc2_:Graphics = this.m_sandboxGradient.graphics;
         _loc2_.clear();
         _loc2_.beginGradientFill(GradientType.RADIAL,[16777215,5197647],[0,1],[0,255],_loc1_);
         _loc2_.drawRect(0,0,stage.stageWidth,stage.stageHeight);
         _loc2_.endFill();
         this.m_sandboxGradient.width = stage.stageWidth;
         this.m_sandboxGradient.height = stage.stageHeight;
      }
      
      public function exportScreenshot() : String
      {
         var _loc5_:Base64Encoder = null;
         var _loc6_:String = null;
         var _loc1_:String = null;
         var _loc2_:BitmapData = new BitmapData(stage.stageWidth,stage.stageHeight,false,0);
         _loc2_.draw(stage);
         var _loc3_:Shape = new Shape();
         _loc3_.graphics.beginFill(0,0.3);
         _loc3_.graphics.drawRect(0,0,stage.stageWidth,stage.stageHeight);
         _loc3_.graphics.endFill();
         _loc2_.draw(_loc3_);
         var _loc4_:ByteArray = PNGEncoder.encode(_loc2_);
         if(_loc4_)
         {
            _loc5_ = new Base64Encoder();
            _loc5_.encodeBytes(_loc4_);
            _loc6_ = _loc5_.toString();
            if(_loc6_)
            {
               _loc1_ = _loc6_;
            }
         }
         return _loc1_;
      }
   }
}

