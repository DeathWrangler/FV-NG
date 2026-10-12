package com.troyer.widget.controller
{
   import com.troyer.widget.MT4DManager;
   import com.troyer.widget.event.WidgetControllerEvent;
   import com.troyer.widget.event.WidgetViewEvent;
   import com.troyer.widget.parser.Utility;
   import com.troyer.widget.view.BaseWidgetView;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   
   public class BaseWidgetController extends EventDispatcher
   {
      
      private static var m_controllerCounter:int;
      
      public static const ATTRIBUTE_NAME:String = "name";
      
      public static const ATTRIBUTE_X:String = "x";
      
      public static const ATTRIBUTE_Y:String = "y";
      
      public static const ATTRIBUTE_WIDTH:String = "width";
      
      public static const ATTRIBUTE_HEIGHT:String = "height";
      
      public static const ATTRIBUTE_FORCE_WIDTH:String = "forceWidth";
      
      public static const ATTRIBUTE_FORCE_HEIGHT:String = "forceHeight";
      
      public static const DEFAULT_NAME_PREFIX:String = "obj";
      
      private static var FACTORY_SUFFIX:String = "Controller";
      
      protected var m_name:String;
      
      protected var m_view:BaseWidgetView;
      
      private var m_listeners:Object = {};
      
      private var m_allListenerTargets:Array = [];
      
      protected var m_globalListeners:Array;
      
      private var m_attributeHistory:Dictionary = new Dictionary();
      
      protected var m_index:int;
      
      private var m_loadCount:int = 0;
      
      public function BaseWidgetController(param1:BaseWidgetView)
      {
         super();
         if(param1 == null)
         {
            throw new Error("Invalid view widget passed to widget controller");
         }
         this.m_view = param1;
         this.m_name = DEFAULT_NAME_PREFIX + m_controllerCounter++;
         this.m_view.setAttribute(BaseWidgetView.ATTRIBUTE_NAME,this.m_name);
      }
      
      public static function getFactoryWidgetController(param1:String, param2:BaseWidgetView) : BaseWidgetController
      {
         var ClassName:Class = null;
         var name:String = param1;
         var view:BaseWidgetView = param2;
         var result:BaseWidgetController = null;
         try
         {
            ClassName = getDefinitionByName("com.troyer.widget.controller." + name + FACTORY_SUFFIX) as Class;
         }
         catch(error:Error)
         {
            MT4DManager.getInstance().getErrorList().addError("Unable to find controller class \'" + name + FACTORY_SUFFIX + "\'.  Did you misspell it?");
            return null;
         }
         result = new ClassName(view);
         view.setController(result);
         result.initialize();
         return result;
      }
      
      public function destroy() : void
      {
         this.removeAllListeners();
         if(this.m_view)
         {
            this.m_view.destroy();
         }
         this.m_globalListeners = null;
      }
      
      final public function clone() : BaseWidgetController
      {
         var _loc6_:BaseWidgetView = null;
         var _loc7_:BaseWidgetController = null;
         var _loc8_:BaseWidgetController = null;
         var _loc1_:BaseWidgetView = this.m_view.clone();
         var _loc2_:Array = this.getContentViewChildren();
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_.length)
         {
            _loc6_ = _loc2_[_loc3_] as BaseWidgetView;
            if(_loc6_)
            {
               _loc7_ = _loc6_.getController();
               if(_loc7_)
               {
                  _loc8_ = _loc7_.clone();
                  _loc1_.addChild(_loc8_.getView());
               }
            }
            _loc3_++;
         }
         var _loc4_:Class = getDefinitionByName(getQualifiedClassName(this)) as Class;
         var _loc5_:BaseWidgetController = new _loc4_(_loc1_);
         _loc1_.setController(_loc5_);
         _loc5_.initialize();
         _loc5_.setAttributes(this.m_attributeHistory);
         return _loc5_;
      }
      
      public function initialize() : void
      {
         this.addViewListener(WidgetViewEvent.CHILD_RESIZE,this.onChildViewResized);
      }
      
      final protected function addListener(param1:IEventDispatcher, param2:String, param3:Function, param4:int = 5) : void
      {
         if(this.m_listeners[param1])
         {
            if(this.m_listeners[param1][param2])
            {
               this.removeListener(param1,param2);
            }
         }
         else
         {
            this.m_listeners[param1] = new Object();
         }
         this.m_allListenerTargets.push(param1);
         this.m_listeners[param1][param2] = param3;
         param1.addEventListener(param2,param3,false,param4);
      }
      
      final public function listen(param1:String, param2:Function) : void
      {
         this.addListener(this,param1,param2);
      }
      
      public function addViewListener(param1:String, param2:Function, param3:int = 5) : void
      {
         this.addListener(this.m_view,param1,param2,param3);
      }
      
      protected function removeListener(param1:IEventDispatcher, param2:String) : void
      {
         if(Boolean(this.m_listeners[param1]) && Boolean(this.m_listeners[param1][param2]))
         {
            param1.removeEventListener(param2,this.m_listeners[param1][param2]);
            delete this.m_listeners[param1][param2];
         }
      }
      
      protected function removeViewListener(param1:String) : void
      {
         this.removeListener(this.m_view,param1);
      }
      
      protected function removeAllListeners() : void
      {
         var _loc1_:IEventDispatcher = null;
         var _loc2_:String = null;
         for each(_loc1_ in this.m_allListenerTargets)
         {
            if(this.m_listeners[_loc1_])
            {
               for(_loc2_ in this.m_listeners[_loc1_])
               {
                  _loc1_.removeEventListener(_loc2_,this.m_listeners[_loc1_][_loc2_]);
               }
            }
         }
         this.m_allListenerTargets = [];
         this.m_listeners = {};
      }
      
      public function getGlobalListeners() : Array
      {
         return this.m_globalListeners;
      }
      
      protected function addGlobalListener(param1:String) : void
      {
         if(!this.m_globalListeners)
         {
            this.m_globalListeners = new Array();
         }
         this.m_globalListeners.push(param1);
      }
      
      public function getName() : String
      {
         return this.m_name;
      }
      
      public function setView(param1:BaseWidgetView) : void
      {
         var _loc2_:int = 0;
         var _loc3_:BaseWidgetView = null;
         if(Boolean(param1) && param1 != this.m_view)
         {
            if(Boolean(this.m_view.parent) && this.m_view.parent != param1)
            {
               this.m_view.parent.addChild(param1);
               _loc3_ = this.m_view.parent as BaseWidgetView;
               if(_loc3_)
               {
                  _loc3_.removeChild(this.m_view);
               }
            }
            _loc2_ = 0;
            while(_loc2_ < this.m_view.numChildren)
            {
               param1.addChild(this.m_view.getChildAt(_loc2_));
               _loc2_++;
            }
            param1.name = this.m_name;
            param1.setController(this);
            param1.setSize(this.m_view.getSize());
            param1.setStyle(this.m_view.getStyle());
            this.removeAllListeners();
            this.m_view.destroy();
            this.m_view = param1;
            this.initialize();
         }
         else
         {
            this.m_view = param1;
         }
      }
      
      public function getView() : BaseWidgetView
      {
         return this.m_view;
      }
      
      public function getAttributeOrder() : Array
      {
         return [ATTRIBUTE_NAME,ATTRIBUTE_FORCE_WIDTH,ATTRIBUTE_FORCE_HEIGHT,ATTRIBUTE_WIDTH,ATTRIBUTE_HEIGHT];
      }
      
      final public function setAttribute(param1:String, param2:*) : void
      {
         this.m_attributeHistory[param1] = param2;
         this.attribute(param1,param2);
      }
      
      protected function attribute(param1:String, param2:*) : void
      {
         switch(param1)
         {
            case ATTRIBUTE_NAME:
               this.m_name = param2;
               this.m_view.setAttribute(param1,param2);
               break;
            case ATTRIBUTE_X:
            case ATTRIBUTE_Y:
               this.m_view[param1] = param2;
               break;
            case ATTRIBUTE_FORCE_WIDTH:
               this.m_view.lockWidth();
               this.updateSize(ATTRIBUTE_WIDTH,param2);
               break;
            case ATTRIBUTE_FORCE_HEIGHT:
               this.m_view.lockHeight();
               this.updateSize(ATTRIBUTE_HEIGHT,param2);
               break;
            case ATTRIBUTE_WIDTH:
            case ATTRIBUTE_HEIGHT:
               this.updateSize(param1,param2);
               break;
            default:
               this.m_view.setAttribute(param1,param2);
         }
      }
      
      public function localizeAttributeValue(param1:MT4DManager, param2:String, param3:String) : String
      {
         if(this.m_view)
         {
            return this.m_view.localizeAttributeValue(param1,param2,param3);
         }
         return param3;
      }
      
      private function updateSize(param1:String, param2:*) : void
      {
         var _loc3_:Rectangle = null;
         if(param1 == ATTRIBUTE_WIDTH || param1 == ATTRIBUTE_HEIGHT)
         {
            _loc3_ = this.m_view.getSize();
            if(_loc3_)
            {
               _loc3_ = _loc3_.clone();
            }
            else
            {
               _loc3_ = new Rectangle();
            }
            if(param2 is String)
            {
               _loc3_[param1] = parseInt(String(param2));
            }
            else if(param2 is Number)
            {
               _loc3_[param1] = param2;
            }
            this.m_view.setSize(_loc3_);
         }
      }
      
      public function localizeAttributes(param1:MT4DManager, param2:Dictionary) : void
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         for(_loc3_ in param2)
         {
            _loc4_ = param2[_loc3_] as String;
            if(_loc4_ != null && _loc4_.length > 0 && _loc4_.charAt(0) == "@")
            {
               param2[_loc3_] = this.localizeAttributeValue(param1,_loc3_,_loc4_);
            }
         }
      }
      
      public function setAttributes(param1:Dictionary) : void
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         param1 = Utility.cloneDictionary(param1);
         var _loc2_:Array = this.getAttributeOrder();
         if(Boolean(_loc2_) && _loc2_.length > 0)
         {
            for each(_loc4_ in _loc2_)
            {
               if(param1[_loc4_])
               {
                  this.setAttribute(_loc4_,param1[_loc4_]);
                  delete param1[_loc4_];
               }
            }
         }
         for(_loc3_ in param1)
         {
            this.setAttribute(_loc3_,param1[_loc3_]);
         }
      }
      
      public function getAttribute(param1:String) : *
      {
         var _loc2_:* = null;
         if(this.m_view)
         {
            if(param1 == ATTRIBUTE_FORCE_WIDTH)
            {
               if(this.m_view.hasFixedWidth())
               {
                  _loc2_ = this.m_view.getSize().width;
               }
               else
               {
                  _loc2_ = 0;
               }
            }
            else if(param1 == ATTRIBUTE_FORCE_HEIGHT)
            {
               if(this.m_view.hasFixedHeight())
               {
                  _loc2_ = this.m_view.getSize().height;
               }
               else
               {
                  _loc2_ = 0;
               }
            }
            else if(param1 == ATTRIBUTE_X)
            {
               if(this.m_view)
               {
                  _loc2_ = this.m_view.x;
               }
               if(isNaN(_loc2_) || _loc2_ == null)
               {
                  _loc2_ = 0;
               }
            }
            else if(param1 == ATTRIBUTE_Y)
            {
               if(this.m_view)
               {
                  _loc2_ = this.m_view.y;
               }
               if(isNaN(_loc2_) || _loc2_ == null)
               {
                  _loc2_ = 0;
               }
            }
            else
            {
               _loc2_ = this.m_view.getAttribute(param1);
            }
         }
         return _loc2_;
      }
      
      final public function getAttributeHistory() : Dictionary
      {
         return this.m_attributeHistory;
      }
      
      public function forceResize() : void
      {
         this.onChildViewResized(null);
      }
      
      protected function onChildViewResized(param1:WidgetViewEvent) : void
      {
         if(param1)
         {
            if(!this.m_view.hasFixedHeight() && !this.m_view.hasFixedWidth())
            {
               this.m_view.setSize(param1.getView().getSize());
            }
         }
      }
      
      public function onSkinExpanded(param1:BaseWidgetView, param2:BaseWidgetView) : void
      {
      }
      
      public function addChildController(param1:BaseWidgetController) : void
      {
         var _loc2_:BaseWidgetView = param1.getView();
         this.m_view.addChild(_loc2_);
         _loc2_.notifyResized();
      }
      
      public function removeChildControllers() : void
      {
         var _loc2_:int = 0;
         var _loc3_:BaseWidgetView = null;
         var _loc1_:Array = this.getViewChildren();
         if(_loc1_)
         {
            _loc2_ = 0;
            while(_loc2_ < _loc1_.length)
            {
               _loc3_ = _loc1_[_loc2_];
               _loc3_.getController().destroy();
               _loc2_++;
            }
         }
         this.m_view.clearLogicalChildren();
      }
      
      public function getViewChildren() : Array
      {
         return this.m_view.getLogicalChildren();
      }
      
      public function getContentViewChildren() : Array
      {
         return this.m_view.getContentHolder().getLogicalChildren();
      }
      
      public function getChildController(param1:String) : BaseWidgetController
      {
         var _loc3_:BaseWidgetView = null;
         var _loc2_:BaseWidgetController = null;
         if(param1.indexOf(".") != -1)
         {
            _loc3_ = this.m_view.getChildByName(param1) as BaseWidgetView;
            if(_loc3_)
            {
               _loc2_ = _loc3_.getController();
            }
         }
         else
         {
            _loc2_ = this.findChildControllerByName(param1);
         }
         return _loc2_;
      }
      
      public function getControllerName() : String
      {
         var _loc2_:Array = null;
         var _loc1_:String = getQualifiedClassName(this);
         _loc2_ = _loc1_.split("::");
         _loc1_ = _loc2_[_loc2_.length - 1];
         if(_loc1_.indexOf(FACTORY_SUFFIX) != -1)
         {
            _loc1_ = _loc1_.replace(FACTORY_SUFFIX,"");
         }
         return _loc1_;
      }
      
      public function getDialog() : DynamicDialog
      {
         var _loc1_:BaseWidgetView = this.getView();
         if(_loc1_)
         {
            return _loc1_.getDialog();
         }
         return null;
      }
      
      public function getFlatChildrenList() : Array
      {
         var _loc2_:Array = null;
         var _loc3_:BaseWidgetView = null;
         var _loc4_:Array = null;
         var _loc1_:Array = null;
         if(this.m_view)
         {
            _loc2_ = this.m_view.getLogicalChildren();
            if(Boolean(_loc2_) && _loc2_.length > 0)
            {
               _loc1_ = new Array();
               for each(_loc3_ in _loc2_)
               {
                  _loc1_.push(_loc3_);
                  _loc4_ = _loc3_.getController().getFlatChildrenList();
                  if((Boolean(_loc4_)) && _loc4_.length > 0)
                  {
                     _loc1_ = _loc1_.concat(_loc4_);
                  }
               }
            }
         }
         return _loc1_;
      }
      
      public function findChildControllerByName(param1:String) : BaseWidgetController
      {
         var _loc2_:BaseWidgetView = this.getView().findChildViewByName(param1);
         if(_loc2_ != null)
         {
            return _loc2_.getController();
         }
         return null;
      }
      
      public function set index(param1:int) : void
      {
         this.m_index = param1;
      }
      
      public function get index() : int
      {
         return this.m_index;
      }
      
      public function get loadCount() : int
      {
         return this.m_loadCount;
      }
      
      protected function incrementLoadCount() : void
      {
         ++this.m_loadCount;
      }
      
      protected function decrementLoadCount() : void
      {
         --this.m_loadCount;
         dispatchEvent(new WidgetControllerEvent(WidgetControllerEvent.LOAD_COMPLETE,this));
         MT4DManager.getInstance().dispatchEvent(new WidgetControllerEvent(WidgetControllerEvent.LOAD_COMPLETE,this));
      }
      
      protected function addError(param1:String) : void
      {
         MT4DManager.getInstance().getErrorList().addError(param1);
      }
      
      protected function addWarning(param1:String) : void
      {
         MT4DManager.getInstance().getErrorList().addWarning(param1);
      }
   }
}

