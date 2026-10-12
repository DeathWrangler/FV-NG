package com.troyer.widget.style
{
   import com.troyer.widget.Constants;
   import com.troyer.widget.MT4DContext;
   import com.troyer.widget.MT4DManager;
   import com.troyer.widget.parser.Utility;
   import flash.utils.Dictionary;
   
   public class DialogLook
   {
      
      public static const KEY_NAME:String = "name";
      
      public static const KEY_STYLE_MAPS:String = "styleMaps";
      
      public static const KEY_TO_STYLE:String = "toStyle";
      
      private var m_name:String;
      
      private var m_context:MT4DContext;
      
      private var m_styleMap:Dictionary;
      
      public function DialogLook(param1:MT4DContext = null)
      {
         super();
         if(param1 == null)
         {
            this.m_context = MT4DManager.getInstance().getDefaultContext();
         }
         else
         {
            this.m_context = param1;
         }
         this.m_styleMap = new Dictionary();
      }
      
      public function getName() : String
      {
         return this.m_name;
      }
      
      public function getContext() : MT4DContext
      {
         return this.m_context;
      }
      
      public function addStyleMap(param1:String, param2:String) : void
      {
         this.m_styleMap[param1] = param2;
      }
      
      public function removeStyleMap(param1:String) : void
      {
         delete this.m_styleMap[param1];
      }
      
      public function getStyleMap() : Dictionary
      {
         return this.m_styleMap;
      }
      
      public function getStyle(param1:String) : BaseStyle
      {
         var _loc2_:String = this.m_styleMap[param1];
         if(_loc2_ == null)
         {
            _loc2_ = param1;
         }
         return this.m_context.getStyle(_loc2_);
      }
      
      public function deserialize(param1:Dictionary) : void
      {
         if(param1.hasOwnProperty("name"))
         {
            this.m_name = param1.name;
         }
         if(param1.hasOwnProperty(Constants.TAG_DIALOG_LOOK))
         {
            this.m_styleMap = Utility.cloneDictionary(param1[Constants.TAG_DIALOG_LOOK]);
         }
      }
      
      public function serialize() : Dictionary
      {
         var _loc1_:Dictionary = new Dictionary();
         _loc1_[KEY_NAME] = this.m_name;
         _loc1_[KEY_STYLE_MAPS] = Utility.cloneDictionary(this.m_styleMap);
         return _loc1_;
      }
   }
}

