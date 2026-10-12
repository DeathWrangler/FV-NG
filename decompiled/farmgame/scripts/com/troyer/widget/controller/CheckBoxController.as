package com.troyer.widget.controller
{
   import com.troyer.widget.parser.Utility;
   import com.troyer.widget.view.BaseWidgetView;
   import flash.events.MouseEvent;
   
   public class CheckBoxController extends ButtonController
   {
      
      public static const ATTRIBUTE_CHECKED:String = "checked";
      
      public static const ATTRIBUTE_TARGET_VIEW:String = "targetView";
      
      protected var m_isChecked:Boolean = true;
      
      protected var m_viewToToggle:BaseWidgetController = null;
      
      public function CheckBoxController(param1:BaseWidgetView)
      {
         super(param1);
      }
      
      override public function getAttributeOrder() : Array
      {
         var _loc1_:Array = super.getAttributeOrder();
         _loc1_.push(ATTRIBUTE_TARGET_VIEW,ATTRIBUTE_CHECKED);
         return _loc1_;
      }
      
      override protected function onMouseUp(param1:MouseEvent) : void
      {
         if(!m_disabled)
         {
            if(m_mouseDown)
            {
               this.m_isChecked = !this.m_isChecked;
               this.updateCheck();
            }
         }
         super.onMouseUp(param1);
      }
      
      override protected function attribute(param1:String, param2:*) : void
      {
         if(param1 == ATTRIBUTE_CHECKED)
         {
            if(param2 is Boolean)
            {
               this.m_isChecked = param2;
            }
            else if(param2 is String)
            {
               this.m_isChecked = Utility.stringIsTrue(param2);
            }
            this.updateCheck();
         }
         else if(param1 == ATTRIBUTE_TARGET_VIEW && param2 is String)
         {
            this.m_viewToToggle = this.getChildController(param2);
         }
         else
         {
            super.attribute(param1,param2);
         }
      }
      
      override public function getAttribute(param1:String) : *
      {
         var _loc2_:* = null;
         if(param1 == ATTRIBUTE_CHECKED)
         {
            _loc2_ = this.m_isChecked;
         }
         else
         {
            _loc2_ = super.getAttribute(param1);
         }
         return _loc2_;
      }
      
      protected function updateCheck() : void
      {
         if(this.m_viewToToggle)
         {
            this.m_viewToToggle.setAttribute(BaseWidgetView.ATTRIBUTE_VISIBLE,this.m_isChecked);
         }
      }
   }
}

