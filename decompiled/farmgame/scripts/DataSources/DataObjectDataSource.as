package DataSources
{
   import DataObjects.BaseDataObject;
   import flash.net.registerClassAlias;
   import flash.utils.IDataInput;
   import flash.utils.IDataOutput;
   import flash.utils.IExternalizable;
   import flash.utils.getQualifiedClassName;
   import mx.utils.DescribeTypeCache;
   
   public class DataObjectDataSource extends BaseDataSource implements IExternalizable
   {
      
      public function DataObjectDataSource(param1:BaseDataObject = null)
      {
         super();
         if(param1)
         {
            m_internalData = param1;
         }
      }
      
      public static function convertDataObjectArrayToDataSourceArray(param1:Array) : Array
      {
         var _loc3_:BaseDataObject = null;
         var _loc2_:Array = new Array();
         for each(_loc3_ in param1)
         {
            _loc2_.push(new DataObjectDataSource(_loc3_));
         }
         return _loc2_;
      }
      
      public static function parseDataObjectAttributesToObject(param1:BaseDataObject, param2:Boolean = false) : Object
      {
         var variable:XML = null;
         var childrenArray:Array = null;
         var childName:String = null;
         var dataObject:BaseDataObject = param1;
         var includeChildren:Boolean = param2;
         var result:Object = {};
         var typeDescription:XML = DescribeTypeCache.describeType(dataObject).typeDescription;
         var childrenNames:Array = [];
         for each(variable in typeDescription.variable)
         {
            if(variable.metadata.(@name == "XmlAttribute").length() > 0)
            {
               if(dataObject.isSet(variable.@name))
               {
                  result[variable.@name] = String(dataObject[variable.@name]);
               }
            }
            else if(dataObject[variable.@name] is BaseDataObject)
            {
               childrenNames.push(variable.@name);
            }
         }
         if(includeChildren)
         {
            childrenArray = [];
            for each(childName in childrenNames)
            {
               childrenArray.push(parseDataObjectAttributesToObject(dataObject[childName],true));
            }
            if(childrenArray.length > 0)
            {
               result["children_from_xml"] = childrenArray;
            }
         }
         return result;
      }
      
      public static function registerAlias() : void
      {
         registerClassAlias("DataSources.DataObjectDataSource",DataObjectDataSource);
      }
      
      public function writeExternal(param1:IDataOutput) : void
      {
         param1.writeObject(m_internalData);
      }
      
      public function readExternal(param1:IDataInput) : void
      {
         m_internalData = param1.readObject();
      }
      
      override public function getData(... rest) : *
      {
         var _loc2_:* = m_internalData;
         var _loc3_:uint = 0;
         while(_loc3_ < rest.length && _loc2_ != null)
         {
            if(!(rest[_loc3_] is String))
            {
               throw new ArgumentError("call to getData with non-string parameter");
            }
            if(_loc2_.hasOwnProperty(rest[_loc3_]))
            {
               _loc2_ = _loc2_[rest[_loc3_]];
            }
            else
            {
               _loc2_ = null;
            }
            _loc3_++;
         }
         if(_loc2_ is BaseDataObject)
         {
            _loc2_ = new DataObjectDataSource(_loc2_);
         }
         return _loc2_;
      }
      
      override public function getInt(... rest) : int
      {
         var _loc2_:int = super.getInt.apply(null,rest);
         if(_loc2_ == BaseDataObject.NUMERIC_DEFAULT_VALUE)
         {
            _loc2_ = 0;
         }
         return _loc2_;
      }
      
      override public function getNumber(... rest) : Number
      {
         var _loc2_:Number = super.getNumber.apply(null,rest);
         if(_loc2_ == BaseDataObject.NUMERIC_DEFAULT_VALUE)
         {
            _loc2_ = 0;
         }
         return _loc2_;
      }
      
      override public function hasData(... rest) : Boolean
      {
         var _loc2_:* = m_internalData;
         var _loc3_:Boolean = false;
         var _loc4_:uint = 0;
         while(_loc4_ < rest.length && _loc2_ != null)
         {
            if(!(rest[_loc4_] is String))
            {
               throw new ArgumentError("call to getData with non-string parameter");
            }
            if(_loc2_.hasOwnProperty(rest[_loc4_]))
            {
               _loc2_ = _loc2_[rest[_loc4_]];
            }
            else
            {
               _loc2_ = null;
            }
            _loc4_++;
         }
         if(_loc2_ is int || _loc2_ is Number)
         {
            _loc3_ = _loc2_ != BaseDataObject.NUMERIC_DEFAULT_VALUE;
         }
         else
         {
            _loc3_ = _loc2_ != null;
         }
         return _loc3_;
      }
      
      override public function hasProperty(param1:String) : Boolean
      {
         return (m_internalData as BaseDataObject).isSet(param1);
      }
      
      override public function getAttributesHash(param1:Boolean = false) : Object
      {
         return parseDataObjectAttributesToObject(m_internalData,param1);
      }
      
      public function getDataObjectDescription() : XML
      {
         return DescribeTypeCache.describeType(m_internalData).typeDescription;
      }
      
      public function getDataObjectQualifiedClassName() : String
      {
         return getQualifiedClassName(m_internalData);
      }
   }
}

