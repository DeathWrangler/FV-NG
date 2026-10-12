package com.troyer.widget.parser
{
   import com.troyer.widget.MT4DConfig;
   import com.troyer.widget.MT4DContext;
   import com.troyer.widget.MT4DManager;
   import com.troyer.widget.event.WidgetLoadEvent;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   
   public class DialogParser extends EventDispatcher
   {
      
      private static var m_dynamics:DynamicClasses;
      
      protected var m_styles:Dictionary;
      
      protected var m_looks:Dictionary;
      
      protected var m_views:Dictionary;
      
      protected var m_dialogs:Dictionary;
      
      protected var m_sampleText:Dictionary;
      
      protected var m_config:MT4DConfig;
      
      private var m_loadQueue:Dictionary;
      
      private var m_controllerCache:Dictionary;
      
      private var m_viewCache:Dictionary;
      
      public function DialogParser(param1:DialogParser)
      {
         super();
         if(param1 != this)
         {
            throw new IllegalOperationError("DialogParser should not be instantiated directly");
         }
         this.m_controllerCache = new Dictionary();
         this.m_viewCache = new Dictionary();
         this.m_loadQueue = new Dictionary();
         this.clear();
      }
      
      public function destroy() : void
      {
      }
      
      private function clear() : void
      {
         this.m_styles = new Dictionary();
         this.m_looks = new Dictionary();
         this.m_views = new Dictionary();
         this.m_dialogs = new Dictionary();
         this.m_sampleText = new Dictionary();
      }
      
      public function load(param1:String, param2:Boolean = false, param3:MT4DContext = null) : void
      {
         var _loc4_:URLLoader = new URLLoader();
         _loc4_.dataFormat = URLLoaderDataFormat.BINARY;
         _loc4_.addEventListener(Event.COMPLETE,this.onLoadComplete);
         _loc4_.addEventListener(IOErrorEvent.IO_ERROR,this.onLoadComplete);
         _loc4_.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onLoadComplete);
         this.m_loadQueue[_loc4_] = {
            "url":param1,
            "replaceExisting":param2,
            "context":param3
         };
         _loc4_.load(new URLRequest(param1));
      }
      
      private function onLoadComplete(param1:Event) : void
      {
         var _loc9_:* = undefined;
         var _loc2_:URLLoader = param1.target as URLLoader;
         var _loc3_:Object = this.m_loadQueue[_loc2_];
         var _loc4_:String = _loc3_.url;
         var _loc5_:Boolean = Boolean(_loc3_.replaceExisting);
         var _loc6_:MT4DContext = _loc3_.context;
         _loc2_.removeEventListener(Event.COMPLETE,this.onLoadComplete);
         _loc2_.removeEventListener(IOErrorEvent.IO_ERROR,this.onLoadComplete);
         _loc2_.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onLoadComplete);
         delete this.m_loadQueue[_loc2_];
         var _loc7_:* = _loc2_.data as ByteArray;
         if(_loc7_)
         {
            if(this.m_config)
            {
               _loc7_ = this.m_config.onUncompressData(param1);
            }
            this.parse(_loc7_,_loc5_,_loc6_);
         }
         else
         {
            this.addError("Failed to load dialog data");
         }
         if(param1.type == Event.COMPLETE)
         {
            this.dispatchEvent(new WidgetLoadEvent(WidgetLoadEvent.LOAD_COMPLETE,_loc4_));
         }
         else
         {
            this.dispatchEvent(new WidgetLoadEvent(WidgetLoadEvent.LOAD_FAILED,_loc4_));
         }
         this.dispatchEvent(param1);
         var _loc8_:int = 0;
         for(_loc9_ in this.m_loadQueue)
         {
            _loc8_++;
         }
         if(_loc8_ == 0)
         {
            this.dispatchEvent(new WidgetLoadEvent(WidgetLoadEvent.ALL_LOADS_COMPLETE));
         }
      }
      
      final public function parse(param1:*, param2:Boolean = false, param3:MT4DContext = null) : void
      {
         var data:* = param1;
         var replaceExisting:Boolean = param2;
         var context:MT4DContext = param3;
         if(context == null)
         {
            context = MT4DManager.getInstance().getDefaultContext();
         }
         try
         {
            this.doParse(data);
            context.addStyles(this.m_styles,replaceExisting);
            context.addLooks(this.m_looks,replaceExisting);
            context.addViews(this.m_views,replaceExisting);
            context.addDialogs(this.m_dialogs,replaceExisting);
            context.addSampleText(this.m_sampleText,replaceExisting);
            this.clear();
         }
         catch(error:Error)
         {
            addError("Parser exception - " + error.message);
            throw error;
         }
      }
      
      protected function doParse(param1:*) : void
      {
      }
      
      protected function addError(param1:String) : void
      {
         var _loc2_:ParserErrorList = MT4DManager.getInstance().getErrorList();
         _loc2_.addError(param1);
      }
      
      protected function addWarning(param1:String) : void
      {
         var _loc2_:ParserErrorList = MT4DManager.getInstance().getErrorList();
         _loc2_.addWarning(param1);
      }
      
      protected function findViewDefinition(param1:String) : Dictionary
      {
         var _loc3_:MT4DContext = null;
         var _loc2_:Dictionary = this.m_views[param1];
         if(_loc2_ == null)
         {
            _loc3_ = MT4DManager.getInstance().getDefaultContext();
            _loc2_ = _loc3_.findViewDefinition(param1);
         }
         return _loc2_;
      }
      
      protected function findViewOrControllerClass(param1:String) : Class
      {
         var _loc2_:Class = null;
         _loc2_ = this.m_controllerCache[param1];
         if(_loc2_ != null)
         {
            return _loc2_;
         }
         _loc2_ = this.m_viewCache[param1];
         if(_loc2_ != null)
         {
            return _loc2_;
         }
         try
         {
            _loc2_ = getDefinitionByName("com.troyer.widget.controller." + param1 + "Controller") as Class;
            this.m_controllerCache[param1] = _loc2_;
            return _loc2_;
         }
         catch(error:Error)
         {
         }
         try
         {
            _loc2_ = getDefinitionByName("com.troyer.widget.view." + param1 + "View") as Class;
            this.m_viewCache[param1] = _loc2_;
            return _loc2_;
         }
         catch(error:Error)
         {
         }
         return null;
      }
   }
}

