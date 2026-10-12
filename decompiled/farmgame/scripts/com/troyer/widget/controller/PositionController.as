package com.troyer.widget.controller
{
   import com.troyer.widget.Constants;
   import com.troyer.widget.event.WidgetViewEvent;
   import com.troyer.widget.view.BaseWidgetView;
   import flash.geom.Rectangle;
   
   public class PositionController extends BaseWidgetController
   {
      
      public static const ATTRIBUTE_CONTENT_X:String = "contentX";
      
      public static const ATTRIBUTE_PAD_X:String = "padX";
      
      public static const ATTRIBUTE_PAD_Y:String = "padY";
      
      public static const ATTRIBUTE_ALIGN:String = "align";
      
      public static const ATTRIBUTE_VALIGN:String = "valign";
      
      public static const ATTRIBUTE_RESIZE_WIDTHS:String = "resizeWidths";
      
      public static const ATTRIBUTE_RESIZE_HEIGHTS:String = "resizeHeights";
      
      public static const ATTRIBUTE_MATCH_WIDTH:String = "matchWidths";
      
      public static const INFO_WIDTH:String = "width";
      
      public static const INFO_TALLEST:String = "tallest";
      
      public static const INFO_CHILDREN:String = "children";
      
      private var m_contentX:int = 1;
      
      private var m_padX:int = 0;
      
      private var m_padY:int = 0;
      
      private var m_align:String = "left";
      
      private var m_valign:String = "top";
      
      private var m_matchWidths:Array;
      
      private var m_matchParentNames:Array;
      
      private var m_resizeWidths:Array;
      
      private var m_resizeHeights:Array;
      
      public function PositionController(param1:BaseWidgetView)
      {
         super(param1);
      }
      
      override public function getAttributeOrder() : Array
      {
         var _loc1_:Array = super.getAttributeOrder();
         _loc1_.push(ATTRIBUTE_CONTENT_X,ATTRIBUTE_PAD_X,ATTRIBUTE_PAD_Y);
         return _loc1_;
      }
      
      override protected function attribute(param1:String, param2:*) : void
      {
         var _loc3_:Array = null;
         var _loc4_:BaseWidgetView = null;
         if(param1 == ATTRIBUTE_CONTENT_X)
         {
            if(param2 is String)
            {
               this.m_contentX = parseInt(param2);
               this.updateChildViews();
            }
            else if(param2 is Number)
            {
               this.m_contentX = param2;
               this.updateChildViews();
            }
         }
         else if(param1 == ATTRIBUTE_PAD_X)
         {
            this.m_padX = parseInt(param2);
            this.updateChildViews();
         }
         else if(param1 == ATTRIBUTE_PAD_Y)
         {
            this.m_padY = parseInt(param2);
            this.updateChildViews();
         }
         else if(param1 == ATTRIBUTE_ALIGN)
         {
            if(param2 == Constants.ALIGN_LEFT || param2 == Constants.ALIGN_CENTER || param2 == Constants.ALIGN_RIGHT)
            {
               this.m_align = param2;
               this.updateChildViews();
            }
            else
            {
               addError("Invalid alignment in view \'" + getName() + "\'");
            }
         }
         else if(param1 == ATTRIBUTE_VALIGN)
         {
            if(param2 == Constants.ALIGN_TOP || param2 == Constants.ALIGN_CENTER || param2 == Constants.ALIGN_BOTTOM)
            {
               this.m_valign = param2;
               this.updateChildViews();
            }
            else
            {
               addError("Invalid vertical alignment in view \'" + getName() + "\'");
            }
         }
         else if(param1 == ATTRIBUTE_RESIZE_WIDTHS && param2 is String)
         {
            this.m_resizeWidths = String(param2).split(",");
            this.updateChildViews();
         }
         else if(param1 == ATTRIBUTE_RESIZE_HEIGHTS && param2 is String)
         {
            this.m_resizeHeights = String(param2).split(",");
            this.updateChildViews();
         }
         else if(param1 == ATTRIBUTE_MATCH_WIDTH && param2 is String)
         {
            _loc3_ = String(param2).split(",");
            this.m_matchWidths = new Array();
            this.m_matchParentNames = new Array();
            for each(param1 in _loc3_)
            {
               _loc4_ = m_view.getChildByName(param1) as BaseWidgetView;
               if(_loc4_)
               {
                  this.m_matchWidths.push(_loc4_);
               }
               if(param1.indexOf(".") != -1)
               {
                  this.m_matchParentNames.push(param1.substr(0,param1.indexOf(".")));
               }
               else
               {
                  this.m_matchParentNames.push(param1);
               }
            }
            this.updateChildViews();
         }
         else
         {
            super.attribute(param1,param2);
         }
      }
      
      override public function getAttribute(param1:String) : *
      {
         var _loc2_:* = null;
         if(param1 == ATTRIBUTE_CONTENT_X)
         {
            _loc2_ = this.m_contentX;
         }
         else if(param1 == ATTRIBUTE_PAD_X)
         {
            _loc2_ = this.m_padX;
         }
         else if(param1 == ATTRIBUTE_PAD_Y)
         {
            _loc2_ = this.m_padY;
         }
         else if(param1 == ATTRIBUTE_ALIGN)
         {
            _loc2_ = this.m_align;
         }
         else if(param1 == ATTRIBUTE_VALIGN)
         {
            _loc2_ = this.m_valign;
         }
         else
         {
            _loc2_ = super.getAttribute(param1);
         }
         return _loc2_;
      }
      
      override protected function onChildViewResized(param1:WidgetViewEvent) : void
      {
         this.updateChildViews();
      }
      
      private function updateChildViews() : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:Object = null;
         var _loc12_:Array = null;
         var _loc13_:BaseWidgetView = null;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:int = 0;
         var _loc17_:BaseWidgetController = null;
         var _loc18_:Rectangle = null;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc21_:Rectangle = null;
         var _loc22_:Boolean = false;
         var _loc23_:int = 0;
         var _loc24_:BaseWidgetView = null;
         var _loc25_:Object = null;
         var _loc26_:Rectangle = null;
         var _loc27_:Array = null;
         var _loc28_:BaseWidgetView = null;
         var _loc29_:int = 0;
         var _loc30_:int = 0;
         var _loc31_:int = 0;
         var _loc32_:Rectangle = null;
         var _loc33_:Number = NaN;
         var _loc34_:String = null;
         var _loc35_:String = null;
         var _loc1_:Array = getViewChildren();
         if(_loc1_)
         {
            _loc2_ = 0;
            _loc3_ = 0;
            _loc4_ = 0;
            _loc5_ = 0;
            _loc6_ = 0;
            _loc7_ = 0;
            _loc8_ = 0;
            _loc9_ = 0;
            _loc10_ = 0;
            _loc11_ = new Object();
            _loc12_ = new Array();
            for each(_loc13_ in _loc1_)
            {
               _loc13_.getController().setAttribute(BaseWidgetController.ATTRIBUTE_X,_loc2_);
               _loc13_.getController().setAttribute(BaseWidgetController.ATTRIBUTE_Y,_loc4_);
               _loc19_ = _loc13_.width;
               _loc20_ = _loc13_.height;
               _loc21_ = _loc13_.getAdjustedSize();
               if(_loc21_)
               {
                  _loc19_ = _loc21_.width;
                  _loc20_ = _loc21_.height;
               }
               if(_loc20_ > _loc6_)
               {
                  _loc6_ = _loc20_;
               }
               if(_loc13_.getAttribute(BaseWidgetView.ATTRIBUTE_OBSTRUCT))
               {
                  if(_loc20_ > _loc7_)
                  {
                     _loc7_ = _loc20_;
                  }
               }
               else
               {
                  _loc19_ = 0;
               }
               _loc3_++;
               if(!_loc11_.hasOwnProperty(INFO_CHILDREN))
               {
                  _loc11_[INFO_CHILDREN] = new Array();
               }
               _loc11_[INFO_CHILDREN].push(_loc13_);
               _loc22_ = _loc1_.indexOf(_loc13_) == _loc1_.length - 1;
               if(_loc3_ % this.m_contentX == 0 || _loc22_)
               {
                  _loc11_[INFO_WIDTH] = _loc2_ + _loc19_;
                  _loc11_[INFO_TALLEST] = _loc6_;
                  if(_loc11_[INFO_WIDTH] > _loc8_)
                  {
                     if(!this.m_resizeWidths || this.m_resizeWidths.indexOf(_loc13_.name) == -1)
                     {
                        _loc8_ = int(_loc11_[INFO_WIDTH]);
                     }
                  }
                  _loc12_.push(_loc11_);
                  _loc11_ = new Object();
                  _loc2_ = 0;
                  _loc4_ += _loc7_;
                  _loc5_ += _loc7_;
                  if(!_loc22_)
                  {
                     _loc4_ += this.m_padY;
                     _loc5_ += this.m_padY;
                  }
                  if(Boolean(this.m_resizeHeights) && this.m_resizeHeights.indexOf(_loc13_.name) == -1)
                  {
                     if(_loc7_ > _loc10_)
                     {
                        _loc10_ = _loc7_;
                     }
                  }
                  _loc6_ = 0;
                  _loc7_ = 0;
               }
               else
               {
                  _loc2_ += _loc19_ + this.m_padX;
               }
            }
            _loc14_ = _loc8_;
            _loc15_ = _loc5_;
            if(m_view.hasFixedWidth())
            {
               _loc14_ = m_view.getSize().width;
            }
            if(m_view.hasFixedHeight())
            {
               _loc15_ = m_view.getSize().height;
            }
            _loc16_ = 0;
            if(m_view.getSize())
            {
               _loc16_ = m_view.getSize().width;
            }
            if(_loc12_.length > 0)
            {
               _loc23_ = 0;
               for each(_loc25_ in _loc12_)
               {
                  if(this.m_align == Constants.ALIGN_CENTER || this.m_align == Constants.ALIGN_RIGHT)
                  {
                     if(_loc25_[INFO_WIDTH] < _loc8_)
                     {
                        _loc23_ = _loc8_ - _loc25_[INFO_WIDTH];
                        if(this.m_align == Constants.ALIGN_CENTER)
                        {
                           _loc23_ >>= 1;
                        }
                        for each(_loc24_ in _loc25_[INFO_CHILDREN])
                        {
                           if(_loc24_.getOffsetLeft() != 0)
                           {
                              _loc24_.getController().setAttribute(BaseWidgetController.ATTRIBUTE_X,_loc24_.x + _loc24_.getOffsetLeft() + _loc23_);
                           }
                           else
                           {
                              _loc24_.getController().setAttribute(BaseWidgetController.ATTRIBUTE_X,_loc24_.x + _loc23_);
                           }
                        }
                     }
                  }
                  else
                  {
                     for each(_loc24_ in _loc25_[INFO_CHILDREN])
                     {
                        if(_loc24_.getOffsetLeft() != 0)
                        {
                           _loc24_.getController().setAttribute(BaseWidgetController.ATTRIBUTE_X,_loc24_.x + _loc24_.getOffsetLeft());
                        }
                     }
                  }
                  if(this.m_valign == Constants.ALIGN_CENTER || this.m_valign == Constants.ALIGN_BOTTOM)
                  {
                     for each(_loc24_ in _loc25_[INFO_CHILDREN])
                     {
                        _loc26_ = _loc24_.getAdjustedSize();
                        if((Boolean(_loc26_)) && _loc26_.height < _loc25_[INFO_TALLEST])
                        {
                           _loc23_ = _loc25_[INFO_TALLEST] - _loc26_.height;
                           if(this.m_valign == Constants.ALIGN_CENTER)
                           {
                              _loc23_ >>= 1;
                           }
                           if(_loc24_.getOffsetTop() != 0)
                           {
                              _loc24_.getController().setAttribute(BaseWidgetController.ATTRIBUTE_Y,_loc24_.y + _loc24_.getOffsetTop() + _loc23_);
                           }
                           else
                           {
                              _loc24_.getController().setAttribute(BaseWidgetController.ATTRIBUTE_Y,_loc24_.y + _loc23_);
                           }
                        }
                     }
                  }
                  else
                  {
                     for each(_loc24_ in _loc25_[INFO_CHILDREN])
                     {
                        if(_loc24_.getOffsetTop() != 0)
                        {
                           _loc24_.getController().setAttribute(BaseWidgetController.ATTRIBUTE_Y,_loc24_.y + _loc24_.getOffsetTop());
                        }
                     }
                  }
                  if(Boolean(this.m_matchWidths) && Boolean(this.m_matchWidths.length > 0) && _loc25_[INFO_WIDTH] < _loc16_)
                  {
                     _loc27_ = new Array();
                     for each(_loc28_ in _loc25_[INFO_CHILDREN])
                     {
                        _loc29_ = 0;
                        while(_loc29_ < this.m_matchParentNames.length)
                        {
                           if(_loc28_.name == this.m_matchParentNames[_loc29_])
                           {
                              _loc27_.push(this.m_matchWidths[_loc29_]);
                           }
                           _loc29_++;
                        }
                     }
                     if(_loc27_.length > 0)
                     {
                        _loc30_ = _loc16_ - _loc25_[INFO_WIDTH];
                        _loc31_ = _loc30_ / _loc27_.length;
                        for each(_loc28_ in _loc27_)
                        {
                           _loc32_ = _loc28_.getSize();
                           _loc33_ = 0;
                           if(Boolean(_loc32_) && _loc32_.width > 0)
                           {
                              _loc33_ = _loc32_.width;
                           }
                           _loc28_.getController().setAttribute(ATTRIBUTE_FORCE_WIDTH,_loc33_ + _loc31_);
                        }
                     }
                  }
                  delete _loc25_[INFO_CHILDREN];
                  delete _loc25_[INFO_WIDTH];
               }
            }
            _loc12_ = null;
            if(Boolean(this.m_resizeWidths) && _loc8_ > 0)
            {
               for each(_loc34_ in this.m_resizeWidths)
               {
                  _loc17_ = getChildController(_loc34_);
                  if(_loc17_)
                  {
                     _loc18_ = _loc17_.getView().getSize();
                     if((Boolean(_loc18_)) && _loc18_.width != _loc8_)
                     {
                        _loc17_.setAttribute(BaseWidgetController.ATTRIBUTE_FORCE_WIDTH,_loc8_);
                     }
                  }
               }
            }
            if(Boolean(this.m_resizeHeights) && _loc10_ > 0)
            {
               for each(_loc35_ in this.m_resizeHeights)
               {
                  _loc17_ = getChildController(_loc35_);
                  if(_loc17_)
                  {
                     _loc18_ = _loc17_.getView().getSize();
                     if((Boolean(_loc18_)) && _loc18_.height != _loc10_)
                     {
                        _loc17_.setAttribute(BaseWidgetController.ATTRIBUTE_FORCE_HEIGHT,_loc10_);
                     }
                  }
               }
            }
            m_view.setSize(new Rectangle(0,0,_loc14_,_loc15_));
         }
      }
   }
}

