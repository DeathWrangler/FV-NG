package Classes
{
   import Classes.DisplayLoading.DLManager;
   import Classes.DisplayLoading.MapResourceDL;
   import Classes.util.FarmGameUtil;
   import Engine.Managers.LoadingManager;
   import Managers.PerformanceExperimentManager;
   import com.urbansquall.ginger.Animation;
   import com.urbansquall.ginger.AnimationPlayer;
   import flash.display.Bitmap;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.media.SoundTransform;
   
   [Event(name="complete",type="flash.events.Event")]
   [Event(name="init",type="flash.events.Event")]
   public class ImageLoader extends EventDispatcher
   {
      
      private static const s_instanceMap:Object = new Object();
      
      private var m_url:String;
      
      private var m_content:Object;
      
      private var m_callbacks:Vector.<Function>;
      
      private var m_isLoading:Boolean;
      
      private var m_loader:Loader;
      
      private var m_useAnimation:Boolean;
      
      public function ImageLoader(access:SingletonEnforcer, url:String, useAnimation:Boolean = false)
      {
         super();
         if(access != SingletonEnforcer.instance)
         {
            throw new Error("Invalid construction of ImageLoade! Use getInstance instead.");
         }
         this.m_useAnimation = useAnimation;
         this.m_url = url;
         this.m_callbacks = new Vector.<Function>();
         if(s_instanceMap.hasOwnProperty(url))
         {
            s_instanceMap[url].push(this);
         }
         else
         {
            s_instanceMap[url] = [this];
         }
      }
      
      public static function getInstance(url:String, useAnimation:Boolean = false, useSingleton:Boolean = true) : ImageLoader
      {
         var result:ImageLoader = null;
         var cached:ImageLoader = null;
         if(useSingleton && s_instanceMap.hasOwnProperty(url))
         {
            for each(cached in s_instanceMap[url])
            {
               if(cached.m_useAnimation == useAnimation)
               {
                  result = cached;
                  break;
               }
            }
         }
         if(!result)
         {
            result = new ImageLoader(SingletonEnforcer.instance,url,useAnimation);
         }
         return result;
      }
      
      public static function clone(oldObj:Object, callback:Function, info:Object = null) : void
      {
         var loader:LoaderWithInfo = null;
         var aPlayer:AnimationPlayer = null;
         if(callback !== null)
         {
            if(oldObj is MovieClip)
            {
               if(oldObj.loaderInfo.bytes)
               {
                  loader = new LoaderWithInfo();
                  loader.info.extraInfo = info;
                  loader.info.callbackFunction = callback as Function;
                  loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onClone);
                  loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onLoadBytesError);
                  loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,onLoadBytesError);
                  loader.loadBytes(oldObj.loaderInfo.bytes);
               }
               else
               {
                  FarmGameUtil.reportClientLog("bytes was null in ImageLoader.clone(), type of oldObj=" + typeof oldObj);
               }
            }
            else if(oldObj is Bitmap)
            {
               callback(new Bitmap((oldObj as Bitmap).bitmapData));
            }
            else if(oldObj is Animation)
            {
               aPlayer = new AnimationPlayer();
               aPlayer.addAnimation("default",oldObj as Animation);
               aPlayer.play("default");
               callback(aPlayer);
            }
         }
         else
         {
            FarmGameUtil.reportClientLog("callback was null in ImageLoader.clone(), type of oldObj=" + typeof oldObj);
         }
      }
      
      public static function onClone(event:Event) : void
      {
         var a:LoaderWithInfo = event.target.loader as LoaderWithInfo;
         a.info.callbackFunction(event.target.loader.content,a.info.extraInfo);
         a.contentLoaderInfo.removeEventListener(Event.COMPLETE,onClone);
      }
      
      public static function onLoadBytesError(event:ErrorEvent) : void
      {
         FarmGameUtil.reportClientLog("ImageLoader ErrorEvent - " + event.type + " during call to loadBytes.");
      }
      
      public function get url() : String
      {
         return this.m_url;
      }
      
      public function getContent(callback:Function) : void
      {
         if(callback !== null)
         {
            if(this.m_content)
            {
               clone(this.m_content,callback);
            }
            else
            {
               this.m_callbacks.push(callback);
               if(!this.m_isLoading)
               {
                  this.m_loader = LoadingManager.load(this.m_url,this.onLoadComplete);
                  this.m_isLoading = true;
                  dispatchEvent(new Event(Event.INIT));
               }
            }
         }
         else
         {
            FarmGameUtil.reportClientLog("callback was null in ImageLoader.getContent, url=" + this.m_url);
         }
      }
      
      public function onLoadComplete(event:Event) : void
      {
         var st:SoundTransform = null;
         var callback:Function = null;
         this.m_loader = event.target.loader as Loader;
         this.m_loader.removeEventListener(Event.COMPLETE,this.onLoadComplete);
         if(this.m_loader.content)
         {
            this.m_content = this.m_loader.content;
            if(this.m_content is MovieClip)
            {
               if(Global.player.isSfxDisabled())
               {
                  st = new SoundTransform();
                  st.volume = 0;
                  (this.m_content as MovieClip).soundTransform = st;
               }
               if(this.m_content.origin_mc)
               {
                  this.m_content.x -= this.m_content.origin_mc.x;
                  this.m_content.y -= this.m_content.origin_mc.y;
               }
               if(this.m_useAnimation)
               {
                  if(!PerformanceExperimentManager.isInAnimationMemoryExperiment || DLManager.shouldMakeAnimations())
                  {
                     this.m_content = MapResourceDL.makeAnimation(this.m_content as MovieClip,1,this.m_content);
                  }
               }
            }
         }
         if(this.m_content)
         {
            for each(callback in this.m_callbacks)
            {
               clone(this.m_content,callback);
            }
            this.m_callbacks.splice(0,this.m_callbacks.length);
            dispatchEvent(new Event(Event.COMPLETE));
         }
         else
         {
            GlobalEngine.log("Loading","ERROR: image failed to load: " + this.m_url);
         }
      }
   }
}

final class SingletonEnforcer
{
   
   public static const instance:SingletonEnforcer = new SingletonEnforcer();
   
   public function SingletonEnforcer()
   {
      super();
   }
}
