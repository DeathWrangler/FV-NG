package com.troyer.widget.controller
{
   import com.troyer.widget.Constants;
   import com.troyer.widget.event.WidgetViewEvent;
   import com.troyer.widget.parser.Utility;
   import com.troyer.widget.view.BaseWidgetView;
   import flash.geom.Rectangle;
   
   public class GridController extends BaseWidgetController
   {
      
      public static const ATTRIBUTE_CONTENT_X:String = "contentX";
      
      public static const ATTRIBUTE_PAD_X:String = "padX";
      
      public static const ATTRIBUTE_PAD_Y:String = "padY";
      
      public static const ATTRIBUTE_RESIZE_CHILDREN:String = "resizeChildren";
      
      public static const ATTRIBUTE_ALIGN:String = "align";
      
      public static const ATTRIBUTE_VALIGN:String = "valign";
      
      private var m_gridX:int = 1;
      
      private var m_padX:int = 0;
      
      private var m_padY:int = 0;
      
      private var m_resizeChildren:Boolean = false;
      
      private var m_align:String = "left";
      
      private var m_valign:String = "top";
      
      public function GridController(param1:BaseWidgetView)
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
         if(param1 == ATTRIBUTE_CONTENT_X)
         {
            if(param2 is String)
            {
               this.m_gridX = parseInt(param2);
               this.alignChildren();
            }
            else if(param2 is Number)
            {
               this.m_gridX = param2;
               this.alignChildren();
            }
         }
         else if(param1 == ATTRIBUTE_PAD_X)
         {
            this.m_padX = parseInt(param2);
            this.alignChildren();
         }
         else if(param1 == ATTRIBUTE_PAD_Y)
         {
            this.m_padY = parseInt(param2);
            this.alignChildren();
         }
         else if(param1 == ATTRIBUTE_RESIZE_CHILDREN && param2 is String)
         {
            this.m_resizeChildren = Utility.stringIsTrue(param2);
         }
         else if(param1 == ATTRIBUTE_ALIGN && param2 is String)
         {
            this.m_align = param2;
            this.alignChildren();
         }
         else if(param1 == ATTRIBUTE_VALIGN && param2 is String)
         {
            this.m_valign = param2;
            this.alignChildren();
         }
         else
         {
            super.attribute(param1,param2);
         }
      }
      
      override public function getAttribute(param1:String) : *
      {
         var _loc2_:* = null;
         if(param1 == ATTRIBUTE_PAD_X)
         {
            _loc2_ = this.m_padX;
         }
         else if(param1 == ATTRIBUTE_PAD_Y)
         {
            _loc2_ = this.m_padY;
         }
         else if(param1 == ATTRIBUTE_CONTENT_X)
         {
            _loc2_ = this.m_gridX;
         }
         else if(param1 == ATTRIBUTE_ALIGN)
         {
            _loc2_ = this.m_align;
         }
         else if(param1 == ATTRIBUTE_VALIGN)
         {
            _loc2_ = this.m_valign;
         }
         else if(param1 == ATTRIBUTE_RESIZE_CHILDREN)
         {
            _loc2_ = this.m_resizeChildren;
         }
         else
         {
            _loc2_ = super.getAttribute(param1);
         }
         return _loc2_;
      }
      
      override protected function onChildViewResized(param1:WidgetViewEvent) : void
      {
         this.alignChildren();
      }
      
      private function alignChildren() : void
      {
         var _loc2_:BaseWidgetView = null;
         var _loc3_:Array = null;
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Rectangle = null;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc15_:int = 0;
         var _loc16_:int = 0;
         var _loc1_:Array = getViewChildren();
         if(_loc1_)
         {
            _loc3_ = [];
            _loc4_ = [];
            _loc5_ = 0;
            _loc6_ = 0;
            _loc7_ = 0;
            _loc5_ = 0;
            while(_loc5_ < _loc1_.length)
            {
               _loc2_ = _loc1_[_loc5_] as BaseWidgetView;
               _loc6_ = _loc5_ % this.m_gridX;
               _loc7_ = _loc5_ / this.m_gridX;
               if(_loc3_[_loc6_] == null)
               {
                  _loc3_.push(0);
               }
               if(_loc4_[_loc7_] == null)
               {
                  _loc4_.push(0);
               }
               if(Boolean(_loc2_) && Boolean(_loc2_.getSize()))
               {
                  _loc10_ = _loc2_.getAdjustedSize().width;
                  _loc11_ = _loc2_.getAdjustedSize().height;
                  if(_loc10_ > _loc3_[_loc6_] && Boolean(_loc2_.getAttribute(BaseWidgetView.ATTRIBUTE_OBSTRUCT)))
                  {
                     _loc3_[_loc6_] = _loc10_;
                  }
                  if(_loc11_ > _loc4_[_loc7_] && Boolean(_loc2_.getAttribute(BaseWidgetView.ATTRIBUTE_OBSTRUCT)))
                  {
                     _loc4_[_loc7_] = _loc11_;
                  }
               }
               _loc5_++;
            }
            if(_loc3_.length > 0)
            {
               _loc5_ = 0;
               while(_loc5_ < _loc1_.length)
               {
                  _loc2_ = _loc1_[_loc5_] as BaseWidgetView;
                  if(_loc2_)
                  {
                     _loc12_ = _loc2_.getAdjustedSize();
                     _loc6_ = _loc5_ % this.m_gridX;
                     _loc7_ = _loc5_ / this.m_gridX;
                     _loc13_ = 0;
                     _loc14_ = 0;
                     _loc15_ = 0;
                     while(_loc15_ < _loc6_)
                     {
                        _loc14_ += _loc3_[_loc15_] + this.m_padX;
                        _loc15_++;
                     }
                     if(_loc12_)
                     {
                        if(this.m_align == Constants.ALIGN_CENTER)
                        {
                           _loc13_ = _loc3_[_loc6_] - _loc12_.width >> 1;
                        }
                        else if(this.m_align == Constants.ALIGN_RIGHT)
                        {
                           _loc13_ = _loc3_[_loc6_] - _loc12_.width;
                        }
                     }
                     _loc2_.x = _loc14_ + _loc2_.getOffsetLeft() + _loc13_;
                     _loc13_ = 0;
                     _loc14_ = 0;
                     _loc16_ = 0;
                     while(_loc16_ < _loc7_)
                     {
                        _loc14_ += _loc4_[_loc16_] + this.m_padY;
                        _loc16_++;
                     }
                     if(_loc12_)
                     {
                        if(this.m_valign == Constants.ALIGN_CENTER)
                        {
                           _loc13_ = _loc4_[_loc7_] - _loc12_.height >> 1;
                        }
                        else if(this.m_valign == Constants.ALIGN_BOTTOM)
                        {
                           _loc13_ = _loc4_[_loc7_] - _loc12_.height;
                        }
                     }
                     _loc2_.y = _loc14_ + _loc2_.getOffsetTop() + _loc13_;
                     if(this.m_resizeChildren)
                     {
                        if(_loc12_ == null || _loc12_.width != _loc3_[_loc6_])
                        {
                           _loc2_.getController().setAttribute(ATTRIBUTE_WIDTH,_loc3_[_loc6_] - (_loc2_.getOffsetLeft() + _loc2_.getOffsetRight()));
                           _loc2_.getController().forceResize();
                        }
                        if(_loc12_ == null || _loc12_.height != _loc4_[_loc7_])
                        {
                           _loc2_.getController().setAttribute(ATTRIBUTE_HEIGHT,_loc4_[_loc7_] - (_loc2_.getOffsetTop() + _loc2_.getOffsetBottom()));
                        }
                     }
                  }
                  _loc5_++;
               }
            }
            _loc8_ = 0;
            _loc9_ = 0;
            _loc5_ = 0;
            while(_loc5_ < _loc3_.length)
            {
               _loc8_ += _loc3_[_loc5_];
               if(_loc5_ < _loc3_.length - 1)
               {
                  _loc8_ += this.m_padX;
               }
               _loc5_++;
            }
            _loc5_ = 0;
            while(_loc5_ < _loc4_.length)
            {
               _loc9_ += _loc4_[_loc5_];
               if(_loc5_ < _loc4_.length - 1)
               {
                  _loc9_ += this.m_padY;
               }
               _loc5_++;
            }
            m_view.setSize(new Rectangle(0,0,_loc8_,_loc9_));
         }
      }
   }
}

