package com.troyer.widget.controller
{
   import com.troyer.widget.MT4DManager;
   import com.troyer.widget.event.WidgetControllerEvent;
   import com.troyer.widget.parser.Utility;
   import com.troyer.widget.style.BaseStyle;
   import com.troyer.widget.view.BaseWidgetView;
   import flash.events.MouseEvent;
   
   public class ButtonController extends BaseWidgetController
   {
      
      public static const ATTRIBUTE_TEXT:String = "text";
      
      public static const ATTRIBUTE_CONTENT:String = "content";
      
      public static const ATTRIBUTE_IMAGE_CONTENT:String = "imageContent";
      
      public static const ATTRIBUTE_IMAGE_SOURCE:String = "imageSrc";
      
      public static const ATTRIBUTE_BASE:String = "base";
      
      public static const ATTRIBUTE_STYLE:String = "style";
      
      public static const ATTRIBUTE_STYLE_OVER:String = "styleOver";
      
      public static const ATTRIBUTE_STYLE_DOWN:String = "styleDown";
      
      public static const ATTRIBUTE_STYLE_DISABLED:String = "styleDisabled";
      
      public static const ATTRIBUTE_DISABLED:String = "disabled";
      
      private var m_baseController:BaseWidgetController;
      
      protected var m_contentController:BaseWidgetController;
      
      private var m_imageController:BaseWidgetController;
      
      private var m_defaultStyle:BaseStyle;
      
      private var m_downStyle:BaseStyle;
      
      private var m_rolloverStyle:BaseStyle;
      
      private var m_disabledStyle:BaseStyle;
      
      private var m_imageSrc:String;
      
      protected var m_mouseDown:Boolean;
      
      protected var m_disabled:Boolean = false;
      
      public function ButtonController(param1:BaseWidgetView)
      {
         super(param1);
         addGlobalListener(WidgetControllerEvent.BUTTON_PRESSED);
      }
      
      override public function initialize() : void
      {
         super.initialize();
         this.m_view.mouseChildren = this.m_view.tabChildren = false;
         addViewListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         addViewListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         addViewListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         addViewListener(MouseEvent.MOUSE_UP,this.onMouseUp);
      }
      
      override public function destroy() : void
      {
         this.m_contentController = null;
         this.m_imageController = null;
         super.destroy();
      }
      
      override public function getAttributeOrder() : Array
      {
         var _loc1_:Array = super.getAttributeOrder();
         _loc1_.push(ATTRIBUTE_BASE,ATTRIBUTE_CONTENT,ATTRIBUTE_STYLE,ATTRIBUTE_STYLE_DISABLED,ATTRIBUTE_DISABLED);
         return _loc1_;
      }
      
      override public function onSkinExpanded(param1:BaseWidgetView, param2:BaseWidgetView) : void
      {
         this.m_baseController = param1.getController().findChildControllerByName("@" + ATTRIBUTE_BASE);
         this.m_contentController = param1.getController().findChildControllerByName("@" + ATTRIBUTE_CONTENT);
         this.m_imageController = param1.getController().findChildControllerByName("@" + ATTRIBUTE_IMAGE_CONTENT);
      }
      
      override protected function attribute(param1:String, param2:*) : void
      {
         var _loc3_:BaseWidgetView = null;
         switch(param1)
         {
            case ATTRIBUTE_BASE:
               this.m_baseController = getChildController(param2);
               if(this.m_baseController)
               {
                  _loc3_ = this.m_baseController.getView();
                  _loc3_.mouseChildren = _loc3_.tabChildren = false;
               }
               break;
            case ATTRIBUTE_CONTENT:
               this.m_contentController = getChildController(param2);
               if(!this.m_contentController)
               {
                  addError("Unable to set content text \'" + param2 + "\' for button \'" + m_name + "\'.");
               }
               break;
            case ATTRIBUTE_IMAGE_CONTENT:
               this.m_imageController = getChildController(param2);
               if(!this.m_imageController)
               {
                  addError("Unable to set image content \'" + param2 + "\' for button \'" + m_name + "\'.");
               }
               break;
            case ATTRIBUTE_IMAGE_SOURCE:
               this.m_imageSrc = param2 as String;
               if(this.m_imageController)
               {
                  this.m_imageController.setAttribute(ImageController.ATTRIBUTE_SOURCE,param2);
               }
               break;
            case ATTRIBUTE_DISABLED:
               if(param2 is String)
               {
                  this.m_disabled = Utility.stringIsTrue(param2);
               }
               else if(param2 is Boolean)
               {
                  this.m_disabled = param2;
               }
               if(this.m_disabled && Boolean(this.m_disabledStyle))
               {
                  this.applyStyle(this.m_disabledStyle);
               }
               else if(this.m_defaultStyle)
               {
                  this.applyStyle(this.m_defaultStyle);
               }
               break;
            case ATTRIBUTE_STYLE:
            case ATTRIBUTE_STYLE_OVER:
            case ATTRIBUTE_STYLE_DOWN:
            case ATTRIBUTE_STYLE_DISABLED:
               if(param2 is BaseStyle || param2 == null)
               {
                  if(param1 == ATTRIBUTE_STYLE)
                  {
                     this.m_defaultStyle = param2;
                     if(this.m_contentController)
                     {
                        this.m_contentController.setAttribute(param1,param2);
                     }
                     if(this.m_baseController)
                     {
                        this.m_baseController.setAttribute(param1,param2);
                     }
                  }
                  else if(param1 == ATTRIBUTE_STYLE_OVER)
                  {
                     this.m_rolloverStyle = param2;
                  }
                  else if(param1 == ATTRIBUTE_STYLE_DOWN)
                  {
                     this.m_downStyle = param2;
                  }
                  else if(param1 == ATTRIBUTE_STYLE_DISABLED)
                  {
                     this.m_disabledStyle = param2;
                  }
                  else
                  {
                     super.attribute(param1,param2);
                  }
               }
               else
               {
                  addError("Button \'" + m_name + "\' set bad attribute " + param1 + " with value: " + param2);
               }
               break;
            case ATTRIBUTE_TEXT:
            case ATTRIBUTE_FORCE_WIDTH:
            case ATTRIBUTE_FORCE_HEIGHT:
               if(this.m_contentController)
               {
                  this.m_contentController.setAttribute(param1,param2);
               }
               break;
            default:
               super.attribute(param1,param2);
         }
      }
      
      override public function getAttribute(param1:String) : *
      {
         var _loc2_:* = null;
         if(param1 == ATTRIBUTE_CONTENT)
         {
            _loc2_ = this.m_contentController;
         }
         else if(param1 == ATTRIBUTE_TEXT)
         {
            if(this.m_contentController)
            {
               _loc2_ = this.m_contentController.getAttribute(param1);
            }
         }
         else if(param1 == ATTRIBUTE_DISABLED)
         {
            _loc2_ = this.m_disabled;
         }
         else
         {
            _loc2_ = super.getAttribute(param1);
         }
         return _loc2_;
      }
      
      private function applyStyle(param1:BaseStyle) : void
      {
         if(param1)
         {
            if(this.m_contentController)
            {
               this.m_contentController.getView().setStyle(param1);
            }
            if(this.m_baseController)
            {
               this.m_baseController.getView().setStyle(param1);
            }
         }
      }
      
      protected function onMouseOver(param1:MouseEvent) : void
      {
         if(!this.m_disabled)
         {
            this.applyStyle(this.m_rolloverStyle);
            dispatchEvent(new WidgetControllerEvent(WidgetControllerEvent.MOUSE_OVER,this));
         }
      }
      
      protected function onMouseOut(param1:MouseEvent) : void
      {
         if(!this.m_disabled)
         {
            this.applyStyle(this.m_defaultStyle);
            this.m_mouseDown = false;
            dispatchEvent(new WidgetControllerEvent(WidgetControllerEvent.MOUSE_OUT,this));
         }
      }
      
      protected function onMouseDown(param1:MouseEvent) : void
      {
         if(!this.m_disabled)
         {
            this.applyStyle(this.m_downStyle);
            this.m_mouseDown = true;
            param1.stopImmediatePropagation();
         }
      }
      
      protected function onMouseUp(param1:MouseEvent) : void
      {
         if(!this.m_disabled)
         {
            this.applyStyle(this.m_rolloverStyle);
            if(this.m_mouseDown)
            {
               dispatchEvent(new WidgetControllerEvent(WidgetControllerEvent.BUTTON_PRESSED,this));
               MT4DManager.getInstance().dispatchEvent(new WidgetControllerEvent(WidgetControllerEvent.BUTTON_PRESSED,this));
            }
         }
      }
      
      override public function localizeAttributeValue(param1:MT4DManager, param2:String, param3:String) : String
      {
         if(param2 == ATTRIBUTE_TEXT)
         {
            return Utility.localizeAttributeValue(param1.config,param3);
         }
         return super.localizeAttributeValue(param1,param2,param3);
      }
   }
}

