package Widgets.Core.Windows
{
   import Classes.util.FarmGameUtil;
   import Engine.Utilities;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Base.ZwWire;
   import Widgets.Core.Managers.ZwWidgetManager;
   import Widgets.Core.Util.ZwProfiler;
   import Widgets.Core.Util.ZwWidgetUtils;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.utils.getQualifiedClassName;
   import flash.utils.getQualifiedSuperclassName;
   
   public class ZwAbstractWindow extends MovieClip
   {
      
      protected var m_widgetManager:ZwWidgetManager;
      
      protected var m_windowAssetPath:String = null;
      
      protected var m_loader:Loader = null;
      
      protected var m_isLoaded:Boolean = false;
      
      protected var m_window:MovieClip = null;
      
      protected var m_enableInput:Boolean = true;
      
      protected var m_wires:Array;
      
      public function ZwAbstractWindow(windowAssetAbsPath:String)
      {
         var qualifiedClassName:String = null;
         var qualifiedSuperClassName:String = null;
         var errorMessage:String = null;
         this.m_widgetManager = new ZwWidgetManager();
         this.m_wires = new Array();
         super();
         this.m_windowAssetPath = windowAssetAbsPath;
         if(this.m_windowAssetPath)
         {
            this.m_loader = this.createLoader(this.m_windowAssetPath,this.onLoadComplete);
            this.visible = false;
         }
         else if(false && Config.DEBUG_MODE)
         {
            qualifiedClassName = getQualifiedClassName(this);
            qualifiedSuperClassName = getQualifiedSuperclassName(this);
            errorMessage = "ZwAbstractWindow: null dialog url, qualifiedClassName=" + qualifiedClassName + ", qualifiedSuperClassName=" + qualifiedSuperClassName;
            FarmGameUtil.reportClientLog(errorMessage);
         }
         ZwProfiler.getInstance().addRef(this);
      }
      
      protected function release() : void
      {
         if(this.m_widgetManager != null)
         {
            this.m_widgetManager.release();
            this.m_widgetManager = null;
         }
         if(null != this.m_loader)
         {
            this.m_loader.unload();
            this.m_loader = null;
         }
         ZwWidgetUtils.removeAllChildren(this);
         this.m_window = null;
         this.m_isLoaded = false;
         if(this.parent)
         {
            this.parent.removeChild(this);
         }
         ZwProfiler.getInstance().removeRef(this);
      }
      
      public function get enableInput() : Boolean
      {
         return this.m_enableInput;
      }
      
      public function set enableInput(value:Boolean) : void
      {
         this.m_enableInput = value;
         if(this.m_isLoaded)
         {
            Utilities.toggleInputAndChildren(this.m_window,this.m_enableInput);
         }
      }
      
      public function close() : void
      {
         dispatchEvent(new Event(Event.CLOSE));
         this.release();
      }
      
      protected function createLoader(url:String, onLoadCallback:Function) : Loader
      {
         throw new Error("Error: Abstract Function: Need to override ZwAbstractWindow:createLoader.");
      }
      
      protected function onLoadComplete(event:Event) : void
      {
         var widget:ZwWidget = null;
         var wire:ZwWire = null;
         if(Boolean(this.m_loader) && this.m_loader.content != null)
         {
            this.m_window = this.m_loader.content as MovieClip;
            if(this.m_window)
            {
               this.recursivelyStop(this.m_window);
               this.hideAllInstances();
               Utilities.toggleInputAndChildren(this.m_window,this.m_enableInput);
               dispatchEvent(new Event(Event.COMPLETE));
               this.m_isLoaded = true;
               this.postLoadComplete();
               widget = null;
               for each(wire in this.m_wires)
               {
                  widget = wire.createWidget(this);
                  if(widget)
                  {
                     this.addWidget(widget);
                  }
               }
               addChild(this.m_window);
            }
         }
      }
      
      protected function hideAllInstances() : void
      {
         var value:DisplayObject = null;
         for each(value in this.m_window)
         {
            if(ZwWidgetUtils.isValidElement(value))
            {
               value.visible = false;
            }
         }
      }
      
      protected function postLoadComplete() : void
      {
         this.visible = true;
      }
      
      protected function addWidget(widget:ZwBaseWidget, visible:Boolean = true) : ZwBaseWidget
      {
         widget.parent = this;
         return this.m_widgetManager.addWidget(widget,visible);
      }
      
      protected function removeWidget(widget:Object) : void
      {
         this.m_widgetManager.removeWidget(widget);
      }
      
      protected function getWidget(widget:Object) : ZwBaseWidget
      {
         return this.m_widgetManager.getWidget(widget);
      }
      
      private function recursivelyStop(container:DisplayObjectContainer) : void
      {
         var displayContainer:DisplayObjectContainer = null;
         if(container is MovieClip)
         {
            MovieClip(container).stop();
         }
         for(var childIdx:int = 0; childIdx < container.numChildren; childIdx++)
         {
            displayContainer = container.getChildAt(childIdx) as DisplayObjectContainer;
            if(Boolean(displayContainer) && displayContainer.numChildren > 1)
            {
               this.recursivelyStop(displayContainer);
            }
         }
      }
      
      public function get shouldFreeze() : Boolean
      {
         return true;
      }
      
      public function addWire(wire:ZwWire) : void
      {
         this.m_wires.push(wire);
      }
      
      public function get window() : MovieClip
      {
         return this.m_window;
      }
   }
}

