package com.facebook.data.feed
{
   import com.facebook.utils.FacebookArrayCollection;
   
   [Bindable]
   public class TemplateCollection extends FacebookArrayCollection
   {
      
      public var template_bundle_id:Number;
      
      public var time_created:Date;
      
      public function TemplateCollection()
      {
         super(null,TemplateData);
      }
      
      public function addTemplateData(param1:TemplateData) : void
      {
         this.addItem(param1);
      }
   }
}

