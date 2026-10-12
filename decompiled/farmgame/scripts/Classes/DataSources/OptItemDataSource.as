package Classes.DataSources
{
   import DataSources.BaseDataSource;
   import flash.utils.getQualifiedClassName;
   
   public class OptItemDataSource extends BaseDataSource
   {
      
      public function OptItemDataSource(data:Object)
      {
         super();
         if(data)
         {
            m_internalData = data;
            return;
         }
         throw new ArgumentError("attempt to initialize OptItemDataSource with null");
      }
      
      private static function convertToDataSourceArray(optItems:Object) : Array
      {
         var item:Object = null;
         var resultArray:Array = new Array();
         if(getQualifiedClassName(optItems) == "Array")
         {
            for each(item in optItems)
            {
               if(getQualifiedClassName(item) == "Classes.DataSources::OptItemDataSource")
               {
                  resultArray.push(item);
               }
               else
               {
                  resultArray.push(new OptItemDataSource(item));
               }
            }
         }
         else if(getQualifiedClassName(optItems) == "Classes.DataSources::OptItemDataSource")
         {
            resultArray.push(optItems);
         }
         else
         {
            resultArray.push(new OptItemDataSource(optItems));
         }
         return resultArray;
      }
      
      override public function getData(... dataHierarchy) : *
      {
         var data:* = m_internalData;
         var i:uint = 0;
         while(i < dataHierarchy.length && data != null)
         {
            if(!(dataHierarchy[i] is String))
            {
               throw new ArgumentError("call to getData with non-string parameter");
            }
            if(data.hasOwnProperty(dataHierarchy[i]))
            {
               data = data[dataHierarchy[i]];
            }
            else
            {
               data = null;
            }
            i++;
         }
         var dataValue:* = null;
         if(data)
         {
            if(data is String)
            {
               dataValue = data;
            }
            else if(data is Object)
            {
               dataValue = new OptItemDataSource(data);
            }
         }
         return dataValue;
      }
      
      override public function getArray(... dataHierarchy) : Array
      {
         var resultArray:Array = [];
         var data:* = m_internalData;
         var i:uint = 0;
         while(i < dataHierarchy.length && data != null)
         {
            if(!(dataHierarchy[i] is String))
            {
               throw new ArgumentError("call to getData with non-string parameter");
            }
            if(data.hasOwnProperty(dataHierarchy[i]))
            {
               data = data[dataHierarchy[i]];
            }
            else
            {
               data = null;
            }
            i++;
         }
         if(data is Object)
         {
            resultArray = convertToDataSourceArray(data);
         }
         return resultArray;
      }
      
      override public function hasData(... dataHierarchy) : Boolean
      {
         var data:Object = m_internalData;
         var isDataDefined:Boolean = false;
         var i:uint = 0;
         while(i < dataHierarchy.length && data != null)
         {
            if(!(dataHierarchy[i] is String))
            {
               throw new ArgumentError("call to getData with non-string parameter");
            }
            if(data.hasOwnProperty(dataHierarchy[i]))
            {
               data = data[dataHierarchy[i]];
            }
            else
            {
               data = null;
            }
            i++;
         }
         if(data != null)
         {
            isDataDefined = true;
         }
         return isDataDefined;
      }
      
      override public function getBoolean(... dataHierarchy) : Boolean
      {
         var rawData:String = this.getData.apply(null,dataHierarchy);
         return rawData == "true";
      }
      
      override public function toString() : String
      {
         var asString:String = "";
         if(m_internalData)
         {
            if(m_internalData.hasOwnProperty("value"))
            {
               asString = m_internalData.value.toString();
            }
            else
            {
               asString = m_internalData.toString();
            }
         }
         return asString;
      }
      
      override public function hasProperty(property:String) : Boolean
      {
         return Boolean(super.hasProperty(property));
      }
      
      override public function getAttributesHash(includeChildren:Boolean = false) : Object
      {
         return m_internalData;
      }
   }
}

