package fl.managers
{
   import fl.core.UIComponent;
   import flash.text.TextFormat;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   import flash.utils.getQualifiedSuperclassName;
   
   public class StyleManager
   {
      
      private static var _instance:StyleManager;
      
      private var classToInstancesDict:Dictionary;
      
      private var globalStyles:Object;
      
      private var styleToClassesHash:Object;
      
      private var classToStylesDict:Dictionary;
      
      private var classToDefaultStylesDict:Dictionary;
      
      public function StyleManager()
      {
         super();
         styleToClassesHash = {};
         classToInstancesDict = new Dictionary(true);
         classToStylesDict = new Dictionary(true);
         classToDefaultStylesDict = new Dictionary(true);
         globalStyles = UIComponent.getStyleDefinition();
      }
      
      public static function clearComponentStyle(component:Object, name:String) : void
      {
         var classDef:Class = getClassDef(component);
         var styleHash:Object = getInstance().classToStylesDict[classDef];
         if(styleHash != null && styleHash[name] != null)
         {
            delete styleHash[name];
            invalidateComponentStyle(classDef,name);
         }
      }
      
      private static function getClassDef(component:Object) : Class
      {
         if(component is Class)
         {
            return component as Class;
         }
         try
         {
            return getDefinitionByName(getQualifiedClassName(component)) as Class;
         }
         catch(e:Error)
         {
            if(component is UIComponent)
            {
               try
               {
                  return component.loaderInfo.applicationDomain.getDefinition(getQualifiedClassName(component)) as Class;
               }
               catch(e:Error)
               {
               }
            }
         }
         return null;
      }
      
      public static function clearStyle(name:String) : void
      {
         setStyle(name,null);
      }
      
      public static function setComponentStyle(component:Object, name:String, style:Object) : void
      {
         var classDef:Class = getClassDef(component);
         var styleHash:Object = getInstance().classToStylesDict[classDef];
         if(styleHash == null)
         {
            styleHash = getInstance().classToStylesDict[classDef] = {};
         }
         if(styleHash == style)
         {
            return;
         }
         styleHash[name] = style;
         invalidateComponentStyle(classDef,name);
      }
      
      private static function setSharedStyles(instance:UIComponent) : void
      {
         var n:String = null;
         var inst:StyleManager = getInstance();
         var classDef:Class = getClassDef(instance);
         var styles:Object = inst.classToDefaultStylesDict[classDef];
         for(n in styles)
         {
            instance.setSharedStyle(n,getSharedStyle(instance,n));
         }
      }
      
      public static function getComponentStyle(component:Object, name:String) : Object
      {
         var classDef:Class = getClassDef(component);
         var styleHash:Object = getInstance().classToStylesDict[classDef];
         return styleHash == null ? null : styleHash[name];
      }
      
      private static function getInstance() : StyleManager
      {
         if(_instance == null)
         {
            _instance = new StyleManager();
         }
         return _instance;
      }
      
      private static function invalidateComponentStyle(componentClass:Class, name:String) : void
      {
         var obj:Object = null;
         var instance:UIComponent = null;
         var instances:Dictionary = getInstance().classToInstancesDict[componentClass];
         if(instances == null)
         {
            return;
         }
         for(obj in instances)
         {
            instance = obj as UIComponent;
            if(instance != null)
            {
               instance.setSharedStyle(name,getSharedStyle(instance,name));
            }
         }
      }
      
      private static function invalidateStyle(name:String) : void
      {
         var classRef:Object = null;
         var classes:Dictionary = getInstance().styleToClassesHash[name];
         if(classes == null)
         {
            return;
         }
         for(classRef in classes)
         {
            invalidateComponentStyle(Class(classRef),name);
         }
      }
      
      public static function registerInstance(instance:UIComponent) : void
      {
         var target:Class = null;
         var defaultStyles:Object = null;
         var styleToClasses:Object = null;
         var n:String = null;
         var inst:StyleManager = getInstance();
         var classDef:Class = getClassDef(instance);
         if(classDef == null)
         {
            return;
         }
         if(inst.classToInstancesDict[classDef] == null)
         {
            inst.classToInstancesDict[classDef] = new Dictionary(true);
            target = classDef;
            while(defaultStyles == null)
            {
               if(target["getStyleDefinition"] != null)
               {
                  defaultStyles = target["getStyleDefinition"]();
                  break;
               }
               try
               {
                  target = instance.loaderInfo.applicationDomain.getDefinition(getQualifiedSuperclassName(target)) as Class;
               }
               catch(err:Error)
               {
                  try
                  {
                     target = getDefinitionByName(getQualifiedSuperclassName(target)) as Class;
                  }
                  catch(e:Error)
                  {
                     defaultStyles = UIComponent.getStyleDefinition();
                     break;
                  }
               }
            }
            styleToClasses = inst.styleToClassesHash;
            for(n in defaultStyles)
            {
               if(styleToClasses[n] == null)
               {
                  styleToClasses[n] = new Dictionary(true);
               }
               styleToClasses[n][classDef] = true;
            }
            inst.classToDefaultStylesDict[classDef] = defaultStyles;
            inst.classToStylesDict[classDef] = {};
         }
         inst.classToInstancesDict[classDef][instance] = true;
         setSharedStyles(instance);
      }
      
      public static function getStyle(name:String) : Object
      {
         return getInstance().globalStyles[name];
      }
      
      private static function getSharedStyle(instance:UIComponent, name:String) : Object
      {
         var classDef:Class = getClassDef(instance);
         var inst:StyleManager = getInstance();
         var style:Object = inst.classToStylesDict[classDef][name];
         if(style != null)
         {
            return style;
         }
         style = inst.globalStyles[name];
         if(style != null)
         {
            return style;
         }
         return inst.classToDefaultStylesDict[classDef][name];
      }
      
      public static function setStyle(name:String, style:Object) : void
      {
         var styles:Object = getInstance().globalStyles;
         if(styles[name] === style && !(style is TextFormat))
         {
            return;
         }
         styles[name] = style;
         invalidateStyle(name);
      }
   }
}

