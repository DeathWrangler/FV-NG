package com.troyer.widget.controller
{
   import com.troyer.widget.event.WidgetControllerEvent;
   import com.troyer.widget.view.BaseWidgetView;
   import com.troyer.widget.view.TextFieldView;
   
   public class DropDownController extends BaseWidgetController
   {
      
      public static const ATTRIBUTE_LIST:String = "list";
      
      public static const ATTRIBUTE_TEXTFIELD:String = "textfield";
      
      public static const ATTRIBUTE_BUTTON:String = "button";
      
      public static const ATTRIBUTE_OPTIONS:String = "options";
      
      public static const ATTRIBUTE_TEXT:String = "text";
      
      private var m_button:ButtonController;
      
      private var m_textFieldController:BaseWidgetController;
      
      private var m_listController:ListController;
      
      public function DropDownController(param1:BaseWidgetView)
      {
         super(param1);
      }
      
      override public function getAttributeOrder() : Array
      {
         var _loc1_:Array = super.getAttributeOrder();
         _loc1_.push(ATTRIBUTE_LIST,ATTRIBUTE_TEXTFIELD,ATTRIBUTE_BUTTON);
         return _loc1_;
      }
      
      override protected function attribute(param1:String, param2:*) : void
      {
         if(param1 == ATTRIBUTE_TEXTFIELD && param2 is String)
         {
            this.m_textFieldController = getChildController(param2) as BaseWidgetController;
         }
         else if(param1 == ATTRIBUTE_LIST && param2 is String)
         {
            this.m_listController = getChildController(param2) as ListController;
            if(this.m_listController)
            {
               addListener(this.m_listController,WidgetControllerEvent.BUTTON_PRESSED,this.onListItemSelected);
            }
            else
            {
               addError("Invalid value for parameter " + param1 + " in view \'" + m_name + "\'. Expected ListController view.");
            }
         }
         else if(param1 == ATTRIBUTE_BUTTON)
         {
            this.m_button = getChildController(param2) as ButtonController;
            if(this.m_button)
            {
               addListener(this.m_button,WidgetControllerEvent.BUTTON_PRESSED,this.onButtonPressed);
            }
            else
            {
               addError("Invalue value for paramater " + param1 + " in view \'" + m_name + "\'. Expected ButtonController view.");
            }
         }
         else if(param1 == ATTRIBUTE_OPTIONS)
         {
            if(this.m_listController)
            {
               this.m_listController.setAttribute(param1,param2);
            }
            else
            {
               addError("No list controller set in \'" + m_name + "\' for attribute " + param1 + " to work.");
            }
         }
         else if(param1 == ATTRIBUTE_TEXT && param2 is String)
         {
            if(this.m_textFieldController)
            {
               this.m_textFieldController.setAttribute(TextFieldView.ATTRIBUTE_TEXT,param2);
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
         if(param1 == ATTRIBUTE_TEXTFIELD)
         {
            return this.m_textFieldController;
         }
         if(param1 == ATTRIBUTE_LIST)
         {
            _loc2_ = this.m_listController;
         }
         else if(param1 == ATTRIBUTE_BUTTON)
         {
            _loc2_ = this.m_button;
         }
         else if(param1 == ATTRIBUTE_TEXT)
         {
            if(this.m_textFieldController)
            {
               _loc2_ = this.m_textFieldController.getAttribute(TextFieldView.ATTRIBUTE_TEXT);
            }
            else
            {
               addError("No textfield found to get attribute " + param1 + " in view " + m_name);
            }
         }
         else
         {
            _loc2_ = super.getAttribute(param1);
         }
         return _loc2_;
      }
      
      private function setListVisible(param1:Boolean) : void
      {
         if(this.m_listController)
         {
            this.m_listController.setAttribute(BaseWidgetView.ATTRIBUTE_VISIBLE,param1);
         }
      }
      
      private function onListItemSelected(param1:WidgetControllerEvent) : void
      {
         var _loc2_:String = null;
         if(this.m_textFieldController)
         {
            _loc2_ = param1.getController().getAttribute(ButtonController.ATTRIBUTE_TEXT) as String;
            if(_loc2_)
            {
               this.m_textFieldController.setAttribute(ButtonController.ATTRIBUTE_TEXT,_loc2_);
               dispatchEvent(new WidgetControllerEvent(WidgetControllerEvent.BUTTON_PRESSED,this));
            }
            else
            {
               addError("Selected drop down option is not valid.");
            }
         }
         this.setListVisible(false);
      }
      
      private function onButtonPressed(param1:WidgetControllerEvent) : void
      {
         var _loc2_:Boolean = false;
         if(this.m_listController)
         {
            _loc2_ = this.m_listController.getAttribute(BaseWidgetView.ATTRIBUTE_VISIBLE);
            this.setListVisible(!_loc2_);
         }
      }
   }
}

