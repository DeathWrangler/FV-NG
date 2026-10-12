package com.facebook.data.fbml
{
   [Bindable]
   public class AbstractTagData
   {
      
      public var type:String;
      
      public var description:String;
      
      public var name:String;
      
      public var header_fbml:String;
      
      public var attributes:AttributeCollection;
      
      public var is_public:String;
      
      public var footer_fbml:String;
      
      public function AbstractTagData(param1:String, param2:String, param3:String, param4:String, param5:String = "", param6:String = "", param7:AttributeCollection = null)
      {
         super();
         this.name = param1;
         this.type = param4;
         this.description = param5;
         this.is_public = param6;
         this.header_fbml = param2;
         this.footer_fbml = param3;
         this.attributes = param7;
      }
   }
}

