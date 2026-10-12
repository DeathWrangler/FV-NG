package Replay
{
   public class ArrayUtils
   {
      
      public function ArrayUtils()
      {
         super();
      }
      
      public static function genWith(generator:Function, maxSize:int = 30) : Array
      {
         var object:Object = null;
         var arrayLength:int = IntUtils.genBetween(0,maxSize);
         var result:Array = new Array();
         for(var i:int = 0; i < arrayLength; i++)
         {
            object = generator.call();
            result.push(object);
         }
         return result;
      }
      
      public static function validElements(elements:Array) : Boolean
      {
         var obj:IValidateable = null;
         var result:Boolean = true;
         for(var i:int = 0; i < elements.length; i++)
         {
            obj = elements[i];
            result &&= obj.isValid();
         }
         return result;
      }
      
      public static function intersection(arr1:Array, arr2:Array) : Array
      {
         var j:uint = 0;
         var result:Array = new Array();
         for(var i:uint = 0; i < arr1.length; i++)
         {
            for(j = 0; j < arr2.length; j++)
            {
               if(arr1[i] == arr2[j])
               {
                  if(result.indexOf(arr1[i]) == -1)
                  {
                     result.push(arr1[i]);
                  }
               }
            }
         }
         return result;
      }
      
      public static function diff(eq:Function, x:Array, y:Array) : Array
      {
         var subtract0:Array = ArrayUtils.subtract(eq,x,y);
         var subtract1:Array = ArrayUtils.subtract(eq,y,x);
         return ArrayUtils.combine(subtract0,subtract1);
      }
      
      public static function subtract(eq:Function, x:Array, y:Array) : Array
      {
         var found:Boolean = false;
         var currentValue:Object = null;
         var j:int = 0;
         var otherValue:Object = null;
         var result:Array = new Array();
         for(var i:int = 0; i < x.length; i++)
         {
            found = false;
            currentValue = x[i];
            for(j = 0; j < y.length; j++)
            {
               otherValue = y[j];
               if(eq(currentValue,otherValue))
               {
                  found = true;
               }
            }
            if(found == false)
            {
               if(result.indexOf(currentValue) == -1)
               {
                  result.push(currentValue);
               }
            }
         }
         return result;
      }
      
      public static function combine(x:Array, y:Array) : Array
      {
         var value:Object = null;
         var result:Array = new Array();
         for(var i:int = 0; i < x.length; i++)
         {
            value = x[i];
            result.push(value);
         }
         for(i = 0; i < y.length; i++)
         {
            value = y[i];
            result.push(value);
         }
         return result;
      }
      
      public static function concat(arrayOfArrays:Array) : Array
      {
         var currentArray:Array = null;
         var j:int = 0;
         var element:Object = null;
         var result:Array = new Array();
         for(var i:int = 0; i < arrayOfArrays.length; i++)
         {
            currentArray = arrayOfArrays[i];
            for(j = 0; j < currentArray.length; j++)
            {
               element = currentArray[j];
               result.push(element);
            }
         }
         return result;
      }
      
      public static function clear(array:Array) : void
      {
         for(var i:int = 0; i < array.length; i++)
         {
            array.pop();
         }
      }
      
      public static function copy(source:Array, dest:Array) : void
      {
         var i:int = 0;
         for(ArrayUtils.clear(dest); i < source.length; )
         {
            dest.push(source[i]);
            i++;
         }
      }
      
      public static function vectorToArray(sourceVector:*) : Array
      {
         var result:Array = [];
         var length:int = int(sourceVector.length);
         for(var index:int = 0; index < length; index++)
         {
            result.push(sourceVector[index]);
         }
         return result;
      }
      
      public static function arrayToVectorObject(sourceArray:Array) : Vector.<Object>
      {
         var result:Vector.<Object> = new Vector.<Object>();
         var length:int = int(sourceArray.length);
         for(var index:int = 0; index < length; index++)
         {
            result.push(sourceArray[index]);
         }
         return result;
      }
      
      public static function shuffle(sourceArray:Array) : void
      {
         var rand:uint = 0;
         var tmpElement:* = undefined;
         var tmpLen:uint = sourceArray.length;
         while(tmpLen > 0)
         {
            rand = Math.floor(Math.random() * tmpLen);
            tmpLen--;
            if(rand != tmpLen)
            {
               tmpElement = sourceArray[rand];
               sourceArray[rand] = sourceArray[tmpLen];
               sourceArray[tmpLen] = tmpElement;
            }
         }
      }
      
      public static function trace_r(obj:*, indent:String = "") : void
      {
         var prop:String = null;
         for(prop in obj)
         {
            trace_r(obj[prop],indent + "  ");
         }
      }
   }
}

