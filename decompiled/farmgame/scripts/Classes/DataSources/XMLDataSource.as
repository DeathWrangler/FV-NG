package Classes.DataSources
{
   import DataSources.BaseDataSource;
   import Managers.FarmGameSettingsManager;
   
   public class XMLDataSource extends BaseDataSource
   {
      
      public function XMLDataSource(rawXML:XML)
      {
         super();
         if(rawXML)
         {
            m_internalData = rawXML;
            return;
         }
         throw new ArgumentError("attempt to initialize XMLDataSource with null");
      }
      
      private static function convertXMLListToDataSourceArray(xmlList:XMLList) : Array
      {
         var xml:XML = null;
         var resultArray:Array = new Array();
         for each(xml in xmlList)
         {
            resultArray.push(new XMLDataSource(xml));
         }
         return resultArray;
      }
      
      override public function getData(... dataHierarchy) : *
      {
         var data:XMLList = new XMLList(m_internalData);
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
            else if(data.hasOwnProperty("@" + dataHierarchy[i]))
            {
               data = data["@" + dataHierarchy[i]];
            }
            else
            {
               data = null;
            }
            i++;
         }
         var dataValue:* = null;
         if(data is XMLList)
         {
            if(data.attributes().length() == 0 && data.hasSimpleContent())
            {
               dataValue = data.toString();
            }
            else if(data.length() == 1)
            {
               dataValue = new XMLDataSource(data[0]);
            }
            else
            {
               dataValue = convertXMLListToDataSourceArray(data);
            }
         }
         return dataValue;
      }
      
      override public function getArray(... dataHierarchy) : Array
      {
         var resultArray:Array = [];
         var data:XMLList = new XMLList(m_internalData);
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
            else if(data.hasOwnProperty("@" + dataHierarchy[i]))
            {
               data = data["@" + dataHierarchy[i]];
            }
            else
            {
               data = null;
            }
            i++;
         }
         if(data is XMLList)
         {
            resultArray = convertXMLListToDataSourceArray(data);
         }
         return resultArray;
      }
      
      override public function hasData(... dataHierarchy) : Boolean
      {
         var data:XMLList = new XMLList(m_internalData);
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
            else if(data.hasOwnProperty("@" + dataHierarchy[i]))
            {
               data = data["@" + dataHierarchy[i]];
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
      
      override public function hasProperty(property:String) : Boolean
      {
         return Boolean(super.hasProperty(property)) || Boolean(super.hasProperty("@" + property));
      }
      
      override public function getAttributesHash(includeChildren:Boolean = false) : Object
      {
         return FarmGameSettingsManager.parseXmlAttributesToObject(m_internalData,includeChildren);
      }
   }
}

