package com.troyer.widget
{
   import com.troyer.widget.controller.BaseWidgetController;
   import com.troyer.widget.controller.DynamicDialog;
   import com.troyer.widget.style.BaseStyle;
   import com.troyer.widget.style.DialogLook;
   import com.troyer.widget.view.BaseWidgetView;
   import com.troyer.widget.view.ViewBuilder;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   
   public class MT4DContext
   {
      
      private var m_name:String;
      
      internal var m_baseContext:MT4DContext;
      
      internal var m_styles:Dictionary;
      
      internal var m_looks:Dictionary;
      
      internal var m_views:Dictionary;
      
      internal var m_dialogs:Dictionary;
      
      internal var m_sampleText:Dictionary;
      
      public function MT4DContext(param1:String)
      {
         super();
         this.m_name = param1;
         this.m_styles = new Dictionary();
         this.m_looks = new Dictionary();
         this.m_views = new Dictionary();
         this.m_dialogs = new Dictionary();
         this.m_sampleText = new Dictionary();
      }
      
      protected static function addError(param1:String) : void
      {
         MT4DManager.getInstance().getErrorList().addError(param1);
      }
      
      protected static function addWarning(param1:String) : void
      {
         MT4DManager.getInstance().getErrorList().addWarning(param1);
      }
      
      public function reset() : void
      {
         this.m_styles = new Dictionary();
         this.m_looks = new Dictionary();
         this.m_views = new Dictionary();
         this.m_dialogs = new Dictionary();
         this.m_sampleText = new Dictionary();
      }
      
      public function destroy() : void
      {
         this.m_styles = null;
         this.m_looks = null;
         this.m_views = null;
         this.m_dialogs = null;
         this.m_sampleText = null;
      }
      
      public function getName() : String
      {
         return this.m_name;
      }
      
      public function getBaseContext() : MT4DContext
      {
         return this.m_baseContext;
      }
      
      public function setBaseContext(param1:MT4DContext) : void
      {
         this.m_baseContext = param1;
      }
      
      public function addStyles(param1:Dictionary, param2:Boolean = false) : void
      {
         var _loc3_:String = null;
         for(_loc3_ in param1)
         {
            if(!param2 && this.m_styles[_loc3_] != null)
            {
               addError("A style with the name \'" + _loc3_ + "\' already exists in the global styles list.");
            }
            this.m_styles[_loc3_] = param1[_loc3_];
         }
      }
      
      public function addLooks(param1:Dictionary, param2:Boolean = false) : void
      {
         var _loc3_:String = null;
         for(_loc3_ in param1)
         {
            if(!param2 && this.m_looks[_loc3_] != null)
            {
               addError("A dialog look with the name \'" + _loc3_ + "\' already exists in the global dialog looks list.");
            }
            this.m_looks[_loc3_] = param1[_loc3_];
         }
      }
      
      public function addViews(param1:Dictionary, param2:Boolean = false) : void
      {
         var _loc3_:String = null;
         for(_loc3_ in param1)
         {
            if(!param2 && this.m_views[_loc3_] != null)
            {
               addError("A view with the name \'" + _loc3_ + "\' already exists in the global views list.");
            }
            this.m_views[_loc3_] = param1[_loc3_];
         }
      }
      
      public function addDialogs(param1:Dictionary, param2:Boolean = false) : void
      {
         var _loc3_:String = null;
         for(_loc3_ in param1)
         {
            if(!param2 && this.m_dialogs[_loc3_] != null)
            {
               addError("A dialog with the name \'" + _loc3_ + "\' already exists in the global dialogs list.");
            }
            this.m_dialogs[_loc3_] = param1[_loc3_];
         }
      }
      
      public function addSampleText(param1:Dictionary, param2:Boolean = false) : void
      {
         var _loc3_:String = null;
         for(_loc3_ in param1)
         {
            if(!param2 && this.m_sampleText[_loc3_] != null)
            {
               addError("A sample text key with the name \'" + _loc3_ + "\' already exists in the global sample text list.");
            }
            this.m_sampleText[_loc3_] = param1[_loc3_];
         }
      }
      
      public function findViewDefinition(param1:String) : Dictionary
      {
         return this.m_views[param1];
      }
      
      public function getStyle(param1:String) : BaseStyle
      {
         var _loc6_:String = null;
         var _loc2_:BaseStyle = null;
         var _loc3_:Dictionary = null;
         var _loc4_:MT4DConfig = MT4DManager.getInstance().config;
         var _loc5_:String = _loc4_.getLocaleCode();
         if((Boolean(_loc5_)) && _loc5_ != "en_US")
         {
            _loc6_ = param1 + "__" + _loc4_.getLocaleCode();
            if(this.m_styles.hasOwnProperty(_loc6_))
            {
               _loc3_ = this.m_styles[_loc6_];
            }
            if(Boolean(_loc3_ == null) && Boolean(this.m_baseContext) && this.m_baseContext.m_styles.hasOwnProperty(_loc6_))
            {
               _loc3_ = this.m_baseContext.m_styles[_loc6_];
            }
         }
         if(_loc3_ == null && this.m_styles.hasOwnProperty(param1))
         {
            _loc3_ = this.m_styles[param1];
         }
         if(Boolean(_loc3_ == null) && Boolean(this.m_baseContext) && this.m_baseContext.m_styles.hasOwnProperty(param1))
         {
            _loc3_ = this.m_baseContext.m_styles[param1];
         }
         if(_loc3_)
         {
            _loc2_ = new BaseStyle(this);
            _loc2_.deserialize(_loc3_);
         }
         return _loc2_;
      }
      
      public function getStyleNames() : Array
      {
         var _loc2_:String = null;
         var _loc1_:Array = new Array();
         if(this.m_styles)
         {
            for(_loc2_ in this.m_styles)
            {
               _loc1_.push(_loc2_);
            }
         }
         return _loc1_;
      }
      
      public function getLook(param1:String) : DialogLook
      {
         var _loc2_:DialogLook = null;
         var _loc3_:Dictionary = null;
         if(this.m_looks.hasOwnProperty(param1))
         {
            _loc3_ = this.m_looks[param1];
         }
         if(Boolean(_loc3_ == null) && Boolean(this.m_baseContext) && this.m_baseContext.m_looks.hasOwnProperty(param1))
         {
            _loc3_ = this.m_baseContext.m_looks[param1];
         }
         if(_loc3_)
         {
            _loc2_ = new DialogLook(this);
            _loc2_.deserialize(_loc3_);
         }
         return _loc2_;
      }
      
      public function getDefaultLook() : DialogLook
      {
         return this.getLook("default");
      }
      
      public function getLookNames() : Array
      {
         var _loc2_:String = null;
         var _loc1_:Array = new Array();
         if(this.m_looks)
         {
            for(_loc2_ in this.m_looks)
            {
               _loc1_.push(_loc2_);
            }
         }
         return _loc1_;
      }
      
      public function getView(param1:String, param2:DialogLook = null) : BaseWidgetView
      {
         var _loc3_:BaseWidgetView = null;
         var _loc4_:Dictionary = null;
         if(this.m_views.hasOwnProperty(param1))
         {
            _loc4_ = this.m_views[param1];
         }
         if(Boolean(_loc4_ == null) && Boolean(this.m_baseContext) && this.m_baseContext.m_views.hasOwnProperty(param1))
         {
            _loc4_ = this.m_baseContext.m_views[param1];
         }
         if(_loc4_)
         {
            _loc3_ = ViewBuilder.buildView(_loc4_,param2,this);
         }
         else
         {
            addError("View \'" + param1 + "\' not found.");
         }
         return _loc3_;
      }
      
      public function getSampleText(param1:String) : String
      {
         return this.m_sampleText[param1] as String;
      }
      
      public function getViewNames() : Array
      {
         var _loc2_:String = null;
         var _loc1_:Array = new Array();
         if(this.m_views)
         {
            for(_loc2_ in this.m_views)
            {
               _loc1_.push(_loc2_);
            }
         }
         return _loc1_;
      }
      
      public function getDialog(param1:String, param2:String = null) : DynamicDialog
      {
         var look:DialogLook = null;
         var view:BaseWidgetView = null;
         var dialogClass:Class = null;
         var i:int = 0;
         var dict:Dictionary = null;
         var importName:String = null;
         var name:String = param1;
         var classPath:String = param2;
         var result:DynamicDialog = null;
         var dialogDef:Dictionary = null;
         if(this.m_dialogs.hasOwnProperty(name))
         {
            dialogDef = this.m_dialogs[name];
         }
         if(Boolean(dialogDef == null) && Boolean(this.m_baseContext) && this.m_baseContext.hasOwnProperty(name))
         {
            dialogDef = this.m_baseContext.m_dialogs[name];
         }
         if(dialogDef)
         {
            if(dialogDef[Constants.ATTRIBUTES][Constants.ATTRIBUTE_VIEW])
            {
               look = null;
               if(dialogDef[Constants.ATTRIBUTES].hasOwnProperty(Constants.ATTRIBUTE_LOOK))
               {
                  look = this.getLook(dialogDef[Constants.ATTRIBUTES][Constants.ATTRIBUTE_VIEW]);
                  if(look == null)
                  {
                     addError("Look \'" + name + "\' not found.");
                     look = this.getLook("default");
                  }
               }
               view = this.getView(dialogDef[Constants.ATTRIBUTES][Constants.ATTRIBUTE_VIEW],look);
               if(view)
               {
                  if(classPath == null)
                  {
                     if(dialogDef[Constants.ATTRIBUTES][Constants.ATTRIBUTE_CLASSPATH])
                     {
                        classPath = dialogDef[Constants.ATTRIBUTES][Constants.ATTRIBUTE_CLASSPATH];
                     }
                     else
                     {
                        classPath = getQualifiedClassName(DynamicDialog);
                     }
                  }
                  try
                  {
                     dialogClass = getDefinitionByName(classPath) as Class;
                  }
                  catch(error:Error)
                  {
                     addError("Unable to find custom dialog class \'" + classPath + "\'.  Did you misspell it?");
                     return null;
                  }
                  result = new dialogClass(view);
                  if(result is DynamicDialog)
                  {
                     if(look)
                     {
                        result.setLook(look);
                     }
                     i = 0;
                     while(i < dialogDef[Constants.CHILDREN].length)
                     {
                        dict = dialogDef[Constants.CHILDREN][i];
                        if(dict[Constants.TAG_NAME] == Constants.TAG_IMPORT)
                        {
                           if(dict.hasOwnProperty(Constants.ATTRIBUTE_NAME))
                           {
                              importName = dict[Constants.ATTRIBUTE_NAME];
                              if(dict.hasOwnProperty(Constants.ATTRIBUTE_TYPE))
                              {
                                 switch(dict[Constants.ATTRIBUTE_TYPE])
                                 {
                                    case Constants.IMPORT_TYPE_VIEW:
                                       result.addImport(importName,this.getView(importName));
                                       break;
                                    case Constants.IMPORT_TYPE_STYLE:
                                       result.addImport(importName,this.getStyle(importName));
                                       break;
                                    case Constants.IMPORT_TYPE_DIALOG:
                                       result.addImport(importName,this.getDialog(importName));
                                 }
                              }
                              else
                              {
                                 addError("Dialog " + name + " has import with no type");
                              }
                           }
                           else
                           {
                              addError("Dialog " + name + " has import with no name");
                           }
                        }
                        i++;
                     }
                     result.setAttribute(BaseWidgetController.ATTRIBUTE_NAME,name);
                     result.initialize();
                     result.setChildAttributes(dialogDef[Constants.CHILDREN]);
                     result.setup();
                  }
                  else
                  {
                     view.destroy();
                     view = null;
                     result = null;
                     addError("classPath: " + classPath + " not instance of Dialog for dialog \'" + name + "\'.");
                  }
               }
            }
         }
         return result;
      }
   }
}

