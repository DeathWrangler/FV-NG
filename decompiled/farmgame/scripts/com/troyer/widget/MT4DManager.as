package com.troyer.widget
{
   import com.troyer.widget.controller.DynamicDialog;
   import com.troyer.widget.parser.DynamicClasses;
   import com.troyer.widget.parser.ParserErrorList;
   import com.troyer.widget.style.BaseStyle;
   import com.troyer.widget.style.DialogLook;
   import com.troyer.widget.view.BaseWidgetView;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   
   public class MT4DManager extends EventDispatcher
   {
      
      private static var m_dynamics:DynamicClasses;
      
      private static var m_instance:MT4DManager;
      
      public static const CONTEXT_DEFAULT:String = "default";
      
      public static const CONTEXT_EDITING:String = "editing";
      
      private var m_contexts:Dictionary;
      
      private var m_defaultContext:MT4DContext;
      
      internal var m_errorList:ParserErrorList;
      
      private var m_config:MT4DConfig;
      
      public function MT4DManager()
      {
         super();
         this.m_contexts = new Dictionary();
         this.m_defaultContext = new MT4DContext("default");
         this.m_contexts[this.m_defaultContext.getName()] = this.m_defaultContext;
         this.m_errorList = new ParserErrorList();
         m_instance = this;
      }
      
      public static function initialize() : void
      {
         getInstance();
      }
      
      public static function getInstance() : MT4DManager
      {
         if(!m_instance)
         {
            new MT4DManager();
         }
         return m_instance;
      }
      
      public function reset() : void
      {
         var _loc1_:MT4DContext = null;
         for each(_loc1_ in this.m_contexts)
         {
            _loc1_.destroy();
         }
         this.m_contexts = new Dictionary();
         this.m_defaultContext = new MT4DContext("default");
         this.m_contexts[this.m_defaultContext.getName()] = this.m_defaultContext;
         this.m_errorList = new ParserErrorList();
      }
      
      public function destroy() : void
      {
         var _loc1_:MT4DContext = null;
         for each(_loc1_ in this.m_contexts)
         {
            _loc1_.destroy();
         }
         this.m_contexts = null;
         this.m_errorList = null;
         m_instance = null;
         this.m_config = null;
      }
      
      public function setConfig(param1:MT4DConfig) : void
      {
         if(param1)
         {
            this.m_config = param1;
         }
      }
      
      public function get config() : MT4DConfig
      {
         return this.m_config;
      }
      
      public function getContextByName(param1:String) : MT4DContext
      {
         return this.m_contexts[param1];
      }
      
      public function addContext(param1:MT4DContext) : void
      {
         this.m_contexts[param1.getName()] = param1;
      }
      
      public function removeContext(param1:MT4DContext) : void
      {
         delete this.m_contexts[param1.getName()];
      }
      
      public function getDefaultContext() : MT4DContext
      {
         return this.m_defaultContext;
      }
      
      public function findViewDefinition(param1:String) : Dictionary
      {
         return this.m_defaultContext.findViewDefinition(param1);
      }
      
      public function getStyle(param1:String) : BaseStyle
      {
         return this.m_defaultContext.getStyle(param1);
      }
      
      public function getStyleNames() : Array
      {
         return this.m_defaultContext.getStyleNames();
      }
      
      public function getLook(param1:String) : DialogLook
      {
         return this.m_defaultContext.getLook(param1);
      }
      
      public function getDefaultLook() : DialogLook
      {
         return this.m_defaultContext.getDefaultLook();
      }
      
      public function getView(param1:String, param2:DialogLook = null) : BaseWidgetView
      {
         return this.m_defaultContext.getView(param1,param2);
      }
      
      public function getSampleText(param1:String) : String
      {
         return this.m_defaultContext.getSampleText(param1);
      }
      
      public function getViewNames() : Array
      {
         return this.m_defaultContext.getViewNames();
      }
      
      public function getLookNames() : Array
      {
         return this.m_defaultContext.getLookNames();
      }
      
      public function getDialog(param1:String, param2:String = null) : DynamicDialog
      {
         return this.m_defaultContext.getDialog(param1,param2);
      }
      
      public function getErrorList() : ParserErrorList
      {
         return this.m_errorList;
      }
      
      public function clearErrors() : void
      {
         this.m_errorList = new ParserErrorList();
      }
      
      protected function addError(param1:String) : void
      {
         this.m_errorList.addError(param1);
      }
      
      protected function addWarning(param1:String) : void
      {
         this.m_errorList.addWarning(param1);
      }
   }
}

