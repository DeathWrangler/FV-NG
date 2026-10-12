package Classes.ZItem
{
   import Engine.Managers.ErrorManager;
   
   public class ExpansionPlotLimits
   {
      
      private static const ATTR_NAME:String = "@name";
      
      private static const ATTR_INDEX:String = "@index";
      
      private static const ATTR_PLOTS:String = "@plots";
      
      private static const ATTR_SQUARES:String = "@squares";
      
      private static const NODE_TERRAIN:String = "terrain";
      
      private static const NODE_LIMIT_MAPPING:String = "limitMapping";
      
      private static const NODE_LIMIT_MAP:String = "limitMap";
      
      private static const NODE_PLOT_LIMIT:String = "plotLimit";
      
      public static const DEFAULT_PLOT_LIMIT_GROUP_NAME:String = "ground";
      
      public static const DEFAULT_PLOT_LIMIT_GROUP_INDEX:int = 0;
      
      private var m_plotLimits:Array;
      
      private var m_limitMappingByLimitGroupName:Array;
      
      private var m_limitMappingByTerrainName:Array;
      
      private var m_limitMappingByTerrainCode:Array;
      
      public function ExpansionPlotLimits(expansionName:String, plotLimitsList:XMLList)
      {
         var node:XML = null;
         var nodeName:String = null;
         this.m_plotLimits = new Array();
         this.m_limitMappingByLimitGroupName = new Array();
         this.m_limitMappingByTerrainName = new Array();
         this.m_limitMappingByTerrainCode = new Array();
         super();
         for each(node in plotLimitsList)
         {
            nodeName = node.name();
            if(nodeName == NODE_LIMIT_MAPPING)
            {
               this.parseLimitMapping(expansionName,node);
            }
            else if(nodeName == NODE_PLOT_LIMIT)
            {
               this.parsePlotLimit(expansionName,node);
            }
         }
      }
      
      private function parseLimitMapping(expansionName:String, node:XML) : void
      {
         var limitMap:XML = null;
         var terrainXML:XML = null;
         var tmpName:String = null;
         var tmpIndex:int = -1;
         var tmpTerrainName:String = null;
         var terrainList:XMLList = null;
         var terrainCodes:Array = null;
         var terrainCode:int = 0;
         for each(limitMap in node.child(NODE_LIMIT_MAP))
         {
            tmpName = limitMap[ATTR_NAME];
            tmpIndex = int(limitMap[ATTR_INDEX]);
            this.m_limitMappingByLimitGroupName[tmpName] = tmpIndex;
            terrainList = limitMap.terrains.child(NODE_TERRAIN);
            for each(terrainXML in terrainList)
            {
               tmpTerrainName = terrainXML.toString();
               terrainCodes = Global.farmGameSettingsManager.convertArrayTerrainNamesToCodes([tmpTerrainName]);
               if(terrainCodes.length > 0)
               {
                  this.m_limitMappingByTerrainName[tmpTerrainName] = tmpIndex;
                  for each(terrainCode in terrainCodes)
                  {
                     this.m_limitMappingByTerrainCode[terrainCode] = tmpIndex;
                  }
               }
            }
         }
      }
      
      private function parsePlotLimit(expansionName:String, plotLimitXML:XML) : void
      {
         var squares:String = null;
         var terrains:XMLList = null;
         var terrain:XML = null;
         var terrainLimitGroupIndex:int = 0;
         if(plotLimitXML.hasOwnProperty(ATTR_SQUARES))
         {
            squares = String(plotLimitXML[ATTR_SQUARES]);
            this.m_plotLimits[squares] = new Array();
            terrains = plotLimitXML.terrains.child(NODE_TERRAIN);
            if(plotLimitXML.hasOwnProperty(ATTR_PLOTS))
            {
               this.m_plotLimits[squares][ExpansionPlotLimits.DEFAULT_PLOT_LIMIT_GROUP_INDEX] = String(plotLimitXML[ATTR_PLOTS]);
            }
            else if(Boolean(terrains) && terrains.length() > 0)
            {
               for each(terrain in terrains)
               {
                  if(terrain.hasOwnProperty(ATTR_NAME) && terrain.hasOwnProperty(ATTR_PLOTS))
                  {
                     terrainLimitGroupIndex = this.getLimitGroupIndexByLimitGroupName(String(terrain[ATTR_NAME]));
                     this.m_plotLimits[squares][terrainLimitGroupIndex] = String(terrain[ATTR_PLOTS]);
                  }
               }
            }
            else
            {
               ErrorManager.addError("ExpansionPlotLimits: Bad Expansion plotLimit data node: " + expansionName + ": " + String(plotLimitXML[ATTR_SQUARES]));
            }
         }
      }
      
      public function getLimitGroupIndexByLimitGroupName(terrainLimitGroupName:String) : int
      {
         var result:int = DEFAULT_PLOT_LIMIT_GROUP_INDEX;
         if(this.m_limitMappingByLimitGroupName.hasOwnProperty(terrainLimitGroupName))
         {
            result = int(this.m_limitMappingByLimitGroupName[terrainLimitGroupName]);
         }
         return result;
      }
      
      public function getLimitGroupNameByLimitGroupIndex(terrainLimitGroupIndex:int) : String
      {
         var key:String = null;
         var result:String = DEFAULT_PLOT_LIMIT_GROUP_NAME;
         for(key in this.m_limitMappingByLimitGroupName)
         {
            if(this.m_limitMappingByLimitGroupName[key] == terrainLimitGroupIndex)
            {
               result = key;
               break;
            }
         }
         return result;
      }
      
      public function getLimitGroupIndexByTerrainName(terrainName:String) : int
      {
         var result:int = ExpansionPlotLimits.DEFAULT_PLOT_LIMIT_GROUP_INDEX;
         if(this.m_limitMappingByTerrainName.hasOwnProperty(terrainName))
         {
            result = int(this.m_limitMappingByTerrainName[terrainName]);
         }
         return result;
      }
      
      public function getLimitGroupIndexByTerrainCode(terrainCode:int) : int
      {
         var result:int = ExpansionPlotLimits.DEFAULT_PLOT_LIMIT_GROUP_INDEX;
         if(this.m_limitMappingByTerrainCode.hasOwnProperty(terrainCode))
         {
            result = int(this.m_limitMappingByTerrainCode[terrainCode]);
         }
         return result;
      }
      
      public function getLimitGroupNameByTerrainName(terrainName:String) : String
      {
         var limitGroupIndex:int = 0;
         var result:String = ExpansionPlotLimits.DEFAULT_PLOT_LIMIT_GROUP_NAME;
         if(this.m_limitMappingByTerrainName.hasOwnProperty(terrainName))
         {
            limitGroupIndex = int(this.m_limitMappingByTerrainName[terrainName]);
            result = this.getLimitGroupNameByLimitGroupIndex(limitGroupIndex);
         }
         return result;
      }
      
      public function getLimitGroupNameByTerrainCode(terrainCode:int) : String
      {
         var limitGroupIndex:int = 0;
         var result:String = ExpansionPlotLimits.DEFAULT_PLOT_LIMIT_GROUP_NAME;
         if(this.m_limitMappingByTerrainCode.hasOwnProperty(terrainCode))
         {
            limitGroupIndex = int(this.m_limitMappingByTerrainCode[terrainCode]);
            result = this.getLimitGroupNameByLimitGroupIndex(limitGroupIndex);
         }
         return result;
      }
      
      public function getPlotLimitByTerrainName(squares:String, terrainName:String) : int
      {
         var result:int = 0;
         var terrainGroupIndex:int = this.getLimitGroupIndexByTerrainName(terrainName);
         if(this.m_plotLimits.hasOwnProperty(squares) && Boolean(this.m_plotLimits[squares].hasOwnProperty(terrainGroupIndex)))
         {
            result = parseInt(this.m_plotLimits[squares][terrainGroupIndex]);
         }
         return result;
      }
      
      public function getPlotLimitByTerrainCode(squares:String, terrainCode:int) : int
      {
         var result:int = 0;
         var terrainGroupIndex:int = this.getLimitGroupIndexByTerrainCode(terrainCode);
         if(this.m_plotLimits.hasOwnProperty(squares) && Boolean(this.m_plotLimits[squares].hasOwnProperty(terrainGroupIndex)))
         {
            result = parseInt(this.m_plotLimits[squares][terrainGroupIndex]);
         }
         return result;
      }
      
      public function getPlotLimitsForSquares(squares:String) : Array
      {
         var result:Array = null;
         if(this.m_plotLimits.hasOwnProperty(squares))
         {
            result = this.m_plotLimits[squares];
         }
         return result;
      }
      
      public function getSmallestFarmSizeInSquares() : String
      {
         var squares:String = null;
         var tmpInt:int = 0;
         var resultString:String = null;
         var resultInt:int = 0;
         if(this.m_plotLimits)
         {
            for(squares in this.m_plotLimits)
            {
               tmpInt = int(squares);
               if(resultString == null || tmpInt < resultInt)
               {
                  resultString = squares;
                  resultInt = tmpInt;
               }
            }
         }
         return resultString;
      }
      
      public function getCurrentWorldPlotLimitsData() : Array
      {
         return this.m_plotLimits;
      }
   }
}

