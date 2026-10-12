package com.troyer.widget.controller
{
   import com.troyer.widget.MT4DManager;
   import com.troyer.widget.parser.Utility;
   import com.troyer.widget.view.BaseWidgetView;
   import com.troyer.widget.view.TextFieldView;
   
   public class FrameController extends BaseWidgetController
   {
      
      public static const ATTRIBUTE_TITLE_CONTENT:String = "titleContent";
      
      public static const ATTRIBUTE_TITLE:String = "title";
      
      public static const ATTRIBUTE_IMAGE_CONTENT:String = "imageContent";
      
      public static const ATTRIBUTE_IMAGE_SOURCE:String = "imageSrc";
      
      private var m_titleText:String;
      
      private var m_titleController:BaseWidgetController;
      
      private var m_imageSrc:String;
      
      private var m_imageController:BaseWidgetController;
      
      public function FrameController(param1:BaseWidgetView)
      {
         super(param1);
      }
      
      override public function destroy() : void
      {
         this.m_titleController = null;
         this.m_imageController = null;
         super.destroy();
      }
      
      override public function onSkinExpanded(param1:BaseWidgetView, param2:BaseWidgetView) : void
      {
         this.m_titleController = param1.getController().findChildControllerByName("@" + ATTRIBUTE_TITLE_CONTENT);
         this.m_imageController = param1.getController().findChildControllerByName("@" + ATTRIBUTE_IMAGE_CONTENT);
      }
      
      override public function getAttributeOrder() : Array
      {
         var _loc1_:Array = super.getAttributeOrder();
         _loc1_.push(ATTRIBUTE_TITLE_CONTENT,ATTRIBUTE_TITLE,ATTRIBUTE_IMAGE_CONTENT,ATTRIBUTE_IMAGE_SOURCE);
         return _loc1_;
      }
      
      override protected function attribute(param1:String, param2:*) : void
      {
         if(param1 == ATTRIBUTE_TITLE_CONTENT)
         {
            this.m_titleController = getChildController(param2);
            if(!this.m_titleController)
            {
               addError("Unable to set title content \'" + param2 + "\' for frame \'" + m_name + "\'.");
            }
         }
         else if(param1 == ATTRIBUTE_TITLE)
         {
            this.m_titleText = param2 as String;
            if(this.m_titleController)
            {
               this.m_titleController.setAttribute(TextFieldView.ATTRIBUTE_TEXT,param2);
            }
         }
         else if(param1 == ATTRIBUTE_IMAGE_CONTENT)
         {
            this.m_imageController = getChildController(param2);
            if(!this.m_imageController)
            {
               addError("Unable to set image content \'" + param2 + "\' for frame \'" + m_name + "\'.");
            }
         }
         else if(param1 == ATTRIBUTE_IMAGE_SOURCE)
         {
            this.m_imageSrc = param2 as String;
            if(this.m_imageController)
            {
               this.m_imageController.setAttribute(ImageController.ATTRIBUTE_SOURCE,param2);
            }
         }
         else
         {
            super.attribute(param1,param2);
         }
      }
      
      override public function getAttribute(param1:String) : *
      {
         if(param1 == ATTRIBUTE_TITLE_CONTENT)
         {
            return this.m_titleController;
         }
         if(param1 == ATTRIBUTE_TITLE)
         {
            return this.m_titleText;
         }
         if(param1 == ATTRIBUTE_IMAGE_CONTENT)
         {
            return this.m_imageController;
         }
         if(param1 == ATTRIBUTE_IMAGE_SOURCE)
         {
            return this.m_imageSrc;
         }
         return super.getAttribute(param1);
      }
      
      override public function localizeAttributeValue(param1:MT4DManager, param2:String, param3:String) : String
      {
         if(param2 == ATTRIBUTE_TITLE)
         {
            return Utility.localizeAttributeValue(param1.config,param3);
         }
         return super.localizeAttributeValue(param1,param2,param3);
      }
   }
}

