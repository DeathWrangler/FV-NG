package com.troyer.widget.controller
{
   import com.troyer.widget.MT4DManager;
   import com.troyer.widget.event.WidgetControllerEvent;
   import com.troyer.widget.style.BaseStyle;
   import com.troyer.widget.view.BaseWidgetView;
   import com.troyer.widget.view.TextFieldView;
   
   public class ListController extends BaseWidgetController
   {
      
      public static const ATTRIBUTE_VIEW_BUTTON:String = "viewButton";
      
      public static const ATTRIBUTE_STYLE_SELECTION:String = "styleSelection";
      
      public static const ATTRIBUTE_CONTENT:String = "content";
      
      public static const ATTRIBUTE_OPTIONS:String = "options";
      
      public static const ATTRIBUTE_SELECTED:String = "selected";
      
      public static const ATTRIBUTE_DELIMITER:String = "delimiter";
      
      private static const BUTTON_PREFIX:String = "button";
      
      private var m_contentController:PositionController;
      
      private var m_buttonReference:ButtonController;
      
      private var m_selectionStyle:BaseStyle;
      
      protected var m_currentSelectedButton:ButtonController;
      
      protected var m_optionString:String;
      
      protected var m_options:Array;
      
      private var m_contentPath:String;
      
      protected var m_delimiter:String = ",";
      
      public function ListController(param1:BaseWidgetView)
      {
         super(param1);
      }
      
      override public function destroy() : void
      {
         this.m_contentController = null;
         this.m_buttonReference = null;
         this.m_options = null;
         super.destroy();
      }
      
      override public function getAttributeOrder() : Array
      {
         var _loc1_:Array = super.getAttributeOrder();
         _loc1_.push(ATTRIBUTE_VIEW_BUTTON,ATTRIBUTE_CONTENT,ATTRIBUTE_DELIMITER,ATTRIBUTE_OPTIONS);
         return _loc1_;
      }
      
      override protected function attribute(param1:String, param2:*) : void
      {
         var _loc3_:ButtonController = null;
         var _loc4_:ButtonController = null;
         if(param1 == ATTRIBUTE_OPTIONS && param2 is String)
         {
            this.m_optionString = param2;
            this.m_options = String(param2).split(this.m_delimiter);
            this.updateOptions();
         }
         else if(param1 == ATTRIBUTE_VIEW_BUTTON && param2 is BaseWidgetView)
         {
            this.m_buttonReference = BaseWidgetView(param2).getController() as ButtonController;
            if(!this.m_buttonReference)
            {
               addError("ListController \'" + m_name + "\' passed attribute " + param1 + " that isn\'t a view with a ButtonController.");
            }
         }
         else if(param1 == ATTRIBUTE_DELIMITER && param2 is String)
         {
            this.m_delimiter = param2;
         }
         else if(param1 == ATTRIBUTE_STYLE_SELECTION && param2 is BaseStyle)
         {
            this.m_selectionStyle = param2;
         }
         else if(param1 == ATTRIBUTE_CONTENT && param2 is String)
         {
            this.m_contentPath = param2;
            this.m_contentController = getChildController(param2) as PositionController;
         }
         else if(param1 == ATTRIBUTE_SELECTED)
         {
            if(param2 is String)
            {
               _loc3_ = getChildController(this.m_contentPath + "." + param2) as ButtonController;
               if(_loc3_)
               {
                  this.selectOptionController(_loc3_);
               }
               else
               {
                  addError("ListController \'" + m_name + "\' passed attribute " + param1 + " with invalid ButtonController path: " + param2);
               }
            }
            else if(param2 is ButtonController)
            {
               this.selectOptionController(param2);
            }
            else if(param2 is Number)
            {
               _loc4_ = getChildController(this.m_contentPath + "." + BUTTON_PREFIX + param2) as ButtonController;
               if(_loc4_)
               {
                  this.selectOptionController(_loc4_);
               }
               else
               {
                  addError("ListController \'" + m_name + "\' passed attribute " + param1 + " with invalid ButtonController path: " + param2);
               }
            }
            else
            {
               addError("ListController \'" + m_name + "\' passed attribute " + param1 + " with an invalid value");
            }
         }
         else
         {
            super.attribute(param1,param2);
         }
      }
      
      override public function getAttribute(param1:String) : *
      {
         var _loc2_:* = null;
         if(param1 == ATTRIBUTE_OPTIONS)
         {
            _loc2_ = this.m_optionString;
         }
         else
         {
            _loc2_ = super.getAttribute(param1);
         }
         return _loc2_;
      }
      
      protected function updateOptions() : void
      {
         var _loc1_:String = null;
         var _loc2_:Number = NaN;
         var _loc3_:* = 0;
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         var _loc6_:ButtonController = null;
         var _loc7_:String = null;
         var _loc8_:BaseWidgetController = null;
         var _loc9_:BaseWidgetController = null;
         if(Boolean(this.m_buttonReference && this.m_contentController) && Boolean(this.m_options) && this.m_options.length > 0)
         {
            if(this.m_currentSelectedButton)
            {
               _loc1_ = this.m_currentSelectedButton.getAttribute(TextFieldView.ATTRIBUTE_TEXT);
            }
            this.m_contentController.removeChildControllers();
            _loc2_ = 0;
            _loc3_ = 0;
            _loc4_ = [];
            _loc5_ = 0;
            while(_loc5_ < this.m_options.length)
            {
               _loc7_ = this.m_options[_loc5_];
               _loc8_ = this.m_buttonReference.clone();
               _loc8_.index = _loc5_;
               _loc8_.setAttribute(BaseWidgetController.ATTRIBUTE_NAME,BUTTON_PREFIX + _loc3_++);
               _loc8_.setAttribute(TextFieldView.ATTRIBUTE_TEXT,_loc7_);
               if(_loc1_ == _loc7_)
               {
                  this.selectOptionController(_loc8_ as ButtonController);
               }
               _loc8_.addEventListener(WidgetControllerEvent.BUTTON_PRESSED,this.onOptionSelected);
               this.m_contentController.addChildController(_loc8_);
               _loc4_.push(_loc8_);
               if(_loc8_.getView().width > _loc2_)
               {
                  _loc2_ = _loc8_.getView().width;
               }
               _loc5_++;
            }
            for each(_loc6_ in _loc4_)
            {
               _loc9_ = _loc6_.getAttribute(ButtonController.ATTRIBUTE_CONTENT);
               if(_loc9_)
               {
                  if(!m_view.hasFixedWidth())
                  {
                     _loc9_.setAttribute(TextFieldView.ATTRIBUTE_WORD_WRAP,"false");
                  }
                  if(_loc9_.getView().getSize().width != _loc2_)
                  {
                     _loc9_.setAttribute(BaseWidgetController.ATTRIBUTE_FORCE_WIDTH,_loc2_);
                  }
               }
               else
               {
                  addError("Couldn\'t find textfield in " + _loc6_.getName());
               }
            }
         }
      }
      
      private function selectOptionController(param1:ButtonController) : void
      {
         if(this.m_currentSelectedButton)
         {
            this.m_currentSelectedButton.setAttribute(BaseWidgetView.ATTRIBUTE_STYLE,this.m_buttonReference.getView().getStyle());
         }
         this.m_currentSelectedButton = param1;
         if(this.m_selectionStyle)
         {
            this.m_currentSelectedButton.setAttribute(BaseWidgetView.ATTRIBUTE_STYLE,this.m_selectionStyle);
         }
         dispatchEvent(new WidgetControllerEvent(WidgetControllerEvent.BUTTON_PRESSED,this.m_currentSelectedButton));
      }
      
      private function onOptionSelected(param1:WidgetControllerEvent) : void
      {
         var _loc2_:ButtonController = param1.getController() as ButtonController;
         var _loc3_:int = parseInt(_loc2_.getName().substring(BUTTON_PREFIX.length));
         this.selectOptionController(_loc2_);
         MT4DManager.getInstance().dispatchEvent(new WidgetControllerEvent(WidgetControllerEvent.BUTTON_PRESSED,this.m_currentSelectedButton));
      }
   }
}

