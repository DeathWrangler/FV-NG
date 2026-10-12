package com.troyer.widget.controller
{
   import com.troyer.widget.event.WidgetViewEvent;
   import com.troyer.widget.parser.Utility;
   import com.troyer.widget.view.BaseWidgetView;
   import flash.geom.Rectangle;
   
   public class MaskController extends ResizeController
   {
      
      public static const ATTRIBUTE_MASK:String = "mask";
      
      public static const ATTRIBUTE_IMAGE:String = "image";
      
      public static const ATTRIBUTE_IMAGE_AS_CONTENT:String = "imageAsContent";
      
      private var m_maskView:BaseWidgetView;
      
      private var m_imageView:BaseWidgetView;
      
      private var m_useImageAsContent:Boolean = false;
      
      public function MaskController(param1:BaseWidgetView)
      {
         super(param1);
      }
      
      override public function destroy() : void
      {
         this.m_maskView = null;
         this.m_imageView = null;
         super.destroy();
      }
      
      override public function getAttributeOrder() : Array
      {
         var _loc1_:Array = super.getAttributeOrder();
         _loc1_.push(ATTRIBUTE_IMAGE,ATTRIBUTE_MASK);
         return _loc1_;
      }
      
      override public function getAttribute(param1:String) : *
      {
         var _loc2_:* = null;
         if(param1 == ATTRIBUTE_MASK)
         {
            _loc2_ = this.m_maskView;
         }
         else if(param1 == ATTRIBUTE_IMAGE)
         {
            _loc2_ = this.m_imageView;
         }
         else if(param1 == ATTRIBUTE_IMAGE_AS_CONTENT)
         {
            _loc2_ = this.m_useImageAsContent;
         }
         else
         {
            _loc2_ = super.getAttribute(param1);
         }
         return _loc2_;
      }
      
      override protected function attribute(param1:String, param2:*) : void
      {
         var _loc3_:BaseWidgetController = null;
         var _loc4_:BaseWidgetController = null;
         if(param1 == ATTRIBUTE_MASK && param2 is String)
         {
            _loc3_ = getChildController(param2);
            if(_loc3_)
            {
               this.m_maskView = _loc3_.getView();
               this.updateMask();
            }
         }
         else if(param1 == ATTRIBUTE_IMAGE && param2 is String)
         {
            _loc4_ = getChildController(param2);
            if(_loc4_)
            {
               this.m_imageView = _loc4_.getView();
               this.updateMask();
            }
         }
         else if(param1 == ATTRIBUTE_IMAGE_AS_CONTENT)
         {
            if(param2 is String)
            {
               this.m_useImageAsContent = Utility.stringIsTrue(param2);
            }
            else if(param2 is Boolean)
            {
               this.m_useImageAsContent = param2;
            }
         }
         else if(param1 == ATTRIBUTE_PAD_X || param1 == ATTRIBUTE_PAD_Y)
         {
            super.attribute(param1,param2);
            this.updateMask();
         }
         else
         {
            super.attribute(param1,param2);
         }
      }
      
      override protected function onChildViewResized(param1:WidgetViewEvent) : void
      {
         var _loc3_:Rectangle = null;
         var _loc2_:Boolean = false;
         if(param1)
         {
            if(Boolean(this.m_maskView) && Boolean(param1.getView() == this.m_maskView) || Boolean(this.m_imageView) && Boolean(param1.getView() == this.m_imageView) || this.m_useImageAsContent)
            {
               _loc2_ = true;
            }
         }
         if(_loc2_ == false)
         {
            super.onChildViewResized(param1);
            this.updateMask();
         }
         else if(this.m_useImageAsContent)
         {
            if(Boolean(this.m_imageView) && Boolean(this.m_maskView))
            {
               _loc3_ = this.m_imageView.getSize();
               if(_loc3_)
               {
                  _loc3_ = _loc3_.clone();
                  this.m_imageView.mask = this.m_maskView;
                  this.m_maskView.setSize(_loc3_);
                  this.m_maskView.getController().forceResize();
                  this.m_view.setSize(_loc3_);
               }
            }
         }
         else
         {
            this.updateMask();
         }
      }
      
      override protected function getEligibleChildren() : Array
      {
         var _loc2_:int = 0;
         var _loc1_:Array = getViewChildren();
         if(this.m_imageView)
         {
            _loc2_ = _loc1_.indexOf(this.m_imageView);
            if(_loc2_ != -1)
            {
               _loc1_.splice(_loc2_,1);
            }
         }
         if(this.m_maskView)
         {
            _loc2_ = _loc1_.indexOf(this.m_maskView);
            if(_loc2_ != -1)
            {
               _loc1_.splice(_loc2_,1);
            }
         }
         return _loc1_;
      }
      
      private function updateMask() : void
      {
         var _loc2_:Rectangle = null;
         var _loc3_:Rectangle = null;
         var _loc1_:Rectangle = m_view.getSize();
         if(_loc1_)
         {
            if(this.m_imageView)
            {
               if(this.m_imageView.parent == null)
               {
                  m_view.addChild(this.m_imageView);
               }
               _loc2_ = this.m_imageView.getSize();
               if(_loc2_ == null || _loc2_.equals(_loc1_) == false)
               {
                  this.m_imageView.setSize(_loc1_);
                  this.m_imageView.getController().forceResize();
               }
               if(this.m_maskView)
               {
                  if(this.m_maskView.parent == null)
                  {
                     this.m_imageView.addChild(this.m_maskView);
                  }
                  _loc3_ = this.m_maskView.getSize();
                  if(_loc3_ == null || _loc3_.equals(_loc1_) == false)
                  {
                     this.m_maskView.setSize(_loc1_);
                     this.m_maskView.getController().forceResize();
                  }
               }
               this.m_imageView.mask = this.m_maskView;
            }
         }
      }
   }
}

