package Classes.util
{
   import Engine.Managers.ErrorManager;
   import flash.utils.describeType;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   
   public class ObjectUtil
   {
      
      private static var typeCache:Object = {};
      
      public function ObjectUtil()
      {
         super();
      }
      
      public static function describeType(obj:*) : XML
      {
         var className:String = null;
         var type:XML = null;
         var result:XML = null;
         if(obj is String)
         {
            className = obj;
         }
         else
         {
            className = getQualifiedClassName(obj);
         }
         if(className in typeCache)
         {
            result = typeCache[className] as XML;
         }
         else
         {
            if(obj is String)
            {
               obj = getDefinitionByName(obj);
            }
            if(obj)
            {
               type = describeType(obj);
               typeCache[className] = type;
               result = type;
            }
            else
            {
               ErrorManager.addError("Could not find class: " + className);
            }
         }
         return result;
      }
      
      public static function isDynamic(obj:*) : Boolean
      {
         var type:XML = null;
         var result:Boolean = false;
         if(obj)
         {
            type = ObjectUtil.describeType(obj);
            result = type.@isDynamic.toString() == "true";
         }
         return result;
      }
      
      public static function objectToString(obj:*) : String
      {
         var type:XML = null;
         var str:String = "";
         if(obj == null)
         {
            str = "null";
         }
         else
         {
            type = ObjectUtil.describeType(obj);
            if(type)
            {
               if(type.@isDynamic.toString() == "true")
               {
                  str = type.@name + "(" + dynamicObjectToString(obj) + ")";
               }
               else
               {
                  str = "[" + type.@name + "]";
               }
            }
            else
            {
               str = "unknown type";
            }
         }
         return str;
      }
      
      private static function dynamicObjectToString(obj:*) : String
      {
         var array:Array = null;
         var i:int = 0;
         var l:int = 0;
         var prop:String = null;
         var result:String = "";
         if(obj)
         {
            if(obj is int || obj is Number)
            {
               result = (obj as Number).toString();
            }
            else if(obj is String)
            {
               result = obj as String;
            }
            else if(obj is Array)
            {
               result = "Array[";
               array = obj as Array;
               i = 0;
               l = int(array.length);
               while(i < l)
               {
                  result += dynamicObjectToString(array[i]);
                  i++;
               }
               result += "]";
            }
            else if(obj is Object)
            {
               result = getQualifiedClassName(obj) + "(";
               for(prop in obj)
               {
                  result += prop + "=" + dynamicObjectToString(obj[prop]);
               }
               result += ")";
            }
         }
         else
         {
            result = "null";
         }
         return result;
      }
      
      public static function getObjectKeys(obj:Object) : Array
      {
         var objectKey:String = null;
         var result:Array = [];
         if(obj)
         {
            for(objectKey in obj)
            {
               result.push(objectKey);
            }
         }
         return result;
      }
      
      public static function pathExists(rootElem:Object, ... path) : Boolean
      {
         return extractPath(rootElem,path) != null;
      }
      
      public static function extractPath(rootElem:Object, ... path) : Object
      {
         var name:String = null;
         if(path)
         {
            while(path.length == 1 && path[0] is Array)
            {
               path = path[0];
            }
         }
         var node:Object = null;
         if(rootElem != null)
         {
            node = rootElem;
            for each(name in path)
            {
               if(!(name in node))
               {
                  node = null;
                  break;
               }
               node = node[name] as Object;
            }
         }
         return node;
      }
      
      public static function objectHasProperties(obj:Object) : Boolean
      {
         var key:* = undefined;
         var result:Boolean = false;
         if(obj)
         {
            var _loc4_:int = 0;
            var _loc5_:* = obj;
            for(key in _loc5_)
            {
               result = true;
            }
         }
         return result;
      }
      
      public static function uniClone(source:Object) : Object
      {
         var key:String = null;
         var clonedObj:Object = {};
         for(key in source)
         {
            clonedObj[key] = source[key];
         }
         return clonedObj;
      }
   }
}

