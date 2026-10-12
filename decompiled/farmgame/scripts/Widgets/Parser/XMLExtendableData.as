package Widgets.Parser
{
   import flash.geom.Point;
   import flash.utils.Dictionary;
   
   public class XMLExtendableData
   {
      
      public static const STR_TOKEN_TAG_EXTENDABLE_DATA:String = "ExtendableData";
      
      public static const STR_TOKEN_TAG_NODE:String = "node";
      
      public static const STR_TOKEN_TAG_VAR:String = "var";
      
      public static const STR_TOKEN_ARRAY_SEPARATOR:String = ",";
      
      public static const STR_TOKEN_COLOR_PREFIX:String = "#";
      
      public static const STR_TOKEN_NESTED_KEYVALUEPAIR_SEPARATOR:String = ":";
      
      public static const STR_NAMESPACE_SEPARATOR:String = ".";
      
      public static const STR_DEFAULT_XDNODE_NAME:String = "default";
      
      public static const STR_DEFAULT_KEY_NAME:String = "default";
      
      public static const STR_RECT_TOP:String = "top";
      
      public static const STR_RECT_LEFT:String = "left";
      
      public static const STR_RECT_RIGHT:String = "right";
      
      public static const STR_RECT_BOTTOM:String = "bottom";
      
      private static const BOOL_DEBUG_TRACE:Boolean = false;
      
      private static const BOOL_DEBUG_UNIT_TEST:Boolean = false;
      
      private var m_xml:XMLList;
      
      private var m_rawXml:XML;
      
      private var m_dic:Dictionary = null;
      
      public function XMLExtendableData(xml:XML, bParseNow:Boolean = true)
      {
         super();
         this.m_rawXml = xml;
         if(bParseNow)
         {
            this.parse();
         }
      }
      
      private static function getRawValue(xmlActualElement:XML, xmlXDNode:XML, aTokenValues:Array, sKey:String) : String
      {
         var sValue:String = null;
         var node:XMLList = null;
         var sRawString:String = null;
         if(xmlActualElement != null)
         {
            sValue = xmlActualElement.attribute(sKey);
            if(sValue != null && sValue != "")
            {
               sRawString = sValue;
            }
         }
         if(sRawString == null)
         {
            while(xmlXDNode != null)
            {
               node = xmlXDNode[STR_TOKEN_TAG_VAR].(@sKey == sKey);
               if(node.length() > 0)
               {
                  sRawString = node.@sValue;
                  break;
               }
               xmlXDNode = xmlXDNode.parent();
            }
         }
         if(sRawString != null && aTokenValues != null)
         {
            sRawString = ReplaceTokens(sRawString,aTokenValues);
         }
         return sRawString;
      }
      
      public static function getNumberFromNode(xmlActualElement:XML, xmlXDNode:XML, aTokenValues:Array, sKey:String, nDefaultValue:Number = NaN) : Number
      {
         var sRawValue:String = null;
         var nResult:Number = nDefaultValue;
         if(xmlXDNode != null)
         {
            sRawValue = XMLExtendableData.getRawValue(xmlActualElement,xmlXDNode,aTokenValues,sKey);
            nResult = convertTokenToNumber(sRawValue,nDefaultValue);
         }
         return nResult;
      }
      
      public static function convertTokenToNumber(sRawValue:String, nDefaultValue:Number = NaN) : Number
      {
         var nResult:Number = nDefaultValue;
         if(sRawValue != null)
         {
            nResult = Number(sRawValue);
         }
         return nResult;
      }
      
      public static function getStringFromNode(xmlActualElement:XML, xmlXDNode:XML, aTokenValues:Array, sKey:String = "default", sDefaultValue:String = "") : String
      {
         var sRawValue:String = null;
         var sResult:String = sDefaultValue;
         if(xmlXDNode != null)
         {
            sRawValue = XMLExtendableData.getRawValue(xmlActualElement,xmlXDNode,aTokenValues,sKey);
            sResult = convertTokenToString(sRawValue,sDefaultValue);
         }
         return sResult;
      }
      
      public static function convertTokenToString(sRawValue:String, sDefaultValue:String = "default") : String
      {
         var sResult:String = sDefaultValue;
         if(sRawValue != null)
         {
            sResult = String(sRawValue);
         }
         return sResult;
      }
      
      public static function getBooleanFromNode(xmlActualElement:XML, xmlXDNode:XML, aTokenValues:Array, sKey:String = "default", bDefaultValue:Boolean = false) : Boolean
      {
         var sRawValue:String = null;
         var bResult:Boolean = bDefaultValue;
         if(xmlXDNode != null)
         {
            sRawValue = XMLExtendableData.getRawValue(xmlActualElement,xmlXDNode,aTokenValues,sKey);
            bResult = convertTokenToBoolean(sRawValue,bDefaultValue);
         }
         return bResult;
      }
      
      public static function convertTokenToBoolean(sRawValue:String, bDefaultValue:Boolean = false) : Boolean
      {
         var bResult:Boolean = bDefaultValue;
         if(sRawValue != null)
         {
            sRawValue = sRawValue.toLowerCase();
            switch(sRawValue)
            {
               case "true":
                  bResult = true;
                  break;
               default:
                  bResult = false;
            }
         }
         return bResult;
      }
      
      public static function getColorFromNode(xmlActualElement:XML, xmlXDNode:XML, aTokenValues:Array, sKey:String = "default", uDefaultValue:uint = 65280) : uint
      {
         var sRawValue:String = null;
         var uResult:uint = uDefaultValue;
         if(xmlXDNode != null)
         {
            sRawValue = XMLExtendableData.getRawValue(xmlActualElement,xmlXDNode,aTokenValues,sKey);
            uResult = convertTokenToColor(sRawValue,uDefaultValue);
         }
         return uResult;
      }
      
      public static function convertTokenToColor(sRawValue:String, uDefaultValue:uint = 65280) : uint
      {
         var uResult:uint = uDefaultValue;
         if(sRawValue != null)
         {
            sRawValue = sRawValue.replace(STR_TOKEN_COLOR_PREFIX,"0x");
            uResult = uint(sRawValue);
         }
         return uResult;
      }
      
      public static function getPointFromNode(xmlActualElement:XML, xmlXDNode:XML, aTokenValues:Array, sKey:String = "default", ptDefaultValue:Point = null) : Point
      {
         var sRawValue:String = null;
         var aResult:Array = null;
         var ptResult:Point = ptDefaultValue;
         if(xmlXDNode != null)
         {
            sRawValue = XMLExtendableData.getRawValue(xmlActualElement,xmlXDNode,aTokenValues,sKey);
            aResult = convertTokenToArrayOfTokens(sRawValue,null);
            if(aResult != null && aResult.length >= 2)
            {
               aResult = convertArrayOfTokensToNumbers(aResult);
               if(aResult != null)
               {
                  ptResult = new Point(aResult[0],aResult[1]);
               }
            }
         }
         return ptResult;
      }
      
      public static function getRectFromNode(xmlActualElement:XML, xmlXDNode:XML, aTokenValues:Array, sKey:String = "default", aDefaultValue:Array = null) : Array
      {
         return getArrayOfKeyValuePairsFromNode(xmlActualElement,xmlXDNode,aTokenValues,sKey,aDefaultValue);
      }
      
      public static function getArrayOfTokensFromNode(xmlActualElement:XML, xmlXDNode:XML, aTokenValues:Array, sKey:String = "default", aDefaultValue:Array = null) : Array
      {
         var sRawValue:String = null;
         var aResult:Array = aDefaultValue;
         if(xmlXDNode != null)
         {
            sRawValue = XMLExtendableData.getRawValue(xmlActualElement,xmlXDNode,aTokenValues,sKey);
            aResult = convertTokenToArrayOfTokens(sRawValue,aDefaultValue);
         }
         return aResult;
      }
      
      public static function convertTokenToArrayOfTokens(sRawValue:String, aDefaultValue:Array = null) : Array
      {
         var aResult:Array = aDefaultValue;
         if(sRawValue != null)
         {
            aResult = sRawValue.split(STR_TOKEN_ARRAY_SEPARATOR);
         }
         return aResult;
      }
      
      public static function convertArrayOfTokensDynamicly(aTokens:Array, aDefaultValue:Array = null, convertTokenFunction:Function = null) : Array
      {
         var nIndex:Number = NaN;
         var aResult:Array = aDefaultValue;
         if(convertTokenFunction != null)
         {
            if(aTokens != null && aTokens.length > 0)
            {
               for(nIndex = 0; nIndex < aTokens.length; nIndex++)
               {
                  aTokens[nIndex] = convertTokenFunction(aTokens[nIndex]);
               }
               aResult = aTokens;
            }
         }
         return aResult;
      }
      
      public static function getArrayOfNumbersFromNode(xmlActualElement:XML, xmlXDNode:XML, aTokenValues:Array = null, sKey:String = "default", aDefaultValue:Array = null) : Array
      {
         var sRawValue:String = null;
         var aResult:Array = aDefaultValue;
         if(xmlXDNode != null)
         {
            sRawValue = XMLExtendableData.getRawValue(xmlActualElement,xmlXDNode,aTokenValues,sKey);
            aResult = convertTokenToArrayOfTokens(sRawValue,aDefaultValue);
            aResult = convertArrayOfTokensToNumbers(aResult);
         }
         return aResult;
      }
      
      public static function convertArrayOfTokensToNumbers(aTokens:Array, aDefaultValue:Array = null) : Array
      {
         return convertArrayOfTokensDynamicly(aTokens,aDefaultValue,convertTokenToNumber);
      }
      
      public static function getArrayOfBooleansFromNode(xmlActualElement:XML, xmlXDNode:XML, aTokenValues:Array = null, sKey:String = "default", aDefaultValue:Array = null) : Array
      {
         var sRawValue:String = null;
         var aResult:Array = aDefaultValue;
         if(xmlXDNode != null)
         {
            sRawValue = XMLExtendableData.getRawValue(xmlActualElement,xmlXDNode,aTokenValues,sKey);
            aResult = convertTokenToArrayOfTokens(sRawValue,aDefaultValue);
            aResult = convertArrayOfTokensToBooleans(aResult);
         }
         return aResult;
      }
      
      public static function convertArrayOfTokensToBooleans(aTokens:Array, aDefaultValue:Array = null) : Array
      {
         return convertArrayOfTokensDynamicly(aTokens,aDefaultValue,convertTokenToBoolean);
      }
      
      public static function getArrayOfColorsFromNode(xmlActualElement:XML, xmlXDNode:XML, aTokenValues:Array = null, sKey:String = "default", aDefaultValue:Array = null) : Array
      {
         var sRawValue:String = null;
         var aResult:Array = aDefaultValue;
         if(xmlXDNode != null)
         {
            sRawValue = XMLExtendableData.getRawValue(xmlActualElement,xmlXDNode,aTokenValues,sKey);
            aResult = convertTokenToArrayOfTokens(sRawValue,aDefaultValue);
            aResult = convertArrayOfTokensToColors(aResult);
         }
         return aResult;
      }
      
      public static function convertArrayOfTokensToColors(aTokens:Array, aDefaultValue:Array = null) : Array
      {
         return convertArrayOfTokensDynamicly(aTokens,aDefaultValue,convertTokenToColor);
      }
      
      public static function getArrayOfKeyValuePairsFromNode(xmlActualElement:XML, xmlXDNode:XML, aTokenValues:Array = null, sKey:String = "default", aDefaultValue:Array = null) : Array
      {
         var sRawValue:String = null;
         var aResult:Array = aDefaultValue;
         if(xmlXDNode != null)
         {
            sRawValue = XMLExtendableData.getRawValue(xmlActualElement,xmlXDNode,aTokenValues,sKey);
            aResult = convertTokenToArrayOfTokens(sRawValue,aDefaultValue);
            aResult = convertArrayOfTokensToKeyValuePairs(aResult);
         }
         return aResult;
      }
      
      public static function convertArrayOfTokensToKeyValuePairs(aTokens:Array, aDefaultValue:Array = null) : Array
      {
         var aFinal:Array = null;
         var nIndex:Number = NaN;
         var aTmpKeyValue:Array = null;
         var aResult:Array = aDefaultValue;
         if(aTokens != null && aTokens.length > 0)
         {
            aFinal = new Array();
            for(nIndex = 0; nIndex < aTokens.length; nIndex++)
            {
               aTmpKeyValue = convertTokenToKeyValuePair(aTokens[nIndex]);
               if(aTmpKeyValue != null && aTmpKeyValue.length >= 2)
               {
                  aFinal[aTmpKeyValue[0]] = aTmpKeyValue[1];
               }
            }
            aResult = aFinal;
         }
         return aResult;
      }
      
      public static function convertTokenToKeyValuePair(sRawValue:String, aDefaultValue:Array = null) : Array
      {
         var aResult:Array = aDefaultValue;
         if(sRawValue != null)
         {
            aResult = sRawValue.split(STR_TOKEN_NESTED_KEYVALUEPAIR_SEPARATOR);
            if(aResult == null || aResult.length < 2)
            {
               aResult = aDefaultValue;
            }
         }
         return aResult;
      }
      
      public static function ReplaceTokens(sText:String, aTokenValues:Array) : String
      {
         var key:int = 0;
         var times:Number = NaN;
         var stringResult:String = sText;
         if(stringResult.indexOf("{") >= 0)
         {
            if(aTokenValues)
            {
               for(key = 0; key < aTokenValues.length; key++)
               {
                  times = 0;
                  if(stringResult)
                  {
                     while(stringResult.indexOf("{" + key + "}") >= 0 && times < 10)
                     {
                        times++;
                        stringResult = stringResult.replace("{" + key + "}",aTokenValues[key]);
                     }
                  }
               }
            }
         }
         return stringResult;
      }
      
      private function dtrace(sText:String) : void
      {
         if(BOOL_DEBUG_TRACE)
         {
         }
      }
      
      public function parse() : void
      {
         var bDoParse:Boolean = this.m_dic == null ? true : false;
         if(bDoParse)
         {
            this.m_dic = new Dictionary();
            this.dtrace("BEGIN XMLExtendableData:buildDictionary() ---------------");
            this.buildDictionary(this.m_rawXml);
            this.dtrace("END XMLExtendableData:buildDictionary()------------------");
            if(BOOL_DEBUG_UNIT_TEST)
            {
               this.unitTest();
            }
         }
      }
      
      private function buildDictionary(inputXml:XML = null, sVarName:String = "") : void
      {
         var children:XMLList = null;
         var tmpXml:XML = null;
         var sTagName:String = null;
         if(inputXml != null)
         {
            children = inputXml.children();
            for each(tmpXml in children)
            {
               sTagName = tmpXml.name();
               switch(sTagName)
               {
                  case STR_TOKEN_TAG_EXTENDABLE_DATA:
                     this.buildDictionary(tmpXml,sVarName);
                     break;
                  case STR_TOKEN_TAG_NODE:
                     this.dtrace("SAVE Link: " + sVarName + tmpXml.@sName);
                     this.m_dic[sVarName + tmpXml.@sName] = tmpXml;
                     this.buildDictionary(tmpXml,sVarName + tmpXml.@sName + STR_NAMESPACE_SEPARATOR);
                     break;
                  case STR_TOKEN_TAG_VAR:
                     this.dtrace(sVarName + tmpXml.@sKey + " = " + tmpXml.@sValue);
               }
            }
         }
      }
      
      public function getXDNodeByName(sXDNodeName:String) : XML
      {
         return this.m_dic[sXDNodeName];
      }
      
      public function getNumber(xmlActualElement:XML, sXDNodeName:String = "default", aTokenValues:Array = null, sKey:String = "default", nDefaultValue:Number = -1) : Number
      {
         return getNumberFromNode(xmlActualElement,this.getXDNodeByName(sXDNodeName),aTokenValues,sKey,nDefaultValue);
      }
      
      public function getString(xmlActualElement:XML, sXDNodeName:String = "default", aTokenValues:Array = null, sKey:String = "default", sDefaultValue:String = "") : String
      {
         return getStringFromNode(xmlActualElement,this.getXDNodeByName(sXDNodeName),aTokenValues,sKey,sDefaultValue);
      }
      
      public function getBoolean(xmlActualElement:XML, sXDNodeName:String = "default", aTokenValues:Array = null, sKey:String = "default", bDefaultValue:Boolean = false) : Boolean
      {
         return getBooleanFromNode(xmlActualElement,this.getXDNodeByName(sXDNodeName),aTokenValues,sKey,bDefaultValue);
      }
      
      public function getColor(xmlActualElement:XML, sXDNodeName:String = "default", aTokenValues:Array = null, sKey:String = "default", uDefaultValue:uint = 65280) : uint
      {
         return getColorFromNode(xmlActualElement,this.getXDNodeByName(sXDNodeName),aTokenValues,sKey,uDefaultValue);
      }
      
      public function getPoint(xmlActualElement:XML, sXDNodeName:String = "default", aTokenValues:Array = null, sKey:String = "default", ptDefaultValue:Point = null) : Point
      {
         return getPointFromNode(xmlActualElement,this.getXDNodeByName(sXDNodeName),aTokenValues,sKey,ptDefaultValue);
      }
      
      public function getRect(xmlActualElement:XML, sXDNodeName:String = "default", aTokenValues:Array = null, sKey:String = "default", aDefaultValue:Array = null) : Array
      {
         return getRectFromNode(xmlActualElement,this.getXDNodeByName(sXDNodeName),aTokenValues,sKey,aDefaultValue);
      }
      
      public function getArrayOfTokens(xmlActualElement:XML, sXDNodeName:String = "default", aTokenValues:Array = null, sKey:String = "default", aDefaultValue:Array = null) : Array
      {
         return getArrayOfTokensFromNode(xmlActualElement,this.getXDNodeByName(sXDNodeName),aTokenValues,sKey,aDefaultValue);
      }
      
      public function getArrayOfNumbers(xmlActualElement:XML, sXDNodeName:String = "default", aTokenValues:Array = null, sKey:String = "default", aDefaultValue:Array = null) : Array
      {
         return getArrayOfNumbersFromNode(xmlActualElement,this.getXDNodeByName(sXDNodeName),aTokenValues,sKey,aDefaultValue);
      }
      
      public function getArrayOfBooleans(xmlActualElement:XML, sXDNodeName:String = "default", aTokenValues:Array = null, sKey:String = "default", aDefaultValue:Array = null) : Array
      {
         return getArrayOfBooleansFromNode(xmlActualElement,this.getXDNodeByName(sXDNodeName),aTokenValues,sKey,aDefaultValue);
      }
      
      public function getArrayOfColors(xmlActualElement:XML, sXDNodeName:String = "default", aTokenValues:Array = null, sKey:String = "default", aDefaultValue:Array = null) : Array
      {
         return getArrayOfColorsFromNode(xmlActualElement,this.getXDNodeByName(sXDNodeName),aTokenValues,sKey,aDefaultValue);
      }
      
      public function getArrayOfKeyValuePairs(xmlActualElement:XML, sXDNodeName:String = "default", aTokenValues:Array = null, sKey:String = "default", aDefaultValue:Array = null) : Array
      {
         return getArrayOfKeyValuePairsFromNode(xmlActualElement,this.getXDNodeByName(sXDNodeName),aTokenValues,sKey,aDefaultValue);
      }
      
      private function unitTest() : void
      {
         var i:Number = NaN;
         var aScopes:Array = ["base","base.unit","base.unit.test"];
         var aKeys:Array = new Array();
         aKeys["sText"] = this.getString;
         aKeys["nInt"] = this.getNumber;
         aKeys["nFloat"] = this.getNumber;
         aKeys["nNegFloat"] = this.getNumber;
         aKeys["nFloatNoZero"] = this.getNumber;
         aKeys["uColor"] = this.getColor;
         aKeys["bFailOnOne"] = this.getBoolean;
         aKeys["bFailOnZero"] = this.getBoolean;
         aKeys["btrue"] = this.getBoolean;
         aKeys["bTrue"] = this.getBoolean;
         aKeys["bFALSE"] = this.getBoolean;
         aKeys["bOther"] = this.getBoolean;
         aKeys["ptOffset"] = this.getPoint;
         aKeys["ptOffset"] = this.getArrayOfNumbers;
         aKeys["aKeywords"] = this.getArrayOfTokens;
         aKeys["aColors"] = this.getArrayOfColors;
         aKeys["aBools"] = this.getArrayOfBooleans;
         aKeys["aKeyValuePairs"] = this.getArrayOfKeyValuePairs;
         var k:String = null;
         var funct:Function = null;
         for(k in aKeys)
         {
            for(i = 0; i < aScopes.length; i++)
            {
            }
         }
      }
   }
}

