package com.troyer.widget.view
{
   import com.troyer.widget.Constants;
   import com.troyer.widget.MT4DContext;
   import com.troyer.widget.MT4DManager;
   import com.troyer.widget.controller.BaseWidgetController;
   import com.troyer.widget.parser.Utility;
   import com.troyer.widget.style.BaseStyle;
   import com.troyer.widget.style.DialogLook;
   import flash.utils.Dictionary;
   
   public class ViewBuilder
   {
      
      private static var m_styleExpandRecursionCount:int;
      
      private static var m_isBuildingView:int;
      
      public function ViewBuilder()
      {
         super();
      }
      
      public static function buildView(param1:Dictionary, param2:DialogLook = null, param3:MT4DContext = null) : BaseWidgetView
      {
         var viewData:Dictionary = param1;
         var look:DialogLook = param2;
         var context:MT4DContext = param3;
         var result:BaseWidgetView = null;
         if(context == null)
         {
            context = MT4DManager.getInstance().getDefaultContext();
         }
         ++m_isBuildingView;
         try
         {
            m_styleExpandRecursionCount = 0;
            result = createViewHeirarchy(viewData,look,context);
            if(result)
            {
               setupViewAttributes(result,viewData,look,context);
            }
            else
            {
               addError("Couldn\'t setup view \'" + viewData[Constants.ATTRIBUTES][BaseWidgetController.ATTRIBUTE_NAME] + "\' attributes.");
            }
         }
         finally
         {
            --m_isBuildingView;
         }
         return result;
      }
      
      internal static function isBuildingView() : Boolean
      {
         return m_isBuildingView > 0;
      }
      
      private static function createViewHeirarchy(param1:Dictionary, param2:DialogLook, param3:MT4DContext) : BaseWidgetView
      {
         var _loc8_:String = null;
         var _loc10_:String = null;
         var _loc11_:BaseStyle = null;
         var _loc4_:BaseStyle = resolveViewStyle(param1,param2,param3);
         var _loc5_:Dictionary = null;
         if(_loc4_ != null)
         {
            if(_loc4_.hasSkin())
            {
               _loc10_ = _loc4_.getSkinTarget();
               if(param1[Constants.TAG_NAME] != _loc10_)
               {
                  addError("The style \'" + _loc4_.getName() + "\' may only be applied to <" + _loc10_ + "> tags, not <" + param1[Constants.TAG_NAME] + " tags.");
               }
               else
               {
                  _loc5_ = _loc4_.getSkinViewData();
               }
            }
         }
         var _loc6_:String = Constants.DEFAULT_WIDGET;
         if(Boolean(_loc5_) && Boolean(_loc5_[Constants.ATTRIBUTES][Constants.ATTRIBUTE_CLASSNAME]))
         {
            _loc8_ = _loc5_[Constants.ATTRIBUTES][Constants.ATTRIBUTE_CONTROLLER];
         }
         else if(param1[Constants.ATTRIBUTES][Constants.ATTRIBUTE_CLASSNAME])
         {
            _loc6_ = param1[Constants.ATTRIBUTES][Constants.ATTRIBUTE_CLASSNAME];
         }
         var _loc7_:BaseWidgetView = BaseWidgetView.getFactoryWidgetView(_loc6_,param3);
         if(_loc7_ == null)
         {
            return null;
         }
         _loc8_ = Constants.DEFAULT_WIDGET;
         if(Boolean(_loc5_) && Boolean(_loc5_[Constants.ATTRIBUTES][Constants.ATTRIBUTE_CONTROLLER]))
         {
            _loc8_ = _loc5_[Constants.ATTRIBUTES][Constants.ATTRIBUTE_CONTROLLER];
         }
         else if(param1[Constants.ATTRIBUTES][Constants.ATTRIBUTE_CONTROLLER])
         {
            _loc8_ = param1[Constants.ATTRIBUTES][Constants.ATTRIBUTE_CONTROLLER];
         }
         var _loc9_:BaseWidgetController = BaseWidgetController.getFactoryWidgetController(_loc8_,_loc7_);
         if(!_loc9_)
         {
            return null;
         }
         if(param1[Constants.ATTRIBUTES][BaseWidgetController.ATTRIBUTE_NAME])
         {
            _loc9_.setAttribute(BaseWidgetController.ATTRIBUTE_NAME,param1[Constants.ATTRIBUTES][BaseWidgetController.ATTRIBUTE_NAME]);
         }
         if(param1[Constants.ATTRIBUTES][BaseWidgetView.ATTRIBUTE_DEPTH])
         {
            _loc9_.setAttribute(BaseWidgetView.ATTRIBUTE_DEPTH,param1[Constants.ATTRIBUTES][BaseWidgetView.ATTRIBUTE_DEPTH]);
         }
         if(_loc5_)
         {
            expandStyleSkin(_loc7_,_loc4_,param2,param3);
            _loc11_ = resolveViewStyle(_loc5_,param2,param3);
            if(_loc11_)
            {
               param1[Constants.STYLE_INSTANCE] = _loc11_;
            }
         }
         else
         {
            param1[Constants.STYLE_INSTANCE] = _loc4_;
         }
         populateViewChildren(_loc7_,param1,param2,param3);
         return _loc7_;
      }
      
      private static function populateViewChildren(param1:BaseWidgetView, param2:Dictionary, param3:DialogLook, param4:MT4DContext) : void
      {
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:Dictionary = null;
         var _loc9_:BaseWidgetView = null;
         var _loc5_:BaseWidgetView = param1.getContentHolder();
         if(param2[Constants.CHILDREN])
         {
            _loc6_ = int(param2[Constants.CHILDREN].length);
            _loc7_ = 0;
            while(_loc7_ < _loc6_)
            {
               _loc8_ = param2[Constants.CHILDREN][_loc7_];
               if(_loc8_)
               {
                  _loc9_ = createViewHeirarchy(_loc8_,param3,param4);
                  if(_loc9_)
                  {
                     _loc5_.addChild(_loc9_);
                  }
               }
               else
               {
                  addError("Null child view (index " + _loc7_ + ") found in view " + param1.getController().getName());
               }
               _loc7_++;
            }
         }
      }
      
      private static function resolveViewStyle(param1:Dictionary, param2:DialogLook, param3:MT4DContext, param4:Boolean = false) : BaseStyle
      {
         var _loc5_:Boolean = false;
         var _loc6_:String = param1[Constants.ATTRIBUTES][Constants.ATTRIBUTE_STYLE];
         if(_loc6_ == null && !param4)
         {
            _loc6_ = param1[Constants.TAG_NAME];
            _loc5_ = true;
         }
         var _loc7_:BaseStyle = null;
         if(_loc6_ != null)
         {
            if(param2 != null)
            {
               _loc7_ = param2.getStyle(_loc6_);
            }
            else
            {
               _loc7_ = param3.getStyle(_loc6_);
            }
            if(_loc7_ == null && !_loc5_)
            {
               addError("Style \'" + _loc6_ + "\' not found.");
            }
         }
         return _loc7_;
      }
      
      internal static function updateViewStyleSkin(param1:BaseWidgetView, param2:BaseStyle, param3:DialogLook, param4:MT4DContext) : void
      {
         m_styleExpandRecursionCount = 0;
         expandStyleSkin(param1,param2,param3,param4);
      }
      
      private static function expandStyleSkin(param1:BaseWidgetView, param2:BaseStyle, param3:DialogLook, param4:MT4DContext) : void
      {
         ++m_styleExpandRecursionCount;
         if(m_styleExpandRecursionCount > 10)
         {
            addError("Circular style definition detected in style \'" + param2.getName() + "\'.");
         }
         var _loc5_:Dictionary = param2.getSkinViewData();
         if(_loc5_)
         {
            populateViewChildren(param1,_loc5_,param3,param4);
         }
         if(!param1)
         {
            addError("Couldn\'t expand skin for style \'" + param2.getName() + "\'.");
         }
         var _loc6_:String = param2.getSkinInjectTarget();
         var _loc7_:BaseWidgetView = null;
         if(_loc6_ != null)
         {
            _loc7_ = param1.findChildViewByName(_loc6_) as BaseWidgetView;
            if(_loc7_ == null)
            {
               addError("Unable to find inject target view \'" + _loc6_ + "\' for style \'" + param2.getName() + "\'.");
            }
         }
         else
         {
            _loc7_ = param1;
         }
         param1.onSkinExpanded(param1,_loc7_);
         param1.getController().onSkinExpanded(param1,_loc7_);
         setupViewAttributes(param1,_loc5_,param3,param4);
         param1.m_contentHolder = _loc7_;
         if(_loc7_)
         {
            _loc7_.m_contentHolderParent = param1;
         }
         param1.m_skin = _loc5_;
         --m_styleExpandRecursionCount;
      }
      
      private static function setupViewAttributes(param1:BaseWidgetView, param2:Dictionary, param3:DialogLook, param4:MT4DContext) : void
      {
         var _loc5_:BaseStyle = null;
         var _loc6_:Dictionary = null;
         var _loc7_:BaseWidgetController = null;
         var _loc8_:String = null;
         var _loc9_:BaseWidgetView = null;
         var _loc10_:int = 0;
         var _loc11_:BaseWidgetView = null;
         var _loc12_:Array = null;
         var _loc13_:int = 0;
         var _loc14_:BaseWidgetView = null;
         if(Boolean(param1) && Boolean(param1.getController()))
         {
            _loc5_ = param2[Constants.STYLE_INSTANCE];
            if(_loc5_)
            {
               param1.setStyle(_loc5_);
            }
            _loc6_ = Utility.cloneDictionary(param2[Constants.ATTRIBUTES]);
            _loc7_ = param1.getController();
            for(_loc8_ in _loc6_)
            {
               if(_loc8_.indexOf(Constants.ATTRIBUTE_STYLE) == 0)
               {
                  if(Boolean(_loc5_) && _loc5_.getName() == _loc6_[_loc8_])
                  {
                     _loc7_.setAttribute(_loc8_,_loc5_);
                  }
                  else
                  {
                     _loc7_.setAttribute(_loc8_,param4.getStyle(_loc6_[_loc8_]));
                  }
                  delete _loc6_[_loc8_];
               }
               else if(_loc8_.indexOf("view") == 0)
               {
                  _loc9_ = param4.getView(_loc6_[_loc8_]);
                  if(_loc9_)
                  {
                     _loc7_.setAttribute(_loc8_,_loc9_);
                  }
                  delete _loc6_[_loc8_];
               }
            }
            _loc7_.localizeAttributes(MT4DManager.getInstance(),_loc6_);
            _loc7_.setAttributes(_loc6_);
            if(param2[Constants.CHILDREN])
            {
               _loc10_ = int(param2[Constants.CHILDREN].length);
               _loc11_ = param1.getContentHolder();
               _loc12_ = _loc11_.getLogicalChildren();
               _loc13_ = 0;
               while(_loc13_ < _loc10_)
               {
                  _loc14_ = _loc12_[_loc13_];
                  if(_loc14_)
                  {
                     setupViewAttributes(_loc14_,param2[Constants.CHILDREN][_loc13_],param3,param4);
                  }
                  _loc13_++;
               }
            }
            delete param2[Constants.STYLE_INSTANCE];
            delete param2[Constants.CONTENT_HOLDER];
         }
      }
      
      private static function addError(param1:String) : void
      {
         MT4DManager.getInstance().getErrorList().addError(param1);
      }
      
      private static function addWarning(param1:String) : void
      {
         MT4DManager.getInstance().getErrorList().addWarning(param1);
      }
   }
}

